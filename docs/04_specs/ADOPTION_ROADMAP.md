# ADOPTION_ROADMAP.md

## Goal

Humantric Net Indonesia가 `auto-company`의 장점만 선별해
Mozzy 개발 운영체계에 안전하게 도입하기 위한 단계별 로드맵이다.

## Non-Negotiables

- auto-loop 상시 실행 금지
- `bypassPermissions` 같은 권한 우회 금지
- 프로덕션 반영 전 인간 승인 필수
- 보안, 개인정보, 결제, 배포는 별도 게이트 적용

## Phase 0. Governance Lock

### Phase 0 Objective

완전자율 요소를 차단하고
통제형 운영 문서를 먼저 고정한다.

### Phase 0 Outputs

- 운영 원칙
- 승인 규칙
- 역할맵
- pilot squad 정의

### Phase 0 Exit Condition

- 문서 기준이 팀 내에서 합의됨

## Phase 1. Read-Only Pilot

### Phase 1 Objective

문서와 분석 작업에만 squad를 투입해
운영 방식이 과도하게 흔들리지 않는지 검증한다.

### Phase 1 Allowed Work

- 경쟁 분석
- 제품 평가
- UX/QA 리뷰
- 아키텍처 검토

### Phase 1 Success Metric

- squad 산출물이 실제 의사결정에 도움이 되는가
- 불필요한 자율 행동이 발생하지 않는가

## Phase 2. Non-Destructive Build Pilot

### Phase 2 Objective

승인된 작은 작업에 한해
브랜치 기반 비파괴적 구현 지원을 시험한다.

### Phase 2 Allowed Work

- 문서 생성/정리
- 테스트 코드 추가
- 작은 리팩터링
- UI/플로우 개선안 작성

### Phase 2 Gate

- main 직접 수정 금지
- destructive action 금지
- release action 금지

## Phase 3. Product Lane Rollout

### Phase 3 Objective

Mozzy의 핵심 업무를 squad 단위로 배정하는 운영 루틴을 만든다.

### Phase 3 Suggested Mapping

- 신규 기능 평가: SQ-01
- 승인된 기능 설계/구현: SQ-02
- trust/privacy 검토: SQ-03
- 커뮤니티 성장/파트너십: SQ-04
- 출시 준비/보류 판단: SQ-05

### Phase 3 Gate

- 각 lane의 owner는 인간 책임자여야 한다

## Phase 4. Measured Expansion

### Phase 4 Objective

운영이 안정적일 때만
agent 활용 범위를 넓힌다.

### Phase 4 Consider Only If

- 승인 규칙 위반이 반복되지 않는다
- squad 산출물 품질이 일정하다
- rollback and audit trail이 충분하다

### Phase 4 Still Forbidden

- 무인 자율 루프
- 자동 배포
- 인간 없는 최종결정

## Human Approval Gates

### Gate A. Scope

- 새 epic
- 새 국가
- 대형 구조 변경

### Gate B. Trust

- 위치정보
- 개인정보
- 인증
- 결제
- 신고/제재/삭제 정책

### Gate C. Release

- production deploy
- store submission
- public launch messaging

### Gate D. Destructive Action

- 데이터 삭제
- 강제 마이그레이션
- 되돌리기 어려운 변경

## Recommended First 30 Days

1. SQ-01로 Mozzy 우선순위 기능 3개를 재정렬한다.
2. 그중 1개만 골라 SQ-02 설계 패키지를 만든다.
3. 위치/신뢰/정책 영향이 있으면 SQ-03 리뷰를 붙인다.
4. 출시 직전이 아니면 SQ-05는 문서 점검까지만 수행한다.
5. 모든 단계 결과를 승인 문서와 session log에 남긴다.

## Success Definition

- Humantric가 14-agent를 설명 가능한 구조로 운영한다.
- squad 호출 기준이 명확하다.
- 승인 없는 자율 행동이 없다.
- Mozzy 개발 속도는 올라가되 통제력은 유지된다.
