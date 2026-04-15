import 'dart:async';

import 'package:flutter/foundation.dart';

import 'agent_catalog.dart';
import 'command_parser.dart';
import 'models.dart';
import 'persistence.dart';

class AutoCompanyStore extends ChangeNotifier {
  AutoCompanyStore._(
    this._repository,
    this._snapshot, {
    required this.stageDelay,
  });

  final AppRepository _repository;
  AppSnapshot _snapshot;
  final Map<String, Future<void>> _activeRuns = {};
  final Duration stageDelay;
  Timer? _remotePollingTimer;
  bool _remoteRefreshInFlight = false;
  BackendHealth? _backendHealth;
  AgentGraph? _selectedAgentGraph;

  static Future<AutoCompanyStore> load(
    AppRepository repository, {
    Duration stageDelay = const Duration(milliseconds: 700),
  }) async {
    final loaded = await repository.load();
    final snapshot = loaded == null
        ? _seedSnapshot()
        : repository.isRemote
        ? _prepareRemoteSnapshot(loaded)
        : _normalizeSnapshot(loaded);
    final store = AutoCompanyStore._(
      repository,
      snapshot,
      stageDelay: stageDelay,
    );
    if (repository.isRemote) {
      await store._refreshBackendHealth();
      store._startRemotePolling();
      await store._refreshSelectedAgentGraph();
    } else {
      store._resumeEligibleOrders();
    }
    return store;
  }

  static Future<AutoCompanyStore> loadRemoteShell(
    AppRepository repository, {
    Duration stageDelay = const Duration(milliseconds: 700),
  }) async {
    final store = AutoCompanyStore._(
      repository,
      _emptySnapshot(),
      stageDelay: stageDelay,
    );
    if (repository.isRemote) {
      await store._refreshBackendHealth();
    }
    return store;
  }

  List<WorkOrder> get orders => List.unmodifiable(_snapshot.orders);

  List<CommandLogEntry> get commandLogs =>
      List.unmodifiable(_snapshot.commandLogs.reversed);

