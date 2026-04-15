# TELEGRAM_PUBLIC_WEBHOOK_DEPLOY.md

## Purpose

이 문서는 HNI auto-company backend를
`ai.humantric.net` 같은 공개 도메인으로 운영할 때 필요한
Telegram webhook 배포 준비 절차를 정리한다.

현재 범위는 배포 아티팩트와 운영 가이드 준비까지다.
실제 DNS 연결, TLS 발급, 서버 반영, public webhook 등록은
실서버에서 별도로 수행한다.

권장 도메인 분리 원칙은
[HNI_AI_SUBDOMAIN_ARCHITECTURE.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_SUBDOMAIN_ARCHITECTURE.md)
를 따른다.

## Deployment Topology

- public domain example: `ai.humantric.net`
- public traffic: `443/tcp`
- reverse proxy: Nginx
- local backend: `127.0.0.1:8787`
- transport: HTTPS only

핵심 원칙:

- Telegram은 public HTTPS endpoint로만 webhook을 호출한다.
- backend는 `127.0.0.1:8787`에만 바인딩해
  reverse proxy 뒤에 숨긴다.
- tracked 파일에는 token, secret, sender/chat id를 넣지 않는다.
- public webhook profile에서는
  `HNI_TELEGRAM_POLLING_ENABLED=false`를 유지한다.

## Files

- nginx example:
  [deploy/nginx/ai.humantric.net.conf](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/deploy/nginx/ai.humantric.net.conf)
- systemd example:
  [deploy/systemd/hni-auto-company-backend.service](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/deploy/systemd/hni-auto-company-backend.service)
- env example:
  [deploy/env/telegram_public.example.env](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/deploy/env/telegram_public.example.env)
- helper scripts:
  [deploy/scripts/check_telegram_status.sh](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/deploy/scripts/check_telegram_status.sh)
  [deploy/scripts/set_telegram_webhook.sh](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/deploy/scripts/set_telegram_webhook.sh)
  [deploy/scripts/delete_telegram_webhook.sh](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/deploy/scripts/delete_telegram_webhook.sh)

## 1. DNS Setup

1. `ai.humantric.net` A 또는 AAAA 레코드를
   reverse proxy 서버 공인 IP로 연결한다.
2. DNS 전파 후
   서버에서 `ai.humantric.net`이
   해당 공인 IP로 해석되는지 확인한다.

## 2. TLS Certificate

1. `ai.humantric.net`용 유효한 TLS 인증서를 발급한다.
2. nginx 예제 파일의 아래 경로를
   실제 인증서 경로로 교체한다.

   - `ssl_certificate`
   - `ssl_certificate_key`

3. self-signed 인증서는 Telegram webhook에 쓰지 않는다.

## 3. Reverse Proxy Setup

1. nginx 예제를 서버 설정 위치에 복사한다.
2. `server_name`, certificate path를
   실제 값으로 교체한다.
3. public `80`은 `443`으로 redirect한다.
4. public `443`은 TLS를 종료한 뒤
   local backend `127.0.0.1:8787`로 프록시한다.
5. backend 포트 `8787`은
   외부에 직접 열지 않는 것을 권장한다.

## 4. Env File Placement

1. tracked example env를 서버용 실제 경로로 복사한다.

   ```bash
   sudo mkdir -p /etc/hni_auto_company
   SOURCE_DIR=/opt/hni_auto_company/hni_auto_company_mvp/deploy/env
   sudo cp \
     "${SOURCE_DIR}/telegram_public.example.env" \
     /etc/hni_auto_company/telegram_public.env
   ```

2. 아래 placeholder를
   실운영 값으로 교체한다.

   - `HNI_TELEGRAM_BOT_TOKEN`
   - `HNI_TELEGRAM_WEBHOOK_BASE_URL`
   - `HNI_TELEGRAM_WEBHOOK_SECRET`
   - `HNI_TELEGRAM_ALLOWED_CHAT_IDS`
   - `HNI_TELEGRAM_ALLOWED_SENDER_IDS`
   - `HNI_TELEGRAM_ALLOWED_USERNAMES`
   - `HNI_TELEGRAM_APPROVER_SENDER_IDS`
   - `HNI_TELEGRAM_APPROVER_USERNAMES`

3. public webhook profile에서는
   `HNI_TELEGRAM_POLLING_ENABLED=false`를 유지한다.

## 5. systemd Service Startup

1. 전용 non-root 서비스 계정을 만든다.
2. systemd 예제를
   `/etc/systemd/system/hni-auto-company-backend.service`로 복사한다.
3. 아래 값을 실제 서버 경로에 맞게 교체한다.

   - `User`
   - `Group`
   - `WorkingDirectory`
   - `EnvironmentFile`

4. 서비스 시작:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now hni-auto-company-backend.service
   sudo systemctl status hni-auto-company-backend.service
   ```

## 6. Webhook Registration Flow

1. backend와 reverse proxy가 모두 기동된 뒤
   local helper script로 상태를 먼저 확인한다.

   ```bash
   ./deploy/scripts/check_telegram_status.sh
   ```

2. `configured: true`, `status: "ready"`를 확인한다.
3. webhook를 등록한다.

   ```bash
   ./deploy/scripts/set_telegram_webhook.sh
   ```

4. 필요 시 webhook를 비울 때는 아래를 사용한다.

   ```bash
   ./deploy/scripts/delete_telegram_webhook.sh
   ```

## 7. Success Verification

아래 세 가지가 함께 확인되면 성공으로 본다.

1. Telegram bot reply
   - allowlist에 포함된 계정으로
     `@hni_mozzy_bot`에 `/help` 또는 `/status WO-101`을 보낸다.
   - Telegram chat에 bot reply가 돌아와야 한다.

2. backend status endpoint
   - `GET /api/v1/integrations/telegram/status`
   - 기대값:
     - `configured: true`
     - `status: "ready"`
     - `mode: "webhook"`
     - `webhook.url` 또는 `webhookUrl`이 비어 있지 않음

3. dashboard command log
   - desktop app을 backend-connected mode로 실행한다.
   - `Channels` 화면의 command log에
     같은 Telegram 입력과 결과가 남아야 한다.

## 8. Operational Warning

- polling mode와 public webhook은 동시에 활성화하지 않는다.
- public webhook 운영 중에는
  `HNI_TELEGRAM_POLLING_ENABLED=false`여야 한다.
- helper script는 local backend endpoint
  `127.0.0.1:8787`을 전제로 한다.
  remote 공개 endpoint에 직접 secret을 실어 보내지 않는다.
