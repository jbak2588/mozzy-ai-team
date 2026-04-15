# EXECUTION_PLAN.md

## Status

APPROVED

## Request Title

Humantric Net Indonesia용 Auto-Company 평가 및
Mozzy 14-Agent 운영체계 설계 및
HNI auto-company 최소 실행 MVP 구현 및
backend-connected v1.1 완성과
실채널 연동 1차 설계 및
Telegram 실연동 v1.2 구현 및
대시보드 14-agent 가시화 및
Telegram polling mode 구현 및
Telegram public webhook 배포 아티팩트 준비 및
`bling` 병렬 제어/landing-domain 적합성 검토 및
`ai.humantric.net` 분리 아키텍처 설계 및
future web dashboard route 구조 설계 및
route별 auth gate / role matrix 설계 및
repository mode selection 설계 및
auth provider / OIDC 설계 및
auth provider 후보 비교와 선택 기준 설계 및
future web dashboard wireframe 구조 설계 및
auth provider별 integration sequence 설계 및
future web dashboard component map 설계 및
future web dashboard implementation backlog 설계 및
auth/session API contract 세분화 및
Mozzy-ai-team vNext 제품 정의 / README 전면 재구성 및
same-repo Gemini orchestrator skeleton 구현 및
Dart backend AI broker / agent graph 구현 및
14-agent control panel 승격 및
Flutter web-safe bootstrap 정리 및
future web dashboard route-driven shell 1차 구현 및
same-origin auth/session bootstrap 1차 구현 및
business API role enforcement 1차 구현 및
same-origin login-first bootstrap 강화 및
OIDC/provider adapter 1차 구현

## Objective

`xiaoq17/nicepkg-auto-company`를 평가하고,
하이퍼로컬 커뮤니티 슈퍼앱 Mozzy
(`jbak2588/bling`)에 맞는
통제형 14개 AI 에이전트 운영모델을 설계한다.
또한 HNI 전용 Flutter 기반 운영 프로그램과
채널/대시보드 구조를 정의한다.
이어 Mozzy V1/V2 제품군과
엔지니어링군의 실제 현황 보고서 초안을 작성한다.
이어 V1/V2 merge blocker checklist를 정리한다.
이어 core smoke verification plan을 정리한다.
이어 V1 baseline feature 표를 정리한다.
이어 V2 first merge slice를 정의한다.
이어 neighborhood read slice용
세부 smoke checklist를 작성한다.
이어 HNI auto-company 최소 실행 MVP를 구현한다.
이어 backend-connected v1.1 MVP를 완성한다.
이어 실채널 연동 1차 설계를 정리한다.
이어 Telegram 실연동 v1.2를 구현한다.
이어 Telegram 연결 확인 절차를 정리하고
대시보드에 14-agent를 표시한다.
이어 public webhook 없이도
로컬 검증 가능한 Telegram polling mode를 구현한다.
이어 public domain webhook mode용
nginx/systemd/env/script/deploy guide를
placeholder 기반으로 준비한다.
이어 `bling` sibling repo를
현재 HNI MVP가 병렬 제어할 수 있는지와,
`public/index.html` 기반 landing 구조에
Telegram용 내부 도메인 연결 여지가 있는지 검토한다.
이어 `humantric.net` landing과
`ai.humantric.net` control/backend를 분리하는
권장 아키텍처를 설계한다.
이어 `ai.humantric.net` 아래의
dashboard/auth/api/webhook namespace를
충돌 없이 운영할 route 구조로 설계한다.
이어 future dashboard route마다
필요 role, auth gate, redirect 규칙을
role matrix 형태로 설계한다.
이어 `apiBaseUrl.isEmpty` 분기로 대표되는
repository mode selection 구조를
현재/future runtime 기준으로 설계한다.
이어 future web dashboard의
human auth provider, OIDC flow,
session 정책을 설계한다.
이어 candidate auth provider를
공식 문서 기준으로 비교하고,
HNI용 선택 기준과 provisional recommendation을 정리한다.
이어 route/auth/session 기준을 바탕으로
future web dashboard의
화면별 wireframe 구조를 설계한다.
이어 shortlisted auth provider마다
app registration, callback, logout,
claim mapping, session issue 순서의
integration sequence를 정리한다.
이어 route와 wireframe을 바탕으로
future web dashboard를
구현 단위 component map으로 세분화한다.
이어 route, auth, component map을 바탕으로
future web dashboard의
구현 우선순위 backlog를 정리한다.
이어 same-origin control plane 기준의
auth/session API contract를
browser route, session endpoint, cookie, error 형식까지 세분화한다.
이어 `Mozzy-ai-team`을
HNI용 14-persona AI agent 협업 control plane으로 재정의하고,
루트 `README.md`를 제품/아키텍처/로드맵/문서 허브로 전면 재구성한다.
이어 `geminiclaw`의 server-side env 패턴을 참조해
same-repo Python Gemini orchestrator skeleton을 추가한다.
이어 Dart backend가
`HNI_AI_ORCHESTRATOR_BASE_URL`을 통해
Python AI service와 통신하도록 broker와 stage-run 연동을 구현한다.
이어 `agent graph`와
interactive 14-agent control panel을
현재 Flutter 앱에 반영한다.
이어 Flutter app이
desktop뿐 아니라 web target에서도
same-origin/`API_BASE_URL` 기준으로 기동 가능하도록
web-safe repository bootstrap을 정리한다.
이어 Flutter web에서
`/dashboard/*`와 `/auth/*`를 직접 열 수 있는
route-driven shell 1차 구현을 추가한다.
이어 same-origin backend 기준의
`/api/v1/session`,
`/api/v1/session/bootstrap`,
`/api/v1/session/logout`
bootstrap과 web route gate를
provider 없는 1차 auth slice로 구현한다.
이어 same-origin session과 role matrix를 기준으로
selected business API에
Operator/Lead/Approver/Admin 최소 권한과
CSRF 검증을 단계적으로 연결한다.
같은 기준으로
dashboard action button도 role별로 비활성화한다.
이어 same-origin bootstrap 기본값을
anonymous + explicit login-first로 재정렬하고,
비로그인 remote web shell에서도
앱이 안전하게 기동되도록
empty remote shell / reconnect 흐름을 추가한다.
이어 backend에
`/auth/login`, `/auth/callback`, `/auth/logout`
browser auth route와
provider adapter abstraction을 추가한다.
현재 adapter 범위는
`bootstrap`과 `mock_oidc`까지로 제한하고,
실제 external provider token exchange는
후속 단계로 둔다.

