# HNI AI Web Dashboard Auth Matrix

## Purpose

이 문서는
`ai.humantric.net` future web dashboard의
route별 auth gate와 role matrix를 정의한다.

핵심 목적은 세 가지다.

- route마다 최소 접근 권한을 고정한다.
- 미인가 접근 시 redirect 규칙을 통일한다.
- Telegram webhook/API와
  operator UI의 권한 경계를 분리한다.

provider / session 원칙은
[HNI_AI_AUTH_OIDC_DESIGN.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_OIDC_DESIGN.md)
를 따른다.
실제 화면 배치는
[HNI_AI_WEB_DASHBOARD_WIREFRAMES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_WIREFRAMES.md)
를 따른다.

## Canonical Role Hierarchy

권한은 아래 순서를 기본 계층으로 본다.

1. `Public`
2. `Operator`
3. `Lead`
4. `Approver`
5. `CEO`
6. `Admin`
7. `Machine`

## Role Definitions

### `Public`

- 비로그인 사용자
- root redirect 진입
- login/callback/session-expired 화면 접근만 허용

### `Operator`

- 일반 내부 운영자
- work order 조회
- reports/channels/audit 조회
- 일상 운영 command 사용

### `Lead`

- squad lead 또는 domain lead
- Operator 권한 포함
- squad dispatch, merge readiness, 보고 검토 범위 확장

### `Approver`

- 승인권자
- Lead 권한 포함
- approval gate 처리
- hold/resume/approval 관련 핵심 화면 접근

### `CEO`

- HNI CEO 또는 CEO delegated final approver
- Approver 권한 포함
- strategy decision과 최종 우선순위 결정

### `Admin`

- 시스템 운영 관리자
- 모든 operator UI route 접근
- auth/session/support route 관리
- protected ops endpoint 접근

### `Machine`

- 사람 사용자가 아닌 system actor
- Telegram webhook, health probe,
  내부 자동화 client 같은 machine principal

## Auth Gate Types

### `PublicOnlyGate`

- 로그인 사용자가 접근하면
  `/dashboard/home`으로 redirect
- 비로그인 사용자는 통과

적용 예:

- `/auth/login`
- `/auth/session-expired`

### `AuthenticatedGate`

- 로그인 여부만 검사
- 비로그인 사용자는 `/auth/login`으로 redirect

적용 예:

- `/dashboard/home`
- `/dashboard/orders`
- `/dashboard/reports`

### `SessionProbeGate`

- 비로그인 상태여도 호출 가능
- same-origin web bootstrap만 허용
- session payload만 반환

적용 예:

- `/api/v1/session`

### `RoleGate`

- 최소 role 이상인지 검사
- 부족하면 `/auth/forbidden` 또는
  `/dashboard/home`으로 redirect

적용 예:

- `/dashboard/approvals`
- `/dashboard/strategy`

### `MachineGate`

- machine credential 또는
  signed request만 통과
- 브라우저 사용자는 직접 접근하지 않음

적용 예:

- `/api/v1/integrations/telegram/webhook`

### `ProtectedOpsGate`

- Admin 또는 별도 ops principal만 허용
- public internet에서 그대로 열지 않고
  추가 보호 계층을 둔다

적용 예:

- `/api/v1/integrations/telegram/set-webhook`
- `/api/v1/integrations/telegram/delete-webhook`

## Route Matrix

### Root and Auth

- `/`
  - gate: redirect gate
  - public: allowed
  - authenticated: `/dashboard/home` redirect
  - unauthenticated: `/auth/login` 또는 intro page

- `/auth/login`
  - gate: `PublicOnlyGate`
  - roles: `Public`

