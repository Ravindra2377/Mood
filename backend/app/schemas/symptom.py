from pydantic import BaseModel
from datetime import datetime

class SymptomCreate(BaseModel):
    symptom: str
    severity: int | None = None
    note: str | None = None

class SymptomRead(BaseModel):
    id: int
    user_id: int
    symptom: str
    severity: int | None
    note: str | None
    created_at: datetime

    model_config = {"from_attributes": True}


class AnalyticsSummary(BaseModel):
    average_mood: float | None
    entries_count: int
    most_common_symptoms: list[str]
