from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class CrisisAlertCreate(BaseModel):
    source: str
    severity: str
    details: Optional[str] = None


class CrisisAlertRead(BaseModel):
    id: int
    user_id: int
    source: str
    severity: str
    details: Optional[str]
    resolved: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class CrisisResource(BaseModel):
    country: str
    hotline: str
    url: Optional[str] = None

    model_config = {"from_attributes": True}
