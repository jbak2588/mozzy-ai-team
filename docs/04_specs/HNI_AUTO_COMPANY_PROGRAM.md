# HNI_AUTO_COMPANY_PROGRAM.md

## Program Definition

HNI auto-company는
PT Humantric Net Indonesia의 CEO 지휘 아래
14개 전문가 페르소나를 활용해
작업 오더를
`분석 -> 계획 -> 실행 -> 평가 -> 수정 -> 완료 보고`
형식으로 처리하는 전용 운영 프로그램이다.

이 프로그램은 `auto-company`의 완전자율 루프를 복제하지 않는다.
대신 **통제형 work order 운영 시스템**으로 정의한다.

## Core Principles

- 최종 의사결정자는 HNI CEO다.
- `ceo-bezos`는 CEO를 대체하지 않고 전략 수석 보좌 역할을 맡는다.
- 14개 페르소나는 항상 전부 동작하지 않고,
  작업 단위에 맞는 squad로 편성된다.
- 승인 없는 범위 확장, 배포, 보안/개인정보/결제 변경은 금지한다.
- 모든 오더는 기록, 보고, 감사 가능 상태를 유지해야 한다.

## Program Goal

- HNI CEO가 작업 목표를 내릴 수 있어야 한다.
- 전략군이 목표를 해석하고 방향안을 만들 수 있어야 한다.
- 제품군/엔지니어링군/비즈니스군/정보군이
  그 방향안을 따라 일할 수 있어야 한다.
- 결과는 보고서와 상태 그래프로 한눈에 보일 수 있어야 한다.

## Runtime Shape

### Client

- Flutter 기반 HNI 운영 콘솔
- Windows/macOS 공통 코드베이스
- 향후 Web 확장 가능 구조

### Backend

- Mozzy와 같은 Firebase 계열을 우선 후보로 둔다
- Firestore: work orders, squads, reports, audit trail
- Cloud Functions / server runtime:
  channel webhook, command parsing, orchestration helpers
- Firebase Auth or admin auth layer:
  HNI 내부 사용자 접근 제어

### Integrations

- Telegram Bot API
- WhatsApp Cloud API
- GitHub repo links
- Mozzy repo state read model

## Work Order Lifecycle

### Step 1. Order Intake

- HNI CEO가 대시보드 또는 채널에서 작업 지시
- 작업 오더 생성
- 우선순위, 대상 제품, 기대 산출물 입력

### Step 2. Strategic Framing

- `ceo-bezos` 중심 전략군이
  오더를 전략 언어로 재해석
- 목표, 범위, 리스크, 추천 squad를 제안

### Step 3. Squad Dispatch

- 작업 유형에 맞는 squad 배정
- 담당 제품군/엔지니어링군/비즈니스군/정보군 결정

### Step 4. Execution

- 각 squad가 분석, 계획, 실행안을 생산
- 필요 시 승인 게이트 통과 후 다음 단계 진행

### Step 5. Evaluation

- Quality / Risk 관점으로 검토
- blocker, gap, open question 분리

### Step 6. Revision

- 수정 필요 시 work order 상태를 `Revise`로 전환
- 재작업 항목과 재검토 요청을 남김

### Step 7. Completion Report

- 완료 상태, 결과 요약, 남은 리스크,
  다음 액션을 CEO에게 보고

## Standard Work Order States

- `New`
- `Strategic Review`
- `Planned`
- `In Progress`
- `Evaluation`
- `Revise`
- `Completed`
- `Hold`
- `Rejected`

## Standard Entities

### Work Order

- order_id
- title
- requested_by
- target_product
- target_branch
- objective
- scope_in
- scope_out
- risk_level
- squad_assigned
- current_state
- next_action

### Squad Report

- report_id
- order_id
- squad_id
- summary
- findings
- blockers
- recommendations
- files_or_links

### Approval Record

- approval_id
- order_id
- gate_type
- approver
- status
- note
- timestamp

## Mozzy-Specific Use

### Current Best Use

현재 Mozzy는
V1 (`main`)과 V2 (`hyperlocal-proposal`) 사이 차이가 크므로,
당장은 아래와 같은 보고형 오더에 가장 적합하다.

- V1 현재 상태 보고
- V2 현재 상태 보고
- merge blocker 분석
- 기능별 품질/완성도 보고

### Near-Term Work Types

- 제품군: UX/기능 상태 보고서
- 엔지니어링군: 구조/미검증 기능/merge risk 보고서
- 전략군: 어떤 기능부터 검증할지 우선순위 판단

## Recommended First Internal Modules

1. Work Order Center
2. Strategy Decision Board
3. Squad Dispatch Panel
4. Report Viewer
5. Approval Gate Panel
6. Mozzy V1/V2 Status Board
7. Audit Timeline
