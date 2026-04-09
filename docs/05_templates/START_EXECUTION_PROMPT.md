# START_EXECUTION_PROMPT.md

새 Codex/VS Code 세션을 시작할 때 아래 프롬프트를 그대로 사용한다.

```md
Read these files first and follow them strictly:

- AGENTS.md
- docs/00_governance/WORKFLOW.md
- docs/00_governance/APPROVAL_RULES.md
- docs/01_plans/EXECUTION_PLAN.md
- docs/01_plans/TASK_QUEUE.md
- docs/02_memory/CONSENSUS.md
- docs/03_logs/SESSION_LOG.md

Operating rule:
Do not act as a free autonomous agent.
If EXECUTION_PLAN is not approved, refine the plan only.
If EXECUTION_PLAN is approved, continue task-by-task
until the approved final execution scope is completed.
Do not ask for next-step approval after every task.
Pause only if scope expansion, destructive change, production action,
or security/privacy/payment risk appears.

Now:
1. verify current document state,
2. update TASK_QUEUE,
3. continue the next approved task,
4. write the result into CONSENSUS and SESSION_LOG.
```

## Usage Note

- 새 세션 시작 직후 이 프롬프트를 먼저 전달한다.
- 추가 스펙 맥락이 필요하면
  `docs/04_specs/PROJECT_SCOPE.md`와
  `docs/04_specs/ROLE_MAP.md`를 이어서 읽힌다.
