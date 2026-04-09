# Mozzy AI Team

이 저장소는 Mozzy 앱 전용 AI Agent 팀의 운영 문서와 실행 규칙을 관리하기 위한 프로젝트입니다.

## 목적

- AI가 무통제 자율주행하지 않도록 통제형 실행 구조를 만든다.
- 최초 실행계획 승인 후에는, 합의된 범위 안에서 최종 단계까지 연속 수행한다.
- 모든 결정, 변경, 작업 이력은 문서로 남긴다.

## 운영 원칙

1. 먼저 실행계획을 작성한다.
2. Planner가 승인하면, 승인 범위 내 작업은 추가 승인 없이 계속 수행한다.
3. 단, 아래 경우에는 다시 승인 요청이 필요하다.
   - 범위 증가
   - 파괴적 변경
   - 운영/배포 반영
   - 결제/보안/인증/개인정보 관련 변경
4. 모든 작업은 TASK_QUEUE, CONSENSUS, SESSION_LOG에 반영한다.

## 핵심 문서

- `AGENTS.md`
- `docs/00_governance/WORKFLOW.md`
- `docs/00_governance/APPROVAL_RULES.md`
- `docs/01_plans/EXECUTION_PLAN.md`
- `docs/01_plans/TASK_QUEUE.md`
- `docs/02_memory/CONSENSUS.md`
- `docs/03_logs/SESSION_LOG.md`

## 시작 순서

1. PROJECT_SCOPE 작성
2. EXECUTION_PLAN 작성
3. Planner 승인
4. TASK_QUEUE 생성
5. 실행 시작
6. SESSION_LOG/CONSENSUS 지속 업데이트
