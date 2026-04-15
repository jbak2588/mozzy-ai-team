# CONSENSUS

## Stable Decisions

### D-001

* **Topic:** 운영 방식
* **Decision:** 무통제 자율주행 방식은 사용하지 않는다.
* **Reason:** 현실 판단 없는 자동 실행을 방지하기 위함.
* **Status:** ACTIVE

### D-002

* **Topic:** 승인 구조
* **Decision:** 최초 실행계획 승인 후에는 합의된 최종 범위까지 연속 실행한다.
* **Reason:** 매 단계 승인 반복으로 인한 흐름 단절 방지.
* **Status:** ACTIVE

### D-003

* **Topic:** 문서 우선순위
* **Decision:** AGENTS > WORKFLOW > APPROVAL_RULES > EXECUTION_PLAN 순으로 운영 기준을 본다.
* **Reason:** 전역 지침과 승인 규칙의 일관성 유지.
* **Status:** ACTIVE

### D-004

* **Topic:** 실행계획 승인 해석
* **Decision:** `EXECUTION_PLAN.md`의 `Planner Decision`에서
  `APPROVED`가 체크된 경우 실행 승인으로 간주하고, `Status`
  필드도 동일하게 `APPROVED`로 정합화한다.
* **Reason:** 승인 상태 해석이 흔들리면 연속 실행 규칙이 깨지기 때문이다.
* **Status:** ACTIVE

### D-005

* **Topic:** 스펙 문서 위치
* **Decision:** `PROJECT_SCOPE.md`와 `ROLE_MAP.md`의 정식 위치는 `docs/04_specs/`로 유지한다.
* **Reason:** 실제 파일 구조와 작업 기록을 일치시켜 탐색 혼선을 줄이기 위함.
* **Status:** ACTIVE

### D-006

* **Topic:** 새 세션 시작 프롬프트
* **Decision:** 새 실행 세션의 표준 시작 프롬프트는
  `docs/05_templates/START_EXECUTION_PROMPT.md`를 사용한다.
* **Reason:** 매 세션마다 동일한 통제형 실행 규칙을
  빠짐없이 재적용하기 위함.
* **Status:** ACTIVE

### D-007

* **Topic:** Markdown 문서 공통 서식
* **Decision:** 프로젝트 내 Markdown 문서는 heading 전후에 빈 줄 1줄을 두는 `MD022` 규칙을 기본값으로 유지한다.
* **Reason:** VS Code `markdownlint` 경고를 줄이고 문서 서식을 일관되게 유지하기 위함.
* **Status:** ACTIVE

### D-008

* **Topic:** Markdown 린트 정리 범위
* **Decision:** 이번 정리 범위는 `MD022`와 그에 직접 연결된
  blank-line 경고까지만 포함하고, `MD013` line-length는
  별도 요청 시 처리한다.
* **Reason:** 사용자 요청 범위를 넘지 않으면서 수정 영향도를
  최소화하기 위함.
* **Status:** ACTIVE

### D-009

* **Topic:** TASK_QUEUE 표 서식
* **Decision:** `TASK_QUEUE.md`의 표 구분선은
  `| --- | --- |` 형태의 compact style spacing을 유지한다.
* **Reason:** `markdownlint`의 `MD060` table-column-style 경고를 방지하기 위함.
* **Status:** ACTIVE

### D-010

* **Topic:** 계획 초기화 해석
* **Decision:** 2026-04-09 사용자 요청의 "초기화"는
  기존 운영 기록 삭제가 아니라,
  새 목적 기준으로 계획 상태를 다시 `DRAFT`로 돌리는 것으로 해석한다.
* **Reason:** 과거 기록을 보존하면서도
  새 목적의 계획을 처음부터 다시 세울 수 있기 때문이다.
* **Status:** ACTIVE

### D-011

* **Topic:** Auto-Company 채택 방식
* **Decision:** `auto-company`는 Humantric에 그대로 복제하지 않고,
  역할 구조와 협업 패턴만 참조 아키텍처로 사용한다.
* **Reason:** 완전자율, 권한 우회, 무승인 실행은
  현재 통제형 운영원칙과 충돌한다.
* **Status:** ACTIVE

### D-012

* **Topic:** Mozzy용 14-agent 운영 원칙
* **Decision:** Mozzy용 14-agent는 모두 advisory role이며,
  범위 확장, 배포, 보안/개인정보/결제 변경은
  인간 승인 없이는 진행하지 않는다.
* **Reason:** Mozzy는 위치, 신뢰, 거래, 커뮤니티가 결합된
  고위험 제품군이기 때문이다.
* **Status:** ACTIVE

### D-013

* **Topic:** 실행계획 승인 전환
* **Decision:** 2026-04-09 사용자 승인에 따라
  `EXECUTION_PLAN.md` 상태를 `APPROVED`로 전환하고
  설계 범위 문서를 연속 실행한다.
* **Reason:** 승인 후에는 합의된 범위를
  중단 없이 끝까지 수행해야 하기 때문이다.
* **Status:** ACTIVE

### D-014

* **Topic:** Humantric 1차 도입 방식
* **Decision:** 1차 도입은 auto-loop 없이,
  문서 기반 orchestration + 소규모 pilot squad 방식으로만 시작한다.
* **Reason:** 완전자율 루프보다
  통제형 시범 적용이 Mozzy 리스크에 더 적합하다.
* **Status:** ACTIVE

### D-015

* **Topic:** Pilot Squad 우선순위
* **Decision:** Humantric는 먼저
  Discovery, Feature Delivery, Trust & Readiness,
  Community Growth, Release Planning의 5개 pilot squad를 정의해 사용한다.
* **Reason:** 14-agent 전체를 항상 동시에 쓰기보다
  작업 유형별 소팀 운영이 실용적이기 때문이다.
* **Status:** ACTIVE

### D-016

* **Topic:** 1차 시범 적용 순서
* **Decision:** 첫 30일 시범 적용은
  `SQ-01 -> SQ-02 -> 필요 시 SQ-03 -> 상황별 SQ-04/SQ-05`
  순서로 진행한다.
* **Reason:** 시장/우선순위 판단 없이 구현부터 시작하는 것을 막고,
  trust 리스크를 필요한 순간에만 별도 검토하기 위함이다.
* **Status:** ACTIVE

### D-017

* **Topic:** HNI 지휘 체계
* **Decision:** HNI CEO가 `ceo-bezos`에게 명시적 오더를 주고,
  전략군이 방향안을 만든 뒤
  제품군, 엔지니어링군, 비즈니스군, 정보군이
  그 결정에 따라 일하는 구조를 기본 운영모델로 본다.
* **Reason:** 완전자율이 아니라
  CEO 주도형 통제 실행 모델이 사용자 의도와 일치하기 때문이다.
