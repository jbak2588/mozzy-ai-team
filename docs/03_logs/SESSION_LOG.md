
# SESSION_LOG.md

## 2026-04-09

### Session 001

- Goal: Mozzy AI Team 프로젝트 초기 구조 정의
- Actions:
  - 폴더 구조 설계
  - 핵심 운영 문서 초안 작성
  - 승인 규칙 정의
- Result:
  - 초기 문서 세트 준비 완료
- Next:
  - PROJECT_SCOPE.md 작성
  - ROLE_MAP.md 작성

### Session 002

- Goal: 승인 상태 정합화 및 남은 승인 범위 문서 작업 완료
- Actions:
  - 필수 운영 문서를 재검토해 `EXECUTION_PLAN.md`의 `Status`와 `Planner Decision` 불일치를 확인
  - 실제 파일 존재 여부를 기준으로 `TASK_QUEUE.md`의 T-001 ~ T-009 상태를 `DONE`으로 정리
  - `docs/05_templates/START_EXECUTION_PROMPT.md`를 작성해 T-010을 완료
  - 스펙 문서의 실제 위치가 `docs/04_specs/`임을 합의 문서에 반영
- Result:
  - 실행계획 승인 상태가 `APPROVED`로 정합화됨
  - 작업 큐가 실제 산출물 상태와 일치하게 정리됨
  - 승인된 초기 구축 범위의 작업 T-001 ~ T-010이 모두 완료됨
- Next:
  - 현재 승인 범위는 완료 상태로 본다
  - 후속 요청은 새 작업 또는 변경 요청으로 접수한다

### Session 003

- Goal: 전체 Markdown 문서의 `MD022` blank line 경고 전수 해소
- Actions:
  - 전체 `*.md` 파일에 대해 `markdownlint-cli@0.40.0`를 실행해 `MD022` 발생 위치를 수집
  - `README.md`, `WORKFLOW.md`, `APPROVAL_RULES.md`,
    `TASK_QUEUE.md`에서 heading/list 주변 빈 줄을 정리
  - 동일 원인으로 발생한 `MD032`도 함께 해소되는지 재검증
- Result:
  - 전 프로젝트 Markdown 문서에서 `MD022` 경고가 사라짐
  - 관련 blank-line 계열 경고인 `MD032`도 함께 해소됨
  - 기록 문서 반영 후 최종 재검증에서도 `MD022` 재발이 없음을 확인
  - 잔여 경고는 요청 범위 밖의 `MD013` line-length만 남음
- Next:
  - 필요 시 별도 요청으로 `MD013` line-length 정리 작업을 수행한다

### Session 004

- Goal: `TASK_QUEUE.md`의 `MD060` table-column-style 경고 해소
- Actions:
  - `TASK_QUEUE.md` 표 헤더 구분선의 pipe spacing을 compact style 기준으로 수정
  - `markdownlint-cli@0.40.0`로 `TASK_QUEUE.md` 단일 검증 수행
  - 결과 규칙을 합의 문서에 기록
- Result:
  - `TASK_QUEUE.md`에서 `MD060`, `MD022`, `MD032` 경고가 사라짐
  - 현재 잔여 경고는 `MD013` line-length만 남음
- Next:
  - 필요 시 표 외 긴 행들을 분리해 `MD013`도 후속 정리한다

### Session 005

- Goal: 새 목적 기준으로 계획 상태를 초기화하고
  `auto-company` 기반 Mozzy 운영계획을 다시 수립
- Actions:
  - `xiaoq17/nicepkg-auto-company`를 임시 클론해
    `CLAUDE.md`, `PROMPT.md`, `.claude/agents/`,
    `.claude/settings.json`, `auto-loop.sh`를 검토
  - `jbak2588/bling`를 임시 클론해
    `README.md`, `pubspec.yaml`, `doc/agent.md`,
    글로벌 준비 문서를 검토
  - `auto-company`의 14-agent 구조와
    Mozzy 적용 시 충돌 지점을 분석
  - `EXECUTION_PLAN.md`, `TASK_QUEUE.md`,
    `PROJECT_SCOPE.md`, `ROLE_MAP.md`를
    새 목적 기준의 planning draft로 재구성
  - `AUTO_COMPANY_EVALUATION.md`를 새로 작성
