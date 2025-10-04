from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ProfileRead(BaseModel):
    id: int
    user_id: int
    display_name: Optional[str]
    language: str
    timezone: Optional[str]
    consent_privacy: bool
    created_at: datetime

    model_config = {"from_attributes": True}

class ProfileUpdate(BaseModel):
    display_name: Optional[str]
    language: Optional[str]
    timezone: Optional[str]
    consent_privacy: Optional[bool]