* **Status:** ACTIVE

### D-018

* **Topic:** Mozzy V1/V2 현재 단계
* **Decision:** Mozzy `main`과 `hyperlocal-proposal`은
  아직 차이가 크고 미검증 범위가 넓으므로,
  당장은 제품군/엔지니어링군의 현황 보고서 작성이 우선이다.
* **Reason:** `hyperlocal-proposal`은 다수의 기능/문서/리팩터링 커밋이
  누적된 상태라 바로 병합이나 구현 진행보다
  현재 상태 파악과 검증 보고가 선행되어야 한다.
* **Status:** ACTIVE

### D-019

* **Topic:** HNI 프로그램 형태
* **Decision:** HNI auto-company는 별도의 전용 프로그램으로 정의하고,
  Mozzy와 같은 Flutter 기반으로
  Windows/macOS 공통 코드로 실행되는 운영 콘솔을 목표로 한다.
* **Reason:** CEO 지시, squad dispatch, 보고서 확인을
  하나의 통합 UI에서 다뤄야 하기 때문이다.
* **Status:** ACTIVE

### D-020

* **Topic:** 작업 지시 인터페이스
* **Decision:** 작업 지시는 대시보드 UI와
  WhatsApp/Telegram 채널 모두에서 가능하도록 설계한다.
* **Reason:** HNI CEO와 운영자가
  화면 기반 조작과 메신저 기반 지시를 병행할 수 있어야 하기 때문이다.
* **Status:** ACTIVE

### D-021

* **Topic:** 채널 도입 순서
* **Decision:** 1차 command 채널은 Telegram을 우선하고,
  WhatsApp은 notification + 제한형 command부터 시작한다.
* **Reason:** Telegram이 작업 명령 인터페이스로 더 단순하고,
  WhatsApp은 운영/정책 제약이 상대적으로 크기 때문이다.
* **Status:** ACTIVE

### D-022

* **Topic:** Mozzy V1/V2 보고 방식
* **Decision:** Mozzy V1/V2 보고는
  제품군 보고서 템플릿과 엔지니어링군 보고서 템플릿을 분리해 운영한다.
* **Reason:** 사용자 가치/기능 관점과
  구조/리스크/검증 관점을 분리해야 의사결정이 쉬워지기 때문이다.
* **Status:** ACTIVE

### D-023

* **Topic:** HNI 대시보드 설계 깊이
* **Decision:** 대시보드 설계는 화면 목록 수준에서 멈추지 않고,
  Flutter 위젯 트리와 state source 수준까지 세분화한다.
* **Reason:** 이후 실제 구현 계획으로 바로 내려갈 수 있어야 하기 때문이다.
* **Status:** ACTIVE

### D-024

* **Topic:** Mozzy 제품군 실제 보고서 작성 기준
* **Decision:** Mozzy V1/V2 제품군 실제 보고서 초안은
  `main`과 `hyperlocal-proposal` 브랜치의 문서,
  diff, 파일 구조, 선택 코드 근거를 바탕으로 작성하고,
  runtime/UI 검증 전까지는
  "초안"과 "비실행 검토" 상태를 명시한다.
* **Reason:** 현재 단계에서는 브랜치 근거만으로도
  방향성과 위험을 판단할 수 있지만,
  실제 동작 검증까지 완료된 것처럼 쓰면 과신이 되기 때문이다.
* **Status:** ACTIVE

### D-025

* **Topic:** Mozzy 엔지니어링군 실제 보고서 작성 기준
* **Decision:** Mozzy V1/V2 엔지니어링군 실제 보고서 초안은
  브랜치의 코드 구조, 의존성, 테스트 파일, diff, 선택 백엔드 파일을
  근거로 작성하고, 실제 앱 실행이나 테스트 실행을 하지 않은 경우
  그 한계를 문서에 명시한다.
* **Reason:** static review만으로도
  구조적 리스크와 merge blocker를 파악할 수 있지만,
  실행 검증까지 한 것처럼 기록하면 잘못된 안정감이 생기기 때문이다.
* **Status:** ACTIVE

### D-026

* **Topic:** Mozzy merge blocker checklist 해석
* **Decision:** Mozzy merge blocker checklist에서
  V1은 `main`의 안정화 게이트로,
  V2는 `hyperlocal-proposal -> main` 병합 게이트로 해석한다.
  열린 blocker가 남아 있으면
  full merge 기본 권고는 `보류`로 둔다.
* **Reason:** V1은 이미 기준 브랜치라
  "merge blocker"를 그대로 적용하면 의미가 모호하고,
  V2는 실제 병합 판단 문서가 필요하기 때문이다.
* **Status:** ACTIVE

### D-027

* **Topic:** Mozzy core smoke verification plan 원칙
* **Decision:** Mozzy core smoke verification은
  로컬 debug/profile 또는 별도 비프로덕션 환경만 전제로 설계하고,
  실사용자 데이터, 실제 결제, 실제 프로덕션 배포는
  smoke 범위에서 제외한다.
* **Reason:** 현재 승인 범위는 검증 계획 문서화까지이며,
  production action이나 민감 데이터 사용은
  별도 승인 없이는 다루면 안 되기 때문이다.
* **Status:** ACTIVE

### D-028

* **Topic:** Mozzy V1 baseline feature 표 해석
* **Decision:** `MOZZY_V1_BASELINE_FEATURE_TABLE.md`는
  `main`의 사용자 기능을
  `Core Baseline`, `Support Baseline`, `Maintain Only`,
  `Defer From Baseline`으로 분류하는
  안정화 우선순위 문서로 사용한다.
  baseline 밖으로 분류된 기능은
  즉시 삭제 대상으로 보지 않는다.
* **Reason:** 현재 단계는 V1 field-test 기준선과
  V2 비교 기준을 정리하는 작업이지,
  기능 제거 결정을 내리는 단계가 아니기 때문이다.
* **Status:** ACTIVE

### D-029

* **Topic:** Mozzy V2 first merge slice 결정
* **Decision:** V2의 첫 병합 단위는
  full shell 전환이나 discovery/trust 전체가 아니라,
  기존 V1 위에 가산적으로 붙일 수 있는
  `Neighborhood Dashboard` 중심의
  read-only slice로 본다.
  `Neighborhood Identity`, relay, trust write,
  wallet, scheduler, shell replacement는
  첫 slice 밖에 둔다.
* **Reason:** neighborhood dashboard는
  기존 컬렉션 read path 중심이라
  backend delta와 migration 부담이 상대적으로 작고,
  hyperlocal 차별화는 보여주면서도
  full branch merge 리스크를 낮출 수 있기 때문이다.
* **Status:** ACTIVE

### D-030

