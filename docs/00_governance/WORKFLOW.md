# WORKFLOW.md

## Standard Workflow

### Phase 1. Intake

- 요청 내용을 읽고 목표를 정리한다.
- 기존 문서와 충돌하는지 확인한다.

### Phase 2. Planning

- 실행계획 초안을 작성한다.
- 범위, 산출물, 완료조건, 위험요소를 명시한다.

### Phase 3. Approval

- Planner가 계획을 수정 또는 승인한다.
- 승인되면 `EXECUTION_PLAN.md` 상태를 `APPROVED`로 표시한다.

### Phase 4. Execution

- 승인 범위 내 작업을 순차 수행한다.
- 각 작업 완료 시 `TASK_QUEUE.md`를 갱신한다.
- 중간 단계마다 “계속할까요?”를 반복하지 않는다.

### Phase 5. Verification

- 산출물, 누락, 위험, 후속 작업을 검토한다.
- 필요 시 수정 반영 후 완료 처리한다.

### Phase 6. Handoff

- 최종 결과 요약
- 변경 파일/문서 목록 정리
- 다음 실행 후보 정리

## Important Rule

Once the execution plan is approved, the team proceeds continuously
until the approved final execution scope is done.

## Stop Conditions

The team must pause and request approval only when:

- approved scope is no longer sufficient,
- destructive action is needed,
- production/system-facing action is needed,
- high-risk security/payment/privacy issue appears.
