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

---

## Open Questions

* 아직 없음
