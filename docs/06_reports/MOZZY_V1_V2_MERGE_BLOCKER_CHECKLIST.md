# Mozzy V1/V2 Merge Blocker Checklist

## Purpose

- 이 문서는 V1과 V2의 merge blocker를
  gate 형태로 정리한다.
- V1은 `main` 안정화 게이트로 본다.
- V2는 `hyperlocal-proposal -> main` 병합 게이트로 본다.

## Evidence Base

- `MOZZY_V1_PRODUCT_REPORT_DRAFT.md`
- `MOZZY_V2_PRODUCT_REPORT_DRAFT.md`
- `MOZZY_V1_ENGINEERING_REPORT_DRAFT.md`
- `MOZZY_V2_ENGINEERING_REPORT_DRAFT.md`

## Status Legend

- `OPEN`: blocker가 열려 있어 병합 또는 기준선 확정을 막는다.
- `PARTIAL`: 일부 근거는 있으나 아직 병합 가능 상태는 아니다.
- `DONE`: blocker 해제 조건이 충족됐다.
- `DEFERRED`: 현재 merge slice 밖으로 의도적으로 뺐다.

## V1 Baseline Gate

### V1-01 Bootstrap 집중도

- Status: `OPEN`
- Why It Blocks:
  `lib/main.dart`가 `809` lines로 커서
  startup 문제의 원인 추적과 회귀 관리가 어렵다.
- Evidence:
  `MOZZY_V1_ENGINEERING_REPORT_DRAFT.md`
- Clear When:
  bootstrap 책임을 문서화하고,
  최소한 startup smoke check가 통과해야 한다.
- Owner Group:
  엔지니어링군

### V1-02 상태관리 혼합

- Status: `OPEN`
- Why It Blocks:
  `get`, `provider`, `riverpod`가 공존해
  구조 기준이 흔들린다.
- Evidence:
  V1 엔지니어링 초안에서
  `package:get/get.dart` import `3`건,
  provider import `40`건,
  riverpod 관련 hit `30`건 확인
- Clear When:
  유지 기준 패턴을 명시하고,
  신규 수정은 한 패턴으로 제한해야 한다.
- Owner Group:
  엔지니어링군

### V1-03 Smoke Test 기준 부재

- Status: `OPEN`
- Why It Blocks:
  `test/` 파일은 `8`개만 확인됐고,
  필드 테스트 핵심 경로의 통과 기준이 없다.
- Evidence:
  V1 엔지니어링 초안
- Clear When:
  아래 경로의 smoke 기준이 체크리스트로 고정돼야 한다.
  `auth gate`, `launcher`, `main feed`,
  `marketplace AI`, `chat notification`
- Owner Group:
  엔지니어링군 + 제품군

### V1-04 Secret Hygiene

- Status: `OPEN`
- Why It Blocks:
  `functions-v2/bling-app-firebase-adminsdk.json` 경로가
  브랜치 기준으로 추적 중이다.
- Evidence:
  V1 엔지니어링 초안
- Clear When:
  실제 키 파일 제거 여부,
  대체 로딩 방식,
  비밀정보 관리 원칙이 확인돼야 한다.
- Owner Group:
  엔지니어링군 + 전략군

### V1-05 핵심 제품 기준선 미고정

- Status: `OPEN`
- Why It Blocks:
  V1은 기능 폭이 넓지만
  어떤 feature가 baseline인지 확정돼 있지 않다.
- Evidence:
  V1 제품군 초안의
  feature-first 구조와 use case 불명확성
- Clear When:
  필드 테스트 핵심 feature와
  보조 feature를 분리한 baseline 표가 필요하다.
- Owner Group:
  제품군

### V1-06 Location / Query 안정성 확인 부족

- Status: `PARTIAL`
- Why It Blocks:
  위치 기반 필터와 AI 검수 흐름이
  Firestore index와 쿼리에 크게 의존한다.
- Evidence:
  V1 엔지니어링 초안,
  `firestore.indexes.json` index `263`개
- Clear When:
  핵심 지역 필터 경로와
  느린 쿼리 가능 구간을 점검해야 한다.
- Owner Group:
  엔지니어링군

## V2 Merge Gate

### V2-01 Full Branch Merge 금지 기본값

- Status: `OPEN`
- Why It Blocks:
  `23` commits ahead,
  `339` files changed 규모라
  full merge는 기본값이 될 수 없다.
- Evidence:
  V2 제품군/엔지니어링군 초안
- Clear When:
  전체 병합 대신
  capability slice 기준 병합 전략이 먼저 정의돼야 한다.
- Owner Group:
  전략군 + 엔지니어링군

### V2-02 Runtime Validation 부재

- Status: `OPEN`
- Why It Blocks:
  smart feed, relay, trust, neighborhood 관련 파일과
  테스트 파일은 보이지만
  실제 앱 실행 검증은 아직 없다.
