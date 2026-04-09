# MOZZY_PRODUCT_REPORT_TEMPLATE.md

## Purpose

이 템플릿은 Mozzy V1 (`main`) 또는
V2 (`hyperlocal-proposal`)에 대해
제품군이 현재 상태를 보고할 때 사용한다.

## Template

```md
# Mozzy Product Report

## Report Meta

- Report ID:
- Report Date:
- Reporter:
- Target Version: V1 / V2
- Target Branch:
- Related Work Order:

## Executive Summary

- 한 줄 상태 판단:
- 현재 단계: Discovery / Review / Validation / Ready / Blocked
- 핵심 메시지 3줄 요약:

## Product Goal At This Version

- 이 버전이 해결하려는 핵심 사용자 문제:
- 기대 사용자 가치:
- 이번 버전의 범위 안:
- 이번 버전의 범위 밖:

## Current Product Status

### 1. Core Experience

- 홈 / 런처:
- 지역 피드:
- 커뮤니티 / 모임:
- 거래 / 마켓:
- 채팅 / 연결:
- 신뢰 / 정책:

### 2. Feature Status Table

| Feature Area | Intended Outcome | Current State | Confidence | Notes |
| --- | --- | --- | --- | --- |
| Example | Example | Done / Partial / Unknown | High / Med / Low | - |

### 3. UX Quality Review

- 진입 흐름:
- 핵심 사용 경로:
- 혼란 가능 지점:
- 과밀/중복 UI:
- 모바일 사용성:

## V1/V2 Comparative View

- V1 대비 개선된 점:
- 아직 검증 안 된 점:
- 사용자 체감이 큰 차이:
- merge 전 확인이 필요한 항목:

## User Risk Review

- 사용자 혼란:
- 기능 과잉:
- 지역성/하이퍼로컬 정합성:
- 신뢰/커뮤니티 오용 가능성:

## Product Findings

- Finding 1:
- Finding 2:
- Finding 3:

## Product Decision Recommendation

- Recommend: Go / Revise / Hold
- Recommendation Reason:
- 반드시 수정할 항목:
- 나중으로 미뤄도 되는 항목:

## Needed From Engineering

- 검증이 필요한 기능:
- 상태 확인이 필요한 구조:
- merge blocker로 보이는 항목:

## Next Actions

1. 
2. 
3. 
```

## Usage Note

- V1과 V2를 같은 형식으로 작성해야 비교가 쉬워진다.
- 제품군 보고서는 사용자 가치와 기능 완성도에 집중한다.
- 구조/코드/테스트/성능 세부사항은
  엔지니어링군 보고서로 넘긴다.
