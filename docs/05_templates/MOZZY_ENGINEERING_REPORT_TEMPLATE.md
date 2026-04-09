# MOZZY_ENGINEERING_REPORT_TEMPLATE.md

## Purpose

이 템플릿은 Mozzy V1 (`main`) 또는
V2 (`hyperlocal-proposal`)에 대해
엔지니어링군이 현재 구조와 검증 상태를 보고할 때 사용한다.

## Template

```md
# Mozzy Engineering Report

## Report Meta

- Report ID:
- Report Date:
- Reporter:
- Target Version: V1 / V2
- Target Branch:
- Related Work Order:

## Executive Summary

- 한 줄 상태 판단:
- Engineering Status: Stable / Review Needed / Risky / Blocked
- 핵심 기술 메시지 3줄 요약:

## Branch / Baseline

- Base Branch:
- Reviewed Branch:
- Compared Against:
- Recent Major Commits:

## Architecture Snapshot

- App Layer:
- Feature Layer:
- State / Data Flow:
- Backend Dependencies:
- External Integrations:

## Current Engineering Status

### 1. Code Structure

- 모듈 분리 상태:
- 중복/복잡도:
- 일관성:
- TODO / 임시 로직:

### 2. Data / Backend

- Firebase / Firestore 영향:
- Functions 영향:
- 인덱스 / 쿼리 리스크:
- 브랜치 간 데이터 모델 차이:

### 3. Verification Status Table

| Area | Expected State | Current State | Confidence | Blocker |
| --- | --- | --- | --- | --- |
| Example | Example | Done / Partial / Unknown | High / Med / Low | Yes / No |

### 4. Test & QA View

- 테스트 존재 여부:
- 핵심 경로 검증 상태:
- 회귀 위험:
- 수동 확인 필요 항목:

## V1/V2 Comparative View

- 구조적으로 달라진 부분:
- merge conflict 가능 영역:
- 아직 미완료로 보이는 기능:
- 되돌리기 어려운 변경:

## Risk Review

- Stability Risk:
- Data / Query Risk:
- Privacy / Trust Risk:
- Release Risk:

## Engineering Findings

- Finding 1:
- Finding 2:
- Finding 3:

## Merge Readiness

- Ready: Yes / No / Partial
- Blockers:
- Preconditions:
- Recommended Merge Strategy:

## Needed From Product

- 기능 정의가 더 필요한 부분:
- UX 의도 확인이 필요한 부분:
- 우선순위 결정을 받아야 하는 부분:

## Next Actions

1. 
2. 
3. 
```

## Usage Note

- 엔지니어링군 보고서는 코드, 구조, 데이터, 검증 상태에 집중한다.
- 제품 가치 평가는 제품군 보고서에 남긴다.
- merge readiness 판단은
  반드시 blocker와 precondition을 함께 적는다.
