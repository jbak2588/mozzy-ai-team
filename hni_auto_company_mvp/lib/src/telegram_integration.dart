import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'command_parser.dart';
import 'models.dart';

class TelegramIntegrationConfig {
  const TelegramIntegrationConfig({
    required this.botToken,
    required this.apiBaseUrl,
    required this.webhookPath,
    this.webhookBaseUrl,
    this.webhookSecret,
    this.allowedChatIds = const {},
    this.allowedSenderIds = const {},
    this.allowedUsernames = const {},
    this.approverSenderIds = const {},
    this.approverUsernames = const {},
    this.pollingEnabled = false,
    this.pollingInterval = const Duration(milliseconds: 1500),
    this.pollingTimeout = Duration.zero,
    this.pollingBatchLimit = 10,
  });

  final String botToken;
  final String apiBaseUrl;
  final String webhookPath;
  final String? webhookBaseUrl;
  final String? webhookSecret;
  final Set<String> allowedChatIds;
  final Set<String> allowedSenderIds;
  final Set<String> allowedUsernames;
  final Set<String> approverSenderIds;
  final Set<String> approverUsernames;
  final bool pollingEnabled;
  final Duration pollingInterval;
  final Duration pollingTimeout;
  final int pollingBatchLimit;

  bool get isConfigured => botToken.trim().isNotEmpty;

  bool get hasSenderPolicy =>
      allowedSenderIds.isNotEmpty || allowedUsernames.isNotEmpty;

  bool get hasApproverPolicy =>
      approverSenderIds.isNotEmpty || approverUsernames.isNotEmpty;

  bool get hasChatPolicy => allowedChatIds.isNotEmpty;

  String? get resolvedWebhookUrl {
    final baseUrl = webhookBaseUrl?.trim();
    if (baseUrl == null || baseUrl.isEmpty) {
      return null;
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = webhookPath.startsWith('/')
        ? webhookPath
        : '/$webhookPath';
    return '$normalizedBase$normalizedPath';
  }

  static TelegramIntegrationConfig fromEnvironment({
    String webhookPath = '/api/v1/integrations/telegram/webhook',
  }) {
    return TelegramIntegrationConfig(
      botToken: _envOrDefine('HNI_TELEGRAM_BOT_TOKEN'),
      apiBaseUrl: _envOrDefine(
        'HNI_TELEGRAM_API_BASE_URL',
        defaultValue: 'https://api.telegram.org',
      ),
      webhookPath: webhookPath,
      webhookBaseUrl: _nullableEnv('HNI_TELEGRAM_WEBHOOK_BASE_URL'),
      webhookSecret: _nullableEnv('HNI_TELEGRAM_WEBHOOK_SECRET'),
      allowedChatIds: _stringSetFromEnv('HNI_TELEGRAM_ALLOWED_CHAT_IDS'),
      allowedSenderIds: _stringSetFromEnv('HNI_TELEGRAM_ALLOWED_SENDER_IDS'),
      allowedUsernames: _normalizedUsernames(
        _stringSetFromEnv('HNI_TELEGRAM_ALLOWED_USERNAMES'),
      ),
      approverSenderIds: _stringSetFromEnv('HNI_TELEGRAM_APPROVER_SENDER_IDS'),
      approverUsernames: _normalizedUsernames(
        _stringSetFromEnv('HNI_TELEGRAM_APPROVER_USERNAMES'),
      ),
      pollingEnabled: _boolEnv('HNI_TELEGRAM_POLLING_ENABLED'),
      pollingInterval: Duration(
        milliseconds: _intEnv(
          'HNI_TELEGRAM_POLLING_INTERVAL_MS',
          defaultValue: 1500,
          minimum: 0,
        ),
      ),
      pollingTimeout: Duration(
        seconds: _intEnv(
          'HNI_TELEGRAM_POLLING_TIMEOUT_SECONDS',
          defaultValue: 0,
          minimum: 0,
        ),
      ),
      pollingBatchLimit: _intEnv(
        'HNI_TELEGRAM_POLLING_BATCH_LIMIT',
        defaultValue: 10,
        minimum: 1,
        maximum: 100,
      ),
    );
  }
}

class TelegramBotProfile {
  const TelegramBotProfile({
    required this.id,
    required this.firstName,
    this.username,
  });

