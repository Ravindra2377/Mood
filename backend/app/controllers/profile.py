from fastapi import APIRouter, HTTPException, Depends
from app.schemas.profile import ProfileRead, ProfileUpdate
from app.models.profile import Profile
from app.dependencies import get_current_user

router = APIRouter()


@router.get('/profile', response_model=ProfileRead)
def read_profile(user_id: int = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        p = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not p:
            # return empty profile object created on demand
            p = Profile(user_id=user_id)
            db.add(p)
            db.commit()
            db.refresh(p)
        return p
    finally:
        db.close()


@router.patch('/profile', response_model=ProfileRead)
def update_profile(payload: ProfileUpdate, user_id: int = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        p = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not p:
            p = Profile(user_id=user_id)
            db.add(p)
        if payload.display_name is not None:
            p.display_name = payload.display_name
        if payload.language is not None:
            p.language = payload.language
        if payload.timezone is not None:
            p.timezone = payload.timezone
        if payload.consent_privacy is not None:
            p.consent_privacy = payload.consent_privacy
        db.commit()
        db.refresh(p)
        return p
    finally:
        db.close()