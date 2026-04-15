# HNI AI Auth Provider Comparison

## Purpose

이 문서는
`ai.humantric.net` future web dashboard의
human auth provider 후보를 비교하고,
HNI용 선택 기준을 세분화한다.

세부 OIDC/session 원칙은
[HNI_AI_AUTH_OIDC_DESIGN.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_OIDC_DESIGN.md)
를 따른다.

## Scope

이번 문서는
"어떤 provider가 더 유명한가"를 정하지 않는다.
대신 아래를 정리한다.

- HNI control plane에 중요한 비교축
- 후보별 장점과 제약
- 현재 시점 provisional recommendation

## Canonical Selection Rule

가장 먼저 볼 기준은 아래다.

1. HNI가 이미 쓰는 workforce IdP가 있는가
2. 그 IdP가
   `OIDC + Authorization Code + PKCE`,
   role/group claim,
   MFA/step-up을
   충분히 지원하는가
3. `ai.humantric.net`의
   same-origin dashboard/API/session 구조와
   충돌하지 않는가

즉 신규 provider 도입은
기존 조직 identity를 재사용할 수 없거나,
재사용해도 요구 조건을 못 맞출 때만 검토한다.

## HNI Selection Criteria

### 1. Protocol Fit

- OIDC 표준 지원
- Authorization Code + PKCE 적합성
- redirect/callback/logout 구성 단순성

### 2. Role and Claim Fit

- `email`, `name`, `sub` 기본 claim 안정성
- `groups` 또는 `roles` claim 제공성
- HNI 내부 role 계층
  `Operator -> Lead -> Approver -> CEO -> Admin`
  으로 매핑하기 쉬운가

### 3. Step-Up and Sensitive Action Fit

- MFA 강제 가능성
- risk-based 또는 conditional step-up 확장성
- `/dashboard/approvals`,
  `/dashboard/strategy`,
  protected ops route에
  stronger auth를 걸기 쉬운가

### 4. Operating Model Fit

- 내부 운영팀이 관리 가능한가
- 외부 B2C/B2B customer identity보다
  내부 operator portal에 더 잘 맞는가
- vendor lock, add-on, 운영 콘솔 복잡도가
  감당 가능한 수준인가

### 5. Architecture Fit

- `ai.humantric.net` same-origin session cookie 모델과 잘 맞는가
- reverse proxy 뒤 backend/session 구조와 충돌하지 않는가
- future web dashboard와 Telegram ops 보호 흐름에
  쉽게 연결되는가

## Candidate Comparison

### A. Microsoft Entra ID

#### Entra Strong Points

- Microsoft Learn 기준으로
  Entra는 OAuth 2.0 / OIDC 표준 endpoint와
  authorization code flow를 제공한다.
- group claim과 application role 구성이 가능하다.
- Conditional Access와 authentication context로
  step-up auth를 세밀하게 걸 수 있다.
- 내부 workforce portal, admin route,
  privileged action 보호와 잘 맞는다.

#### Entra Constraints

- group claim이 많아지면
  token에 모두 실리지 않을 수 있고,
  큰 멤버십은 Graph fallback을 고려해야 한다.
- Conditional Access와 auth context는
  조직 정책/라이선스/운영 이해도가 필요하다.
- Microsoft 중심 운영을 하지 않는 조직에는
  admin surface가 다소 무겁다.

#### Entra HNI Fit

- HNI가 Microsoft 365 / Entra를 이미 쓰고 있으면
  가장 자연스러운 1순위 후보다.
- internal operator dashboard,
  approval gate,
  recent-auth/step-up 시나리오와 특히 잘 맞는다.

### B. Okta

#### Okta Strong Points

- Okta 공식 문서는
  public client에 대해
  Authorization Code with PKCE를
  권장 흐름으로 둔다.
- groups claim을 앱별로 커스터마이즈할 수 있다.
- `acr_values` 기반 step-up authentication guide가 있어
  route별 stronger auth 설계와 잘 맞는다.
- 특정 hyperscaler에 덜 종속적인
  neutral workforce IdP로 쓰기 좋다.

#### Okta Constraints

- production에서 custom authorization server나
  세밀한 claim/custom policy가 필요하면
  별도 제품/플랜 고려가 필요할 수 있다.
- Entra보다 기본 생태계 결합은 약하지만,
  대신 운영자가 직접 구성해야 할 항목이 늘 수 있다.

#### Okta HNI Fit

- HNI가 특정 cloud/vendor에 identity를 묶고 싶지 않다면
  strong candidate다.
- internal operator portal과
  role-based gate, step-up route 보호에 잘 맞는다.

### C. Auth0

#### Auth0 Strong Points

- Auth0는 PKCE flow를 명확히 지원한다.
- custom claim, Actions, Organizations,
  refresh token rotation 같은 확장성이 강하다.
- 향후 HNI가
  internal operator뿐 아니라
  partner/vendor/external org 분리까지
  키우려면 유연성이 높다.

#### Auth0 Constraints

- Organizations, Adaptive MFA 등
  일부 강한 기능은 plan 영향을 받는다.
- 문서와 SDK가 SPA/public-client 중심으로 전개되는 경우가 많아,
  HNI control plane에서는
  browser token 저장보다
  server-issued session으로 한 번 더 감싸는 설계가 필요하다.
- purely internal workforce portal만 본다면
  Entra/Okta보다 과한 범용성이 될 수 있다.

#### Auth0 HNI Fit

- future HNI가
  외부 협력사, 파트너사, tenant-style organization 분리를
  first-class requirement로 둘 때 강하다.
