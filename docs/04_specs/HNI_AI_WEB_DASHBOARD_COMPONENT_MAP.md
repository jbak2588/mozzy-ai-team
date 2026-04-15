# HNI AI Web Dashboard Component Map

## Purpose

이 문서는
future `ai.humantric.net` web dashboard를
실제 구현 단위의 component map으로 정리한다.

route 구조는
[HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md),
화면 구조는
[HNI_AI_WEB_DASHBOARD_WIREFRAMES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_WIREFRAMES.md)
를 따른다.

## Top-Level Module Layout

권장 기본 구조는 아래다.

- `app_shell`
- `auth`
- `dashboard_home`
- `orders`
- `strategy`
- `squads`
- `reports`
- `mozzy_board`
- `approvals`
- `channels`
- `audit`
- `shared_ui`
- `data_access`
- `session_state`

## Global Component Layers

### 1. App Shell Layer

공통 shell component:

- `AppBootstrap`
- `RootRouter`
- `AppShell`
- `PrimaryNavRail`
- `ContextTopBar`
- `SecondaryInsightPaneHost`
- `GlobalCommandDock`
- `GlobalToastHost`

역할:

- route mount
- shell layout 유지
- global environment badge
- backend health/status 노출
- global create-order action 제공

### 2. Auth and Session Layer

공통 auth component:

- `SessionLoader`
- `AuthGuard`
- `RoleGate`
- `RecentAuthGate`
- `ForbiddenPage`
- `SessionExpiredPage`
- `LoginPage`
- `LogoutHandler`
- `CallbackHandler`

역할:

- current session fetch
- role resolution
- route access control
- reauthentication trigger
- callback success/failure handling

### 3. Shared Data Layer

공통 data/query component:

- `ApiClient`
- `SessionRepository`
- `OrdersRepository`
- `ReportsRepository`
- `ApprovalsRepository`
- `ChannelsRepository`
- `MozzyRepository`
- `AuditRepository`
- `DashboardSummaryRepository`

역할:

- `/api/v1/**` 호출
- query/cache/error boundary
- DTO to UI model normalize

## Route-to-Component Map

### `/dashboard/home`

#### Home Page Component

- `DashboardHomePage`

#### Home Child Components

- `ExecutiveSummaryStrip`
- `ActiveOrdersCard`
- `PendingApprovalsCard`
- `RiskAlertPanel`
- `AgentBoardPanel`
- `RecentReportsPanel`
- `ChannelHealthPanel`

#### Home Data Sources

- `DashboardSummaryRepository`
- `OrdersRepository`
- `ApprovalsRepository`
- `ReportsRepository`
- `ChannelsRepository`

### `/dashboard/orders`

#### Orders Page Component

- `OrdersPage`

#### Orders Child Components

- `OrderFilterBar`
- `OrderListTable`
- `OrderListRow`
- `OrderMetaCard`
- `LifecycleStepper`
- `ArtifactsList`
- `OrderAuditPreview`
- `OrderActionBar`

#### Orders Data Sources

- `OrdersRepository`
- `ApprovalsRepository`
- `AuditRepository`

### `/dashboard/orders/:orderId`

#### Order Detail Page Component

- `OrderDetailPage`

#### Order Detail Child Components

- `OrderHeader`
- `ExecutionStageCards`
- `ReportsLinkedPanel`
- `ApprovalControls`
- `AuditTimelinePane`

#### Order Detail Data Sources

- `OrdersRepository`
- `ReportsRepository`
- `ApprovalsRepository`
- `AuditRepository`

### `/dashboard/strategy`

#### Strategy Page Component

- `StrategyPage`

#### Strategy Child Components

- `StrategyQueueList`
- `RecommendationCard`
- `ScenarioComparePanel`
- `DecisionMemoPane`

#### Strategy Data Sources

- `OrdersRepository`
- `ReportsRepository`
- `DashboardSummaryRepository`

### `/dashboard/squads`

#### Squads Page Component

- `SquadsPage`

#### Squads Child Components

- `SquadCapacityStrip`
- `SquadLaneBoard`
- `SquadLaneCard`
- `DispatchInspector`
- `BlockerHeatmap`

#### Squads Data Sources

- `OrdersRepository`
- `DashboardSummaryRepository`

### `/dashboard/reports`

#### Reports Page Component

- `ReportsPage`

#### Reports Child Components

- `ReportFilterBar`
- `ReportListPane`
- `ReportViewerPane`
- `FindingsSummaryRail`
- `LinkedOrderCard`

#### Reports Data Sources

- `ReportsRepository`
- `OrdersRepository`

### `/dashboard/reports/:reportId`

#### Report Detail Page Component

- `ReportDetailPage`

