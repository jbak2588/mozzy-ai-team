# HNI Telegram v1.2 Scope

## Purpose

이 문서는
HNI auto-company `v1.1` backend 위에
Telegram command channel을
실제로 연결하는 `v1.2` 구현 범위를 정리한다.

이번 범위는
**backend-ready live integration**까지다.
실제 public webhook 개통과
production 운영 전환은 포함하지 않는다.
추가로 local/non-production 검증을 위해
polling mode를 함께 지원한다.

## Objective

- Telegram inbound message를
  backend work-order command로 변환한다.
- Telegram sender/chat policy를
  backend에서 강제한다.
- command 결과와 completion summary를
  Telegram reply로 되돌린다.
- public webhook이 없을 때는
  polling mode로 같은 intake 경로를 재사용한다.
- desktop client는
  기존 polling dashboard 구조를 유지한다.

## Implemented Components

- `lib/src/telegram_integration.dart`
  - env 기반 Telegram config
  - Bot API client
  - webhook status helper
  - polling helper
  - update normalizer
  - sender policy evaluator
  - outbound reply / completion summary helper
- `lib/src/backend_service.dart`
  - `GET /api/v1/integrations/telegram/status`
  - `POST /api/v1/integrations/telegram/set-webhook`
  - `POST /api/v1/integrations/telegram/delete-webhook`
  - `POST /api/v1/integrations/telegram/poll-once`
  - `POST /api/v1/integrations/telegram/webhook`
- `bin/server.dart`
  - env 기반 Telegram integration bootstrap
  - polling bootstrap

## Runtime Contract

### Inbound

1. Telegram이 webhook route로 `message.text` update를 보낸다.
2. backend는
   `X-Telegram-Bot-Api-Secret-Token`을 검증한다.
3. update를
   `chatId`, `senderId`, `senderLabel`, `senderUsername`, `text`로 정규화한다.
4. sender/chat policy를 검사한다.
5. 허용된 command만
   기존 `submitCommand()` 경로로 보낸다.
6. command 결과를
   Telegram reply와 dashboard command log에 함께 기록한다.

### Inbound: polling mode

1. backend가 Telegram `getUpdates`를 주기적으로 호출한다.
2. update를
   `chatId`, `senderId`, `senderLabel`, `senderUsername`, `text`로 정규화한다.
3. sender/chat policy를 검사한다.
4. 허용된 command만
   기존 `submitCommand()` 경로로 보낸다.
5. 처리된 `update_id` 다음 값은
   polling cursor로 저장해 중복 수신을 줄인다.

### Outbound

- command reply:
  `/new_order`, `/approve`, `/hold`, `/resume`, `/status`, `/help`
  결과를 바로 Telegram으로 회신
- completion summary:
  Telegram에서 생성된 work order가 완료되면
  같은 chat으로 completion summary를 발송

## Environment Variables

- `HNI_TELEGRAM_BOT_TOKEN`
- `HNI_TELEGRAM_API_BASE_URL`
  - default: `https://api.telegram.org`
- `HNI_TELEGRAM_WEBHOOK_BASE_URL`
  - `set-webhook` helper가 route URL을 만들 때 사용
- `HNI_TELEGRAM_WEBHOOK_SECRET`
  - Telegram `secret_token`과 같은 값
- `HNI_TELEGRAM_ALLOWED_CHAT_IDS`
  - optional, comma-separated
- `HNI_TELEGRAM_ALLOWED_SENDER_IDS`
  - optional, comma-separated
- `HNI_TELEGRAM_ALLOWED_USERNAMES`
  - optional, comma-separated
- `HNI_TELEGRAM_APPROVER_SENDER_IDS`
  - optional, comma-separated
- `HNI_TELEGRAM_APPROVER_USERNAMES`
  - optional, comma-separated
- `HNI_TELEGRAM_POLLING_ENABLED`
  - default: `false`
- `HNI_TELEGRAM_POLLING_INTERVAL_MS`
  - default: `1500`
- `HNI_TELEGRAM_POLLING_TIMEOUT_SECONDS`
  - default: `0`
- `HNI_TELEGRAM_POLLING_BATCH_LIMIT`
  - default: `10`

## Sender Policy

- `status`, `help`, `new_order`는
  일반 command 권한으로 처리한다.
- `approve`, `hold`, `resume`는
  privileged command로 처리한다.
- approver policy가 비어 있으면
  sender policy를 그대로 privileged 기준으로 재사용한다.
- allowlist가 비어 있으면
  비프로덕션 기본값으로 모두 허용한다.

## API Endpoints

### `GET /api/v1/integrations/telegram/status`

- bot token 설정 여부
- mode (`webhook` or `polling`)
- webhook path / webhook URL
- sender policy 적용 여부
- Telegram `getMe` / `getWebhookInfo` 결과
- polling enabled / active / cursor / last error

### `POST /api/v1/integrations/telegram/set-webhook`

Body:

```json
{
  "url": "https://example.com/api/v1/integrations/telegram/webhook",
  "dropPendingUpdates": false
}
```

`url`이 없으면
`HNI_TELEGRAM_WEBHOOK_BASE_URL + webhookPath`를 사용한다.

### `POST /api/v1/integrations/telegram/delete-webhook`

Body:

```json
{
  "dropPendingUpdates": false
}
```

### `POST /api/v1/integrations/telegram/poll-once`

- queued Telegram update를 한 번 읽어 처리
- public webhook 없이 local/non-production 검증할 때 사용
- response에 `processed` count와 `pollingCursor`가 포함됨

### `POST /api/v1/integrations/telegram/webhook`

- Telegram webhook ingress
- 지원 범위는 `message.text` command
- secret mismatch는 `401`
- sender/chat policy denial은 `200 + accepted:false`

## Verification Target

- fake Telegram client 기준으로
  `/new_order` -> reply 성공
- privileged sender 기준으로
  `/approve` -> auto-run 완료 + completion summary 성공
- invalid secret 기준으로
  webhook request 거부
- queued update 기준으로
  `poll-once` -> order 생성 + cursor 전진 성공
- `flutter analyze`, `flutter test` 통과

## Out of Scope

- 실제 public HTTPS endpoint 개통
- Telegram BotFather 운영 절차 문서화
- production-grade auth/session/user management
- WhatsApp live command 구현
- desktop dashboard 내 Telegram settings UI
- polling과 webhook의 production-grade failover orchestration

## References

- Telegram Bot API:
  [Telegram Bot API](https://core.telegram.org/bots/api)
