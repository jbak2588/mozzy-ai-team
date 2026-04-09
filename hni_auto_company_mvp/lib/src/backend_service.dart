import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'command_parser.dart';
import 'models.dart';
import 'telegram_integration.dart';

abstract class BackendSnapshotRepository {
  Future<AppSnapshot?> load();

  Future<void> save(AppSnapshot snapshot);
}

class FileBackendSnapshotRepository implements BackendSnapshotRepository {
  FileBackendSnapshotRepository(this.file);

  final File file;

  @override
  Future<AppSnapshot?> load() async {
    if (!await file.exists()) {
      return null;
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return null;
    }
    return AppSnapshot.fromJson(jsonDecode(contents) as Map<String, dynamic>);
  }

  @override
  Future<void> save(AppSnapshot snapshot) async {
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(snapshot.toJson()));
  }
}

class MemoryBackendSnapshotRepository implements BackendSnapshotRepository {
  AppSnapshot? _snapshot;

  @override
  Future<AppSnapshot?> load() async => _snapshot?.deepCopy();

  @override
  Future<void> save(AppSnapshot snapshot) async {
    _snapshot = snapshot.deepCopy();
  }
}

class BackendCommandResult {
  BackendCommandResult({required this.snapshot, required this.result});

  final AppSnapshot snapshot;
  final String result;
}

class AutoCompanyBackendService {
  AutoCompanyBackendService._(
    this._repository,
    this._snapshot, {
    required this.stageDelay,
    this.telegramIntegration,
  });

  final BackendSnapshotRepository _repository;
  final AppSnapshot _snapshot;
  final Map<String, Future<void>> _activeRuns = {};
  final Duration stageDelay;
  final TelegramIntegration? telegramIntegration;
  Future<void>? _telegramPollingTask;
  bool _telegramPollingStopping = false;
  String? _telegramPollingLastError;
  DateTime? _telegramPollingLastSuccessAt;
  DateTime? _telegramPollingLastAttemptAt;

  static Future<AutoCompanyBackendService> load(
    BackendSnapshotRepository repository, {
    Duration stageDelay = const Duration(milliseconds: 500),
    TelegramIntegration? telegramIntegration,
  }) async {
    final loaded = await repository.load();
    final snapshot = loaded == null
        ? _seedSnapshot()
        : _normalizeSnapshot(loaded);
    final service = AutoCompanyBackendService._(
      repository,
      snapshot,
      stageDelay: stageDelay,
      telegramIntegration: telegramIntegration,
    );
    await service._persist();
    service._resumeEligibleOrders();
    service._startTelegramPollingIfNeeded();
    return service;
  }

  AppSnapshot get snapshot => _snapshot.deepCopy();

  int get activeRunCount => _activeRuns.length;

  bool get isTelegramPollingActive => _telegramPollingTask != null;

  Future<WorkOrder> createOrder(OrderDraft draft) async {
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
      status: OrderStatus.approvalPending,
      planSummary: planSummary,
      riskProfile: draft.riskProfile,
      planApproved: false,
      createdAt: now,
      updatedAt: now,
      sourceChatId: draft.sourceChatId,
      sourceSenderId: draft.sourceSenderId,
      sourceUsername: draft.sourceUsername,
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
    await _persist();
    return order;
  }

  Future<AppSnapshot> approveApproval(String orderId, String approvalId) async {
    final order = _findOrder(orderId);
    if (order == null) {
      throw StateError('$orderId not found');
    }
    ApprovalRecord? target;
    for (final approval in order.approvals) {
      if (approval.id == approvalId) {
        target = approval;
        break;
      }
    }
    if (target == null) {
      throw StateError('$approvalId not found');
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
      await _persist();
      unawaited(_ensureRunner(order.id));
      return snapshot;
    }

    order.status = order.pendingApproval(ApprovalType.risk) != null
        ? OrderStatus.hold
        : OrderStatus.approvalPending;
    await _persist();
    return snapshot;
  }

