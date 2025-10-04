from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from app.services import security
from fastapi import Request
from typing import Optional

oauth2_scheme = OAuth2PasswordBearer(tokenUrl='/api/auth/token')
# optional oauth scheme for endpoints that may be public
oauth2_scheme_optional = OAuth2PasswordBearer(tokenUrl='/api/auth/token', auto_error=False)


def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = security.decode_access_token(token)
    if not payload or 'sub' not in payload:
        raise HTTPException(status_code=401, detail='Invalid token')
    user_id = int(payload['sub'])
    # load user from DB
    from app.main import SessionLocal
    from app.models.user import User
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=401, detail='User not found')
        return user
    finally:
        db.close()


def get_current_user_optional(token: str | None = Depends(oauth2_scheme_optional)):
    # If no token provided, return None (public access)
    if not token:
        return None
    payload = security.decode_access_token(token)
    if not payload or 'sub' not in payload:
        return None
    user_id = int(payload['sub'])
    # load user from DB
    from app.main import SessionLocal
    from app.models.user import User
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == user_id).first()
        return user
    finally:
        db.close()


def get_current_active_user(current_user = Depends(get_current_user)):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail='Inactive user')
    return current_user


def require_role(role: str):
    def role_checker(current_user = Depends(get_current_user)):
        if current_user.role != role:
            raise HTTPException(status_code=403, detail='Insufficient permissions')
        return current_user
    return role_checker


def get_locale(request: Request, current_user = Depends(get_current_user_optional)) -> str:
    """Dependency that returns the resolved locale for the request. Prefers the user's
    profile.language if present; otherwise falls back to request.state.locale set by middleware.
    """
    # If middleware already resolved and cached a profile language, use it.
    if getattr(request.state, 'profile_locale_cached', False):
        return getattr(request.state, 'locale', 'en')
    # Otherwise fall back to middleware-resolved locale which may be from Accept-Language
    return getattr(request.state, 'locale', 'en')
