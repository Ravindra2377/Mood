from fastapi import APIRouter, Depends, HTTPException, Header
from typing import List, Optional
from app.schemas.mood import MoodCreate, MoodRead
from app.models.mood_entry import MoodEntry
from app.models.user import User
from app.services import security
from app.services.analytics import record_event
from app.schemas.journal import JournalCreate, JournalRead
from app.schemas.symptom import SymptomCreate, SymptomRead, AnalyticsSummary
from app.models.journal_entry import JournalEntry
from app.models.symptom_entry import SymptomEntry
from collections import Counter
from datetime import datetime, timedelta, timezone
from sqlalchemy import func

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
        try:
            record_event('mood.create', user_id=user.id, props={'score': entry.score})
        except Exception:
            pass
        return entry
    finally:
        db.close()


@router.post('/journals', response_model=JournalRead)
def create_journal(payload: JournalCreate, user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        from app.services.crypto import encrypt_text
        content_enc = encrypt_text(payload.content) if payload.content else ''
        # if envelope format (JSON with ct and ek), store ek separately
        encryption_key = None
        try:
            import json
            doc = json.loads(content_enc)
            if isinstance(doc, dict) and 'ct' in doc and 'ek' in doc:
                ciphertext = doc['ct']
                encryption_key = doc['ek']
            else:
                ciphertext = content_enc
        except Exception:
            ciphertext = content_enc

        # Normalize entry_date: allow payload.entry_date ISO string or None
        entry_date_val = None
        try:
            if getattr(payload, 'entry_date', None):
                # payload.entry_date may be a datetime; convert to date
                ed = payload.entry_date
                if isinstance(ed, str):
                    from datetime import date
                    entry_date_val = datetime.fromisoformat(ed).date()
                elif hasattr(ed, 'date'):
                    entry_date_val = ed.date()
                else:
                    entry_date_val = ed
        except Exception:
            entry_date_val = None

        j = JournalEntry(user_id=user.id, title=payload.title, content=ciphertext, encryption_key=encryption_key, entry_date=entry_date_val, progress=getattr(payload, 'progress', None))
        db.add(j)
        db.commit()
        db.refresh(j)
        # decrypt for response
        try:
            # if stored with envelope encryption, use envelope decrypt
            if getattr(j, 'encryption_key', None):
                from app.services.envelope_crypto import decrypt_from_kms
                j.content = decrypt_from_kms(j.content, j.encryption_key)
            else:
                from app.services.crypto import decrypt_text
                j.content = decrypt_text(j.content) if j.content else j.content
        except Exception:
            pass
        return j
    finally:
        db.close()


@router.get('/journals', response_model=list[JournalRead])
def list_journals(date: str | None = None, start: str | None = None, end: str | None = None, user: User = Depends(get_current_user)):
    """List journals for the current user.
    Optional query parameters:
      - date: YYYY-MM-DD to return entries for a specific day
      - start, end: ISO datetimes to return entries in a date range
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        q = db.query(JournalEntry).filter(JournalEntry.user_id == user.id)
        # filter by logical entry_date if provided
        try:
            if date:
                d = datetime.fromisoformat(date).date()
                q = q.filter(JournalEntry.entry_date == d)
            else:
                if start:
                    s_dt = datetime.fromisoformat(start)
                    if s_dt.tzinfo is None:
                        s_dt = s_dt.replace(tzinfo=timezone.utc)
                    q = q.filter(JournalEntry.created_at >= s_dt)
                if end:
                    e_dt = datetime.fromisoformat(end)
                    if e_dt.tzinfo is None:
                        e_dt = e_dt.replace(tzinfo=timezone.utc)
                    q = q.filter(JournalEntry.created_at <= e_dt)
        except Exception:
            # ignore parse errors and return unfiltered list
            pass

        items = q.order_by(JournalEntry.created_at.desc()).all()
        # decrypt before returning
        try:
            for it in items:
                if getattr(it, 'content', None):
                    if getattr(it, 'encryption_key', None):
                        from app.services.envelope_crypto import decrypt_from_kms
                        it.content = decrypt_from_kms(it.content, it.encryption_key)
                    else:
                        from app.services.crypto import decrypt_text
                        it.content = decrypt_text(it.content)
        except Exception:
            pass
        return items
    finally:
        db.close()


@router.post('/symptoms', response_model=SymptomRead)
def create_symptom(payload: SymptomCreate, user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        s = SymptomEntry(user_id=user.id, symptom=payload.symptom, severity=payload.severity, note=payload.note)
        db.add(s)
        db.commit()
        db.refresh(s)
        return s
    finally:
        db.close()


@router.get('/symptoms', response_model=list[SymptomRead])
def list_symptoms(user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        items = db.query(SymptomEntry).filter(SymptomEntry.user_id == user.id).order_by(SymptomEntry.created_at.desc()).all()
        return items
    finally:
        db.close()


@router.get('/moods/analytics', response_model=AnalyticsSummary)
def mood_analytics(user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        moods = db.query(MoodEntry).filter(MoodEntry.user_id == user.id).all()
        if moods:
            avg = sum(m.score for m in moods) / len(moods)
        else:
            avg = None
        count = len(moods)
        symptoms = db.query(SymptomEntry).filter(SymptomEntry.user_id == user.id).all()
        most_common = [s for s, _ in Counter([sym.symptom for sym in symptoms]).most_common(3)] if symptoms else []
        return AnalyticsSummary(average_mood=avg, entries_count=count, most_common_symptoms=most_common)
    finally:
        db.close()


@router.get('/moods/analytics/daily')
def mood_analytics_daily(start: str | None = None, end: str | None = None, user: User = Depends(get_current_user)):
    """Return daily mood averages and counts between start and end (ISO dates). Defaults to last 30 days."""
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        if end:
            end_dt = datetime.fromisoformat(end)
            # if naive, assume UTC
            if end_dt.tzinfo is None:
                end_dt = end_dt.replace(tzinfo=timezone.utc)
        else:
            end_dt = datetime.now(timezone.utc)
        if start:
            start_dt = datetime.fromisoformat(start)
            if start_dt.tzinfo is None:
                start_dt = start_dt.replace(tzinfo=timezone.utc)
        else:
            start_dt = end_dt - timedelta(days=30)

        q = db.query(func.date(MoodEntry.created_at).label('day'), func.avg(MoodEntry.score).label('avg_score'), func.count(MoodEntry.id).label('count'))
        q = q.filter(MoodEntry.user_id == user.id, MoodEntry.created_at >= start_dt, MoodEntry.created_at <= end_dt)
        q = q.group_by(func.date(MoodEntry.created_at)).order_by(func.date(MoodEntry.created_at).asc())
        rows = q.all()
        result = [{'day': r.day.isoformat(), 'average': float(r.avg_score) if r.avg_score is not None else None, 'count': int(r.count)} for r in rows]
        return {'start': start_dt.isoformat(), 'end': end_dt.isoformat(), 'daily': result}
    finally:
        db.close()


@router.get('/journals/summary')
def journals_progress_summary(start: str | None = None, end: str | None = None, user: User = Depends(get_current_user)):
    """Return daily progress summary for journals between start and end dates.
    Returns list of {day: YYYY-MM-DD, avg_progress: float, count: int}
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        if end:
            end_dt = datetime.fromisoformat(end)
            if end_dt.tzinfo is None:
                end_dt = end_dt.replace(tzinfo=timezone.utc)
        else:
            end_dt = datetime.now(timezone.utc)
        if start:
            start_dt = datetime.fromisoformat(start)
            if start_dt.tzinfo is None:
                start_dt = start_dt.replace(tzinfo=timezone.utc)
        else:
            start_dt = end_dt - timedelta(days=30)

        q = db.query(func.date(JournalEntry.entry_date).label('day'), func.avg(JournalEntry.progress).label('avg_progress'), func.count(JournalEntry.id).label('count'))
        q = q.filter(JournalEntry.user_id == user.id, JournalEntry.entry_date != None, JournalEntry.entry_date >= start_dt.date(), JournalEntry.entry_date <= end_dt.date())
        q = q.group_by(func.date(JournalEntry.entry_date)).order_by(func.date(JournalEntry.entry_date).asc())
        rows = q.all()
        result = [{'day': r.day.isoformat(), 'avg_progress': float(r.avg_progress) if r.avg_progress is not None else None, 'count': int(r.count)} for r in rows]
        return {'start': start_dt.isoformat(), 'end': end_dt.isoformat(), 'daily': result}
    finally:
        db.close()