## In Scope

- `auto-company` 리포지토리 구조 평가
- 14개 AI agent 구성 분석
- Mozzy/bling 현재 제품 구조와의 적합성 검토
- Humantric Net Indonesia용 14-agent 역할맵 설계
- 승인 기반 운영계획 초안 작성
- HNI 전용 Flutter 운영 프로그램 정의
- Windows/macOS 공통 대시보드 설계
- WhatsApp/Telegram 작업 지시 채널 설계
- Mozzy V1/V2 제품군 실제 초안 보고서 작성
- Mozzy V1/V2 엔지니어링군 실제 초안 보고서 작성
- Mozzy V1/V2 merge blocker checklist 작성
- Mozzy core smoke verification plan 작성
- Mozzy V1 baseline feature 표 작성
- Mozzy V2 first merge slice 정의
- Mozzy neighborhood read slice 세부 smoke checklist 작성
- HNI auto-company 최소 실행 MVP 구현
- HNI auto-company backend-connected v1.1 MVP 구현
- 실채널 연동 1차 설계 문서화
- Telegram command channel 실연동 구현
- Telegram webhook/status helper 및 reply path 구현
- Telegram 연결 확인 절차 정리
- HNI 대시보드 14-agent board 구현
- Telegram polling intake mode 구현
- Telegram poll-once helper 및 polling status 반영
- Telegram public webhook 배포 아티팩트 준비
- Telegram public webhook용 nginx reverse proxy 예제 작성
- Telegram public webhook용 systemd service 예제 작성
- Telegram public webhook용 placeholder env 예제 작성
- Telegram public webhook용 helper script 작성
- Telegram public webhook 배포 가이드 작성
- `bling` sibling repo 병렬 제어 가능성 검토
- `bling` landing/public hosting의 Telegram 도메인 연결 적합성 검토
- `ai.humantric.net` 분리 아키텍처 설계
- future `ai.humantric.net` web dashboard route 구조 설계
- route별 auth gate / role matrix 설계
- repository mode selection 설계
- auth provider / OIDC 설계
- auth provider 후보 비교와 선택 기준 설계
- future web dashboard wireframe 구조 설계
- auth provider별 integration sequence 설계
- future web dashboard component map 설계
- future web dashboard implementation backlog 설계
- auth/session API contract 세분화
- `Mozzy-ai-team` vNext 제품 정의 문서화
- 루트 `README.md`의 제품 허브형 재작성
- same-repo Python Gemini orchestrator skeleton 구현
- Dart backend AI orchestrator broker 구현
- backend `agent graph` API 구현
- 14-agent interactive control panel 구현
- Flutter web-safe bootstrap 정리
- future web dashboard route-driven shell 1차 구현
- same-origin auth/session bootstrap 1차 구현
- business API role enforcement 1차 구현
- same-origin login-first bootstrap 강화
- OIDC/provider adapter 1차 구현

