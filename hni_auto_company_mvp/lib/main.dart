import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/auth_session.dart';
import 'src/persistence.dart';
import 'src/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  final remoteMode = kIsWeb || apiBaseUrl.isNotEmpty;
  final sessionController = remoteMode
      ? AuthSessionController(baseUrl: apiBaseUrl)
      : AuthSessionController.seeded(AuthSessionSnapshot.localAdmin());
  if (remoteMode) {
    await sessionController.refresh();
  }
  final repository = kIsWeb
      ? HttpAppRepository(
          baseUrl: apiBaseUrl,
          sessionController: sessionController,
        )
      : apiBaseUrl.isEmpty
      ? FileAppRepository()
      : HttpAppRepository(
          baseUrl: apiBaseUrl,
          sessionController: sessionController,
        );
  final store = remoteMode && !sessionController.isAuthenticated
      ? await AutoCompanyStore.loadRemoteShell(repository)
      : await AutoCompanyStore.load(repository);
  runApp(HniAutoCompanyApp(store: store, sessionController: sessionController));
}
