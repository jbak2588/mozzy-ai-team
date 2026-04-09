# Mozzy Neighborhood Read Slice Smoke Checklist

## Purpose

- 이 문서는
  `V2-SLICE-01 Neighborhood Dashboard Read`용
  세부 smoke checklist다.
- 목적은 full V2 acceptance가 아니라,
  neighborhood dashboard의
  read-only capability를
  additive route 기준으로 검증하는 것이다.

## Scope

- 대상 slice:
  `Neighborhood Dashboard Read`
- 관련 문서:
  `MOZZY_V2_FIRST_MERGE_SLICE.md`
  `MOZZY_CORE_SMOKE_VERIFICATION_PLAN.md`
- 핵심 경로:
  boot -> auth -> dashboard entry ->
  load/refresh -> detail 이동 -> back

## Preconditions

### P-01 Workspace

- 브랜치가 대상 작업선인지 확인
- `flutter pub get` 완료
- `secrets.local.json` 존재 확인

### P-02 Secret Hygiene

- tracked admin SDK 파일을 입력으로 사용하지 않음
- 비프로덕션 계정 또는 emulator만 사용

### P-03 Test Baseline

- 권장 자동 체크:
  `flutter analyze`
- 권장 자동 체크:
  `flutter test test/features/neighborhood/neighborhood_service_test.dart`

### P-04 Device Baseline

- 최소 1개 mobile emulator 또는 test device
- 가능하면 작은 화면 1개, 큰 화면 1개

## Evidence Pack

- Smoke Run ID
- Branch / Commit
- Device / OS
- Entry path
- Executed checks
- Pass / Fail
- Screenshot 또는 짧은 녹화
- 실패 로그
- blocker severity

## Checklist

### NRS-01 Boot

- Goal:
  앱이 crash 없이 시작되는지 확인
- Steps:
  1. 대상 entry로 실행
  2. splash 또는 첫 화면 로딩 확인
  3. startup error log 확인
- Pass:
  fatal crash 없음
- Evidence:
  boot capture + console log

### NRS-02 Auth Gate

- Goal:
  로그인 후 dashboard 진입 dead end가 없는지 확인
- Steps:
  1. 테스트 계정 로그인
  2. 기본 홈 또는 제한 entry 도달
  3. 무한 로딩/빈 화면 여부 확인
- Pass:
  auth 이후 usable screen 도달
- Evidence:
  auth success capture

### NRS-03 Entry Availability

- Goal:
  neighborhood dashboard 진입점이 실제로 동작하는지 확인
- Steps:
  1. launcher / location / deep link 중
     설계된 진입점을 사용
  2. dashboard route 이동 확인
  3. route not found 여부 확인
- Pass:
  2탭 이내 또는 설계된 deep link로 진입 가능
- Evidence:
  entry path capture

### NRS-04 Loading State

- Goal:
  첫 로딩 상태가 깨지지 않는지 확인
- Steps:
  1. dashboard 첫 진입
  2. spinner 또는 skeleton 노출 확인
  3. 로딩 종료 여부 확인
- Pass:
  무한 로딩 없이 완료 또는 error/empty로 전이
- Evidence:
  loading capture

### NRS-05 Dashboard Render

- Goal:
  기본 구조가 정상 렌더되는지 확인
- Steps:
  1. app bar title 확인
  2. stats grid 확인
  3. section block 또는 empty state 확인
- Pass:
  title + stats + body 구조 중단 없이 표시
- Evidence:
  full screen capture

### NRS-06 Refresh

- Goal:
  pull-to-refresh가 정상 동작하는지 확인
- Steps:
  1. dashboard에서 refresh 수행
  2. spinner 노출 확인
  3. 화면 복귀 확인
- Pass:
  refresh 후 screen recovery
- Evidence:
  refresh capture

### NRS-07 Empty State

- Goal:
  데이터가 적은 지역에서도 화면이 깨지지 않는지 확인
- Steps:
  1. 빈 결과 가능 지역 진입
  2. section 미노출 또는 empty state 확인
  3. layout 깨짐 여부 확인
- Pass:
  빈 데이터에서도 usable layout 유지
- Evidence:
  empty-state capture

### NRS-08 Error Handling

- Goal:
  query 실패 시 fallback이 동작하는지 확인
- Steps:
  1. 네트워크 제한 또는 잘못된 지역 조건 사용
  2. 에러 메시지 또는 fallback 확인
  3. 앱 전체 freeze 여부 확인
- Pass:
  error가 local screen 범위에 머무름
- Evidence:
  error capture + log

### NRS-09 Section Integrity

- Goal:
  섹션별 카드가 잘못된 타입으로 섞이지 않는지 확인
- Steps:
  1. news/products/jobs/shops/together/lost-found 확인
  2. 제목과 썸네일 매칭 확인
  3. 중복 카드 과다 노출 확인
- Pass:
  섹션 라벨과 카드 타입이 대체로 일치
- Evidence:
  section capture

### NRS-10 Detail Navigation

- Goal:
  카드 탭 후 detail 이동이 가능한지 확인
- Steps:
  1. 카드 1개 선택
  2. detail screen 이동 확인
  3. back navigation 확인
- Pass:
  detail 진입 후 원위치 복귀 가능
- Evidence:
  nav capture

### NRS-11 Location Accuracy

- Goal:
  표시 지역과 실제 query 대상이 크게 어긋나지 않는지 확인
- Steps:
  1. 선택 지역명 기록
  2. title / app bar / 결과 카드 지역성 확인
  3. 명백한 타 지역 데이터 혼입 여부 확인
- Pass:
  지역 mismatch가 명백하지 않음
- Evidence:
  location capture

### NRS-12 V1 Non-Regression

- Goal:
  slice 추가가 V1 기본 흐름을 깨지 않는지 확인
- Steps:
  1. dashboard 진입 전후로 V1 홈 복귀
  2. launcher 또는 주요 탭 재사용
  3. chat/feed 등 기존 진입점 1개 재확인
- Pass:
  V1 핵심 흐름 유지
- Evidence:
  before/after capture

## Exit Rule

- 아래 중 하나라도 실패하면
  neighborhood slice는 `FAIL`
- dashboard route 자체 진입 실패
- 무한 로딩
- refresh 후 recovery 실패
- detail/back navigation 실패
- V1 기본 흐름 회귀

## Severity Guide

- `Blocker`:
  route 진입 불가, crash, 무한 로딩, back 불가
- `Major`:
  section 다수 비정상, 지역 mismatch 명확, refresh 불안정
- `Minor`:
  일부 empty copy 이상, 경미한 UI 어긋남

## Run Order

1. `NRS-01`
2. `NRS-02`
3. `NRS-03`
4. `NRS-04`
5. `NRS-05`
6. `NRS-06`
7. `NRS-07`
8. `NRS-08`
9. `NRS-09`
10. `NRS-10`
11. `NRS-11`
12. `NRS-12`

## Current Recommendation

- 첫 실행은 내부 테스트 계정 1개와
  데이터가 있는 지역 1곳,
  빈 지역 1곳으로 나눠 수행한다.
- smoke 통과 전에는
  discovery, trust, shell replacement slice로 넘어가지 않는다.
