# HNI AI Web Dashboard Routes

## Purpose

이 문서는 `ai.humantric.net` 아래에
future web dashboard를 붙일 때의
route 구조를 정의한다.

목표는 세 가지다.

- dashboard UI route와
  backend API route를 분리한다.
- Telegram webhook path를
  future web UI와 충돌 없이 유지한다.
- 기존 Flutter IA의 화면 목록을
  web URL namespace로 내린다.

권한 규칙은
[HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md)
를 따른다.
화면 구조는
[HNI_AI_WEB_DASHBOARD_WIREFRAMES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_WIREFRAMES.md)
를 따른다.

## Canonical Route Groups

### Root

- `/`
  - 기본 동작:
    - 로그인 상태면 `/dashboard/home`으로 redirect
    - 비로그인 상태면 `/auth/login` 또는
      minimal control intro로 redirect

### Auth

- `/auth/login`
- `/auth/logout`
- `/auth/session-expired`
- `/auth/callback`
- `/auth/forbidden`

### Dashboard

- `/dashboard`
  - `/dashboard/home`
  - `/dashboard/orders`
  - `/dashboard/orders/:orderId`
  - `/dashboard/strategy`
  - `/dashboard/squads`
  - `/dashboard/reports`
  - `/dashboard/reports/:reportId`
  - `/dashboard/mozzy-board`
  - `/dashboard/approvals`
  - `/dashboard/channels`
  - `/dashboard/audit`

### API

- `/api/v1/health`
- `/api/v1/session`
- `/api/v1/session/logout`
- `/api/v1/orders`
- `/api/v1/orders/:orderId`
- `/api/v1/orders/:orderId/approvals/:approvalId/approve`
- `/api/v1/orders/:orderId/hold`
- `/api/v1/orders/:orderId/resume`
- `/api/v1/snapshot`
- `/api/v1/commands`

### Telegram Integration

- `/api/v1/integrations/telegram/status`
- `/api/v1/integrations/telegram/set-webhook`
- `/api/v1/integrations/telegram/delete-webhook`
- `/api/v1/integrations/telegram/poll-once`
- `/api/v1/integrations/telegram/webhook`

## Route Boundary Rules

### 1. UI routes are always under `/dashboard`

operator 화면은
root level에 흩뿌리지 않고
모두 `/dashboard/**` 아래에 둔다.

이유:

- auth middleware 적용이 단순해진다
- reverse proxy와 SPA fallback 구성이 단순해진다
- Telegram/API path와 충돌하지 않는다

### 2. Auth routes are always under `/auth`

로그인/세션 만료/권한 없음 화면은
`/auth/**` namespace로 고정한다.

이유:

- 대시보드와 인증 플로우를 분리할 수 있다
- future SSO/OIDC callback path를
  예측 가능하게 유지할 수 있다

### 3. Machine APIs stay under `/api/v1`

UI가 호출하는 JSON API와
integration webhook는
모두 `/api/v1/**` 아래에 둔다.

이유:

- 버전 관리가 쉬워진다
- observability/logging 분리가 쉽다
- non-UI clients와 공용 규칙을 만들 수 있다

### 4. Telegram webhook path stays unchanged

기존 Telegram runtime path인
`/api/v1/integrations/telegram/webhook`는 유지한다.

이유:

- 이미 구현된 backend route와 정합성이 맞다
- webhook helper/status 문서와도 일치한다
- future dashboard를 붙여도
  integration path migration이 필요 없어진다

## Mapping From Existing Flutter IA

기존 IA의 suggested router shape는
web 기준으로 아래처럼 매핑한다.

- `/home` -> `/dashboard/home`
- `/orders` -> `/dashboard/orders`
- `/orders/:id` -> `/dashboard/orders/:orderId`
- `/strategy` -> `/dashboard/strategy`
- `/squads` -> `/dashboard/squads`
- `/reports` -> `/dashboard/reports`
- `/reports/:id` -> `/dashboard/reports/:reportId`
- `/mozzy-board` -> `/dashboard/mozzy-board`
- `/approvals` -> `/dashboard/approvals`
- `/channels` -> `/dashboard/channels`
- `/audit` -> `/dashboard/audit`

## Recommended Access Levels

### Public

- `/`
- `/auth/login`
- `/auth/callback`
- `/auth/session-expired`

### Authenticated Operator

- `/api/v1/session`
- `/dashboard/home`
- `/dashboard/orders`
- `/dashboard/orders/:orderId`
- `/dashboard/reports`
- `/dashboard/reports/:reportId`
- `/dashboard/channels`
- `/dashboard/audit`

### Elevated Operator or CEO

- `/dashboard/strategy`
- `/dashboard/squads`
- `/dashboard/mozzy-board`
- `/dashboard/approvals`

### Machine-to-Machine

- `/api/v1/integrations/telegram/webhook`

### Local-only or protected ops route

아래는 public internet에
그대로 노출하기보다
추가 보호를 권장한다.

- `/api/v1/integrations/telegram/status`
- `/api/v1/integrations/telegram/set-webhook`
- `/api/v1/integrations/telegram/delete-webhook`
- `/api/v1/integrations/telegram/poll-once`

### Session Discovery Route

- `/api/v1/session`

이 경로는
public marketing API가 아니라
same-origin dashboard bootstrap용으로 본다.

### Session Mutation Route

- `/api/v1/session/logout`

이 경로는
cookie session 종료용 JSON endpoint다.

## Reverse Proxy Guidance

### Option A. Single backend with SPA fallback

- `/dashboard/**` -> web dashboard app
- `/auth/**` -> auth-aware UI app
- `/api/v1/**` -> backend API

이 방식은
frontend와 backend를 같은 origin에서 운영하기 쉽다.

### Option B. UI bundle + API backend behind same domain

- `/dashboard/**` -> static web bundle
- `/auth/**` -> static web bundle or auth handler
- `/api/v1/**` -> private backend proxy

이 방식은
future Flutter web dashboard 또는
별도 web frontend를 붙이기 쉽다.

## Root Behavior Recommendation

현재는 root `/`를
크게 쓰지 않는 것이 안전하다.

권장 동작:

1. 로그인 세션이 있으면 `/dashboard/home` redirect
2. 없으면 `/auth/login` redirect

대안:

- root에 아주 작은 control intro page를 두고
  로그인 버튼만 노출

## Non-Goals

- 이번 문서는 실제 auth provider를 선택하지 않는다.
- 이번 문서는 UI framework를 Flutter web로 확정하지 않는다.
- 이번 문서는 실제 server-side redirect 구현까지 하지 않는다.
