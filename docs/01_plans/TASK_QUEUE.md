# TASK_QUEUE.md

| ID | Task | Status | Depends On | Output |
| --- | --- | --- | --- | --- |
| P-001 | `auto-company` 리포 구조 검토 | DONE | - | repo 평가 근거 |
| P-002 | 14개 agent 구성 추출 | DONE | P-001 | agent 분석 메모 |
| P-003 | `bling` 제품/기술 현황 스캔 | DONE | - | 적용 맥락 요약 |
| P-004 | 적합성/갭 분석 작성 | DONE | P-001~P-003 | 평가 문서 |
| P-005 | Humantric용 14-agent 역할맵 재작성 | DONE | P-004 | `ROLE_MAP.md` |
| P-006 | 새 프로젝트 범위/실행계획 초안 작성 | DONE | P-004,P-005 | scope + plan draft |
| P-007 | 구현 승인 여부 결정 | DONE | P-006 | 2026-04-09 approved |
| P-008 | Mozzy pilot squad 설계 | DONE | P-007 | `PILOT_SQUADS.md` |
| P-009 | Humantric 도입 로드맵 작성 | DONE | P-007 | `ADOPTION_ROADMAP.md` |
| P-010 | 승인 후 설계 패키지 검증 | DONE | P-008,P-009 | final doc verification |
| P-011 | HNI 지휘체계 및 V1/V2 보고 단계 검토 | DONE | P-008,P-009 | governance review |
| P-012 | HNI 프로그램 정의 문서 작성 | DONE | P-011 | `HNI_AUTO_COMPANY_PROGRAM.md` |
| P-013 | 대시보드/채널 설계 문서 작성 | DONE | P-012 | `HNI_DASHBOARD_CHANNELS.md` |
| P-014 | 확장 설계 문서 검증 | DONE | P-012,P-013 | final doc verification |
| P-015 | Mozzy 제품 보고서 템플릿 | DONE | P-011 | `PRODUCT_REPORT_TEMPLATE.md` |
| P-016 | Mozzy 엔지니어링 템플릿 | DONE | P-011 | `ENGINEERING_REPORT_TEMPLATE.md` |
| P-017 | HNI 대시보드 Flutter IA | DONE | P-013 | `HNI_DASHBOARD_FLUTTER_IA.md` |
| P-018 | 추가 설계 문서 검증 | DONE | P-015,P-016,P-017 | final doc verification |
| P-019 | Mozzy V1/V2 제품 근거 수집 | DONE | P-015 | branch evidence memo |
| P-020 | Mozzy V1 제품군 보고서 초안 작성 | DONE | P-019 | V1 report draft |
| P-021 | Mozzy V2 제품군 보고서 초안 작성 | DONE | P-019 | V2 report draft |
| P-022 | 제품군 보고서 초안 검증 | DONE | P-020,P-021 | final doc verification |
| P-023 | Mozzy V1/V2 엔지니어링 근거 수집 | DONE | P-016 | eng evidence memo |
| P-024 | Mozzy V1 엔지니어링 보고서 초안 작성 | DONE | P-023 | V1 eng draft |
| P-025 | Mozzy V2 엔지니어링 보고서 초안 작성 | DONE | P-023 | V2 eng draft |
| P-026 | 엔지니어링 보고서 초안 검증 | DONE | P-024,P-025 | final doc verification |
| P-027 | merge blocker 범위 정의 | DONE | P-022,P-026 | checklist scope |
| P-028 | V1/V2 merge blocker checklist 작성 | DONE | P-027 | blocker checklist |
| P-029 | merge blocker checklist 검증 | DONE | P-028 | final doc verification |
| P-030 | core smoke 범위 정의 | DONE | P-029 | smoke scope |
| P-031 | core smoke verification plan 작성 | DONE | P-030 | smoke plan |
| P-032 | core smoke plan 검증 | DONE | P-031 | final doc verification |
| P-033 | V1 baseline feature 표 범위 정의 | DONE | P-031 | baseline scope |
| P-034 | V1 baseline feature 표 작성 | DONE | P-033 | V1 baseline table |
| P-035 | V1 baseline feature 표 검증 | DONE | P-034 | final doc verification |
| P-036 | V2 first merge slice 범위 정의 | DONE | P-029,P-031 | slice scope |
| P-037 | V2 first merge slice 문서 작성 | DONE | P-036 | V2 slice doc |
| P-038 | V2 first merge slice 정합화 검증 | DONE | P-037 | final doc verification |
| P-039 | neighborhood read smoke 범위 정의 | DONE | P-037 | smoke checklist scope |
| P-040 | neighborhood smoke 작성 | DONE | P-039 | nbhd checklist |
| P-041 | neighborhood read smoke 문서 검증 | DONE | P-040 | final doc verification |
| P-042 | HNI MVP 범위 정의 | DONE | P-012,P-013,P-017 | MVP scope |
| P-043 | Flutter MVP 스캐폴드 생성 | DONE | P-042 | desktop app skeleton |
| P-044 | work order 실행 엔진 구현 | DONE | P-043 | execution engine |
| P-045 | dashboard/UI 시뮬레이터 구현 | DONE | P-044 | MVP screens |
| P-046 | MVP 검증 및 문서 반영 | DONE | P-045 | verification + docs |
| P-047 | v1.1 backend 범위 정의 | DONE | P-046 | v1.1 scope |
| P-048 | 로컬 HTTP backend 구현 | DONE | P-047 | backend server |
| P-049 | Flutter client backend 연결 | DONE | P-048 | remote client |
| P-050 | 실채널 1차 설계 문서화 | DONE | P-049 | live channel design |
| P-051 | v1.1 검증 및 문서 반영 | DONE | P-050 | verification + docs |
| P-052 | GitHub 커밋/푸시 반영 | DONE | P-051 | local commit + remote push |
| P-053 | Telegram 실연동 범위 정의 | DONE | P-050,P-051 | Telegram v1.2 scope |
| P-054 | Telegram 실연동 문서 반영 | DONE | P-053 | plan + spec update |
| P-055 | Telegram backend/reply 구현 | DONE | P-054 | webhook + dispatcher |
| P-056 | Telegram 실연동 검증 | DONE | P-055 | analyze + test |
| P-057 | Telegram 작업 기록 반영 | DONE | P-056 | consensus + session log |
| P-058 | 앱 루트 context 예외 수정 | DONE | P-057 | UI context fix |
| P-059 | Telegram 확인/agent board 범위 반영 | DONE | P-058 | plan + IA update |
| P-060 | Home dashboard 14-agent board 구현 | DONE | P-059 | agent visibility UI |
| P-061 | Telegram 안내/agent board 검증 및 기록 | DONE | P-060 | README + logs |
| P-062 | Telegram runtime 상태 점검/안내 | DONE | P-061 | runtime check + guide |
| P-063 | 실 Telegram bot token 유효성 검증 | DONE | P-062 | live bot status |
| P-064 | Telegram 계정 바인딩 가이드 보강 | DONE | P-063 | README + logs |
| P-065 | Telegram 사용자 메시지 live 수신 확인 | DONE | P-064 | sender binding evidence |
| P-066 | Telegram polling 범위 반영 | DONE | P-065 | plan + spec update |
| P-067 | Telegram polling backend 구현 | DONE | P-066 | poll loop + helper |
| P-068 | Telegram polling 검증 및 기록 | DONE | P-067 | tests + logs |
| P-069 | Telegram 로컬 runtime env 적용 | DONE | P-068 | ignored local env |
| P-070 | Telegram polling live roundtrip 검증 | DONE | P-069 | roundtrip proof |
| P-071 | Telegram/polling 변경 GitHub 반영 | DONE | P-070 | commit + push |

