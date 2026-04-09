# Mozzy Engineering Report

## Report Meta

- Report ID: `ENG-V2-2026-04-09-01`
- Report Date: `2026-04-09`
- Reporter: HNI Engineering Group Draft
- Target Version: V2
- Target Branch: `hyperlocal-proposal`
- Related Work Order:
  `HNI controlled evaluation / Mozzy V1-V2 engineering review`
- Evidence Base:
  `pubspec.yaml`,
  `lib/main.dart`,
  `lib/main_mozzy_ii.dart`,
  `lib/core/mozzy_ii_app/*`,
  `lib/core/services/*`,
  `functions-v2/*`,
  `firestore.indexes.json`,
  `test/*`
- Branch Delta:
  `23` commits ahead,
  `339` files changed,
  `49,895` insertions,
  `1,219` deletions
- Validation Limit:
  이번 문서는 static code review 기준이며,
  앱 실행과 `flutter test`는 수행하지 않았다

## Executive Summary

- 한 줄 상태 판단:
  V2는 구조 개선 의도는 분명하지만,
  현재 브랜치 상태는 merge-ready보다 validation candidate에 가깝다.
- Engineering Status: Risky
- 핵심 기술 메시지 3줄 요약:
  - `main` 대비 Dart 파일이 `329 -> 515`,
    core services가 `11 -> 33`,
    core models가 `9 -> 19`로 크게 늘었다.
  - 테스트 파일은 `8 -> 40`으로 증가했지만,
    실제 실행 검증은 아직 없다.
  - `main_mozzy_ii.dart`가 추가됐어도
    기존 `main.dart`는 `875` lines로 더 커졌고,
    `get`/`provider` 흔적도 남아 있다.

## Branch / Baseline

- Base Branch: `main`
- Reviewed Branch: `hyperlocal-proposal`
- Compared Against: `main`
- Recent Major Commits:
  - `d6a9acc` Mozzy II 전기능 프로덕션 마이그레이션
  - `969f8e2` i18n 25개 언어 + Hub/Trust/Boost 개선
  - `80ffe8d` GlobalRelay UI + CreatorProgram 통합
  - `00278b4` NeighborhoodIdentity dual-track location fix

## Architecture Snapshot

- App Layer:
  legacy `main.dart`와
  별도 `main_mozzy_ii.dart` entry가 공존한다
- Feature Layer:
  기존 feature tree 위에
  `mozzy_ii_app`, `neighborhood`, discovery,
  monetization, trust 계층이 추가됐다
- State / Data Flow:
  riverpod hit `55`건으로 늘었지만,
  provider import `42`건,
  `package:get/get.dart` import `3`건이 남아 있다
- Backend Dependencies:
  Firebase stack 위에
  `functions-v2` `21`개 파일,
  boost expiry와 trust batch 유틸이 추가됐다
- External Integrations:
  Google Maps, ML Kit, Gemini,
  Stripe Connect service,
  Xendit payment service 흔적이 있다

## Current Engineering Status

### 1. Code Structure

- 모듈 분리 상태:
  문서상 레이어링은 개선됐지만
  old shell과 new shell이 동시에 존재한다.
- 중복/복잡도:
  공통 서비스와 새 계층이 같이 커져
  복잡도가 높다.
- 일관성:
  Riverpod 중심으로 가려는 방향은 보이지만
  의존성과 import는 아직 혼합 상태다.
- TODO / 임시 로직:
  static grep 기준 `TODO/FIXME` `10`건 확인

### 2. Data / Backend

- Firebase / Firestore 영향:
  `firestore.indexes.json`에서
  index `223`개를 확인했다.
- Functions 영향:
  `functions-v2/index.js`가 수정됐고,
  `util_boost_expiry_scheduler.js`,
  `util_trust_score_batch.js`가 추가됐다.
- 인덱스 / 쿼리 리스크:
  relay, trust, discovery, dual-track location이
  query coupling을 높인다.
