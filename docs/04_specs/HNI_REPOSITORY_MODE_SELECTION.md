# HNI Repository Mode Selection

## Purpose

이 문서는
`hni_auto_company_mvp/lib/main.dart`의
아래 분기를 중심으로
repository mode selection 구조를 정의한다.

```dart
final repository = apiBaseUrl.isEmpty
    ? FileAppRepository()
    : HttpAppRepository(baseUrl: apiBaseUrl);
```

핵심 목적은 세 가지다.

- 현재 분기가 무엇을 의미하는지 고정한다.
- local mode와 backend-connected mode의 경계를 명확히 한다.
- future web/dashboard 단계에서
  어떻게 확장해야 하는지 원칙을 정한다.

## Current Interpretation

현재 분기는
v1.1 기준의 2-mode selector다.

- `API_BASE_URL`이 비어 있으면
  local file-backed mode
- `API_BASE_URL`이 있으면
  backend-connected HTTP mode

즉 이 코드는
“저장소 종류 선택”이면서 동시에
“runtime mode 선택” 역할도 한다.

## Current Mode Matrix

### Mode A. Local File Mode

- selector:
  `API_BASE_URL` 없음
- repository:
  `FileAppRepository`
- authority:
  local application support JSON file
- 주요 목적:
  desktop 단독 실행
- 장점:
  - setup가 단순함
  - backend 없이도 데모 가능
  - 오프라인/로컬 실험에 유리
- 한계:
  - multi-user 불가
  - webhook/integration과 자연스럽게 합쳐지지 않음
  - state authority가 client에 있어 운영 환경과 멀어짐

### Mode B. Backend-Connected HTTP Mode

- selector:
  `API_BASE_URL` 존재
- repository:
  `HttpAppRepository`
- authority:
  backend snapshot/API
- 주요 목적:
  local backend 또는 future remote backend 연결
- 장점:
  - state authority가 backend에 있음
  - Telegram/channel flow와 정합성이 맞음
  - future web/admin 구조로 이어가기 쉬움
- 한계:
  - backend availability에 의존
  - 현재는 polling 기반이라 즉시성 한계 존재

## Why This Works for v1.1

v1.1의 목표는
local MVP와 backend-connected MVP를
하나의 client entry에서 공존시키는 것이었다.

그 조건에서는
`API_BASE_URL` 유무만으로도
mode를 나누는 방식이 충분히 단순하고 실용적이다.

즉 현재 분기는
복잡한 mode registry보다
빠른 검증을 위한 pragmatic bootstrap으로 본다.

## Why This Should Not Be the Final Form

future 단계에서
다음 runtime이 추가될 가능성이 높다.

- desktop local demo mode
- desktop backend-connected mode
- web dashboard mode
- remote production admin mode
- test/mock mode

이때 `API_BASE_URL` 유무만으로
모든 모드를 구분하면
해석이 모호해진다.

예:

- web runtime인데 `API_BASE_URL`이 빠진 경우
- local backend를 쓰지만 별도 auth/profile이 필요한 경우
- test 환경에서 mock repository를 써야 하는 경우

## Future Design Principle

### 1. Repository choice and runtime mode should be separated conceptually

앞으로는 아래 두 층을 분리해 생각한다.

- runtime mode:
  앱이 어떤 환경에서 실행되는가
- repository implementation:
  state authority에 어떻게 접근하는가

현재는 이 둘이 한 줄 분기로 합쳐져 있지만,
future 단계에서는 명시적으로 나누는 것이 맞다.

### 2. Web dashboard should default to remote repository only

future `ai.humantric.net` web dashboard에서는
기본값을 file repository로 두지 않는다.

이유:

- browser local state는 authority가 되면 안 된다
- operator UI는 backend authority와 붙어야 한다
- Telegram/webhook/audit와 같은 운영 데이터는
  중앙 authority 기준이어야 한다

즉 web/admin runtime에서는
`HttpAppRepository` 또는 그 후속 remote repository만 허용한다.

### 3. Fail-fast validation is preferred over silent fallback

future runtime에서는
필수 env가 없을 때
조용히 local file mode로 떨어지지 않는 것이 좋다.

권장:

- desktop demo만 local fallback 허용
- web/admin은 env 불충분 시 startup error 또는 config error 화면

## Recommended Future Shape

### Option A. Explicit runtime mode env

예:

```text
HNI_APP_MODE=desktop_local
HNI_APP_MODE=desktop_remote
HNI_APP_MODE=web_admin
```

그리고 bootstrap에서
mode별로 허용 repository를 고른다.

### Option B. Repository factory layer

예:

- `AppRuntimeConfig`
- `RepositoryFactory`
- `BootstrapValidator`

역할:

- env/define 읽기
- mode validation
- repository 생성
- 잘못된 조합 차단

## Recommended Decision Table

### Desktop local demo

- runtime:
  `desktop_local`
- repository:
  `FileAppRepository`
- allowed:
  yes

### Desktop backend-connected

- runtime:
  `desktop_remote`
- repository:
  `HttpAppRepository`
- required:
  `API_BASE_URL`

### Web dashboard

- runtime:
  `web_admin`
- repository:
  remote only
- required:
  backend base URL + auth/session context
- local file fallback:
  no

## Bootstrap Guidance

현재 줄의 의미는 유지하되,
future refactor에서는 아래 형태를 권장한다.

1. config를 읽는다
2. runtime mode를 판정한다
3. mode와 env가 합법 조합인지 검증한다
4. repository를 생성한다
5. store를 load한다
6. app을 실행한다

## Relationship to Existing Files

- current bootstrap:
  [main.dart](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/lib/main.dart)
- repository abstraction:
  [persistence.dart](/Users/jbak2588/mozzy-ai-team/hni_auto_company_mvp/lib/src/persistence.dart)
- v1.1 scope:
  [HNI_AUTO_COMPANY_V11_SCOPE.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AUTO_COMPANY_V11_SCOPE.md)

## Non-Goals

- 이번 문서는 실제 factory 코드를 구현하지 않는다.
- 이번 문서는 web auth/session provider를 확정하지 않는다.
- 이번 문서는 store 구조 자체를 리팩터링하지 않는다.