- Result:
  - 기존 초기 구축 계획은 역사 기록으로 남기고,
    새 목적의 실행계획 상태를 `DRAFT`로 전환
  - Humantric용 14-agent 역할맵 초안과
    `auto-company` 평가 문서가 준비됨
  - 구현은 시작하지 않았고,
    다음 단계는 승인 여부 결정만 남음
  - 계획 문서 전체가 `markdownlint-cli@0.40.0` 기준을 통과함
- Next:
  - 사용자가 계획을 승인하면 pilot squad 설계로 진행
  - 승인 전에는 계획 refinement만 수행

### Session 006

- Goal: 승인된 설계 범위를 연속 실행해
  pilot squad와 도입 로드맵까지 완성
- Actions:
  - 사용자 승인에 맞춰 `EXECUTION_PLAN.md`를 `APPROVED`로 전환
  - `TASK_QUEUE.md`에서 `P-007`을 완료 처리하고
    후속 작업 `P-008`~`P-010`을 추가
  - `docs/04_specs/PILOT_SQUADS.md`를 작성해
    Mozzy용 표준 squad 조합을 설계
  - `docs/04_specs/ADOPTION_ROADMAP.md`를 작성해
    Humantric용 단계별 도입 순서와 승인 게이트를 정리
  - `CONSENSUS.md`에 승인 전환과
    1차 도입 원칙을 기록
- Result:
  - 설계 범위가 계획 초안에서 승인된 실행 패키지로 전환됨
  - Mozzy에 바로 적용 가능한 5개 pilot squad가 문서화됨
  - Humantric의 단계별 도입 로드맵과
    인간 승인 게이트가 문서화됨
  - 전체 Markdown 문서가 `markdownlint-cli@0.40.0` 기준을 통과함
- Next:
  - 현재 승인된 설계 범위는 완료 상태로 본다
  - 후속 구현 요청이 오면 squad 단위 실행계획으로 이어간다

### Session 007

- Goal: HNI용 실제 지휘 체계와
  Mozzy V1/V2의 현재 우선 단계를 검토
- Actions:
  - 사용자 의도를 HNI CEO 주도형 14-persona 운영모델로 재해석
  - `jbak2588/bling` 원격 브랜치 목록을 다시 확인해
    `hyperlocal-proposal` 존재를 검증
  - `origin/main`에 아직 병합되지 않은
    `hyperlocal-proposal` 커밋 흐름을 검토
- Result:
  - HNI CEO -> 전략군 -> 제품/엔지니어링/비즈니스/정보군의
    지휘 체계가 목표와 일치함을 확인
  - Mozzy V1/V2는 현재 시점에서
    제품군/엔지니어링군 현황 보고서를 먼저 만드는 것이 적절하다고 판단
- Next:
  - 필요 시 V1/V2 보고서 템플릿과 작성 순서를 설계한다

### Session 008

- Goal: HNI 전용 프로그램 정의와
  채널/대시보드 설계 문서 추가
- Actions:
  - `EXECUTION_PLAN.md`와 `TASK_QUEUE.md`에
    범위 확장을 반영
  - HNI auto-company를
    Flutter 기반 Windows/macOS 운영 콘솔로 정의
  - 작업 지시/보고를 위한
    대시보드와 WhatsApp/Telegram 채널 구조를 문서화
  - `CONSENSUS.md`에
    프로그램 형태와 지시 인터페이스 결정을 기록
- Result:
  - HNI 전용 프로그램 아키텍처 문서가 추가됨
  - 채널/대시보드 설계 문서가 추가됨
  - 확장 설계 문서까지 포함한 전체 Markdown 검증을 완료함
  - Telegram 우선, WhatsApp 제한형 도입 원칙을 합의 문서에 기록함
- Next:
  - 필요 시 다음 단계로
    V1/V2 보고서 템플릿 또는 프로그램 정보구조를 설계한다

### Session 009

- Goal: Mozzy V1/V2 보고서 템플릿과
  HNI 대시보드 Flutter IA/spec 작성
- Actions:
  - `EXECUTION_PLAN.md`와 `TASK_QUEUE.md`에
    새 산출물 범위를 반영
  - `docs/05_templates/` 아래에
    제품군 보고서 템플릿과 엔지니어링군 보고서 템플릿을 작성
  - `docs/04_specs/HNI_DASHBOARD_FLUTTER_IA.md`를 작성해
    화면별 Flutter 위젯 구조와 state source를 세분화
  - `CONSENSUS.md`에
    보고서 분리 원칙과 IA 설계 깊이를 기록
