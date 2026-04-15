import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'agent_catalog.dart';
import 'ai_orchestrator.dart';
import 'auth_session_models.dart';
import 'auth_provider_adapter.dart';
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

class AuthBootstrapConfig {
  const AuthBootstrapConfig({
    required this.enabled,
    required this.defaultAuthenticated,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.provider,
    required this.providerSubjectId,
    required this.sessionTtl,
    required this.recentAuthTtl,
    this.pictureUrl,
  });

  final bool enabled;
  final bool defaultAuthenticated;
  final String userId;
  final String email;
  final String name;
  final String role;
  final String provider;
  final String providerSubjectId;
  final String? pictureUrl;
  final Duration sessionTtl;
  final Duration recentAuthTtl;

  factory AuthBootstrapConfig.fromEnvironment() {
    return AuthBootstrapConfig(
      enabled: _envBool('HNI_AUTH_BOOTSTRAP_ENABLED', defaultValue: true),
      defaultAuthenticated: _envBool(
        'HNI_AUTH_BOOTSTRAP_DEFAULT_AUTHENTICATED',
        defaultValue: false,
      ),
      userId: _envString('HNI_AUTH_BOOTSTRAP_USER_ID', 'bootstrap-admin'),
      email: _envString('HNI_AUTH_BOOTSTRAP_EMAIL', 'admin@humantric.net'),
      name: _envString('HNI_AUTH_BOOTSTRAP_NAME', 'HNI Bootstrap Admin'),
      role: _envString('HNI_AUTH_BOOTSTRAP_ROLE', 'Admin'),
      provider: _envString('HNI_AUTH_BOOTSTRAP_PROVIDER', 'bootstrap'),
      providerSubjectId: _envString(
        'HNI_AUTH_BOOTSTRAP_SUBJECT',
        'bootstrap-admin',
      ),
      pictureUrl: _envOptional('HNI_AUTH_BOOTSTRAP_PICTURE_URL'),
      sessionTtl: Duration(
        hours: _envInt('HNI_AUTH_BOOTSTRAP_SESSION_TTL_HOURS', 8),
      ),
      recentAuthTtl: Duration(
        minutes: _envInt('HNI_AUTH_BOOTSTRAP_RECENT_AUTH_MINUTES', 15),
      ),
    );
  }

  HniUserRole get roleLevel => HniUserRoleView.fromName(role);
}

class AutoCompanyBackendService {
  static const _sessionCookieName = 'hni_session';
  static const _authFlowCookieName = 'hni_auth_flow';

  AutoCompanyBackendService._(
    this._repository,
    this._snapshot, {
    required this.stageDelay,
    required this.authBootstrap,
    required this.authProvider,
    this.telegramIntegration,
    this.orchestrator,
  }) : _csrfToken = 'csrf-${DateTime.now().microsecondsSinceEpoch}';

  final BackendSnapshotRepository _repository;
  final AppSnapshot _snapshot;
  final Map<String, Future<void>> _activeRuns = {};
  final Duration stageDelay;
  final AuthBootstrapConfig authBootstrap;
  final AuthProviderAdapter authProvider;
  final TelegramIntegration? telegramIntegration;
  final AiOrchestratorClient? orchestrator;
  final String _csrfToken;
  final Map<String, AuthSessionSnapshot> _issuedSessions = {};
  Future<void>? _telegramPollingTask;
  bool _telegramPollingStopping = false;
  String? _telegramPollingLastError;
  DateTime? _telegramPollingLastSuccessAt;
  DateTime? _telegramPollingLastAttemptAt;

