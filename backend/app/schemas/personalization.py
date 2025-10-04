from pydantic import BaseModel
from typing import Optional, Any
from datetime import datetime


class EngagementEventIn(BaseModel):
    event_type: str
    metadata: Optional[Any] = None


class RecommendationOut(BaseModel):
    content_key: str
    score: int
    created_at: datetime

    model_config = {"from_attributes": True}