#### Report Detail Child Components

- `ReportMetaHeader`
- `SummaryCard`
- `FindingsSection`
- `BlockersSection`
- `RecommendationSection`
- `EvidenceLinksPanel`

#### Report Detail Data Sources

- `ReportsRepository`
- `OrdersRepository`

### `/dashboard/mozzy-board`

#### Approvals Page Component

- `MozzyBoardPage`

#### Approvals Child Components

- `BranchComparisonHeader`
- `V1StatusBoard`
- `V2SliceBoard`
- `MergeBlockerLedger`
- `OpenQuestionsPanel`

#### Approvals Data Sources

- `MozzyRepository`
- `ReportsRepository`

### `/dashboard/approvals`

#### Channels Page Component

- `ApprovalsPage`

#### Channels Child Components

- `ApprovalQueueList`
- `ImpactSummaryCard`
- `DecisionControls`
- `ApprovalHistoryTimeline`
- `RiskNotesPanel`

#### Channels Data Sources

- `ApprovalsRepository`
- `OrdersRepository`
- `AuditRepository`

### `/dashboard/channels`

#### Audit Page Component

- `ChannelsPage`

#### Audit Child Components

- `ChannelHealthStrip`
- `CommandLogList`
- `CommandDetailPane`
- `TelegramStatusCard`
- `OpsActionsCard`
- `ReplyPreviewCard`

#### Audit Data Sources

- `ChannelsRepository`
- `AuditRepository`

### `/dashboard/audit`

#### Page Component

- `AuditPage`

#### Child Components

- `AuditFilterPanel`
- `AuditTimelineStream`
- `EntityInspector`
- `ExportActions`

#### Data Sources

- `AuditRepository`

## Cross-Cutting Components

아래는 여러 feature가 공통으로 쓰는 구성요소다.

- `StatusChip`
- `RiskBadge`
- `RoleBadge`
- `BackendHealthBadge`
- `EmptyStateCard`
- `ErrorStateCard`
- `LoadingSkeleton`
- `ConfirmActionDialog`
- `MarkdownReportViewer`
- `TimelineList`

## State Ownership Guidance

### Shell State

- current route
- current session
- backend health
- global command composer state

### Feature State

- filters
- selected entity id
- sort / tabs
- optimistic action status

### Server State

- orders
- reports
- approvals
- command logs
- audit events
- mozzy comparison snapshots

권장 원칙:

- server truth는 repository/query layer에 둔다
- UI state는 route feature module 안에 둔다
- auth/session은 feature별로 중복 보관하지 않는다

## Component-to-Auth Map

### Operator+

- `DashboardHomePage`
- `OrdersPage`
- `OrderDetailPage`
- `ReportsPage`
- `ReportDetailPage`
- `ChannelsPage`
- `AuditPage`

### Lead+

- `SquadsPage`
- `MozzyBoardPage`

### Approver+

- `StrategyPage`
- `ApprovalsPage`
- `DecisionControls`

### Admin+

- `OpsActionsCard`
- webhook helper control surface
- audit export actions

## Suggested Frontend Package Shape

- `lib/web/app_shell/`
- `lib/web/auth/`
- `lib/web/features/dashboard_home/`
- `lib/web/features/orders/`
- `lib/web/features/strategy/`
- `lib/web/features/squads/`
- `lib/web/features/reports/`
- `lib/web/features/mozzy_board/`
- `lib/web/features/approvals/`
- `lib/web/features/channels/`
- `lib/web/features/audit/`
- `lib/web/shared/`
- `lib/web/data/`

## Desktop MVP Reuse Opportunities

현재 desktop MVP에서
개념적으로 재사용 가능한 것은 아래다.

- `14-Agent Board` 정보 모델
- work order lifecycle 상태명
- approval / hold / resume action 개념
- channel command log 개념
- backend health / remote mode 상태 개념

즉 web dashboard는
UI를 새로 그리더라도
도메인 vocabulary는 desktop MVP와 맞춰야 한다.

## Recommended Implementation Order

1. `app_shell`
2. `auth`
3. `dashboard_home`
4. `orders`
5. `approvals`
6. `channels`
7. `reports`
8. `mozzy_board`
9. `strategy`, `squads`, `audit`

이 순서가 맞는 이유:

- home/orders/approvals/channels가
  control plane의 첫 운영 가치와 가장 직접 연결된다
- Mozzy-specific board는
  그 다음 도메인 특화 계층으로 붙이면 된다

## Non-Goals

- 실제 framework 선택은 아직 확정하지 않는다
- 실제 codegen, API schema generation은 아직 하지 않는다
- visual token naming까지는 이번 문서 범위에 넣지 않는다
