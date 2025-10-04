from fastapi import APIRouter, Depends, Response, HTTPException, Request
from app.dependencies import get_current_user
from app.models.user import User
from app.models.consent_audit import ConsentAudit
from app.services.task_queue import enqueue
import io, csv, json
import logging

log = logging.getLogger('privacy')

router = APIRouter()


@router.get('/privacy/export')
def export_my_data(format: str = 'json', current_user: User = Depends(get_current_user)):
    """Export basic user data and records (moods, journals) for the requesting user.

    For privacy, this only returns data for the requesting user. Admin export should be separate.
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        uid = current_user.id
        # collect user, profile, moods, journals
        from app.models.user import User as UserModel
        from app.models.profile import Profile
        from app.models.mood_entry import MoodEntry
        from app.models.journal_entry import JournalEntry

        user = db.query(UserModel).filter(UserModel.id == uid).first()
        profile = db.query(Profile).filter(Profile.user_id == uid).first()
        moods = db.query(MoodEntry).filter(MoodEntry.user_id == uid).all()
        journals = db.query(JournalEntry).filter(JournalEntry.user_id == uid).all()

        # decrypt journals
        try:
            from app.services.crypto import decrypt_text
            for j in journals:
                if getattr(j, 'content', None):
                    j.content = decrypt_text(j.content)
        except Exception:
            log.exception('Failed to decrypt journals during export')

        payload = {
            'user': {'id': user.id, 'email': user.email},
            'profile': { 'language': getattr(profile, 'language', None), 'display_name': getattr(profile, 'display_name', None) },
            'moods': [{'id': m.id, 'score': m.score, 'note': m.note, 'created_at': m.created_at.isoformat() if m.created_at else None} for m in moods],
            'journals': [{'id': j.id, 'title': j.title, 'content': getattr(j, 'content', None), 'created_at': j.created_at.isoformat() if j.created_at else None} for j in journals]
        }

        if format.lower() == 'csv':
            output = io.StringIO()
            writer = csv.writer(output)
            writer.writerow(['section','id','key','value'])
            writer.writerow(['user', user.id, 'email', user.email])
            for m in payload['moods']:
                writer.writerow(['mood', m['id'], 'score', m['score']])
            for j in payload['journals']:
                writer.writerow(['journal', j['id'], 'title', j['title']])
            return Response(content=output.getvalue(), media_type='text/csv', headers={'Content-Disposition': 'attachment; filename="data_export.csv"'})
        return payload
    finally:
        db.close()


def _do_delete_user_data(user_id: int):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        # delete journals, moods, profile, optionally anonymize user
        from app.models.journal_entry import JournalEntry
        from app.models.mood_entry import MoodEntry
        from app.models.profile import Profile
        db.query(JournalEntry).filter(JournalEntry.user_id == user_id).delete()
        db.query(MoodEntry).filter(MoodEntry.user_id == user_id).delete()
        db.query(Profile).filter(Profile.user_id == user_id).delete()
        # note: keep user row to preserve referential integrity but anonymize email
        from app.models.user import User as UserModel
        u = db.query(UserModel).filter(UserModel.id == user_id).first()
        if u:
            u.email = f'deleted_user_{user_id}@example.com'
        db.commit()
    finally:
        db.close()


@router.post('/privacy/delete')
def delete_my_data(request: Request, current_user: User = Depends(get_current_user)):
    """Request deletion of user's personal data. Deletion is executed in background to avoid blocking.

    Returns a 202 Accepted and enqueues the deletion task; a consent audit is recorded.
    """
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        audit = ConsentAudit(user_id=current_user.id, field='data_deletion_requested', old_value='False', new_value='True', source_ip=request.client.host if request.client else None, source_ua=request.headers.get('user-agent'))
        db.add(audit)
        db.commit()
    finally:
        db.close()

    # enqueue deletion to background
    enqueue(_do_delete_user_data, current_user.id)
    return Response(status_code=202)
