import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/backend_service.dart';
import 'package:hni_auto_company_mvp/src/models.dart';

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
      () async => service.snapshot.orders
          .firstWhere((item) => item.id == order.id)
          .status ==
          OrderStatus.completed,
    );

    final completed = service.snapshot.orders.firstWhere((item) => item.id == order.id);
    expect(completed.status, OrderStatus.completed);
    expect(
      completed.reports.any((report) => report.stage == ExecutionStage.completion),
      isTrue,
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
