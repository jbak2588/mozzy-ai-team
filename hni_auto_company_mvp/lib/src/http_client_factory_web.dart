import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

http.Client createHttpClient({required String baseUrl}) {
  final client = BrowserClient();
  if (baseUrl.isNotEmpty) {
    client.withCredentials = true;
  }
  return client;
}
