# HNI AI Auth Provider Integration Sequences

## Purpose

이 문서는
`ai.humantric.net` future web dashboard의
auth provider별 실제 integration sequence를 정리한다.

선택 기준은
[HNI_AI_AUTH_PROVIDER_COMPARISON.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_PROVIDER_COMPARISON.md),
공통 auth 원칙은
[HNI_AI_AUTH_OIDC_DESIGN.md](/Users/jbak2588/mozzy-ai-team/docs/04_specs/HNI_AI_AUTH_OIDC_DESIGN.md)
를 따른다.

## Common HNI Auth Spine

provider가 달라도
HNI control plane의 공통 spine은 아래 순서를 유지한다.

1. provider app registration
2. HNI login start
3. provider authorize redirect
4. HNI callback receive
5. backend code exchange
6. claim validation and normalization
7. internal role mapping
8. HNI session cookie issue
9. route gate evaluation
10. logout and session termination

## Canonical HNI Routes

integration sequence에서 기준이 되는 route는 아래다.

- `/auth/login`
- `/auth/callback`
- `/auth/logout`
- `/auth/session-expired`
- `/auth/forbidden`

민감 액션 보호는
`/dashboard/approvals`,
`/dashboard/strategy`,
`/api/v1/integrations/telegram/set-webhook` 같은
protected route에서 추가로 걸린다.

## Common Registration Checklist

모든 후보에서 공통으로 필요한 것은 아래다.

- application/client registration
- allowed redirect URI 등록
- allowed logout URI 등록
- issuer/authority 확인
- scope/claim 설계
- group 또는 role source 결정
- MFA / step-up 정책 연결

HNI standard callback example:

- login callback:
  `https://ai.humantric.net/auth/callback`
- logout return:
  `https://ai.humantric.net/auth/login`

## Sequence A. Microsoft Entra ID

### Entra Registration

1. Entra admin center에서
   workforce web app registration을 만든다.
2. web platform redirect URI로
   `https://ai.humantric.net/auth/callback`를 등록한다.
3. front-channel logout URL 또는
   signed-out callback에 대응하는
   `https://ai.humantric.net/auth/logout` 또는
   HNI logout return URL을 등록한다.
4. tenant scope를
   HNI workforce tenant 기준으로 고정한다.
5. group claim 또는 app role 전략을 정한다.
6. Conditional Access / authentication context를
   sensitive route 정책과 매핑한다.

### Entra Runtime Sequence

1. 사용자가 `/auth/login` 진입
2. HNI backend가 Entra authorize endpoint로 redirect
3. Entra sign-in / MFA / consent 처리
4. browser가 `/auth/callback`으로 돌아옴
5. backend가 authorization code를 token으로 교환
6. ID token claim과 issuer/tenant를 검증
7. `groups` 또는 `roles`를
   HNI internal role로 normalize
8. HNI session cookie 발급
9. `/dashboard/home` 또는 intended route로 redirect

### Entra Logout Sequence

1. 사용자가 `/auth/logout` 호출
2. HNI app session 삭제
3. 필요 시 Entra sign-out endpoint로 redirect
4. logout return route에서
   `/auth/login` 또는 signed-out view 표시

### Entra HNI Notes

- HNI가 Microsoft 365/Entra를 이미 쓰면
  registration과 조직 사용자 관리가 가장 자연스럽다.
- group overage 가능성을 고려해
  claim만으로 role mapping이 안 닫히는 경우의 fallback을
  초기에 결정해야 한다.

## Sequence B. Okta

### Okta Registration

1. Okta Admin Console에서
   OIDC app integration을 만든다.
2. application type은
   HNI 구조에 맞는 web/public client 성격으로 선택한다.
3. sign-in redirect URI에
   `https://ai.humantric.net/auth/callback`를 등록한다.
4. sign-out redirect URI에
   `https://ai.humantric.net/auth/login`을 등록한다.
5. Authorization Code와
   필요한 경우 Refresh Token 사용 범위를 정한다.
6. groups claim과
   step-up policy 연계를 설정한다.

### Okta Runtime Sequence

1. `/auth/login`에서 Okta authorize endpoint로 redirect
2. user sign-in / MFA
3. browser가 HNI callback으로 복귀
4. HNI backend가 code와 verifier를 기준으로 token 교환
5. claim 검증 후
   group 값을 HNI role로 normalize
6. HNI session cookie 발급
7. target dashboard route로 redirect

### Okta Logout Sequence

1. HNI session 삭제
2. Okta sign-out 또는 redirect logout flow 호출
3. logout return URL에서
   HNI signed-out state 표시

### Okta HNI Notes

- vendor-neutral workforce IdP가 필요할 때
  가장 단순한 primary candidate다.
- HNI는 browser token 장기 저장보다
  backend session model을 유지하므로,
  Okta SDK를 쓰더라도 최종 상태는
  HNI session cookie로 닫는 것이 맞다.

## Sequence C. Auth0

### Auth0 Registration

1. Auth0에서
   HNI dashboard용 application을 만든다.
2. Allowed Callback URLs에
   `https://ai.humantric.net/auth/callback`를 등록한다.
3. Allowed Logout URLs에
   `https://ai.humantric.net/auth/login`을 등록한다.