- Result:
  - Mozzy V1/V2 보고를 위한 템플릿 2종이 추가됨
  - HNI 대시보드의 Flutter 위젯 단위 IA/spec 문서가 추가됨
  - 추가 설계 문서까지 포함한 전체 Markdown 검증을 완료함
- Next:
  - 필요 시 다음 단계로
    실제 V1/V2 제품군 보고서 초안 작성을 시작한다

### Session 010

- Goal: Mozzy V1/V2 제품군 보고서 실제 초안 작성
- Actions:
  - `origin/main`과 `origin/hyperlocal-proposal`의
    README, 백서, IA 문서, 변경 요약 문서를 재검토
  - 두 브랜치의 diff 규모
    (`23` commits ahead, `339` files changed)를 확인
  - V2의 핵심 추가 축인
    discovery, relay, trust, neighborhood, shell 구조를
    선택 코드 수준에서 확인
  - 제품군 템플릿을 바탕으로
    V1/V2 실제 초안 보고서를 작성
- Result:
  - Mozzy V1 제품군 초안 보고서가 추가됨
  - Mozzy V2 제품군 초안 보고서가 추가됨
  - 두 문서 모두 runtime 검증 전 단계의
    evidence-based draft로 정리됨
- Next:
  - 필요 시 다음 단계로
    V1/V2 엔지니어링군 보고서 실제 초안을 작성한다

### Session 011

- Goal: Mozzy V1/V2 엔지니어링군 보고서 실제 초안 작성
- Actions:
  - `main`과 `hyperlocal-proposal`의
    `pubspec.yaml`, `main.dart`, `main_mozzy_ii.dart`,
    `functions-v2`, `test/`, `firestore.indexes.json`을 재검토
  - 상태관리 흔적, 테스트 수, Dart 파일 수,
    core service/model 증가 폭을 수집
  - 제품군 보고서와 분리해
    구조, 데이터, 검증 공백, merge blocker 중심의
    엔지니어링 초안 보고서를 작성
- Result:
  - Mozzy V1 엔지니어링 초안 보고서가 추가됨
  - Mozzy V2 엔지니어링 초안 보고서가 추가됨
  - 두 문서 모두 static code review 기반 draft로 정리됨
- Next:
  - 필요 시 다음 단계로
    V1/V2 merge blocker checklist 또는 검증 계획으로 이어간다

### Session 012

- Goal: Mozzy V1/V2 merge blocker checklist 작성
- Actions:
  - 기존 제품군/엔지니어링군 초안에서
    merge blocker 후보를 재정리
  - V1은 `main` 안정화 게이트,
    V2는 `hyperlocal-proposal -> main` 병합 게이트로 해석
  - blocker별 근거, 차단 이유, 해제 조건,
    권장 owner group을 체크리스트로 문서화
- Result:
  - V1/V2 merge blocker checklist 문서가 추가됨
  - full merge 보류 판단 기준이
    문서형 gate로 정리됨
- Next:
  - 필요 시 다음 단계로
    core smoke verification plan을 작성한다

### Session 013

- Goal: Mozzy core smoke verification plan 작성
- Actions:
  - merge blocker checklist와
    제품군/엔지니어링군 초안에서 smoke 대상 경로를 추출
  - README의 로컬 실행 방식,
    `run_local.sh/.ps1`,
    `smoke_generatefinalreport.js`를 확인
  - V1 안정화 smoke와
    V2 병합 전 smoke를 분리한 검증 계획 문서를 작성
- Result:
  - core smoke verification plan 문서가 추가됨
  - 비프로덕션 전제, 자동/수동 smoke, 증적 수집,
    차단 조건이 한 문서로 정리됨
- Next:
  - 필요 시 다음 단계로
    V1 baseline feature 표 또는 V2 first merge slice 정의로 이어간다

### Session 014

