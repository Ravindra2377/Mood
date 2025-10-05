from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class TimerCreate(BaseModel):
    label: Optional[str] = None
    target_at: datetime


class TimerRead(BaseModel):
    id: int
    user_id: int
    label: Optional[str]
    target_at: datetime
    created_at: datetime
    fired_at: Optional[datetime]

    class Config:
        orm_mode = True
