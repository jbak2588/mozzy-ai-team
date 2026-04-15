import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/app.dart';
import 'package:hni_auto_company_mvp/src/auth_session.dart';
import 'package:hni_auto_company_mvp/src/models.dart';
import 'package:hni_auto_company_mvp/src/persistence.dart';
import 'package:hni_auto_company_mvp/src/store.dart';

void main() {
  testWidgets(
    'channel command snackbar does not require outer ScaffoldMessenger',
    (tester) async {
      _setDesktopViewport(tester);
      final store = await AutoCompanyStore.load(
        _MemoryRepository(),
        stageDelay: Duration.zero,
      );

      await tester.pumpWidget(
        HniAutoCompanyApp(
          store: store,
          sessionController: _sessionController(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Channels'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '/help');
      await tester.tap(find.widgetWithText(FilledButton, 'Run'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Command dispatched'), findsOneWidget);
    },
  );

  testWidgets('new order dialog opens without outer Navigator lookup failure', (
    tester,
  ) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(store: store, sessionController: _sessionController()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'New Work Order'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Create Work Order'), findsOneWidget);
    expect(find.text('Risk Flags'), findsOneWidget);
  });

  testWidgets('home dashboard shows 14-agent board entries', (tester) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(store: store, sessionController: _sessionController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('14-Agent Control Panel'), findsOneWidget);
    expect(find.text('ceo-bezos'), findsWidgets);
    expect(find.text('research-thompson'), findsOneWidget);
    expect(find.text('devops-hightower'), findsOneWidget);
  });

  testWidgets('dashboard route can open squads screen directly', (tester) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(
        store: store,
        sessionController: _sessionController(),
        initialLocation: '/dashboard/squads',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('14-Agent Dispatch Console'), findsOneWidget);
    expect(find.text('ceo-bezos'), findsWidgets);
    expect(find.text('qa-bach'), findsWidgets);
  });

  testWidgets('auth login placeholder route renders without crash', (
    tester,
  ) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(
        store: store,
        sessionController: AuthSessionController.seeded(
          AuthSessionSnapshot.anonymous(),
        ),
        initialLocation: '/auth/login',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login Route'), findsOneWidget);
    expect(find.text('Bootstrap Session'), findsOneWidget);
  });

  testWidgets('sidebar navigation changes dashboard route section', (
    tester,
  ) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(store: store, sessionController: _sessionController()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gates'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Approval Gates'), findsOneWidget);
  });

  testWidgets('operator session disables lead and approver actions on home', (
    tester,
  ) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(
        store: store,
        sessionController: _sessionController(role: 'Operator'),
      ),
    );
    await tester.pumpAndSettle();

    final dispatchButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Dispatch'),
    );
    final holdButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Hold Order'),
    );

    expect(dispatchButton.onPressed, isNull);
    expect(holdButton.onPressed, isNull);
  });

  testWidgets('operator session disables approver buttons on orders', (
    tester,
  ) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(
        store: store,
        sessionController: _sessionController(role: 'Operator'),
        initialLocation: '/dashboard/orders',
      ),
    );
    await tester.pumpAndSettle();

    final approvePlan = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Approve Plan'),
    );
    final holdButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Hold'),
    );
    final resumeButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Resume'),
    );

    expect(approvePlan.onPressed, isNull);
    expect(holdButton.onPressed, isNull);
    expect(resumeButton.onPressed, isNull);
  });

  testWidgets('admin session keeps protected order actions enabled', (
    tester,
  ) async {
    _setDesktopViewport(tester);
    final store = await AutoCompanyStore.load(
      _MemoryRepository(),
      stageDelay: Duration.zero,
    );

    await tester.pumpWidget(
      HniAutoCompanyApp(
        store: store,
        sessionController: _sessionController(role: 'Admin'),
        initialLocation: '/dashboard/orders',
      ),
    );
    await tester.pumpAndSettle();

    final approvePlan = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Approve Plan'),
    );
    final holdButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Hold'),
    );

    expect(approvePlan.onPressed, isNotNull);
    expect(holdButton.onPressed, isNotNull);
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

void _setDesktopViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1600, 1200);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

AuthSessionController _sessionController({String role = 'Admin'}) {
  if (role == 'Admin') {
    return AuthSessionController.seeded(AuthSessionSnapshot.localAdmin());
  }

  final now = DateTime.now().toUtc();
  return AuthSessionController.seeded(
    AuthSessionSnapshot(
      authenticated: true,
      principal: SessionPrincipal(
        userId: '${role.toLowerCase()}-user',
        email: '${role.toLowerCase()}@humantric.net',
        name: '$role User',
        role: role,
        provider: 'test',
        providerSubjectId: '${role.toLowerCase()}-user',
      ),
      capabilities: {
        'canApprove': role == 'Approver' || role == 'CEO' || role == 'Admin',
        'canAccessStrategy':
            role == 'Lead' ||
            role == 'Approver' ||
            role == 'CEO' ||
            role == 'Admin',
        'canManageTelegramOps': role == 'Admin',
        'canExportAudit':
            role == 'Approver' || role == 'CEO' || role == 'Admin',
      },
      authTime: now,
      issuedAt: now,
      expiresAt: now.add(const Duration(hours: 8)),
      recentAuthExpiresAt: now.add(const Duration(minutes: 15)),
      csrfToken: 'test-csrf',
    ),
  );
}