## Status Legend

- TODO
- IN_PROGRESS
- DONE
- BLOCKED

## Reset Note

- 2026-04-09 사용자 요청에 따라 작업 큐를 새 목적 기준으로 초기화했다.
- 이전 초기 구축 작업 기록은 `SESSION_LOG.md`에 보존한다.
- 새 계획 문서는 `markdownlint-cli@0.40.0` 전체 검사 기준을 통과했다.
- 2026-04-09 사용자 승인 후 `P-008`~`P-010`을 연속 실행했다.
- 승인 후 추가된 설계 문서도 `markdownlint-cli@0.40.0` 전체 검사 기준을 통과했다.
- HNI CEO -> 전략군 -> 제품/엔지니어링/비즈니스/정보군 흐름이 적합한지 검토했다.
- HNI 전용 프로그램과 채널/대시보드 설계를 범위 확장으로 반영했다.
- `HNI_AUTO_COMPANY_PROGRAM.md`, `HNI_DASHBOARD_CHANNELS.md`도 lint 통과 상태다.
- Mozzy 보고서 템플릿과 HNI Flutter IA/spec도 범위에 반영했다.
- `MOZZY_*_REPORT_TEMPLATE.md`, `HNI_DASHBOARD_FLUTTER_IA.md`도 lint 통과 상태다.
- 2026-04-09 사용자 요청으로
  Mozzy V1/V2 제품군 실제 초안 보고서 작성까지 범위를 확장했다.