- Goal: Mozzy V1 baseline feature 표 작성
- Actions:
  - `EXECUTION_PLAN.md`와 `TASK_QUEUE.md`에
    baseline feature 표 범위 확장을 반영
  - `MOZZY_V1_PRODUCT_REPORT_DRAFT.md`,
    `MOZZY_CORE_SMOKE_VERIFICATION_PLAN.md`,
    `origin/main:README.md`,
    `origin/main:lib/features/*`를 다시 검토
  - V1 사용자 기능을
    `Core Baseline`, `Support Baseline`,
    `Maintain Only`, `Defer From Baseline`으로 분류한
    baseline feature 표 문서를 작성
  - `CONSENSUS.md`에
    표의 해석 원칙을 기록
- Result:
  - V1 field-test 안정화 우선순위를 보여주는
    baseline feature 표 문서가 추가됨
  - baseline 범위가 제품 보고서와 smoke plan에
    연결된 형태로 정리됨
  - 앱 코드 수정 없이 문서 범위에서
    전체 Markdown 검증까지 완료했다
- Next:
  - 필요 시 다음 단계로
    V2 first merge slice 정의로 이어간다

### Session 015

- Goal: Mozzy V2 first merge slice 정의
- Actions:
  - `EXECUTION_PLAN.md`와 `TASK_QUEUE.md`에
    V2 first merge slice 범위 확장을 반영
  - V2 제품군/엔지니어링군 초안,
    merge blocker checklist,
    core smoke plan을 다시 검토
  - `hyperlocal-proposal`의
    `discovery`, `trust`, `neighborhood` 후보 파일과
    테스트 범위를 비교해
    첫 slice 후보를 축소
  - `Neighborhood Dashboard` 중심 read-only slice를
    첫 병합 단위로 문서화하고
    관련 gate 문서도 정합화
- Result:
  - V2 첫 병합 단위가
    `Neighborhood Dashboard` 중심 read-only slice로 고정됨
  - discovery/trust보다
    neighborhood가 더 작은 가산형 단위라는 근거가 정리됨
  - merge blocker와 smoke plan이
    실제 첫 slice 기준으로 정합화됨
- Next:
  - 필요 시 다음 단계로
    neighborhood read slice용 smoke checklist 세분화로 이어간다

### Session 016

- Goal: neighborhood read slice 세부 smoke checklist 작성
- Actions:
  - `EXECUTION_PLAN.md`와 `TASK_QUEUE.md`에
    neighborhood read smoke checklist 범위 확장을 반영
  - V2 first merge slice 문서,
    core smoke plan,
    merge blocker checklist를 다시 검토
  - neighborhood dashboard의 read-only 특성에 맞춰
    preflight, boot, entry, data, fallback,
    navigation, V1 non-regression 체크리스트를 세분화
  - HNI auto-company가 아직
    승인 후 자동 연속 실행 프로그램으로 구현되지 않은 이유를
    합의 문서에 현재 상태로 기록
- Result:
  - neighborhood read slice 세부 smoke checklist 문서가 추가됨
  - first merge slice와 smoke plan 사이의
    실행 단위가 더 구체화됨
  - HNI auto-company의 현재 상태가
    "설계 패키지"와 "실제 런타임 미구현"으로 명확히 분리됨
- Next:
  - 필요 시 다음 단계로
    HNI auto-company 최소 실행 MVP 구현 계획으로 이어간다

### Session 017

- Goal: HNI auto-company 최소 실행 MVP 착수
- Actions:
  - `EXECUTION_PLAN.md`와 `TASK_QUEUE.md`에
    실제 MVP 구현 범위를 반영
  - HNI 프로그램 정의, 대시보드 IA,
    채널 설계 문서를 다시 검토
  - MVP를 `hni_auto_company_mvp/`
    Flutter 데스크톱 앱으로 구현하기로 결정
  - 외부 webhook 대신
    로컬 command simulator + approval 후 자동 연속 실행 엔진을
    1차 구현 범위로 고정
- Result:
  - 문서 기반 설계 단계에서
    실제 실행 가능한 MVP 구현 단계로 전환됨
  - 구현 우선순위가
    `state machine -> UI -> local simulation`
    순서로 고정됨
- Next:
  - Flutter 스캐폴드 생성 후
    실행 엔진과 UI를 구현한다

### Session 018

