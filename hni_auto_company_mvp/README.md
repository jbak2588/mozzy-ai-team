# HNI Auto-Company MVP

## Purpose

이 앱은 HNI auto-company의 최소 실행 MVP다.

- HNI CEO 또는 운영자가 work order를 만든다.
- plan approval 전에는 실행이 시작되지 않는다.
- approval 이후에는 `분석 -> 계획 -> 실행 -> 평가 -> 수정 -> 완료 보고`
  흐름을 추가 승인 요청 없이 끝까지 자동 실행한다.
- 결과는 dashboard, reports, approvals, audit timeline에서 확인한다.

## Current MVP Scope

- Flutter Windows/macOS 데스크톱 앱
- 로컬 JSON persistence
- work order 생성/보류/재개
- plan approval / risk gate approval
- auto-run stage engine
- report timeline
- Telegram/WhatsApp 형식 local command simulator

## v1.1 Backend-Connected Mode

- 로컬 HTTP backend가 authoritative state를 가진다.
- desktop client는 `API_BASE_URL`이 있을 때
  backend-connected mode로 동작한다.
- approval 이후 stage auto-run은
  backend에서 진행되고 client는 polling으로 따라간다.

## Local Run

```bash
cd hni_auto_company_mvp
flutter pub get
flutter run -d macos
```

Windows에서는 `flutter run -d windows`를 사용한다.

## Backend Run

```bash
cd hni_auto_company_mvp
dart run bin/server.dart
```

backend-connected mode로 실행하려면:

```bash
cd hni_auto_company_mvp
flutter run -d macos --dart-define=API_BASE_URL=http://127.0.0.1:8787
```

## Telegram Live Mode

Telegram 실연동은 backend에서만 처리한다.
desktop client는 기존과 같이 `API_BASE_URL`로 연결한다.
현재 target bot handle은 `@hni_mozzy_bot`다.
이 값은 bot 식별자이며
sender allowlist username과는 다르다.

예시 환경 변수:

```bash
export HNI_TELEGRAM_BOT_TOKEN=123456:telegram-token
export HNI_TELEGRAM_WEBHOOK_SECRET=hni-telegram-secret
export HNI_TELEGRAM_WEBHOOK_BASE_URL=https://example.com
export HNI_TELEGRAM_ALLOWED_SENDER_IDS=123456789
export HNI_TELEGRAM_APPROVER_SENDER_IDS=123456789
```

status 확인:

```bash
curl http://127.0.0.1:8787/api/v1/integrations/telegram/status
```

webhook helper:

```bash
curl -X POST \
  http://127.0.0.1:8787/api/v1/integrations/telegram/set-webhook \
  -H 'content-type: application/json' \
  -d '{"dropPendingUpdates":false}'
```

Telegram webhook route:

- `POST /api/v1/integrations/telegram/webhook`
- 지원 command:
  `/new_order`, `/approve`, `/hold`, `/resume`, `/status`, `/help`

## Telegram Polling Mode

public webhook 없이
로컬 backend에서 direct message를 intake하려면
polling mode를 쓴다.

예시 환경 변수:

```bash
export HNI_TELEGRAM_BOT_TOKEN=123456:telegram-token
export HNI_TELEGRAM_POLLING_ENABLED=true
export HNI_TELEGRAM_POLLING_INTERVAL_MS=1500
export HNI_TELEGRAM_ALLOWED_SENDER_IDS=123456789
export HNI_TELEGRAM_APPROVER_SENDER_IDS=123456789
export HNI_TELEGRAM_ALLOWED_CHAT_IDS=123456789
```

중요:

- polling mode와 public webhook은 동시에 운영하지 않는다.
- 기존 webhook이 살아 있으면
  먼저 `delete-webhook` helper로 비운 뒤 polling을 시작한다.

manual helper:

```bash
curl -X POST \
  http://127.0.0.1:8787/api/v1/integrations/telegram/poll-once
```

status에서 아래를 함께 본다.

- `mode: "polling"`
- `pollingEnabled: true`
- `pollingActive: true`
- `pollingCursor`

## Telegram Connection Check