- Evidence:
  V2 엔지니어링 초안
- Clear When:
  `main_mozzy_ii.dart` 기준의
  core smoke run 결과가 필요하다.
- Owner Group:
  엔지니어링군

### V2-03 Dual Shell 공존

- Status: `OPEN`
- Why It Blocks:
  `main.dart`와 `main_mozzy_ii.dart`가 공존해
  진입 전략이 아직 닫히지 않았다.
- Evidence:
  V2 엔지니어링 초안
- Clear When:
  V2 shell이 실험선인지,
  대체 shell인지,
  공존 기간이 얼마인지 결정해야 한다.
- Owner Group:
  제품군 + 엔지니어링군

### V2-04 상태관리 단일화 미완료

- Status: `OPEN`
- Why It Blocks:
  Riverpod 확장 방향은 보이지만
  provider와 `get` 흔적이 남아 있다.
- Evidence:
  V2 엔지니어링 초안에서
  riverpod hit `55`건,
  provider import `42`건,
  `package:get/get.dart` import `3`건 확인
- Clear When:
  허용 상태관리 패턴과
  잔존 레거시 허용 범위를 문서로 고정해야 한다.
- Owner Group:
  엔지니어링군

### V2-05 Shared Contract / Data Migration

- Status: `OPEN`
- Why It Blocks:
  trust, wallet, subscription, relay,
  analytics 모델이 다수 추가돼
  데이터 계약 이동 리스크가 크다.
- Evidence:
  V2 제품군/엔지니어링군 초안
- Clear When:
  기존 V1 데이터와
  새 모델 간 migration boundary를 표로 정리해야 한다.
- Owner Group:
  엔지니어링군

### V2-06 Backend Delta 검증

- Status: `OPEN`
- Why It Blocks:
  `functions-v2/index.js` 수정과
  `util_boost_expiry_scheduler.js`,
  `util_trust_score_batch.js` 추가가 있다.
- Evidence:
  V2 엔지니어링 초안
- Clear When:
  함수별 영향 범위,
  스케줄러 전제,
  롤백 조건을 정리해야 한다.
- Owner Group:
  엔지니어링군

### V2-07 Secret Hygiene

- Status: `OPEN`
- Why It Blocks:
  V1과 동일하게
  tracked admin SDK 경로 문제가 남아 있다.
- Evidence:
  V1/V2 엔지니어링 초안 공통
- Clear When:
  비밀정보 파일 추적 제거와
  안전한 대체 주입 방식이 확인돼야 한다.
- Owner Group:
  엔지니어링군 + 전략군

### V2-08 Query / Index / Location Risk

- Status: `OPEN`
- Why It Blocks:
  relay, discovery, dual-track location이
  query coupling을 크게 높인다.
- Evidence:
  V2 엔지니어링 초안,
  `firestore.indexes.json` index `223`개
- Clear When:
  location query, relay scope,
  trust update의 실패 경로를 점검해야 한다.
- Owner Group:
  엔지니어링군

### V2-09 Product Slice 미확정

- Status: `DONE`
- Why It Blocks:
  V2는 전체 브랜치보다
  slice 병합이 적합한데
  첫 병합 단위가 아직 정해지지 않았다.
- Evidence:
  V2 제품군 초안,
  V2 엔지니어링 초안,
  `MOZZY_V2_FIRST_MERGE_SLICE.md`
- Clear When:
  `Neighborhood Dashboard` 중심
  read-only slice를 첫 병합 단위로 고정했다.
- Owner Group:
  전략군 + 제품군 + 엔지니어링군

### V2-10 Feature Parity / Launch Scope

- Status: `OPEN`
- Why It Blocks:
  새 shell과 새 레이어가 생겼지만
  어떤 기존 경험을 그대로 유지할지 확정되지 않았다.
- Evidence:
  V2 제품군 초안의
  parity 미검증, launch slice 축소 권고
- Clear When:
  `must keep`, `can defer`, `new in V2`
  3분류 표가 준비돼야 한다.
- Owner Group:
  제품군

## Gate Summary

- V1 Baseline Gate:
  `NOT CLEAR`
- V2 Full Merge Gate:
  `NOT CLEAR`
- Current Recommendation:
  `hyperlocal-proposal` full merge는 보류하고,
  먼저 V1 안정화와
  V2 `Neighborhood Dashboard` read-only slice 검증을 수행한다.

## Recommended Order

1. V1 secret hygiene와 smoke 기준을 먼저 고정한다.
2. V1 baseline feature 표를 만든다.
3. V2 첫 merge slice를
   `Neighborhood Dashboard` read-only로 고정한다.
4. V2 core smoke verification plan을
   neighborhood slice 기준으로 구체화한다.
5. 그 다음에만 slice 단위 merge 판단으로 넘어간다.