- Goal: HNI auto-company 최소 실행 MVP 구현 및 검증 완료
- Actions:
  - `flutter create --platforms=macos,windows hni_auto_company_mvp`로
    데스크톱 앱 스캐폴드를 생성
  - `models.dart`, `persistence.dart`, `command_parser.dart`,
    `store.dart`를 작성해
    work order 상태모델, 로컬 JSON 저장, command parser,
    approval 후 자동 연속 실행 엔진을 구현
  - `app.dart`를 작성해
    Home, Orders, Reports, Gates, Channels, Audit 화면과
    create order dialog, command simulator UI를 구현
  - `command_parser_test.dart`, `store_test.dart`를 작성하고
    `flutter analyze`, `flutter test`로 검증
  - runner cleanup에서
    `whenComplete`가 제거된 `Future`를 반환해
    자기 자신을 다시 기다리던 타임아웃 원인을 찾아 수정
  - MVP scope 문서와 앱 README를
    실제 구현 결과에 맞게 갱신
- Result:
  - HNI auto-company 최소 실행 MVP가
    실제 실행 가능한 Flutter 데스크톱 앱으로 구현됨
  - plan approval 이후
    추가 단계 승인 요청 없이
    `Execution -> Evaluation -> Revision -> Completion`이
    자동 연속 실행됨
  - 로컬 command simulator와
    dashboard/report/audit UI까지 검증 가능한 상태가 됨
- Next:
  - 필요 시 다음 단계로
    실제 Telegram/WhatsApp 연동 설계 또는
    remote backend 도입 계획으로 이어간다

### Session 019

- Goal: HNI auto-company backend-connected v1.1 MVP 완성과
  실채널 연동 1차 설계 완료
- Actions:
  - `EXECUTION_PLAN.md`와 `TASK_QUEUE.md`에
    v1.1 backend-connected MVP 및
    실채널 연동 1차 설계 범위를 반영
  - `pubspec.yaml`에 `http`, `shelf`, `shelf_router`를 추가
  - `bin/server.dart`, `lib/src/backend_service.dart`를 작성해
    로컬 HTTP backend와 authoritative work order orchestration을 구현
  - `lib/src/persistence.dart`, `lib/main.dart`, `lib/src/store.dart`,
    `lib/src/app.dart`를 수정해
    `API_BASE_URL` 기반 remote client mode와 backend polling UI를 구현
  - `backend_service_test.dart`, `http_repository_test.dart`를 추가하고
    `dart run bin/server.dart`, `flutter analyze`, `flutter test`로 검증
  - `HNI_AUTO_COMPANY_V11_SCOPE.md`,
    `HNI_CHANNEL_LIVE_INTEGRATION_PHASE1.md`를 작성하고
    앱 README를 v1.1 기준으로 갱신
- Result:
  - HNI auto-company가
    로컬 file MVP에서
    backend-connected v1.1 구조로 확장됨
  - backend가 authoritative state와
    approval 이후 auto-run을 담당하고,
    desktop client는 polling dashboard로 연결됨
  - Telegram 우선 / WhatsApp notification 우선의
    실채널 1차 설계가 문서화됨
- Next:
  - 필요 시 다음 단계로
    Telegram 실연동 구현 또는
    backend auth/webhook security 계층 구현으로 이어간다

### Session 020

- Goal: 현재 작업 산출물의 GitHub 커밋/푸시 시도
- Actions:
  - 승인 규칙과 현재 git 상태를 다시 확인
  - local repo가 `No commits yet on main`이고
    `origin` remote가 없음을 확인
  - GitHub 계정 연결 상태는 확인됐지만
    `gh` CLI는 설치되어 있지 않음을 확인
  - `.gitignore`를 추가해
    `.vscode/`, `output/`, `.hni_auto_company/`를 commit 범위에서 제외
  - push blocker를
    `TASK_QUEUE.md`, `CONSENSUS.md`, `SESSION_LOG.md`에 기록
- Result:
  - 커밋 준비 범위는 정리됐지만
    push target repository가 없어
    push는 blocker 상태로 남음
- Next:
  - local commit을 생성한다
  - 사용자가 remote repository를 준비하면 push를 이어간다

### Session 021

- Goal: 생성된 GitHub repository로 push 완료
- Actions:
  - 사용자가 제공한
    `https://github.com/jbak2588/mozzy-ai-team`를
    `origin` remote로 연결
  - 기존 local root commit
    `00edbee Implement HNI auto-company v1.1 MVP`를
    `origin/main`으로 push
  - `TASK_QUEUE.md`, `CONSENSUS.md`, `SESSION_LOG.md`의
    push blocker 상태를 해제하도록 기록 갱신
