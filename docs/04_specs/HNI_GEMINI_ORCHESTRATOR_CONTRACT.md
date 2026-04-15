# HNI_GEMINI_ORCHESTRATOR_CONTRACT.md

## Purpose

이 문서는 Dart control backend와
same-repo Python Gemini orchestrator 사이의
1차 계약을 정리한다.

## Base URL

- env:
  `HNI_AI_ORCHESTRATOR_BASE_URL`
- example:
  `http://127.0.0.1:8091`

## Endpoints

### `GET /health`

- purpose:
  service health와 provider mode 확인
- response:
  - `status`
  - `providerMode`
  - `model`

### `POST /v1/stage-runs`

- purpose:
  하나의 work order stage 실행 요청
- request:
  - `orderId`
  - `stage`
  - `objective`
  - `targetProduct`
  - `targetBranch`
  - `assignedSquad`
  - `selectedPersonas`
- response:
  - `runId`
  - `status`
  - `provider`
  - `selectedPersonas`
  - `summary`
  - `findings`
  - `recommendations`

### `GET /v1/stage-runs/{runId}`

- purpose:
  생성된 stage run 재조회

### `GET /v1/work-orders/{orderId}/agent-graph`

- purpose:
  14-agent diagram용 최신 graph 상태 반환
- response:
  - `orderId`
  - `orderStatus`
  - `assignedSquad`
  - `selectedPersonas`
  - `leadPersona`
  - `providerMode`
  - `nodes[]`

## Security Rule

- `GEMINI_API_KEY`는 Python service env에만 둔다.
- Flutter client나 tracked markdown 예제에는
  실제 key를 기록하지 않는다.
- Dart backend는 Gemini key를 알지 못하고
  URL만 안다.