* **Topic:** Neighborhood read slice smoke 해석
* **Decision:** neighborhood read slice smoke는
  `main_mozzy_ii.dart` 전체 수용 테스트가 아니라,
  제한 entry 또는 additive route 기준의
  `dashboard read path` 검증으로 해석한다.
  핵심 pass 조건은
  진입, 로딩, 새로고침, empty/error fallback,
  detail 이동, V1 기본 흐름 비파괴다.
* **Reason:** 첫 slice의 목적은
  V2 shell 전체를 승인하는 것이 아니라,
  가장 작은 hyperlocal capability를
  낮은 리스크로 검증하는 데 있기 때문이다.
* **Status:** ACTIVE

### D-031

* **Topic:** HNI auto-company 현재 미구현 원인
* **Decision:** 현재 `mozzy-ai-team`의 HNI auto-company는
  실행 규칙, 역할맵, 대시보드/채널, 보고서 체계까지는
  문서와 스펙으로 정의됐지만,
  실제로 승인 후 자동 연속 실행을 수행하는
  프로그램 자체는 아직 구현되지 않았다.
  부족한 것은
  work order state machine,
  approval latch,
  task queue runner,
  orchestration backend,
  dashboard frontend,
  Telegram/WhatsApp webhook,
  completion reporter다.
* **Reason:** 지금까지 승인된 범위는
  주로 운영 설계, 보고 체계, 검증 문서 작성이었고,
  `EXECUTION_PLAN.md`에서도 앱 코드 수정과
  자율 루프 즉시 도입은 범위 밖으로 두었기 때문이다.
* **Status:** ACTIVE

### D-032

* **Topic:** HNI auto-company 최소 실행 MVP 범위
* **Decision:** 첫 MVP는
  `hni_auto_company_mvp/` 아래의
  Flutter Windows/macOS 데스크톱 앱으로 구현한다.
  실제 외부 Telegram/WhatsApp webhook 연동 대신
  동일 명령 규격의 로컬 command simulator를 넣고,
  핵심 기능은
  plan approval 이후 추가 승인 요청 없이
  stage를 순차 실행하는
  work order state machine과
  completion report 생성으로 둔다.
* **Reason:** 외부 채널 실연동보다
  승인 후 자동 연속 실행 엔진을 먼저 구현하는 것이
  사용자 핵심 요구를 가장 작고 검증 가능한 범위로 충족하기 때문이다.
* **Status:** ACTIVE

### D-033

* **Topic:** HNI MVP 실행 엔진 의미
* **Decision:** HNI MVP의 실제 실행 엔진은
  `AutoCompanyStore` 기반의 로컬 state machine으로 본다.
  work order는 `Strategic Review`와 `Planning`을
  초안 단계에서 먼저 기록하고,
  `Plan Approval`과 필요 시 `Risk Gate`가 해제되면
  `Execution -> Evaluation -> Revision -> Completion`을
  추가 승인 요청 없이 자동 연속 실행한다.
  앱 재시작 후에도
  로컬 JSON 상태를 다시 읽어
  재개 가능한 order는 runner를 이어간다.
* **Reason:** 사용자가 요구한 핵심은
  완전자율 회사가 아니라
  승인된 오더를 합의된 종료 단계까지
  자동 연속 수행하는 통제형 운영 프로그램이기 때문이다.
* **Status:** ACTIVE

### D-034

* **Topic:** HNI v1.1 backend-connected MVP 방향
* **Decision:** v1.1은
  기존 Flutter 데스크톱 앱 위에
  로컬 HTTP backend를 붙인 구조로 확장한다.
  backend는 authoritative snapshot과
  work order mutation endpoint를 제공하고,
  Flutter 앱은 API client + polling 방식으로 연결한다.
  이번 단계의 backend는
  production용 분산 아키텍처가 아니라
  실채널 연동 전 단계의
  검증 가능한 로컬 orchestration backend로 둔다.
* **Reason:** 실채널 연동을 안전하게 설계하려면
  채널 webhook이 붙을 server-side ingress와
  상태 저장/명령 처리 계층이 먼저 있어야 하기 때문이다.
* **Status:** ACTIVE

### D-035

* **Topic:** HNI v1.1 runtime ownership
* **Decision:** v1.1에서는
  work order authoritative state와
  approval 이후 auto-run ownership을
  backend service가 가진다.
  Flutter client는 dashboard, command UI,
  polling-based read model 역할을 맡는다.
  로컬 file mode는 계속 fallback으로 유지한다.
* **Reason:** 실채널이 붙을 위치는 backend여야 하며,
  desktop client가 orchestration owner인 구조로는
  channel ingress와 audit 일관성을 만들기 어렵기 때문이다.
* **Status:** ACTIVE

### D-036

* **Topic:** 실채널 연동 1차 우선순위
* **Decision:** 실채널 1차 연동은
  Telegram command channel을 먼저,
  WhatsApp은 notification 우선 + 제한형 command로 둔다.
  CEO approval 같은 고권한 action은
  backend sender policy 검증을 통과해야만 반영한다.
* **Reason:** Telegram은 command 중심 운용이 단순하고,
  WhatsApp은 정책/템플릿/운영 제약이 더 커서
  1차에는 notification 중심 설계가 안전하기 때문이다.
* **Status:** ACTIVE

### D-037

* **Topic:** GitHub publish 전제조건
* **Decision:** GitHub push를 수행하려면
  최소한 local git remote가 설정되어 있어야 한다.
  remote가 없으면
  작업 산출물은 local commit까지 반영하고,
  push blocker를 문서에 기록한 뒤
  target repository 또는 remote URL이 준비될 때까지 멈춘다.
* **Reason:** remote 없는 저장소에서는
  외부 publish 경로를 추정할 수 없고,
  잘못된 대상에 push하는 것이 더 위험하기 때문이다.
* **Status:** ACTIVE

### D-038

* **Topic:** 현재 저장소의 GitHub publish target
* **Decision:** 현재 `mozzy-ai-team` 작업 저장소의
  canonical GitHub remote는
  `https://github.com/jbak2588/mozzy-ai-team.git`로 둔다.
  기본 publish branch는 `main`이다.
* **Reason:** 사용자가 대상 repository를 생성했고,
  local root commit과 후속 문서 반영 commit을
  이 remote의 `main`으로 push했기 때문이다.
* **Status:** ACTIVE

### D-039

* **Topic:** Telegram 실연동 v1.2 구현 범위
* **Decision:** Telegram 실연동은
  `hni_auto_company_mvp`의 backend에
  비프로덕션 기준으로 구현한다.
  범위는
  webhook ingress route,
  sender identity 정규화,
  secret header 검증,
  Telegram API status helper,
  inbound command -> backend action 변환,
  outbound reply / completion summary dispatch다.
  token, webhook secret, webhook base URL은
  모두 env 또는 dart-define으로만 주입하고
  저장소에는 넣지 않는다.
  실제 production webhook 개통과
  WhatsApp live command는
  이번 범위 밖으로 유지한다.
