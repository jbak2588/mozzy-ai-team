import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/app.dart';
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

      await tester.pumpWidget(HniAutoCompanyApp(store: store));
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

    await tester.pumpWidget(HniAutoCompanyApp(store: store));
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

    await tester.pumpWidget(HniAutoCompanyApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('14-Agent Board'), findsOneWidget);
    expect(find.text('ceo-bezos'), findsOneWidget);
    expect(find.text('research-thompson'), findsOneWidget);
    expect(find.text('devops-hightower'), findsOneWidget);
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