- Result:
  - local 저장소와 GitHub repository가 연결됨
  - `main` 브랜치가
    `origin/main`을 tracking 하도록 설정됨
  - GitHub publish blocker가 해소됨
- Next:
  - 필요 시 다음 단계로
    Telegram 실연동 구현을 진행한다

### Session 022

- Goal: Telegram 실연동 v1.2 계획 반영, 코드 구현, 검증 완료
- Actions:
  - `EXECUTION_PLAN.md`, `TASK_QUEUE.md`, `CONSENSUS.md`에
    Telegram 실연동 v1.2 범위와 비프로덕션 제약을 반영
  - `HNI_TELEGRAM_V12_SCOPE.md`를 작성하고
    `HNI_CHANNEL_LIVE_INTEGRATION_PHASE1.md`,
    앱 `README.md`를 실제 구현 상태에 맞게 갱신
  - `telegram_integration.dart`를 추가해
    env 기반 Telegram config,
    Bot API client,
    webhook status helper,
    update normalizer,
    sender policy evaluator,
    reply/completion summary dispatcher를 구현
  - `backend_service.dart`, `models.dart`, `server.dart`, `app.dart`를 수정해
    Telegram webhook/status/set-webhook/delete-webhook route,
    sender metadata 저장,
    command log 표시,
    completion summary dispatch를 연결
  - `telegram_integration_test.dart`를 추가해
    webhook 생성, privileged approve, 권한 거부,
    secret mismatch를 검증
  - `dart format`, `flutter analyze`, `flutter test`,
    `markdownlint-cli@0.40.0 '**/*.md'`로 검증
- Result:
  - HNI auto-company backend가
    Telegram command channel을 실제 webhook ingress로 받을 수 있는
    v1.2 상태로 확장됨
  - Telegram 명령은
    backend sender policy를 통과한 뒤
    기존 work-order command 경로로 정규화됨
  - Telegram에서 생성된 order는
    완료 시 같은 chat으로 completion summary를 다시 발송함
  - production webhook 개통 없이도
    로컬/비프로덕션에서 검증 가능한 live integration 경로가 준비됨
- Next:
  - 필요 시 다음 단계로
    Telegram public webhook 개통 준비 문서화 또는
    WhatsApp notification-only 실연동으로 이어간다

### Session 023

- Goal: 테스트 구동 중 확인된 루트 context 예외 수정
- Actions:
  - 디버그 콘솔의
    `No ScaffoldMessenger widget found` 예외를 기준으로
    `app.dart`의 snackbar/dialog 호출 경로를 재검토
  - `HniAutoCompanyApp`에
    `scaffoldMessengerKey`, `navigatorKey`를 추가하고
    루트 state의 바깥 `context` 대신
    key 기반 경로로 snackbar와 dialog를 호출하도록 수정
  - `TopHeader`, `Channel Simulator`,
    create-order dialog의 dropdown 배치를 조정해
    widget test 중 발생하던 overflow를 함께 제거
  - `app_widget_test.dart`를 추가해
    channel snackbar와 new-order dialog가
    예외 없이 열리는지 회귀 검증
  - `flutter test`로 전체 테스트 통과를 확인
- Result:
  - `No ScaffoldMessenger widget found` 예외가 재현 기준으로 해소됨
  - 루트 앱 action이
    app-shell 내부 `Navigator`/`ScaffoldMessenger`에 안전하게 연결됨
  - widget test 기준의 layout overflow도 함께 정리됨
- Next:
  - 필요 시 다음 단계로
    이 수정분을 GitHub commit/push한다

### Session 024

- Goal: Telegram 연결 확인 절차 정리 및 대시보드 14-agent 가시화
- Actions:
  - `EXECUTION_PLAN.md`, `TASK_QUEUE.md`, `CONSENSUS.md`,
    `HNI_DASHBOARD_FLUTTER_IA.md`에
    Telegram 확인 절차와 14-agent board 범위를 반영
  - `README.md`의 Telegram live mode 아래에
    status endpoint, set-webhook, `/help` roundtrip,
    dashboard command log를 기준으로 한
    연결 확인 절차를 추가
  - `app.dart`에
    14-agent 정적 디렉터리와
    Home `14-Agent Board` UI를 구현
  - `app_widget_test.dart`에
    `14-Agent Board`가 실제로 보이는지 회귀 테스트를 추가
  - `flutter analyze`, `flutter test`,
    `markdownlint-cli@0.40.0 '**/*.md'`로 검증
