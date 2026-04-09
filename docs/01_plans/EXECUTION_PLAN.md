# EXECUTION_PLAN.md

## Status

APPROVED

## Request Title

Humantric Net Indonesia용 Auto-Company 평가 및
Mozzy 14-Agent 운영체계 설계 및
HNI auto-company 최소 실행 MVP 구현 및
backend-connected v1.1 완성과
실채널 연동 1차 설계

## Objective

`xiaoq17/nicepkg-auto-company`를 평가하고,
하이퍼로컬 커뮤니티 슈퍼앱 Mozzy
(`jbak2588/bling`)에 맞는
통제형 14개 AI 에이전트 운영모델을 설계한다.
또한 HNI 전용 Flutter 기반 운영 프로그램과
채널/대시보드 구조를 정의한다.
이어 Mozzy V1/V2 제품군과
엔지니어링군의 실제 현황 보고서 초안을 작성한다.
이어 V1/V2 merge blocker checklist를 정리한다.
이어 core smoke verification plan을 정리한다.
이어 V1 baseline feature 표를 정리한다.
이어 V2 first merge slice를 정의한다.
이어 neighborhood read slice용
세부 smoke checklist를 작성한다.
이어 HNI auto-company 최소 실행 MVP를 구현한다.
이어 backend-connected v1.1 MVP를 완성한다.
이어 실채널 연동 1차 설계를 정리한다.

## In Scope

- `auto-company` 리포지토리 구조 평가
- 14개 AI agent 구성 분석
- Mozzy/bling 현재 제품 구조와의 적합성 검토
- Humantric Net Indonesia용 14-agent 역할맵 설계
- 승인 기반 운영계획 초안 작성
- HNI 전용 Flutter 운영 프로그램 정의
- Windows/macOS 공통 대시보드 설계
- WhatsApp/Telegram 작업 지시 채널 설계
- Mozzy V1/V2 제품군 실제 초안 보고서 작성
- Mozzy V1/V2 엔지니어링군 실제 초안 보고서 작성
- Mozzy V1/V2 merge blocker checklist 작성
- Mozzy core smoke verification plan 작성
- Mozzy V1 baseline feature 표 작성
- Mozzy V2 first merge slice 정의
- Mozzy neighborhood read slice 세부 smoke checklist 작성
- HNI auto-company 최소 실행 MVP 구현
- HNI auto-company backend-connected v1.1 MVP 구현
- 실채널 연동 1차 설계 문서화

## Out of Scope

- `bling` 앱 코드 수정
- Claude/Code/Codex의 자율 루프 즉시 도입
- 배포, 프로덕션 반영, 권한 우회 설정 적용
- 보안/개인정보/결제 로직 변경
- 실제 Telegram/WhatsApp production webhook 개통

## Deliverables

1. `docs/04_specs/AUTO_COMPANY_EVALUATION.md`
2. `docs/04_specs/PROJECT_SCOPE.md`
3. `docs/04_specs/ROLE_MAP.md`
4. `docs/01_plans/TASK_QUEUE.md`
5. `docs/02_memory/CONSENSUS.md`
6. `docs/03_logs/SESSION_LOG.md`
7. `docs/04_specs/PILOT_SQUADS.md`
8. `docs/04_specs/ADOPTION_ROADMAP.md`
9. `docs/04_specs/HNI_AUTO_COMPANY_PROGRAM.md`
10. `docs/04_specs/HNI_DASHBOARD_CHANNELS.md`
11. `docs/05_templates/MOZZY_PRODUCT_REPORT_TEMPLATE.md`
12. `docs/05_templates/MOZZY_ENGINEERING_REPORT_TEMPLATE.md`
13. `docs/04_specs/HNI_DASHBOARD_FLUTTER_IA.md`
14. `docs/06_reports/MOZZY_V1_PRODUCT_REPORT_DRAFT.md`
15. `docs/06_reports/MOZZY_V2_PRODUCT_REPORT_DRAFT.md`
16. `docs/06_reports/MOZZY_V1_ENGINEERING_REPORT_DRAFT.md`
17. `docs/06_reports/MOZZY_V2_ENGINEERING_REPORT_DRAFT.md`
18. `docs/06_reports/MOZZY_V1_V2_MERGE_BLOCKER_CHECKLIST.md`
19. `docs/06_reports/MOZZY_CORE_SMOKE_VERIFICATION_PLAN.md`
20. `docs/06_reports/MOZZY_V1_BASELINE_FEATURE_TABLE.md`
21. `docs/06_reports/MOZZY_V2_FIRST_MERGE_SLICE.md`
22. `docs/06_reports/MOZZY_NEIGHBORHOOD_READ_SLICE_SMOKE_CHECKLIST.md`
23. `docs/04_specs/HNI_AUTO_COMPANY_MVP_SCOPE.md`
24. `hni_auto_company_mvp/`
25. `docs/04_specs/HNI_AUTO_COMPANY_V11_SCOPE.md`
26. `docs/04_specs/HNI_CHANNEL_LIVE_INTEGRATION_PHASE1.md`

## Execution Sequence