- 2026-04-09 사용자 요청으로
  Mozzy V1/V2 엔지니어링군 실제 초안 보고서 작성까지 범위를 확장했다.
- 2026-04-09 사용자 요청으로
  Mozzy V1/V2 merge blocker checklist 작성까지 범위를 확장했다.
- 2026-04-09 사용자 요청으로
  Mozzy core smoke verification plan 작성까지 범위를 확장했다.
- 2026-04-09 사용자 요청으로
  Mozzy V1 baseline feature 표 작성까지 범위를 확장했다.
- 2026-04-09 사용자 요청으로
  Mozzy V2 first merge slice 정의까지 범위를 확장했다.
- 2026-04-09 사용자 요청으로
  neighborhood read slice 세부 smoke checklist까지 범위를 확장했다.
- 2026-04-09 사용자 요청으로
  HNI auto-company 최소 실행 MVP 구현까지 범위를 확장했다.
- `hni_auto_company_mvp/` Flutter 앱과
  관련 테스트/README가 구현됐다.
- MVP 검증은
  `flutter analyze`와 `flutter test` 기준으로 완료했다.
- 2026-04-09 사용자 요청으로
  backend-connected v1.1 MVP와
  실채널 연동 1차 설계까지 범위를 확장했다.
- `bin/server.dart`와
  backend-connected client mode가 구현됐다.
- 실채널 연동 1차 설계는
  Telegram 우선, WhatsApp notification + 제한형 command 기준으로 문서화했다.
- 2026-04-09 커밋/푸시 요청 기준으로
  초기에는 `origin` remote 부재가 blocker였지만,
  이후 `jbak2588/mozzy-ai-team` remote 연결과
  `main` push까지 완료했다.
- 2026-04-09 사용자 요청으로
  Telegram 실연동 v1.2 구현까지 범위를 확장했다.
- Telegram v1.2 구현은
  backend webhook/status helper,
  sender policy, reply path,
  completion summary dispatch 기준으로 완료했다.
- Telegram 구현 검증은
  `flutter analyze`, `flutter test`,
  `markdownlint-cli@0.40.0 '**/*.md'` 기준으로 완료했다.
- 2026-04-09 테스트 구동 중 확인된
  `No ScaffoldMessenger widget found` 예외를
  별도 후속 수정 항목으로 반영했다.
- `scaffoldMessengerKey`와 `navigatorKey`를
  루트 앱에 연결해
  snackbar/dialog 호출 경로를 안정화했다.
- header와 channel/dialog dropdown을
  반응형으로 조정해
  widget test 기준 overflow도 제거했다.
- 2026-04-09 사용자 요청으로
  Telegram 연결 확인 절차와
  대시보드 14-agent 가시화를 범위에 추가했다.
- Home dashboard에
  `14-Agent Board`를 추가해
  14개 persona를 역할군/리드/원형 이름과 함께 표시한다.
- Telegram 연결 확인 절차는
  README에 status endpoint, set-webhook,
  `/help` roundtrip, command log 기준으로 정리했다.
- 2026-04-09 runtime 점검 기준으로
  현재 shell env에는 Telegram bot token/webhook 값이 없고,
  backend `127.0.0.1:8787`도 미기동 상태였다.
- 2026-04-09 사용자 제공 실 bot token 기준으로
  Telegram Bot API와 backend status를 재검증한 결과,
  `@hni_mozzy_bot`는 유효했고
  webhook은 아직 비어 있었다.
- 같은 시점 `getUpdates` 기준으로
  bot에 들어온 사용자 메시지가 없어
  개인 계정 sender binding은 아직 완료되지 않았다.
- 이후 사용자 첨부 이미지와
  live `getUpdates`를 대조한 결과,
  개인 계정의 direct message가
  Telegram bot update queue까지는 실제로 도달했음을 확인했다.
- 다만 현재 구현은 webhook ingress 기준이라
  public HTTPS webhook 또는 polling 경로 없이는
  그 메시지가 HNI backend로 아직 전달되지 않는다.
- 2026-04-09 사용자 추가 요청으로
  public webhook 없이도 Telegram roundtrip 검증이 가능하도록
  polling mode를 범위에 포함했다.
- 실 Telegram token과 sender/chat 식별자는
  git 추적 밖의 `.hni_auto_company/telegram.local.env`에만 반영했다.
- 2026-04-09 사용자 요청으로
  Telegram polling live roundtrip을
  임시 backend state 파일 기준으로 직접 검증했다.
- 이어 같은 변경분을
  local env 제외 기준으로 GitHub `origin/main`에 반영한다.
