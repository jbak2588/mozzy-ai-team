import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'models.dart';

class RemoteCommandResult {
  RemoteCommandResult({
    required this.snapshot,
    required this.result,
  });

  final AppSnapshot snapshot;
  final String result;
}

class BackendHealth {
  const BackendHealth({
    required this.baseUrl,
    required this.ok,
    required this.status,
  });

  final String baseUrl;
  final bool ok;
  final String status;
}

abstract class AppRepository {
  bool get isRemote => false;

  Future<AppSnapshot?> load();

  Future<void> save(AppSnapshot snapshot);

  Future<AppSnapshot> fetchSnapshot() async {
    throw UnsupportedError('fetchSnapshot is not supported for this repository.');
  }

  Future<AppSnapshot> createOrder(OrderDraft draft) async {
    throw UnsupportedError('createOrder is not supported for this repository.');
  }

  Future<AppSnapshot> approveApproval(String orderId, String approvalId) async {
    throw UnsupportedError(
      'approveApproval is not supported for this repository.',
    );
  }

  Future<AppSnapshot> holdOrder(String orderId, {String note = 'Manual hold'}) async {
    throw UnsupportedError('holdOrder is not supported for this repository.');
  }

  Future<AppSnapshot> resumeOrder(String orderId) async {
    throw UnsupportedError('resumeOrder is not supported for this repository.');
  }

  Future<RemoteCommandResult> submitCommand(
    CommandChannel channel,
    String input,
  ) async {
    throw UnsupportedError('submitCommand is not supported for this repository.');
  }

  Future<BackendHealth?> health() async => null;
}

class FileAppRepository extends AppRepository {
  FileAppRepository({this.overrideFile});

  final File? overrideFile;

  @override
  Future<AppSnapshot?> load() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      return null;
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return null;
    }
    return AppSnapshot.fromJson(
      jsonDecode(contents) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> save(AppSnapshot snapshot) async {
    final file = await _resolveFile();
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(snapshot.toJson()));
  }

  Future<File> _resolveFile() async {
    if (overrideFile != null) {
      return overrideFile!;
    }
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/hni_auto_company_mvp_state.json');
  }
}

class HttpAppRepository extends AppRepository {
  HttpAppRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  bool get isRemote => true;

  @override
  Future<AppSnapshot?> load() => fetchSnapshot();

  @override
  Future<void> save(AppSnapshot snapshot) async {}

  @override
  Future<AppSnapshot> fetchSnapshot() async {
    final response = await _client.get(_uri('/api/v1/snapshot'));
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> createOrder(OrderDraft draft) async {
    final response = await _client.post(
      _uri('/api/v1/orders'),
      headers: _jsonHeaders,
      body: jsonEncode(draft.toJson()),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> approveApproval(String orderId, String approvalId) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/approvals/$approvalId/approve'),
      headers: _jsonHeaders,
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> holdOrder(String orderId, {String note = 'Manual hold'}) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/hold'),
      headers: _jsonHeaders,
      body: jsonEncode({'note': note}),
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<AppSnapshot> resumeOrder(String orderId) async {
    final response = await _client.post(
      _uri('/api/v1/orders/$orderId/resume'),
      headers: _jsonHeaders,
    );
    return _decodeSnapshotResponse(response);
  }

  @override
  Future<RemoteCommandResult> submitCommand(
    CommandChannel channel,
    String input,
  ) async {
    final response = await _client.post(
      _uri('/api/v1/commands'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'channel': channel.name,
        'input': input,
      }),
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
      final response = await _client.get(_uri('/health'));
      final decoded = _decodeJson(response);
      return BackendHealth(
        baseUrl: baseUrl,
        ok: response.statusCode == 200,
        status: decoded['status'] as String? ?? 'unknown',
      );
    } catch (_) {
      return BackendHealth(
        baseUrl: baseUrl,
        ok: false,
        status: 'unreachable',
      );
    }
  }

  Uri _uri(String path) {
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
    throw HttpException('Response did not include snapshot payload.');
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Backend request failed (${response.statusCode}): ${response.body}',
      );
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      throw HttpException('Backend response was empty.');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static const _jsonHeaders = {
    'content-type': 'application/json',
  };
}
