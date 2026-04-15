# HNI AI Subdomain Architecture

## Purpose

이 문서는 `humantric.net`과
`ai.humantric.net`를 분리하는
HNI 공개 도메인 아키텍처를 정의한다.

핵심 목적은 세 가지다.

- Mozzy/HNI landing과
  HNI auto-company control plane을 분리한다.
- Telegram webhook/backend를
  static landing host와 분리한다.
- `bling` Firebase Hosting 구조를 유지하면서도
  HNI 운영 backend를 안전하게 붙인다.

## Recommended Topology

### `humantric.net`

- 소유 repo: `bling`
- 역할:
  - marketing landing
  - Mozzy 소개/IR/download/recruitment
  - `/app` web preview 진입점
- 구현 성격:
  - Firebase Hosting public static/web hosting
  - `public/index.html` 중심

### `ai.humantric.net`

- 소유 repo: `mozzy-ai-team`
- 역할:
  - HNI auto-company backend public entry
  - Telegram webhook domain
  - HNI operator dashboard future web entry
  - admin/status/control routes
- 구현 성격:
  - reverse proxy + private backend
  - HTTPS only
  - backend는 `127.0.0.1:8787` 유지

## Why Split Is Preferred

### 1. Hosting Model Conflict Avoidance

`bling`의 Firebase Hosting은
`/app/** -> /app/index.html`,
그 외 `** -> /index.html`로
catchall rewrite가 걸려 있다.

이 구조에서는 Telegram webhook path를
같은 host에 추가해도
별도 backend rewrite/proxy가 없으면
landing page로 흡수될 수 있다.

### 2. Security Boundary

landing host는
검색엔진/광고/일반 공개 페이지 특성이 강하다.
반면 HNI backend는
bot token, webhook secret, command intake,
approval flow, audit trail을 다룬다.

둘을 같은 runtime에 두면
정적 공개 자산과 운영 backend의
책임 경계가 흐려진다.

### 3. Operational Clarity

도메인을 분리하면
사용자-facing landing 문제와
Telegram/backend 문제를
독립적으로 운영할 수 있다.

## Traffic Model

### Public Web Users

1. 일반 방문자는 `https://humantric.net/`에 들어온다.
2. landing page는 Mozzy/HNI 소개와
   app preview/download/IR로 안내한다.
3. HNI 내부 운영용 진입이 필요하면
   별도 CTA 또는 deep link로
   `https://ai.humantric.net/`을 가리킨다.

### Telegram Command Flow

1. Telegram Bot API가
   `https://ai.humantric.net/api/v1/integrations/telegram/webhook`로 전달한다.
2. reverse proxy가
   local backend `127.0.0.1:8787`로 프록시한다.
3. backend가
   sender policy, command parsing,
   work order mutation, reply dispatch를 처리한다.

### Future Dashboard Web Flow

현재 HNI는 desktop-first지만,
향후 web dashboard를 붙인다면
`ai.humantric.net/dashboard` namespace를 권장한다.
상세 route 구조는
[HNI_AI_WEB_DASHBOARD_ROUTES.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_WEB_DASHBOARD_ROUTES.md)
를 따른다.

## Domain Responsibility Matrix

- `humantric.net`
  - role: landing + Mozzy preview
  - runtime: Firebase Hosting
  - audience: public
- `ai.humantric.net`
  - role: HNI control/backend
  - runtime: reverse proxy + private app
  - audience: operators + Telegram

## DNS and TLS

### Landing Domain (`humantric.net`)

- 기존 landing/web preview 운영값 유지
- `bling` hosting 정책을 그대로 사용

### Control Domain (`ai.humantric.net`)

- 별도 A/AAAA 레코드
- 별도 TLS certificate
- HTTPS only
- reverse proxy는 `443/tcp` 수신

## Reverse Proxy Boundary

`ai.humantric.net`에서만
reverse proxy와 backend를 운영한다.

권장 구조:

- public ingress:
  - `443 -> nginx`
- private app runtime:
  - `nginx -> 127.0.0.1:8787`
- backend는 외부 방화벽에 직접 노출하지 않는다.

## Landing Integration Rules

`humantric.net` landing에는
아래 두 가지까지만 두는 것을 권장한다.

- HNI control plane 소개 CTA
- Telegram bot deep link 또는 contact CTA

권장 예:

- `Open HNI Control`
  -> `https://ai.humantric.net/`
- `Open Telegram Bot`
  -> `https://t.me/hni_mozzy_bot`

반대로 아래는 landing host에 두지 않는다.

- Telegram webhook receiver
- backend status endpoint
- approval/control API
- bot token/secret 관련 설정

## Path Policy

### Landing Host Paths

- `/`
- `/app`
- `/download`
- `/investors`
- `/recruitment`
- 기타 landing/public static routes

### Control Host Paths

- `/api/v1/integrations/telegram/webhook`
- `/api/v1/integrations/telegram/status`
- `/api/v1/integrations/telegram/set-webhook`
- `/api/v1/integrations/telegram/delete-webhook`
- `/api/v1/integrations/telegram/poll-once`
- 향후 `/dashboard`, `/auth`, `/api/v1/orders` 등

## Implementation Guidance

### Current Phase

지금 당장 필요한 것은
`ai.humantric.net`를
Telegram webhook와 HNI backend 전용으로 두는 것이다.

즉,

- landing는 `bling`에서 계속 운영
- backend는 `mozzy-ai-team`에서 계속 운영
- 두 시스템은 링크로만 연결

### Optional Next Step

필요하면 나중에
`ai.humantric.net` 아래에
web dashboard를 추가할 수 있다.
하지만 이 단계에서도
landing를 같은 host로 합치지는 않는다.

## Rollout Order

1. `humantric.net`은 기존 구조 유지
2. `ai.humantric.net` DNS 생성
3. `ai.humantric.net` TLS 발급
4. reverse proxy + backend 배치
5. Telegram webhook 등록
6. 필요 시 `humantric.net` landing에
   `ai.humantric.net` 또는 bot deep link CTA 추가

## Non-Goals

- `humantric.net` Firebase Hosting 위에
  webhook backend를 직접 탑재하지 않는다.
- `public/index.html` 자체를
  webhook endpoint로 바꾸지 않는다.
- 이번 문서는 실제 production cutover를 수행하지 않는다.
