import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_session.dart';
import 'http_client_factory.dart';
import 'models.dart';

class BackendRequestException implements Exception {
  const BackendRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RemoteCommandResult {
  RemoteCommandResult({required this.snapshot, required this.result});

  final AppSnapshot snapshot;
  final String result;
}

class BackendHealth {
  const BackendHealth({
    required this.baseUrl,
    required this.ok,
    required this.status,
    this.orchestratorStatus,
  });

  final String baseUrl;
  final bool ok;
  final String status;
  final String? orchestratorStatus;
}

abstract class AppRepository {
  bool get isRemote => false;

  Future<AppSnapshot?> load();

  Future<void> save(AppSnapshot snapshot);

  Future<AppSnapshot> fetchSnapshot() async {
    throw UnsupportedError(
      'fetchSnapshot is not supported for this repository.',
    );
  }

  Future<AppSnapshot> createOrder(OrderDraft draft) async {
    throw UnsupportedError('createOrder is not supported for this repository.');
  }

  Future<AppSnapshot> approveApproval(String orderId, String approvalId) async {
    throw UnsupportedError(
      'approveApproval is not supported for this repository.',
    );
  }

  Future<AppSnapshot> holdOrder(
    String orderId, {
    String note = 'Manual hold',
  }) async {
    throw UnsupportedError('holdOrder is not supported for this repository.');
  }

  Future<AppSnapshot> resumeOrder(String orderId) async {
    throw UnsupportedError('resumeOrder is not supported for this repository.');
  }

  Future<AppSnapshot> assignPersonaLead(String orderId, String persona) async {
    throw UnsupportedError(
      'assignPersonaLead is not supported for this repository.',
    );
  }

  Future<AppSnapshot> dispatchPersona(String orderId, String persona) async {
    throw UnsupportedError(
      'dispatchPersona is not supported for this repository.',
    );
  }

  Future<AgentGraph> fetchAgentGraph(String orderId) async {
    throw UnsupportedError(
      'fetchAgentGraph is not supported for this repository.',
    );
  }

  Future<RemoteCommandResult> submitCommand(
    CommandChannel channel,
    String input,
  ) async {
    throw UnsupportedError(
      'submitCommand is not supported for this repository.',
    );
  }

  Future<BackendHealth?> health() async => null;
}

class HttpAppRepository extends AppRepository {
  HttpAppRepository({
    required this.baseUrl,
    this.sessionController,
    http.Client? client,
  }) : _client = client ?? createHttpClient(baseUrl: baseUrl);

  final String baseUrl;
  final AuthSessionController? sessionController;
  final http.Client _client;

  @override
  bool get isRemote => true;

  @override
  Future<AppSnapshot?> load() => fetchSnapshot();

  @override
  Future<void> save(AppSnapshot snapshot) async {}

  @override
  Future<AppSnapshot> fetchSnapshot() async {
    final response = await _client.get(
      _uri('/api/v1/snapshot'),
      headers: _headers(),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> createOrder(OrderDraft draft) async {
    final response = await _client.post(
      _uri('/api/v1/orders'),
      headers: _headers(includeCsrf: true),
      body: jsonEncode(draft.toJson()),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> approveApproval(String orderId, String approvalId) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/approvals/$approvalId/approve'),
      headers: _headers(includeCsrf: true),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> holdOrder(
    String orderId, {
    String note = 'Manual hold',
  }) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/hold'),
      headers: _headers(includeCsrf: true),
      body: jsonEncode({'note': note}),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> resumeOrder(String orderId) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/resume'),
      headers: _headers(includeCsrf: true),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> assignPersonaLead(String orderId, String persona) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/agent-graph/assign'),
      headers: _headers(includeCsrf: true),
      body: jsonEncode({'persona': persona}),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> dispatchPersona(String orderId, String persona) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/agent-graph/dispatch'),
      headers: _headers(includeCsrf: true),
      body: jsonEncode({'persona': persona}),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AgentGraph> fetchAgentGraph(String orderId) async {
    final response = await _client.get(
      _uri('/api/v1/orders/$orderId/agent-graph'),
      headers: _headers(),
    );
    final decoded = _decodeJson(response);
    final payload = decoded['agentGraph'];
    if (payload is! Map<String, dynamic>) {
      throw const BackendRequestException(
        'Response did not include agentGraph payload.',
      );
    }
    return AgentGraph.fromJson(payload);
  }

  @override
  Future<RemoteCommandResult> submitCommand(
    CommandChannel channel,
    String input,
  ) async {
    final response = await _client.post(
      _uri('/api/v1/commands'),
      headers: _headers(includeCsrf: true),
      body: jsonEncode({'channel': channel.name, 'input': input}),
    );
    final decoded = _decodeJson(response);
    return RemoteCommandResult(
      snapshot: _snapshotFromPayload(decoded),
      result: decoded['result'] as String? ?? 'Command processed.',
    );
  }

  @override
  Future<BackendHealth?> health() async {
    try {
      final response = await _client.get(_uri('/health'), headers: _headers());
      final decoded = _decodeJson(response);
      return BackendHealth(
        baseUrl: baseUrl,
        ok: response.statusCode == 200,
        status: decoded['status'] as String? ?? 'unknown',
        orchestratorStatus: decoded['orchestratorStatus'] as String?,
      );
    } catch (_) {
      return BackendHealth(baseUrl: baseUrl, ok: false, status: 'unreachable');
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

  AppSnapshot _decodeSnapshotResponse(http.Response response) {
    final decoded = _decodeJson(response);
    return _snapshotFromPayload(decoded);
  }

  AppSnapshot _snapshotFromPayload(Map<String, dynamic> decoded) {
    final snapshotJson = decoded['snapshot'];
    if (snapshotJson is Map<String, dynamic>) {
      return AppSnapshot.fromJson(snapshotJson);
    }
    throw const BackendRequestException(
      'Response did not include snapshot payload.',
    );
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendRequestException(
        'Backend request failed (${response.statusCode}): ${response.body}',
      );
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      throw const BackendRequestException('Backend response was empty.');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Map<String, String> _headers({bool includeCsrf = false}) {
    final session = sessionController;
    if (session == null) {
      return {..._jsonHeaders};
    }
    return session.requestHeaders(includeCsrf: includeCsrf);
  }

  static const _jsonHeaders = {'content-type': 'application/json'};
}
