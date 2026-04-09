# APPROVAL_RULES.md

## Approval Required

The team must request approval in these cases:

1. Initial execution plan approval
2. Scope expansion beyond the approved plan
3. Production deployment or release action
4. Destructive changes
   - deleting data
   - force-replacing important files
   - irreversible migrations
5. Security/auth/payment/privacy changes
6. Large architectural reversal
7. External publishing under founder/company name

## Approval Not Required

The team may continue without extra approval in these cases:

1. Sequential execution inside approved scope
2. Internal task ordering changes
3. Draft refinement of already approved documents
4. Non-destructive refactoring
5. Adding logs, checklists, test notes, or supporting documentation
6. Fixing obvious inconsistencies within approved direction

## Default Behavior

- If ambiguity is small and a safe reversible assumption exists,
  proceed and record it.
- If ambiguity affects scope, money, production, trust, or compliance,
  stop and request approval.

## Documentation Rule

Every approval decision must be reflected in:

- `EXECUTION_PLAN.md`
- `CONSENSUS.md`
- `SESSION_LOG.md`
