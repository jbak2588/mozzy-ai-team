# PILOT_SQUADS.md

## Purpose

Humantric Net Indonesia가 Mozzy에 14-agent 운영모델을 도입할 때
항상 14개를 동시에 쓰지 않고,
작업 유형별 3~5개 pilot squad로 운영하기 위한 기준 문서다.

## Global Rules

- 모든 squad는 승인된 범위 안에서만 동작한다.
- squad는 advisory/implementation support 역할만 가진다.
- 보안, 개인정보, 결제, 배포는 인간 승인 게이트를 통과해야 한다.
- squad 산출물은 관련 문서와 브랜치에 남긴다.

## SQ-01 Discovery Squad

### SQ-01 Use When

- 신규 기능이나 신규 시장 기회를 평가할 때
- Mozzy 기능 우선순위를 다시 정할 때

### SQ-01 Agent Mix

- Strategy Lead
- Market Intelligence Lead
- Risk Auditor
- Product Experience Lead
- Finance & Unit Economics Lead

### SQ-01 Main Outputs

- 문제 정의
- 시장/경쟁 평가
- go / no-go 판단
- 1페이지 우선순위 결정안

### SQ-01 Stop Gate

- 시장 검증이 약할 때
- 수익성 가설이 성립하지 않을 때

## SQ-02 Feature Delivery Squad

### SQ-02 Use When

- 승인된 기능을 실제 설계/구현 단위로 내릴 때
- Flutter/Firebase 기준의 작업 계획을 자를 때

### SQ-02 Agent Mix

- Interaction Flow Lead
- Visual Design Lead
- App Delivery Lead
- Platform Architecture Lead
- Quality Lead

### SQ-02 Main Outputs

- 사용자 플로우
- UI/컴포넌트 방향
- 구현 순서
- 테스트 관점 체크리스트

### SQ-02 Stop Gate

- 구조 변경이 대형 리팩터링으로 번질 때
- 핵심 경로 회귀 위험이 큰데 검증안이 없을 때

## SQ-03 Trust & Readiness Squad

### SQ-03 Use When

- 위치, 신뢰도, 신고, 삭제, 정책, 모더레이션이 관련될 때
- 앱 심사, 정책 대응, 운영 리스크 검토가 필요할 때

### SQ-03 Agent Mix

- Risk Auditor
- Product Experience Lead
- Platform Architecture Lead
- Quality Lead
- Release & Infra Lead

### SQ-03 Main Outputs

- 위험 시나리오
- 정책/운영 체크리스트
- 기술 제약 정리
- release blocker 목록

### SQ-03 Stop Gate

- 개인정보나 결제 영향이 감지될 때
- 운영 정책이 명확하지 않을 때

## SQ-04 Community Growth Squad

### SQ-04 Use When

- 로컬 커뮤니티 활성화 전략을 만들 때
- 지역 피드, 모임, 상점, 친구찾기의 성장 실험을 설계할 때

### SQ-04 Agent Mix

- Community Operations Lead
- Brand & GTM Lead
- Market Intelligence Lead
- Partnership & Monetization Lead
- Strategy Lead

### SQ-04 Main Outputs

- 성장 실험안
- 지역 운영 플레이북
- 포지셔닝 메시지
- 초기 파트너십 가설

### SQ-04 Stop Gate

- 운영 실험이 실제 제품 범위 확장으로 이어질 때
- 지역 운영 리소스 가정이 비현실적일 때

## SQ-05 Release Planning Squad

### SQ-05 Use When

- 출시 후보를 정리할 때
- QA, 문서, 모니터링, 롤백 준비를 묶어 검토할 때

### SQ-05 Agent Mix

- Quality Lead
- Release & Infra Lead
- App Delivery Lead
- Strategy Lead

### SQ-05 Main Outputs

- 출시 준비도 체크리스트
- 리스크/롤백 계획
- known issues 목록
- 출시 보류 또는 진행 권고

### SQ-05 Stop Gate

- 프로덕션 배포 승인 미확정
- 모니터링/롤백 계획 미준비

## Recommended First Use Order

1. SQ-01로 기능/시장 우선순위를 정한다.
2. SQ-02로 승인된 항목을 설계/구현 단위로 내린다.
3. 필요 시 SQ-03로 trust/privacy 리스크를 별도 점검한다.
4. 사용자 확보나 지역 확장이 필요하면 SQ-04를 호출한다.
5. 출시 직전에는 SQ-05로 go / hold 판단을 만든다.
