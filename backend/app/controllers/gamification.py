from fastapi import APIRouter, HTTPException
from app.schemas.gamification import AchievementRead

router = APIRouter()

@router.get('/achievements', response_model=list[AchievementRead])
def list_achievements():
    # placeholder - return empty list for now
    return []
