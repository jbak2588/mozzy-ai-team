from datetime import datetime, timezone
from typing import Literal, Optional

from pydantic import BaseModel, Field


class StageRunRequest(BaseModel):
    orderId: str
    stage: str
    objective: str
    targetProduct: str
    targetBranch: str
    assignedSquad: Optional[str] = None
    selectedPersonas: list[str] = Field(default_factory=list)


class StageRunResponse(BaseModel):
    runId: str
    orderId: str
    stage: str
    status: Literal["completed", "failed"]
    provider: str
    selectedPersonas: list[str]
    summary: str
    findings: list[str]
    recommendations: list[str]
    createdAt: str
    completedAt: Optional[str] = None
    error: Optional[str] = None


class AgentGraphNode(BaseModel):
    persona: str
    group: str
    title: str
    focus: str
    status: str
    assigned: bool
    isLead: bool
    reportCount: int
    latestSummary: Optional[str] = None
    currentStageLabel: Optional[str] = None


class AgentGraphResponse(BaseModel):
    orderId: str
    orderStatus: str
    assignedSquad: str
    selectedPersonas: list[str]
    leadPersona: Optional[str] = None
    activeStageLabel: Optional[str] = None
    providerMode: str
    nodes: list[AgentGraphNode]


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()
