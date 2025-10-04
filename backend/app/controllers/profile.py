from fastapi import APIRouter, HTTPException, Depends, Response
from app.schemas.profile import ProfileRead, ProfileUpdate
from app.models.profile import Profile
from app.models.consent_audit import ConsentAudit
from fastapi import Request
from app.dependencies import get_current_user

router = APIRouter()


@router.get('/profile', response_model=ProfileRead)
def read_profile(current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from datetime import datetime, timezone, timedelta
    from app.models.gamification import Streak, Achievement, PointsLedger
    db = SessionLocal()
    try:
        user_id = current_user.id
        p = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not p:
            # return empty profile object created on demand
            p = Profile(user_id=user_id)
            db.add(p)
            db.commit()
            db.refresh(p)
        # compute engagement_status based on recent activity
        now = datetime.now(timezone.utc)
        last_dates = []
        s = db.query(Streak).filter(Streak.user_id == user_id).first()
        if s and s.last_active_at:
            last_dates.append(s.last_active_at)
        a = db.query(Achievement).filter(Achievement.user_id == user_id).order_by(Achievement.created_at.desc()).first()
        if a and a.created_at:
            last_dates.append(a.created_at)
        pl = db.query(PointsLedger).filter(PointsLedger.user_id == user_id).order_by(PointsLedger.created_at.desc()).first()
        if pl and pl.created_at:
            last_dates.append(pl.created_at)

        last_activity = max(last_dates) if last_dates else None
        new_status = 'inactive'
        if last_activity:
            delta = now - last_activity
            if delta <= timedelta(days=7):
                new_status = 'active'
            elif delta <= timedelta(days=30):
                new_status = 'at_risk'
            else:
                new_status = 'inactive'

        if getattr(p, 'engagement_status', None) != new_status:
            p.engagement_status = new_status
            db.add(p)
            db.commit()
            db.refresh(p)

        return p
    finally:
        db.close()


@router.patch('/profile', response_model=ProfileRead)
def update_profile(payload: ProfileUpdate, request: Request, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        user_id = current_user.id
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
        # track consent changes and record audits
        if payload.consent_privacy is not None:
            old = p.consent_privacy
            if old != payload.consent_privacy:
                audit = ConsentAudit(user_id=current_user.id, field='consent_privacy', old_value=str(old), new_value=str(payload.consent_privacy), source_ip=request.client.host if request.client else None, source_ua=request.headers.get('user-agent'))
                db.add(audit)
            p.consent_privacy = payload.consent_privacy
        if payload.notify_email is not None:
            old_n = getattr(p, 'notify_email', None)
            if old_n != payload.notify_email:
                audit = ConsentAudit(user_id=user_id, field='notify_email', old_value=str(old_n), new_value=str(payload.notify_email), source_ip=request.client.host if request.client else None, source_ua=request.headers.get('user-agent'))
                db.add(audit)
            p.notify_email = payload.notify_email
        if payload.notify_push is not None:
            old_n = getattr(p, 'notify_push', None)
            if old_n != payload.notify_push:
                audit = ConsentAudit(user_id=user_id, field='notify_push', old_value=str(old_n), new_value=str(payload.notify_push), source_ip=request.client.host if request.client else None, source_ua=request.headers.get('user-agent'))
                db.add(audit)
            p.notify_push = payload.notify_push
        if payload.notify_sms is not None:
            old_n = getattr(p, 'notify_sms', None)
            if old_n != payload.notify_sms:
                audit = ConsentAudit(user_id=user_id, field='notify_sms', old_value=str(old_n), new_value=str(payload.notify_sms), source_ip=request.client.host if request.client else None, source_ua=request.headers.get('user-agent'))
                db.add(audit)
            p.notify_sms = payload.notify_sms
        db.commit()
        db.refresh(p)
        return p
    finally:
        db.close()


@router.get('/profile/audits')
def list_profile_audits(current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        user_id = current_user.id
        audits = db.query(ConsentAudit).filter(ConsentAudit.user_id == user_id).order_by(ConsentAudit.changed_at.desc()).all()
        return [
            {
                'id': a.id,
                'field': a.field,
                'old_value': a.old_value,
                'new_value': a.new_value,
                'changed_at': a.changed_at.isoformat() if a.changed_at else None,
                    'source_ip': a.source_ip,
                    'source_ua': a.source_ua,
            }
            for a in audits
        ]
    finally:
        db.close()


@router.get('/profile/audits/export')
def export_profile_audits(format: str = 'json', current_user = Depends(get_current_user)):
    """Export consent audit history for the current user as JSON or CSV.

    Query param `format` may be 'json' (default) or 'csv'.
    """
    from app.main import SessionLocal
    import io, csv
    db = SessionLocal()
    try:
        user_id = current_user.id
        audits = db.query(ConsentAudit).filter(ConsentAudit.user_id == user_id).order_by(ConsentAudit.changed_at.desc()).all()
        rows = [
            {
                'id': a.id,
                'field': a.field,
                'old_value': a.old_value,
                'new_value': a.new_value,
                'changed_at': a.changed_at.isoformat() if a.changed_at else None,
                'source_ip': a.source_ip,
                'source_ua': a.source_ua,
            }
            for a in audits
        ]
        if format.lower() == 'csv':
            output = io.StringIO()
            writer = csv.writer(output)
            writer.writerow(['id','field','old_value','new_value','changed_at','source_ip','source_ua'])
            for r in rows:
                writer.writerow([r['id'], r['field'], r['old_value'], r['new_value'], r['changed_at'], r['source_ip'], r['source_ua']])
            csv_text = output.getvalue()
            return Response(content=csv_text, media_type='text/csv', headers={'Content-Disposition': 'attachment; filename="consent_audits.csv"'})
        return rows
    finally:
        db.close()