* **Reason:** 사용자가 요청한 것은
  설계가 아니라 실제 Telegram command channel 구현이지만,
  production 개통은 별도 승인 사안이므로
  backend-ready integration까지만 안전하게 구현해야 하기 때문이다.
* **Status:** ACTIVE

### D-040

* **Topic:** Telegram sender policy 해석
* **Decision:** Telegram sender policy는
  일반 command와 privileged command를 분리한다.
  `status`, `help`, `new_order`는
  sender allowlist 기준으로 보고,
  `approve`, `hold`, `resume`는
  approver allowlist 기준으로 본다.
  approver allowlist가 비어 있으면
  sender allowlist를 재사용한다.
  allowlist가 모두 비어 있으면
  비프로덕션 기본값으로 모두 허용한다.
* **Reason:** 승인/보류/재개는
  일반 조회나 오더 생성보다 높은 권한이 필요하지만,
  현재 단계는 production IAM이 아니라
  backend policy gate로 통제하는 비프로덕션 구현이기 때문이다.
* **Status:** ACTIVE

### D-041

* **Topic:** Flutter 앱 루트 UI action context
* **Decision:** `HniAutoCompanyApp` 같은
  루트 `State`에서
  `MaterialApp` 바깥의 `context`로
  `ScaffoldMessenger.of(context)`나
  `showDialog(context: context)`를 직접 호출하지 않는다.
  루트 action은
  `scaffoldMessengerKey`와 `navigatorKey`를 통해
  app-shell 내부 문맥으로 연결한다.
* **Reason:** 루트 state의 `context`는
  `MaterialApp` 아래의 `ScaffoldMessenger`와 `Navigator`
  ancestor를 보장하지 않으므로,
  runtime에서
  `No ScaffoldMessenger widget found` 같은 예외가 발생할 수 있기 때문이다.
* **Status:** ACTIVE

### D-042

* **Topic:** Telegram 연결 확인 기준
* **Decision:** Telegram 연결 확인은
  세 단계로 본다.
  1. backend status endpoint에서
  bot/webhook 상태가 조회된다.
  2. 필요 시 set-webhook helper로
  webhook URL을 등록한다.
  3. Telegram에서 `/help` 또는 `/status`를 보내면
  bot reply와 dashboard command log가 함께 생긴다.
  production webhook 개통 전에는
  local backend 단독으로는
  cloud Telegram inbound를 받을 수 없으므로,
  외부 HTTPS URL 또는 tunnel이 필요하다는 점을
  명시한다.
* **Reason:** 단순히 token이 설정된 것만으로는
  실연동이 확인되지 않고,
  status 조회 + command roundtrip까지 봐야
  실제 연결 여부를 판정할 수 있기 때문이다.
* **Status:** ACTIVE

### D-043

* **Topic:** HNI dashboard 14-agent 가시화
* **Decision:** Home dashboard에는
  14-agent 전체를 한눈에 볼 수 있는
  `14-Agent Board`를 둔다.
  각 agent는
  역할군, lead title, 원형 persona, Mozzy/HNI 초점을
  함께 표시한다.
* **Reason:** 사용자가 HNI CEO 시점에서
  현재 orchestration 구조의 전체 페르소나를
  대시보드 안에서 직접 확인하길 원하기 때문이다.
* **Status:** ACTIVE

### D-044

* **Topic:** Telegram 개인 계정 연결 해석
* **Decision:** HNI auto-company의 Telegram 연동은
  개인 Telegram 계정 자체를 API client로 연결하는 방식이 아니라,
  별도 Telegram bot을 만든 뒤
  사용자의 개인 계정이 그 bot과 대화하는 방식으로 본다.
  현재 구현의 allowlist 키는
  전화번호가 아니라
  `sender_id`, `username`, `chat_id`다.
  따라서 사용자의 전화번호만으로는
  직접 연동 확인이 불가능하다.
* **Reason:** Telegram Bot API는
  bot token을 기준으로 인증되며,
  현재 HNI backend 구현도
  phone number가 아니라
  sender/chat 식별자로 권한을 판단하기 때문이다.
* **Status:** ACTIVE

### D-045

* **Topic:** 실 Telegram bot token 검증 방식
* **Decision:** 사용자가 제공한 실 Telegram bot token은
  저장소 파일에 기록하지 않고,
  shell runtime에서만 주입해
  `getMe`, `getWebhookInfo`, backend status 검증에 사용한다.
  public webhook 등록이나
  외부 inbound 개통은
  별도 승인 전까지 진행하지 않는다.
* **Reason:** 실 secret을
  repo/문서에 남기지 않으면서도
  bot 유효성과 HNI backend 연동 상태를
  안전하게 검증해야 하기 때문이다.
* **Status:** ACTIVE

### D-046

* **Topic:** Telegram 개인 계정 sender binding 전제조건
* **Decision:** HNI app에서
  개인 Telegram 계정 연결이 완료됐다고 보려면,
  사용자가 먼저 `@hni_mozzy_bot`에
  `/start`, `/help` 같은 메시지를 보내고,
  그로부터 얻은 `username` 또는 `sender_id`
  (`chat_id`는 선택)를 allowlist에 반영해야 한다.
  username이 없으면
  첫 메시지 이후 `getUpdates` 또는 향후 ingress log로
  numeric sender id를 확인한다.
* **Reason:** bot token 검증만으로는
  개인 사용자의 권한 식별자가 생기지 않고,
  실제 sender authorization은
  message-derived identity가 있어야 걸 수 있기 때문이다.
* **Status:** ACTIVE

### D-047

* **Topic:** Telegram 개인 계정 연결 완료 판정의 중간 상태
* **Decision:** 사용자가 bot chat에
  직접 `/start`, 일반 텍스트를 보냈고
  그 메시지가 Telegram `getUpdates`에 보이면,
  이는 bot과 개인 계정 사이의
  sender binding evidence로 본다.
  다만 HNI backend가 webhook ingress만 쓰는 현재 구조에서는
  public HTTPS webhook 또는 polling path가 없으면
  그 단계만으로 app command roundtrip이 완료된 것은 아니다.
* **Reason:** Telegram Bot API queue에
  사용자 메시지가 존재한다는 사실과,
  HNI backend가 그 메시지를 실제 intake했다는 사실은
  서로 다른 단계이기 때문이다.
* **Status:** ACTIVE

### D-048