1. `auto-company` 구조와 14-agent 구성을 분석한다.
2. `bling` 제품/기술 맥락을 요약한다.
3. 적용 가능한 요소와 금지할 요소를 분리한다.
4. Humantric용 14-agent 역할맵을 재설계한다.
5. Mozzy pilot squad 구성을 설계한다.
6. Humantric용 도입 로드맵과 승인 게이트를 정리한다.
7. HNI 전용 프로그램 구조와 work order 흐름을 정의한다.
8. Flutter 대시보드와 채널 인터페이스를 정의한다.
9. Mozzy V1/V2 제품군/엔지니어링군 보고서 템플릿을 만든다.
10. HNI 대시보드의 Flutter 위젯 단위 IA/spec을 세분화한다.
11. `main`과 `hyperlocal-proposal`의 실제 근거를 바탕으로
    Mozzy V1/V2 제품군 보고서 초안을 작성한다.
12. `main`과 `hyperlocal-proposal`의 실제 근거를 바탕으로
    Mozzy V1/V2 엔지니어링군 보고서 초안을 작성한다.
13. 제품군/엔지니어링군 초안을 바탕으로
    Mozzy V1/V2 merge blocker checklist를 작성한다.
14. merge blocker checklist를 바탕으로
    Mozzy core smoke verification plan을 작성한다.
15. V1 제품 보고서와 core smoke plan을 바탕으로
    Mozzy V1 baseline feature 표를 작성한다.
16. V2 제품/엔지니어링 초안과
    merge blocker checklist를 바탕으로
    Mozzy V2 first merge slice를 정의한다.
17. V2 first merge slice를 바탕으로
    neighborhood read slice 세부 smoke checklist를 작성한다.
18. HNI auto-company 설계를 바탕으로
    최소 실행 MVP를 실제 Flutter 데스크톱 앱으로 구현한다.
19. 로컬 실행 MVP를 바탕으로
    로컬 HTTP backend + Flutter client 연결의
    backend-connected v1.1 MVP를 구현한다.
20. backend-connected v1.1 구조를 바탕으로
    Telegram/WhatsApp 실채널 연동 1차 설계를 문서화한다.

## Risks

- `auto-company`의 완전자율 철학이 현재 통제형 운영원칙과 충돌한다.
- Mozzy는 Flutter/Firebase 기반 슈퍼앱이라
  일반 SaaS형 agent 설계를 그대로 가져오기 어렵다.
- 위치, 신뢰도, 커뮤니티, 거래, 채팅이 얽혀 있어
  보안/개인정보 리스크가 크다.

## Definition of Done

- `auto-company` 평가 결과가 문서화됨
- 14-agent 역할과 Humantric용 변형안이 명확히 정리됨
- pilot squad 조합과 사용 시점이 문서화됨
- 도입 단계와 승인 게이트가 문서화됨
- HNI 전용 운영 프로그램의 구조가 정의됨
- 대시보드와 채널 인터페이스가 정의됨
- Mozzy V1/V2 보고서 템플릿이 준비됨
- Mozzy V1/V2 제품군 실제 초안 보고서가 준비됨
- Mozzy V1/V2 엔지니어링군 실제 초안 보고서가 준비됨
- Mozzy V1/V2 merge blocker checklist가 준비됨
- Mozzy core smoke verification plan이 준비됨
- Mozzy V1 baseline feature 표가 준비됨
- Mozzy V2 first merge slice가 정의됨
- neighborhood read slice 세부 smoke checklist가 준비됨
- HNI auto-company 최소 실행 MVP가 구현됨
- HNI auto-company backend-connected v1.1 MVP가 구현됨
- 실채널 연동 1차 설계 문서가 준비됨
- HNI 대시보드의 Flutter 위젯 단위 IA/spec이 정의됨
- 무엇을 도입하고 무엇을 금지할지 구분됨
- 승인된 설계 범위의 문서 패키지가 완성됨

## Planner Decision

- [x] APPROVED
- [ ] REVISE
- [ ] HOLD

## Planner Notes

- 2026-04-09 사용자 승인으로 실행 단계로 전환한다.
- 이번 승인 범위는 운영모델 설계 문서 완성까지다.
- 사용자 추가 요청으로 HNI 전용 프로그램 정의와
  채널/대시보드 설계를 범위에 포함한다.
- 사용자 추가 요청으로 Mozzy V1/V2 보고서 템플릿과
  Flutter IA/spec을 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1/V2 제품군 실제 초안 보고서 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1/V2 엔지니어링군 실제 초안 보고서 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1/V2 merge blocker checklist 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy core smoke verification plan 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V1 baseline feature 표 작성도 범위에 포함한다.
- 사용자 추가 요청으로
  Mozzy V2 first merge slice 정의도 범위에 포함한다.
- 사용자 추가 요청으로
  neighborhood read slice 세부 smoke checklist도 범위에 포함한다.
- 사용자 추가 요청으로
  HNI auto-company 최소 실행 MVP 구현도 범위에 포함한다.
- 사용자 추가 요청으로
  backend-connected v1.1 MVP와
  실채널 연동 1차 설계도 범위에 포함한다.
- 앱 코드 수정과 배포는 여전히 범위 밖이다.
- `auto-company`는 참조 아키텍처로만 다룬다.
