import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/auth_session.dart';
import 'package:hni_auto_company_mvp/src/backend_service.dart';
import 'package:hni_auto_company_mvp/src/models.dart';
import 'package:hni_auto_company_mvp/src/persistence.dart';

void main() {
  test(
    'http repository talks to backend service and sees completed order',
    () async {
      final repository = MemoryBackendSnapshotRepository();
      final service = await AutoCompanyBackendService.load(
        repository,
        stageDelay: Duration.zero,
      );
      final server = await AutoCompanyBackendService.serve(
        service: service,
        port: 0,
      );
      addTearDown(server.close);

      final sessionController = AuthSessionController(
        baseUrl: 'http://${server.address.host}:${server.port}',
      );
      await sessionController.refresh();
      expect(sessionController.isAuthenticated, isFalse);
      await expectLater(
        sessionController.bootstrapLogin(returnTo: '/dashboard/home'),
        completion('/dashboard/home'),
      );
      expect(sessionController.isAuthenticated, isTrue);

      final client = HttpAppRepository(
        baseUrl: 'http://${server.address.host}:${server.port}',
        sessionController: sessionController,
      );

      final initial = await client.fetchSnapshot();
      expect(initial.orders, isNotEmpty);

      final created = await client.createOrder(
        OrderDraft(
          title: 'Remote order',
          objective: 'http repository flow',
          targetProduct: 'HNI',
          targetBranch: 'main',
          requestedBy: 'CEO',
          sourceChannel: CommandChannel.dashboard,
          assignedSquad: 'Feature Delivery',
          riskProfile: RiskProfile(),
        ),
      );

      final newOrder = created.orders.first;
      final planApproval = newOrder.pendingApproval(ApprovalType.plan);
      expect(planApproval, isNotNull);

      final initialGraph = await client.fetchAgentGraph(newOrder.id);
      expect(initialGraph.orderId, newOrder.id);
      expect(initialGraph.nodes, isNotEmpty);

      await client.assignPersonaLead(newOrder.id, 'qa-bach');
      await client.dispatchPersona(newOrder.id, 'ui-duarte');
      final updatedGraph = await client.fetchAgentGraph(newOrder.id);
      expect(updatedGraph.leadPersona, 'qa-bach');
      expect(
        updatedGraph.nodes
            .firstWhere((item) => item.persona == 'ui-duarte')
            .assigned,
        isTrue,
      );

      await client.approveApproval(newOrder.id, planApproval!.id);
      await _waitUntil(() async {
        final snapshot = await client.fetchSnapshot();
        return snapshot.orders
                .firstWhere((item) => item.id == newOrder.id)
                .status ==
            OrderStatus.completed;
      });

      final completed = await client.fetchSnapshot();
      expect(
        completed.orders.firstWhere((item) => item.id == newOrder.id).status,
        OrderStatus.completed,
      );
    },
  );

  test('protected business API denies anonymous snapshot request', () async {
    final repository = MemoryBackendSnapshotRepository();
    final service = await AutoCompanyBackendService.load(
      repository,
      stageDelay: Duration.zero,
      authBootstrap: const AuthBootstrapConfig(
        enabled: true,
        defaultAuthenticated: false,
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

    final client = HttpAppRepository(
      baseUrl: 'http://${server.address.host}:${server.port}',
    );

    await expectLater(
      client.fetchSnapshot(),
      throwsA(
        isA<BackendRequestException>().having(
          (error) => error.message,
          'message',
          contains('401'),
        ),
      ),
    );
  });
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
