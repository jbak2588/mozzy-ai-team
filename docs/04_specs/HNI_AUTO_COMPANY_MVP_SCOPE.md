# HNI Auto-Company MVP Scope

## Goal

이 문서는
`hni_auto_company_mvp/`에서 구현할
HNI auto-company 최소 실행 MVP 범위를 고정한다.

## Core User Promise

- HNI CEO가 work order를 생성할 수 있다.
- 실행계획을 검토하고 승인할 수 있다.
- 승인 후에는
  다음 단계 진행 승인을 반복 요청하지 않고
  합의된 stage를 끝까지 순차 실행한다.
- 결과는 dashboard와 report timeline에서 확인할 수 있다.

## MVP In Scope

- Flutter Windows/macOS 데스크톱 앱
- 로컬 persistent state
- work order 생성
- strategy/plan summary 표시
- plan approval action
- approval 이후 자동 stage 실행
- stage별 artifact/report 생성
- completion report 생성
- approval gate 목록 표시
- Telegram/WhatsApp 형식의 local command simulator
- audit timeline

## MVP Out of Scope

- 실제 Telegram webhook
- 실제 WhatsApp Cloud API
- multi-user auth
- remote backend
- real AI inference
- GitHub live sync
- production deploy
- billing/privacy/security workflow 자동화

## Minimal Execution Stages

1. `Strategic Review`
2. `Planned`
3. `In Progress`
4. `Evaluation`
5. `Revise`
6. `Completed`

## MVP Success Criteria

- 새 order를 만들 수 있다.
- approval 전에는 auto-run이 시작되지 않는다.
- approval 후에는
  상태가 stage 순서대로 자동 진행된다.
- 진행 중 stage별 report가 누적된다.
- 완료 시 completion report가 생성된다.
- 앱 재실행 후에도 저장 상태를 다시 읽을 수 있다.

## Architecture Shape

- local repository:
  JSON persistence
- application controller:
  state machine + runner
- presentation:
  dashboard, orders, reports, approvals, channels
- simulation:
  command parser for Telegram/WhatsApp-like input

## Current Implementation Snapshot

- app entry:
  `hni_auto_company_mvp/lib/main.dart`
- orchestration engine:
  `hni_auto_company_mvp/lib/src/store.dart`
- order/state models:
  `hni_auto_company_mvp/lib/src/models.dart`
- local persistence:
  `hni_auto_company_mvp/lib/src/persistence.dart`
- channel command parser:
  `hni_auto_company_mvp/lib/src/command_parser.dart`
- dashboard UI:
  `hni_auto_company_mvp/lib/src/app.dart`
- verification:
  `hni_auto_company_mvp/test/command_parser_test.dart`,
  `hni_auto_company_mvp/test/store_test.dart`