  List<ReportEntry> get allReports {
    final items = <ReportEntry>[];
    for (final order in _snapshot.orders) {
      items.addAll(order.reports);
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<AuditEntry> get allAuditEntries {
    final items = <AuditEntry>[];
    for (final order in _snapshot.orders) {
      items.addAll(order.auditTrail);
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  String? get selectedOrderId => _snapshot.selectedOrderId;

  WorkOrder? get selectedOrder {
    final currentId = _snapshot.selectedOrderId;
    if (currentId == null) {
      return _snapshot.orders.isEmpty ? null : _snapshot.orders.first;
    }
    for (final order in _snapshot.orders) {
      if (order.id == currentId) {
        return order;
      }
    }
    return _snapshot.orders.isEmpty ? null : _snapshot.orders.first;
  }

  List<PendingApprovalItem> get approvalQueue {
    final items = <PendingApprovalItem>[];
    for (final order in _snapshot.orders) {
      for (final approval in order.approvals) {
        if (approval.status == ApprovalStatus.pending) {
          items.add(PendingApprovalItem(order: order, approval: approval));
        }
      }
    }
    items.sort((a, b) => b.approval.createdAt.compareTo(a.approval.createdAt));
    return items;
  }

  bool get isRemoteMode => _repository.isRemote;

  String get modeLabel => isRemoteMode ? 'Backend v1.1' : 'Local MVP';

  String get backendStatusLabel {
    if (!isRemoteMode) {
      return 'Local file state';
    }
    final health = _backendHealth;
    if (health == null) {
      return 'Backend unknown';
    }
    return health.ok ? 'Backend ${health.status}' : 'Backend ${health.status}';
  }

  String? get backendBaseUrl => _backendHealth?.baseUrl;

  int get activeRunCount => isRemoteMode
      ? _snapshot.orders
            .where(
              (item) =>
                  item.status == OrderStatus.inProgress ||
                  item.status == OrderStatus.evaluation ||
                  item.status == OrderStatus.revise,
            )
            .length
      : _activeRuns.length;

  int get pendingApprovalCount => approvalQueue.length;

  int get activeOrderCount => _snapshot.orders
      .where(
        (item) =>
            item.status == OrderStatus.approvalPending ||
            item.status == OrderStatus.planned ||
            item.status == OrderStatus.inProgress ||
            item.status == OrderStatus.evaluation ||
            item.status == OrderStatus.revise,
      )
      .length;

  int get completedCount => _snapshot.orders
      .where((item) => item.status == OrderStatus.completed)
      .length;

  AgentGraph? get selectedAgentGraph {
    if (isRemoteMode) {
      return _selectedAgentGraph;
    }
    final order = selectedOrder;
    return order == null ? null : _buildAgentGraph(order);
  }

  Future<void> reconnectRemote() async {
    if (!isRemoteMode) {
      return;
    }
    await _refreshBackendHealth();
    await _refreshFromRemote();
    _startRemotePolling();
  }

  Future<void> enterRemoteShell() async {
    if (!isRemoteMode) {
      return;
    }
    _remotePollingTimer?.cancel();
    _remotePollingTimer = null;
    _snapshot = _emptySnapshot();
    _selectedAgentGraph = null;
    await _refreshBackendHealth();
    notifyListeners();
  }

  void selectOrder(String orderId) {
    _snapshot.selectedOrderId = orderId;
    notifyListeners();
    if (isRemoteMode) {
      unawaited(_refreshSelectedAgentGraph());
    }
    if (!isRemoteMode) {
      unawaited(_persist());
    }
  }

  Future<WorkOrder> createOrder(OrderDraft draft) async {
    if (isRemoteMode) {
      final nextSnapshot = await _repository.createOrder(draft);
      _applyRemoteSnapshot(nextSnapshot);
      return selectedOrder ?? _snapshot.orders.first;
    }

    final now = DateTime.now();
    final orderId = _nextId('WO');
    final strategicSummary =
        '${draft.assignedSquad} 기준으로 ${draft.targetProduct} 작업 목표를 정렬했다.';
    final planSummary = _buildPlanSummary(draft);
    final order = WorkOrder(
      id: orderId,
      title: draft.title,
      objective: draft.objective,
      targetProduct: draft.targetProduct,
      targetBranch: draft.targetBranch,
      requestedBy: draft.requestedBy,
      sourceChannel: draft.sourceChannel,
      assignedSquad: draft.assignedSquad,
      assignedPersonaLead: defaultLeadForSquad(draft.assignedSquad),
      status: OrderStatus.approvalPending,
      planSummary: planSummary,
      riskProfile: draft.riskProfile,
      planApproved: false,
      createdAt: now,
      updatedAt: now,
      selectedPersonas: defaultPersonasForSquad(draft.assignedSquad),
      stageRecords: [
        StageRecord(
          stage: ExecutionStage.strategicReview,
          state: StageState.completed,
          summary: strategicSummary,
          startedAt: now,
          endedAt: now,
        ),
        StageRecord(
          stage: ExecutionStage.planning,
          state: StageState.completed,
          summary: planSummary,
          startedAt: now,
          endedAt: now,
        ),
        StageRecord(
          stage: ExecutionStage.execution,
          state: StageState.pending,
          summary: '승인 후 자동 실행 대기',
        ),
        StageRecord(
          stage: ExecutionStage.evaluation,
          state: StageState.pending,
          summary: '실행 이후 평가 예정',
        ),
        StageRecord(
          stage: ExecutionStage.revision,
          state: StageState.pending,
          summary: '평가 결과 보정 예정',
        ),
        StageRecord(
          stage: ExecutionStage.completion,
          state: StageState.pending,
          summary: '완료 보고 생성 예정',
        ),
      ],
      reports: [
        _buildReport(
          orderId: orderId,
          stage: ExecutionStage.strategicReview,
          title: 'Strategic framing prepared',
          ownerGroup: '전략군',
          personaLead: 'ceo-bezos',
          summary:
              '${draft.targetProduct} 작업 목표를 전략 언어로 고정하고 ${draft.assignedSquad}를 추천했다.',
          findings: [
            draft.objective,
            'branch target: ${draft.targetBranch}',
            'initial squad: ${draft.assignedSquad}',
          ],
          recommendations: [
            '계획 승인 전에는 구현 실행을 시작하지 않는다.',
            '고위험 플래그가 있으면 risk gate를 유지한다.',
          ],
          createdAt: now,
        ),
        _buildReport(
          orderId: orderId,
          stage: ExecutionStage.planning,
          title: 'Execution plan drafted',
          ownerGroup: '전략군 + 제품군 + 엔지니어링군',
          personaLead: 'cto-vogels',
          summary: planSummary,
          findings: ['approval 이후 자동 연속 실행', 'stage 완료 시 report가 누적 생성'],
          recommendations: ['CEO plan approval 후 runner 시작'],
          createdAt: now,
        ),
      ],
      approvals: [
        ApprovalRecord(
          id: _nextId('AP'),
          orderId: orderId,
          type: ApprovalType.plan,
          status: ApprovalStatus.pending,
          note: '실행계획 승인이 필요합니다.',
          createdAt: now,
        ),
        if (draft.riskProfile.requiresGate)
          ApprovalRecord(
            id: _nextId('AP'),
            orderId: orderId,
            type: ApprovalType.risk,
            status: ApprovalStatus.pending,
            note: '고위험 플래그: ${draft.riskProfile.labels.join(', ')}',
            createdAt: now,
          ),
      ],
      auditTrail: [
        AuditEntry(
          id: _nextId('AU'),
          orderId: orderId,
          message: 'Work order created by ${draft.requestedBy}',
          createdAt: now,
        ),
        AuditEntry(
          id: _nextId('AU'),
          orderId: orderId,
          message: 'Strategic framing drafted by ceo-bezos',
          createdAt: now,
        ),
        AuditEntry(
          id: _nextId('AU'),
          orderId: orderId,
          message: 'Execution plan drafted and queued for approval',
          createdAt: now,
        ),
      ],
    );
    _snapshot.orders.insert(0, order);
    _snapshot.selectedOrderId = order.id;
    await _saveAndNotify();
    return order;
  }

  Future<void> approveFirstPending(String orderId) async {
    final order = _findOrder(orderId);
    if (order == null) {
      return;
    }
    final approval =
        order.pendingApproval(ApprovalType.plan) ??
        order.pendingApproval(ApprovalType.risk);
    if (approval != null) {
      await approveApproval(orderId, approval.id);
    }
  }

  Future<void> approveApproval(String orderId, String approvalId) async {
    if (isRemoteMode) {
      final nextSnapshot = await _repository.approveApproval(
        orderId,
        approvalId,
      );
      _applyRemoteSnapshot(nextSnapshot);
      return;
    }

    final order = _findOrder(orderId);
    if (order == null) {
      return;
    }
    ApprovalRecord? target;
    for (final approval in order.approvals) {
      if (approval.id == approvalId) {
        target = approval;
        break;
      }
    }
    if (target == null) {
      return;
    }

    target.status = ApprovalStatus.approved;
    target.resolvedAt = DateTime.now();
    order.updatedAt = DateTime.now();
    order.auditTrail.insert(
      0,
      AuditEntry(
        id: _nextId('AU'),
        orderId: order.id,
        message: '${target.type.label} approved',
        createdAt: DateTime.now(),
      ),
    );

    if (target.type == ApprovalType.plan) {
      order.planApproved = true;
    }

    if (order.planApproved &&
        order.pendingApproval(ApprovalType.risk) == null) {
      order.status = OrderStatus.planned;
      await _saveAndNotify();
      await _ensureRunner(order.id);
      return;
    }

    order.status = order.pendingApproval(ApprovalType.risk) != null
        ? OrderStatus.hold
        : OrderStatus.approvalPending;
    await _saveAndNotify();
  }

  Future<void> holdOrder(String orderId, {String note = 'Manual hold'}) async {
    if (isRemoteMode) {
      final nextSnapshot = await _repository.holdOrder(orderId, note: note);
      _applyRemoteSnapshot(nextSnapshot);
      return;
    }

    final order = _findOrder(orderId);
    if (order == null) {
      return;
    }
    order.status = OrderStatus.hold;
    order.updatedAt = DateTime.now();
    order.auditTrail.insert(
      0,
      AuditEntry(
        id: _nextId('AU'),
        orderId: order.id,
        message: 'Order held: $note',
        createdAt: DateTime.now(),
      ),
    );
    await _saveAndNotify();
  }

  Future<void> resumeOrder(String orderId) async {
    if (isRemoteMode) {
      final nextSnapshot = await _repository.resumeOrder(orderId);
      _applyRemoteSnapshot(nextSnapshot);
      return;
    }

    final order = _findOrder(orderId);
    if (order == null || !order.planApproved || order.hasPendingApprovals) {
      return;
    }
    order.status = OrderStatus.planned;
    order.updatedAt = DateTime.now();
    order.auditTrail.insert(
      0,
      AuditEntry(
        id: _nextId('AU'),
        orderId: order.id,
        message: 'Order resumed by manual action',
        createdAt: DateTime.now(),
      ),
    );
    await _saveAndNotify();
    await _ensureRunner(order.id);
  }

  Future<String> submitCommand(CommandChannel channel, String input) async {
    if (isRemoteMode) {
      final response = await _repository.submitCommand(channel, input);
      _applyRemoteSnapshot(response.snapshot);
      return response.result;
    }

    final parser = const CommandParser();
    final command = parser.parse(input);
    late final String result;

    if (!command.isValid) {
      result = command.error ?? 'Invalid command';
    } else {
      switch (command.type) {
        case ParsedCommandType.help:
          result = CommandParser.helpText(channel);
          break;
        case ParsedCommandType.newOrder:
          final order = await createOrder(
            OrderDraft(
              title: command.title!,
              objective: command.objective!,
              targetProduct: command.targetProduct ?? 'Mozzy',
              targetBranch: command.targetBranch ?? 'main',
              requestedBy: '${channel.label} operator',
              sourceChannel: channel,
              assignedSquad: 'Feature Delivery',
              riskProfile: RiskProfile(),
            ),
          );
          result = 'Created ${order.id} and queued plan approval.';
          break;
        case ParsedCommandType.approve:
          await approveFirstPending(command.orderId!);
          result = 'Approved next pending gate for ${command.orderId}.';
          break;
        case ParsedCommandType.hold:
          await holdOrder(
            command.orderId!,
            note: command.note ?? 'Manual hold',
          );
          result = 'Held ${command.orderId}.';
          break;
        case ParsedCommandType.resume:
          await resumeOrder(command.orderId!);
          result = 'Resume requested for ${command.orderId}.';
          break;
        case ParsedCommandType.status:
          result = orderStatusLine(command.orderId!);
          break;
        case ParsedCommandType.invalid:
          result = command.error ?? 'Invalid command';
          break;
      }
    }

    _snapshot.commandLogs.add(
      CommandLogEntry(
        id: _nextId('CMD'),
        channel: channel,
        input: input,
        result: result,
        createdAt: DateTime.now(),
      ),
    );
    await _saveAndNotify();
    return result;
  }

  Future<void> assignPersonaLead(String orderId, String persona) async {
    if (isRemoteMode) {
      final nextSnapshot = await _repository.assignPersonaLead(
        orderId,
        persona,
      );
      _applyRemoteSnapshot(nextSnapshot);
      await _refreshSelectedAgentGraph();
      return;
    }

    final order = _findOrder(orderId);
    if (order == null) {
      return;
    }
    _normalizeOrderPersonas(order);
    order.assignedPersonaLead = persona;
    if (!order.selectedPersonas.contains(persona)) {
      order.selectedPersonas.insert(0, persona);
    }
    order.updatedAt = DateTime.now();
    order.auditTrail.insert(
      0,
      AuditEntry(
        id: _nextId('AU'),
        orderId: order.id,
        message: 'Persona lead assigned from dashboard: $persona',
        createdAt: order.updatedAt,
      ),
    );
    await _saveAndNotify();
  }

  Future<void> dispatchPersona(String orderId, String persona) async {
    if (isRemoteMode) {
      final nextSnapshot = await _repository.dispatchPersona(orderId, persona);
      _applyRemoteSnapshot(nextSnapshot);
      await _refreshSelectedAgentGraph();
      return;
    }

    final order = _findOrder(orderId);
    if (order == null) {
      return;
    }
    _normalizeOrderPersonas(order);
    if (!order.selectedPersonas.contains(persona)) {
      order.selectedPersonas.add(persona);
    }
    order.assignedPersonaLead ??= persona;
    order.updatedAt = DateTime.now();
    order.auditTrail.insert(
      0,
      AuditEntry(
        id: _nextId('AU'),
        orderId: order.id,
        message: 'Persona dispatched from dashboard: $persona',
        createdAt: order.updatedAt,
      ),
    );
    await _saveAndNotify();
    if (order.planApproved &&
        !order.hasPendingApprovals &&
        order.status != OrderStatus.completed &&
        order.status != OrderStatus.hold) {
      await _ensureRunner(order.id);
    }
  }

  String orderStatusLine(String orderId) {
    final order = _findOrder(orderId);
    if (order == null) {
      return '$orderId not found';
    }
    return '${order.id} · ${order.status.label} · '
        '${order.completedStages}/${order.stageRecords.length} stages complete';
  }

  Future<void> _ensureRunner(String orderId) {
    final existing = _activeRuns[orderId];
    if (existing != null) {
      return existing;
    }
    final future = _runApprovedChain(orderId).whenComplete(() {
      _activeRuns.remove(orderId);
    });
    _activeRuns[orderId] = future;
    return future;
  }

  Future<void> _runApprovedChain(String orderId) async {
    final order = _findOrder(orderId);
    if (order == null) {
      return;
    }
    order.auditTrail.insert(
      0,
      AuditEntry(
        id: _nextId('AU'),
        orderId: order.id,
        message: 'Auto-run started after approval',
        createdAt: DateTime.now(),
      ),
    );
    await _saveAndNotify();

    for (final stage in const [
      ExecutionStage.execution,
      ExecutionStage.evaluation,
      ExecutionStage.revision,
      ExecutionStage.completion,
    ]) {
      final currentOrder = _findOrder(orderId);
      if (currentOrder == null || currentOrder.hasPendingApprovals) {
        break;
      }
      late final StageRecord record;
      bool found = false;
      for (final item in currentOrder.stageRecords) {
        if (item.stage == stage) {
          record = item;
          found = true;
          break;
        }
      }
      if (!found ||
          record.state == StageState.completed ||
          record.state == StageState.skipped) {
        continue;
      }

      currentOrder.status = _statusForStage(stage);
      currentOrder.updatedAt = DateTime.now();
      record.state = StageState.running;
      record.startedAt ??= DateTime.now();
      record.summary = _runningSummaryForStage(stage);
      currentOrder.auditTrail.insert(
        0,
        AuditEntry(
          id: _nextId('AU'),
          orderId: currentOrder.id,
          message: '${stage.label} started',
          createdAt: DateTime.now(),
        ),
      );
      await _saveAndNotify();
      if (stageDelay > Duration.zero) {
        await Future.delayed(stageDelay);
      }

      final now = DateTime.now();
      record.state = StageState.completed;
      record.endedAt = now;
      record.summary = _completedSummaryForStage(currentOrder, stage);
      currentOrder.reports.add(_buildStageReport(currentOrder, stage, now));
      currentOrder.auditTrail.insert(
        0,
        AuditEntry(
          id: _nextId('AU'),
          orderId: currentOrder.id,
          message: '${stage.label} completed',
          createdAt: now,
        ),
      );
      currentOrder.updatedAt = now;
      if (stage == ExecutionStage.completion) {
        currentOrder.status = OrderStatus.completed;
      }
      await _saveAndNotify();
    }
  }

  void _resumeEligibleOrders() {
    for (final order in _snapshot.orders) {
      _normalizeOrderPersonas(order);
      if (order.planApproved &&
          !order.hasPendingApprovals &&
          order.status != OrderStatus.completed) {
        order.status = OrderStatus.planned;
        for (final record in order.stageRecords) {
          if (record.state == StageState.running) {
            record.state = StageState.pending;
          }
        }
        unawaited(_ensureRunner(order.id));
      }
    }
  }

  WorkOrder? _findOrder(String orderId) {
    for (final order in _snapshot.orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  Future<void> _saveAndNotify() async {
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() => _repository.save(_snapshot);

  Future<void> _refreshBackendHealth() async {
    if (!isRemoteMode) {
      return;
    }
    _backendHealth = await _repository.health();
    notifyListeners();
  }

  void _startRemotePolling() {
    if (!isRemoteMode) {
      return;
    }
    _remotePollingTimer?.cancel();
    _remotePollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_refreshFromRemote());
    });
    unawaited(_refreshFromRemote());
  }

  Future<void> _refreshFromRemote() async {
    if (!isRemoteMode || _remoteRefreshInFlight) {
      return;
    }
    _remoteRefreshInFlight = true;
    try {
      final nextSnapshot = await _repository.fetchSnapshot();
      _applyRemoteSnapshot(nextSnapshot);
      await _refreshSelectedAgentGraph();
      _backendHealth = await _repository.health();
    } catch (error) {
      final health = await _repository.health();
      final status = switch (error) {
        BackendRequestException(:final message) when message.contains('(401)') =>
          'auth-required',
        BackendRequestException(:final message) when message.contains('(403)') =>
          'forbidden',
        _ => health?.status ?? 'unreachable',
      };
      _backendHealth = BackendHealth(
        baseUrl: health?.baseUrl ?? backendBaseUrl ?? '',
        ok: false,
        status: status,
        orchestratorStatus: health?.orchestratorStatus,
      );
      notifyListeners();
    } finally {
      _remoteRefreshInFlight = false;
    }
  }

  void _applyRemoteSnapshot(AppSnapshot nextSnapshot) {
    final previousSelected = _snapshot.selectedOrderId;
    _snapshot = _prepareRemoteSnapshot(nextSnapshot);
    _snapshot.selectedOrderId ??=
        previousSelected ??
        (_snapshot.orders.isNotEmpty ? _snapshot.orders.first.id : null);
    notifyListeners();
  }

  Future<void> _refreshSelectedAgentGraph() async {
    if (!isRemoteMode) {
      return;
    }
    final orderId = _snapshot.selectedOrderId;
    if (orderId == null) {
      _selectedAgentGraph = null;
      notifyListeners();
      return;
    }
    try {
      _selectedAgentGraph = await _repository.fetchAgentGraph(orderId);
      notifyListeners();
    } catch (_) {
      final fallbackOrder = _findOrder(orderId);
      _selectedAgentGraph = fallbackOrder == null
          ? null
          : _buildAgentGraph(fallbackOrder);
      notifyListeners();
    }
  }

  void _normalizeOrderPersonas(WorkOrder order) {
    order.selectedPersonas = List<String>.from(order.selectedPersonas);
    if (order.selectedPersonas.isEmpty) {
      order.selectedPersonas.addAll(
        defaultPersonasForSquad(order.assignedSquad),
      );
    }
    order.assignedPersonaLead ??= defaultLeadForSquad(order.assignedSquad);
    if (!order.selectedPersonas.contains(order.assignedPersonaLead)) {
      order.selectedPersonas.insert(0, order.assignedPersonaLead!);
    }
  }

  String _nextId(String prefix) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '$prefix-$timestamp';
  }

  String _buildPlanSummary(OrderDraft draft) {
    return '목표: ${draft.objective}\n'
        '제품: ${draft.targetProduct}\n'
        '브랜치: ${draft.targetBranch}\n'
        'squad: ${draft.assignedSquad}\n'
        '승인 후 stage를 순차 실행하고 completion report까지 자동 생성한다.';
  }

  String _runningSummaryForStage(ExecutionStage stage) => switch (stage) {
    ExecutionStage.execution => '엔지니어링군과 제품군이 산출물을 정리 중',
    ExecutionStage.evaluation => 'critic-munger와 qa-bach가 결과 검토 중',
    ExecutionStage.revision => '피드백 기반 수정안 반영 중',
    ExecutionStage.completion => '최종 완료 보고를 작성 중',
    _ => '',
  };

  String _completedSummaryForStage(
    WorkOrder order,
    ExecutionStage stage,
  ) => switch (stage) {
    ExecutionStage.execution => '${order.assignedSquad}가 합의된 범위의 실행 산출물을 생성했다.',
    ExecutionStage.evaluation => 'blocker와 잔여 리스크를 평가하고 completion 조건을 확인했다.',
    ExecutionStage.revision => '평가 결과를 반영해 문구와 실행 항목을 보정했다.',
    ExecutionStage.completion => 'HNI CEO에게 제출할 completion report를 생성했다.',
    _ => '',
  };

  OrderStatus _statusForStage(ExecutionStage stage) => switch (stage) {
    ExecutionStage.execution => OrderStatus.inProgress,
    ExecutionStage.evaluation => OrderStatus.evaluation,
    ExecutionStage.revision => OrderStatus.revise,
    ExecutionStage.completion => OrderStatus.completed,
    _ => OrderStatus.planned,
  };

  ReportEntry _buildStageReport(
    WorkOrder order,
    ExecutionStage stage,
    DateTime createdAt,
  ) {
    return switch (stage) {
      ExecutionStage.execution => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Execution artifacts produced',
        ownerGroup: '제품군 + 엔지니어링군',
        personaLead: 'fullstack-dhh',
        summary:
            '${order.assignedSquad}가 ${order.targetProduct}용 실행 산출물을 생성했다.',
        findings: [
          order.objective,
          'branch target: ${order.targetBranch}',
          '연속 실행 규칙 적용',
        ],
        recommendations: ['evaluation 단계에서 blocker만 분리한다.'],
        createdAt: createdAt,
      ),
      ExecutionStage.evaluation => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Evaluation completed',
        ownerGroup: 'QA + 전략군',
        personaLead: 'critic-munger',
        summary: '현재 결과는 합의된 scope 안에서 수용 가능한 상태다.',
        findings: ['scope drift 없음', '추가 승인 요청 없이 다음 stage 진행 가능'],
        recommendations: ['completion report에 잔여 리스크를 명시한다.'],
        createdAt: createdAt,
      ),
      ExecutionStage.revision => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Revision applied',
        ownerGroup: '엔지니어링군 + 제품군',
        personaLead: 'ui-duarte',
        summary: '평가에서 드러난 개선 메모를 반영했다.',
        findings: ['문구/흐름 정합화', 'completion readiness 재확인'],
        recommendations: ['완료 보고로 종료한다.'],
        createdAt: createdAt,
      ),
      ExecutionStage.completion => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Completion report ready',
        ownerGroup: '전략군',
        personaLead: 'ceo-bezos',
        summary: '${order.title} work order가 합의된 stage를 끝까지 완료했다.',
        findings: [
          'order status: Completed',
          '추가 승인 요청 없이 agreed chain finished',
        ],
        recommendations: ['다음 오더를 새로 생성하거나 후속 epic으로 분리한다.'],
        createdAt: createdAt,
      ),
      _ => _buildReport(
        orderId: order.id,
        stage: stage,
        title: stage.label,
        ownerGroup: '전략군',
        personaLead: 'ceo-bezos',
        summary: stage.label,
        findings: const [],
        recommendations: const [],
        createdAt: createdAt,
      ),
    };
  }

  ReportEntry _buildReport({
    required String orderId,
    required ExecutionStage stage,
    required String title,
    required String ownerGroup,
    required String personaLead,
    required String summary,
    required List<String> findings,
    required List<String> recommendations,
    required DateTime createdAt,
  }) {
    return ReportEntry(
      id: _nextId('RP'),
      orderId: orderId,
      stage: stage,
      title: title,
      summary: summary,
      findings: findings,
      recommendations: recommendations,
      ownerGroup: ownerGroup,
      personaLead: personaLead,
      createdAt: createdAt,
    );
  }

  @override
  void dispose() {
    _remotePollingTimer?.cancel();
    super.dispose();
  }
}

