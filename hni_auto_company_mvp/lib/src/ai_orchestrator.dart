import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'models.dart';

class StageRunResult {
  StageRunResult({
    required this.runId,
    required this.status,
    required this.provider,
    required this.summary,
    required this.findings,
    required this.recommendations,
    required this.selectedPersonas,
    this.error,
  });

  final String runId;
  final String status;
  final String provider;
  final String summary;
  final List<String> findings;
  final List<String> recommendations;
  final List<String> selectedPersonas;
  final String? error;

  factory StageRunResult.fromJson(Map<String, dynamic> json) {
    return StageRunResult(
      runId: json['runId'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      provider: json['provider'] as String? ?? 'unknown',
      summary: json['summary'] as String? ?? '',
      findings: (json['findings'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      selectedPersonas: (json['selectedPersonas'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      error: json['error'] as String?,
    );
  }
}

class OrchestratorHealth {
  const OrchestratorHealth({required this.status, required this.providerMode});

  final String status;
  final String providerMode;
}

class AiOrchestratorClient {
  AiOrchestratorClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<OrchestratorHealth> health() async {
    final response = await _client.get(_uri('/health'));
    final decoded = _decodeJson(response);
    return OrchestratorHealth(
      status: decoded['status'] as String? ?? 'unknown',
      providerMode: decoded['providerMode'] as String? ?? 'unknown',
    );
  }

  Future<StageRunResult> startStageRun({
    required WorkOrder order,
    required ExecutionStage stage,
    required List<String> selectedPersonas,
  }) async {
    final response = await _client.post(
      _uri('/v1/stage-runs'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'orderId': order.id,
        'stage': stage.name,
        'objective': order.objective,
        'targetProduct': order.targetProduct,
        'targetBranch': order.targetBranch,
        'assignedSquad': order.assignedSquad,
        'selectedPersonas': selectedPersonas,
      }),
    );
    return StageRunResult.fromJson(_decodeJson(response));
  }

  Future<AgentGraph> fetchAgentGraph(String orderId) async {
    final response = await _client.get(
      _uri('/v1/work-orders/$orderId/agent-graph'),
    );
    return AgentGraph.fromJson(_decodeJson(response));
  }

  Uri _uri(String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Orchestrator request failed (${response.statusCode}): ${response.body}',
      );
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      throw HttpException('Orchestrator response was empty.');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static const _jsonHeaders = {'content-type': 'application/json'};
}
