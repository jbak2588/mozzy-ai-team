from __future__ import annotations

import json
import uuid
from dataclasses import dataclass
from typing import Any, Optional
from urllib import parse, request

from .config import Settings
from .models import AgentGraphNode, AgentGraphResponse, StageRunRequest, StageRunResponse, utc_now_iso
from .personas import PERSONAS


@dataclass
class StageRunRecord:
    payload: StageRunResponse


class GeminiOrchestratorEngine:
    def __init__(self, settings: Settings):
        self._settings = settings
        self._runs: dict[str, StageRunRecord] = {}
        self._runs_by_order: dict[str, list[str]] = {}

    @property
    def provider_mode(self) -> str:
        return "gemini" if self._settings.gemini_api_key else "deterministic-fallback"

    def run_stage(self, stage_run: StageRunRequest) -> StageRunResponse:
        personas = stage_run.selectedPersonas or self._default_personas(stage_run.assignedSquad)
        summary, findings, recommendations, provider = self._generate_content(stage_run, personas)
        created_at = utc_now_iso()
        run = StageRunResponse(
            runId=f"SR-{uuid.uuid4().hex[:12]}",
            orderId=stage_run.orderId,
            stage=stage_run.stage,
            status="completed",
            provider=provider,
            selectedPersonas=personas,
            summary=summary,
            findings=findings,
            recommendations=recommendations,
            createdAt=created_at,
            completedAt=created_at,
        )
        self._runs[run.runId] = StageRunRecord(payload=run)
        self._runs_by_order.setdefault(stage_run.orderId, []).append(run.runId)
        return run

    def get_run(self, run_id: str) -> Optional[StageRunResponse]:
        record = self._runs.get(run_id)
        return None if record is None else record.payload

    def build_agent_graph(self, order_id: str) -> AgentGraphResponse:
        run_ids = self._runs_by_order.get(order_id, [])
        latest_run = self._runs[run_ids[-1]].payload if run_ids else None
        selected = [] if latest_run is None else latest_run.selectedPersonas
        lead = selected[0] if selected else None
        nodes: list[AgentGraphNode] = []
        for item in PERSONAS:
            has_report = latest_run is not None and item["persona"] in latest_run.selectedPersonas
            status = "idle"
            if latest_run is not None and item["persona"] == lead:
                status = "lead"
            elif latest_run is not None and item["persona"] in latest_run.selectedPersonas:
                status = "completed"
            elif has_report:
                status = "recent"
            nodes.append(
                AgentGraphNode(
                    persona=item["persona"],
                    group=item["group"],
                    title=item["title"],
                    focus=item["focus"],
                    status=status,
                    assigned=item["persona"] in selected,
                    isLead=item["persona"] == lead,
                    reportCount=1 if item["persona"] in selected else 0,
                    latestSummary=latest_run.summary if has_report else None,
                    currentStageLabel=latest_run.stage if latest_run is not None else None,
                )
            )
        return AgentGraphResponse(
            orderId=order_id,
            orderStatus="orchestrated" if latest_run else "queued",
            assignedSquad="Gemini Orchestrator",
            selectedPersonas=selected,
            leadPersona=lead,
            activeStageLabel=None if latest_run is None else latest_run.stage,
            providerMode=self.provider_mode,
            nodes=nodes,
        )

    def _generate_content(
        self,
        stage_run: StageRunRequest,
        personas: list[str],
    ) -> tuple[str, list[str], list[str], str]:
        if self._settings.gemini_api_key:
            try:
                text = self._call_gemini(stage_run, personas)
                return (
                    text,
                    [
                        f"selected personas: {', '.join(personas)}",
                        f"target branch: {stage_run.targetBranch}",
                    ],
                    [f"Advance to the next lifecycle stage after reviewing {stage_run.stage} output."],
                    "gemini",
                )
            except Exception as error:
                return self._fallback_content(stage_run, personas, provider=f"gemini-fallback:{error}")
        return self._fallback_content(stage_run, personas, provider="deterministic-fallback")

    def _fallback_content(
        self,
        stage_run: StageRunRequest,
        personas: list[str],
        *,
        provider: str,
    ) -> tuple[str, list[str], list[str], str]:
        stage_title = stage_run.stage.replace("_", " ")
        summary = (
            f"{stage_title.title()} finished for {stage_run.orderId}. "
            f"{', '.join(personas)}가 {stage_run.targetProduct} / {stage_run.targetBranch} 기준으로 정리했다."
        )
        findings = [
            stage_run.objective,
            f"selected personas: {', '.join(personas)}",
            f"assigned squad: {stage_run.assignedSquad or 'unspecified'}",
        ]
        recommendations = [
            f"{stage_run.stage} 결과를 control plane report로 반영한다.",
            "필요 시 lead persona를 재지정하고 다음 stage를 dispatch한다.",
        ]
        return summary, findings, recommendations, provider

    def _call_gemini(self, stage_run: StageRunRequest, personas: list[str]) -> str:
        prompt = (
            "You are the HNI Mozzy-ai-team Gemini orchestrator.\n"
            f"Stage: {stage_run.stage}\n"
            f"Order: {stage_run.orderId}\n"
            f"Objective: {stage_run.objective}\n"
            f"Target product: {stage_run.targetProduct}\n"
            f"Target branch: {stage_run.targetBranch}\n"
            f"Selected personas: {', '.join(personas)}\n"
            "Return a concise Korean execution summary in 2-4 sentences."
        )
        payload = json.dumps(
            {
                "contents": [
                    {
                        "parts": [
                            {"text": prompt},
                        ]
                    }
                ]
            }
        ).encode("utf-8")
        query = parse.urlencode({"key": self._settings.gemini_api_key})
        url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{self._settings.gemini_model}:generateContent?{query}"
        )
        req = request.Request(
            url,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with request.urlopen(req, timeout=15) as response:
            body = json.loads(response.read().decode("utf-8"))
        return _extract_text(body) or "Gemini summary was empty."

    @staticmethod
    def _default_personas(assigned_squad: Optional[str]) -> list[str]:
        if assigned_squad == "Discovery":
            return ["ceo-bezos", "research-thompson", "product-norman"]
        if assigned_squad == "Feature Delivery":
            return ["cto-vogels", "fullstack-dhh", "qa-bach", "ui-duarte"]
        if assigned_squad == "Trust & Readiness":
            return ["critic-munger", "qa-bach", "devops-hightower"]
        return ["ceo-bezos", "cto-vogels", "fullstack-dhh"]


def _extract_text(payload: dict[str, Any]) -> str:
    candidates = payload.get("candidates") or []
    for candidate in candidates:
        content = candidate.get("content") or {}
        for part in content.get("parts") or []:
            text = part.get("text")
            if isinstance(text, str) and text.strip():
                return text.strip()
    return ""