* **Topic:** Bot username와 sender username 구분
* **Decision:** `@hni_mozzy_bot`는
  HNI가 지시를 보내는 대상 bot handle로 사용한다.
  그러나 이 값은
  개인 사용자의 sender allowlist username이 아니다.
  사용자 계정에 Telegram username이 없으면
  sender authorization은
  `sender_id`와 `chat_id` 기준으로 고정한다.
* **Reason:** bot의 공개 handle과
  실제 명령 발신자의 식별자는 서로 다른 값이며,
  현재 실측 데이터에서도 사용자 쪽 `sender_username`은 비어 있었기 때문이다.
* **Status:** ACTIVE

### D-049

* **Topic:** Telegram non-production intake mode
* **Decision:** public webhook이 없는 로컬 검증 단계에서는
  Telegram intake를 webhook만으로 강제하지 않고,
  backend polling mode를 병행 지원한다.
  polling mode는
  `getUpdates`를 사용해 direct message를 수신하고,
  기존 webhook과 동일한 authorization/command/reply 경로로 넘긴다.
* **Reason:** 현재 사용자는
  bot과 개인 계정의 direct message까지는 확보했지만,
  외부 HTTPS endpoint가 없어
  webhook ingress로는 roundtrip을 완성할 수 없기 때문이다.
* **Status:** ACTIVE

### D-050

* **Topic:** 실 Telegram runtime env 보관 위치
* **Decision:** 실 bot token과
  sender/chat allowlist 값은
  git에 추적되지 않는
  `.hni_auto_company/telegram.local.env`에만 둔다.
  repo 문서에는
  값 자체를 쓰지 않고
  구조와 절차만 기록한다.
* **Reason:** 사용자가 요청한 실제 연결값을
  로컬 실행에는 적용하되,
  secret과 개인 식별자를
  저장소 이력에 남기지 않기 위해서다.
* **Status:** ACTIVE

### D-051

* **Topic:** Telegram polling live verification 기준
* **Decision:** Telegram polling live roundtrip이 성공했다고 보려면
  세 조건을 함께 만족해야 한다.
  1. pending update가 `poll-once` 또는 polling loop로 실제 처리된다.
  2. backend command log에
  sender id/chat id와 함께 결과가 남는다.
  3. 같은 private chat으로
  bot outbound `sendMessage`가 `ok:true`로 확인된다.
* **Reason:** polling intake만으로는
  outbound delivery가 검증되지 않고,
  outbound만으로는 backend intake가 검증되지 않기 때문이다.
* **Status:** ACTIVE

### D-052

* **Topic:** 현재 GitHub publish scope
* **Decision:** 이번 GitHub publish는
  Telegram v1.2 구현, polling mode, dashboard/README/spec/test 변경과
  그에 따른 Flutter macOS workspace 동기화 파일까지 포함한다.
  반면 실 bot token과 개인 식별자가 들어 있는
  `.hni_auto_company/telegram.local.env`는
  계속 로컬 전용으로 남겨 GitHub publish에서 제외한다.
* **Reason:** 사용자가 요청한 기능 변경 전체는
  remote에 반영해야 하지만,
  실 secret/runtime 값은
  local-only 원칙을 계속 지켜야 하기 때문이다.
* **Status:** ACTIVE

### D-053

* **Topic:** Telegram public webhook 배포 준비 원칙
* **Decision:** public webhook 배포 준비는
  placeholder 기반 아티팩트와 문서까지만
  저장소에 추적하고,
  실제 token, secret, sender/chat id,
  실서비스 env 파일은 git에 커밋하지 않는다.
  또한 public webhook profile에서는
  `HNI_TELEGRAM_POLLING_ENABLED=false`를 강제한다.
* **Reason:** 사용자는 공개 도메인 배포 준비물을 원하지만,
  production secret과 실운영 값은
  문서/예제 파일에 남기면 안 되며,
  polling과 webhook 동시 운영은
  Telegram update source를 혼동시킬 수 있기 때문이다.
* **Status:** ACTIVE

### D-054

* **Topic:** 공개 webhook 배포 경계
* **Decision:** 이번 범위는
  `ai.humantric.net` 예시 기준의
  nginx reverse proxy, systemd service, env example,
  helper script, deployment guide 준비까지로 제한한다.
  실제 DNS 연결, TLS 발급,
  reverse proxy 적용, public webhook 등록은
  production/system-facing action이므로
  사용자가 서버에서 별도로 수행한다.
* **Reason:** 현재 승인 범위는 배포 준비 아티팩트 생성이지,
  실제 외부 노출이나 서버 설정 집행이 아니기 때문이다.
* **Status:** ACTIVE

### D-055

* **Topic:** `bling` 병렬 제어 해석
* **Decision:** 현재 HNI auto-company MVP는
  `bling`을 병렬 작업 대상으로
  문서상/운영상 추적할 수는 있지만,
  실제 repo를 직접 제어하는 live control plane은 아니다.
  현재 구현은 work order, branch/product target, channel intake까지이며,
  GitHub live sync와 다중 repo 실행 제어는
  아직 범위 밖으로 유지한다.
* **Reason:** 프로그램 스펙에는
  `GitHub repo links`, `Mozzy repo state read model`이 있지만,
  v1.1 범위 문서에서는
  `GitHub live sync`가 명시적으로 out of scope이기 때문이다.
* **Status:** ACTIVE

### D-056

* **Topic:** `bling` landing과 Telegram 내부 도메인 연결 방식
* **Decision:** `bling/public/index.html`은
  `humantric.net` 루트용 정적 landing page일 뿐이며,
  그 파일 자체로 Telegram webhook/internal domain endpoint를
  수용할 수는 없다.
  Telegram용 내부 도메인은
  별도 subdomain 예: `ai.humantric.net`로 분리하거나,
  같은 host를 쓸 경우
  `firebase.json` catchall rewrite보다 앞선
  전용 backend rewrite/proxy를 추가해야 한다.
* **Reason:** 현재 Firebase Hosting은
  `/app/** -> /app/index.html`,
  그 외 `** -> /index.html`로 고정돼 있어
  별도 backend route가 없으면
  Telegram path도 landing page로 흡수되기 때문이다.
* **Status:** ACTIVE

### D-057

* **Topic:** HNI 공개 도메인 정식 분리 원칙
* **Decision:** 공개 운영 구조는
  `humantric.net`을 Mozzy/HNI marketing landing과
  web preview 진입점으로 유지하고,
  `ai.humantric.net`을
  HNI auto-company control plane과
  Telegram webhook/backend 전용 도메인으로 분리한다.
  landing host에는
  Telegram webhook를 직접 수용하지 않고,
  필요한 경우 CTA나 deep link만 둔다.
* **Reason:** Firebase Hosting catchall rewrite 구조와
  backend secret/webhook 운영 요구를 분리해야
  routing 충돌과 보안 혼선을 줄일 수 있기 때문이다.
* **Status:** ACTIVE

