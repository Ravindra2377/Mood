from fastapi import APIRouter, Depends, HTTPException
from app.schemas.personalization import EngagementEventIn, RecommendationOut
from app.services.personalization import record_event, generate_recommendations
from app.dependencies import get_current_user
from app.models.user import User
from sqlalchemy.orm import Session
from app.services.scheduler import schedule_for_profile, due_notifications
from app.models.profile import Profile

router = APIRouter()


@router.post('/personalization/event')
def post_event(payload: EngagementEventIn, current_user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db: Session = SessionLocal()
    try:
        ev = record_event(db, current_user, payload.event_type, payload.metadata)
        return {'status': 'ok', 'event_id': ev.id}
    finally:
        db.close()


@router.get('/personalization/recommendations', response_model=list[RecommendationOut])
def get_recommendations(current_user: User = Depends(get_current_user)):
    from app.main import SessionLocal
    db: Session = SessionLocal()
    try:
        recs = generate_recommendations(db, current_user)
        return recs
    finally:
        db.close()



@router.post('/personalization/schedule/compute')
def compute_schedule(current_user: User = Depends(get_current_user)):
    """Compute and persist next_notification_at for the current user."""
    from app.main import SessionLocal
    db: Session = SessionLocal()
    try:
        profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
        if not profile:
            # create default profile if missing
            profile = Profile(user_id=current_user.id)
            db.add(profile)
            db.commit()
            db.refresh(profile)
        profile = schedule_for_profile(db, profile)
        return {"status": "ok", "next_notification_at": profile.next_notification_at}
    finally:
        db.close()


@router.get('/personalization/schedule/due')
def list_due_notifications():
    """List profiles with notifications due in the near horizon (for sending by a worker)."""
    from app.main import SessionLocal
    db: Session = SessionLocal()
    try:
        rows = due_notifications(db, lookahead_minutes=60)
        return [
            {
                'user_id': p.user_id,
                'next_notification_at': p.next_notification_at,
                'notify_email': p.notify_email,
                'notify_push': p.notify_push,
                'notify_sms': p.notify_sms,
            }
            for p in rows
        ]
    finally:
        db.close()
