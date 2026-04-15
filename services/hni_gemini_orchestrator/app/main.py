from fastapi import FastAPI, HTTPException

from .config import load_settings
from .engine import GeminiOrchestratorEngine
from .models import AgentGraphResponse, StageRunRequest, StageRunResponse

settings = load_settings()
engine = GeminiOrchestratorEngine(settings)

app = FastAPI(
    title="HNI Gemini Orchestrator",
    version="0.1.0",
    description="Gemini-based persona execution runtime for Mozzy-ai-team.",
)


@app.get("/health")
def health() -> dict[str, str]:
    return {
        "status": "ok",
        "providerMode": engine.provider_mode,
        "model": settings.gemini_model,
    }


@app.post("/v1/stage-runs", response_model=StageRunResponse)
def create_stage_run(payload: StageRunRequest) -> StageRunResponse:
    return engine.run_stage(payload)


@app.get("/v1/stage-runs/{run_id}", response_model=StageRunResponse)
def get_stage_run(run_id: str) -> StageRunResponse:
    result = engine.get_run(run_id)
    if result is None:
        raise HTTPException(status_code=404, detail="run not found")
    return result


@app.get("/v1/work-orders/{order_id}/agent-graph", response_model=AgentGraphResponse)
def get_agent_graph(order_id: str) -> AgentGraphResponse:
    return engine.build_agent_graph(order_id)
