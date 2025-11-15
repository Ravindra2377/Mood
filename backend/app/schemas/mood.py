from pydantic import BaseModel, field_validator
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

    @field_validator("id", mode="before")
    @classmethod
    def _coerce_id(cls, value: object) -> str:
        return str(value)