- Result:
  - 사용자가 Telegram 연결 여부를
    status 조회와 command roundtrip 기준으로 판단할 수 있게 됨
  - Home dashboard에서
    HNI의 14개 advisory persona를 한눈에 볼 수 있게 됨
  - 기존 Telegram/widget 회귀와 함께
    새 agent board 표시도 테스트로 확인됨
- Next:
  - 필요 시 다음 단계로
    이 변경분을 GitHub commit/push한다

### Session 025

- Goal: 사용자 Telegram 계정 기준의 실제 연결 방법 안내와 runtime 상태 점검
- Actions:
  - 사용자 첨부 이미지에서
    표시 이름 `JaeHyun Park`와
    전화번호 `+62 852 81562588`를 확인
  - 현재 shell env의
    `HNI_TELEGRAM_BOT_TOKEN`,
    `HNI_TELEGRAM_WEBHOOK_SECRET`,
    `HNI_TELEGRAM_WEBHOOK_BASE_URL`,
    sender allowlist 값 유무를 점검
  - `curl http://127.0.0.1:8787/api/v1/integrations/telegram/status`와
    `lsof -iTCP:8787`로
    backend runtime 상태를 점검
  - 구현 기준상
    Telegram 연동은 개인 계정을 직접 API에 묶는 것이 아니라
    bot token + webhook + sender/chat allowlist 구조라는 점을
    운영 해석으로 정리
- Result:
  - 현재 환경에서는
    Telegram bot token/webhook 관련 env가 모두 unset 상태였고,
    backend `127.0.0.1:8787`도 미기동이라
    API가 연결됐다고 볼 수 없음을 확인
  - 사용자 계정은
    bot과 대화하는 sender로 연결되어야 하며,
    전화번호 자체는 현재 구현의 allowlist 키가 아님을 확인
- Next:
  - 필요 시 다음 단계로
    BotFather bot 생성, env 주입, webhook 등록까지 실제 연결 작업을 진행한다

### Session 026

- Goal: 실 Telegram bot token 기준의 live 검증과 계정 바인딩 가이드 정리
- Actions:
  - 사용자 제공 bot token으로
    Telegram Bot API `getMe`, `getWebhookInfo`, `getUpdates`를 호출해
    bot 유효성, webhook 상태, 사용자 메시지 유입 여부를 점검
  - shell runtime에만
    token과 임시 webhook secret을 주입해
    `dart run bin/server.dart`를 기동하고
    `/api/v1/integrations/telegram/status` 응답을 확인
  - `README.md`에
    `@hni_mozzy_bot` 기준의 계정 바인딩 절차와
    username/sender_id allowlist 설정 순서를 추가
  - 실 token은
    repo/문서에 남기지 않는 운영 규칙을
    합의 문서에 반영
- Result:
  - `@hni_mozzy_bot` token이 유효하고,
    HNI backend status endpoint도
    `configured: true`, `status: ready`로 응답함을 확인
  - Telegram 측 webhook URL은 아직 비어 있고,
    `getUpdates`도 `0`건이라
    사용자의 개인 계정 sender binding은 아직 완료되지 않았음을 확인
  - 따라서 현재 상태는
    "Bot API 연결 성공 / backend 연동 성공 / 개인 계정 바인딩 대기"로 정리됨
- Next:
  - 사용자가 `@hni_mozzy_bot`에 먼저 메시지를 보내고,
    그 뒤 `username` 또는 `sender_id`를 allowlist에 반영한다
  - public webhook 또는 polling mode가 필요하면
    별도 승인 후 다음 범위로 진행한다

### Session 027

- Goal: 첨부 이미지 기준 Telegram bot direct message 실수신 여부 확인
- Actions:
  - 사용자 첨부 이미지에서
    `@hni_mozzy_bot` chat에 `/start`, `halo`가 전송된 상태를 확인
  - Telegram Bot API `getWebhookInfo`로
    현재 webhook이 비어 있고
    pending update가 누적되는지 점검
  - Telegram Bot API `getUpdates`로
    실제 private message update가 존재하는지 확인