  Future<AppSnapshot> holdOrder(
    String orderId, {
    String note = 'Manual hold',
  }) async {
    final order = _findOrder(orderId);
    if (order == null) {
      throw StateError('$orderId not found');
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
    await _persist();
    return snapshot;
  }

  Future<AppSnapshot> resumeOrder(String orderId) async {
    final order = _findOrder(orderId);
    if (order == null) {
      throw StateError('$orderId not found');
    }
    if (!order.planApproved || order.hasPendingApprovals) {
      throw StateError('$orderId is not ready to resume');
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
    await _persist();
    unawaited(_ensureRunner(order.id));
    return snapshot;
  }

  Future<BackendCommandResult> submitCommand(
    CommandChannel channel,
    String input, {
    String? requestedBy,
    String? sourceChatId,
    String? sourceSenderId,
    String? sourceUsername,
  }) async {
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
              requestedBy: requestedBy ?? '${channel.label} operator',
              sourceChannel: channel,
              assignedSquad: 'Feature Delivery',
              riskProfile: RiskProfile(),
              sourceChatId: sourceChatId,
              sourceSenderId: sourceSenderId,
              sourceUsername: sourceUsername,
            ),
          );
          result = 'Created ${order.id} and queued plan approval.';
          break;
        case ParsedCommandType.approve:
          final order = _findOrder(command.orderId!);
          if (order == null) {
            result = '${command.orderId} not found';
            break;
          }
          final approval =
              order.pendingApproval(ApprovalType.plan) ??
              order.pendingApproval(ApprovalType.risk);
          if (approval == null) {
            result = 'No pending approval for ${command.orderId}.';
            break;
          }
          await approveApproval(command.orderId!, approval.id);
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

    _appendCommandLog(
      channel: channel,
      input: input,
      result: result,
      senderLabel: requestedBy,
      senderId: sourceSenderId,
      chatId: sourceChatId,
    );
    await _persist();
    return BackendCommandResult(snapshot: snapshot, result: result);
  }

  String orderStatusLine(String orderId) {
    final order = _findOrder(orderId);
    if (order == null) {
      return '$orderId not found';
    }
    return '${order.id} · ${order.status.label} · '
        '${order.completedStages}/${order.stageRecords.length} stages complete';
  }

  void _appendCommandLog({
    required CommandChannel channel,
    required String input,
    required String result,
    String? senderLabel,
    String? senderId,
    String? chatId,
  }) {
    _snapshot.commandLogs.add(
      CommandLogEntry(
        id: _nextId('CMD'),
        channel: channel,
        input: input,
        result: result,
        createdAt: DateTime.now(),
        senderLabel: senderLabel,
        senderId: senderId,
        chatId: chatId,
      ),
    );
  }

  Handler handler() {
    final router = Router()
      ..get('/health', (Request request) {
        return _jsonResponse({
          'status': 'ok',
          'activeRuns': activeRunCount,
          'orders': _snapshot.orders.length,
        });
      })
      ..get('/api/v1/snapshot', (Request request) {
        return _jsonResponse({'snapshot': snapshot.toJson()});
      })
      ..post('/api/v1/orders', (Request request) async {
        final payload = await _readJson(request);
        await createOrder(OrderDraft.fromJson(payload));
        return _jsonResponse({'snapshot': snapshot.toJson()});
      })
      ..post('/api/v1/orders/<orderId>/approvals/<approvalId>/approve', (
        Request request,
        String orderId,
        String approvalId,
      ) async {
        final nextSnapshot = await approveApproval(orderId, approvalId);
        return _jsonResponse({'snapshot': nextSnapshot.toJson()});
      })
      ..post('/api/v1/orders/<orderId>/hold', (
        Request request,
        String orderId,
      ) async {
        final payload = await _readJson(request);
        final nextSnapshot = await holdOrder(
          orderId,
          note: payload['note'] as String? ?? 'Manual hold',
        );
        return _jsonResponse({'snapshot': nextSnapshot.toJson()});
      })
      ..post('/api/v1/orders/<orderId>/resume', (
        Request request,
        String orderId,
      ) async {
        final nextSnapshot = await resumeOrder(orderId);
        return _jsonResponse({'snapshot': nextSnapshot.toJson()});
      })
      ..get('/api/v1/integrations/telegram/status', (Request request) async {
        final status = await _telegramStatusPayload();
        return _jsonResponse(status);
      })
      ..post('/api/v1/integrations/telegram/set-webhook', (
        Request request,
      ) async {
        final payload = await _readJson(request);
        final status = await _setTelegramWebhook(payload);
        return _jsonResponse(status);
      })
      ..post('/api/v1/integrations/telegram/delete-webhook', (
        Request request,
      ) async {
        final payload = await _readJson(request);
        final status = await _deleteTelegramWebhook(payload);
        return _jsonResponse(status);
      })
      ..post('/api/v1/integrations/telegram/poll-once', (
        Request request,
      ) async {
        final processed = await pollTelegramOnce();
        return _jsonResponse({
          'processed': processed,
          'snapshot': snapshot.toJson(),
          'telegram': await _telegramStatusPayload(),
        });
      })
      ..post('/api/v1/integrations/telegram/webhook', (Request request) async {
        return _handleTelegramWebhook(request);
      })
      ..post('/api/v1/commands', (Request request) async {
        final payload = await _readJson(request);
        final channel = CommandChannel.values.byName(
          payload['channel'] as String? ?? CommandChannel.dashboard.name,
        );
        final result = await submitCommand(
          channel,
          payload['input'] as String? ?? '',
          requestedBy: payload['requestedBy'] as String?,
          sourceChatId: payload['sourceChatId'] as String?,
          sourceSenderId: payload['sourceSenderId'] as String?,
          sourceUsername: payload['sourceUsername'] as String?,
        );
        return _jsonResponse({
          'snapshot': result.snapshot.toJson(),
          'result': result.result,
        });
      });

    return Pipeline().addMiddleware(logRequests()).addHandler((request) async {
      try {
        return await router.call(request);
      } on StateError catch (error) {
        return _jsonResponse({'error': error.message}, statusCode: 400);
      } on FormatException catch (error) {
        return _jsonResponse({'error': error.message}, statusCode: 400);
      } catch (error) {
        return _jsonResponse({'error': error.toString()}, statusCode: 500);
      }
    });
  }

