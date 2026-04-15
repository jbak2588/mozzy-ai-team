from pathlib import Path
import sys

from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.main import app


client = TestClient(app)


def test_health_works():
    response = client.get("/health")
    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert "providerMode" in payload


def test_stage_run_roundtrip():
    response = client.post(
        "/v1/stage-runs",
        json={
            "orderId": "WO-777",
            "stage": "execution",
            "objective": "AI orchestration contract smoke",
            "targetProduct": "Mozzy",
            "targetBranch": "main",
            "assignedSquad": "Feature Delivery",
            "selectedPersonas": ["fullstack-dhh", "qa-bach"],
        },
    )
    assert response.status_code == 200
    created = response.json()
    assert created["orderId"] == "WO-777"
    assert created["status"] == "completed"
    run_id = created["runId"]

    fetched = client.get(f"/v1/stage-runs/{run_id}")
    assert fetched.status_code == 200
    assert fetched.json()["runId"] == run_id


def test_agent_graph_reflects_latest_run():
    client.post(
        "/v1/stage-runs",
        json={
            "orderId": "WO-graph",
            "stage": "evaluation",
            "objective": "graph status test",
            "targetProduct": "Mozzy",
            "targetBranch": "hyperlocal-proposal",
            "assignedSquad": "Trust & Readiness",
            "selectedPersonas": ["critic-munger", "qa-bach"],
        },
    )
    response = client.get("/v1/work-orders/WO-graph/agent-graph")
    assert response.status_code == 200
    payload = response.json()
    assert payload["orderId"] == "WO-graph"
    assert "nodes" in payload
    node_map = {item["persona"]: item for item in payload["nodes"]}
    assert node_map["critic-munger"]["assigned"] is True
    assert node_map["critic-munger"]["isLead"] is True
