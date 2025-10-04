from fastapi import APIRouter, HTTPException, Depends
from app.schemas.gamification import AchievementRead
from app.dependencies import get_current_user

router = APIRouter()

@router.get('/achievements', response_model=list[AchievementRead])
def list_achievements(user_id: int = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.gamification import Achievement
    db = SessionLocal()
    try:
        items = db.query(Achievement).filter(Achievement.user_id == user_id).all()
        return items
    finally:
        db.close()

@router.post('/achievements', response_model=AchievementRead)
def create_achievement(key: str, points: int = 0, user_id: int = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.gamification import Achievement
    db = SessionLocal()
    try:
        a = Achievement(user_id=user_id, key=key, points=points)
        db.add(a)
        db.commit()
        db.refresh(a)
        return a
    finally:
        db.close()