4. 필요한 경우 custom domain을 붙인다.
5. Organizations 사용 여부를 결정한다.
6. Universal Login, MFA,
   refresh token rotation 정책을 정한다.

### Auth0 Runtime Sequence

1. `/auth/login`에서
   Auth0 Universal Login으로 redirect
2. user 인증 완료 후
   callback route로 복귀
3. HNI backend가 code를 교환
4. Auth0 claim / org / custom claim을 normalize
5. HNI internal role로 매핑
6. HNI session cookie 발급
7. intended route로 복귀

### Auth0 Logout Sequence

1. HNI session 삭제
2. Auth0 logout endpoint 호출
3. `returnTo`는
   Allowed Logout URLs에 등록된 값만 사용
4. `/auth/login` 또는 signed-out page로 복귀

### Auth0 HNI Notes

- future에 partner/vendor organization 분리가 중요하면
  Organizations가 강점이다.
- current HNI scope가
  internal operator control plane 중심이면
  provider 기능이 과할 수 있다.

## Sequence D. Google Cloud Identity Platform / IAP Route

### Google Route Registration

1. Google Cloud에서 Identity Platform을 활성화한다.
2. Authorized Domains에
   `ai.humantric.net`을 추가한다.
3. external OIDC provider를 붙일 경우
   issuer, client ID, client secret을 등록한다.
4. callback URL은
   Identity Platform handler 기준으로 설정한다.
5. IAP를 쓸 경우
   app 앞단 보호 정책과 group access를 설정한다.

### Google Route Runtime Sequence

1. user가 protected app으로 진입
2. Identity Platform 또는 IAP가
   auth redirect를 수행
3. upstream OIDC provider 인증
4. provider callback 후
   Google-managed handler가 세션을 형성
5. 필요 시 app이 signed headers 또는
   session retrieval로 identity를 받음

### Google Route Logout Sequence

1. app local session 종료
2. IAP sign-out 또는
   Identity Platform session sign-out 수행
3. provider-specific session 정리를 별도로 고려

### Google Route HNI Notes

- 이 경로는
  HNI app 자체가 primary IdP가 아니라
  Google-hosted identity layer를 경유하는 방식이다.
- 현재 repo에서 상정한
  HNI backend session spine과는
  가장 다른 경로이므로
  conditional path로만 본다.

## Provider-to-HNI Mapping Summary

- login start
  - Entra ID:
    HNI `/auth/login` -> Entra authorize
  - Okta:
    HNI `/auth/login` -> Okta authorize
  - Auth0:
    HNI `/auth/login` -> Auth0 Universal Login
  - Google route:
    protected app -> Google auth layer
- callback owner
  - Entra ID / Okta / Auth0:
    HNI backend
  - Google route:
    Google-managed handler first
- session authority
  - Entra ID / Okta / Auth0:
    HNI backend session cookie
  - Google route:
    Google session + app adaptation
- role source
  - Entra ID:
    groups or app roles
  - Okta:
    groups claim
  - Auth0:
    org/custom claims
  - Google route:
    Google/IAP identity and app mapping
- current recommendation
  - Entra ID:
    primary if Microsoft stack exists
  - Okta:
    primary if neutral IdP needed
  - Auth0:
    conditional
  - Google route:
    conditional

## Recommended Implementation Order

실제 구현 순서는 아래가 안전하다.

1. HNI 공통 auth contract 먼저 구현
2. provider adapter는 하나만 먼저 연결
3. role normalization table 고정
4. session cookie / logout / forbidden flow 검증
5. recent-auth / step-up route 보호 추가
6. 두 번째 provider는
   contract compatibility 검증 후에만 추가

## HNI-Specific Manual Values

실구성 시 사람이 채워야 할 값:

- issuer / authority
- client ID
- client secret 또는 인증서
- callback URL
- logout return URL
- allowed domain
- HNI role mapping source
- MFA / step-up policy name

## Official Sources

- Microsoft Entra web app setup:
  [learn.microsoft.com/en-us/entra/identity-platform/tutorial-web-app-dotnet-prepare-app](https://learn.microsoft.com/en-us/entra/identity-platform/tutorial-web-app-dotnet-prepare-app)
- Microsoft Entra auth code flow:
  [learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)
- Okta PKCE flow:
  [developer.okta.com/docs/guides/implement-grant-type/authcodepkce/main/](https://developer.okta.com/docs/guides/implement-grant-type/authcodepkce/main/)
- Okta web redirect model:
  [developer.okta.com/docs/guides/sign-into-web-app-redirect/go/main/](https://developer.okta.com/docs/guides/sign-into-web-app-redirect/go/main/)
- Auth0 application settings:
  [auth0.com/docs/get-started/applications/application-settings](https://auth0.com/docs/get-started/applications/application-settings)
- Auth0 logout redirect:
  [auth0.com/docs/login/logout/redirect-users-after-logout](https://auth0.com/docs/login/logout/redirect-users-after-logout)
- Google Identity Platform OIDC:
  [docs.cloud.google.com/identity-platform/docs/web/oidc](https://docs.cloud.google.com/identity-platform/docs/web/oidc)
- Google IAP external identity sessions:
  [docs.cloud.google.com/iap/docs/external-identity-sessions](https://docs.cloud.google.com/iap/docs/external-identity-sessions)
