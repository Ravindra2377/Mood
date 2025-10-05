from fastapi import APIRouter, Depends, HTTPException
from app.dependencies import get_current_user
from app.services.i18n import t, load_locale
from app.models.profile import Profile
from app.services.i18n import t_format, bundle
from app.models.translation import Translation
from typing import Dict
from app.dependencies import require_role

router = APIRouter()


@router.get('/me/language')
def get_my_language(current_user=Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
        if not p:
            # create profile on demand
            p = Profile(user_id=current_user.id)
            db.add(p)
            db.commit()
            db.refresh(p)
        return {'language': p.language}
    finally:
        db.close()


@router.post('/me/language')
def set_my_language(language: str, current_user=Depends(get_current_user)):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
        if not p:
            p = Profile(user_id=current_user.id)
        p.language = language
        db.add(p)
        db.commit()
        return {'language': p.language}
    finally:
        db.close()


@router.get('/translate')
def translate(key: str, locale: str | None = None, current_user=Depends(get_current_user)):
    lang = 'en'
    if locale:
        lang = locale
    else:
        # try to infer from profile
        from app.main import SessionLocal
        db = SessionLocal()
        try:
            p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
            if p and getattr(p, 'language', None):
                lang = p.language
        finally:
            db.close()
    return {'key': key, 'locale': lang, 'text': t(key, lang)}

@router.get('/bundle')
def get_bundle(locale: str = 'en'):
    return bundle(locale)

@router.get('/admin/translations', dependencies=[Depends(require_role('admin'))])
def list_translations(locale: str | None = None):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        q = db.query(Translation)
        if locale:
            q = q.filter(Translation.locale == locale)
        rows = q.all()
        return [{ 'id': r.id, 'locale': r.locale, 'key': r.key, 'value': r.value } for r in rows]
    finally:
        db.close()

@router.post('/admin/translations', dependencies=[Depends(require_role('admin'))])
def upsert_translation(locale: str, key: str, value: str):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        tr = db.query(Translation).filter(Translation.locale == locale, Translation.key == key).first()
        if tr:
            tr.value = value
        else:
            tr = Translation(locale=locale, key=key, value=value)
            db.add(tr)
        db.commit()
        return {'locale': tr.locale, 'key': tr.key, 'value': tr.value}
    finally:
        db.close()

@router.delete('/admin/translations/{translation_id}', dependencies=[Depends(require_role('admin'))])
def delete_translation(translation_id: int):
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        tr = db.query(Translation).filter(Translation.id == translation_id).first()
        if not tr:
            raise HTTPException(status_code=404, detail='Not found')
        db.delete(tr)
        db.commit()
        return {'deleted': True}
    finally:
        db.close()