  final String id;
  final String firstName;
  final String? username;

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'username': username,
  };

  factory TelegramBotProfile.fromJson(Map<String, dynamic> json) {
    return TelegramBotProfile(
      id: (json['id'] ?? '').toString(),
      firstName: json['first_name'] as String? ?? '',
      username: json['username'] as String?,
    );
  }
}

class TelegramWebhookStatus {
  const TelegramWebhookStatus({
    required this.url,
    required this.pendingUpdateCount,
    required this.hasCustomCertificate,
    this.ipAddress,
    this.lastErrorDate,
    this.lastErrorMessage,
    this.maxConnections,
    this.allowedUpdates = const [],
  });

  final String url;
  final int pendingUpdateCount;
  final bool hasCustomCertificate;
  final String? ipAddress;
  final DateTime? lastErrorDate;
  final String? lastErrorMessage;
  final int? maxConnections;
  final List<String> allowedUpdates;

  Map<String, dynamic> toJson() => {
    'url': url,
    'pendingUpdateCount': pendingUpdateCount,
    'hasCustomCertificate': hasCustomCertificate,
    'ipAddress': ipAddress,
    'lastErrorDate': lastErrorDate?.toIso8601String(),
    'lastErrorMessage': lastErrorMessage,
    'maxConnections': maxConnections,
    'allowedUpdates': allowedUpdates,
  };

