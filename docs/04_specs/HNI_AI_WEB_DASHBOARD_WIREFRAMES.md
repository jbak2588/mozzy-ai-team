# HNI AI Web Dashboard Wireframes

## Purpose

이 문서는
`ai.humantric.net` future web dashboard의
route별 wireframe 구조를 정의한다.

route 규칙은
[HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md),
권한 규칙은
[HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md),
auth/session 원칙은
[HNI_AI_AUTH_OIDC_DESIGN.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_OIDC_DESIGN.md)
를 따른다.
구현 단위 분해는
[HNI_AI_WEB_DASHBOARD_COMPONENT_MAP.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_COMPONENT_MAP.md)
를 따른다.

## Design Bias

핵심 bias는 아래다.

- desktop-first
- internal ops console
- dense information, low decoration
- one-screen situational awareness
- split-pane 우선

즉 이 dashboard는
marketing landing처럼 보이면 안 되고,
order, approval, channel, audit를
한 번에 읽고 조작하는 control plane이어야 한다.

## Global Shell

모든 authenticated route는
기본적으로 아래 shell을 공유한다.

- 좌측:
  `PrimaryNavRail`
- 상단:
  `ContextTopBar`
- 중앙:
  `PrimaryWorkPane`
- 우측:
  `SecondaryInsightPane`
- 하단 또는 우측 하단:
  `GlobalCommandDock`

## Shared Shell Regions

### PrimaryNavRail

- logo / environment badge
- `Home`
- `Orders`
- `Strategy`
- `Squads`
- `Reports`
- `Mozzy Board`
- `Approvals`
- `Channels`
- `Audit`

### ContextTopBar

- current route title
- breadcrumb
- global search
- environment / backend health chip
- session / role chip
- `New Work Order` primary action

### SecondaryInsightPane

route마다 달라지지만
보통 아래 중 일부를 담는다.

- pending approvals
- risk alerts
- Telegram status
- recent reports
- Mozzy V1/V2 readiness snapshot
- audit highlights

### GlobalCommandDock

- quick command input
- recent command result
- hotkeys hint

## Auth and Entry Screens

### `/auth/login`

#### Login Layout

- centered auth card
- 좌측 짧은 trust note
- 우측 sign-in module

#### Login Primary Panels

- `SignInCard`
- `ProviderChoiceBlock`
- `SecurityNoticeBlock`
- `AllowedRolesPreview`

#### UX Notes

- 기본 버튼은
  "Continue with company SSO"
- provider brand보다
  HNI control plane 접근이라는 맥락을 먼저 보여준다
- 환경이 staging이면
  상단에 non-production badge를 고정한다

### `/auth/session-expired`

#### Session Expired Layout

- single recovery card
- background는 최소한으로 유지

#### Session Expired Primary Panels

- `SessionExpiredCard`
- `ReauthenticateButton`
- `LastAttemptMeta`

### `/auth/forbidden`

#### Forbidden Layout

- single message card
- support / approver contact hint

#### Forbidden Primary Panels

- `ForbiddenReasonCard`
- `CurrentRoleChip`
- `RequestAccessAction`

## Dashboard Core Screens

### `/dashboard/home`

#### Home Layout

- top:
  KPI strip
- center-left:
  active orders
- center-right:
  pending approvals + risk
- bottom-left:
  14-agent board
- bottom-right:
  recent reports + channel health

#### Home Primary Panels

- `ExecutiveSummaryStrip`
- `ActiveOrdersTable`
- `PendingApprovalsLane`
- `RiskAlertPanel`
- `AgentBoardPanel`
- `RecentReportsPanel`
- `ChannelHealthPanel`

#### Home Intent

로그인 직후
"무엇이 막혀 있고 무엇을 먼저 눌러야 하는가"가
바로 보여야 한다.

### `/dashboard/orders`

#### Orders Layout

- left:
  filter + order list
- center:
  selected order summary
- right:
  approvals, artifacts, audit preview

#### Orders Primary Panels

- `OrderFilterBar`
- `OrderListTable`
- `OrderMetaCard`
- `LifecycleStepper`
- `AssignedSquadCard`
- `ArtifactsList`
- `OrderAuditPreview`

#### Orders Intent

한 화면에서
queue triage와 single order review가
동시에 가능해야 한다.

### `/dashboard/orders/:orderId`

#### Order Detail Layout

- top:
  order header + status chips
- main:
  lifecycle timeline
- lower-left:
  reports and artifacts
- lower-right:
  approval controls + audit trail

#### Order Detail Primary Panels

- `OrderHeader`
- `LifecycleTimeline`
- `ExecutionStageCards`
- `ReportsLinkedPanel`
- `ApprovalControls`
- `AuditTimelinePane`

#### Order Detail Intent

이 화면은
order의 canonical control view다.
승인, 보류, 재개, 결과 확인이
이곳에서 닫혀야 한다.

## Governance and Planning Screens

### `/dashboard/strategy`

#### Strategy Layout

- left:
  strategy queue
- center:
  current recommendation
- right:
  CEO decision pane

