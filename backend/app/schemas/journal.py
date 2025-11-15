from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Literal

# Journal mood options
JournalMoodType = Literal["angry", "sad", "neutral", "happy", "excited"]

class JournalCreate(BaseModel):
    title: str | None = None
    content: str
    mood: JournalMoodType = "neutral"
    entry_date: datetime | None = None
    progress: int | None = None

class JournalRead(BaseModel):
    id: str  # expose as string for Flutter client
    user_id: int
    title: str | None
    content: str
    mood: JournalMoodType
    character_count: int | None = None
    created_at: datetime
    updated_at: datetime | None = None
    entry_date: datetime | None
    progress: int | None
    sentiment: str | None = None
    sentiment_score: float | None = None
    keywords: list[str] = Field(default_factory=list)

    model_config = {"from_attributes": True}

    @field_validator("id", mode="before")
    @classmethod
    def _coerce_id(cls, value: object) -> str:
        return str(value)

    @field_validator("keywords", mode="before")
    @classmethod
    def _parse_keywords(cls, value: object) -> list[str]:
        if value is None:
            return []
        if isinstance(value, list):
            return value
        if isinstance(value, str):
            items = [item.strip() for item in value.split(",") if item.strip()]
            return items
        return []

class JournalUpdate(BaseModel):
    title: str | None = None
    content: str | None = None
    mood: JournalMoodType | None = None
    entry_date: datetime | None = None
    progress: int | None = None

class JournalStats(BaseModel):
    """Statistics for user's journal entries"""
    total_entries: int
    this_week: int
    this_month: int
    mood_breakdown: dict  # { "angry": 2, "sad": 1, "neutral": 3, "happy": 4, "excited": 1 }
    average_length: float
    last_entry_date: datetime | None = None


class JournalAnalysisRequest(BaseModel):
    text: str


class JournalAnalysisResponse(BaseModel):
    sentiment: str
    sentiment_score: float
    keywords: list[str]
