from fastapi import APIRouter, Depends, HTTPException, Request
from typing import List
from app.dependencies import get_current_user
from app.models.crisis import CrisisAlert
from app.models.mood_entry import MoodEntry
from app.models.user import User
from app.schemas.crisis import CrisisAlertCreate, CrisisAlertRead, CrisisResource as CrisisResourceSchema
from app.config import settings
from app.services.detector import predict_severity
from app.services.i18n import t_format
from app.dependencies import get_current_user_optional
from app.services.notifications import escalate_alert_email, push_alert_stub
from app.services.analytics import record_event

router = APIRouter()


# Minimal keyword-based crisis detector for demonstration. In production, replace with
# a more robust classifier (ML model, third-party service, or richer rules).
CRISIS_KEYWORDS = {
    'suicide': 'high',
    'kill myself': 'high',
    'i want to die': 'high',
    'die by suicide': 'high',
    'hurt myself': 'high',
    'self-harm': 'high',
    'panic attack': 'medium',
    'depressed': 'medium',
    'hopeless': 'medium',
}


import json
from pathlib import Path

# load resources from JSON data file
_res_path = Path(__file__).parent.parent / 'data' / 'crisis_resources.json'
try:
    RESOURCES = json.loads(_res_path.read_text(encoding='utf-8'))
except Exception:
    RESOURCES = []


def detect_crisis_in_text(text: str):
    t = (text or '').lower()
    for k, severity in CRISIS_KEYWORDS.items():
        if k in t:
            return severity, k
    return None, None


def _determine_locale(request: Request | None, current_user=None) -> str:
    """Determine preferred locale: profile.language > Accept-Language header > default 'en'."""
    # try user profile if available
    if current_user:
        try:
            from app.main import SessionLocal
            from app.models.profile import Profile
            db = SessionLocal()
            try:
                p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
                if p and getattr(p, 'language', None):
                    return p.language
            finally:
                db.close()
        except Exception:
            # swallow DB/profile errors and fallback to header
            pass

    if request is not None:
        al = request.headers.get('accept-language')
        if al:
            # pick the first language tag
            tag = al.split(',')[0].strip().lower()
            # normalize to basic two-letter locale
            if tag.startswith('es'):
                return 'es'
            if tag.startswith('en'):
                return 'en'
            # fallback to primary subtag
            if '-' in tag:
                return tag.split('-')[0]
            return tag

    return 'en'


@router.post('/detect', response_model=CrisisAlertRead)
def detect_and_record(payload: CrisisAlertCreate, current_user=Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        # simple recording of alert triggered by client (or internal detector)
        ca = CrisisAlert(user_id=current_user.id, source=payload.source, severity=payload.severity, details=payload.details)
        db.add(ca)
        db.commit()
        db.refresh(ca)
        return ca
    finally:
        db.close()


@router.post('/analyze_text')
def analyze_text_for_crisis(text: str, request: Request, current_user=Depends(get_current_user)):
    # run detector and optionally create an alert
    # try model-based detector first
    severity = None
    matched = None
    model_sev = predict_severity(text)
    if model_sev:
        severity = model_sev
    else:
        severity, matched = detect_crisis_in_text(text)
    if severity:
        from app.main import SessionLocal
        db = SessionLocal()
        try:
            ca = CrisisAlert(user_id=current_user.id, source='chat', severity=severity, details=f"matched:{matched}; excerpt:{text[:200]}")
            db.add(ca)
            db.commit()
            db.refresh(ca)
            try:
                record_event('crisis.detected', user_id=current_user.id, props={'severity': severity, 'match': matched})
            except Exception:
                pass
            # escalate if high severity
            if severity == 'high':
                # determine locale for user/request
                locale = _determine_locale(request, current_user)
                # localized subject and bodies
                subject = t_format('crisis_alert_subject', locale, user_id=current_user.id)
                html_body = t_format('crisis_alert_html', locale, severity=severity, match=matched, excerpt=text[:500], user_id=current_user.id)
                text_body = t_format('crisis_alert_text', locale, severity=severity, match=matched, excerpt=text[:500], user_id=current_user.id)
                escalate_alert_email(subject, html_body, text_body=text_body)
                # push stub (localized short message)
                push_msg = t_format('crisis_push_short', locale, severity=severity)
                push_alert_stub(current_user.id, push_msg)
            return {'alerted': True, 'severity': severity, 'match': matched}
        finally:
            db.close()
    return {'alerted': False}


@router.get('/alerts', response_model=List[CrisisAlertRead])
def list_unresolved_alerts(current_user=Depends(get_current_user)):
    # Only allow admin access to the moderation list
    if getattr(current_user, 'role', 'user') != 'admin':
        raise HTTPException(status_code=403, detail='Not authorized')
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        rows = db.query(CrisisAlert).filter(CrisisAlert.resolved == False).order_by(CrisisAlert.created_at.desc()).all()
        return rows
    finally:
        db.close()


@router.post('/alerts/{alert_id}/resolve')
def resolve_alert(alert_id: int, current_user=Depends(get_current_user)):
    # Only admin can mark resolved
    if getattr(current_user, 'role', 'user') != 'admin':
        raise HTTPException(status_code=403, detail='Not authorized')
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        a = db.query(CrisisAlert).filter(CrisisAlert.id == alert_id).first()
        if not a:
            raise HTTPException(status_code=404, detail='Alert not found')
        a.resolved = True
        db.add(a)
        db.commit()
        # record audit
        from app.models.crisis import CrisisAudit
        audit = CrisisAudit(alert_id=a.id, actor_user_id=current_user.id, action='resolved', note=None)
        db.add(audit)
        db.commit()
        return {'resolved': True}
    finally:
        db.close()


@router.get('/dashboard/alerts', response_model=List[CrisisAlertRead])
def dashboard_alerts(skip: int = 0, limit: int = 50, severity: str | None = None, resolved: bool | None = None, current_user=Depends(get_current_user)):
    # Admin-only dashboard
    if getattr(current_user, 'role', 'user') != 'admin':
        raise HTTPException(status_code=403, detail='Not authorized')
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        q = db.query(CrisisAlert)
        if severity:
            q = q.filter(CrisisAlert.severity == severity)
        if resolved is not None:
            q = q.filter(CrisisAlert.resolved == resolved)
        rows = q.order_by(CrisisAlert.created_at.desc()).offset(skip).limit(limit).all()
        return rows
    finally:
        db.close()


@router.get('/resources', response_model=List[CrisisResourceSchema])
def list_resources(country: str | None = None, current_user=Depends(get_current_user_optional)):
    # country param, or infer from profile if available
    target = country
    if not target and current_user:
        # try to infer from profile
        from app.main import SessionLocal
        from app.models.profile import Profile
        db = SessionLocal()
        try:
            p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
            if p and getattr(p, 'country', None):
                target = p.country
        finally:
            db.close()

    if target:
        return [r for r in RESOURCES if r.get('country') == target]
    return RESOURCES