  static Future<AutoCompanyBackendService> load(
    BackendSnapshotRepository repository, {
    Duration stageDelay = const Duration(milliseconds: 500),
    AuthBootstrapConfig? authBootstrap,
    AuthProviderAdapter? authProvider,
    TelegramIntegration? telegramIntegration,
    AiOrchestratorClient? orchestrator,
  }) async {
    final loaded = await repository.load();
    final snapshot = loaded == null
        ? _seedSnapshot()
        : _normalizeSnapshot(loaded);
    final service = AutoCompanyBackendService._(
      repository,
      snapshot,
      stageDelay: stageDelay,
      authBootstrap: authBootstrap ?? AuthBootstrapConfig.fromEnvironment(),
      authProvider:
          authProvider ??
          AuthProviderAdapter.fromConfig(AuthProviderConfig.fromEnvironment()),
      telegramIntegration: telegramIntegration,
      orchestrator: orchestrator,
    );
    await service._persist();
    service._resumeEligibleOrders();
    service._startTelegramPollingIfNeeded();
    return service;
  }

  AppSnapshot get snapshot => _snapshot.deepCopy();

  int get activeRunCount => _activeRuns.length;

  bool get isTelegramPollingActive => _telegramPollingTask != null;

  String get authProviderMode => authProvider.mode.wireName;

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
      assignedPersonaLead: defaultLeadForSquad(draft.assignedSquad),
      status: OrderStatus.approvalPending,
      planSummary: planSummary,
      riskProfile: draft.riskProfile,
      planApproved: false,
      createdAt: now,
      updatedAt: now,
      selectedPersonas: defaultPersonasForSquad(draft.assignedSquad),
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
          'authProviderMode': authProvider.mode.wireName,
          'orchestratorStatus': orchestrator == null
              ? 'disabled'
              : 'configured',
        });
      })
      ..get('/auth/login', (Request request) {
        return _handleAuthLogin(request);
      })
      ..get('/auth/callback', (Request request) async {
        return _handleAuthCallback(request);
      })
      ..get('/auth/logout', (Request request) {
        return _handleAuthLogout(request);
      })
      ..get('/api/v1/session', (Request request) {
        return _sessionResponse(
          request,
          ensureCookie: true,
          addCacheHeaders: true,
        );
      })
      ..post('/api/v1/session/bootstrap', (Request request) async {
        final payload = await _readJson(request);
        if (!authBootstrap.enabled) {
          return _jsonResponse({
            'error': 'Auth bootstrap is disabled.',
          }, statusCode: 404);
        }
        return _sessionResponse(
          request,
          redirectTo: payload['returnTo'] as String? ?? '/dashboard/home',
          forceAuthenticated: true,
          ensureCookie: true,
          addCacheHeaders: true,
        );
      })
      ..post('/api/v1/session/logout', (Request request) async {
        final payload = await _readJson(request);
        final currentSession = _resolveSession(request);
        if (currentSession.authenticated &&
            request.headers['x-hni-csrf-token'] != currentSession.csrfToken) {
          return _jsonResponse({
            'error': 'CSRF token mismatch.',
          }, statusCode: 403);
        }
        return _sessionResponse(
          request,
          redirectTo: payload['returnTo'] as String? ?? '/auth/login',
          forceAuthenticated: false,
          markSignedOut: true,
          addCacheHeaders: true,
        );
      })
      ..get('/api/v1/snapshot', (Request request) {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.operator,
        );
        if (auth != null) {
          return auth;
        }
        return _jsonResponse({'snapshot': snapshot.toJson()});
      })
      ..post('/api/v1/orders', (Request request) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.operator,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
        final payload = await _readJson(request);
        await createOrder(OrderDraft.fromJson(payload));
        return _jsonResponse({'snapshot': snapshot.toJson()});
      })
      ..post('/api/v1/orders/<orderId>/approvals/<approvalId>/approve', (
        Request request,
        String orderId,
        String approvalId,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.approver,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
        final nextSnapshot = await approveApproval(orderId, approvalId);
        return _jsonResponse({'snapshot': nextSnapshot.toJson()});
      })
      ..post('/api/v1/orders/<orderId>/hold', (
        Request request,
        String orderId,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.approver,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
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
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.approver,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
        final nextSnapshot = await resumeOrder(orderId);
        return _jsonResponse({'snapshot': nextSnapshot.toJson()});
      })
      ..get('/api/v1/orders/<orderId>/agent-graph', (
        Request request,
        String orderId,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.operator,
        );
        if (auth != null) {
          return auth;
        }
        final graph = await agentGraph(orderId);
        return _jsonResponse({'agentGraph': graph.toJson()});
      })
      ..post('/api/v1/orders/<orderId>/agent-graph/assign', (
        Request request,
        String orderId,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.lead,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
        final payload = await _readJson(request);
        final nextSnapshot = await assignPersonaLead(
          orderId,
          payload['persona'] as String? ?? '',
        );
        return _jsonResponse({
          'snapshot': nextSnapshot.toJson(),
          'agentGraph': _buildAgentGraph(
            _findOrder(orderId) ?? nextSnapshot.orders.first,
          ).toJson(),
        });
      })
      ..post('/api/v1/orders/<orderId>/agent-graph/dispatch', (
        Request request,
        String orderId,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.lead,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
        final payload = await _readJson(request);
        final nextSnapshot = await dispatchPersona(
          orderId,
          payload['persona'] as String? ?? '',
        );
        return _jsonResponse({
          'snapshot': nextSnapshot.toJson(),
          'agentGraph': _buildAgentGraph(
            _findOrder(orderId) ?? nextSnapshot.orders.first,
          ).toJson(),
        });
      })
      ..get('/api/v1/integrations/telegram/status', (Request request) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.admin,
        );
        if (auth != null) {
          return auth;
        }
        final status = await _telegramStatusPayload();
        return _jsonResponse(status);
      })
      ..post('/api/v1/integrations/telegram/set-webhook', (
        Request request,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.admin,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
        final payload = await _readJson(request);
        final status = await _setTelegramWebhook(payload);
        return _jsonResponse(status);
      })
      ..post('/api/v1/integrations/telegram/delete-webhook', (
        Request request,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.admin,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
        final payload = await _readJson(request);
        final status = await _deleteTelegramWebhook(payload);
        return _jsonResponse(status);
      })
      ..post('/api/v1/integrations/telegram/poll-once', (
        Request request,
      ) async {
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.admin,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
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
        final auth = _authorizeApiRequest(
          request,
          minimumRole: HniUserRole.operator,
          requireCsrf: true,
        );
        if (auth != null) {
          return auth;
        }
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

    return Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler((request) async {
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
      final stageOutcome = await _resolveStageOutcome(currentOrder, stage);
      record.state = StageState.completed;
      record.endedAt = now;
      record.summary = stageOutcome.summary;
      currentOrder.reports.add(
        _buildStageReport(
          currentOrder,
          stage,
          now,
          stageOutcome.summary,
          stageOutcome.findings,
          stageOutcome.recommendations,
          currentOrder.assignedPersonaLead,
        ),
      );
      currentOrder.auditTrail.insert(
        0,
        AuditEntry(
          id: _nextId('AU'),
          orderId: currentOrder.id,
          message: stageOutcome.auditMessage(stage),
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

  Future<AgentGraph> agentGraph(String orderId) async {
    final order = _findOrder(orderId);
    if (order == null) {
      throw StateError('$orderId not found');
    }
    return _buildAgentGraph(order);
  }

  Future<AppSnapshot> assignPersonaLead(String orderId, String persona) async {
    final order = _findOrder(orderId);
    if (order == null) {
      throw StateError('$orderId not found');
    }
    final index = buildAgentPersonaIndex();
    if (!index.containsKey(persona)) {
      throw StateError('Unknown persona: $persona');
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
        message: 'Persona lead assigned: $persona',
        createdAt: order.updatedAt,
      ),
    );
    await _persist();
    return snapshot;
  }

  Future<AppSnapshot> dispatchPersona(String orderId, String persona) async {
    final order = _findOrder(orderId);
    if (order == null) {
      throw StateError('$orderId not found');
    }
    final index = buildAgentPersonaIndex();
    if (!index.containsKey(persona)) {
      throw StateError('Unknown persona: $persona');
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
        message: 'Persona dispatched from control panel: $persona',
        createdAt: order.updatedAt,
      ),
    );
    await _persist();
    if (order.planApproved &&
        !order.hasPendingApprovals &&
        order.status != OrderStatus.completed &&
        order.status != OrderStatus.hold) {
      unawaited(_ensureRunner(order.id));
    }
    return snapshot;
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

  void _normalizeOrderPersonas(WorkOrder order) {
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

  static AppSnapshot _normalizeSnapshot(AppSnapshot snapshot) {
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
      assignedPersonaLead: defaultLeadForSquad('Discovery'),
      status: OrderStatus.completed,
      planSummary: '보고서 초안 작성 및 baseline 분류 완료',
      riskProfile: RiskProfile(),
      planApproved: true,
      createdAt: now.subtract(const Duration(hours: 6)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      selectedPersonas: defaultPersonasForSquad('Discovery'),
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
      assignedPersonaLead: defaultLeadForSquad('Feature Delivery'),
      status: OrderStatus.approvalPending,
      planSummary: 'Neighborhood dashboard read path smoke 후 report',
      riskProfile: RiskProfile(),
      planApproved: false,
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      selectedPersonas: defaultPersonasForSquad('Feature Delivery'),
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

  AgentGraph _buildAgentGraph(WorkOrder order) {
    _normalizeOrderPersonas(order);
    final activeRecord = order.stageRecords.where(
      (item) => item.state == StageState.running,
    );
    final currentStageLabel = activeRecord.isEmpty
        ? null
        : activeRecord.first.stage.label;
    final nodes = <AgentGraphNode>[];
    for (final descriptor in agentPersonas) {
      final matchingReports = order.reports
          .where((report) => report.personaLead == descriptor.persona)
          .toList();
      final latestSummary = matchingReports.isEmpty
          ? null
          : matchingReports.last.summary;
      nodes.add(
        AgentGraphNode(
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
        ),
      );
    }
    return AgentGraph(
      orderId: order.id,
      orderStatus: order.status.label,
      assignedSquad: order.assignedSquad,
      selectedPersonas: List<String>.from(order.selectedPersonas),
      leadPersona: order.assignedPersonaLead,
      activeStageLabel: currentStageLabel,
      providerMode: orchestrator == null
          ? 'deterministic'
          : 'gemini-orchestrated',
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

  Future<_StageOutcome> _resolveStageOutcome(
    WorkOrder order,
    ExecutionStage stage,
  ) async {
    _normalizeOrderPersonas(order);
    final client = orchestrator;
    if (client == null) {
      return _StageOutcome.fallback(
        summary: _completedSummaryForStage(order, stage),
        findings: _defaultFindingsForStage(order, stage),
        recommendations: _defaultRecommendationsForStage(stage),
      );
    }
    try {
      final result = await client.startStageRun(
        order: order,
        stage: stage,
        selectedPersonas: order.selectedPersonas,
      );
      return _StageOutcome(
        summary: result.summary,
        findings: result.findings,
        recommendations: result.recommendations,
        provider: result.provider,
        runId: result.runId,
      );
    } catch (error) {
      order.auditTrail.insert(
        0,
        AuditEntry(
          id: _nextId('AU'),
          orderId: order.id,
          message: 'Gemini orchestrator failed, falling back: $error',
          createdAt: DateTime.now(),
        ),
      );
      await _persist();
      return _StageOutcome.fallback(
        summary: _completedSummaryForStage(order, stage),
        findings: _defaultFindingsForStage(order, stage),
        recommendations: _defaultRecommendationsForStage(stage),
      );
    }
  }

  List<String> _defaultFindingsForStage(WorkOrder order, ExecutionStage stage) {
    return switch (stage) {
      ExecutionStage.execution => [
        order.objective,
        'branch target: ${order.targetBranch}',
        'selected personas: ${order.selectedPersonas.join(', ')}',
      ],
      ExecutionStage.evaluation => [
        'selected personas: ${order.selectedPersonas.join(', ')}',
        'scope drift 없음',
      ],
      ExecutionStage.revision => [
        'lead persona: ${order.assignedPersonaLead}',
        '평가 결과 보정 반영',
      ],
      ExecutionStage.completion => [
        'completion summary ready',
        'lead persona: ${order.assignedPersonaLead}',
      ],
      _ => const [],
    };
  }

  List<String> _defaultRecommendationsForStage(ExecutionStage stage) {
    return switch (stage) {
      ExecutionStage.execution => const ['evaluation 단계로 진행한다.'],
      ExecutionStage.evaluation => const ['revision 단계에서 정합화를 마친다.'],
      ExecutionStage.revision => const ['completion report를 생성한다.'],
      ExecutionStage.completion => const ['다음 work order를 dispatch한다.'],
      _ => const [],
    };
  }

  Response _sessionResponse(
    Request request, {
    bool? forceAuthenticated,
    AuthSessionSnapshot? explicitSession,
    bool ensureCookie = false,
    bool markSignedOut = false,
    bool addCacheHeaders = false,
    String? redirectTo,
  }) {
    final currentCookieValue = _cookieValue(request, _sessionCookieName);
    if (markSignedOut && currentCookieValue != null) {
      _issuedSessions.remove(currentCookieValue);
    }
    final session =
        explicitSession ??
        (forceAuthenticated == null
            ? _resolveSession(request)
            : forceAuthenticated
            ? _bootstrapSession()
            : AuthSessionSnapshot.anonymous());
    final headers = <String, String>{};
    if (addCacheHeaders) {
      headers[HttpHeaders.cacheControlHeader] = 'no-store';
      headers[HttpHeaders.varyHeader] = 'Cookie';
    }
    if (markSignedOut) {
      headers[HttpHeaders.setCookieHeader] = _sessionCookieHeader('signed_out');
    } else if (ensureCookie && session.authenticated) {
      final sessionToken =
          currentCookieValue != null &&
              _issuedSessions.containsKey(currentCookieValue)
          ? currentCookieValue
          : _issueSession(session);
      _issuedSessions[sessionToken] = session;
      headers[HttpHeaders.setCookieHeader] = _sessionCookieHeader(sessionToken);
    }
    final body = <String, dynamic>{
      'session': session.toJson(),
      'redirectTo': redirectTo,
    }..removeWhere((_, value) => value == null);
    return _jsonResponse(body, headers: headers);
  }

  AuthSessionSnapshot _resolveSession(Request request) {
    final cookieValue = _cookieValue(request, _sessionCookieName);
    if (cookieValue == 'signed_out') {
      return AuthSessionSnapshot.anonymous();
    }
    if (cookieValue != null && _issuedSessions.containsKey(cookieValue)) {
      return _issuedSessions[cookieValue]!;
    }
    if (!authBootstrap.enabled) {
      return AuthSessionSnapshot.anonymous();
    }
    if (authBootstrap.defaultAuthenticated) {
      return _bootstrapSession();
    }
    return AuthSessionSnapshot.anonymous();
  }

  Response? _authorizeApiRequest(
    Request request, {
    required HniUserRole minimumRole,
    bool requireCsrf = false,
  }) {
    final session = _resolveSession(request);
    if (!session.authenticated) {
      return _jsonResponse({
        'error': 'Authentication required.',
        'authenticated': false,
        'requiredRole': minimumRole.label,
      }, statusCode: 401);
    }
    if (!session.hasAtLeast(minimumRole)) {
      return _jsonResponse({
        'error': 'Forbidden.',
        'authenticated': true,
        'requiredRole': minimumRole.label,
        'actualRole': session.role.label,
      }, statusCode: 403);
    }
    if (requireCsrf &&
        request.method != 'GET' &&
        request.headers['x-hni-csrf-token'] != session.csrfToken) {
      return _jsonResponse({'error': 'CSRF token mismatch.'}, statusCode: 403);
    }
    return null;
  }

  Response _handleAuthLogin(Request request) {
    if (!authBootstrap.enabled &&
        authProvider.mode == AuthProviderMode.bootstrap) {
      return _jsonResponse({
        'error': 'Auth provider is not available.',
      }, statusCode: 404);
    }
    final returnTo = _sanitizeReturnTo(
      request.requestedUri.queryParameters['returnTo'] ??
          authProvider.defaultReturnTo,
    );
    final challenge = authProvider.beginLogin(returnTo: returnTo);
    return Response(
      303,
      headers: {
        HttpHeaders.locationHeader: challenge.redirectLocation,
        HttpHeaders.setCookieHeader: _authFlowCookieHeader(challenge.pending),
        HttpHeaders.cacheControlHeader: 'no-store',
      },
    );
  }

  Future<Response> _handleAuthCallback(Request request) async {
    final pending = _pendingAuthFlow(request);
    if (pending == null) {
      return Response(
        303,
        headers: {
          HttpHeaders.locationHeader: '/auth/login?error=missing_auth_flow',
          HttpHeaders.setCookieHeader: _sessionCookieHeader('signed_out'),
        },
      );
    }
    try {
      final identity = authProvider.completeCallback(
        requestedUri: request.requestedUri,
        pending: pending,
        bootstrapIdentity: _bootstrapIdentity(),
      );
      final session = _sessionForIdentity(identity);
      final sessionToken = _issueSession(session);
      return Response(
        303,
        headers: {
          HttpHeaders.locationHeader: pending.returnTo,
          HttpHeaders.setCookieHeader: _sessionCookieHeader(sessionToken),
          HttpHeaders.cacheControlHeader: 'no-store',
        },
      );
    } on FormatException catch (error) {
      return Response(
        303,
        headers: {
          HttpHeaders.locationHeader:
              '/auth/login?error=${Uri.encodeQueryComponent(error.message)}',
          HttpHeaders.setCookieHeader: _sessionCookieHeader('signed_out'),
        },
      );
    }
  }

  Response _handleAuthLogout(Request request) {
    final currentCookieValue = _cookieValue(request, _sessionCookieName);
    if (currentCookieValue != null) {
      _issuedSessions.remove(currentCookieValue);
    }
    final returnTo = _sanitizeReturnTo(
      request.requestedUri.queryParameters['returnTo'] ?? '/auth/login',
    );
    return Response(
      303,
      headers: {
        HttpHeaders.locationHeader: returnTo,
        HttpHeaders.setCookieHeader: _sessionCookieHeader('signed_out'),
        HttpHeaders.cacheControlHeader: 'no-store',
      },
    );
  }

  AuthSessionSnapshot _bootstrapSession() {
    return _sessionForIdentity(_bootstrapIdentity());
  }

  AuthProviderIdentity _bootstrapIdentity() {
    return AuthProviderIdentity(
      userId: authBootstrap.userId,
      email: authBootstrap.email,
      name: authBootstrap.name,
      pictureUrl: authBootstrap.pictureUrl,
      role: authBootstrap.role,
      provider: authBootstrap.provider,
      providerSubjectId: authBootstrap.providerSubjectId,
    );
  }

  AuthSessionSnapshot _sessionForIdentity(AuthProviderIdentity identity) {
    final now = DateTime.now().toUtc();
    return AuthSessionSnapshot(
      authenticated: true,
      principal: SessionPrincipal(
        userId: identity.userId,
        email: identity.email,
        name: identity.name,
        pictureUrl: identity.pictureUrl,
        role: identity.role,
        provider: identity.provider,
        providerSubjectId: identity.providerSubjectId,
      ),
      capabilities: _capabilitiesForRole(
        HniUserRoleView.fromName(identity.role),
      ),
      authTime: now,
      issuedAt: now,
      expiresAt: now.add(authBootstrap.sessionTtl),
      recentAuthExpiresAt: now.add(authBootstrap.recentAuthTtl),
      csrfToken: _csrfToken,
    );
  }

  Map<String, bool> _capabilitiesForRole(HniUserRole role) {
    return {
      'canAccessStrategy': role.meets(HniUserRole.approver),
      'canApprove': role.meets(HniUserRole.approver),
      'canManageTelegramOps': role.meets(HniUserRole.admin),
      'canExportAudit': role.meets(HniUserRole.admin),
    };
  }

  String? _cookieValue(Request request, String name) {
    final header = request.headers[HttpHeaders.cookieHeader];
    if (header == null || header.trim().isEmpty) {
      return null;
    }
    for (final item in header.split(';')) {
      final parts = item.trim().split('=');
      if (parts.length < 2) {
        continue;
      }
      if (parts.first.trim() == name) {
        return parts.sublist(1).join('=').trim();
      }
    }
    return null;
  }

  String _issueSession(AuthSessionSnapshot session) {
    final token = 'session-${DateTime.now().microsecondsSinceEpoch}';
    _issuedSessions[token] = session;
    return token;
  }

  PendingAuthFlow? _pendingAuthFlow(Request request) {
    final raw = _cookieValue(request, _authFlowCookieName);
    return PendingAuthFlow.decode(
      raw == null ? null : Uri.decodeComponent(raw),
    );
  }

  String _authFlowCookieHeader(PendingAuthFlow flow) {
    return '$_authFlowCookieName=${Uri.encodeComponent(flow.encode())}; '
        'Path=/; HttpOnly; SameSite=Lax';
  }

  String _sessionCookieHeader(String value) {
    return '$_sessionCookieName=$value; Path=/; HttpOnly; SameSite=Lax';
  }

  String _sanitizeReturnTo(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return authProvider.defaultReturnTo;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.hasScheme || trimmed.startsWith('//')) {
      return authProvider.defaultReturnTo;
    }
    return trimmed.startsWith('/') ? trimmed : authProvider.defaultReturnTo;
  }

  Middleware _corsMiddleware() {
    return (innerHandler) {
      return (request) async {
        final corsHeaders = _corsHeadersForOrigin(
          request.headers['origin'],
        );
        if (request.method == 'OPTIONS') {
          if (corsHeaders.isEmpty) {
            return Response.notFound('Route not found');
          }
          return Response(204, headers: corsHeaders);
        }
        final response = await innerHandler(request);
        if (corsHeaders.isEmpty) {
          return response;
        }
        return response.change(
          headers: _mergeResponseHeaders(response.headers, corsHeaders),
        );
      };
    };
  }

  Map<String, String> _corsHeadersForOrigin(String? origin) {
    if (!_isAllowedCorsOrigin(origin)) {
      return const {};
    }
    return {
      HttpHeaders.accessControlAllowOriginHeader: origin!,
      HttpHeaders.accessControlAllowCredentialsHeader: 'true',
      HttpHeaders.accessControlAllowMethodsHeader: 'GET, POST, OPTIONS',
      HttpHeaders.accessControlAllowHeadersHeader:
          'Content-Type, X-HNI-CSRF-Token',
      HttpHeaders.accessControlMaxAgeHeader: '600',
      HttpHeaders.varyHeader: 'Origin',
    };
  }

  bool _isAllowedCorsOrigin(String? origin) {
    if (origin == null || origin.trim().isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(origin);
    if (uri == null || uri.host.isEmpty) {
      return false;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    if (uri.host == 'localhost') {
      return true;
    }
    final address = InternetAddress.tryParse(uri.host);
    return address?.isLoopback ?? false;
  }

  Map<String, String> _mergeResponseHeaders(
    Map<String, String> existing,
    Map<String, String> extra,
  ) {
    final merged = Map<String, String>.from(existing);
    for (final entry in extra.entries) {
      if (entry.key == HttpHeaders.varyHeader) {
        merged[entry.key] = _mergeHeaderValues(merged[entry.key], entry.value);
      } else {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  String _mergeHeaderValues(String? existing, String next) {
    if (existing == null || existing.trim().isEmpty) {
      return next;
    }
    final values = existing
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    if (values.contains(next)) {
      return existing;
    }
    return '$existing, $next';
  }

  Response _jsonResponse(
    Map<String, dynamic> body, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        ...?headers,
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
    DateTime createdAt, [
    String? summaryOverride,
    List<String>? findingsOverride,
    List<String>? recommendationsOverride,
    String? personaLeadOverride,
  ]) {
    return switch (stage) {
      ExecutionStage.execution => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Execution artifacts produced',
        ownerGroup: '제품군 + 엔지니어링군',
        personaLead: personaLeadOverride ?? 'fullstack-dhh',
        summary:
            summaryOverride ??
            '${order.assignedSquad}가 ${order.targetProduct}용 실행 산출물을 생성했다.',
        findings:
            findingsOverride ??
            [
              order.objective,
              'branch target: ${order.targetBranch}',
              'backend-run orchestration active',
            ],
        recommendations:
            recommendationsOverride ?? ['evaluation 단계에서 blocker만 분리한다.'],
        createdAt: createdAt,
      ),
      ExecutionStage.evaluation => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Evaluation completed',
        ownerGroup: 'QA + 전략군',
        personaLead: personaLeadOverride ?? 'critic-munger',
        summary: summaryOverride ?? '현재 결과는 합의된 scope 안에서 수용 가능한 상태다.',
        findings:
            findingsOverride ??
            ['scope drift 없음', '다음 stage를 backend가 계속 진행 가능'],
        recommendations:
            recommendationsOverride ?? ['completion report에 잔여 리스크를 명시한다.'],
        createdAt: createdAt,
      ),
      ExecutionStage.revision => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Revision applied',
        ownerGroup: '엔지니어링군 + 제품군',
        personaLead: personaLeadOverride ?? 'ui-duarte',
        summary: summaryOverride ?? '평가에서 드러난 개선 메모를 반영했다.',
        findings: findingsOverride ?? ['문구/흐름 정합화', 'completion readiness 재확인'],
        recommendations: recommendationsOverride ?? ['완료 보고로 종료한다.'],
        createdAt: createdAt,
      ),
      ExecutionStage.completion => _buildReport(
        orderId: order.id,
        stage: stage,
        title: 'Completion report ready',
        ownerGroup: '전략군',
        personaLead: personaLeadOverride ?? 'ceo-bezos',
        summary:
            summaryOverride ?? '분석 -> 계획 -> 실행 -> 평가 -> 수정 -> 완료 보고 흐름이 종료됐다.',
        findings:
            findingsOverride ??
            [
              'final status: completed',
              'target product: ${order.targetProduct}',
            ],
        recommendations:
            recommendationsOverride ?? ['CEO review 후 다음 work order를 발행한다.'],
        createdAt: createdAt,
      ),
      _ => _buildReport(
        orderId: order.id,
        stage: stage,
        title: stage.label,
        ownerGroup: 'HNI',
        personaLead: personaLeadOverride ?? 'system',
        summary: summaryOverride ?? stage.label,
        findings: findingsOverride ?? const [],
        recommendations: recommendationsOverride ?? const [],
        createdAt: createdAt,
      ),
    };
  }
}

class _StageOutcome {
  const _StageOutcome({
    required this.summary,
    required this.findings,
    required this.recommendations,
    this.provider,
    this.runId,
  });

  final String summary;
  final List<String> findings;
  final List<String> recommendations;
  final String? provider;
  final String? runId;

  factory _StageOutcome.fallback({
    required String summary,
    required List<String> findings,
    required List<String> recommendations,
  }) {
    return _StageOutcome(
      summary: summary,
      findings: findings,
      recommendations: recommendations,
      provider: 'deterministic-fallback',
    );
  }

  String auditMessage(ExecutionStage stage) {
    final providerLabel = provider == null ? 'deterministic' : provider!;
    if (runId == null || runId!.isEmpty) {
      return '${stage.label} completed on backend [$providerLabel]';
    }
    return '${stage.label} completed on backend [$providerLabel] run=$runId';
  }
}

String _envString(String name, String defaultValue) {
  return Platform.environment[name]?.trim().isNotEmpty == true
      ? Platform.environment[name]!.trim()
      : defaultValue;
}

String? _envOptional(String name) {
  final value = Platform.environment[name]?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

int _envInt(String name, int defaultValue) {
  return int.tryParse(Platform.environment[name] ?? '') ?? defaultValue;
}

bool _envBool(String name, {required bool defaultValue}) {
  final value = Platform.environment[name]?.trim().toLowerCase();
  if (value == null || value.isEmpty) {
    return defaultValue;
  }
  return value == '1' || value == 'true' || value == 'yes';
}
