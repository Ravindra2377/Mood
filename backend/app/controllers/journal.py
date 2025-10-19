from fastapi import APIRouter, Depends, HTTPException, Header, Query
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from sqlalchemy import func, and_
from app.schemas.journal import JournalCreate, JournalRead, JournalUpdate, JournalStats
from app.models.journal_entry import JournalEntry, JournalMood
from app.models.user import User
from app.services import security
from app.services.analytics import record_event

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

@router.get('/journal', response_model=List[JournalRead])
def list_journal_entries(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    from_date: Optional[str] = Query(None, alias='from'),
    to_date: Optional[str] = Query(None, alias='to'),
    mood: Optional[str] = Query(None),
    user: User = Depends(get_current_user)
):
    """
    Get user's journal entries with optional filtering by date range and mood
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        q = db.query(JournalEntry).filter(JournalEntry.user_id == user.id)
        
        # Date filtering
        try:
            if from_date:
                start = datetime.fromisoformat(from_date)
                if start.tzinfo is None:
                    start = start.replace(tzinfo=timezone.utc)
                q = q.filter(JournalEntry.created_at >= start)
            
            if to_date:
                end = datetime.fromisoformat(to_date)
                if end.tzinfo is None:
                    end = end.replace(tzinfo=timezone.utc)
                q = q.filter(JournalEntry.created_at <= end)
        except ValueError:
            raise HTTPException(status_code=400, detail='Invalid date format')
        
        # Mood filtering
        if mood:
            try:
                mood_enum = JournalMood(mood.lower())
                q = q.filter(JournalEntry.mood == mood_enum)
            except ValueError:
                raise HTTPException(status_code=400, detail='Invalid mood value')
        
        # Sort by latest first
        q = q.order_by(JournalEntry.created_at.desc())
        
        # Pagination
        total = q.count()
        offset = (page - 1) * limit
        entries = q.offset(offset).limit(limit).all()
        
        return entries
    finally:
        db.close()

@router.post('/journal', response_model=JournalRead)
def create_journal_entry(
    entry: JournalCreate,
    user: User = Depends(get_current_user)
):
    """
    Create a new journal entry with mood tracking
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        # Calculate character count
        char_count = len(entry.content) if entry.content else 0
        
        journal_entry = JournalEntry(
            user_id=user.id,
            title=entry.title,
            content=entry.content,
            mood=JournalMood(entry.mood.lower()) if entry.mood else JournalMood.NEUTRAL,
            character_count=char_count,
            entry_date=entry.entry_date,
            progress=entry.progress
        )
        
        db.add(journal_entry)
        db.commit()
        db.refresh(journal_entry)
        
        # Record analytics event
        record_event(user.id, 'journal_entry_created', {
            'mood': entry.mood,
            'character_count': char_count
        })
        
        return journal_entry
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@router.get('/journal/{entry_id}', response_model=JournalRead)
def get_journal_entry(
    entry_id: int,
    user: User = Depends(get_current_user)
):
    """
    Get a specific journal entry
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        entry = db.query(JournalEntry).filter(
            and_(
                JournalEntry.id == entry_id,
                JournalEntry.user_id == user.id
            )
        ).first()
        
        if not entry:
            raise HTTPException(status_code=404, detail='Journal entry not found')
        
        return entry
    finally:
        db.close()

@router.put('/journal/{entry_id}', response_model=JournalRead)
def update_journal_entry(
    entry_id: int,
    update_data: JournalUpdate,
    user: User = Depends(get_current_user)
):
    """
    Update a journal entry
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        entry = db.query(JournalEntry).filter(
            and_(
                JournalEntry.id == entry_id,
                JournalEntry.user_id == user.id
            )
        ).first()
        
        if not entry:
            raise HTTPException(status_code=404, detail='Journal entry not found')
        
        # Update fields
        if update_data.title is not None:
            entry.title = update_data.title
        if update_data.content is not None:
            entry.content = update_data.content
            entry.character_count = len(update_data.content)
        if update_data.mood is not None:
            entry.mood = JournalMood(update_data.mood.lower())
        if update_data.entry_date is not None:
            entry.entry_date = update_data.entry_date
        if update_data.progress is not None:
            entry.progress = update_data.progress
        
        db.commit()
        db.refresh(entry)
        
        record_event(user.id, 'journal_entry_updated', {
            'entry_id': entry_id,
            'mood': entry.mood.value
        })
        
        return entry
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@router.delete('/journal/{entry_id}')
def delete_journal_entry(
    entry_id: int,
    user: User = Depends(get_current_user)
):
    """
    Delete a journal entry
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        entry = db.query(JournalEntry).filter(
            and_(
                JournalEntry.id == entry_id,
                JournalEntry.user_id == user.id
            )
        ).first()
        
        if not entry:
            raise HTTPException(status_code=404, detail='Journal entry not found')
        
        db.delete(entry)
        db.commit()
        
        record_event(user.id, 'journal_entry_deleted', {'entry_id': entry_id})
        
        return {'message': 'Journal entry deleted successfully'}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@router.get('/journal/stats/summary', response_model=JournalStats)
def get_journal_stats(
    user: User = Depends(get_current_user)
):
    """
    Get journal statistics for the user
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        all_entries = db.query(JournalEntry).filter(JournalEntry.user_id == user.id)
        total_entries = all_entries.count()
        
        # This week
        week_ago = datetime.now(timezone.utc) - timedelta(days=7)
        this_week = all_entries.filter(JournalEntry.created_at >= week_ago).count()
        
        # This month
        month_ago = datetime.now(timezone.utc) - timedelta(days=30)
        this_month = all_entries.filter(JournalEntry.created_at >= month_ago).count()
        
        # Mood breakdown
        mood_counts = db.query(JournalEntry.mood, func.count(JournalEntry.id)).filter(
            JournalEntry.user_id == user.id
        ).group_by(JournalEntry.mood).all()
        
        mood_breakdown = {mood.value: count for mood, count in mood_counts}
        
        # Average length
        avg_length = db.query(func.avg(JournalEntry.character_count)).filter(
            JournalEntry.user_id == user.id
        ).scalar() or 0
        
        # Last entry date
        last_entry = all_entries.order_by(JournalEntry.created_at.desc()).first()
        last_entry_date = last_entry.created_at if last_entry else None
        
        return JournalStats(
            total_entries=total_entries,
            this_week=this_week,
            this_month=this_month,
            mood_breakdown=mood_breakdown,
            average_length=float(avg_length),
            last_entry_date=last_entry_date
        )
    finally:
        db.close()
