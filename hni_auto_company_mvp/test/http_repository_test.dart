import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/backend_service.dart';
import 'package:hni_auto_company_mvp/src/models.dart';
import 'package:hni_auto_company_mvp/src/persistence.dart';

void main() {
  test('http repository talks to backend service and sees completed order', () async {
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

    final client = HttpAppRepository(
      baseUrl: 'http://${server.address.host}:${server.port}',
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

    await client.approveApproval(newOrder.id, planApproval!.id);
    await _waitUntil(() async {
      final snapshot = await client.fetchSnapshot();
      return snapshot.orders.firstWhere((item) => item.id == newOrder.id).status ==
          OrderStatus.completed;
    });

    final completed = await client.fetchSnapshot();
    expect(
      completed.orders.firstWhere((item) => item.id == newOrder.id).status,
      OrderStatus.completed,
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
