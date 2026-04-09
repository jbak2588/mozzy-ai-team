# HNI_DASHBOARD_FLUTTER_IA.md

## Purpose

이 문서는 HNI auto-company 대시보드를
Flutter 위젯 단위로 세분화한
정보구조(IA)와 초기 spec을 정리한다.

## App Shell

### Root Structure

- `HniDashboardApp`
  - `AppBootstrap`
  - `AuthGate`
  - `DashboardShell`

### DashboardShell

- `DashboardScaffold`
  - `DashboardSidebar`
  - `DashboardTopBar`
  - `DashboardBodyRouter`
  - `GlobalCommandComposer`
  - `GlobalNotificationTray`

## Navigation Model

### Primary Sections

1. Executive Home
2. Work Orders
3. Strategy Board
4. Squad Dispatch
5. Reports
6. Mozzy Product Board
7. Approval Gates
8. Channel Center
9. Audit Timeline

### Suggested Router Shape

- `/home`
- `/orders`
- `/orders/:id`
- `/strategy`
- `/squads`
- `/reports`
- `/reports/:id`
- `/mozzy-board`
- `/approvals`
- `/channels`
- `/audit`

## Screen-Level Widget Spec

### 1. Executive Home

#### Executive Home Widget Tree

- `ExecutiveHomeScreen`
- `ExecutiveSummaryHeader`
- `RiskAlertStrip`
- `KpiCardGrid`
- `AgentBoardPanel`
- `ActiveOrdersPanel`
- `PendingApprovalsPanel`
- `RecentReportsPanel`
- `SquadLoadPanel`

#### Executive Home State Sources

- `dashboardSummaryProvider`
- `agentDirectoryProvider`
- `activeOrdersProvider`
- `pendingApprovalsProvider`
- `recentReportsProvider`

#### Executive Home Key Actions

- 새 work order 생성
- 14-agent 역할군 확인
- high-risk order로 이동
- 최근 보고서 상세 보기

### 2. Work Orders

#### Work Orders Widget Tree

- `WorkOrdersScreen`
  - `OrderFilterBar`
  - `OrderListPane`
  - `OrderDetailPane`

- `OrderListPane`
  - `OrderSearchField`
  - `OrderStatusTabs`
  - `OrderTable`

- `OrderDetailPane`
  - `OrderMetaCard`
  - `OrderLifecycleStepper`
  - `AssignedSquadCard`
  - `OrderArtifactsList`
  - `OrderActionBar`

#### Work Orders State Sources

- `orderFiltersProvider`
- `orderListProvider`
- `selectedOrderProvider`

#### Work Orders Key Actions

- order 생성
- 상태 변경
- squad 배정
- artifact 연결

### 3. Strategy Board

#### Strategy Board Widget Tree

- `StrategyBoardScreen`
  - `StrategyDecisionHeader`
  - `StrategyOrderQueue`
  - `BezosRecommendationCard`
  - `StrategicOptionsPanel`
  - `CeoDecisionPanel`

#### Strategy Board State Sources

- `strategyQueueProvider`
- `strategyRecommendationProvider`
- `ceoDecisionDraftProvider`

#### Strategy Board Key Actions

- 전략안 비교
- CEO 코멘트 기록
- 승인 / 보류 / 수정 지시

### 4. Squad Dispatch

#### Squad Dispatch Widget Tree

- `SquadDispatchScreen`
  - `SquadSummaryStrip`
  - `SquadBoard`
  - `SquadCapacityPanel`
  - `DispatchInspector`

- `SquadBoard`
  - `SquadLaneCard` x N

- `SquadLaneCard`
  - `SquadHeader`
  - `AssignedOrderChips`
  - `BlockerBadgeRow`
  - `DispatchActions`

#### Squad Dispatch State Sources

- `squadBoardProvider`
- `squadCapacityProvider`
- `dispatchInspectorProvider`

#### Squad Dispatch Key Actions

- squad 배정 변경
- blocker 표시
- squad 상세 열기

### 5. Reports

#### Reports Widget Tree

- `ReportsScreen`
  - `ReportFilterBar`
  - `ReportListPane`
  - `ReportViewerPane`

- `ReportViewerPane`
  - `ReportMetaHeader`
  - `ReportSummaryCard`
  - `FindingsSection`
  - `BlockersSection`
  - `RecommendationSection`
  - `LinkedArtifactsSection`