#### Strategy Primary Panels

- `StrategyQueueList`
- `RecommendationCard`
- `ScenarioComparePanel`
- `DecisionMemoPane`

#### Strategy Intent

전략군 제안과
CEO 코멘트가 한 눈에 이어져야 한다.

### `/dashboard/squads`

#### Squads Layout

- top:
  squad capacity strip
- main:
  squad lanes
- right:
  dispatch inspector

#### Squads Primary Panels

- `SquadCapacityStrip`
- `SquadLaneBoard`
- `DispatchInspector`
- `BlockerHeatmap`

#### Squads Intent

어느 squad가 비어 있고,
어디가 막혔는지를
한 화면에서 바로 보여준다.

## Reporting Screens

### `/dashboard/reports`

#### Reports Layout

- left:
  report list and filters
- center:
  report viewer
- right:
  linked order and findings summary

#### Reports Primary Panels

- `ReportFilterBar`
- `ReportListPane`
- `ReportViewerPane`
- `FindingsSummaryRail`
- `LinkedOrderCard`

### `/dashboard/reports/:reportId`

#### Report Detail Layout

- top:
  report title + status
- main:
  report narrative
- right:
  blockers / recommendations / linked evidence

#### Report Detail Primary Panels

- `ReportMetaHeader`
- `SummaryCard`
- `FindingsSection`
- `BlockersSection`
- `RecommendationSection`
- `EvidenceLinksPanel`

## Mozzy-Specific Screen

### `/dashboard/mozzy-board`

#### Mozzy Board Layout

- top:
  branch selector + merge readiness header
- main-left:
  V1 baseline board
- main-right:
  V2 slice board
- bottom:
  blocker ledger + open questions

#### Mozzy Board Primary Panels

- `BranchComparisonHeader`
- `V1StatusBoard`
- `V2SliceBoard`
- `MergeBlockerLedger`
- `OpenQuestionsPanel`

#### Mozzy Board Intent

Mozzy V1과 V2를
문서/기능/merge readiness 기준으로
나란히 판단하는 canonical route다.

## Approval and Channel Screens

### `/dashboard/approvals`

#### Approvals Layout

- left:
  pending approval queue
- center:
  selected approval impact summary
- right:
  decision controls + history

#### Approvals Primary Panels

- `ApprovalQueueList`
- `ImpactSummaryCard`
- `DecisionControls`
- `ApprovalHistoryTimeline`
- `RiskNotesPanel`

#### Approvals Intent

Approver는
queue 확인, 영향 판단, 결정 기록을
화면 전환 없이 끝낼 수 있어야 한다.

### `/dashboard/channels`

#### Channels Layout

- top:
  Telegram / WhatsApp health strip
- left:
  command log stream
- center:
  selected command detail
- right:
  integration status and safe actions

#### Channels Primary Panels

- `ChannelHealthStrip`
- `CommandLogList`
- `CommandDetailPane`
- `TelegramStatusCard`
- `OpsActionsCard`
- `ReplyPreviewCard`

#### Channels Intent

실시간 command visibility와
integration health 확인이
같은 화면에서 이뤄져야 한다.

### `/dashboard/audit`

#### Audit Layout

- left:
  audit filters
- center:
  timeline stream
- right:
  entity detail inspector

#### Audit Primary Panels

- `AuditFilterPanel`
- `AuditTimelineStream`
- `EntityInspector`
- `ExportActions`

## Responsive Rules

### Desktop Wide

- 좌측 nav 고정
- 중앙/우측 split-pane 유지
- command dock는 우측 하단 고정 가능

### Desktop Narrow

- 우측 secondary pane를
  collapsible drawer로 전환
- list/detail 우선순위를 유지

### Mobile

- 이번 문서는 mobile first를 목표로 하지 않는다
- mobile은 read-only 또는 limited triage 정도로만 가정한다

## Banner and State Rules

모든 protected screen은
상단에 아래 상태 중 필요한 배너를 노출한다.

- `NonProductionBanner`
- `BackendDisconnectedBanner`
- `SessionExpiringBanner`
- `ApprovalRequiredBanner`
- `TelegramIntegrationWarningBanner`

## Route-to-Wireframe Mapping Summary

- `/auth/**`
  - centered recovery/auth card 구조
- `/dashboard/home`
  - summary-first overview
- `/dashboard/orders*`
  - list/detail canonical split
- `/dashboard/strategy`
  - queue/recommendation/decision 3-pane
- `/dashboard/squads`
  - lane board + inspector
- `/dashboard/reports*`
  - list/viewer/evidence split
- `/dashboard/mozzy-board`
  - V1/V2 comparison board
- `/dashboard/approvals`
  - queue/impact/decision split
- `/dashboard/channels`
  - live log/detail/status split
- `/dashboard/audit`
  - filters/timeline/inspector split

## Non-Goals

- 실제 Flutter web widget 구현은 아직 하지 않는다
- 실제 auth provider integration screen은 아직 만들지 않는다
- final visual design system 토큰은 아직 확정하지 않는다