- 현재처럼 internal operator control plane이 중심이면
  primary보다 conditional candidate에 가깝다.

### D. Google Cloud Identity Platform / IAP Route

#### Google Route Strong Points

- Identity Platform은
  OIDC/SAML provider 연동과
  MFA, multi-tenant 구성을 지원한다.
- IAP는 HTTPS app 앞단에서
  identity 기반 access control layer를 제공하고,
  group-based access를 중앙 정책으로 다룰 수 있다.
- control plane이 Google Cloud에 강하게 올라가면
  infra/auth 경계를 단순화할 수 있다.

#### Google Route Constraints

- Identity Platform은
  app-centric auth 서비스 성격이 강하고,
  workforce role governance 자체는
  dedicated workforce IdP보다 직접 설계가 더 필요하다.
- IAP의 장점은
  app이 Google Cloud 또는 IAP 보호 경로에 있을 때 커진다.
- 현재 repo의 same-origin session 설계와는 양립 가능하지만,
  auth를 IAP 중심으로 바꾸면
  reverse proxy, header trust, hosting topology를
  함께 재설계해야 한다.

#### Google Route HNI Fit

- HNI가 앞으로
  `ai.humantric.net` control plane을
  Google Cloud 운영모델에 강하게 결합할 경우에만
  조건부로 검토할 만하다.
- 현재 문서 범위에서는
  primary recommendation이 아니다.

## Comparison Summary

- `Microsoft Entra ID`
  - protocol fit: strong
  - role/group fit: strong
  - MFA/step-up fit: strong
  - current recommendation:
    Microsoft stack가 이미 있으면 primary candidate
- `Okta`
  - protocol fit: strong
  - role/group fit: strong
  - MFA/step-up fit: strong
  - current recommendation:
    neutral workforce IdP가 필요하면 primary candidate
- `Auth0`
  - protocol fit: strong
  - role/group fit: medium to strong
  - MFA/step-up fit: medium to strong
  - current recommendation:
    extensibility/B2B organization 분리가 핵심일 때 conditional
- `Google Cloud Identity Platform / IAP`
  - protocol fit: medium to strong
  - role/group fit: medium
  - MFA/step-up fit: medium to strong
  - current recommendation:
    Google-centric hosting/security 모델일 때만 conditional

## Provisional Recommendation

현재 기준 recommendation은 아래 순서다.

1. 기존 HNI workforce IdP가 이미 있으면
   그 provider를 먼저 검증한다.
2. Microsoft 중심 운영이면
   `Microsoft Entra ID`를 우선 검토한다.
3. 신규 도입이 필요하고
   neutral workforce IdP가 필요하면
   `Okta`를 우선 검토한다.
4. future partner/vendor organization 분리가
   핵심 requirement면
   `Auth0`를 별도로 올린다.
5. `Google Cloud Identity Platform / IAP` 경로는
   control plane hosting 자체를
   Google Cloud 보안 모델에 더 강하게 얹을 때만 검토한다.

## Recommendation for This Repo

현재 repo 문서만 기준으로 보면
최종 provider를 지금 고정할 정보는 아직 부족하다.

따라서 현재 결정은 아래다.

- auth architecture는 계속 provider-agnostic하게 유지
- default flow는
  `OIDC Authorization Code + PKCE + server-issued session cookie`
  유지
- actual provider selection은
  HNI의 existing workforce stack 확인 이후 확정
- provisional shortlist는
  `Entra ID`, `Okta`, `Auth0`

## Official Source Notes

아래는 이번 비교에 사용한 공식 문서다.

- Microsoft Entra protocol overview:
  [learn.microsoft.com/en-us/entra/identity-platform/v2-protocols](https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols)
- Microsoft Entra group claims:
  [learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-fed-group-claims](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-fed-group-claims)
- Microsoft Entra Conditional Access auth context:
  [learn.microsoft.com/en-us/entra/identity-platform/developer-guide-conditional-access-authentication-context](https://learn.microsoft.com/en-us/entra/identity-platform/developer-guide-conditional-access-authentication-context)
- Microsoft Entra MFA overview:
  [learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks)
- Okta PKCE guide:
  [developer.okta.com/docs/guides/implement-grant-type/authcodepkce/main/](https://developer.okta.com/docs/guides/implement-grant-type/authcodepkce/main/)
- Okta groups claim guide:
  [developer.okta.com/docs/guides/customize-tokens-groups-claim/main/](https://developer.okta.com/docs/guides/customize-tokens-groups-claim/main/)
- Okta step-up auth:
  [developer.okta.com/docs/guides/step-up-authentication/main/](https://developer.okta.com/docs/guides/step-up-authentication/main/)
- Auth0 PKCE flow:
  [auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce](https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce)
- Auth0 Organizations:
  [auth0.com/docs/manage-users/organizations](https://auth0.com/docs/manage-users/organizations)
- Auth0 Adaptive MFA:
  [auth0.com/docs/mfa/adaptive-mfa](https://auth0.com/docs/mfa/adaptive-mfa)
- Auth0 refresh token rotation:
  [auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)
- Google Cloud Identity Platform auth:
  [cloud.google.com/identity-platform/docs/concepts-authentication](https://cloud.google.com/identity-platform/docs/concepts-authentication)
- Google Cloud Identity Platform MFA:
  [cloud.google.com/identity-platform/docs/web/mfa](https://cloud.google.com/identity-platform/docs/web/mfa)
- Google Cloud IAP overview:
  [docs.cloud.google.com/iap/docs/concepts-overview](https://docs.cloud.google.com/iap/docs/concepts-overview)