## Out of Scope

- `bling` 앱 코드 수정
- Claude/Code/Codex의 자율 루프 즉시 도입
- 배포, 프로덕션 반영, 권한 우회 설정 적용
- 보안/개인정보/결제 로직 변경
- 실제 Telegram/WhatsApp production webhook 개통
- 실제 WhatsApp live command 구현
- 실제 Gemini production key 운영 전환
- 실제 OIDC provider production 연결

## Deliverables

1. `docs/04_specs/AUTO_COMPANY_EVALUATION.md`
2. `docs/04_specs/PROJECT_SCOPE.md`
3. `docs/04_specs/ROLE_MAP.md`
4. `docs/01_plans/TASK_QUEUE.md`
5. `docs/02_memory/CONSENSUS.md`
6. `docs/03_logs/SESSION_LOG.md`
7. `docs/04_specs/PILOT_SQUADS.md`
8. `docs/04_specs/ADOPTION_ROADMAP.md`
9. `docs/04_specs/HNI_AUTO_COMPANY_PROGRAM.md`
10. `docs/04_specs/HNI_DASHBOARD_CHANNELS.md`
11. `docs/05_templates/MOZZY_PRODUCT_REPORT_TEMPLATE.md`
12. `docs/05_templates/MOZZY_ENGINEERING_REPORT_TEMPLATE.md`
13. `docs/04_specs/HNI_DASHBOARD_FLUTTER_IA.md`
14. `docs/06_reports/MOZZY_V1_PRODUCT_REPORT_DRAFT.md`
15. `docs/06_reports/MOZZY_V2_PRODUCT_REPORT_DRAFT.md`
16. `docs/06_reports/MOZZY_V1_ENGINEERING_REPORT_DRAFT.md`
17. `docs/06_reports/MOZZY_V2_ENGINEERING_REPORT_DRAFT.md`
18. `docs/06_reports/MOZZY_V1_V2_MERGE_BLOCKER_CHECKLIST.md`
19. `docs/06_reports/MOZZY_CORE_SMOKE_VERIFICATION_PLAN.md`
20. `docs/06_reports/MOZZY_V1_BASELINE_FEATURE_TABLE.md`
21. `docs/06_reports/MOZZY_V2_FIRST_MERGE_SLICE.md`
22. `docs/06_reports/MOZZY_NEIGHBORHOOD_READ_SLICE_SMOKE_CHECKLIST.md`
23. `docs/04_specs/HNI_AUTO_COMPANY_MVP_SCOPE.md`
24. `hni_auto_company_mvp/`
25. `docs/04_specs/HNI_AUTO_COMPANY_V11_SCOPE.md`
26. `docs/04_specs/HNI_CHANNEL_LIVE_INTEGRATION_PHASE1.md`
27. `docs/04_specs/HNI_TELEGRAM_V12_SCOPE.md`
28. `hni_auto_company_mvp/lib/src/telegram_integration.dart`
29. `hni_auto_company_mvp/deploy/nginx/ai.humantric.net.conf`
30. `hni_auto_company_mvp/deploy/systemd/hni-auto-company-backend.service`
31. `hni_auto_company_mvp/deploy/env/telegram_public.example.env`
32. `hni_auto_company_mvp/deploy/scripts/set_telegram_webhook.sh`
33. `hni_auto_company_mvp/deploy/scripts/delete_telegram_webhook.sh`
34. `hni_auto_company_mvp/deploy/scripts/check_telegram_status.sh`
35. `hni_auto_company_mvp/docs/TELEGRAM_PUBLIC_WEBHOOK_DEPLOY.md`
36. `docs/04_specs/HNI_AI_SUBDOMAIN_ARCHITECTURE.md`
37. `docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md`
38. `docs/04_specs/HNI_AI_WEB_DASHBOARD_AUTH_MATRIX.md`
39. `docs/04_specs/HNI_REPOSITORY_MODE_SELECTION.md`
40. `docs/04_specs/HNI_AI_AUTH_OIDC_DESIGN.md`
41. `docs/04_specs/HNI_AI_AUTH_PROVIDER_COMPARISON.md`
42. `docs/04_specs/HNI_AI_WEB_DASHBOARD_WIREFRAMES.md`
43. `docs/04_specs/HNI_AI_AUTH_PROVIDER_INTEGRATION_SEQUENCES.md`
44. `docs/04_specs/HNI_AI_WEB_DASHBOARD_COMPONENT_MAP.md`
45. `docs/04_specs/HNI_AI_WEB_IMPLEMENTATION_BACKLOG.md`
46. `docs/04_specs/HNI_AI_AUTH_SESSION_API_CONTRACT.md`
47. `docs/04_specs/MOZZY_AI_TEAM_VNEXT.md`
48. `docs/04_specs/HNI_GEMINI_ORCHESTRATOR_CONTRACT.md`
49. `services/hni_gemini_orchestrator/`
50. `README.md`

