# Mozzy V2 First Merge Slice

## Decision Summary

- V2의 첫 병합 단위는
  `Neighborhood Dashboard` 중심의
  read-only slice로 정의한다.
- 목표는 V2 전체를 병합하는 것이 아니라,
  V1 기준선 위에
  hyperlocal 차별화 한 축을
  가장 낮은 리스크로 추가하는 것이다.

## Why This Slice First

- `discovery`는 shell, smart feed, relay,
  shared contracts, 여러 feature domain을 함께 끌고 와
  범위가 너무 넓다.
- `trust`는 user 문서 write,
  score recalculation, 배치 유틸까지 엮여
  데이터 리스크가 크다.
- 반면 `Neighborhood Dashboard`는
  기존 컬렉션 read path와 화면 추가 중심이라
  additive slice로 다루기 쉽다.

## Evidence Base

- `docs/06_reports/MOZZY_V2_PRODUCT_REPORT_DRAFT.md`
- `docs/06_reports/MOZZY_V2_ENGINEERING_REPORT_DRAFT.md`
- `docs/06_reports/MOZZY_V1_V2_MERGE_BLOCKER_CHECKLIST.md`
- `docs/06_reports/MOZZY_CORE_SMOKE_VERIFICATION_PLAN.md`
- `origin/hyperlocal-proposal:lib/features/neighborhood/*`
- `origin/hyperlocal-proposal:test/features/neighborhood/*`

## Slice Name

- Working Name:
  `V2-SLICE-01 Neighborhood Dashboard Read`

## Product Goal

- 현재 지역의 활동 밀도와 대표 콘텐츠를
  한 화면에서 보여주는
  hyperlocal dashboard를 V1 위에 가산적으로 추가한다.
- 이 slice는
  "Mozzy가 기능 모음이 아니라
  동네 단위 운영체제"라는 방향을
  가장 낮은 위험으로 시험하는 목적을 가진다.

## In Scope

- `lib/features/neighborhood/data/neighborhood_service.dart`
- `lib/features/neighborhood/screens/neighborhood_dashboard_screen.dart`
- `test/features/neighborhood/neighborhood_service_test.dart`
- 기존 V1 화면에서 neighborhood dashboard로 가는
  제한적 entry 연결 설계
- read-only Firestore query 검증
- empty/error/loading 상태 검증

## Out of Scope

- `Neighborhood Identity` 전체
- `main_mozzy_ii.dart`를 기본 entry로 전환
- `mozzy_ii_shell` 전체 도입
- `smart_feed`, `cross_link`, `relay`
- `trust_score_service`와 trust write path
- wallet, subscription, ad campaign
- scheduler/functions 변경
- V2 full branch merge

## Why It Is Safer

- 기존 컬렉션 조회 위주다:
  `posts`, `products`, `jobs`, `shops`
- 또한 `together_posts`, `lost_and_found`,
  `users`, `room_listings`를 읽는다.
- 새 Cloud Function이나 scheduler가 필요 없다.
- 결제, 개인정보, trust score write를 건드리지 않는다.
- V1 shell을 바로 대체하지 않아
  dual shell 리스크를 줄인다.
- hyperlocal narrative는 보여주면서도
  migration boundary를 좁게 유지할 수 있다.

## Recommended Entry Strategy

- 기본 shell은 계속 V1을 유지한다.
- dashboard는 아래 중 하나로
  제한적 진입을 건다.
- 기존 launcher의 실험 entry
- location/지역 화면에서 진입
- 내부 초청 사용자 전용 deep link
- 기본 홈 대체나
  전체 nav 재편은 첫 slice에서 하지 않는다.

## Minimal File Boundary

- Must Keep:
  `lib/features/neighborhood/data/neighborhood_service.dart`
- Must Keep:
  `lib/features/neighborhood/screens/neighborhood_dashboard_screen.dart`
- Must Keep:
  `test/features/neighborhood/neighborhood_service_test.dart`
- Optional Adapter:
  existing V1 route wiring file 1곳
- Excluded:
  `lib/features/neighborhood/data/neighborhood_identity_service.dart`
- Excluded:
  `lib/features/neighborhood/screens/neighborhood_identity_screen.dart`
- Excluded:
  `lib/core/mozzy_ii_app/*`
- Excluded:
  `lib/core/services/discovery/*`
- Excluded:
  `lib/core/services/trust/*`
- Excluded:
  `functions-v2/*trust*`, `functions-v2/*boost*`

## Preconditions

1. V1 baseline smoke가 먼저 통과해야 한다.
2. tracked secret 없이
   로컬 비프로덕션 실행이 가능해야 한다.
3. 기존 detail screen 이동이 깨지지 않아야 한다.
4. locationParts 기반 query가
   최소 대상 지역에서 동작해야 한다.

## Smoke Scope For This Slice

- `V2-S01`: V2 또는 제한 entry boot
- `V2-S02`: auth 뒤 dashboard 진입 dead end 없음
- `V2-S07`: neighborhood dashboard 로딩/새로고침
- `V2-S10`: empty/error/fallback 처리

## Acceptance Criteria

- dashboard 진입이 crash 없이 된다.
- 통계 카드가 최소 empty state라도 정상 렌더된다.
- 대표 섹션 중 1개 이상이
  실제 데이터 또는 empty state로 나온다.
- 새로고침이 무한 로딩 없이 끝난다.
- detail screen 이동 또는
  back navigation이 막히지 않는다.
- 기존 V1 홈/런처 기본 흐름을 깨지 않는다.

## Deferred To Later Slices

- `V2-SLICE-02` 후보:
  trust read/write 분리 검토
- `V2-SLICE-03` 후보:
  smart feed + discovery read path
- `V2-SLICE-04` 후보:
  relay scope 확장
- `V2-SLICE-05` 후보:
  shell replacement 여부 판단

## Current Recommendation

1. full merge는 계속 보류한다.
2. 첫 병합 단위는
   `Neighborhood Dashboard Read`로 고정한다.
3. shell replacement 없이
   additive route 방식으로만 검증한다.
4. smoke와 field feedback이 안정적일 때만
   다음 slice로 넘어간다.