- 브랜치 간 데이터 모델 차이:
  wallet, subscription, analytics,
  ad/trust/relay 모델이 다수 추가됐다.

### 3. Verification Status Table

| Area | Expected State | Current State | Confidence | Blocker |
| --- | --- | --- | --- | --- |
| V2 Entry | shell boot | Unknown | Low | Yes |
| Discovery | feed/relay work | Partial | Med | Yes |
| Trust | trust flow | Partial | Med | Yes |
| Data | models/indexes sync | Partial | Low | Yes |
| Tests | expanded suite | Partial | Med | Yes |
| State | Riverpod-first | Partial | High | Yes |
| Secret | no tracked creds | Partial | High | Yes |

### 4. Test & QA View

- 테스트 존재 여부:
  `test/` 아래 `40`개 파일 확인,
  `main` 대비 `32`개 추가
- 핵심 경로 검증 상태:
  smart feed, relay, neighborhood,
  trust, wallet 관련 테스트 파일은 보이지만
  실행 검증은 이번 리뷰에서 하지 않았다
- 회귀 위험:
  `339`개 파일 변경 규모 때문에 높다
- 수동 확인 필요 항목:
  `main_mozzy_ii.dart` entry,
  auth -> shell,
  smart feed,
  relay scope,
  neighborhood dashboard,
  trust update,
  wallet/subscription

## V1/V2 Comparative View

- 구조적으로 달라진 부분:
  separate shell, core models/services 확장,
  test coverage 확대,
  backend scheduler 추가가 핵심이다
- merge conflict 가능 영역:
  `lib/core/services`,
  `lib/core/models`,
  `assets/lang`,
  `functions-v2/index.js`,
  주요 feature screen 전반
- 아직 미완료로 보이는 기능:
  상태관리 단일화와 shell 전환 경계가
  아직 완전히 닫히지 않았다
- 되돌리기 어려운 변경:
  shared contract, Firestore index,
  backend scheduler, trust/relay 데이터는
  단순 롤백이 어렵다

## Risk Review

- Stability Risk:
  높음. 구조와 기능 변화가 동시에 크다
- Data / Query Risk:
  높음. shared contract와 location query 변화가 크다
- Privacy / Trust Risk:
  높음. relay + 위치 + trust 확산 구조에
  tracked admin SDK 경로 이슈가 겹친다
- Release Risk:
  높음. static 증거만으로는 merge를 지지하기 어렵다

## Engineering Findings

- Finding 1:
  V2는 방향성은 더 좋지만
  실제로는 대규모 플랫폼 마이그레이션 브랜치에 가깝다.
- Finding 2:
  테스트 파일 증가는 긍정적이지만
  runtime proof가 없어 안정성 결론을 내릴 수 없다.
- Finding 3:
  전체 브랜치 병합보다
  capability slice 단위 병합이 훨씬 안전하다.

## Merge Readiness

- Ready: No
- Blockers:
  runtime validation 부재,
  mixed state management,
  dual shell 공존,
  shared contract migration,
  backend delta,
  tracked admin SDK 경로
- Preconditions:
  test execution,
  core smoke run,
  migration boundary 정의,
  secret hygiene review,
  launch slice 축소가 필요하다
- Recommended Merge Strategy:
  full branch merge 대신
  discovery, neighborhood, trust 같은
  slice 기준 단계 병합이 적합하다

## Needed From Product

- 기능 정의가 더 필요한 부분:
  첫 merge slice에 넣을 feature 묶음 결정
- UX 의도 확인이 필요한 부분:
  V2 shell이 V1 launcher를 대체하는지 여부
- 우선순위 결정을 받아야 하는 부분:
  parity가 먼저인지,
  차별화 feature가 먼저인지 정해야 한다

## Next Actions

1. V2 merge blocker checklist를 만든다.
2. core smoke verification plan을 만든다.
3. 브랜치를 merge 가능한 capability slice로 나눈다.
