import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_session_models.dart';
import 'http_client_factory.dart';

export 'auth_session_models.dart';

enum AuthSessionPhase { loading, ready, error }

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({
    required this.baseUrl,
    http.Client? client,
    AuthSessionSnapshot? initialSession,
    AuthSessionPhase initialPhase = AuthSessionPhase.loading,
  }) : _client = client ?? createHttpClient(baseUrl: baseUrl),
       _session = initialSession ?? AuthSessionSnapshot.anonymous(),
       _phase = initialPhase;

  factory AuthSessionController.seeded(
    AuthSessionSnapshot session, {
    String baseUrl = '',
    http.Client? client,
  }) {
    return AuthSessionController(
      baseUrl: baseUrl,
      client: client,
      initialSession: session,
      initialPhase: AuthSessionPhase.ready,
    );
  }

  final String baseUrl;
  final http.Client _client;
  AuthSessionSnapshot _session;
  AuthSessionPhase _phase;
  String? _lastError;
  String? _cookieHeader;

  AuthSessionSnapshot get session => _session;

  AuthSessionPhase get phase => _phase;

  String? get lastError => _lastError;

  String? get csrfToken => _session.csrfToken;

  String? get cookieHeader => _cookieHeader;

  bool get isLoading => _phase == AuthSessionPhase.loading;

  bool get isAuthenticated => _session.authenticated;

  Future<void> refresh() async {
    _phase = AuthSessionPhase.loading;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _client.get(_uri('/api/v1/session'));
      _session = _decodeSession(response);
      _storeCookieHeader(response);
      _phase = AuthSessionPhase.ready;
    } catch (error) {
      _session = AuthSessionSnapshot.anonymous();
      _phase = AuthSessionPhase.error;
      _lastError = error.toString();
    }
    notifyListeners();
  }

  Future<String?> bootstrapLogin({String returnTo = '/dashboard/home'}) async {
    _phase = AuthSessionPhase.loading;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _client.post(
        _uri('/api/v1/session/bootstrap'),
        headers: _jsonHeaders,
        body: jsonEncode({'returnTo': returnTo}),
      );
      final decoded = _decodeJson(response);
      _session = AuthSessionSnapshot.fromEnvelope(decoded);
      _storeCookieHeader(response);
      _phase = AuthSessionPhase.ready;
      notifyListeners();
      return decoded['redirectTo'] as String?;
    } catch (error) {
      _phase = AuthSessionPhase.error;
      _lastError = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String?> logout({String returnTo = '/auth/login'}) async {
    _phase = AuthSessionPhase.loading;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _client.post(
        _uri('/api/v1/session/logout'),
        headers: {...requestHeaders(includeCsrf: true)},
        body: jsonEncode({'returnTo': returnTo}),
      );
      final decoded = _decodeJson(response);
      _session = AuthSessionSnapshot.fromEnvelope(decoded);
      _storeCookieHeader(response);
      _phase = AuthSessionPhase.ready;
      notifyListeners();
      return decoded['redirectTo'] as String?;
    } catch (error) {
      _phase = AuthSessionPhase.error;
      _lastError = error.toString();
      notifyListeners();
      return null;
    }
  }

  Uri _uri(String path) {
    if (baseUrl.isEmpty) {
      return Uri.parse(path);
    }
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  AuthSessionSnapshot _decodeSession(http.Response response) {
    final decoded = _decodeJson(response);
    return AuthSessionSnapshot.fromEnvelope(decoded);
  }

  Map<String, String> requestHeaders({
    bool includeJson = true,
    bool includeCsrf = false,
  }) {
    return {
      if (includeJson) ..._jsonHeaders,
      if (includeCsrf && _session.csrfToken != null)
        'X-HNI-CSRF-Token': _session.csrfToken!,
      if (!kIsWeb && _cookieHeader != null) 'Cookie': _cookieHeader!,
    };
  }

  void _storeCookieHeader(http.Response response) {
    if (kIsWeb) {
      return;
    }
    final raw = response.headers['set-cookie'];
    if (raw == null || raw.trim().isEmpty) {
      return;
    }
    final first = raw.split(';').first.trim();
    if (first.isEmpty) {
      return;
    }
    _cookieHeader = first;
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FormatException(
        'Session request failed (${response.statusCode}): ${response.body}',
      );
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      throw const FormatException('Session response was empty.');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static const _jsonHeaders = {'content-type': 'application/json'};
}