- `/auth/logout`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/auth/session-expired`
  - gate: `PublicOnlyGate`
  - roles: `Public`

- `/auth/callback`
  - gate: auth callback gate
  - roles: `Public`

- `/auth/forbidden`
  - gate: display gate
  - roles: `Public`, `Operator+`

### Dashboard Core

- `/dashboard/home`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/dashboard/orders`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/dashboard/orders/:orderId`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/dashboard/reports`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/dashboard/reports/:reportId`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/dashboard/channels`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/dashboard/audit`
  - gate: `RoleGate`
  - roles: `Operator+`
  - note: export/admin actions는 `Admin`만

### Decision and Governance

- `/dashboard/strategy`
  - gate: `RoleGate`
  - roles: `Approver+`

- `/dashboard/squads`
  - gate: `RoleGate`
  - roles: `Lead+`

- `/dashboard/mozzy-board`
  - gate: `RoleGate`
  - roles: `Lead+`

- `/dashboard/approvals`
  - gate: `RoleGate`
  - roles: `Approver+`

## API Matrix

### General App API

- `/api/v1/session`
  - gate: `SessionProbeGate`
  - roles: `Public`, `Operator+`

- `/api/v1/session/logout`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/api/v1/health`
  - gate: `MachineGate` 또는 protected ops allowlist
  - roles: `Admin`, `Machine`

- `/api/v1/snapshot`
  - gate: `AuthenticatedGate` on UI session or service token
  - roles: `Operator+`

- `/api/v1/orders`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/api/v1/orders/:orderId`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

- `/api/v1/orders/:orderId/approvals/:approvalId/approve`
  - gate: `RoleGate`
  - roles: `Approver+`

- `/api/v1/orders/:orderId/hold`
  - gate: `RoleGate`
  - roles: `Approver+`

- `/api/v1/orders/:orderId/resume`
  - gate: `RoleGate`
  - roles: `Approver+`

- `/api/v1/commands`
  - gate: `AuthenticatedGate`
  - roles: `Operator+`

### Telegram Integration API

- `/api/v1/integrations/telegram/webhook`
  - gate: `MachineGate`
  - roles: `Machine`

- `/api/v1/integrations/telegram/status`
  - gate: `ProtectedOpsGate`
  - roles: `Admin+`

- `/api/v1/integrations/telegram/set-webhook`
  - gate: `ProtectedOpsGate`
  - roles: `Admin+`

- `/api/v1/integrations/telegram/delete-webhook`
  - gate: `ProtectedOpsGate`
  - roles: `Admin+`

- `/api/v1/integrations/telegram/poll-once`
  - gate: `ProtectedOpsGate`
  - roles: `Admin+`

## Redirect Rules

### Unauthenticated Browser User

- target가 `/dashboard/**`이면
  `/auth/login`으로 보낸다

### Authenticated but Insufficient Role

- target가 dashboard UI면
  `/auth/forbidden` 또는 `/dashboard/home`
- target가 API면
  `403 Forbidden`

### Public Route Access by Logged-in User

- `/auth/login`, `/auth/session-expired` 접근 시
  `/dashboard/home`으로 보낸다

## UI Notes

권한이 있어도
모든 액션 버튼을 항상 노출할 필요는 없다.

예:

- `/dashboard/audit`는 Operator도 볼 수 있지만
  export 또는 retention override는 Admin만
- `/dashboard/orders/:orderId`는 Operator도 보지만
  approve/hold/resume action은 Approver만
- `/dashboard/strategy`는 Approver 이상만 보이게 유지

## Telegram and Web Role Relationship

Telegram sender authorization과
web dashboard role은 동일 값이 아니다.

원칙:

- Telegram allowlist는
  channel ingress identity
- web role matrix는
  authenticated HNI internal user identity

다만 향후 운영상 매핑은 가능하다.

예:

- Telegram approver sender
  -> web role `Approver` 이상
- Telegram machine webhook
  -> web role 체계 밖 `Machine`

## Non-Goals

- 실제 auth provider 선정
- 실제 OIDC claim schema 정의
- 실제 session cookie/JWT 구현
- 실제 RBAC middleware 코드 구현
