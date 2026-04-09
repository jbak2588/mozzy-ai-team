import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/backend_service.dart';
import 'package:hni_auto_company_mvp/src/models.dart';
import 'package:hni_auto_company_mvp/src/telegram_integration.dart';
import 'package:shelf/shelf.dart';

void main() {
  test('telegram webhook creates order and replies to sender', () async {
    final fakeApi = FakeTelegramApiClient();
    final service = await _loadService(fakeApi: fakeApi);
    final response = await service.handler().call(
      _telegramWebhookRequest(
        '/new_order Telegram intake | backend webhook 연결 | HNI | main',
      ),
    );

    expect(response.statusCode, 200);

    final body =
        jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body['accepted'], isTrue);
    expect((body['result'] as String?) ?? '', contains('Created WO-'));

    final created = service.snapshot.orders.first;
    expect(created.sourceChannel, CommandChannel.telegram);
    expect(created.sourceChatId, '9001');
    expect(created.sourceSenderId, '42');
    expect(created.requestedBy, 'HNI CEO');
    expect(fakeApi.sentMessages.single.chatId, '9001');
    expect(fakeApi.sentMessages.single.text, contains('Created ${created.id}'));
  });

  test(
    'telegram approve command completes order and sends completion summary',
    () async {
      final fakeApi = FakeTelegramApiClient();
      final service = await _loadService(fakeApi: fakeApi);
      final handler = service.handler();

      await handler.call(
        _telegramWebhookRequest(
          '/new_order Telegram approval | 승인 후 자동 완료 | Mozzy | hyperlocal-proposal',
        ),
      );
      final created = service.snapshot.orders.first;

      final approveResponse = await handler.call(
        _telegramWebhookRequest('/approve ${created.id}'),
      );
      expect(approveResponse.statusCode, 200);

      await _waitUntil(
        () async =>
            service.snapshot.orders
                .firstWhere((item) => item.id == created.id)
                .status ==
            OrderStatus.completed,
      );

      final completed = service.snapshot.orders.firstWhere(
        (item) => item.id == created.id,
      );
      expect(completed.status, OrderStatus.completed);
      expect(
        completed.auditTrail.any(
          (entry) =>
              entry.message.contains('Telegram completion summary dispatched'),
        ),
        isTrue,
      );
      expect(fakeApi.sentMessages.length, greaterThanOrEqualTo(3));
      expect(fakeApi.sentMessages.last.text, contains('HNI completion report'));
    },
  );

  test(
    'telegram privileged command is denied for non-approver sender',
    () async {
      final fakeApi = FakeTelegramApiClient();
      final service = await _loadService(fakeApi: fakeApi);
      final handler = service.handler();

      await handler.call(
        _telegramWebhookRequest(
          '/new_order Unauthorized approve | gate 검증 | Mozzy | main',
        ),
      );
      final created = service.snapshot.orders.first;

      final response = await handler.call(
        _telegramWebhookRequest(
          '/approve ${created.id}',
          senderId: '77',
          firstName: 'Viewer',
          username: 'viewer',
        ),
      );

      expect(response.statusCode, 200);

      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['accepted'], isFalse);
      expect((body['reason'] as String?) ?? '', contains('not allowed'));

      final order = service.snapshot.orders.firstWhere(
        (item) => item.id == created.id,
      );
      expect(order.status, OrderStatus.approvalPending);
      expect(fakeApi.sentMessages.last.text, contains('not allowed'));
    },
  );

  test('telegram webhook rejects invalid secret token', () async {
    final fakeApi = FakeTelegramApiClient();
    final service = await _loadService(fakeApi: fakeApi);
    final initialLogCount = service.snapshot.commandLogs.length;
    final response = await service.handler().call(
      _telegramWebhookRequest('/status WO-999', secret: 'wrong-secret'),
    );

    expect(response.statusCode, 401);
    expect(service.snapshot.commandLogs.length, initialLogCount);
    expect(fakeApi.sentMessages, isEmpty);
  });

  test('telegram poll-once processes queued updates without webhook', () async {
    final fakeApi = FakeTelegramApiClient()
      ..queuedUpdates.add(
        _telegramUpdatePayload(
          '/new_order Polling intake | webhook 없이 명령 수신 | HNI | main',
        ),
      );
    final service = await _loadService(fakeApi: fakeApi);

    final response = await service.handler().call(
      Request(
        'POST',
        Uri.parse('http://127.0.0.1/api/v1/integrations/telegram/poll-once'),
      ),
    );

    expect(response.statusCode, 200);

    final body =
        jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body['processed'], 1);
    expect(
      ((body['telegram'] as Map<String, dynamic>)['pollingCursor'] as num?)
          ?.toInt(),
      1002,
    );

    final created = service.snapshot.orders.first;
    expect(created.sourceChannel, CommandChannel.telegram);
    expect(created.sourceChatId, '9001');
    expect(created.sourceSenderId, '42');
    expect(fakeApi.sentMessages.single.text, contains('Created ${created.id}'));
    expect(service.snapshot.telegramPollingOffset, 1002);
  });
}

