import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/persistence.dart';
import 'src/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  final repository = apiBaseUrl.isEmpty
      ? FileAppRepository()
      : HttpAppRepository(baseUrl: apiBaseUrl);
  final store = await AutoCompanyStore.load(repository);
  runApp(HniAutoCompanyApp(store: store));
}