- Result:
  - 사용자 계정의 direct message가
    Telegram bot update queue까지 실제로 도달했음을 확인
  - 따라서 bot과 개인 계정 사이의
    1차 sender binding evidence는 확보됐다
  - 그러나 현재 HNI app은 webhook ingress 기준이라
    public HTTPS webhook 또는 polling path 없이는
    이 메시지가 backend command log/reply로 이어지지 않는다
- Next:
  - 필요 시 다음 단계로
    sender/chat allowlist 값을 실제 env에 반영한다
  - public webhook 또는 polling mode 중
    하나를 선택해 backend inbound를 완성한다

### Session 028

- Goal: Telegram polling mode 구현과 bot handle 해석 정리
- Actions:
  - `@hni_mozzy_bot`는
    target bot handle로 유지하되,
    sender authorization은
    여전히 사용자 `sender_id`/`chat_id`를 기준으로 본다는 점을
    합의 문서에 기록
  - `telegram_integration.dart`에
    polling env와 `getUpdates` client 경로를 추가
  - `backend_service.dart`에
    polling loop, `poll-once` helper,
    polling status/cursor 반영,
    webhook/polling 공용 Telegram payload 처리 경로를 추가
  - `README.md`와
    `HNI_TELEGRAM_V12_SCOPE.md`에
    polling mode와 public webhook 전제조건을 정리
  - `telegram_integration_test.dart`에
    queued update 기반 polling 검증을 추가
  - git 추적 밖의
    `.hni_auto_company/telegram.local.env`를 만들어
    실 bot token, sender/chat id, polling env를 로컬 runtime에 적용
- Result:
  - public webhook 없이도
    Telegram direct message를 backend command로 intake할 수 있는
    polling mode가 구현됨
  - Telegram status endpoint에서
    polling enabled/active/cursor 정보를 함께 확인할 수 있게 됨
  - `@hni_mozzy_bot`는
    bot handle이고 sender allowlist username이 아니라는 점을
    운영 규칙으로 고정함
  - 실 연결값은
    git 추적 밖 로컬 env 파일로만 보관되도록 정리함
- Next:
  - 필요 시 다음 단계로
    polling roundtrip을 직접 검증한다
  - public webhook을 원하면
    public HTTPS URL, TLS, reverse proxy 기준으로 다음 범위를 진행한다

### Session 029

- Goal: Telegram polling live roundtrip 직접 검증
- Actions:
  - git 추적 밖 로컬 env를 사용하되
    기존 사용자 state를 건드리지 않도록
    임시 backend state 파일로 server를 실행
  - Telegram pending update `2`건(`/start`, `halo`)이 있는 상태를 확인
  - `POST /api/v1/integrations/telegram/poll-once`로
    두 update를 실제 처리하고
    command log와 polling cursor를 확인
  - 같은 private chat `5290546807`로
    Telegram Bot API `sendMessage`를 직접 호출해
    outbound delivery를 확인
- Result:
  - polling helper가 pending update `2`건을 실제 intake했고,
    backend command log에
    `senderId/chatId = 5290546807`와 함께
    `Unknown command. Try /help` 결과가 기록됨
  - polling cursor가 `186781256`으로 전진했고,
    같은 offset 기준 `getUpdates`는 빈 결과를 반환함
  - outbound verification message도
    `ok: true`, `message_id: 5`로 성공해
    live roundtrip이 성립함을 확인
- Next:
  - 필요 시 다음 단계로
    background polling mode 기준의 추가 live command를 검증한다
  - 또는 public webhook 구성을 진행한다

### Session 030

- Goal: Telegram/polling 변경분 GitHub commit + push
- Actions:
  - 현재 staged 변경 범위를
    Telegram v1.2, polling mode, dashboard/README/spec/test,
    macOS workspace sync까지 포함하는 publish scope로 정리
  - `.hni_auto_company/telegram.local.env`는
    local-only secret 파일이라
    git publish 대상에서 계속 제외
  - 변경분을 commit하고
    `origin/main`으로 push
- Result:
  - 현재 Telegram/polling 변경분이
    GitHub remote에 반영됨
- Next:
  - 필요 시 다음 단계로
    public webhook 구성 또는 추가 live command 검증으로 이어간다
