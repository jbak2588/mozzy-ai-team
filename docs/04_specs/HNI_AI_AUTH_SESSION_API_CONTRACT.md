# HNI AI Auth Session API Contract

## Purpose

이 문서는
future `ai.humantric.net` web dashboard의
auth/session API contract를 정의한다.

핵심 목적은 아래다.

- browser auth route와 JSON session endpoint를 분리한다
- frontend bootstrap과 route gate가 읽을 표준 session payload를 고정한다
- cookie, CSRF, error 응답 형식을 same-origin 기준으로 통일한다

## Contract Scope

이번 문서는 실제 provider를 선택하지 않는다.
대신 아래를 고정한다.

- `/auth/*` browser flow
- `/api/v1/session*` JSON contract
- session cookie shape
- CSRF rule
- error envelope

세부 OIDC 흐름은
[HNI_AI_AUTH_OIDC_DESIGN.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_OIDC_DESIGN.md),
provider별 redirect 순서는
[HNI_AI_AUTH_PROVIDER_INTEGRATION_SEQUENCES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_PROVIDER_INTEGRATION_SEQUENCES.md)
를 따른다.

## Boundary Rule

경계는 아래처럼 고정한다.

- browser navigation / redirect:
  `/auth/*`
- JSON session discovery / termination:
  `/api/v1/session`,
  `/api/v1/session/logout`
- business API:
  `/api/v1/**`

즉 로그인 시작과 callback은
브라우저 redirect flow이고,
로그인 이후 상태 읽기는
JSON session endpoint가 담당한다.

## Canonical Browser Auth Routes

### `GET /auth/login`

역할:

- provider authorize redirect 시작
- optional recent-auth 재시도 시작

권장 query:

- `returnTo`
- `prompt`
- `reauth`

예시:

- `/auth/login?returnTo=/dashboard/orders`
- `/auth/login?returnTo=/dashboard/approvals&prompt=login&reauth=1`

동작:

- server가 state, nonce, PKCE verifier/challenge를 준비
- provider authorize endpoint로 `302` redirect

### `GET /auth/callback`

역할:

- provider code/state 수신
- backend code exchange
- claim normalization
- session cookie 발급

query input:

- `code`
- `state`
- provider-specific error fields

성공 시:

- session cookie 설정
- `returnTo` 또는 `/dashboard/home`로 redirect

실패 시:

- `/auth/login` 또는 `/auth/forbidden`로 redirect
- optional error code query 포함

### `GET /auth/logout`

역할:

- browser convenience logout route
- local session 정리 후 provider logout으로 이동하거나
  local signed-out route로 복귀

주의:

- JSON API 기준의 canonical logout mutation은
  `POST /api/v1/session/logout`
- `/auth/logout`는 navigation alias로 본다

### `GET /auth/session-expired`

역할:

- expired session recovery 화면

### `GET /auth/forbidden`

역할:

- role 부족 또는 policy 차단 화면

## Canonical JSON Session API

### `GET /api/v1/session`

역할:

- current browser session bootstrap
- route gate 초기 상태 로드
- capability rendering 기준 제공
- CSRF token 제공

gate:

- same-origin session probe
- 비로그인 상태에서도 호출 가능

headers:

- `Cache-Control: no-store`
- `Vary: Cookie`

success shape:

```json
{
  "session": {
    "authenticated": true,
    "principal": {
      "userId": "usr_123",
      "email": "operator@humantric.net",
      "name": "HNI Operator",
      "pictureUrl": "https://example.com/avatar.png",
      "role": "Approver",
      "provider": "entra",
      "providerSubjectId": "provider-subject-id"
    },
    "capabilities": {
      "canAccessStrategy": true,
      "canApprove": true,
      "canManageTelegramOps": false,
      "canExportAudit": false
    },
    "authTime": "2026-04-10T10:00:00Z",
    "issuedAt": "2026-04-10T10:00:00Z",
    "expiresAt": "2026-04-10T18:00:00Z",
    "recentAuthExpiresAt": "2026-04-10T10:15:00Z",
    "csrfToken": "csrf-token-value"
  }
}
```

anonymous shape:

```json
{
  "session": {
    "authenticated": false,
    "principal": null,
    "capabilities": {},
    "authTime": null,
    "issuedAt": null,
    "expiresAt": null,
    "recentAuthExpiresAt": null,
    "csrfToken": null
  }
}
```

