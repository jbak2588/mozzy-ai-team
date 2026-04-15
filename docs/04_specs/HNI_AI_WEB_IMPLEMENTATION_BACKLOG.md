# HNI AI Web Implementation Backlog

## Purpose

이 문서는
future `ai.humantric.net` web dashboard를
실제 구현 작업 순서로 내린 backlog다.

입력 문서는 아래다.

- route:
  [HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md)
- auth:
  [HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md)
- auth/session contract:
  [HNI_AI_AUTH_SESSION_API_CONTRACT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_SESSION_API_CONTRACT.md)
- wireframe:
  [HNI_AI_WEB_DASHBOARD_WIREFRAMES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_WIREFRAMES.md)
- provider sequence:
  [HNI_AI_AUTH_PROVIDER_INTEGRATION_SEQUENCES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_PROVIDER_INTEGRATION_SEQUENCES.md)
- component map:
  [HNI_AI_WEB_DASHBOARD_COMPONENT_MAP.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_COMPONENT_MAP.md)

## Backlog Principles

- 한 번에 모든 route를 구현하지 않는다
- shell/auth contract를 먼저 닫는다
- provider는 하나만 먼저 붙인다
- first slice는 operator value가 큰 화면부터 연다
- hardening은 마지막이 아니라
  각 phase acceptance에 일부 포함한다

## Delivery Phases

### Phase 0. Foundation

- web target bootstrap
- app shell
- session/api client contract
- auth routes
- role gates

### Phase 1. Core Ops Slice

- dashboard home
- orders
- approvals
- channels

### Phase 2. Reporting Slice

- reports
- mozzy board

### Phase 3. Governance Slice

- strategy
- squads
- audit

### Phase 4. Hardening

- tests
- telemetry
- empty/error states
- recent-auth / step-up
- secondary provider readiness

## Recommended First Shipping Slice

첫 shipping slice는 아래를 포함한다.

- `app_shell`
- `auth`
- `dashboard_home`
- `orders`
- `approvals`
- `channels`

이 slice가 열리면
HNI는 web에서 최소한 아래를 할 수 있다.

- 로그인
- 현재 order/approval 상태 확인
- 작업 상세 열람
- 승인/보류 흐름 진입
- Telegram channel 상태와 command log 확인

## Work Items

### WB-001 Web Bootstrap

- goal:
  web dashboard의 기본 project entry와 route mount를 만든다
- depends on:
  route spec, repository mode selection
- output:
  web target bootstrap, app router base, environment config
- acceptance:
  `/`, `/auth/login`, `/dashboard/home` route가 비어 있는 shell로라도 열린다

### WB-002 App Shell

- goal:
  모든 protected route가 공유할 shell을 구현한다
- depends on:
  WB-001, wireframe
- output:
  `AppShell`, `PrimaryNavRail`, `ContextTopBar`,
  `SecondaryInsightPaneHost`, `GlobalCommandDock`
- acceptance:
  route 전환 시 shell은 유지되고 중앙 work pane만 교체된다

### WB-003 Session and API Contract

- goal:
  frontend가 의존할 최소 session/api contract를 고정한다
- depends on:
  WB-001
- output:
  `ApiClient`, `SessionRepository`, base error model,
  backend health contract,
  auth/session DTO alignment
- acceptance:
  unauthenticated, authenticated, forbidden, expired 상태를
  하나의 session model로 표현할 수 있다

### WB-004 Auth Routes

- goal:
  `/auth/login`, `/auth/callback`, `/auth/logout`,
  `/auth/session-expired`, `/auth/forbidden`를 구현한다
- depends on:
  WB-003, provider integration sequence
- output:
  auth pages and handlers
- acceptance:
  login start, callback success/failure, logout return,
  forbidden/expired 화면이 닫힌다

### WB-005 Auth Guards

- goal:
  `AuthGuard`, `RoleGate`, `RecentAuthGate`를 구현한다
- depends on:
  WB-004, auth matrix
- output:
  route gate layer
- acceptance:
  `Operator+`, `Lead+`, `Approver+`, `Admin+` 경계가
  route별로 재현된다

### WB-006 Dashboard Home

- goal:
  첫 운영 overview 화면을 구현한다
- depends on:
  WB-002, WB-003, WB-005
- output:
  `DashboardHomePage`, summary cards, risk and approval widgets
- acceptance:
  로그인 후 home에서
  active orders, pending approvals, channel health를 한 번에 읽을 수 있다