AppSnapshot _emptySnapshot() {
  return AppSnapshot(orders: [], commandLogs: []);
}

AppSnapshot _seedSnapshot() {
  final now = DateTime.now();

  final completedOrder = WorkOrder(
    id: 'WO-100',
    title: 'Mozzy V1/V2 status reporting',
    objective: '제품군/엔지니어링군 상태를 정리한다.',
    targetProduct: 'Mozzy',
    targetBranch: 'main + hyperlocal-proposal',
    requestedBy: 'HNI CEO',
    sourceChannel: CommandChannel.dashboard,
    assignedSquad: 'Discovery',
    assignedPersonaLead: defaultLeadForSquad('Discovery'),
    status: OrderStatus.completed,
    planSummary: '승인 후 분석, 평가, 완료 보고까지 자동 연속 처리.',
    riskProfile: RiskProfile(),
    planApproved: true,
    createdAt: now.subtract(const Duration(hours: 5)),
    updatedAt: now.subtract(const Duration(hours: 4)),
    selectedPersonas: defaultPersonasForSquad('Discovery'),
    stageRecords: [
      for (final stage in ExecutionStage.values)
        StageRecord(
          stage: stage,
          state: StageState.completed,
          summary: '${stage.label} 완료',
          startedAt: now.subtract(const Duration(hours: 5)),
          endedAt: now.subtract(const Duration(hours: 4)),
        ),
    ],
    reports: [
      ReportEntry(
        id: 'RP-100',
        orderId: 'WO-100',
        stage: ExecutionStage.completion,
        title: 'Completion report ready',
        summary: '샘플 완료 보고서',
        findings: const ['All stages completed'],
        recommendations: const ['Open next work order'],
        ownerGroup: '전략군',
        personaLead: 'ceo-bezos',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ],
    approvals: [
      ApprovalRecord(
        id: 'AP-100',
        orderId: 'WO-100',
        type: ApprovalType.plan,
        status: ApprovalStatus.approved,
        note: 'Plan approved',
        createdAt: now.subtract(const Duration(hours: 5)),
        resolvedAt: now.subtract(const Duration(hours: 5)),
      ),
    ],
    auditTrail: [
      AuditEntry(
        id: 'AU-100',
        orderId: 'WO-100',
        message: 'Sample completed order restored',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ],
  );

  final pendingOrder = WorkOrder(
    id: 'WO-101',
    title: 'Neighborhood slice smoke run',
    objective: 'V2 neighborhood read slice smoke를 승인 후 자동 수행한다.',
    targetProduct: 'Mozzy',
    targetBranch: 'hyperlocal-proposal',
    requestedBy: 'HNI CEO',
    sourceChannel: CommandChannel.telegram,
    assignedSquad: 'Trust & Readiness',
    assignedPersonaLead: defaultLeadForSquad('Trust & Readiness'),
    status: OrderStatus.approvalPending,
    planSummary: 'smoke checklist를 기준으로 boot부터 completion report까지 연결.',
    riskProfile: RiskProfile(),
    planApproved: false,
    createdAt: now.subtract(const Duration(minutes: 40)),
    updatedAt: now.subtract(const Duration(minutes: 35)),
    selectedPersonas: defaultPersonasForSquad('Trust & Readiness'),
    stageRecords: [
      StageRecord(
        stage: ExecutionStage.strategicReview,
        state: StageState.completed,
        summary: 'slice scope 정리',
        startedAt: now.subtract(const Duration(minutes: 40)),
        endedAt: now.subtract(const Duration(minutes: 39)),
      ),
      StageRecord(
        stage: ExecutionStage.planning,
        state: StageState.completed,
        summary: 'approval 후 연속 실행 plan 생성',
        startedAt: now.subtract(const Duration(minutes: 39)),
        endedAt: now.subtract(const Duration(minutes: 37)),
      ),
      StageRecord(
        stage: ExecutionStage.execution,
        state: StageState.pending,
        summary: 'approval 대기',
      ),
      StageRecord(
        stage: ExecutionStage.evaluation,
        state: StageState.pending,
        summary: 'approval 대기',
      ),
      StageRecord(
        stage: ExecutionStage.revision,
        state: StageState.pending,
        summary: 'approval 대기',
      ),
      StageRecord(
        stage: ExecutionStage.completion,
        state: StageState.pending,
        summary: 'approval 대기',
      ),
    ],
    reports: [
      ReportEntry(
        id: 'RP-101',
        orderId: 'WO-101',
        stage: ExecutionStage.strategicReview,
        title: 'Strategic framing prepared',
        summary: 'Neighborhood read slice를 첫 대상 work order로 설정',
        findings: const ['risk gate 없음', 'approval 후 auto-run'],
        recommendations: const ['CEO가 plan을 승인하면 즉시 실행'],
        ownerGroup: '전략군',
        personaLead: 'ceo-bezos',
        createdAt: now.subtract(const Duration(minutes: 38)),
      ),
    ],
    approvals: [
      ApprovalRecord(
        id: 'AP-101',
        orderId: 'WO-101',
        type: ApprovalType.plan,
        status: ApprovalStatus.pending,
        note: '승인 후 자동 연속 실행 시작',
        createdAt: now.subtract(const Duration(minutes: 36)),
      ),
    ],
    auditTrail: [
      AuditEntry(
        id: 'AU-101',
        orderId: 'WO-101',
        message: 'Pending sample order seeded for demo',
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
    ],
  );

  return AppSnapshot(
    orders: [pendingOrder, completedOrder],
    commandLogs: [
      CommandLogEntry(
        id: 'CMD-100',
        channel: CommandChannel.telegram,
        input: '/status WO-101',
        result: 'WO-101 · Approval Pending · 2/6 stages complete',
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
    ],
    selectedOrderId: 'WO-101',
  );
}

AppSnapshot _normalizeSnapshot(AppSnapshot snapshot) {
  for (final order in snapshot.orders) {
    if (order.selectedPersonas.isEmpty) {
      order.selectedPersonas.addAll(
        defaultPersonasForSquad(order.assignedSquad),
      );
    }
    order.assignedPersonaLead ??= defaultLeadForSquad(order.assignedSquad);
    for (final record in order.stageRecords) {
      if (record.state == StageState.running) {
        record.state = StageState.pending;
      }
    }
    if (!order.planApproved) {
      order.status = OrderStatus.approvalPending;
    } else if (order.hasPendingApprovals) {
      order.status = OrderStatus.hold;
    } else if (order.status != OrderStatus.completed) {
      order.status = OrderStatus.planned;
    }
  }
  if (snapshot.selectedOrderId == null && snapshot.orders.isNotEmpty) {
    snapshot.selectedOrderId = snapshot.orders.first.id;
  }
  return snapshot;
}

AppSnapshot _prepareRemoteSnapshot(AppSnapshot snapshot) {
  snapshot.orders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  for (final order in snapshot.orders) {
    if (order.selectedPersonas.isEmpty) {
      order.selectedPersonas.addAll(
        defaultPersonasForSquad(order.assignedSquad),
      );
    }
    order.assignedPersonaLead ??= defaultLeadForSquad(order.assignedSquad);
  }
  if (snapshot.selectedOrderId == null && snapshot.orders.isNotEmpty) {
    snapshot.selectedOrderId = snapshot.orders.first.id;
  }
  return snapshot;
}

AgentGraph _buildAgentGraph(WorkOrder order) {
  final runningStages = order.stageRecords.where(
    (item) => item.state == StageState.running,
  );
  final currentStageLabel = runningStages.isEmpty
      ? null
      : runningStages.first.stage.label;
  final nodes = agentPersonas.map((descriptor) {
    final matchingReports = order.reports
        .where((report) => report.personaLead == descriptor.persona)
        .toList();
    final latestSummary = matchingReports.isEmpty
        ? null
        : matchingReports.last.summary;
    return AgentGraphNode(
      persona: descriptor.persona,
      group: descriptor.group,
      title: descriptor.title,
      focus: descriptor.focus,
      status: _agentStatusFor(
        order: order,
        persona: descriptor.persona,
        hasRecentReport: matchingReports.isNotEmpty,
      ),
      assigned: order.selectedPersonas.contains(descriptor.persona),
      isLead: order.assignedPersonaLead == descriptor.persona,
      reportCount: matchingReports.length,
      latestSummary: latestSummary,
      currentStageLabel: currentStageLabel,
    );
  }).toList();
  return AgentGraph(
    orderId: order.id,
    orderStatus: order.status.label,
    assignedSquad: order.assignedSquad,
    selectedPersonas: List<String>.from(order.selectedPersonas),
    leadPersona: order.assignedPersonaLead,
    activeStageLabel: currentStageLabel,
    providerMode: 'local-store',
    nodes: nodes,
  );
}

AgentNodeStatus _agentStatusFor({
  required WorkOrder order,
  required String persona,
  required bool hasRecentReport,
}) {
  final isAssigned = order.selectedPersonas.contains(persona);
  final isLead = order.assignedPersonaLead == persona;
  if (isLead && order.status == OrderStatus.planned) {
    return AgentNodeStatus.lead;
  }
  if (order.status == OrderStatus.completed &&
      (isAssigned || hasRecentReport)) {
    return AgentNodeStatus.completed;
  }
  if (order.status == OrderStatus.hold && (isAssigned || isLead)) {
    return AgentNodeStatus.blocked;
  }
  if ((order.status == OrderStatus.inProgress ||
          order.status == OrderStatus.evaluation ||
          order.status == OrderStatus.revise) &&
      (isAssigned || isLead)) {
    return AgentNodeStatus.active;
  }
  if ((order.status == OrderStatus.approvalPending ||
          order.status == OrderStatus.planned) &&
      (isAssigned || isLead)) {
    return AgentNodeStatus.queued;
  }
  if (hasRecentReport) {
    return AgentNodeStatus.recent;
  }
  return AgentNodeStatus.idle;
}
