# Mozzy V1 Baseline Feature Table

## Purpose

- 이 문서는 `main` 브랜치를
  내부초청 필드 테스트용 V1 기준선으로 볼 때,
  어떤 기능을 우선 안정화해야 하는지 정리한다.
- 기준선 표는 기능 삭제 결정 문서가 아니다.
- 목적은 V1 유지 우선순위와
  V2 비교 기준을 동시에 고정하는 것이다.

## Evidence Base

- `origin/main:README.md`
- `origin/main:lib/features/*`
- `docs/06_reports/MOZZY_V1_PRODUCT_REPORT_DRAFT.md`
- `docs/06_reports/MOZZY_CORE_SMOKE_VERIFICATION_PLAN.md`

## Tier Legend

- `Core Baseline`:
  V1 field-test의 정체성과 직접 연결되는 기능이다.
  이 축이 흔들리면 baseline 유지 판단을 보류한다.
- `Support Baseline`:
  핵심 경험을 보강하는 기능이다.
  접근 가능성과 기본 품질은 필요하지만
  첫 진입의 대표 루프로 보지는 않는다.
- `Maintain Only`:
  기능은 유지하되
  현재 baseline sign-off의 1차 기준으로는 보지 않는다.
- `Defer From Baseline`:
  V1에 존재하더라도
  이번 안정화 우선순위에는 올리지 않는다.

## Baseline Table

| Area | Tier | Smoke | Note |
| --- | --- | --- | --- |
| Auth | Core | S01/S02 | entry/login |
| Launcher | Core | S03 | first hub |
| Feed+Boards | Core | S04 | local info loop |
| Geo | Core | S05 | scope + privacy |
| Trade | Core | S07 | trade to chat |
| Chat | Core | S08 | room access |
| Trust | Core | S06 | moderation |
| Community | Support | follow-up | roles later |
| Jobs | Support | follow-up | not first loop |
| Stores | Support | follow-up | commerce ext |
| Profile | Support | follow-up | self-manage |
| Friends | Maintain | trust review | not hero |
| Auction | Maintain | no core | isolated |
| Realty | Maintain | no core | later check |
| Lost&Found | Maintain | no core | utility keep |
| POM | Defer | no core | not now |
| Admin | Maintain | internal | ops only |

## Feature Notes

- `Auth`:
  `auth`, `main_screen`.
  V1 진입과 login dead end 제거가 우선이다.
- `Launcher`:
  `main_screen`, `categories`.
  첫 허브는 유지하되 feature 과밀을 낮춰야 한다.
- `Feed+Boards`:
  `main_feed`, `local_news`, `boards`.
  V1의 대표 local info loop로 본다.
- `Geo`:
  `location`.
  지역 범위 반영과 privacy 정합성이 핵심이다.
- `Trade`:
  `marketplace`.
  거래 시작 후 채팅 전환이 이어져야 한다.
- `Chat`:
  `chat`, `notifications`.
  목록과 방 진입의 dead end가 없어야 한다.
- `Trust`:
  `auth`, `admin`, privacy guide.
  신뢰와 moderation 체감축으로 본다.
- `Community`:
  `clubs`, `together`.
  유지하되 역할 경계는 나중에 더 정리한다.
- `Jobs`:
  `jobs`.
  지역 일자리 연결은 support 축으로 유지한다.
- `Stores`:
  `local_stores`.
  지역 commerce 확장 기능으로 본다.
- `Profile`:
  `user_profile`, `my_bling`.
  계정과 내 활동 확인용 support 축이다.
- `Friends`:
  `find_friends`.
  trust review 전에는 hero 배치를 보류한다.
- `Auction`:
  `auction`.
  존재는 유지하되 핵심 기준선은 아니다.
- `Realty`:
  `real_estate`.
  세부 검증 전까지는 유지 중심으로 본다.
- `Lost&Found`:
  `lost_and_found`.
  로컬 utility 성격은 있으나 우선순위는 낮다.
- `POM`:
  `pom`.
  V1보다 V2 이후 재판단이 안전하다.
- `Admin`:
  `admin`, `manuals`.
  내부 운영 기능으로만 해석한다.

## Baseline Summary

- V1의 1차 기준선은
  `진입 -> 런처 -> 지역 피드 -> 지역 설정 ->
  거래/채팅 -> trust` 흐름이다.
- `Community`, `Jobs`, `Local Stores`, `Profile`은
  baseline을 보강하는 2차 축으로 본다.
- `Find Friends`, `Auction`, `Real Estate`,
  `Lost and Found`, `Admin Ops`는
  존재는 유지하되 현재 baseline sign-off의
  핵심 합격선으로 두지 않는다.
- `POM / Shorts`는
  V1 기준선보다 V2 재구성 이후에
  다시 우선순위를 판단하는 편이 안전하다.

## Operational Implication

1. V1 안정화 smoke와 수동 검토는
   `Core Baseline` 항목부터 우선 수행한다.
2. `Support Baseline`은
   접근성 저하나 명백한 UX dead end가 없는지 확인한다.
3. `Maintain Only`는
   기능 삭제가 아니라 우선순위 하향으로 해석한다.
4. V2 비교 시에는
   이 표의 `Core Baseline`이
   V2에서 더 선명해졌는지를 먼저 본다.

## Exclusions

- `shared`, `web_lite`, `manuals` 전반은
  사용자 기능이 아니라 기술/보조 모듈로 본다.
- 따라서 이 문서의 표는
  사용자 체감 기능 묶음 중심으로만 정리한다.
