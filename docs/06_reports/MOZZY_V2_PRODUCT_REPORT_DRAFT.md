# Mozzy Product Report

## Report Meta

- Report ID: `PRD-V2-2026-04-09-01`
- Report Date: `2026-04-09`
- Reporter: HNI Product Group Draft
- Target Version: V2
- Target Branch: `hyperlocal-proposal`
- Related Work Order:
  `HNI controlled evaluation / Mozzy V1-V2 product review`
- Evidence Base:
  `origin/hyperlocal-proposal` 기준 문서,
  `doc/Mozzy I → Mozzy II 변경 및 추가 사항 정리.md`,
  `doc/Mozzy II IA 초안.md`,
  `Mozzy(모지) 백서 Ver 5.0...`,
  `git diff` / 선택 코드 확인
- Branch Delta:
  `main` 대비 `23` commits ahead,
  `339` files changed,
  `49,895` insertions,
  `1,219` deletions
- Validation Limit:
  변경 규모는 확인했지만
  아직 runtime 실행과 실제 feature completeness는 검증하지 않았다

## Executive Summary

- 한 줄 상태 판단:
  V2는 제품 방향은 V1보다 훨씬 선명하지만,
  현재 시점에서는 merge-ready release라기보다
  대규모 검증 전 통합선에 가깝다.
- 현재 단계: Validation
- 핵심 메시지 3줄 요약:
  - V2는 feature 나열형에서 벗어나
    `local-first, global-ready` 제품 엔진으로 재정의돼 있다.
  - intent 기반 shell, smart feed, relay, trust,
    neighborhood layer가 추가돼 제품 서사가 강해졌다.
  - 반면 변경 폭이 너무 커서
    현재는 "좋은 방향"과 "안전한 병합"을 분리해서 봐야 한다.

## Product Goal At This Version

- 이 버전이 해결하려는 핵심 사용자 문제:
  동네에서 시작한 생활 콘텐츠와 수요를
  더 잘 발견되고 연결되게 만들어
  retention과 확장성을 동시에 높인다.
- 기대 사용자 가치:
  사용자는 단순 feature 목록이 아니라
  발견, 이동, 거래, 연결, 신뢰를 하나의 흐름으로 경험한다.
- 이번 버전의 범위 안:
  intent 기반 shell,
  smart feed / cross-link / relay,
  trust score,
  neighborhood dashboard,
  번역/글로벌 확장 구조,
  monetization / wallet / subscription 방향
- 이번 버전의 범위 밖:
  현재 문서 기준으로는
  모든 신규 경험의 안정적 운영 검증과
  `main` 병합 완료 상태는 포함되지 않는다

## Current Product Status

### 1. Core Experience

- 홈 / 런처:
  `Home`, `Explore`, `Map`, `Create`, `Inbox`, `My`의
  6탭 shell 방향이 문서와 코드에서 모두 확인된다.
- 지역 피드:
  `SmartFeedScreen`, discovery layer,
  local -> national -> global fallback 의도가 확인된다.
- 커뮤니티 / 모임:
  `Together`, `Clubs`, `Find Friends`에 더해
  neighborhood dashboard와 cross-link 연결이 붙는다.
- 거래 / 마켓:
  marketplace, jobs, stores, auction 등이
  discovery/monetization 레이어와 엮이는 방향이다.
- 채팅 / 연결:
  `Inbox`, `Hub`, alert board 개념이 추가됐지만,
  실제 핵심 대화 loop의 완성도는 아직 미확인이다.
- 신뢰 / 정책:
  `TrustScoreService`,
  AI screening,
  neighborhood identity가 추가돼
  trust를 독립 제품축으로 끌어올린다.

### 2. Feature Status Table

| Feature Area | Intended Outcome | Current State | Confidence | Notes |
| --- | --- | --- | --- | --- |
| Intent-based Shell | 목적 중심 진입 구조 | Partial | Med | `mozzy_ii_app` shell 확인 |
| Discovery / Smart Feed | 통합 발견 경험 | Partial | Med | smart feed/service 확인 |
| Geo / Relay | local-first 확장 분배 | Partial | Med | relay service와 문서 의도 확인 |
| Trust Layer | feature 공통 trust 축 | Partial | Med | trust service 확인, 체감은 미검증 |
| Neighborhood Layer | 동네 정체성과 로컬 대시보드 | Partial | Med | neighborhood 신규 추가 확인 |
| Monetization | boost, subscription, wallet | Partial | Low | 서비스 추가, UX 미확인 |
| Translation | 글로벌 읽기 가능성 확보 | Partial | Low | 언어 파일과 번역 서비스 확인 |
| Migration | 기존 11개 feature 재정렬 | Partial | Med | 재배치 문서 확인, parity 미검증 |

