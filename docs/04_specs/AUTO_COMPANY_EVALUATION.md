# AUTO_COMPANY_EVALUATION.md

## Evaluation Target

- 사용자 요청 기준: `nicepkg/auto-company`
- 실제 확인 리포지토리: `xiaoq17/nicepkg-auto-company`
- 기준 브랜치: `main`

## What Auto-Company Is

`auto-company`는 Claude Code Agent Teams를 이용해
AI 팀이 24/7로 계속 돌도록 만든 자율 루프형 운영 저장소다.

핵심 구성은 아래와 같다.

- `CLAUDE.md`: 회사 헌장, 안전선, 14-agent 역할, 협업 흐름
- `PROMPT.md`: 각 사이클에서 읽는 루프 프롬프트
- `.claude/agents/*.md`: 14개 agent 정의
- `.claude/settings.json`: Agent Teams 활성화와 권한 설정
- `auto-loop.sh`: fresh session + consensus relay 방식의 반복 실행기
- `docs/<role>/`: agent별 산출물 디렉터리
- `memories/consensus.md`: 사이클 간 공통 기억

## 14 Agents In Auto-Company

### 전략층

- `ceo-bezos`: 전략, 우선순위, 비즈니스 방향
- `cto-vogels`: 아키텍처, 기술선택, 신뢰성
- `critic-munger`: 역검토, pre-mortem, 결정 제동

### 제품층

- `product-norman`: 문제정의, UX 원칙, 사용성
- `ui-duarte`: 시각 시스템, 디자인 언어
- `interaction-cooper`: 사용자 플로우, persona, 내비게이션

### 엔지니어링층

- `fullstack-dhh`: 구현, 리팩터링, 기술 생산성
- `qa-bach`: 테스트 전략, 품질 리스크
- `devops-hightower`: 배포, CI/CD, 운영 안정성

### 비즈니스층

- `marketing-godin`: 포지셔닝, 마케팅, 메시지
- `operations-pg`: 초기 운영, 성장, 커뮤니티 활성화
- `sales-ross`: 판매 구조, 전환, 수익화 패키징
- `cfo-campbell`: 가격, 수익성, 단위경제

### 인텔리전스층

- `research-thompson`: 시장 조사, 경쟁 분석, 구조적 해석

## How The 14 Agents Are Actually Wired

- 14개 agent는 모두 개별 persona 파일로 정의돼 있다.
- 실제 실행은 매 사이클마다 3~5개 관련 agent만 묶는 방식이다.
- 협업 기준 흐름은 `CLAUDE.md`와
  `.claude/skills/team/SKILL.md`에 연결된다.
- 장기 상태는 `memories/consensus.md` 하나로 넘긴다.
- `auto-loop.sh`가 새 세션을 반복적으로 열어
  prompt + consensus를 읽히고 결과를 다시 기록한다.

## What Makes Auto-Company Powerful

- 역할이 분명해서 사고 프레임을 빠르게 전환할 수 있다.
- 문서 위치와 산출물 디렉터리가 agent별로 명확하다.
- 전략, 제품, 엔지니어링, 비즈니스가 한 루프 안에 묶여 있다.
- 반복 사이클과 consensus relay 구조가 있어
  장기 작업을 이어가기 쉽다.

## What Conflicts With Humantric Governance

- `CLAUDE.md`는 인간 승인 없이 직접 행동하라고 강하게 지시한다.
- `.claude/settings.json`은 `bypassPermissions`를 기본값으로 둔다.
- `auto-loop.sh`는 사실상 자율 운영을 전제로 한다.
- CEO agent가 최종 결정을 AI 내부에서 내리도록 설계돼 있다.

이 4가지는 현재 Mozzy 운영원칙과 직접 충돌한다.

## Mozzy / Bling Context Check

`bling`은 단순 SaaS가 아니라 아래 특성을 가진 Flutter 기반 슈퍼앱이다.

- Flutter 앱 + Firebase + Cloud Functions 조합
- 지역 피드, 마켓, 채팅, 친구찾기, 상점, 모임, 구인 등 다기능 구조
- 위치정보, 신뢰도, 커뮤니티 운영, 거래가 강하게 엮여 있음
- 다국어와 국가 확장 문서가 이미 존재함
- 보안/개인정보/운영 리스크가 일반 랜딩페이지 SaaS보다 큼

따라서 `auto-company`의 완전자율 모델은 부적합하고,
역할 분리와 문서 구조만 선별 도입하는 편이 맞다.

## Adoption Recommendation For Humantric

### Keep

- 14-agent 역할 분해 방식
- agent별 문서 산출물 구조
- 작업 유형별 3~5 agent 소팀 편성 방식
- consensus 기반 의사결정 기록

### Reject

- 인간 승인 없는 자율 실행
- 권한 우회 기본 설정
- 자동 루프 기반 상시 실행
- AI 내부 최종결정 구조

### Replace

- `autonomous loop` → `approved execution workflow`
- `AI CEO final decision` → `human final approval`
- `bypassPermissions` → 최소권한 + 승인게이트
- `ship without asking` → 문서화 후 승인 범위 내 연속 실행

## Recommended Humantric Adoption Shape

1. 14-agent는 유지하되 전부 advisory role로 재정의한다.
2. Humantric 의사결정자가 scope / release / security gate를 가진다.
3. Mozzy 작업은 항상 소규모 agent squad 단위로 호출한다.
4. 초기에는 루프 자동화 없이 문서 기반 orchestration부터 시작한다.
5. 실제 구현은 승인 후 pilot squad부터 점진 적용한다.

## Conclusion

`auto-company`는 Humantric가 그대로 복제할 대상이 아니라,
**역할 구조와 협업 틀을 추출해 통제형 운영체계로 변환할 참고 모델**이다.

Mozzy에 맞는 답은
"14개 자율 agent 회사"가 아니라
"14개 전문 agent를 인간 승인 체계 아래 운영하는 제품 개발 팀"이다.