실제 Telegram이 연결됐는지 확인할 때는
아래 순서로 본다.

1. backend status endpoint가 응답해야 한다.

   ```bash
   curl http://127.0.0.1:8787/api/v1/integrations/telegram/status
   ```

   기대값:
   - `configured: true`
   - `status: "ready"`
   - webhook mode면 `webhook.url` 또는 `webhookUrl`이 비어 있지 않음
   - polling mode면 `pollingEnabled: true`, `pollingActive: true`
2. webhook mode에서 webhook URL이 비어 있으면
   `set-webhook` helper를 먼저 호출한다.
3. Telegram bot chat에서
   allowlist에 포함된 sender로 `/help` 또는 `/status WO-101`을 보낸다.
4. 아래 둘이 동시에 확인되면 연결 성공으로 본다.
   - Telegram 안에서 bot reply가 돌아온다
   - dashboard `Channels` 화면 command log에 같은 입력/결과가 남는다

주의:

- Telegram cloud webhook은 local `127.0.0.1`로 직접 들어오지 않는다.
- 실제 inbound를 보려면
  `HNI_TELEGRAM_WEBHOOK_BASE_URL`에
  Telegram이 접근 가능한 HTTPS URL 또는 tunnel URL이 필요하다.

## Telegram Account Binding

개인 Telegram 계정은
전화번호 표기(`+62 ...`)만으로는 직접 연결되지 않는다.
현재 HNI backend는
`username`, `sender_id`, `chat_id`로
권한을 판단한다.

`@hni_mozzy_bot`에 계정을 연결하는 순서:

1. Telegram에서 `https://t.me/hni_mozzy_bot`를 열고
   먼저 `/start` 또는 `/help`를 보낸다.
2. 계정에 Telegram `username`이 있으면
   아래처럼 username allowlist를 먼저 쓰는 것이 가장 단순하다.

   ```bash
   export HNI_TELEGRAM_ALLOWED_USERNAMES=your_username
   export HNI_TELEGRAM_APPROVER_USERNAMES=your_username
   ```

3. username이 없으면
   첫 메시지 이후 `getUpdates` 또는 ingress log에서
   numeric `sender_id`를 확인한 뒤
   sender allowlist를 쓴다.

   ```bash
   export HNI_TELEGRAM_ALLOWED_SENDER_IDS=123456789
   export HNI_TELEGRAM_APPROVER_SENDER_IDS=123456789
   ```

4. 특정 개인 chat만 허용하고 싶으면
   `chat_id`까지 함께 고정할 수 있다.

   ```bash
   export HNI_TELEGRAM_ALLOWED_CHAT_IDS=123456789
   ```

5. backend를 다시 실행하고
   status endpoint가 `configured: true`,
   `status: "ready"`인지 확인한다.
6. public HTTPS webhook이 아직 없으면
   Bot API 연결은 성공해도
   Telegram cloud inbound는 webhook 기준 backend로 들어오지 않는다.
   이 경우 polling mode를 켜면
   public webhook 없이도 non-production roundtrip 검증이 가능하다.

## Public Webhook Requirements

public webhook 방식으로 가려면
아래가 필요하다.

1. Telegram이 접근 가능한 public HTTPS URL
2. 유효한 TLS 인증서
3. `HNI_TELEGRAM_WEBHOOK_BASE_URL`
4. `HNI_TELEGRAM_WEBHOOK_SECRET`
5. sender/chat allowlist 값
6. backend가 외부에서 도달 가능한 host/port 또는 reverse proxy
7. `set-webhook` helper 호출
8. polling mode 비활성화

## Verification

```bash
cd hni_auto_company_mvp
flutter analyze
flutter test
```

## Supported Commands

- `/new_order title | objective | product | branch`
- `/approve WO-101`
- `/hold WO-101 | note`
- `/resume WO-101`
- `/status WO-101`
- `/help`

## Persistence

앱 상태는 `Application Support` 경로 아래의
`hni_auto_company_mvp_state.json`에 저장된다.

## Not Included Yet

- 실제 public webhook 개통
- 실제 WhatsApp Cloud API
- multi-user auth
- production-hosted backend
- real AI inference
- GitHub live sync
