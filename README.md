# Mozzy-ai-team

`Mozzy-ai-team`은
HNI용 `HNI-auto-company`를
웹 + 채널 기반으로 확장한
14-persona AI Agent 협업 control plane 프로젝트다.

이 저장소는 단순 운영 문서 보관소가 아니라
다음 네 층을 함께 관리한다.

- Flutter desktop/web control plane
- Dart backend orchestration state
- Telegram channel integration
- same-repo Python Gemini orchestrator

## Mozzy-ai-team이 무엇인가

핵심 목표는
HNI CEO가 work order를 발행하면
전략군, 제품군, 엔지니어링군, 비즈니스군, 정보군이
14개 persona를 바탕으로
`분석 -> 계획 -> 실행 -> 평가 -> 수정 -> 완료 보고`
형식으로 협업하는 시스템을 만드는 것이다.

운영 원칙은 기존과 같다.

- 무통제 자율주행은 허용하지 않는다.
- 승인 후에는 합의된 범위 안에서 연속 실행한다.
- 범위 확장, 배포, 보안/개인정보/결제, destructive action은 별도 승인한다.
- 모든 주요 결정과 이력은 repo 문서에 남긴다.

## 핵심 기능

- Work order lifecycle과 approval gate 운영
- Telegram 기반 command ingress와 dashboard command log
- 14-persona 조직도 기반 squad dispatch
- report / audit / completion summary 누적
- Mozzy V1/V2 상태 추적과 merge-readiness 보드
- Gemini 기반 persona execution runtime 연동

## 시스템 아키텍처

### 1. Flutter Control Plane

- 위치:
  [hni_auto_company_mvp](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp)
- 역할:
  operator dashboard, 14-agent control panel,
  orders/reports/approvals/channels/audit UI
- 방향:
  desktop 우선 구현을 유지하면서 Flutter Web로 확장

### 2. Dart Backend

- 위치:
  [server.dart](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/bin/server.dart)
- 역할:
  authoritative work order state, approval gates,
  Telegram ingress, report/audit accumulation
- 추가된 경계:
  Python AI service broker와 agent graph API

### 3. Python Gemini Orchestrator

- 위치:
  [services/hni_gemini_orchestrator](/Users/jbak2588/mozzy-ai-team/services/hni_gemini_orchestrator)
- 역할:
  Gemini 기반 stage-run 생성, 14-agent graph 상태 제공
- 원칙:
  `GEMINI_API_KEY`는 이 서비스 env에만 저장하고
  Flutter client와 Dart backend에는 노출하지 않음

### 4. Channel Layer

- 1차 command 채널:
  Telegram
- WhatsApp:
  notification + 제한형 command는 후속 범위
- public webhook 운영은
  `ai.humantric.net` 기준 reverse proxy 뒤 private backend 전제를 유지

## 14 Persona 운영 모델

### Strategy

- `ceo-bezos`
- `cto-vogels`
- `critic-munger`

### Product

- `product-norman`
- `ui-duarte`
- `interaction-cooper`

### Engineering

- `fullstack-dhh`
- `qa-bach`
- `devops-hightower`

### Business

- `marketing-godin`
- `operations-pg`
- `sales-ross`
- `cfo-campbell`

### Intelligence

- `research-thompson`

이 14개는 항상 동시에 실행되는 것이 아니라
work order별로 squad 형태로 묶여 동작한다.

## 조직도 대시보드

`Mozzy-ai-team`의 14-agent 조직도는
단순 리스트가 아니라 control panel이다.

현재/목표 기능:

- persona별 상태 확인
- selected order 기준 lead 지정
- selected order 기준 dispatch trigger
- hold / resume
- latest report jump
- audit trail jump

관련 구현 기준:

- [MOZZY_AI_TEAM_VNEXT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/MOZZY_AI_TEAM_VNEXT.md)
- [HNI_AI_WEB_DASHBOARD_WIREFRAMES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_WIREFRAMES.md)
- [HNI_AI_WEB_DASHBOARD_COMPONENT_MAP.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_COMPONENT_MAP.md)

## AI 연동 방식

1차 AI provider는 Gemini 단일 엔진이다.