Future<AutoCompanyBackendService> _loadService({
  required FakeTelegramApiClient fakeApi,
}) async {
  final repository = MemoryBackendSnapshotRepository();
  await repository.save(AppSnapshot(orders: [], commandLogs: []));
  return AutoCompanyBackendService.load(
    repository,
    stageDelay: Duration.zero,
    telegramIntegration: TelegramIntegration(
      config: const TelegramIntegrationConfig(
        botToken: 'telegram-token',
        apiBaseUrl: 'https://api.telegram.org',
        webhookPath: '/api/v1/integrations/telegram/webhook',
        webhookSecret: 'super-secret',
        allowedSenderIds: {'42'},
        approverSenderIds: {'42'},
      ),
      apiClient: fakeApi,
    ),
  );
}

Request _telegramWebhookRequest(
  String text, {
  String secret = 'super-secret',
  String senderId = '42',
  String firstName = 'HNI CEO',
  String username = 'hni_ceo',
}) {
  return Request(
    'POST',
    Uri.parse('http://127.0.0.1/api/v1/integrations/telegram/webhook'),
    headers:
        const {
          'content-type': 'application/json',
          'x-telegram-bot-api-secret-token': 'super-secret',
        }.map(
          (key, value) => MapEntry(
            key,
            key == 'x-telegram-bot-api-secret-token' ? secret : value,
          ),
        ),
    body: jsonEncode({
      ..._telegramUpdatePayload(
        text,
        senderId: senderId,
        firstName: firstName,
        username: username,
      ),
    }),
  );
}

Map<String, dynamic> _telegramUpdatePayload(
  String text, {
  String senderId = '42',
  String firstName = 'HNI CEO',
  String username = 'hni_ceo',
  int updateId = 1001,
}) {
  return {
    'update_id': updateId,
    'message': {
      'message_id': 9002,
      'date': 1710000000,
      'text': text,
      'from': {
        'id': int.parse(senderId),
        'is_bot': false,
        'first_name': firstName,
        'username': username,
      },
      'chat': {
        'id': 9001,
        'type': 'private',
        'first_name': firstName,
        'username': username,
      },
    },
  };
}

Future<void> _waitUntil(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Condition was not met before timeout.');
}

class FakeTelegramApiClient implements TelegramApiClient {
  final List<FakeTelegramMessage> sentMessages = [];
  final List<Map<String, dynamic>> queuedUpdates = [];
  String webhookUrl = '';
  bool dropPendingUpdates = false;

  @override
  Future<void> deleteWebhook({bool dropPendingUpdates = false}) async {
    webhookUrl = '';
    this.dropPendingUpdates = dropPendingUpdates;
  }

  @override
  Future<TelegramBotProfile> getMe() async {
    return const TelegramBotProfile(
      id: 'bot-1',
      firstName: 'HNI Bot',
      username: 'hni_bot',
    );
  }

  @override
  Future<TelegramWebhookStatus> getWebhookInfo() async {
    return TelegramWebhookStatus(
      url: webhookUrl,
      pendingUpdateCount: 0,
      hasCustomCertificate: false,
      allowedUpdates: const ['message'],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUpdates({
    int? offset,
    int limit = 10,
    int timeoutSeconds = 0,
    List<String> allowedUpdates = const ['message'],
  }) async {
    if (offset != null) {
      queuedUpdates.removeWhere((item) {
        final updateId = (item['update_id'] as num?)?.toInt() ?? 0;
        return updateId < offset;
      });
    }
    return queuedUpdates
        .take(limit)
        .map((item) => jsonDecode(jsonEncode(item)) as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    sentMessages.add(FakeTelegramMessage(chatId: chatId, text: text));
  }

  @override
  Future<void> setWebhook({
    required String url,
    String? secretToken,
    List<String> allowedUpdates = const ['message'],
    bool dropPendingUpdates = false,
  }) async {
    webhookUrl = url;
    this.dropPendingUpdates = dropPendingUpdates;
  }
}

class FakeTelegramMessage {
  const FakeTelegramMessage({required this.chatId, required this.text});

  final String chatId;
  final String text;
}