## Execution Sequence

1. `auto-company` 구조와 14-agent 구성을 분석한다.
2. `bling` 제품/기술 맥락을 요약한다.
3. 적용 가능한 요소와 금지할 요소를 분리한다.
4. Humantric용 14-agent 역할맵을 재설계한다.
5. Mozzy pilot squad 구성을 설계한다.
6. Humantric용 도입 로드맵과 승인 게이트를 정리한다.
7. HNI 전용 프로그램 구조와 work order 흐름을 정의한다.
8. Flutter 대시보드와 채널 인터페이스를 정의한다.
9. Mozzy V1/V2 제품군/엔지니어링군 보고서 템플릿을 만든다.
10. HNI 대시보드의 Flutter 위젯 단위 IA/spec을 세분화한다.
11. `main`과 `hyperlocal-proposal`의 실제 근거를 바탕으로
    Mozzy V1/V2 제품군 보고서 초안을 작성한다.
12. `main`과 `hyperlocal-proposal`의 실제 근거를 바탕으로
    Mozzy V1/V2 엔지니어링군 보고서 초안을 작성한다.
13. 제품군/엔지니어링군 초안을 바탕으로
    Mozzy V1/V2 merge blocker checklist를 작성한다.
14. merge blocker checklist를 바탕으로
    Mozzy core smoke verification plan을 작성한다.
15. V1 제품 보고서와 core smoke plan을 바탕으로
    Mozzy V1 baseline feature 표를 작성한다.
16. V2 제품/엔지니어링 초안과
    merge blocker checklist를 바탕으로
    Mozzy V2 first merge slice를 정의한다.
17. V2 first merge slice를 바탕으로
    neighborhood read slice 세부 smoke checklist를 작성한다.
18. HNI auto-company 설계를 바탕으로
    최소 실행 MVP를 실제 Flutter 데스크톱 앱으로 구현한다.
19. 로컬 실행 MVP를 바탕으로
    로컬 HTTP backend + Flutter client 연결의
    backend-connected v1.1 MVP를 구현한다.
20. backend-connected v1.1 구조를 바탕으로
    Telegram/WhatsApp 실채널 연동 1차 설계를 문서화한다.
21. 실채널 연동 설계를 바탕으로
    Telegram 실연동 범위와 비프로덕션 제약을 문서화한다.
22. backend에
    Telegram webhook ingress, sender policy,
    status helper, reply dispatch를 구현한다.
23. Telegram 실연동 구현 결과를
    테스트와 analyze 기준으로 검증하고
    운영 문서에 반영한다.
24. Telegram 연결 확인 기준을
    README와 운영 응답 기준으로 정리하고,
    Home dashboard에 14-agent board를 반영한다.