### D-058

* **Topic:** `ai.humantric.net` route namespace 원칙
* **Decision:** `ai.humantric.net`에서는
  operator UI를 `/dashboard/**`,
  auth flow를 `/auth/**`,
  application API를 `/api/v1/**`,
  Telegram integration을 `/api/v1/integrations/telegram/**`
  아래로 고정한다.
  root `/`는
  dashboard 진입 redirect 또는
  최소 소개/health entry로만 사용한다.
* **Reason:** future web dashboard를 붙일 때
  UI route와 webhook/API route가 섞이면
  reverse proxy, auth, observability 구성이 불안정해지기 때문이다.
* **Status:** ACTIVE

### D-059

* **Topic:** future web dashboard 권한 계층
* **Decision:** future web dashboard의 기본 권한 계층은
  `Public -> Operator -> Lead -> Approver -> CEO -> Admin -> Machine`
  순서로 둔다.
  `/dashboard/**`는 최소 Operator부터,
  전략/승인 관련 route는 Approver 또는 CEO,
  webhook는 Machine 전용으로 본다.
* **Reason:** 화면별 권한을 ad-hoc로 붙이면
  route 설계와 auth gate가 쉽게 흔들리므로,
  일관된 상위 role 계층이 먼저 있어야 하기 때문이다.
* **Status:** ACTIVE

### D-060

* **Topic:** repository bootstrap 해석
* **Decision:** 현재 `main.dart`의
  `apiBaseUrl.isEmpty ? FileAppRepository() : HttpAppRepository(...)`
  분기는
  `로컬 단독 실행`과 `backend-connected 실행`을 가르는
  v1.1용 runtime mode selector로 해석한다.
  future web/dashboard 단계에서는
  file repository를 기본값으로 확장하지 않고,
  명시적 mode validation 또는 factory로 진화시키는 방향을 기본 원칙으로 둔다.
* **Reason:** `API_BASE_URL` 유무만으로는
  v1.1 desktop에는 충분하지만,
  future web/admin/runtime profile이 늘어나면
  mode 해석이 모호해질 수 있기 때문이다.
* **Status:** ACTIVE

### D-061

* **Topic:** future web dashboard의 human auth 방식
* **Decision:** `ai.humantric.net`의
  human operator 인증은
  OIDC Authorization Code + PKCE를 기본으로 두고,
  토큰을 브라우저 장기 저장소에 직접 남기기보다
  server-issued session cookie 기반으로 운영하는 방향을
  기본 원칙으로 둔다.
  Telegram webhook 같은 machine path는
  이 human OIDC 세션과 분리한다.
* **Reason:** control plane은
  일반 공개 웹보다 보안 민감도가 높고,
  same-origin dashboard/API 구조에서는
  server-side session이 route gate와
  ops 보호 정책을 더 단순하게 만들기 때문이다.
* **Status:** ACTIVE

### D-062

* **Topic:** HNI auth provider 선택 우선순위
* **Decision:** future web dashboard의
  auth provider는
  "기존 HNI workforce IdP 재사용 여부"를
  최우선 기준으로 본다.
  별도 신규 선택이 필요하면
  1차 비교축은
  `OIDC + PKCE 적합성`,
  `group/role claim 매핑`,
  `MFA/step-up`,
  `운영 난이도`,
  `ai.humantric.net same-origin session 적합성`으로 둔다.
* **Reason:** provider를 브랜드 선호로 먼저 고르면
  실제 내부 운영체계와
  role mapping 요구가 뒤로 밀리기 때문이다.
* **Status:** ACTIVE

### D-063

* **Topic:** auth provider provisional recommendation
* **Decision:** 현재 문서 기준 provisional recommendation은
  "기존 workforce IdP 재사용 우선"이고,
  신규 선택이 필요하면
  internal operator dashboard 중심에서는
  `Microsoft Entra ID`와 `Okta`를 primary candidate로,
  B2B 조직 분리와 강한 extensibility가 핵심이면
  `Auth0`를 conditional candidate로 본다.
  `Google Cloud Identity Platform / IAP` 경로는
  control plane을 Google Cloud 운영모델에 더 강하게 붙일 때만
  별도 검토한다.
* **Reason:** 현재 HNI 요구는
  외부 대고객 identity보다
  내부 operator control plane, role mapping,
  step-up protection과 더 가깝기 때문이다.
* **Status:** ACTIVE

### D-064

* **Topic:** future web dashboard wireframe 원칙
* **Decision:** `ai.humantric.net`의
  future web dashboard wireframe은
  marketing-style landing이 아니라
  desktop-first internal ops console로 설계한다.
  핵심 화면은
  `좌측 고정 nav + 상단 context bar + 중앙 primary pane + 우측 secondary pane`
  기준의 split-pane 구조를 우선한다.
* **Reason:** HNI control plane은
  미려한 소개형 화면보다
  order, approval, report, channel 상태를
  동시에 읽고 조작하는 밀도 높은 운영 화면이 더 적합하기 때문이다.
* **Status:** ACTIVE

### D-065

* **Topic:** auth provider integration sequencing 원칙
* **Decision:** provider별 integration sequence는
  vendor SDK 중심으로 화면 로직을 퍼뜨리기보다,
  `provider registration -> redirect/callback ->`
  `code exchange -> claim normalization ->`
  `internal session issue`
  순서의
  HNI 공통 control plane 흐름으로 정리한다.
  provider 차이는
  등록값, issuer/endpoint, logout 규칙,
  claim source 차이로 국한한다.
* **Reason:** 실제 provider가 바뀌어도
  HNI backend의 session/role 모델은
  최대한 동일해야
  향후 구현과 교체 비용이 낮아지기 때문이다.
* **Status:** ACTIVE

### D-066

* **Topic:** future web dashboard component 분해 원칙
* **Decision:** future web dashboard component map은
  `route-aligned feature modules + shared control-shell components`
  구조를 기본으로 둔다.
  즉 `/dashboard/orders`, `/dashboard/approvals`,
  `/dashboard/channels` 같은
  업무 화면은 feature module로 자르고,
  nav/topbar/session banner/command dock는
  공통 shell component로 유지한다.
* **Reason:** control plane은
  route별 책임 경계가 분명해야 하고,
  shell과 feature를 섞으면
  auth gate, API contract, UI 상태 관리가 쉽게 비대해지기 때문이다.
* **Status:** ACTIVE

### D-067

* **Topic:** web implementation backlog 우선순위
* **Decision:** future web dashboard의
  첫 구현 순서는
  `app_shell -> auth/session -> home -> orders -> approvals -> channels`
  를 기본값으로 둔다.
  이후 `reports -> mozzy_board -> strategy/squads/audit`
  순서로 확장한다.
