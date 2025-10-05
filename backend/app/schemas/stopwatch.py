from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class StopwatchCreate(BaseModel):
    label: Optional[str] = None


class StopwatchRead(BaseModel):
    id: int
    user_id: int
    label: Optional[str]
    started_at: datetime
    stopped_at: Optional[datetime]

    class Config:
        orm_mode = True