### `POST /api/v1/session/logout`

역할:

- local HNI session 종료
- optional provider logout redirect 대상 계산

headers:

- `X-HNI-CSRF-Token`

body:

```json
{
  "returnTo": "/auth/login"
}
```

### `POST /api/v1/session/bootstrap`

역할:

- non-production bootstrap login
- provider 미연동 단계의 same-origin shell 검증

body:

```json
{
  "returnTo": "/dashboard/home"
}
```

success shape:

```json
{
  "session": {
    "authenticated": true,
    "principal": {
      "userId": "bootstrap-admin",
      "email": "admin@humantric.net",
      "name": "HNI Bootstrap Admin",
      "pictureUrl": null,
      "role": "Admin",
      "provider": "bootstrap",
      "providerSubjectId": "bootstrap-admin"
    },
    "capabilities": {
      "canAccessStrategy": true,
      "canApprove": true,
      "canManageTelegramOps": true,
      "canExportAudit": true
    },
    "authTime": "2026-04-10T10:00:00Z",
    "issuedAt": "2026-04-10T10:00:00Z",
    "expiresAt": "2026-04-10T18:00:00Z",
    "recentAuthExpiresAt": "2026-04-10T10:15:00Z",
    "csrfToken": "csrf-token-value"
  },
  "redirectTo": "/dashboard/home"
}
```

주의:

- 이 endpoint는 provider 미연동 단계의 bootstrap helper다.
- production OIDC 전환 후에는 provider redirect route로 대체한다.
- tracked example과 README에는 placeholder만 남기고,
  실제 principal 값은 server env에서만 주입한다.

success shape:

```json
{
  "session": {
    "authenticated": false,
    "principal": null,
    "capabilities": {},
    "authTime": null,
    "issuedAt": null,
    "expiresAt": null,
    "recentAuthExpiresAt": null,
    "csrfToken": null
  },
  "redirectTo": "/auth/login"
}
```

## Cookie Contract

세션 cookie는
최소한 아래 속성을 가져야 한다.

- name:
  `hni_session`
- `HttpOnly`
- `Secure`
- `SameSite=Lax`
- `Path=/`

운영 원칙:

- browser local storage에 access token을 저장하지 않는다
- provider token은 backend code exchange 이후
  server-side에서만 다룬다
- browser는 session cookie만 보유한다

## CSRF Contract

same-origin session 기반이므로
mutating request에는 CSRF 보호를 요구한다.

규칙:

- `GET /api/v1/session`이 현재 `csrfToken`을 반환
- frontend는 이 값을 memory state에만 보관
- `POST`, `PUT`, `PATCH`, `DELETE` 요청에는
  `X-HNI-CSRF-Token` 헤더를 보낸다
- token mismatch면 request를 거부한다

대상 예:

- `/api/v1/session/logout`
- `/api/v1/orders`
- `/api/v1/orders/:orderId/approvals/:approvalId/approve`
- `/api/v1/orders/:orderId/hold`
- `/api/v1/orders/:orderId/resume`
- `/api/v1/commands`
- protected ops endpoints

## Error Contract

모든 auth/session 관련 error는
아래 envelope를 따른다.

```json
{
  "error": {
    "code": "session_expired",
    "message": "Session has expired.",
    "requestId": "req_123",
    "redirectTo": "/auth/session-expired",
    "reauthUrl": "/auth/login?returnTo=/dashboard/approvals&prompt=login&reauth=1"
  }
}
```

## Recommended Status Codes

- `200`
  - session probe success
  - logout success
- `400`
  - callback validation failure
  - malformed payload
- `401`
  - unauthenticated
  - session expired
- `403`
  - forbidden role
  - invalid CSRF
- `428`
  - recent auth required
- `502`
  - upstream provider failure

## Canonical Error Codes

- `unauthenticated`
- `session_expired`
- `forbidden`
- `recent_auth_required`
- `invalid_csrf`
- `callback_validation_failed`
- `provider_exchange_failed`
- `provider_logout_failed`

## Session-to-Route Contract

### Route Gate Input

frontend route gate는
`GET /api/v1/session`의 아래 필드만 신뢰한다.

- `session.authenticated`
- `session.principal.role`
- `session.capabilities`
- `session.expiresAt`
- `session.recentAuthExpiresAt`

### Gate Mapping

