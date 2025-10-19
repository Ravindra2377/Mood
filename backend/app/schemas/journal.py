from pydantic import BaseModel
from datetime import datetime

class JournalCreate(BaseModel):
    title: str | None = None
    content: str
    entry_date: datetime | None = None
    progress: int | None = None

class JournalRead(BaseModel):
    id: str  # expose as string for Flutter client
    user_id: int
    title: str | None
    content: str
    created_at: datetime
    updated_at: datetime | None = None
    entry_date: datetime | None
    progress: int | None

    model_config = {"from_attributes": True}

class JournalUpdate(BaseModel):
    title: str | None = None
    content: str | None = None
    entry_date: datetime | None = None
    progress: int | None = None