* **Reason:** control plane의
  첫 운영 가치는 로그인 이후
  작업 현황, 승인, 채널 상태를
  빠르게 읽고 조작하는 데서 먼저 나오기 때문이다.
* **Status:** ACTIVE

### D-068

* **Topic:** provider 구현 전략
* **Decision:** web 구현 첫 단계에서는
  multi-provider 동시 지원보다
  HNI 공통 auth contract와
  primary provider adapter 1개를 먼저 완성한다.
  두 번째 provider는
  session/role contract가 닫힌 뒤에만 추가한다.
* **Reason:** provider abstraction을
  구현 전부터 넓게 열어두면
  callback, logout, role mapping, recent-auth가
  동시에 흔들릴 가능성이 커지기 때문이다.
* **Status:** ACTIVE

### D-069

* **Topic:** auth/session API boundary
* **Decision:** future web dashboard의
  human auth 계약은
  browser redirect route는 `/auth/*`,
  JSON session discovery/termination은
  `/api/v1/session`과 `/api/v1/session/logout`
  으로 분리한다.
  provider redirect와 callback은 browser route가 담당하고,
  frontend bootstrap과 route gate는
  same-origin session endpoint를 기준으로 상태를 읽는다.
* **Reason:** OIDC redirect와 UI bootstrap을
  한 endpoint 계층에 섞으면
  browser navigation과 JSON contract가 함께 흔들리기 때문이다.
* **Status:** ACTIVE

### D-070

* **Topic:** session contract shape
* **Decision:** session API는
  `HttpOnly + Secure + SameSite` session cookie를 기준으로 하고,
  `GET /api/v1/session`에서
  `authenticated`, `principal`, `capabilities`,
  `expiresAt`, `recentAuthExpiresAt`, `csrfToken`
  형태의 same-origin bootstrap payload를 반환한다.
  mutating API는
  session cookie 외에 `X-HNI-CSRF-Token`을 요구한다.
* **Reason:** HNI control plane은
  browser token 저장을 최소화하면서도
  route gate, capability rendering,
  CSRF 보호를 동시에 만족해야 하기 때문이다.
* **Status:** ACTIVE

### D-071

* **Topic:** Mozzy-ai-team vNext 제품 정의
* **Decision:** `Mozzy-ai-team`은
  HNI용 `HNI-auto-company`를
  web + channel 기반으로 확장한
  14-persona AI agent 협업 control plane으로 정의한다.
  루트 `README.md`도 이 정의를 기준으로
  제품/아키텍처/로드맵/문서 허브 역할로 재작성한다.
* **Reason:** 현재 저장소는 이미
  desktop MVP, Telegram, web spec, backend 구조를 포함하고 있어
  단순 운영 문서 저장소 설명으로는
  실제 제품 범위를 반영하지 못하기 때문이다.
* **Status:** ACTIVE

### D-072

* **Topic:** Gemini 실행 엔진 위치
* **Decision:** Gemini 실행 엔진은
  `services/hni_gemini_orchestrator/` 아래의
  same-repo Python service로 둔다.
  Dart backend는
  `HNI_AI_ORCHESTRATOR_BASE_URL`만 알고
  `GEMINI_API_KEY`는 알지 못한다.
* **Reason:** Gemini key를
  Flutter client와 Dart control backend에서 분리해
  server-side secret 경계를 분명히 해야 하기 때문이다.
* **Status:** ACTIVE

### D-073

* **Topic:** Gemini key 정책
* **Decision:** 1차 AI provider는 Gemini 단일 엔진으로 시작하되,
  실제 key는 Python service env에만 두고
  tracked 파일과 Flutter bundle에는 넣지 않는다.
  key가 없을 때는 deterministic fallback으로
  skeleton 검증을 계속할 수 있게 한다.
* **Reason:** 초기 구현에서는
  runtime 연결과 control plane contract를 먼저 닫아야 하고,
  실제 key 주입은 더 높은 운영 통제를 요구하기 때문이다.
* **Status:** ACTIVE

### D-074

* **Topic:** 14-agent 조직도 역할
* **Decision:** 14-agent 조직도는
  read-only 가시화가 아니라
  assign / dispatch / hold / report jump를 포함한
  interactive control panel로 취급한다.
* **Reason:** HNI CEO와 operator가
  조직도에서 바로 작업 흐름을 제어할 수 있어야
  `Mozzy-ai-team`의 차별점이 살아나기 때문이다.
* **Status:** ACTIVE

### D-075

* **Topic:** Flutter web bootstrap 원칙
* **Decision:** Flutter app은
  desktop에서는 file mode fallback을 유지하되,
  web에서는 local file persistence를 사용하지 않고
  same-origin 또는 `API_BASE_URL` 기반의
  HTTP repository만 사용한다.
* **Reason:** web target에서는
  `dart:io` 기반 file persistence가 성립하지 않고,
  control plane도 결국 backend-connected 운영을 전제로 해야 하기 때문이다.
* **Status:** ACTIVE

### D-076

* **Topic:** future web route bootstrap 방식
* **Decision:** future web dashboard의 1차 구현은
  `go_router` 기반 route-driven shell로 진행하고,
  `/dashboard/*` direct route와
  `/auth/*` placeholder route를 먼저 연다.
  실제 OIDC/provider enforcement는
  다음 slice로 미루고,
  이번 단계에서는 browser URL, sidebar navigation,
  web build 안정성만 닫는다.
* **Reason:** web dashboard는
  먼저 deep link와 same-origin shell이 성립해야
  이후 auth/session contract와 route gate를
  실제 코드로 연결할 수 있기 때문이다.
* **Status:** ACTIVE

### D-077

* **Topic:** same-origin auth bootstrap 방식
* **Decision:** 첫 auth 구현 slice는
  외부 OIDC/provider 연동 대신
  same-origin bootstrap session으로 진행한다.
  backend는
  `/api/v1/session`,
  `/api/v1/session/bootstrap`,
  `/api/v1/session/logout`
  JSON endpoint를 제공하고,
  frontend는 이 session payload로
  web route gate를 계산한다.
* **Reason:** provider 연결 전에도
  browser route, role gate, session bootstrap,
  logout/redirect 흐름을 먼저 닫아야
  이후 OIDC adapter를 안전하게 붙일 수 있기 때문이다.
* **Status:** ACTIVE

### D-078

* **Topic:** auth bootstrap 보안 경계
* **Decision:** 이번 same-origin auth slice는
  non-production bootstrap session만 포함하고,
  실제 OIDC/provider 연결과
  business API 전면 role enforcement는
  후속 단계로 남긴다.
  현재 단계의 목적은
  browser shell과 session contract 검증이다.
