# Mozzy Core Smoke Verification Plan

## Purpose

- 이 문서는 Mozzy의 core smoke verification 절차를 정의한다.
- V1은 `main` 안정화용 smoke plan으로 본다.
- V2는 `hyperlocal-proposal` 병합 전 smoke plan으로 본다.

## Operating Assumptions

- smoke는 비프로덕션 환경에서만 수행한다.
- 실제 배포, 실제 결제, 실사용자 데이터 사용은 제외한다.
- smoke 결과는 merge 판단 보조 근거이며,
  전체 QA 대체물이 아니다.

## Environment Policy

### Allowed

- 로컬 debug/profile 실행
- 에뮬레이터 또는 테스트 기기
- Firebase emulator 또는 별도 테스트 프로젝트
- `secrets.local.json` 기반 local secrets 주입

### Not Allowed

- production 배포
- production 결제
- production user data write
- tracked secret 파일 재사용을 전제로 한 검증

## Local Run Baseline

- 의존성 설치:
  `flutter pub get`
- 기본 로컬 실행:
  `flutter run`
- secrets 파일 기반 실행:
  `./scripts/run_local.sh`
  또는 `./scripts/run_local.ps1`
- V2 entry 실행:
  `flutter run -t lib/main_mozzy_ii.dart --dart-define-from-file=secrets.local.json`

## Evidence Rules

- 각 smoke run마다 아래 증적을 남긴다.
  - 실행 브랜치 / commit SHA
  - 실행 기기 / OS
  - 실행 커맨드
  - pass/fail
  - 실패 로그 캡처
  - 화면 캡처 또는 짧은 녹화
- blocker가 열린 항목은
  "재현 여부 + 차단 수준 + 임시 우회 가능 여부"를 같이 적는다.

## Global Exit Rule

- 아래 항목 중 하나라도 실패하면
  해당 smoke run은 `FAIL`이다.
  - startup crash
  - auth dead end
  - 핵심 화면 무한 로딩
  - 위치/피드/신뢰 핵심 경로 진입 실패
  - secret hygiene 위반

## Phase 0 Preflight

### P0-01 Workspace

- branch가 맞는지 확인한다.
- `flutter pub get` 완료 여부를 확인한다.
- `secrets.local.json` 존재 여부를 확인한다.

### P0-02 Secret Hygiene

- `functions-v2/bling-app-firebase-adminsdk.json`를
  smoke 입력으로 쓰지 않는다.
- 필요한 경우 환경 변수 또는 별도 비공개 파일만 사용한다.

### P0-03 App Check / Maps

- README 기준으로
  local debug/profile은 App Check debug provider를 사용한다.
- `GOOGLE_MAPS_API_KEY`,
  `GOOGLE_SERVER_API_KEY`,
  `GOOGLE_STATIC_MAP_API_KEY`가
  `secrets.local.json` 또는 local config로 주입되어야 한다.

### P0-04 Automated Preflight

- 공통:
  - `flutter analyze`
- V1 권장:
  - `flutter test test/features/auth/auth_gate_test.dart`
  - `flutter test test/integration/trust_system_test.dart`
  - `flutter test test/ai_final_report_screen_test.dart`
  - `flutter test test/widget_test.dart`
- V2 권장:
  - `flutter test test/core/services/smart_feed_service_test.dart`
  - `flutter test test/features/neighborhood/neighborhood_service_test.dart`
  - `flutter test test/mozzy_ii/discovery/global_relay_service_test.dart`
  - `flutter test test/mozzy_ii/discovery/cross_link_service_test.dart`
  - `flutter test test/mozzy_ii/trust/trust_score_service_test.dart`
  - `flutter test test/mozzy_ii/monetization/wallet_service_test.dart`

## V1 Core Smoke

### V1 Goal

- `main`이 내부초청 필드 테스트 baseline으로
  계속 유지 가능한지 본다.

### V1 Entry

- 기본 entry:
  `flutter run --dart-define-from-file=secrets.local.json`
- 권장:
  `./scripts/run_local.sh`
  또는 `./scripts/run_local.ps1`

### V1 Smoke Matrix

