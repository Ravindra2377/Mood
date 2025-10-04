from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class AchievementRead(BaseModel):
    id: int
    user_id: int
    key: str
    points: int
    created_at: datetime

    model_config = {"from_attributes": True}


class AchievementCreate(BaseModel):
    key: str
    points: int | None = 0

    model_config = {"from_attributes": True}


class StreakRead(BaseModel):
    id: int
    user_id: int
    current_streak: int
    best_streak: int
    last_active_at: Optional[datetime]

    model_config = {"from_attributes": True}


class RewardRead(BaseModel):
    id: int
    key: str
    title: str
    description: Optional[str]
    cost_points: int

    model_config = {"from_attributes": True}


class RewardCreate(BaseModel):
    key: str
    title: str
    description: Optional[str] = None
    cost_points: int = 0

    model_config = {"from_attributes": True}


class ClaimedRewardRead(BaseModel):
    id: int
    user_id: int
    reward_id: int
    meta: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