  factory TelegramWebhookStatus.fromJson(Map<String, dynamic> json) {
    final lastErrorRaw = json['last_error_date'];
    return TelegramWebhookStatus(
      url: json['url'] as String? ?? '',
      pendingUpdateCount: (json['pending_update_count'] as num?)?.toInt() ?? 0,
      hasCustomCertificate: json['has_custom_certificate'] == true,
      ipAddress: json['ip_address'] as String?,
      lastErrorDate: lastErrorRaw is num
          ? DateTime.fromMillisecondsSinceEpoch(
              lastErrorRaw.toInt() * 1000,
              isUtc: true,
            ).toLocal()
          : null,
      lastErrorMessage: json['last_error_message'] as String?,
      maxConnections: (json['max_connections'] as num?)?.toInt(),
      allowedUpdates: (json['allowed_updates'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class TelegramNormalizedUpdate {
  const TelegramNormalizedUpdate({
    required this.updateId,
    required this.externalMessageId,
    required this.chatId,
    required this.chatLabel,
    required this.senderId,
    required this.senderLabel,
    required this.text,
    this.senderUsername,
  });

  final String updateId;
  final String externalMessageId;
  final String chatId;
  final String chatLabel;
  final String senderId;
  final String senderLabel;
  final String? senderUsername;
  final String text;

  static TelegramNormalizedUpdate? fromJson(Map<String, dynamic> json) {
    final message = _messageFromUpdate(json);
    if (message == null) {
      return null;
    }
    final text = message['text'];
    if (text is! String || text.trim().isEmpty) {
      return null;
    }
    final chat = message['chat'] as Map<String, dynamic>? ?? const {};
    final from = message['from'] as Map<String, dynamic>? ?? const {};
    final senderId = (from['id'] ?? '').toString();
    final senderUsername = _normalizeUsername(from['username'] as String?);
    final senderLabel = _senderLabelFromJson(from);
    return TelegramNormalizedUpdate(
      updateId: (json['update_id'] ?? '').toString(),
      externalMessageId: (message['message_id'] ?? '').toString(),
      chatId: (chat['id'] ?? '').toString(),
      chatLabel: _chatLabelFromJson(chat),
      senderId: senderId,
      senderLabel: senderLabel,
      senderUsername: senderUsername,
      text: text.trim(),
    );
  }

  static Map<String, dynamic>? _messageFromUpdate(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is Map<String, dynamic>) {
      return message;
    }
    return null;
  }

  static String _senderLabelFromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final joined = [
      firstName,
      lastName,
    ].where((item) => item.trim().isNotEmpty).join(' ').trim();
    if (joined.isNotEmpty) {
      return joined;
    }
    final username = _normalizeUsername(json['username'] as String?);
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    return 'tg:${(json['id'] ?? '').toString()}';
  }

  static String _chatLabelFromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    if (title.trim().isNotEmpty) {
      return title.trim();
    }
    final username = _normalizeUsername(json['username'] as String?);
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final joined = [
      firstName,
      lastName,
    ].where((item) => item.trim().isNotEmpty).join(' ').trim();
    if (joined.isNotEmpty) {
      return joined;
    }
    return 'chat:${(json['id'] ?? '').toString()}';
  }
}

class TelegramAuthorizationResult {
  const TelegramAuthorizationResult._({
    required this.allowed,
    this.reason,
    this.replyToSender = false,
  });

  const TelegramAuthorizationResult.allowed() : this._(allowed: true);

  const TelegramAuthorizationResult.denied(
    String reason, {
    bool replyToSender = true,
  }) : this._(allowed: false, reason: reason, replyToSender: replyToSender);

  final bool allowed;
  final String? reason;
  final bool replyToSender;
}

abstract class TelegramApiClient {
  Future<TelegramBotProfile> getMe();

  Future<TelegramWebhookStatus> getWebhookInfo();

  Future<List<Map<String, dynamic>>> getUpdates({
    int? offset,
    int limit = 10,
    int timeoutSeconds = 0,
    List<String> allowedUpdates = const ['message'],
  });

  Future<void> setWebhook({
    required String url,
    String? secretToken,
    List<String> allowedUpdates = const ['message'],
    bool dropPendingUpdates = false,
  });

  Future<void> deleteWebhook({bool dropPendingUpdates = false});

  Future<void> sendMessage({required String chatId, required String text});
}

class HttpTelegramApiClient implements TelegramApiClient {
  HttpTelegramApiClient({required this.config, http.Client? client})
    : _client = client ?? http.Client();

  final TelegramIntegrationConfig config;
  final http.Client _client;

  @override
  Future<TelegramBotProfile> getMe() async {
    final result = await _postMap('getMe', const {});
    return TelegramBotProfile.fromJson(result);
  }

  @override
  Future<TelegramWebhookStatus> getWebhookInfo() async {
    final result = await _postMap('getWebhookInfo', const {});
    return TelegramWebhookStatus.fromJson(result);
  }

  @override
  Future<List<Map<String, dynamic>>> getUpdates({
    int? offset,
    int limit = 10,
    int timeoutSeconds = 0,
    List<String> allowedUpdates = const ['message'],
  }) async {
    final payload = <String, dynamic>{
      'limit': limit,
      'timeout': timeoutSeconds,
      'allowed_updates': allowedUpdates,
    };
    if (offset != null) {
      payload['offset'] = offset;
    }
    final result = await _postResult('getUpdates', payload);
    if (result is! List<dynamic>) {
      return const [];
    }
    return result
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<void> setWebhook({
    required String url,
    String? secretToken,
    List<String> allowedUpdates = const ['message'],
    bool dropPendingUpdates = false,
  }) async {
    final payload = <String, dynamic>{
      'url': url,
      'allowed_updates': allowedUpdates,
      'drop_pending_updates': dropPendingUpdates,
    };
    if (secretToken != null && secretToken.isNotEmpty) {
      payload['secret_token'] = secretToken;
    }
    await _postMap('setWebhook', payload);
  }

  @override
  Future<void> deleteWebhook({bool dropPendingUpdates = false}) async {
    await _postMap('deleteWebhook', {
      'drop_pending_updates': dropPendingUpdates,
    });
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    await _postMap('sendMessage', {'chat_id': chatId, 'text': text});
  }

  Future<Map<String, dynamic>> _postMap(
    String method,
    Map<String, dynamic> payload,
  ) async {
    final result = await _postResult(method, payload);
    if (result is Map<String, dynamic>) {
      return result;
    }
    return {'value': result};
  }

  Future<dynamic> _postResult(
    String method,
    Map<String, dynamic> payload,
  ) async {
    final baseUrl = config.apiBaseUrl.endsWith('/')
        ? config.apiBaseUrl.substring(0, config.apiBaseUrl.length - 1)
        : config.apiBaseUrl;
    final uri = Uri.parse('$baseUrl/bot${config.botToken}/$method');
    final response = await _client.post(
      uri,
      headers: const {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Telegram API request failed (${response.statusCode}): ${response.body}',
      );
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      throw HttpException('Telegram API response was empty.');
    }
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    if (decoded['ok'] != true) {
      throw HttpException(
        decoded['description'] as String? ?? 'Telegram API request failed.',
      );
    }
    return decoded['result'];
  }
}

class TelegramIntegration {
  TelegramIntegration({required this.config, TelegramApiClient? apiClient})
    : _apiClient = apiClient ?? HttpTelegramApiClient(config: config);

  final TelegramIntegrationConfig config;
  final TelegramApiClient _apiClient;

  bool get isConfigured => config.isConfigured;

  bool validateSecret(String? headerValue) {
    final expected = config.webhookSecret;
    if (expected == null || expected.isEmpty) {
      return true;
    }
    return headerValue == expected;
  }

  TelegramNormalizedUpdate? normalizeUpdate(Map<String, dynamic> payload) {
    return TelegramNormalizedUpdate.fromJson(payload);
  }

  TelegramAuthorizationResult authorize(
    TelegramNormalizedUpdate update,
    ParsedCommand command,
  ) {
    if (config.hasChatPolicy &&
        !config.allowedChatIds.contains(update.chatId)) {
      return const TelegramAuthorizationResult.denied(
        'Chat is not allowed for HNI command intake.',
        replyToSender: false,
      );
    }

    if (_requiresPrivilegedAccess(command.type)) {
      if (!_isApproverAllowed(update)) {
        return const TelegramAuthorizationResult.denied(
          'Sender is not allowed to run approval or hold commands.',
        );
      }
      return const TelegramAuthorizationResult.allowed();
    }

    if (!_isSenderAllowed(update)) {
      return const TelegramAuthorizationResult.denied(
        'Sender is not allowed to issue Telegram work-order commands.',
      );
    }
    return const TelegramAuthorizationResult.allowed();
  }

  Future<Map<String, dynamic>> statusPayload() async {
    if (!isConfigured) {
      return {
        'configured': false,
        'status': 'disabled',
        'mode': config.pollingEnabled ? 'polling' : 'webhook',
        'pollingEnabled': config.pollingEnabled,
        'pollingIntervalMs': config.pollingInterval.inMilliseconds,
        'pollingTimeoutSeconds': config.pollingTimeout.inSeconds,
        'pollingBatchLimit': config.pollingBatchLimit,
        'webhookPath': config.webhookPath,
        'webhookUrl': config.resolvedWebhookUrl,
      };
    }

    try {
      final bot = await _apiClient.getMe();
      final webhook = await _apiClient.getWebhookInfo();
      return {
        'configured': true,
        'status': 'ready',
        'apiBaseUrl': config.apiBaseUrl,
        'mode': config.pollingEnabled ? 'polling' : 'webhook',
        'pollingEnabled': config.pollingEnabled,
        'pollingIntervalMs': config.pollingInterval.inMilliseconds,
        'pollingTimeoutSeconds': config.pollingTimeout.inSeconds,
        'pollingBatchLimit': config.pollingBatchLimit,
        'webhookPath': config.webhookPath,
        'webhookUrl': config.resolvedWebhookUrl,
        'hasSecret': (config.webhookSecret ?? '').isNotEmpty,
        'hasChatPolicy': config.hasChatPolicy,
        'hasSenderPolicy': config.hasSenderPolicy,
        'hasApproverPolicy': config.hasApproverPolicy,
        'bot': bot.toJson(),
        'webhook': webhook.toJson(),
      };
    } catch (error) {
      return {
        'configured': true,
        'status': 'error',
        'apiBaseUrl': config.apiBaseUrl,
        'mode': config.pollingEnabled ? 'polling' : 'webhook',
        'pollingEnabled': config.pollingEnabled,
        'pollingIntervalMs': config.pollingInterval.inMilliseconds,
        'pollingTimeoutSeconds': config.pollingTimeout.inSeconds,
        'pollingBatchLimit': config.pollingBatchLimit,
        'webhookPath': config.webhookPath,
        'webhookUrl': config.resolvedWebhookUrl,
        'error': error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> setWebhook({
    String? urlOverride,
    bool dropPendingUpdates = false,
  }) async {
    _ensureConfigured();
    final targetUrl = (urlOverride?.trim().isNotEmpty ?? false)
        ? urlOverride!.trim()
        : config.resolvedWebhookUrl;
    if (targetUrl == null || targetUrl.isEmpty) {
      throw StateError('Telegram webhook URL is not configured.');
    }
    await _apiClient.setWebhook(
      url: targetUrl,
      secretToken: config.webhookSecret,
      allowedUpdates: const ['message'],
      dropPendingUpdates: dropPendingUpdates,
    );
    return statusPayload();
  }

  Future<Map<String, dynamic>> deleteWebhook({
    bool dropPendingUpdates = false,
  }) async {
    _ensureConfigured();
    await _apiClient.deleteWebhook(dropPendingUpdates: dropPendingUpdates);
    return statusPayload();
  }

  Future<void> sendReply(TelegramNormalizedUpdate update, String text) async {
    _ensureConfigured();
    await _apiClient.sendMessage(chatId: update.chatId, text: text);
  }

  Future<List<Map<String, dynamic>>> pollUpdates({int? offset}) async {
    _ensureConfigured();
    return _apiClient.getUpdates(
      offset: offset,
      limit: config.pollingBatchLimit,
      timeoutSeconds: config.pollingTimeout.inSeconds,
      allowedUpdates: const ['message'],
    );
  }

  Future<void> sendCompletionSummary(WorkOrder order) async {
    _ensureConfigured();
    final chatId = order.sourceChatId;
    if (chatId == null || chatId.isEmpty) {
      return;
    }
    final lines = <String>[
      'HNI completion report',
      '${order.id} · ${order.title}',
      'status: ${order.status.label}',
      'target: ${order.targetProduct} / ${order.targetBranch}',
      'completed stages: ${order.completedStages}/${order.stageRecords.length}',
    ];
    final latestReport = order.reports.isEmpty ? null : order.reports.last;
    if (latestReport != null && latestReport.summary.trim().isNotEmpty) {
      lines.add('summary: ${latestReport.summary}');
    }
    await _apiClient.sendMessage(chatId: chatId, text: lines.join('\n'));
  }

  bool _isSenderAllowed(TelegramNormalizedUpdate update) {
    if (!config.hasSenderPolicy) {
      return true;
    }
    if (config.allowedSenderIds.contains(update.senderId)) {
      return true;
    }
    final username = update.senderUsername;
    return username != null && config.allowedUsernames.contains(username);
  }

  bool _isApproverAllowed(TelegramNormalizedUpdate update) {
    if (config.hasApproverPolicy) {
      if (config.approverSenderIds.contains(update.senderId)) {
        return true;
      }
      final username = update.senderUsername;
      return username != null && config.approverUsernames.contains(username);
    }
    return _isSenderAllowed(update);
  }

  bool _requiresPrivilegedAccess(ParsedCommandType type) {
    return type == ParsedCommandType.approve ||
        type == ParsedCommandType.hold ||
        type == ParsedCommandType.resume;
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw StateError('Telegram integration is not configured.');
    }
  }
}

String _envOrDefine(String key, {String defaultValue = ''}) {
  return Platform.environment[key] ??
      String.fromEnvironment(key, defaultValue: defaultValue);
}

bool _boolEnv(String key, {bool defaultValue = false}) {
  final raw = _envOrDefine(key).trim().toLowerCase();
  if (raw.isEmpty) {
    return defaultValue;
  }
  return raw == '1' || raw == 'true' || raw == 'yes' || raw == 'on';
}

int _intEnv(
  String key, {
  required int defaultValue,
  int? minimum,
  int? maximum,
}) {
  final raw = _envOrDefine(key).trim();
  final parsed = int.tryParse(raw) ?? defaultValue;
  var normalized = parsed;
  if (minimum != null && normalized < minimum) {
    normalized = minimum;
  }
  if (maximum != null && normalized > maximum) {
    normalized = maximum;
  }
  return normalized;
}

String? _nullableEnv(String key) {
  final value = _envOrDefine(key).trim();
  return value.isEmpty ? null : value;
}

Set<String> _stringSetFromEnv(String key) {
  final raw = _nullableEnv(key);
  if (raw == null) {
    return <String>{};
  }
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet();
}

Set<String> _normalizedUsernames(Set<String> values) {
  return values.map(_normalizeUsername).whereType<String>().toSet();
}

String? _normalizeUsername(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed.replaceFirst('@', '').toLowerCase();
}
