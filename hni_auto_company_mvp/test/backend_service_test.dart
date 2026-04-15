import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:hni_auto_company_mvp/src/auth_session.dart';
import 'package:hni_auto_company_mvp/src/auth_provider_adapter.dart';
import 'package:hni_auto_company_mvp/src/backend_service.dart';
import 'package:hni_auto_company_mvp/src/models.dart';
import 'package:shelf/shelf.dart';

void main() {
  test('backend service auto-runs approved order to completion', () async {
    final repository = MemoryBackendSnapshotRepository();
    final service = await AutoCompanyBackendService.load(
      repository,
      stageDelay: Duration.zero,
    );

    final order = await service.createOrder(
      OrderDraft(
        title: 'Backend order',
        objective: 'server-side chain',
        targetProduct: 'HNI',
        targetBranch: 'main',
        requestedBy: 'CEO',
        sourceChannel: CommandChannel.dashboard,
        assignedSquad: 'Feature Delivery',
        riskProfile: RiskProfile(),
      ),
    );

    final planApproval = order.pendingApproval(ApprovalType.plan);
    expect(planApproval, isNotNull);

    await service.approveApproval(order.id, planApproval!.id);
    await _waitUntil(
      () async =>
          service.snapshot.orders
              .firstWhere((item) => item.id == order.id)
              .status ==
          OrderStatus.completed,
    );

    final completed = service.snapshot.orders.firstWhere(
      (item) => item.id == order.id,
    );
    expect(completed.status, OrderStatus.completed);
    expect(
      completed.reports.any(
        (report) => report.stage == ExecutionStage.completion,
      ),
      isTrue,
    );
  });

  test(
    'backend service agent graph reflects lead assignment and dispatch',
    () async {
      final repository = MemoryBackendSnapshotRepository();
      final service = await AutoCompanyBackendService.load(
        repository,
        stageDelay: Duration.zero,
      );

      final created = await service.createOrder(
        OrderDraft(
          title: 'Graph order',
          objective: 'persona control panel smoke',
          targetProduct: 'Mozzy',
          targetBranch: 'main',
          requestedBy: 'CEO',
          sourceChannel: CommandChannel.dashboard,
          assignedSquad: 'Feature Delivery',
          riskProfile: RiskProfile(),
        ),
      );

      await service.assignPersonaLead(created.id, 'qa-bach');
      await service.dispatchPersona(created.id, 'ui-duarte');
      final graph = await service.agentGraph(created.id);

      expect(graph.leadPersona, 'qa-bach');
      final leadNode = graph.nodes.firstWhere(
        (node) => node.persona == 'qa-bach',
      );
      final dispatchedNode = graph.nodes.firstWhere(
        (node) => node.persona == 'ui-duarte',
      );
      expect(leadNode.isLead, isTrue);
      expect(leadNode.assigned, isTrue);
      expect(dispatchedNode.assigned, isTrue);
    },
  );

  test(
    'backend service exposes same-origin bootstrap session endpoints',
    () async {
      final repository = MemoryBackendSnapshotRepository();
      final service = await AutoCompanyBackendService.load(
        repository,
        stageDelay: Duration.zero,
        authBootstrap: const AuthBootstrapConfig(
          enabled: true,
          defaultAuthenticated: true,
          userId: 'bootstrap-admin',
          email: 'admin@humantric.net',
          name: 'HNI Bootstrap Admin',
          role: 'Admin',
          provider: 'bootstrap',
          providerSubjectId: 'bootstrap-admin',
          sessionTtl: Duration(hours: 8),
          recentAuthTtl: Duration(minutes: 15),
        ),
      );
      final server = await AutoCompanyBackendService.serve(
        service: service,
        port: 0,
      );
      addTearDown(server.close);

      final baseUrl = 'http://${server.address.host}:${server.port}';
      final sessionResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/session'),
      );
      final sessionJson =
          jsonDecode(sessionResponse.body) as Map<String, dynamic>;
      final session = AuthSessionSnapshot.fromEnvelope(sessionJson);

      expect(session.authenticated, isTrue);
      expect(session.role, HniUserRole.admin);
      expect(
        sessionResponse.headers['set-cookie'],
        contains('hni_session=session-'),
      );

      final logoutResponse = await http.post(
        Uri.parse('$baseUrl/api/v1/session/logout'),
        headers: {
          'content-type': 'application/json',
          'x-hni-csrf-token': session.csrfToken!,
        },
        body: jsonEncode({'returnTo': '/auth/login'}),
      );
      final logoutJson =
          jsonDecode(logoutResponse.body) as Map<String, dynamic>;
      final loggedOut = AuthSessionSnapshot.fromEnvelope(logoutJson);

      expect(loggedOut.authenticated, isFalse);
      expect(logoutJson['redirectTo'], '/auth/login');
      expect(
        logoutResponse.headers['set-cookie'],
        contains('hni_session=signed_out'),
      );
    },
  );

  test(
    'backend service allows local preview CORS preflight and session fetch',
    () async {
      final repository = MemoryBackendSnapshotRepository();
      final service = await AutoCompanyBackendService.load(
        repository,
        stageDelay: Duration.zero,
        authBootstrap: const AuthBootstrapConfig(
          enabled: true,
          defaultAuthenticated: true,
          userId: 'bootstrap-admin',
          email: 'admin@humantric.net',
          name: 'HNI Bootstrap Admin',
          role: 'Admin',
          provider: 'bootstrap',
          providerSubjectId: 'bootstrap-admin',
          sessionTtl: Duration(hours: 8),
          recentAuthTtl: Duration(minutes: 15),
        ),
      );
      final handler = service.handler();
      const origin = 'http://127.0.0.1:3000';

      final preflight = await handler.call(
        Request(
          'OPTIONS',
          Uri.parse('http://127.0.0.1/api/v1/session/bootstrap'),
          headers: {
            'origin': origin,
            'access-control-request-method': 'POST',
            'access-control-request-headers': 'content-type',
          },
        ),
      );

      expect(preflight.statusCode, 204);
      expect(preflight.headers['access-control-allow-origin'], origin);
      expect(preflight.headers['access-control-allow-credentials'], 'true');
      expect(
        preflight.headers['access-control-allow-headers'],
        contains('Content-Type'),
      );

      final sessionResponse = await handler.call(
        Request(
          'GET',
          Uri.parse('http://127.0.0.1/api/v1/session'),
          headers: {'origin': origin},
        ),
      );

      expect(sessionResponse.statusCode, 200);
      expect(sessionResponse.headers['access-control-allow-origin'], origin);
      expect(
        sessionResponse.headers['access-control-allow-credentials'],
        'true',
      );
      expect(sessionResponse.headers['vary'], contains('Cookie'));
      expect(sessionResponse.headers['vary'], contains('Origin'));
    },
  );

  test('business API returns 403 when role is below endpoint minimum', () async {
    final repository = MemoryBackendSnapshotRepository();
    final service = await AutoCompanyBackendService.load(
      repository,
      stageDelay: Duration.zero,
      authBootstrap: const AuthBootstrapConfig(
        enabled: true,
        defaultAuthenticated: true,
        userId: 'bootstrap-operator',
        email: 'operator@humantric.net',
        name: 'HNI Operator',
        role: 'Operator',
        provider: 'bootstrap',
        providerSubjectId: 'bootstrap-operator',
        sessionTtl: Duration(hours: 8),
        recentAuthTtl: Duration(minutes: 15),
      ),
    );
    final server = await AutoCompanyBackendService.serve(
      service: service,
      port: 0,
    );
    addTearDown(server.close);

    final baseUrl = 'http://${server.address.host}:${server.port}';
    final sessionResponse = await http.get(
      Uri.parse('$baseUrl/api/v1/session'),
    );
    final sessionJson =
        jsonDecode(sessionResponse.body) as Map<String, dynamic>;
    final session = AuthSessionSnapshot.fromEnvelope(sessionJson);
    final cookie = sessionResponse.headers['set-cookie']!.split(';').first;

    final createResponse = await http.post(
      Uri.parse('$baseUrl/api/v1/orders'),
      headers: {
        'content-type': 'application/json',
        'cookie': cookie,
        'x-hni-csrf-token': session.csrfToken!,
      },
      body: jsonEncode({
        'title': 'Role gate order',
        'objective': 'operator can create but not approve',
        'targetProduct': 'HNI',
        'targetBranch': 'main',
        'requestedBy': 'CEO',
        'sourceChannel': CommandChannel.dashboard.name,
        'assignedSquad': 'Feature Delivery',
        'riskProfile': const <String, dynamic>{},
      }),
    );
    final createdJson = jsonDecode(createResponse.body) as Map<String, dynamic>;
    final created = AppSnapshot.fromJson(
      createdJson['snapshot'] as Map<String, dynamic>,
    );
    final order = created.orders.first;
    final planApproval = order.pendingApproval(ApprovalType.plan)!;

    final forbidden = await http.post(
      Uri.parse(
        '$baseUrl/api/v1/orders/${order.id}/approvals/${planApproval.id}/approve',
      ),
      headers: {
        'content-type': 'application/json',
        'cookie': cookie,
        'x-hni-csrf-token': session.csrfToken!,
      },
    );

    expect(forbidden.statusCode, 403);
    expect(forbidden.body, contains('requiredRole'));
    expect(forbidden.body, contains('Approver'));
  });

  test(
    'mock oidc auth routes issue session and redirect back to dashboard',
    () async {
      final repository = MemoryBackendSnapshotRepository();
      final service = await AutoCompanyBackendService.load(
        repository,
        stageDelay: Duration.zero,
        authBootstrap: const AuthBootstrapConfig(
          enabled: true,
          defaultAuthenticated: false,
          userId: 'bootstrap-admin',
          email: 'admin@humantric.net',
          name: 'HNI Bootstrap Admin',
          role: 'Admin',
          provider: 'bootstrap',
          providerSubjectId: 'bootstrap-admin',
          sessionTtl: Duration(hours: 8),
          recentAuthTtl: Duration(minutes: 15),
        ),
        authProvider: AuthProviderAdapter.fromConfig(
          const AuthProviderConfig(
            mode: AuthProviderMode.mockOidc,
            defaultReturnTo: '/dashboard/home',
            mockIdentity: AuthProviderIdentity(
              userId: 'oidc-lead',
              email: 'lead@humantric.net',
              name: 'OIDC Lead',
              role: 'Lead',
              provider: 'mock-oidc',
              providerSubjectId: 'oidc-lead',
            ),
          ),
        ),
      );
      final handler = service.handler();

      final loginResponse = await handler.call(
        Request(
          'GET',
          Uri.parse('http://127.0.0.1/auth/login?returnTo=/dashboard/orders'),
        ),
      );

      expect(loginResponse.statusCode, 303);
      final flowCookie = loginResponse.headers['set-cookie']!.split(';').first;
      final callbackLocation = loginResponse.headers['location']!;
      expect(callbackLocation, contains('/auth/callback'));

      final callbackResponse = await handler.call(
        Request(
          'GET',
          Uri.parse('http://127.0.0.1$callbackLocation'),
          headers: {'cookie': flowCookie},
        ),
      );

      expect(callbackResponse.statusCode, 303);
      expect(callbackResponse.headers['location'], '/dashboard/orders');
      final sessionCookie = callbackResponse.headers['set-cookie']!
          .split(';')
          .first;

      final sessionResponse = await handler.call(
        Request(
          'GET',
          Uri.parse('http://127.0.0.1/api/v1/session'),
          headers: {'cookie': sessionCookie},
        ),
      );
      final sessionJson =
          jsonDecode(await sessionResponse.readAsString())
              as Map<String, dynamic>;
      final session = AuthSessionSnapshot.fromEnvelope(sessionJson);

      expect(session.authenticated, isTrue);
      expect(session.role, HniUserRole.lead);
      expect(session.principal?.provider, 'mock-oidc');
    },
  );
}

Future<void> _waitUntil(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Condition was not met before timeout.');
}
