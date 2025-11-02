from fastapi import APIRouter, Depends, HTTPException, Header, Query, Request
from typing import List, Optional
from app.schemas.mood import MoodCreate, MoodRead
from app.models.mood_entry import MoodEntry
from app.models.user import User
from app.services import security
from app.services.analytics import record_event
from app.schemas.journal import JournalCreate, JournalRead, JournalUpdate
from app.schemas.symptom import SymptomCreate, SymptomRead, AnalyticsSummary
from app.models.journal_entry import JournalEntry
from app.models.symptom_entry import SymptomEntry
from collections import Counter
from datetime import datetime, timedelta, timezone
from sqlalchemy import func
from app.models.sleep_entry import SleepEntry
from app.limits import limiter, user_or_ip_rate_key

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

@limiter.limit("240/hour", key_func=user_or_ip_rate_key)
@router.get('/moods', response_model=List[MoodRead])
def list_moods(request: Request, page: int | None = None, limit: int | None = None, from_: str | None = Query(None, alias='from'), to: str | None = Query(None, alias='to'), user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        q = db.query(MoodEntry).filter(MoodEntry.user_id == user.id)
        # Date filtering
        try:
            if from_:
                from datetime import datetime, timezone as _tz
                start = datetime.fromisoformat(from_)
                if start.tzinfo is None:
                    start = start.replace(tzinfo=_tz.utc)
                q = q.filter(MoodEntry.created_at >= start)
            if to:
                from datetime import datetime, timezone as _tz
                end = datetime.fromisoformat(to)
                if end.tzinfo is None:
                    end = end.replace(tzinfo=_tz.utc)
                q = q.filter(MoodEntry.created_at <= end)
        except Exception:
            pass
        q = q.order_by(MoodEntry.created_at.desc())
        # Pagination
        if limit and limit > 0:
            p = max(1, page or 1)
            q = q.limit(limit).offset((p - 1) * limit)
        entries = q.all()
        # Coerce id to string in response model via Pydantic schema definition
        return entries
    finally:
        db.close()

@limiter.limit("60/hour", key_func=user_or_ip_rate_key)
@router.post('/moods', response_model=MoodRead)
def create_mood(request: Request, entry_in: MoodCreate, user: User = Depends(get_current_user)):
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


@limiter.limit("30/hour", key_func=user_or_ip_rate_key)
@router.post('/journals', response_model=JournalRead)
def create_journal(request: Request, payload: JournalCreate, user: User = Depends(get_current_user)):
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
        # inject updated_at for Flutter client compatibility (no DB column; return created_at)
        try:
            setattr(j, 'updated_at', getattr(j, 'created_at', None))
        except Exception:
            pass
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


@limiter.limit("180/hour", key_func=user_or_ip_rate_key)
@router.get('/journals', response_model=list[JournalRead])
def list_journals(request: Request, date: str | None = None, start: str | None = None, end: str | None = None, user: User = Depends(get_current_user)):
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


@limiter.limit("60/hour", key_func=user_or_ip_rate_key)
@router.put('/journals/{journal_id}', response_model=JournalRead)
def update_journal(request: Request, journal_id: int, payload: JournalUpdate, user: User = Depends(get_current_user)):
    """Update an existing journal entry. Only the owner may update."""
    from app.main import SessionLocal
    from app.models.journal_entry import JournalEntry
    db = SessionLocal()
    try:
        j = db.query(JournalEntry).filter(JournalEntry.id == journal_id, JournalEntry.user_id == user.id).first()
        if not j:
            raise HTTPException(status_code=404, detail='Journal not found')

        # encrypt content similarly to create_journal
        from app.services.crypto import encrypt_text
        content_enc = encrypt_text(payload.content) if getattr(payload, 'content', None) else None
        encryption_key = None
        if content_enc is not None:
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
        if getattr(payload, 'title', None) is not None:
            j.title = payload.title
        if content_enc is not None:
            j.content = ciphertext
            j.encryption_key = encryption_key
        # handle entry_date and progress if provided
        try:
            if getattr(payload, 'entry_date', None):
                ed = payload.entry_date
                if isinstance(ed, str):
                    j.entry_date = datetime.fromisoformat(ed).date()
                elif hasattr(ed, 'date'):
                    j.entry_date = ed.date()
            else:
                j.entry_date = j.entry_date or None
        except Exception:
            pass
        if getattr(payload, 'progress', None) is not None:
            j.progress = payload.progress

        db.add(j)
        db.commit()
        db.refresh(j)

        # inject updated_at for Flutter client compatibility
        try:
            setattr(j, 'updated_at', datetime.now(timezone.utc))
        except Exception:
            pass

        # decrypt for response
        try:
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


@limiter.limit("30/hour", key_func=user_or_ip_rate_key)
@router.delete('/journals/{journal_id}')
def delete_journal(request: Request, journal_id: int, user: User = Depends(get_current_user)):
    """Delete a journal entry owned by the user."""
    from app.main import SessionLocal
    from app.models.journal_entry import JournalEntry
    db = SessionLocal()
    try:
        j = db.query(JournalEntry).filter(JournalEntry.id == journal_id, JournalEntry.user_id == user.id).first()
        if not j:
            raise HTTPException(status_code=404, detail='Journal not found')
        db.delete(j)
        db.commit()
        return {'message': 'ok'}
    finally:
        db.close()


@limiter.limit("60/hour", key_func=user_or_ip_rate_key)
@router.post('/symptoms', response_model=SymptomRead)
def create_symptom(request: Request, payload: SymptomCreate, user: User = Depends(get_current_user)):
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


@limiter.limit("180/hour", key_func=user_or_ip_rate_key)
@router.get('/symptoms', response_model=list[SymptomRead])
def list_symptoms(request: Request, user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        items = db.query(SymptomEntry).filter(SymptomEntry.user_id == user.id).order_by(SymptomEntry.created_at.desc()).all()
        return items
    finally:
        db.close()


@limiter.limit("120/hour", key_func=user_or_ip_rate_key)
@router.get('/moods/analytics', response_model=AnalyticsSummary)
def mood_analytics(request: Request, user: User = Depends(get_current_user)):
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


@limiter.limit("120/hour", key_func=user_or_ip_rate_key)
@router.get('/moods/analytics/daily')
def mood_analytics_daily(request: Request, start: str | None = None, end: str | None = None, user: User = Depends(get_current_user)):
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
        result = [{'day': r.day.isoformat() if hasattr(r.day, 'isoformat') else str(r.day), 'average': float(r.avg_score) if r.avg_score is not None else None, 'count': int(r.count)} for r in rows]
        return {'start': start_dt.isoformat(), 'end': end_dt.isoformat(), 'daily': result}
    finally:
        db.close()


@limiter.limit("120/hour", key_func=user_or_ip_rate_key)
@router.get('/journals/summary')
def journals_progress_summary(request: Request, start: str | None = None, end: str | None = None, user: User = Depends(get_current_user)):
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
        result = [{'day': r.day.isoformat() if hasattr(r.day, 'isoformat') else str(r.day), 'avg_progress': float(r.avg_progress) if r.avg_progress is not None else None, 'count': int(r.count)} for r in rows]
        return {'start': start_dt.isoformat(), 'end': end_dt.isoformat(), 'daily': result}
    finally:
        db.close()


@limiter.limit("120/hour", key_func=user_or_ip_rate_key)
@router.get('/sleep/metric')
def sleep_metric(request: Request, window: str | None = None, user: User = Depends(get_current_user)):
    """Return a simple sleep metric.

    Query parameter `window` controls which metric is returned:
      - omitted or 'last' (default): use the latest completed sleep entry
      - '7d' : compute the average sleep duration across the last 7 days (entries with sleep_end)

    Response includes percent (0-100) and hours (float). For multi-day windows, also returns count.
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        now = datetime.now(timezone.utc)
        # support simple window values
        if window and window.lower() in ('7d', '7', '7-day', 'week'):
            days = 7
        else:
            days = None

        if days is None:
            # Find the latest sleep entry with an end timestamp
            s = db.query(SleepEntry).filter(SleepEntry.user_id == user.id, SleepEntry.sleep_end != None).order_by(SleepEntry.sleep_end.desc()).first()
            if not s or not s.sleep_end or not s.sleep_start:
                return {'percent': None, 'hours': None}
            dur = s.sleep_end - s.sleep_start
            hours = dur.total_seconds() / 3600.0
            percent = int(min(100, round((hours / 8.0) * 100)))
            return {'percent': percent, 'hours': round(hours, 2), 'window': 'last', 'count': 1}
        else:
            start = now - timedelta(days=days)
            rows = db.query(SleepEntry).filter(SleepEntry.user_id == user.id, SleepEntry.sleep_end != None, SleepEntry.sleep_end >= start).all()
            valid = [r for r in rows if getattr(r, 'sleep_start', None) and getattr(r, 'sleep_end', None)]
            if not valid:
                return {'percent': None, 'hours': None, 'window': f'last_{days}_days', 'count': 0}
            total_seconds = 0.0
            for r in valid:
                dur = r.sleep_end - r.sleep_start
                total_seconds += max(0.0, dur.total_seconds())
            avg_hours = (total_seconds / len(valid)) / 3600.0
            percent = int(min(100, round((avg_hours / 8.0) * 100)))
            return {'percent': percent, 'hours': round(avg_hours, 2), 'window': f'last_{days}_days', 'count': len(valid)}
    finally:
        db.close()