### WB-007 Orders List and Detail

- goal:
  queue triage와 order detail canonical view를 구현한다
- depends on:
  WB-006
- output:
  `OrdersPage`, `OrderDetailPage`, lifecycle panels
- acceptance:
  order list -> detail drill-down,
  artifact/report/audit preview가 닫힌다

### WB-008 Approvals

- goal:
  approval queue와 decision pane을 구현한다
- depends on:
  WB-007, WB-005
- output:
  `ApprovalsPage`, queue, impact summary, decision controls
- acceptance:
  Approver 이상만 접근 가능하고
  selected approval의 영향/이력/결정 UI가 닫힌다

### WB-009 Channels

- goal:
  Telegram 중심 channel health와 command log view를 구현한다
- depends on:
  WB-006, WB-003
- output:
  `ChannelsPage`, status cards, command detail, safe ops actions
- acceptance:
  bot status, polling/webhook mode, recent command log를
  한 화면에서 읽을 수 있다

### WB-010 Reports

- goal:
  report list/viewer/evidence 흐름을 구현한다
- depends on:
  WB-007
- output:
  `ReportsPage`, `ReportDetailPage`
- acceptance:
  report list filtering, detail reading, linked order jump가 가능하다

### WB-011 Mozzy Board

- goal:
  Mozzy V1/V2 비교 보드를 web에 구현한다
- depends on:
  WB-010
- output:
  `MozzyBoardPage`, branch comparison, merge blocker ledger
- acceptance:
  V1/V2 상태와 blocker를
  한 route에서 비교 가능하다

### WB-012 Strategy and Squads

- goal:
  strategy decision과 squad dispatch UI를 구현한다
- depends on:
  WB-008, WB-011
- output:
  `StrategyPage`, `SquadsPage`
- acceptance:
  전략 제안, CEO 메모, squad capacity/dispatch를
  역할에 맞게 볼 수 있다

### WB-013 Audit

- goal:
  timeline 중심 audit 화면을 구현한다
- depends on:
  WB-007, WB-008, WB-009
- output:
  `AuditPage`, filters, entity inspector
- acceptance:
  order/approval/channel 관련 사건을
  timeline과 entity drill-down으로 읽을 수 있다

### WB-014 Primary Provider Adapter

- goal:
  shortlisted provider 중 primary 하나를 실제로 붙인다
- depends on:
  WB-004, provider sequence
- output:
  provider registration, callback exchange, claim normalization
- acceptance:
  real provider login으로
  HNI session cookie와 role mapping이 닫힌다

### WB-015 Hardening and Verification

- goal:
  first slice의 회귀와 운영 위험을 줄인다
- depends on:
  WB-006 ~ WB-014
- output:
  route smoke tests, role-gate tests, error/empty states,
  recent-auth gate, telemetry hooks
- acceptance:
  protected route 회귀와 auth/session 기본 장애가
  테스트와 관측 포인트로 잡힌다

## Phase-to-Item Mapping

- Phase 0:
  `WB-001` ~ `WB-005`
- Phase 1:
  `WB-006` ~ `WB-009`
- Phase 2:
  `WB-010` ~ `WB-011`
- Phase 3:
  `WB-012` ~ `WB-013`
- Phase 4:
  `WB-014` ~ `WB-015`

## Suggested Execution Order

1. `WB-001` Web Bootstrap
2. `WB-002` App Shell
3. `WB-003` Session and API Contract
4. `WB-004` Auth Routes
5. `WB-005` Auth Guards
6. `WB-006` Dashboard Home
7. `WB-007` Orders
8. `WB-008` Approvals
9. `WB-009` Channels
10. `WB-010` Reports
11. `WB-011` Mozzy Board
12. `WB-012` Strategy and Squads
13. `WB-013` Audit
14. `WB-014` Primary Provider Adapter
15. `WB-015` Hardening and Verification

## Backlog Notes

- `WB-014`는 provider를 하나만 먼저 붙인다
- first slice에서 multi-provider switcher는 넣지 않는다
- `Channels`의 webhook set/delete는
  UI 노출 전에 Admin gate와 recent-auth가 먼저 닫혀야 한다
- mobile optimization은 first slice 목표가 아니다

## Non-Goals

- 실제 sprint 기간 산정
- 인력 배정
- production rollout 일정
- provider 2개 이상 동시 구현 계획