참조 기준은
[`jbak2588/geminiclaw`](https://github.com/jbak2588/geminiclaw)
의 server-side env 패턴이며,
이 저장소에서는 같은 원칙만 가져온다.

- `GEMINI_API_KEY`는 Python orchestrator env에만 둔다
- Dart backend는 `HNI_AI_ORCHESTRATOR_BASE_URL`만 사용한다
- Flutter client에는 API key를 전달하지 않는다
- tracked 파일에는 실제 key를 커밋하지 않는다

계약 문서:

- [HNI_GEMINI_ORCHESTRATOR_CONTRACT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_GEMINI_ORCHESTRATOR_CONTRACT.md)

## 현재 구현 상태

이미 구현된 범위:

- HNI auto-company desktop MVP
- local JSON mode + backend-connected mode
- Telegram live integration
- Telegram polling mode
- public webhook deployment artifacts
- `ai.humantric.net` 분리 아키텍처 설계
- web route/auth/session/backlog/spec 문서 세트
- same-repo Gemini orchestrator skeleton
- backend agent graph / control panel 연동

아직 후속 구현이 남은 범위:

- Flutter Web route/auth/session 본 구현
- OIDC provider 실제 연결
- Telegram -> stage dispatch -> report update end-to-end hardening
- Mozzy board의 web slice 확대

## 개발 로드맵

### Phase 0

- 제품 정의와 계획 기준 재정렬
- README 재구성
- repo 문서 허브 정리

### Phase 1

- Flutter control plane 기준선 정리
- 14-agent control panel 고도화
- backend API와 report/audit 흐름 정합화

### Phase 2

- same-repo Python Gemini orchestrator skeleton
- Dart backend broker 연동
- stage-run / agent-graph contract 고정

### Phase 3

- web target bootstrap
- shell/auth/session/home/orders/approvals/channels 순 구현
- `ai.humantric.net` 기준 operator dashboard 오픈

### Phase 4

- OIDC provider 실제 연결
- observability / retry / hardening
- Telegram command -> report update end-to-end 검증

## 문서 허브

거버넌스:

- [AGENTS.md](/Users/jbak2588/mozzy-ai-team/AGENTS.md)
- [WORKFLOW.md](/Users/jbak2588/mozzy-ai-team/docs/00_governance/WORKFLOW.md)
- [APPROVAL_RULES.md](/Users/jbak2588/mozzy-ai-team/docs/00_governance/APPROVAL_RULES.md)
- [EXECUTION_PLAN.md](/Users/jbak2588/mozzy-ai-team/docs/01_plans/EXECUTION_PLAN.md)
- [TASK_QUEUE.md](/Users/jbak2588/mozzy-ai-team/docs/01_plans/TASK_QUEUE.md)
- [CONSENSUS.md](/Users/jbak2588/mozzy-ai-team/docs/02_memory/CONSENSUS.md)
- [SESSION_LOG.md](/Users/jbak2588/mozzy-ai-team/docs/03_logs/SESSION_LOG.md)

웹/인증/대시보드:

- [HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md)
- [HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md)
- [HNI_AI_AUTH_OIDC_DESIGN.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_OIDC_DESIGN.md)
- [HNI_AI_AUTH_SESSION_API_CONTRACT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_SESSION_API_CONTRACT.md)
- [HNI_AI_WEB_IMPLEMENTATION_BACKLOG.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_IMPLEMENTATION_BACKLOG.md)

운영 프로그램/채널:

- [HNI_AUTO_COMPANY_PROGRAM.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AUTO_COMPANY_PROGRAM.md)
- [HNI_DASHBOARD_CHANNELS.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_DASHBOARD_CHANNELS.md)
- [HNI_TELEGRAM_V12_SCOPE.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_TELEGRAM_V12_SCOPE.md)
- [TELEGRAM_PUBLIC_WEBHOOK_DEPLOY.md](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/docs/TELEGRAM_PUBLIC_WEBHOOK_DEPLOY.md)

제품 방향:

- [MOZZY_AI_TEAM_VNEXT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/MOZZY_AI_TEAM_VNEXT.md)
- [HNI_AI_SUBDOMAIN_ARCHITECTURE.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_SUBDOMAIN_ARCHITECTURE.md)
- [HNI_GEMINI_ORCHESTRATOR_CONTRACT.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_GEMINI_ORCHESTRATOR_CONTRACT.md)

## 로컬 개발 시작

### Flutter UI 실행

```bash
cd hni_auto_company_mvp
flutter pub get
flutter run -d macos
```

web/backend 연결 기준 실행:

```bash
cd hni_auto_company_mvp
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8787
```

### Dart backend 실행

```bash
cd hni_auto_company_mvp
dart run bin/server.dart
```

Gemini orchestrator를 함께 붙일 때:

```bash
export HNI_AI_ORCHESTRATOR_BASE_URL=http://127.0.0.1:8091
cd hni_auto_company_mvp
dart run bin/server.dart
```

### Python Gemini orchestrator 실행

```bash
cd services/hni_gemini_orchestrator
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export GEMINI_API_KEY=your_key
uvicorn app.main:app --host 127.0.0.1 --port 8091 --reload
```

## 검증 기준

- `flutter analyze`
- `flutter test`
- `flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8787`
- `python3 -m pytest services/hni_gemini_orchestrator/tests`
- `npx --yes markdownlint-cli@0.40.0 '**/*.md'`

## Important Notes

- repo 문서가 여전히 system of record다
- GitHub는 PR/release/code review 보조 채널이다
- 실 Telegram/WhatsApp production 개통과 auth provider 실운영 연결은 별도 승인 범위다
