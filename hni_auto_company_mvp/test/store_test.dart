import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/models.dart';
import 'package:hni_auto_company_mvp/src/persistence.dart';
import 'package:hni_auto_company_mvp/src/store.dart';

void main() {
  test('plan approval auto-runs remaining stages to completion', () async {
    final repository = _MemoryRepository();
    final store = await AutoCompanyStore.load(
      repository,
      stageDelay: Duration.zero,
    );

    final order = await store.createOrder(
      OrderDraft(
        title: 'MVP auto run',
        objective: 'approval 후 chain 완료',
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

    await store.approveApproval(order.id, planApproval!.id);

    final completedOrder = store.orders.firstWhere(
      (item) => item.id == order.id,
    );
    expect(completedOrder.status, OrderStatus.completed);
    expect(
      completedOrder.stageRecords.every(
        (record) => record.state == StageState.completed,
      ),
      isTrue,
    );
    expect(
      completedOrder.reports.any(
        (report) => report.stage == ExecutionStage.completion,
      ),
      isTrue,
    );
  });

  test('risk gate keeps order on hold until approved', () async {
    final repository = _MemoryRepository();
    final store = await AutoCompanyStore.load(
      repository,
      stageDelay: Duration.zero,
    );

    final order = await store.createOrder(
      OrderDraft(
        title: 'Risky order',
        objective: 'risk gate 확인',
        targetProduct: 'HNI',
        targetBranch: 'main',
        requestedBy: 'CEO',
        sourceChannel: CommandChannel.dashboard,
        assignedSquad: 'Trust & Readiness',
        riskProfile: RiskProfile(security: true),
      ),
    );

    final planApproval = order.pendingApproval(ApprovalType.plan)!;
    await store.approveApproval(order.id, planApproval.id);

    final heldOrder = store.orders.firstWhere((item) => item.id == order.id);
    expect(heldOrder.status, OrderStatus.hold);

    final riskApproval = heldOrder.pendingApproval(ApprovalType.risk)!;
    await store.approveApproval(order.id, riskApproval.id);

    final completedOrder = store.orders.firstWhere(
      (item) => item.id == order.id,
    );
    expect(completedOrder.status, OrderStatus.completed);
  });
}

class _MemoryRepository extends AppRepository {
  AppSnapshot? _snapshot;

  @override
  Future<AppSnapshot?> load() async => _snapshot;

  @override
  Future<void> save(AppSnapshot snapshot) async {
    _snapshot = AppSnapshot.fromJson(snapshot.toJson());
  }
}
