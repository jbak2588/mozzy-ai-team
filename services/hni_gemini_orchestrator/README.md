# HNI Gemini Orchestrator

이 서비스는 `Mozzy-ai-team`의 Gemini 기반 persona execution 전용 runtime이다.

## Purpose

- Dart control backend가 직접 LLM key를 다루지 않게 한다.
- 14 persona의 stage-run 결과를 server-side에서 생성한다.
- `agent graph` 상태를 control plane에 제공한다.

## Environment

`.env.example`을 복사해 사용한다.

- `GEMINI_API_KEY`
- `HNI_GEMINI_MODEL`
- `HNI_GEMINI_PORT`

## Run

```bash
cd services/hni_gemini_orchestrator
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export GEMINI_API_KEY=your_key
uvicorn app.main:app --host 127.0.0.1 --port 8091 --reload
```

## API

- `GET /health`
- `POST /v1/stage-runs`
- `GET /v1/stage-runs/{run_id}`
- `GET /v1/work-orders/{order_id}/agent-graph`