25. public webhook 없이도
    Telegram direct message를 backend로 intake할 수 있도록
    polling mode와 poll-once helper를 구현한다.
26. production action 없이도
    public domain webhook 배포를 준비할 수 있도록
    nginx/systemd/env/script/documentation 아티팩트를 만든다.
27. `bling` landing 검토 결과를 바탕으로
    `humantric.net`과 `ai.humantric.net`의
    역할 분리 아키텍처를 설계한다.
28. HNI dashboard IA를 바탕으로
    `ai.humantric.net`의 dashboard/auth/api/webhook route 구조를 설계한다.
29. route 구조를 바탕으로
    route별 auth gate와 role matrix를 설계한다.
30. 현재 `API_BASE_URL` 분기를 바탕으로
    repository mode selection과 future bootstrap 확장 원칙을 설계한다.
31. `Mozzy-ai-team`의 vNext 제품 정의와
    Gemini/orchestrator/web/channel 구조를
    루트 README와 spec 문서 기준으로 재정렬한다.
32. same-repo Python Gemini orchestrator skeleton과
    `.env.example`/README/tests를 추가한다.
33. Dart backend에 AI orchestrator broker,
    stage-run fallback, `agent graph` API를 추가한다.
34. Flutter app의 14-agent board를
    assign / dispatch / hold / report jump가 가능한
    control panel로 승격한다.
35. Flutter app이 web target에서도
    remote/same-origin HTTP repository로 기동되도록
    persistence/bootstrap을 정리한다.
36. route/auth matrix를 바탕으로
    auth provider / OIDC / session 설계를 정리한다.
37. OIDC 설계를 바탕으로
    provider 후보 비교와 선택 기준을
    공식 문서 기준으로 정리한다.
38. route/auth/session 원칙과
    기존 Flutter IA를 바탕으로
    future web dashboard wireframe 구조를 설계한다.
39. shortlisted auth provider를 바탕으로
    provider별 integration sequence를 정리한다.
40. route와 wireframe 구조를 바탕으로
    future web dashboard component map을 정리한다.
41. route/auth/component 구조를 바탕으로
    future web dashboard implementation backlog를 정리한다.
42. future auth 설계를 바탕으로
    browser route와 same-origin session endpoint 중심의
    auth/session API contract를 세분화한다.

## Risks

- `auto-company`의 완전자율 철학이 현재 통제형 운영원칙과 충돌한다.
- Mozzy는 Flutter/Firebase 기반 슈퍼앱이라
  일반 SaaS형 agent 설계를 그대로 가져오기 어렵다.
- 위치, 신뢰도, 커뮤니티, 거래, 채팅이 얽혀 있어
  보안/개인정보 리스크가 크다.

## Definition of Done

- `auto-company` 평가 결과가 문서화됨
- 14-agent 역할과 Humantric용 변형안이 명확히 정리됨
- pilot squad 조합과 사용 시점이 문서화됨
- 도입 단계와 승인 게이트가 문서화됨
- HNI 전용 운영 프로그램의 구조가 정의됨
- 대시보드와 채널 인터페이스가 정의됨
- Mozzy V1/V2 보고서 템플릿이 준비됨
- Mozzy V1/V2 제품군 실제 초안 보고서가 준비됨
- Mozzy V1/V2 엔지니어링군 실제 초안 보고서가 준비됨
- Mozzy V1/V2 merge blocker checklist가 준비됨
- Mozzy core smoke verification plan이 준비됨
- Mozzy V1 baseline feature 표가 준비됨
- Mozzy V2 first merge slice가 정의됨
- neighborhood read slice 세부 smoke checklist가 준비됨
- HNI auto-company 최소 실행 MVP가 구현됨
- HNI auto-company backend-connected v1.1 MVP가 구현됨
- 실채널 연동 1차 설계 문서가 준비됨
- Telegram webhook/update/reply 경로가 비프로덕션 기준으로 구현됨
- Telegram token/secret/webhook base URL이 env 기반으로 분리됨
- Telegram 명령 결과가 backend audit와 Telegram reply에 함께 반영됨
- Telegram 연결 확인 절차가 정리됨
- Home dashboard에서 14-agent가 모두 보임
- Telegram polling mode로
  webhook 없이도 non-production roundtrip 검증이 가능함