#### Reports State Sources

- `reportFiltersProvider`
- `reportListProvider`
- `selectedReportProvider`

#### Reports Key Actions

- 보고서 비교
- PDF/export
- order 연결

### 6. Mozzy Product Board

#### Mozzy Product Board Widget Tree

- `MozzyProductBoardScreen`
  - `BranchComparisonHeader`
  - `VersionStatusCards`
  - `ProductReportPanel`
  - `EngineeringReportPanel`
  - `MergeReadinessCard`
  - `OpenQuestionsPanel`

- `VersionStatusCards`
  - `VersionCard(v1)`
  - `VersionCard(v2)`

#### Mozzy Product Board State Sources

- `mozzyBranchStatusProvider`
- `mozzyProductReportsProvider`
- `mozzyEngineeringReportsProvider`
- `mergeReadinessProvider`

#### Mozzy Product Board Key Actions

- V1/V2 비교 보기
- blocker drill-down
- 보고서 생성 요청

### 7. Approval Gates

#### Approval Gates Widget Tree

- `ApprovalGatesScreen`
  - `ApprovalQueueHeader`
  - `GateTypeTabs`
  - `ApprovalRequestList`
  - `ApprovalDecisionPane`

- `ApprovalDecisionPane`
  - `ApprovalMetaCard`
  - `ImpactSummaryCard`
  - `ApproveRejectControls`
  - `ApprovalHistoryTimeline`

#### Approval Gates State Sources

- `approvalQueueProvider`
- `selectedApprovalProvider`

#### Approval Gates Key Actions

- 승인
- 보류
- 반려
- 코멘트 추가

### 8. Channel Center

#### Channel Center Widget Tree

- `ChannelCenterScreen`
  - `ChannelStatusHeader`
  - `InboundCommandFeed`
  - `CommandParserResultPane`
  - `FailedCommandQueue`
  - `ChannelConfigPanel`

#### Channel Center State Sources

- `channelHealthProvider`
- `inboundCommandsProvider`
- `selectedCommandProvider`
- `failedCommandsProvider`

#### Channel Center Key Actions

- 명령 재처리
- order 변환 승인
- 채널 상태 확인

### 9. Audit Timeline

#### Audit Timeline Widget Tree

- `AuditTimelineScreen`
  - `AuditFilterBar`
  - `AuditEventList`
  - `AuditEventDetail`

#### Audit Timeline State Sources

- `auditFiltersProvider`
- `auditEventsProvider`
- `selectedAuditEventProvider`

#### Audit Timeline Key Actions

- actor별 필터
- order 추적
- approval trace 확인

## Shared Widgets

- `StatusChip`
- `RiskBadge`
- `ConfidenceBadge`
- `OrderStateStepper`
- `BranchTag`
- `ArtifactLinkTile`
- `EmptyStatePanel`
- `SectionCard`
- `CommandComposerSheet`

## State Architecture Suggestion

### Recommended Layers

- `view models / controllers`
- `providers`
- `repositories`
- `services`
- `dto/models`

### Suggested Provider Groups

- auth
- dashboard summary
- work orders
- strategy board
- squads
- reports
- mozzy board
- approvals
- channels
- audit

## Data Contracts

### WorkOrderViewModel

- id
- title
- objective
- state
- priority
- squadId
- riskLevel
- targetProduct
- targetBranch

### ReportViewModel

- id
- orderId
- reportType
- ownerGroup
- summary
- findingsCount
- blockerCount
- createdAt

### MozzyVersionViewModel

- versionLabel
- branchName
- productStatus
- engineeringStatus
- mergeReadiness
- lastReportAt

## First Build Priority

1. `DashboardShell`
2. `ExecutiveHomeScreen`
3. `WorkOrdersScreen`
4. `MozzyProductBoardScreen`
5. `ReportsScreen`
6. `ApprovalGatesScreen`
7. `ChannelCenterScreen`

## Implementation Notes

- Desktop first layout로 설계하고,
  narrow width에서는 2-pane를 1-pane로 축소한다.
- Flutter 공통 위젯을 유지하되,
  channel webhook 처리는 backend에 둔다.
- Mozzy Product Board는
  가장 먼저 작동하는 가치 증명 화면으로 본다.
