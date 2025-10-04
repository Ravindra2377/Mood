from fastapi import APIRouter, Depends, HTTPException, Header
from typing import List, Optional
from app.schemas.mood import MoodCreate, MoodRead
from app.models.mood_entry import MoodEntry
from app.models.user import User
from app.services import security

router = APIRouter()

def get_current_user(authorization: Optional[str] = Header(None)) -> User:
    if not authorization:
        raise HTTPException(status_code=401, detail='Missing authorization header')
    try:
        scheme, token = authorization.split()
    except Exception:
        raise HTTPException(status_code=401, detail='Invalid authorization header')
    payload = security.decode_access_token(token)
    if not payload or 'sub' not in payload:
        raise HTTPException(status_code=401, detail='Invalid token')
    user_id = int(payload['sub'])
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        user = db.query(User).get(user_id)
        if not user:
            raise HTTPException(status_code=401, detail='User not found')
        return user
    finally:
        db.close()

@router.get('/moods', response_model=List[MoodRead])
def list_moods(user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        entries = db.query(MoodEntry).filter(MoodEntry.user_id == user.id).order_by(MoodEntry.created_at.desc()).all()
        return entries
    finally:
        db.close()

@router.post('/moods', response_model=MoodRead)
def create_mood(entry_in: MoodCreate, user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        entry = MoodEntry(user_id=user.id, score=entry_in.score, note=entry_in.note)
        db.add(entry)
        db.commit()
        db.refresh(entry)
        return entry
    finally:
        db.close()
