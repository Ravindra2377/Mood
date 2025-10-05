from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.stopwatch import StopwatchCreate, StopwatchRead
from app.schemas.timer import TimerCreate, TimerRead

router = APIRouter()


@router.post('/stopwatches', response_model=StopwatchRead)
def start_stopwatch(payload: StopwatchCreate, user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.stopwatch import Stopwatch
    db = SessionLocal()
    try:
        s = Stopwatch(user_id=user.id, label=payload.label)
        db.add(s)
        db.commit()
        db.refresh(s)
        return s
    finally:
        db.close()


@router.post('/stopwatches/{stopwatch_id}/stop', response_model=StopwatchRead)
def stop_stopwatch(stopwatch_id: int, user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.stopwatch import Stopwatch
    db = SessionLocal()
    try:
        s = db.query(Stopwatch).filter(Stopwatch.id == stopwatch_id, Stopwatch.user_id == user.id).first()
        if not s:
            raise HTTPException(status_code=404, detail='Stopwatch not found')
        if s.stopped_at is None:
            from datetime import datetime, timezone
            s.stopped_at = datetime.now(timezone.utc)
            db.commit()
            db.refresh(s)
        return s
    finally:
        db.close()


@router.get('/stopwatches', response_model=List[StopwatchRead])
def list_stopwatches(user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.stopwatch import Stopwatch
    db = SessionLocal()
    try:
        items = db.query(Stopwatch).filter(Stopwatch.user_id == user.id).order_by(Stopwatch.started_at.desc()).all()
        return items
    finally:
        db.close()


@router.post('/timers', response_model=TimerRead)
def create_timer(payload: TimerCreate, user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.timer import Timer
    db = SessionLocal()
    try:
        t = Timer(user_id=user.id, label=payload.label, target_at=payload.target_at)
        db.add(t)
        db.commit()
        db.refresh(t)
        return t
    finally:
        db.close()


@router.get('/timers', response_model=List[TimerRead])
def list_timers(user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.timer import Timer
    db = SessionLocal()
    try:
        items = db.query(Timer).filter(Timer.user_id == user.id).order_by(Timer.created_at.desc()).all()
        return items
    finally:
        db.close()
