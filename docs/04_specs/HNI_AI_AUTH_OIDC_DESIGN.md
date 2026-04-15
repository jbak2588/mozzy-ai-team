# HNI AI Auth OIDC Design

## Purpose

이 문서는
`ai.humantric.net` future web dashboard의
human auth provider / OIDC 설계를 정의한다.

핵심 목적은 세 가지다.

- operator UI용 인증 방식을 고정한다.
- route/auth matrix와 맞는 session 규칙을 정리한다.
- Telegram webhook 같은 machine path와
  human login을 분리한다.

## Recommended Human Auth Model

권장 기본값은 아래다.

- protocol:
  OIDC
- flow:
  Authorization Code + PKCE
- session model:
  server-issued session cookie
- token handling:
  browser local storage 장기 보관 지양
- audience:
  HNI internal operators only

## Why OIDC

OIDC를 기본으로 두는 이유:

- workforce identity provider와 연동하기 쉽다
- email/profile/group claim을 표준적으로 다룰 수 있다
- future SSO와 role mapping으로 이어가기 쉽다
- `/auth/callback` route와 정합성이 맞다

## Why Session Cookie over Browser Token Storage

권장 구조는
“OIDC 로그인 -> server-side code exchange ->
session cookie 발급”이다.

이유:

- dashboard와 API가 같은 origin 아래에 있다
- route gate 구현이 단순해진다
- XSS 관점에서 access token 노출면을 줄일 수 있다
- protected ops route를 다루기 쉽다

## Provider Requirements

최종 provider는 아직 고르지 않지만,
아래 조건은 필요하다.

세부 후보 비교와 선택 기준은
[HNI_AI_AUTH_PROVIDER_COMPARISON.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_PROVIDER_COMPARISON.md)
를 따른다.
provider별 실제 도입 순서는
[HNI_AI_AUTH_PROVIDER_INTEGRATION_SEQUENCES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_PROVIDER_INTEGRATION_SEQUENCES.md)
를 따른다.

- OIDC standard support
- Authorization Code + PKCE support
- redirect URI 등록 가능
- email / profile claim 제공
- group 또는 role claim 제공
- session 종료 또는 logout redirect 지원
- MFA 또는 step-up auth 확장 가능

예시 provider category:

- Google Workspace 계열 workforce identity
- Microsoft Entra ID
- Okta / Auth0 같은 workforce IdP

## Canonical Auth Flow

### 1. Login Start

브라우저가
`/auth/login`으로 진입한다.

backend 또는 auth handler는
OIDC authorize endpoint로 redirect한다.

포함 요소:

- `client_id`
- `redirect_uri`
- `response_type=code`
- `scope=openid profile email`
- `state`
- `nonce`
- PKCE challenge

### 2. Provider Authentication

사용자는 IdP에서 로그인한다.
필요 시 MFA 또는 조직 정책을 거친다.

### 3. Callback

IdP는
`/auth/callback`으로 code를 보낸다.

서버는 다음을 수행한다.

- code exchange
- issuer 검증
- audience 검증
- nonce/state 검증
- claim 파싱
- role mapping

### 4. Session Issue

검증이 끝나면
서버가 session cookie를 발급한다.

권장 속성:

- `HttpOnly`
- `Secure`
- `SameSite=Lax` 또는 정책에 맞는 stricter 값
- 짧은 수명과 rotation 전략

### 5. Authorized UI Access

브라우저는 session cookie로
`/dashboard/**`와 `/api/v1/**`를 호출한다.

route gate는
session + resolved role을 기준으로 동작한다.

## Recommended Callback and Auth Routes

- `/auth/login`
- `/auth/callback`
- `/auth/logout`
- `/auth/session-expired`
- `/auth/forbidden`

JSON session contract는
[HNI_AI_AUTH_SESSION_API_CONTRACT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_SESSION_API_CONTRACT.md)
를 따른다.

이 경로는
[HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md)
와 정합성을 맞춘다.

## Session Policy

### Base Session

권장 기본:

- idle timeout:
  짧게 유지
- absolute lifetime:
  업무 세션 단위로 제한
- refresh:
  server-side renewal 또는 재로그인 정책 사용

정확한 시간값은
실제 조직 정책 단계에서 확정한다.

### Recent Auth for Sensitive Actions

아래는 “recent auth” 또는
step-up auth를 권장한다.

- `/dashboard/approvals`
- `/dashboard/strategy`
- approval/hold/resume API
- webhook set/delete 같은 ops route

즉 로그인만 되어 있다고
항상 민감 액션을 허용하지 않는다.

## Role Claim Mapping

OIDC provider에서 받은 claim은
내부 role hierarchy로 매핑한다.

기본 내부 role:

- `Operator`
- `Lead`
- `Approver`
- `CEO`
- `Admin`

권장 입력 claim:

- `sub`
- `email`
- `email_verified`
- `name`
- `picture`
- `groups` 또는 `roles`

## Example Mapping Rule

- provider group `hni-operators`
  -> `Operator`
- provider group `hni-leads`
  -> `Lead`
- provider group `hni-approvers`
  -> `Approver`
- provider group `hni-ceo`
  -> `CEO`
- provider group `hni-admins`
  -> `Admin`

여러 그룹이 있으면
가장 높은 내부 role을 우선 적용한다.

## Human vs Machine Separation

중요한 원칙:

- human dashboard access:
  OIDC + session cookie
- Telegram webhook:
  machine integration path
- protected ops helper:
  admin auth 또는 별도 ops protection

즉
`/api/v1/integrations/telegram/webhook`는
human login 세션과 별개다.

## Recommended Session State Shape

session에는 최소한 아래가 필요하다.

- internal user id
- email
- resolved role
- auth time
- session issued at
- last activity at
- provider subject id

## Audit Events

권장 audit event:

- login success
- login failure
- logout
- session expired
- forbidden access
- role-mapped login
- step-up auth success/failure

## Protected Ops Consideration

아래 경로는
일반 operator session보다
더 강한 보호를 권장한다.

- `/api/v1/integrations/telegram/status`
- `/api/v1/integrations/telegram/set-webhook`
- `/api/v1/integrations/telegram/delete-webhook`
- `/api/v1/integrations/telegram/poll-once`

가능한 방식:

- `Admin` role 제한
- recent auth 요구
- IP allowlist 또는 별도 admin tunnel

## Recommended Env and Config Shape

future env 예시는 아래처럼 둘 수 있다.

- `HNI_AUTH_MODE=oidc`
- `HNI_OIDC_ISSUER`
- `HNI_OIDC_CLIENT_ID`
- `HNI_OIDC_CLIENT_SECRET`
- `HNI_OIDC_REDIRECT_URI`
- `HNI_OIDC_LOGOUT_REDIRECT_URI`
- `HNI_OIDC_SCOPES`
- `HNI_SESSION_COOKIE_NAME`

이 값들은
web runtime 또는 backend secret store에서 관리한다.

## Relationship to Existing Docs

- route namespace:
  [HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md)
- route gate / role matrix:
  [HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md)
- subdomain structure:
  [HNI_AI_SUBDOMAIN_ARCHITECTURE.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_SUBDOMAIN_ARCHITECTURE.md)

## Non-Goals

- 이번 문서는 최종 IdP 벤더를 확정하지 않는다.
- 이번 문서는 실제 middleware 코드를 구현하지 않는다.
- 이번 문서는 session duration 숫자를 최종 확정하지 않는다.
- 이번 문서는 machine webhook auth를 OIDC로 바꾸지 않는다.
