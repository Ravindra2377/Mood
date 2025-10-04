from pydantic import BaseModel
from datetime import datetime

class JournalCreate(BaseModel):
    title: str | None = None
    content: str

class JournalRead(BaseModel):
    id: int
    user_id: int
    title: str | None
    content: str
    created_at: datetime

    model_config = {"from_attributes": True}