- Telegram public webhook deployment guide와
  placeholder 기반 배포 파일이 준비됨
- `bling` 병렬 제어 한계와
  landing/domain 연결 조건이 정리됨
- `ai.humantric.net` 분리 아키텍처와
  도메인별 책임 경계가 정리됨
- `ai.humantric.net`의
  future web dashboard route namespace가 정리됨
- future dashboard route별
  auth gate와 role matrix가 정리됨
- repository mode selection과
  bootstrap 확장 원칙이 정리됨
- future web dashboard용
  auth provider / OIDC / session 원칙이 정리됨
- auth provider 후보 비교와
  선택 기준이 정리됨
- future web dashboard용
  wireframe 구조가 정리됨
- shortlisted auth provider별
  integration sequence가 정리됨
- future web dashboard의
  component map이 정리됨
- future web dashboard의
  implementation backlog가 정리됨
- auth/session API contract가 정리됨
- HNI 대시보드의 Flutter 위젯 단위 IA/spec이 정의됨
- 무엇을 도입하고 무엇을 금지할지 구분됨
- 승인된 설계 범위의 문서 패키지가 완성됨

## Planner Decision

- [x] APPROVED
- [ ] REVISE
- [ ] HOLD

## Planner Notes

- 2026-04-09 사용자 승인으로 실행 단계로 전환한다.
- 이번 승인 범위는 운영모델 설계 문서 완성까지다.
- 사용자 추가 요청으로 HNI 전용 프로그램 정의와
  채널/대시보드 설계를 범위에 포함한다.
- 사용자 추가 요청으로 Mozzy V1/V2 보고서 템플릿과
  Flutter IA/spec을 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1/V2 제품군 실제 초안 보고서 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1/V2 엔지니어링군 실제 초안 보고서 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1/V2 merge blocker checklist 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy core smoke verification plan 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1 baseline feature 표 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V2 first merge slice 정의도 범위에 포함한다.
- 사용자 추가 요청으로
  neighborhood read slice 세부 smoke checklist도 범위에 포함한다.
- 사용자 추가 요청으로
  HNI auto-company 최소 실행 MVP 구현도 범위에 포함한다.
- 사용자 추가 요청으로
  backend-connected v1.1 MVP와
  실채널 연동 1차 설계도 범위에 포함한다.
- 사용자 추가 요청으로
  Telegram 실연동 v1.2 구현도 범위에 포함한다.
- 사용자 추가 요청으로
  Telegram 연결 확인 안내와
  대시보드 14-agent 가시화도 범위에 포함한다.
- 2026-04-09 사용자 제공 실 Telegram bot token으로
  비저장 runtime 검증을 수행하되,
  public webhook 등록은
  여전히 별도 승인 전 범위 밖으로 둔다.
- 사용자 추가 요청으로
  Telegram polling mode 구현도 범위에 포함한다.
- 사용자 추가 요청으로
  Telegram polling live roundtrip 직접 검증도 범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  Telegram public webhook 배포 아티팩트와
  배포 가이드 준비도 범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  `bling` 병렬 제어 가능성과
  landing/public hosting 기준의
  Telegram 도메인 연결 적합성 검토도 범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  `ai.humantric.net` 분리 아키텍처 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  future `ai.humantric.net` web dashboard route 구조 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  route별 auth gate / role matrix 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  repository mode selection 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  auth provider / OIDC 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  auth provider 후보 비교와
  선택 기준 설계도 범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  future web dashboard wireframe 구조 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  auth provider별 integration sequence 설계와
  future web dashboard component map 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  future web dashboard implementation backlog 설계도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  auth/session API contract 세분화도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  승인된 vNext 범위 안에서
  future web dashboard의
  route-driven shell 1차 구현도 이어서 반영한다.
- 2026-04-10 사용자 추가 요청으로
  same-origin auth/session bootstrap 1차 구현도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  selected business API role enforcement 1차 구현도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  same-origin login-first bootstrap 강화도
  범위에 포함한다.
- 2026-04-10 사용자 추가 요청으로
  OIDC/provider adapter 1차 구현도
  범위에 포함한다.
- 실제 OIDC/provider 연결과
  production-grade 전면 auth enforcement는
  여전히 범위 밖이다.
- `auto-company`는 참조 아키텍처로만 다룬다.
