# HNI Auto-Company MVP

## Purpose

이 앱은 HNI auto-company의 최소 실행 MVP다.

- HNI CEO 또는 운영자가 work order를 만든다.
- plan approval 전에는 실행이 시작되지 않는다.
- approval 이후에는 `분석 -> 계획 -> 실행 -> 평가 -> 수정 -> 완료 보고`
  흐름을 추가 승인 요청 없이 끝까지 자동 실행한다.
- 결과는 dashboard, reports, approvals, audit timeline에서 확인한다.

## Current MVP Scope

- Flutter Windows/macOS 데스크톱 앱
- 로컬 JSON persistence
- work order 생성/보류/재개
- plan approval / risk gate approval
- auto-run stage engine
- report timeline
- Telegram/WhatsApp 형식 local command simulator

## v1.1 Backend-Connected Mode

- 로컬 HTTP backend가 authoritative state를 가진다.
- desktop client는 `API_BASE_URL`이 있을 때
  backend-connected mode로 동작한다.
- approval 이후 stage auto-run은
  backend에서 진행되고 client는 polling으로 따라간다.

## Local Run

```bash
cd hni_auto_company_mvp
flutter pub get
flutter run -d macos
```

Windows에서는 `flutter run -d windows`를 사용한다.

## Backend Run

```bash
cd hni_auto_company_mvp
dart run bin/server.dart
```

backend-connected mode로 실행하려면:

```bash
cd hni_auto_company_mvp
flutter run -d macos --dart-define=API_BASE_URL=http://127.0.0.1:8787
```

## Verification

```bash
cd hni_auto_company_mvp
flutter analyze
flutter test
```

## Supported Commands

- `/new_order title | objective | product | branch`
- `/approve WO-101`
- `/hold WO-101 | note`
- `/resume WO-101`
- `/status WO-101`
- `/help`

## Persistence

앱 상태는 `Application Support` 경로 아래의
`hni_auto_company_mvp_state.json`에 저장된다.

## Not Included Yet

- 실제 Telegram webhook
- 실제 WhatsApp Cloud API
- multi-user auth
- production-hosted backend
- real AI inference
- GitHub live sync