### 3. UX Quality Review

- 진입 흐름:
  V1보다 훨씬 명확하다.
  사용자가 "무엇을 하려는가" 기준으로 접근하게 하려는 설계가 보인다.
- 핵심 사용 경로:
  `Home -> Explore/Map -> Create/Inbox/My` 구조는
  반복 사용 loop를 의식한 설계로 읽힌다.
- 혼란 가능 지점:
  relay, geoScope, trust, monetization 개념이 한 번에 들어오면
  용어와 상태가 과도하게 복잡해질 수 있다.
- 과밀/중복 UI:
  V1 shell과 V2 shell이 공존하는 동안에는
  중복 진입점과 실험 화면이 사용자 혼란을 만들 수 있다.
- 모바일 사용성:
  IA 방향은 좋아졌지만,
  실제 스크롤 길이와 정보 밀도는 실기기 검증이 필요하다.

## V1/V2 Comparative View

- V1 대비 개선된 점:
  feature catalog에서
  discovery/geo/trust 중심 제품 엔진으로 이동했다.
- 아직 검증 안 된 점:
  실제 유지율 개선,
  local-first loop 완성도,
  cross-feature 추천 품질,
  shell 전환 비용은 검증되지 않았다.
- 사용자 체감이 큰 차이:
  V1은 기능 목록을 탐색하는 느낌이고,
  V2는 "현재 지역에서 무엇을 발견하고 확장할지"를 안내하는 구조다.
- merge 전 확인이 필요한 항목:
  feature parity,
  fallback 동작,
  데이터 계약 마이그레이션,
  trust/relay 오작동 리스크,
  성능 및 복잡도 증가

## User Risk Review

- 사용자 혼란:
  V1과 V2가 동시에 남아 있으면
  shell/용어/행동 기준이 이중화될 수 있다.
- 기능 과잉:
  discovery, relay, trust, monetization이
  한 릴리즈에 과도하게 결합될 위험이 있다.
- 지역성/하이퍼로컬 정합성:
  개념적으로는 V1보다 훨씬 강하지만,
  실제 데이터 품질과 추천 로직이 따라주지 않으면
  약속 대비 체감이 약해질 수 있다.
- 신뢰/커뮤니티 오용 가능성:
  relay와 boost는 잘 작동하면 강력하지만,
  moderation 전에 확산되면 품질 저하 위험도 같이 커진다.

## Product Findings

- Finding 1:
  V2는 단순한 기능 추가가 아니라
  Mozzy를 하이퍼로컬 discovery network로 다시 정의한다.
- Finding 2:
  제품 전략의 선명도는 V1보다 분명히 높고,
  neighborhood 중심 차별화도 강해졌다.
- Finding 3:
  그러나 현재 branch는
  "바로 merge할 제품"보다
  "검증해야 할 대규모 통합 후보"로 보는 것이 안전하다.

## Product Decision Recommendation

- Recommend: Hold
- Recommendation Reason:
  방향은 맞지만,
  현재 변경 폭과 미검증 범위를 고려하면
  바로 `main` 병합을 권고할 단계는 아니다.
- 반드시 수정할 항목:
  첫 사용자 loop 확정,
  V1 대비 feature parity 확인,
  shell 공존/전환 전략 정리,
  trust/relay 핵심 흐름 검증,
  launch slice 축소
- 나중으로 미뤄도 되는 항목:
  고도화 광고 슬롯 전체,
  creator program 세부 확장,
  전 국가 동시 확장형 메시지

## Needed From Engineering

- 검증이 필요한 기능:
  `main_mozzy_ii.dart` entry,
  smart feed 로딩,
  neighborhood dashboard,
  relay scope 전환,
  trust score 갱신 흐름
- 상태 확인이 필요한 구조:
  V1 데이터와 V2 shared contract의 호환,
  shell 라우팅,
  translation/cache,
  monetization service 연결 상태
- merge blocker로 보이는 항목:
  아직 runtime 기준으로 확인되지 않은
  core loop completeness와 migration 안정성

## Next Actions

1. V2 핵심 사용자 경로를 화면 단위 검증 체크리스트로 쪼갠다.
2. 제품군 기준의 merge/no-merge 판단 항목을 고정한다.
3. 이어서 엔지니어링군 실제 초안 보고서로 blocker를 구조화한다.
