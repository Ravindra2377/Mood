from pydantic import BaseModel
from datetime import datetime

class AchievementRead(BaseModel):
    id: int
    user_id: int
    key: str
    points: int
    created_at: datetime

    model_config = {"from_attributes": True}