  static Future<HttpServer> serve({
    required AutoCompanyBackendService service,
    String host = '127.0.0.1',
    int port = 8787,
  }) {
    return shelf_io.serve(service.handler(), host, port);
  }

  Future<void> close() async {
    _telegramPollingStopping = true;
    await _telegramPollingTask;
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
        message: 'Backend auto-run started after approval',
        createdAt: DateTime.now(),
      ),
    );
    await _persist();

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
          message: '${stage.label} started on backend',
          createdAt: DateTime.now(),
        ),
      );
      await _persist();

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
          message: '${stage.label} completed on backend',
          createdAt: now,
        ),
      );
      currentOrder.updatedAt = now;
      if (stage == ExecutionStage.completion) {
        currentOrder.status = OrderStatus.completed;
      }
      await _persist();
      if (stage == ExecutionStage.completion) {
        await _dispatchCompletionSummary(currentOrder);
      }
    }
  }

  Future<void> _dispatchCompletionSummary(WorkOrder order) async {
    final telegram = telegramIntegration;
    if (telegram == null ||
        order.sourceChannel != CommandChannel.telegram ||
        order.sourceChatId == null ||
        order.sourceChatId!.isEmpty) {
      return;
    }
    try {
      await telegram.sendCompletionSummary(order);
      order.auditTrail.insert(
        0,
        AuditEntry(
          id: _nextId('AU'),
          orderId: order.id,
          message: 'Telegram completion summary dispatched',
          createdAt: DateTime.now(),
        ),
      );
      order.updatedAt = DateTime.now();
      await _persist();
    } catch (error) {
      order.auditTrail.insert(
        0,
        AuditEntry(
          id: _nextId('AU'),
          orderId: order.id,
          message: 'Telegram completion summary failed: $error',
          createdAt: DateTime.now(),
        ),
      );
      order.updatedAt = DateTime.now();
      await _persist();
    }
  }

  void _resumeEligibleOrders() {
    for (final order in _snapshot.orders) {
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

  Future<Map<String, dynamic>> _telegramStatusPayload() async {
    final telegram = telegramIntegration;
    if (telegram == null) {
      return {
        'configured': false,
        'status': 'disabled',
        'pollingEnabled': false,
        'pollingActive': false,
      };
    }
    final payload = await telegram.statusPayload();
    payload['pollingActive'] = isTelegramPollingActive;
    payload['pollingCursor'] = _snapshot.telegramPollingOffset;
    payload['lastPollingAttemptAt'] = _telegramPollingLastAttemptAt
        ?.toIso8601String();
    payload['lastPollingSuccessAt'] = _telegramPollingLastSuccessAt
        ?.toIso8601String();
    payload['lastPollingError'] = _telegramPollingLastError;
    return payload;
  }

  Future<Map<String, dynamic>> _setTelegramWebhook(
    Map<String, dynamic> payload,
  ) async {
    final telegram = telegramIntegration;
    if (telegram == null) {
      throw StateError('Telegram integration is not enabled for this backend.');
    }
    final dropPendingUpdates = payload['dropPendingUpdates'] == true;
    return telegram.setWebhook(
      urlOverride: payload['url'] as String?,
      dropPendingUpdates: dropPendingUpdates,
    );
  }

  Future<Map<String, dynamic>> _deleteTelegramWebhook(
    Map<String, dynamic> payload,
  ) async {
    final telegram = telegramIntegration;
    if (telegram == null) {
      throw StateError('Telegram integration is not enabled for this backend.');
    }
    final dropPendingUpdates = payload['dropPendingUpdates'] == true;
    return telegram.deleteWebhook(dropPendingUpdates: dropPendingUpdates);
  }

  Future<Response> _handleTelegramWebhook(Request request) async {
    final telegram = telegramIntegration;
    if (telegram == null || !telegram.isConfigured) {
      return _jsonResponse({
        'accepted': false,
        'error': 'Telegram integration is not configured.',
      }, statusCode: 503);
    }

    final secretHeader =
        request.headers['x-telegram-bot-api-secret-token'] ??
        request.headers['X-Telegram-Bot-Api-Secret-Token'];
    if (!telegram.validateSecret(secretHeader)) {
      return _jsonResponse({
        'accepted': false,
        'error': 'Invalid Telegram secret token.',
      }, statusCode: 401);
    }

    final payload = await _readJson(request);
    final result = await _processTelegramPayload(payload);
    return _jsonResponse(result);
  }

  Future<int> pollTelegramOnce() async {
    final telegram = telegramIntegration;
    if (telegram == null || !telegram.isConfigured) {
      throw StateError('Telegram integration is not configured.');
    }
    _telegramPollingLastAttemptAt = DateTime.now();
    final updates = await telegram.pollUpdates(
      offset: _snapshot.telegramPollingOffset,
    );
    if (updates.isEmpty) {
      _telegramPollingLastError = null;
      _telegramPollingLastSuccessAt = DateTime.now();
      return 0;
    }

    var processed = 0;
    for (final payload in updates) {
      await _processTelegramPayload(payload);
      final updateId = _updateIdFromPayload(payload);
      if (updateId != null) {
        final nextOffset = updateId + 1;
        final currentOffset = _snapshot.telegramPollingOffset;
        if (currentOffset == null || nextOffset > currentOffset) {
          _snapshot.telegramPollingOffset = nextOffset;
        }
        await _persist();
      }
      processed += 1;
    }
    _telegramPollingLastError = null;
    _telegramPollingLastSuccessAt = DateTime.now();
    return processed;
  }

  Future<Map<String, dynamic>> _processTelegramPayload(
    Map<String, dynamic> payload,
  ) async {
    final telegram = telegramIntegration;
    if (telegram == null || !telegram.isConfigured) {
      return {
        'accepted': false,
        'error': 'Telegram integration is not configured.',
      };
    }

    final update = telegram.normalizeUpdate(payload);
    if (update == null) {
      _appendCommandLog(
        channel: CommandChannel.telegram,
        input: '<unsupported update>',
        result: 'Ignored Telegram update without message text.',
      );
      await _persist();
      return {
        'accepted': false,
        'ignored': true,
        'reason': 'No supported message text found.',
      };
    }

    final parsed = const CommandParser().parse(update.text);
    final authorization = telegram.authorize(update, parsed);
    if (!authorization.allowed) {
      final reason =
          authorization.reason ?? 'Telegram sender is not authorized.';
      _appendCommandLog(
        channel: CommandChannel.telegram,
        input: update.text,
        result: reason,
        senderLabel: update.senderLabel,
        senderId: update.senderId,
        chatId: update.chatId,
      );
      await _persist();
      if (authorization.replyToSender) {
        await _sendTelegramReplySafely(telegram, update, reason);
      }
      return {
        'accepted': false,
        'reason': reason,
        'snapshot': snapshot.toJson(),
      };
    }

    try {
      final result = await submitCommand(
        CommandChannel.telegram,
        update.text,
        requestedBy: update.senderLabel,
        sourceChatId: update.chatId,
        sourceSenderId: update.senderId,
        sourceUsername: update.senderUsername,
      );
      await _sendTelegramReplySafely(telegram, update, result.result);
      return {
        'accepted': true,
        'result': result.result,
        'snapshot': result.snapshot.toJson(),
      };
    } on StateError catch (error) {
      final reason = error.message;
      _appendCommandLog(
        channel: CommandChannel.telegram,
        input: update.text,
        result: reason,
        senderLabel: update.senderLabel,
        senderId: update.senderId,
        chatId: update.chatId,
      );
      await _persist();
      await _sendTelegramReplySafely(telegram, update, reason);
      return {
        'accepted': false,
        'reason': reason,
        'snapshot': snapshot.toJson(),
      };
    } on FormatException catch (error) {
      final reason = error.message;
      _appendCommandLog(
        channel: CommandChannel.telegram,
        input: update.text,
        result: reason,
        senderLabel: update.senderLabel,
        senderId: update.senderId,
        chatId: update.chatId,
      );
      await _persist();
      await _sendTelegramReplySafely(telegram, update, reason);
      return {
        'accepted': false,
        'reason': reason,
        'snapshot': snapshot.toJson(),
      };
    }
  }

  void _startTelegramPollingIfNeeded() {
    final telegram = telegramIntegration;
    if (telegram == null ||
        !telegram.isConfigured ||
        !telegram.config.pollingEnabled ||
        _telegramPollingTask != null) {
      return;
    }
    _telegramPollingStopping = false;
    _telegramPollingTask = _runTelegramPollingLoop().whenComplete(() {
      _telegramPollingTask = null;
    });
  }

  Future<void> _runTelegramPollingLoop() async {
    final telegram = telegramIntegration;
    if (telegram == null || !telegram.config.pollingEnabled) {
      return;
    }
    while (!_telegramPollingStopping) {
      try {
        final processed = await pollTelegramOnce();
        if (_telegramPollingStopping) {
          break;
        }
        if (telegram.config.pollingTimeout == Duration.zero &&
            telegram.config.pollingInterval > Duration.zero &&
            processed == 0) {
          await Future<void>.delayed(telegram.config.pollingInterval);
        }
      } catch (error) {
        _telegramPollingLastError = error.toString();
        if (_telegramPollingStopping) {
          break;
        }
        if (telegram.config.pollingInterval > Duration.zero) {
          await Future<void>.delayed(telegram.config.pollingInterval);
        }
      }
    }
  }

  int? _updateIdFromPayload(Map<String, dynamic> payload) {
    final raw = payload['update_id'];
    if (raw is num) {
      return raw.toInt();
    }
    return int.tryParse(raw?.toString() ?? '');
  }

  Future<void> _sendTelegramReplySafely(
    TelegramIntegration telegram,
    TelegramNormalizedUpdate update,
    String text,
  ) async {
    try {
      await telegram.sendReply(update, text);
    } catch (_) {
      // Keep command handling authoritative on backend even if reply delivery fails.
    }
  }

  Future<void> _persist() => _repository.save(_snapshot);

  static AppSnapshot _normalizeSnapshot(AppSnapshot snapshot) {
    snapshot.orders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (snapshot.selectedOrderId == null && snapshot.orders.isNotEmpty) {
      snapshot.selectedOrderId = snapshot.orders.first.id;
    }
    return snapshot;
  }

  static AppSnapshot _seedSnapshot() {
    final now = DateTime.now();
    final completed = WorkOrder(
      id: 'WO-100',
      title: 'Mozzy V1 baseline review',
      objective: 'V1 field-test baseline을 제품/엔지니어링 관점으로 정리',
      targetProduct: 'Mozzy',
      targetBranch: 'main',
      requestedBy: 'HNI CEO',
      sourceChannel: CommandChannel.dashboard,
      assignedSquad: 'Discovery',
      status: OrderStatus.completed,
      planSummary: '보고서 초안 작성 및 baseline 분류 완료',
      riskProfile: RiskProfile(),
      planApproved: true,
      createdAt: now.subtract(const Duration(hours: 6)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      stageRecords: [
        for (final stage in ExecutionStage.values)
          StageRecord(
            stage: stage,
            state: StageState.completed,
            summary: '${stage.label} completed',
            startedAt: now.subtract(const Duration(hours: 6)),
            endedAt: now.subtract(const Duration(hours: 5)),
          ),
      ],
      reports: [
        _buildReport(
          orderId: 'WO-100',
          stage: ExecutionStage.completion,
          title: 'Completion report ready',
          ownerGroup: '전략군',
          personaLead: 'ceo-bezos',
          summary: 'baseline review order completed.',
          findings: ['V1 baseline table drafted', 'merge blockers documented'],
          recommendations: ['next order는 V2 slice smoke로 이동'],
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
      ],
      approvals: [
        ApprovalRecord(
          id: 'AP-100',
          orderId: 'WO-100',
          type: ApprovalType.plan,
          status: ApprovalStatus.approved,
          note: 'approved',
          createdAt: now.subtract(const Duration(hours: 6)),
          resolvedAt: now.subtract(const Duration(hours: 6)),
        ),
      ],
      auditTrail: [
        AuditEntry(
          id: 'AU-100',
          orderId: 'WO-100',
          message: 'Completion report delivered to HNI CEO',
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
      ],
    );

    final pending = WorkOrder(
      id: 'WO-101',
      title: 'Neighborhood slice smoke',
      objective: 'V2 first merge slice를 read-only smoke 기준으로 검증',
      targetProduct: 'Mozzy',
      targetBranch: 'hyperlocal-proposal',
      requestedBy: 'Telegram operator',
      sourceChannel: CommandChannel.telegram,
      assignedSquad: 'Feature Delivery',
      status: OrderStatus.approvalPending,
      planSummary: 'Neighborhood dashboard read path smoke 후 report',
      riskProfile: RiskProfile(),
      planApproved: false,
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      stageRecords: [
        StageRecord(
          stage: ExecutionStage.strategicReview,
          state: StageState.completed,
          summary: 'Neighborhood slice를 first merge 단위로 고정',
          startedAt: now.subtract(const Duration(hours: 2)),
          endedAt: now.subtract(const Duration(hours: 2)),
        ),
        StageRecord(
          stage: ExecutionStage.planning,
          state: StageState.completed,
          summary: 'Smoke checklist와 evidence 규격 작성',
          startedAt: now.subtract(const Duration(hours: 2)),
          endedAt: now.subtract(const Duration(hours: 2)),
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
        _buildReport(
          orderId: 'WO-101',
          stage: ExecutionStage.planning,
          title: 'Execution plan drafted',
          ownerGroup: '전략군 + 엔지니어링군',
          personaLead: 'cto-vogels',
          summary: 'smoke order drafted and waiting plan approval.',
          findings: [
            'route: neighborhood read',
            'non-production validation only',
          ],
          recommendations: ['CEO approval 후 자동 실행 가능'],
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
      approvals: [
        ApprovalRecord(
          id: 'AP-101',
          orderId: 'WO-101',
          type: ApprovalType.plan,
          status: ApprovalStatus.pending,
          note: 'Neighborhood read smoke 실행 승인 필요',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
      auditTrail: [
        AuditEntry(
          id: 'AU-101',
          orderId: 'WO-101',
          message: 'Work order queued from Telegram simulator',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
    );

    return AppSnapshot(
      orders: [pending, completed],
      commandLogs: [
        CommandLogEntry(
          id: 'CMD-100',
          channel: CommandChannel.dashboard,
          input: '/help',
          result: CommandParser.helpText(CommandChannel.dashboard),
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
      selectedOrderId: pending.id,
    );
  }

  static ReportEntry _buildReport({
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
      id: 'REP-${createdAt.microsecondsSinceEpoch}-${stage.name}',
      orderId: orderId,
      stage: stage,
      title: title,
      ownerGroup: ownerGroup,
      personaLead: personaLead,
      summary: summary,
      findings: findings,
      recommendations: recommendations,
      createdAt: createdAt,
    );
  }

  Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      },
    );
  }

  Future<Map<String, dynamic>> _readJson(Request request) async {
    final body = await request.readAsString();
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(body) as Map<String, dynamic>;
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
          'backend-run orchestration active',
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
        findings: ['scope drift 없음', '다음 stage를 backend가 계속 진행 가능'],
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
        summary: '분석 -> 계획 -> 실행 -> 평가 -> 수정 -> 완료 보고 흐름이 종료됐다.',
        findings: [
          'final status: completed',
          'target product: ${order.targetProduct}',
        ],
        recommendations: ['CEO review 후 다음 work order를 발행한다.'],
        createdAt: createdAt,
      ),
      _ => _buildReport(
        orderId: order.id,
        stage: stage,
        title: stage.label,
        ownerGroup: 'HNI',
        personaLead: 'system',
        summary: stage.label,
        findings: const [],
        recommendations: const [],
        createdAt: createdAt,
      ),
    };
  }
}
