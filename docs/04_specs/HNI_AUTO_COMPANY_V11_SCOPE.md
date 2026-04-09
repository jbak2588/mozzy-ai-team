# HNI Auto-Company v1.1 Scope

## Goal

이 문서는
`hni_auto_company_mvp/`의
backend-connected v1.1 MVP 범위를 고정한다.

## v1.1 Definition

v1.1은 기존 로컬 MVP를 다음 구조로 확장한 버전이다.

- Flutter Windows/macOS 앱은
  HNI desktop client로 동작한다.
- 로컬 HTTP backend가
  authoritative work order state를 가진다.
- work order mutation은
  backend API를 통해 처리된다.
- approval 이후 stage auto-run도
  backend에서 진행된다.
- desktop client는 polling으로
  backend snapshot을 읽어 화면을 갱신한다.

## v1.1 In Scope

- `bin/server.dart` 기반 로컬 backend 서버
- backend JSON persistence
- `/health`, `/api/v1/snapshot`,
  `/api/v1/orders`,
  `/api/v1/orders/:id/approvals/:approvalId/approve`,
  `/api/v1/orders/:id/hold`,
  `/api/v1/orders/:id/resume`,
  `/api/v1/commands` endpoint
- Flutter desktop client의 remote repository 연결
- `API_BASE_URL` 기반 local/remote mode 전환
- remote polling 기반 dashboard 동기화
- backend/service 테스트와 HTTP repository 테스트

## v1.1 Out of Scope

- production hosting
- real auth
- multi-tenant isolation
- websocket/live push
- external Telegram webhook production 연결
- external WhatsApp Cloud API production 연결
- GitHub live sync

## Runtime Shape

### Desktop Client

- Flutter app
- HNI CEO / operator command UI
- report / approval / audit viewer
- backend polling client

### Local Backend

- Dart HTTP server
- work order orchestration service
- local file persistence
- future webhook ingress placeholder

## Success Criteria

- backend 서버가 로컬에서 정상 기동한다.
- Flutter app이 `API_BASE_URL`로 backend에 연결된다.
- 새 order 생성/승인/보류/재개가 API를 통해 동작한다.
- approval 이후 backend가
  `Execution -> Evaluation -> Revision -> Completion`을
  자동 연속 실행한다.
- client는 polling으로 stage 진행과 completion report를 본다.

## Current Implementation

- backend entry:
  `hni_auto_company_mvp/bin/server.dart`
- backend orchestration:
  `hni_auto_company_mvp/lib/src/backend_service.dart`
- client repository:
  `hni_auto_company_mvp/lib/src/persistence.dart`
- client store:
  `hni_auto_company_mvp/lib/src/store.dart`
- client UI:
  `hni_auto_company_mvp/lib/src/app.dart`
- tests:
  `hni_auto_company_mvp/test/backend_service_test.dart`,
  `hni_auto_company_mvp/test/http_repository_test.dart`

## Run Commands

### Backend

```bash
cd hni_auto_company_mvp
dart run bin/server.dart
```

### Desktop Client with Backend

```bash
cd hni_auto_company_mvp
flutter run -d macos --dart-define=API_BASE_URL=http://127.0.0.1:8787
```

Windows에서는 `-d windows`를 사용한다.

## Known Limits

- polling 기반이라
  즉시 push 업데이트는 없다.
- state file은 단일 local JSON이라
  동시성 제어가 단순하다.
- selected order 같은 UI 상태는
  multi-user 기준으로 정교하게 분리하지 않았다.
- 실제 webhook/auth/queue는
  다음 단계에서 설계 및 구현한다.
