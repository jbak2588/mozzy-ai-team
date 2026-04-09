# Mozzy Engineering Report

## Report Meta

- Report ID: `ENG-V1-2026-04-09-01`
- Report Date: `2026-04-09`
- Reporter: HNI Engineering Group Draft
- Target Version: V1
- Target Branch: `main`
- Related Work Order:
  `HNI controlled evaluation / Mozzy V1-V2 engineering review`
- Evidence Base:
  `pubspec.yaml`,
  `lib/main.dart`,
  `lib/features/*`,
  `functions-v2/*`,
  `firestore.indexes.json`,
  `test/*`
- Validation Limit:
  이번 문서는 static code review 기준이며,
  앱 실행과 `flutter test`는 수행하지 않았다

## Executive Summary

- 한 줄 상태 판단:
  V1은 필드 테스트 기준선으로는 유지 가능하지만,
  엔지니어링 관점에서는 혼합 아키텍처 정리가 필요하다.
- Engineering Status: Review Needed
- 핵심 기술 메시지 3줄 요약:
  - `lib/main.dart`가 `809` lines인 단일 bootstrap이라
    초기화 책임이 과도하게 모여 있다.
  - 상태관리는 `get`, `provider`, `flutter_riverpod`가 공존해
    구조 일관성이 약하다.
  - 테스트는 `8`개만 확인됐고,
    `functions-v2/bling-app-firebase-adminsdk.json` 경로가
    추적 중이라 보안 위생 검토가 필요하다.

## Branch / Baseline

- Base Branch: `main`
- Reviewed Branch: `main`
- Compared Against: `hyperlocal-proposal`
- Recent Major Commits:
  - `0864c45` 포스트 생성 촬영 기능 추가
  - `4ceb348` App Check 경로와 Firestore index 조정
  - `563105a` 국가 인지형 피드와 내비게이션 모듈화
  - `2d424df` Firebase hardening + AI verification fixes

## Architecture Snapshot

- App Layer:
  단일 `lib/main.dart` bootstrap 중심 구조
- Feature Layer:
  `lib/features/*` 아래 광범위한 feature tree,
  총 `329`개 Dart 파일 확인
- State / Data Flow:
  `package:get/get.dart` import `3`건,
  provider import `40`건,
  riverpod 관련 hit `30`건 확인
- Backend Dependencies:
  Firebase Auth, Firestore, Storage, Functions,
  Messaging, Crashlytics, App Check
- External Integrations:
  Google Maps, Google Sign-In,
  Sign in with Apple, ML Kit 번역,
  Cloud Functions 기반 AI 검수

## Current Engineering Status

### 1. Code Structure

- 모듈 분리 상태:
  feature 단위 분리는 넓게 되어 있지만,
  진입부와 공통 상태가 무겁다.
- 중복/복잡도:
  bootstrap 집중도가 높고
  상태관리 패턴이 섞여 있다.
- 일관성:
  Flutter 구조는 유지되지만
  state management 기준은 단일하지 않다.
- TODO / 임시 로직:
  static grep 기준 `TODO/FIXME` `19`건 확인

### 2. Data / Backend

- Firebase / Firestore 영향:
  `firestore.indexes.json`에서
  index `263`개를 확인했다.
- Functions 영향:
  `functions-v2` 파일 `19`개가
  이미 `main` baseline에 포함돼 있다.
- 인덱스 / 쿼리 리스크:
  위치 기반 필터와 AI 검수 흐름이
  index 의존성을 크게 만든다.
- 브랜치 간 데이터 모델 차이:
  `main`도 이미 global/country-aware 흔적을 포함해
  V1/V2 경계가 완전히 분리되진 않는다.

### 3. Verification Status Table

| Area | Expected State | Current State | Confidence | Blocker |
| --- | --- | --- | --- | --- |
| Bootstrap | clean startup | Partial | Med | No |
| State | single pattern | Partial | High | Yes |
| Backend | aligned funcs/db | Partial | Med | Yes |
| Tests | smoke + models | Partial | High | Yes |
| Secret | no tracked creds | Partial | High | Yes |

### 4. Test & QA View

- 테스트 존재 여부:
  `test/` 아래 `8`개 파일 확인
- 핵심 경로 검증 상태:
  이번 리뷰에서는 실제 실행 검증을 하지 않았다
- 회귀 위험:
  feature 폭이 넓은데
  자동 검증 폭은 얕아 중간 이상이다
- 수동 확인 필요 항목:
  app start, auth gate, location filter,
  main feed, marketplace AI, chat notification

## V1/V2 Comparative View

- 구조적으로 달라진 부분:
  V2는 별도 entrypoint와 추가 core layer를 만든다
- merge conflict 가능 영역:
  `lib/core/services`,
  `lib/core/models`,
  `assets/lang`,
  `functions-v2/index.js`
- 아직 미완료로 보이는 기능:
  상태관리 단일화와 bootstrap 경량화가 남아 있다
- 되돌리기 어려운 변경:
  Firestore index와 backend function 변경은
  가볍게 롤백하기 어렵다

## Risk Review

- Stability Risk:
  중간. baseline 유지에는 가능하나 구조 피로가 크다
- Data / Query Risk:
  중간. 위치/AI 쿼리 의존성이 높다
- Privacy / Trust Risk:
  중간 이상. 위치 데이터와
  tracked admin SDK 경로 존재를 같이 봐야 한다
- Release Risk:
  중간. low test depth가 가장 큰 약점이다

## Engineering Findings

- Finding 1:
  V1은 기능 baseline은 넓지만
  엔지니어링 구조는 단일 원칙으로 정리되지 않았다.
- Finding 2:
  자동 테스트 수가 적어
  필드 테스트 이후 회귀를 빠르게 잡기 어렵다.
- Finding 3:
  보안 위생과 bootstrap 정리는
  V2 이전에도 먼저 손봐야 할 항목이다.

## Merge Readiness

- Ready: Partial
- Blockers:
  mixed state management,
  low test depth,
  tracked admin SDK 경로,
  oversized bootstrap
- Preconditions:
  V1 stabilization checklist,
  smoke test 기준,
  secret hygiene review가 먼저 필요하다
- Recommended Merge Strategy:
  `main`은 안정화 기준선으로만 유지하고,
  대규모 구조 변경은 직접 누적하지 않는 편이 안전하다

## Needed From Product

- 기능 정의가 더 필요한 부분:
  필드 테스트 핵심 feature와 보조 feature 구분
- UX 의도 확인이 필요한 부분:
  launcher 우선인지 feed 우선인지 정리 필요
- 우선순위 결정을 받아야 하는 부분:
  V1에 남길 수정과 V2로 넘길 수정을 분리해야 한다

## Next Actions

1. V1 stabilization checklist를 만든다.
2. V1 수동 smoke 기준을 고정한다.
3. tracked admin SDK 경로의 처리 방식을 결정한다.
