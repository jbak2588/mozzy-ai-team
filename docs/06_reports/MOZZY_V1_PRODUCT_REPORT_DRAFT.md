# Mozzy Product Report

## Report Meta

- Report ID: `PRD-V1-2026-04-09-01`
- Report Date: `2026-04-09`
- Reporter: HNI Product Group Draft
- Target Version: V1
- Target Branch: `main`
- Related Work Order:
  `HNI controlled evaluation / Mozzy V1-V2 product review`
- Evidence Base:
  `origin/main:README.md`,
  `origin/main:lib/features/*`,
  `origin/main` branch file structure
- Validation Limit:
  runtime 실행, 실제 디바이스 UX, 데이터 품질은 아직 검증하지 않았다

## Executive Summary

- 한 줄 상태 판단:
  V1은 내부초청 필드 테스트용으로는 성립하지만,
  제품 경험은 아직 기능 나열형 슈퍼앱에 더 가깝다.
- 현재 단계: Review
- 핵심 메시지 3줄 요약:
  - 지역 소식, 거래, 구인, 모임, 채팅을 한 앱에 넣은
    폭넓은 생활형 베이스는 이미 갖춰져 있다.
  - 다만 현재 구조는 사용자의 목적 중심이라기보다
    feature 중심 진입에 가까워 초기 이해 부담이 크다.
  - V2와 비교하면 V1은 baseline으로는 유효하지만,
    장기 제품 정체성을 대표하기에는 방향성이 약하다.

## Product Goal At This Version

- 이 버전이 해결하려는 핵심 사용자 문제:
  동네 생활에 필요한 소식, 거래, 구인, 연결 수요를
  한 앱에서 해결하게 한다.
- 기대 사용자 가치:
  한 지역 안에서 정보 탐색, 거래, 소통, 만남을
  분산 앱 없이 처리할 수 있다.
- 이번 버전의 범위 안:
  지역 피드, 마켓플레이스, 구인구직, 모임, 채팅,
  동네 가게, 경매, 부동산, POM 등
  다기능 생활 서비스 제공
- 이번 버전의 범위 밖:
  명확한 intent 기반 IA,
  점진적 글로벌 relay 구조,
  통합 trust engine,
  V2식 discovery engine

## Current Product Status

### 1. Core Experience

- 홈 / 런처:
  Gojek 스타일의 feature launcher 성격이 강하고,
  사용 목적보다 메뉴 선택을 먼저 요구한다.
- 지역 피드:
  `local_news`, `boards`, `main_feed`가 존재해
  동네 정보 소비의 기본축은 형성되어 있다.
- 커뮤니티 / 모임:
  `clubs`, `together`, `find_friends`가 분리되어 있어
  기능은 넓지만 경험은 다소 분산돼 있다.
- 거래 / 마켓:
  `marketplace`, `auction`, `local_stores`,
  `real_estate`, `jobs`까지 포함해 생활 거래 범위는 넓다.
- 채팅 / 연결:
  `chat`, `notifications`, `user_profile` 구조가 있어
  연결 허브의 기본은 존재한다.
- 신뢰 / 정책:
  위치 노출 가이드와 이메일 인증, admin/AI audit 화면은 있으나
  전 feature 공통 trust layer로 보이진 않는다.

### 2. Feature Status Table

| Feature Area | Intended Outcome | Current State | Confidence | Notes |
| --- | --- | --- | --- | --- |
| Launcher / Home | 동네 생활 진입 허브 | Partial | Med | 런처 구조 확인, 우선순위 불명확 |
| News Feed | 지역 정보 탐색 | Partial | Med | `local_news/main_feed/boards` 확인 |
| Trade | 중고거래와 생활거래 허브 | Partial | Med | 거래 feature 폭은 넓지만 통합감은 약함 |
| Jobs / Talent | 지역 일자리 연결 | Partial | Med | `jobs` 구조 확인, 가치 검증은 미완료 |
| Community | 모임과 관계 형성 | Partial | Med | `clubs/together/find_friends` 분산 |
| Chat / Messaging | 거래/관계 후속 대화 | Partial | Med | 채팅 구조는 있으나 허브 품질은 미검증 |
| Admin | 운영자 제어와 AI audit | Partial | Med | 운영 화면 확인, 체감 trust는 미검증 |
| Localization / Geo | 다국어와 지역 정합성 | Partial | Low | 다국어 의도는 보이지만 UX는 미확인 |

