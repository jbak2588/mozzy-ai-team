# HNI_DASHBOARD_CHANNELS.md

## Purpose

이 문서는 HNI auto-company 프로그램의
대시보드 UI/UX와
WhatsApp/Telegram 작업 지시 채널을 설계한다.

## UX Direction

- CEO가 현재 작업 상태를 한눈에 볼 수 있어야 한다.
- 작업 지시와 결과 보고가 화면 안에서 시각적으로 연결되어야 한다.
- 채널로 들어온 지시도 동일한 work order로 정규화되어야 한다.
- Mozzy V1/V2 상태를 제품군/엔지니어링군 관점에서 비교 가능해야 한다.

## Dashboard Information Architecture

### 1. Executive Home

- 오늘의 active orders
- high-risk orders
- squad별 진행 상태
- 최신 완료 보고
- 승인 대기 건수

### 2. Work Order Center

- 오더 목록
- 상태별 필터
- 우선순위/제품/브랜치 필터
- order detail drawer

### 3. Strategy Board

- `ceo-bezos` 제안
- 전략군 판단
- CEO 코멘트
- 승인/보류/수정 결정

### 4. Squad Dispatch Board

- squad별 담당 주문
- 예상 완료 시점
- blocker 표시
- 담당 페르소나 구성

### 5. Report Viewer

- 분석 보고
- 계획 문서
- 평가 결과
- 수정 요청
- 완료 보고

### 6. Mozzy Product Board

- V1 (`main`) 상태 카드
- V2 (`hyperlocal-proposal`) 상태 카드
- 제품군 보고
- 엔지니어링군 보고
- merge readiness indicator

### 7. Approval Gate Panel

- scope gate
- trust gate
- release gate
- destructive gate

### 8. Channel Center

- Telegram inbound commands
- WhatsApp inbound commands
- command parsing result
- failed command / retry queue

## Visual Components

- lifecycle stepper
- squad swimlane board
- risk heat badge
- branch comparison card
- approval gate chips
- report timeline
- command activity feed

## Primary Screens

### Screen A. CEO Command Screen

- 새 work order 생성
- 채널로 보낼 공지 선택
- 전략군 호출 요청

### Screen B. Order Detail Screen

- 목표
- 범위
- 배정 squad
- 상태 전이
- 관련 보고서
- 승인 기록

### Screen C. Mozzy V1/V2 Review Screen

- 제품군 보고서 요약
- 엔지니어링군 보고서 요약
- 기능 완성도 표시
- merge blocker 목록

## Channel Design

### Telegram

#### Telegram Role

- 1차 명령 채널 우선 후보
- 저마찰 command input
- 운영자/CEO 실시간 지시

#### Telegram Command Examples

- `/new_order`
- `/order_status <id>`
- `/approve <id>`
- `/hold <id>`
- `/report <id>`

#### Telegram Recommended Use

- 긴급 지시
- 상태 조회
- 간단 승인/보류

### WhatsApp

#### WhatsApp Role

- 경영진 친화형 command + notification 채널
- 승인 알림과 요약 보고 전달

#### WhatsApp Recommended Use

- executive notification
- 승인 요청
- 완료 보고 요약
- 제한된 구조형 command

#### WhatsApp Design Note

- WhatsApp은 Telegram보다
  운영/정책 제약이 크므로
  1차 구현은 notification + 제한형 command로 시작하는 것이 안전하다.

## Unified Channel Flow

1. CEO/운영자가 Telegram 또는 WhatsApp에서 명령 전송
2. channel webhook 수신
3. command parser가 표준 work order action으로 변환
4. backend가 order state 또는 order creation 반영
5. Flutter dashboard가 실시간으로 상태 업데이트
6. 결과 요약이 다시 채널과 대시보드에 반영

## Suggested Backend Flow

- Channel Gateway
- Command Parser
- Work Order Service
- Approval Service
- Report Service
- Notification Service

## Recommended Implementation Order

1. Flutter 대시보드 정보구조 먼저 설계
2. Telegram command channel 먼저 연결
3. WhatsApp notification + 제한형 command 추가
4. Mozzy V1/V2 보고서 화면 연결
5. 승인 게이트 시각화 연결

## Mozzy-Specific First Use

가장 먼저 붙이기 좋은 화면은
`Mozzy Product Board`다.

이 보드에서 아래를 먼저 보여준다.

- V1 현재 상태
- V2 현재 상태
- 제품군 보고서
- 엔지니어링군 보고서
- merge readiness

## Technical Note

- Flutter를 사용하면 Windows/macOS 공통 UI를 유지할 수 있다.
- 채널 연동은 Flutter 앱 안에서 직접 처리하기보다
  backend webhook 계층으로 분리하는 편이 안정적이다.
- 대시보드는 orchestration UI,
  채널은 command entry / notification UI로 분리해야 한다.