* **Reason:** 외부 provider와 전면 API gate를
  한 번에 묶으면 인증/인가 변경 영향이 커지므로,
  우선 route bootstrap과 session contract부터
  분리 구현하는 것이 더 안전하기 때문이다.
* **Status:** ACTIVE

### D-079

* **Topic:** business API role enforcement rollout
* **Decision:** same-origin bootstrap 다음 단계의
  인가 강화는 selected business API에 한해
  단계적으로 적용한다.
  현재 1차 enforcement 대상은
  `/api/v1/snapshot`, `/api/v1/orders`,
  approval/hold/resume,
  agent graph assign/dispatch,
  `/api/v1/commands`,
  Telegram status/set/delete/poll-once이며,
  최소 role과 CSRF를 함께 요구한다.
  UI action button도 같은 role matrix로 맞춘다.
  반면 machine ingress인
  Telegram webhook는
  human session/CSRF gate에 넣지 않는다.
* **Reason:** human operator path는
  단계적으로 강화하되,
  live channel ingress와 machine callback까지
  한 번에 같은 gate로 묶으면
  운영 경계가 오히려 불분명해지기 때문이다.
* **Status:** ACTIVE

### D-080

* **Topic:** login-first bootstrap 기본값
* **Decision:** same-origin bootstrap의 기본 동작은
  `defaultAuthenticated=true`가 아니라
  anonymous + explicit bootstrap login으로 둔다.
  `HNI_AUTH_BOOTSTRAP_DEFAULT_AUTHENTICATED` 기본값은
  `false`로 내리고,
  remote web shell은 비로그인 상태에서
  빈 shell로 먼저 기동한 뒤
  login 후 reconnect로 snapshot을 붙인다.
* **Reason:** bootstrap 기본값이
  자동 인증 상태로 남아 있으면
  향후 OIDC/provider 연동 이전에도
  login-first 흐름을 검증할 수 없고,
  stricter auth 방향과도 충돌하기 때문이다.
* **Status:** ACTIVE

### D-081

* **Topic:** provider adapter 1차 범위
* **Decision:** provider adapter 1차는
  browser auth route와 adapter abstraction까지 구현하되,
  현재 지원 모드는
  `bootstrap`과 `mock_oidc`로 제한한다.
  backend는
  `/auth/login`, `/auth/callback`, `/auth/logout`
  route를 제공하고,
  session issuance는 tokenized server-side session map으로 관리한다.
  실제 external provider token exchange와
  production IdP 연결은
  다음 단계로 남긴다.
* **Reason:** route/callback/session issuance 뼈대를 먼저 고정해야
  이후 Entra/Okta/Auth0 같은 실제 provider를 붙일 때
  session/redirect 구조를 다시 뜯지 않아도 되기 때문이다.
* **Status:** ACTIVE

### D-082

* **Topic:** 로컬 프런트엔드 프리뷰 실행 방식
* **Decision:** 사용자가 화면 확인을 요청한 경우
  local preview는
  Dart backend(`127.0.0.1:8787`)와
  Flutter web client를 같은 머신에서 함께 띄우는 방식으로 처리한다.
  가능하면 production 배포 대신
  로컬 browser preview를 우선 사용한다.
* **Reason:** 현재 승인 범위 안에서
  프런트엔드 화면을 가장 빠르고 안전하게 확인하는 방법이
  local backend + web client 조합이기 때문이다.
* **Status:** ACTIVE

### D-083

* **Topic:** backend auth/session 런타임 경계
* **Decision:** `bin/server.dart`에서 사용하는
  auth/session 모델은
  Flutter `foundation`에 의존하지 않는
  pure Dart 계층으로 유지하고,
  `ChangeNotifier` 기반 controller만
  Flutter 쪽에 둔다.
* **Reason:** local backend는
  `dart run bin/server.dart`로 바로 기동 가능해야 하며,
  서버 런타임이 `dart:ui`를 요구하면
  preview와 운영 검증 경로가 즉시 막히기 때문이다.
* **Status:** ACTIVE

### D-084

* **Topic:** local preview 수정 후 최소 검증 기준
* **Decision:** local preview를 위해
  backend/runtime 코드를 손댄 경우
  최소한 `curl /api/v1/session` 응답과
  관련 `flutter test` 타깃을 함께 확인한다.
* **Reason:** 화면만 뜬다고 끝내면
  backend session/bootstrap 경로가
  실제로 깨졌는지 놓치기 쉽기 때문이다.
* **Status:** ACTIVE

### D-085

* **Topic:** local web preview의 cross-origin session 규칙
* **Decision:** `flutter run -d chrome --dart-define=API_BASE_URL=...`
  형태의 local preview에서는
  backend가 loopback origin에 대해
  `OPTIONS` preflight와 credentialed CORS response를 제공해야 한다.
* **Reason:** browser는
  `127.0.0.1:3000 -> 127.0.0.1:8787` 요청을
  cross-origin으로 처리하므로,
  preflight와 `Access-Control-Allow-Credentials`
  없이는 session bootstrap 자체가 실패하기 때문이다.
* **Status:** ACTIVE

### D-086

* **Topic:** Flutter web remote client HTTP 기본값
* **Decision:** Flutter web에서
  `API_BASE_URL`이 비어 있지 않은 remote mode는
  credential 포함 `BrowserClient`를 기본 HTTP client로 사용한다.
  IO/runtime은 기존 일반 `http.Client`를 유지한다.
* **Reason:** session cookie가
  browser credential jar를 통해
  유지/재전송되어야 이후 snapshot/orders/approvals 호출도
  같은 로그인 상태를 재사용할 수 있기 때문이다.
* **Status:** ACTIVE

### D-087

* **Topic:** 현재 로컬 상태 publish 범위 해석
* **Decision:** 사용자가
  "현재 로컬상태 커밋 + 푸시"를 명시적으로 요청한 경우,
  현재 worktree 전체를
  하나의 publish scope로 보고
  해당 상태 그대로 커밋/푸시한다.
* **Reason:** 이 표현은
  부분 파일 선택보다
  현 시점의 전체 로컬 상태 반영 의도가 더 강하므로,
  범위를 다시 쪼개 묻는 것보다
  그대로 반영하는 쪽이 사용자 의도에 더 가깝기 때문이다.
* **Status:** ACTIVE

### D-088

* **Topic:** commit+push 요청과 `gh` 부재 처리
* **Decision:** 사용자가
  PR이 아니라
  commit+push만 요청한 경우에는
  `gh` CLI 부재를 blocker로 보지 않고
  표준 `git push`로 publish를 진행한다.
* **Reason:** 이번 범위의 필수 동작은
  원격 branch 반영이며,
  이는 GitHub CLI 없이도
  기존 origin remote로 충분히 수행 가능하기 때문이다.
* **Status:** ACTIVE

---

## Open Questions

* 아직 없음
