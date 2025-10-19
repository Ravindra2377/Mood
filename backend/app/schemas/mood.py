from pydantic import BaseModel
from datetime import datetime

class MoodCreate(BaseModel):
    score: int
    note: str | None = None

class MoodRead(BaseModel):
    id: str  # expose as string for Flutter client
    user_id: int
    score: int
    note: str | None
    created_at: datetime

    model_config = {"from_attributes": True}