- `authenticated == false`
  -> `/auth/login`
- role 부족
  -> `/auth/forbidden`
- recent auth 부족
  -> `reauthUrl` 사용 후 재인증

## Capability Model

첫 계약 버전의 권장 capability key:

- `canAccessStrategy`
- `canApprove`
- `canManageTelegramOps`
- `canExportAudit`
- `canViewMozzyBoard`

원칙:

- role은 coarse gate
- capability는 UI action visibility와
  fine-grained control에 사용

## Relationship to Existing Backend Style

현재 desktop/backend MVP는
`/api/v1/snapshot`과
`{"snapshot": ...}` 응답을 기준으로 한다.

future web auth/session contract는
그와 병행되는 별도 계약으로 본다.

- business domain state:
  `snapshot`
- auth/session state:
  `session`
- auth/session failure:
  `error`

즉 future web dashboard는
bootstrap 시
`/api/v1/session`과
도메인 data endpoint를 함께 읽는 구조를 권장한다.

## Recommended Implementation Order

1. `GET /api/v1/session`
2. `POST /api/v1/session/logout`
3. auth callback success/failure redirect handling
4. route gate integration
5. recent-auth / step-up error handling
6. protected ops CSRF verification

## Current Implemented Enforcement Slice

현재 구현은 production-grade 전면 enforcement가 아니라
selected business API에 대한 1차 enforcement다.

same-origin bootstrap 기본 동작은
anonymous + explicit login-first이며,
`HNI_AUTH_BOOTSTRAP_DEFAULT_AUTHENTICATED`
기본값은 `false`다.
즉 remote web shell은
비로그인 상태에서 빈 shell로 먼저 기동하고,
`POST /api/v1/session/bootstrap` 성공 후
route gate와 remote snapshot을 다시 연결한다.
backend browser auth route도
1차로 구현되어 있으며,
현재 adapter mode는
`bootstrap`과 `mock_oidc`다.

적용 대상:

- `GET /api/v1/snapshot`
  - `Operator+`
- `POST /api/v1/orders`
  - `Operator+`
  - `X-HNI-CSRF-Token` 필요
- `POST /api/v1/orders/:orderId/approvals/:approvalId/approve`
  - `Approver+`
  - `X-HNI-CSRF-Token` 필요
- `POST /api/v1/orders/:orderId/hold`
  - `Approver+`
  - `X-HNI-CSRF-Token` 필요
- `POST /api/v1/orders/:orderId/resume`
  - `Approver+`
  - `X-HNI-CSRF-Token` 필요
- `GET /api/v1/orders/:orderId/agent-graph`
  - `Operator+`
- `POST /api/v1/orders/:orderId/agent-graph/assign`
  - `Lead+`
  - `X-HNI-CSRF-Token` 필요
- `POST /api/v1/orders/:orderId/agent-graph/dispatch`
  - `Lead+`
  - `X-HNI-CSRF-Token` 필요
- `POST /api/v1/commands`
  - `Operator+`
  - `X-HNI-CSRF-Token` 필요
- `GET /api/v1/integrations/telegram/status`
  - `Admin+`
- `POST /api/v1/integrations/telegram/set-webhook`
  - `Admin+`
  - `X-HNI-CSRF-Token` 필요
- `POST /api/v1/integrations/telegram/delete-webhook`
  - `Admin+`
  - `X-HNI-CSRF-Token` 필요
- `POST /api/v1/integrations/telegram/poll-once`
  - `Admin+`
  - `X-HNI-CSRF-Token` 필요

예외:

- `POST /api/v1/integrations/telegram/webhook`
  - machine ingress route로 유지
  - human session cookie / CSRF gate를 적용하지 않음

## Official References

- OAuth 2.0:
  [datatracker.ietf.org/doc/html/rfc6749](https://datatracker.ietf.org/doc/html/rfc6749)
- PKCE:
  [datatracker.ietf.org/doc/html/rfc7636](https://datatracker.ietf.org/doc/html/rfc7636)
- OpenID RP-Initiated Logout:
  [openid.net/specs/openid-connect-rpinitiated-1_0.html](https://openid.net/specs/openid-connect-rpinitiated-1_0.html)
- HTTP cookie state management:
  [ietf.org/rfc/rfc6265.txt.pdf](https://www.ietf.org/rfc/rfc6265.txt.pdf)