| ID | Area | Check | Pass Condition | Evidence |
| --- | --- | --- | --- | --- |
| V1-S01 | Startup | app boot | splash -> auth 또는 home 진입 | capture + log |
| V1-S02 | Auth | auth gate | login/signup dead end 없음 | capture |
| V1-S03 | Launcher | main nav | 탭/런처 기본 이동 가능 | capture |
| V1-S04 | Feed | main/local feed | 목록 또는 empty state 정상 | capture |
| V1-S05 | Location | filter | 지역 필터 변경 후 화면 반응 | capture |
| V1-S06 | Trust | trust path | trust 관련 화면/상태 접근 가능 | capture |
| V1-S07 | Marketplace AI | AI entry | AI 진입/요청 전 단계 오류 없음 | capture + log |
| V1-S08 | Chat | messaging path | 채팅 목록 또는 방 진입 가능 | capture |

### V1 Optional Smoke

- 로컬 함수 smoke:
  `node scripts/smoke_generatefinalreport.js`
- 조건:
  Firebase emulator 또는 별도 테스트 프로젝트가 준비된 경우만

### V1 Fail Handling

- `V1-S01`~`V1-S03` 중 하나라도 실패하면
  baseline 유지 판단을 보류한다.
- `V1-S04`~`V1-S08` 실패는
  blocker severity를 나눠 기록한다.

## V2 Core Smoke

### V2 Goal

- `hyperlocal-proposal`을 full merge하지 않고도
  core loop와 merge slice 검증이 가능한지 본다.

### V2 Entry

- V2 entry:
  `flutter run -t lib/main_mozzy_ii.dart`
  `--dart-define-from-file=secrets.local.json`

### V2 Smoke Matrix

| ID | Area | Check | Pass Condition | Evidence |
| --- | --- | --- | --- | --- |
| V2-S01 | Boot | V2 entry boot | crash 없이 shell 진입 | capture + log |
| V2-S02 | Auth->Shell | auth flow | shell dead end 없음 | capture |
| V2-S03 | Home | home render | 핵심 card 또는 empty state 정상 | capture |
| V2-S04 | Explore/Map | nav render | 탭 이동과 기본 렌더 정상 | capture |
| V2-S05 | Smart Feed | discovery | feed 또는 empty state 정상 | capture + log |
| V2-S06 | Relay | geo/relay UI | scope 전환 UI 오류 없음 | capture |
| V2-S07 | Neighborhood | dashboard | 대시보드 진입과 새로고침 정상 | capture |
| V2-S08 | Trust | trust path | trust 관련 상태 접근 가능 | capture |
| V2-S09 | Wallet | monetization path | wallet read path 정상 | capture |
| V2-S10 | Fallback | empty/loading | 무한 로딩 없이 fallback 처리 | capture |

### V2 Slice Rule

- V2 smoke는 full branch acceptance가 아니라
  slice readiness 판단용으로 쓴다.
- 첫 smoke slice는
  `Neighborhood Dashboard` 중심의 read-only slice로 고정한다.
- 이 slice는 full shell replacement가 아니라
  기존 V1 위에 가산적으로 붙는
  limited capability 검증으로 본다.

### V2 Optional Smoke

- targeted smoke를 slice 단위로 반복한다.
- 첫 slice 예:
  - neighborhood read slice면 `V2-S01`, `V2-S02`, `V2-S07`, `V2-S10`
- 후속 slice 예:
  - discovery slice면 `V2-S03`~`V2-S06`
  - trust slice면 `V2-S08`

### V2 Fail Handling

- `V2-S01`~`V2-S03` 중 하나라도 실패하면
  slice merge 논의를 중단한다.
- `V2-S05`~`V2-S10` 실패는
  해당 slice blocker로 직접 연결한다.

## Reporting Template

- Smoke Run ID:
- Branch / Commit:
- Device / OS:
- Environment:
- Scope: V1 baseline / V2 slice
- Checks Executed:
- Passed:
- Failed:
- Blockers Opened:
- Screenshots / Video:
- Logs:
- Recommendation:

## Current Recommendation

1. 먼저 V1 smoke를 고정해 `main` 기준선을 안정화한다.
2. 다음으로 V2 전체가 아니라
   `Neighborhood Dashboard` read-only slice를 먼저 검증한다.
3. 선택한 slice에만 V2 smoke를 적용한다.
4. smoke 통과 전에는 `hyperlocal-proposal` full merge를 진행하지 않는다.
5. neighborhood slice 실행 시에는
   `MOZZY_NEIGHBORHOOD_READ_SLICE_SMOKE_CHECKLIST.md`를 사용한다.
