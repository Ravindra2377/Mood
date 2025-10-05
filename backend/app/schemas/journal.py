from pydantic import BaseModel
from datetime import datetime

class JournalCreate(BaseModel):
    title: str | None = None
    content: str
    entry_date: datetime | None = None
    progress: int | None = None

class JournalRead(BaseModel):
    id: int
    user_id: int
    title: str | None
    content: str
    created_at: datetime
    entry_date: datetime | None
    progress: int | None

    model_config = {"from_attributes": True}