### 3. UX Quality Review

- 진입 흐름:
  기능 목록이 먼저 보이는 구조일 가능성이 높아
  신규 사용자가 "무엇부터 해야 하는지" 판단하기 어렵다.
- 핵심 사용 경로:
  지역 소식, 거래, 구인, 모임 각각의 진입점은 있으나
  하나의 대표 loop로 수렴된 느낌은 약하다.
- 혼란 가능 지점:
  비슷한 커뮤니티 기능이 여러 곳에 나뉘어 있고,
  feed와 board, club, together의 경계가 즉시 선명하지 않을 수 있다.
- 과밀/중복 UI:
  생활형 기능을 폭넓게 담은 대신
  super app 과밀감이 생길 가능성이 높다.
- 모바일 사용성:
  Flutter 기반이라 기기 대응은 기대되지만,
  실제 스크롤 깊이와 탭 우선순위는 별도 검증이 필요하다.

## V1/V2 Comparative View

- V1 대비 개선된 점:
  해당 없음. V1은 baseline 역할이다.
- 아직 검증 안 된 점:
  실제 필드 테스트에서 어떤 feature가
  주 사용 경로로 선택되는지 근거가 부족하다.
- 사용자 체감이 큰 차이:
  V1은 feature catalog 성격이 강하고,
  V2는 의도상 intent/discovery 중심 구조로 이동한다.
- merge 전 확인이 필요한 항목:
  어떤 V1 feature가 실제로 반복 사용되는지,
  어떤 feature가 menu clutter를 만드는지 먼저 확인해야 한다.

## User Risk Review

- 사용자 혼란:
  너무 많은 기능이 동등한 중요도로 보이면
  첫 사용자의 진입 결정이 느려질 수 있다.
- 기능 과잉:
  breadth는 강점이지만,
  핵심 loop가 보이지 않으면 retention을 해칠 수 있다.
- 지역성/하이퍼로컬 정합성:
  지역 중심 의도는 보이지만,
  제품 전체를 묶는 지역성 narrative는 아직 약하다.
- 신뢰/커뮤니티 오용 가능성:
  거래, 모임, 친구 찾기, 게시물 기능이 넓은 만큼
  trust와 moderation 일관성이 중요하다.

## Product Findings

- Finding 1:
  V1은 이미 동네 생활 전반을 담은 폭넓은 super app baseline이다.
- Finding 2:
  다만 제품의 핵심 가치가
  "하이퍼로컬 운영체제"보다는 "기능 묶음"으로 읽힐 가능성이 크다.
- Finding 3:
  따라서 V1은 유지 기준선으로 유용하지만,
  장기 북극성은 V2식 재구성이 더 적합하다.

## Product Decision Recommendation

- Recommend: Revise
- Recommendation Reason:
  V1은 field-test baseline으로는 유지 가능하지만,
  핵심 경험 단순화와 trust/discovery 정렬 없이는
  확장 기준 버전으로 삼기 어렵다.
- 반드시 수정할 항목:
  대표 use case 정의,
  홈 진입 우선순위 정리,
  지역성 narrative 강화,
  trust 체감 포인트 명확화
- 나중으로 미뤄도 되는 항목:
  고도화 monetization,
  글로벌 relay,
  고급 cross-feature 연결

## Needed From Engineering

- 검증이 필요한 기능:
  홈 진입 흐름, 지역 피드 소비, 거래 진입 후 채팅 전환
- 상태 확인이 필요한 구조:
  `main_feed`, `boards`, `clubs`, `together`, `find_friends` 간 역할 경계
- merge blocker로 보이는 항목:
  이번 문서는 `main` baseline 리뷰라
  직접적인 merge blocker보다는 비교 기준 정리가 우선이다

## Next Actions

1. V1 실제 화면 흐름을 캡처 기준으로 다시 검토한다.
2. 반복 사용 feature와 저사용 feature를 구분할 실사용 근거를 모은다.
3. V2와 비교할 baseline checklist를 고정한다.
