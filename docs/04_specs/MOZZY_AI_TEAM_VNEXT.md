# MOZZY_AI_TEAM_VNEXT.md

## Purpose

이 문서는 `Mozzy-ai-team`의 vNext 제품 정의를 고정한다.

`Mozzy-ai-team`은
HNI용 `HNI-auto-company`를
web + channel 기반으로 확장한
14-persona AI agent 협업 control plane이다.

## Product Definition

- HNI CEO가 work order를 발행한다.
- 전략군이 framing을 만들고
  제품군/엔지니어링군/비즈니스군/정보군이
  이를 실행 가능한 흐름으로 전환한다.
- dashboard와 channel이 같은 work order state를 본다.
- 14-agent 조직도는
  단순 장식이 아니라
  assign / dispatch / hold / report jump를 수행하는 control surface다.

## Runtime Layers

### Flutter Control Plane

- desktop + web 공통 UI
- home / squads / orders / reports / approvals / channels / audit
- 14-agent control panel

### Dart Backend

- work order state
- approval gates
- report / audit accumulation
- Telegram ingress
- Python AI service broker

### Python Gemini Orchestrator

- same-repo service
- `services/hni_gemini_orchestrator/`
- Gemini key는 여기서만 사용
- stage-run과 agent-graph API 제공

## Delivery Priority

1. README + 제품 기준선 재정렬
2. same-repo Gemini orchestrator skeleton
3. Dart backend broker + agent graph API
4. Flutter control panel 승격
5. web route/auth/session implementation
6. auth/provider hardening

## References

- web backlog:
  [HNI_AI_WEB_IMPLEMENTATION_BACKLOG.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_IMPLEMENTATION_BACKLOG.md)
- route spec:
  [HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md)
- auth/session:
  [HNI_AI_AUTH_SESSION_API_CONTRACT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_SESSION_API_CONTRACT.md)
