from fastapi import APIRouter, HTTPException, status, Depends, Body
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.schemas.user import (
	UserCreate,
	UserRead,
	Token,
	PasswordResetRequest,
	PasswordResetConfirm,
)
from app.models.user import User
from app.models.refresh_token import RefreshToken
from app.services import security
from app.services.email import send_email
from app.services.i18n import t_format
from app.dependencies import get_locale
from app.config import settings
from app.services.analytics import record_event
from datetime import datetime, timedelta, timezone
import secrets
import hashlib


router = APIRouter()


@router.post("/signup", response_model=UserRead)
def signup(user_in: UserCreate):
	"""Create a new user (minimal implementation)."""
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		existing = db.query(User).filter(User.email == user_in.email).first()
		if existing:
			raise HTTPException(status_code=400, detail="Email already registered")
		user = User(email=user_in.email, hashed_password=security.hash_password(user_in.password))
		db.add(user)
		db.commit()
		db.refresh(user)
		# record signup event
		try:
			record_event('signup', user_id=user.id, props={'email': user_in.email})
		except Exception:
			pass
		return user
	finally:
		db.close()


@router.post("/token", response_model=Token)
def token(form_data: OAuth2PasswordRequestForm = Depends()):
	"""Exchange username/password for an access token and issue a refresh token."""
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		user = db.query(User).filter(User.email == form_data.username).first()
		if not user or not security.verify_password(form_data.password, user.hashed_password):
			raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
		# update last login
		user.last_login = datetime.now(timezone.utc)
		db.add(user)
		db.commit()
		access_token = security.create_access_token({"sub": str(user.id), "role": user.role})
		# create a refresh token and persist a hash server-side
		refresh_plain = secrets.token_urlsafe(48)
		refresh_hash = hashlib.sha256(refresh_plain.encode("utf-8")).hexdigest()
		expires = datetime.now(timezone.utc) + timedelta(days=30)
		rt = RefreshToken(user_id=user.id, token_hash=refresh_hash, expires_at=expires)
		db.add(rt)
		db.commit()
		db.refresh(rt)
		# record login event
		try:
			record_event('login', user_id=user.id, props={'method': 'password'})
		except Exception:
			pass
		return {"access_token": access_token, "token_type": "bearer", "refresh_token": refresh_plain}
	finally:
		db.close()


@router.post("/password-reset/request")
def password_reset_request(payload: PasswordResetRequest, locale: str = Depends(get_locale)):
	"""Generate a password reset token and (stub) send it to the user's email."""
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		user = db.query(User).filter(User.email == payload.email).first()
		if not user:
			# don't reveal user existence
			return {"status": "ok"}
		token = secrets.token_urlsafe(32)
		# store a hash of the token so DB leaks don't reveal usable tokens
		token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
		user.password_reset_token = token_hash
		user.password_reset_expires = datetime.now(timezone.utc) + timedelta(hours=1)
		db.add(user)
		db.commit()
		# In real app, send email with a reset link containing token
		reset_link = f"https://example.com/reset-password?token={token}"
		html = t_format('password_reset_html', locale, email=user.email, reset_link=reset_link)
		text = t_format('password_reset_text', locale, email=user.email, reset_link=reset_link)
		subject = t_format('password_reset_subject', locale)
		result = send_email(to=user.email, subject=subject, html_body=html, text_body=text)
		if settings.DEV_EMAIL_PREVIEW:
			# Include the reset link when running in dev preview so tests can extract token
			return {"preview": result, "reset_link": reset_link}
		return {"status": "ok"}
	finally:
		db.close()


@router.post("/password-reset/confirm")
def password_reset_confirm(payload: PasswordResetConfirm, locale: str = Depends(get_locale)):
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		token_hash = hashlib.sha256(payload.token.encode("utf-8")).hexdigest()
		user = db.query(User).filter(User.password_reset_token == token_hash).first()
		# ensure expiry comparison is timezone-aware
		expires = user.password_reset_expires if user else None
		if expires is not None and expires.tzinfo is None:
			from datetime import timezone as _tz
			expires = expires.replace(tzinfo=_tz.utc)
		if not user or not expires or expires < datetime.now(timezone.utc):
			raise HTTPException(status_code=400, detail="Invalid or expired token")
		user.hashed_password = security.hash_password(payload.new_password)
		user.password_reset_token = None
		user.password_reset_expires = None
		db.add(user)
		db.commit()
		# send confirmation email that password was changed
		login_link = "https://example.com/login"
		html = t_format('password_changed_html', locale, email=user.email, login_link=login_link)
		text = t_format('password_changed_text', locale, email=user.email, login_link=login_link)
		subject = t_format('password_changed_subject', locale)
		result = send_email(to=user.email, subject=subject, html_body=html, text_body=text)
		if settings.DEV_EMAIL_PREVIEW:
			return {"preview": result}
		return {"status": "ok"}
	finally:
		db.close()


@router.post("/refresh")
def refresh_token(payload: dict = Body(...)):
	"""Exchange a refresh token for a new access token and rotate the refresh token.
	The used refresh token is revoked and a new one is issued.
	"""
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		old_refresh_token = payload.get("old_refresh_token")
		if not old_refresh_token:
			raise HTTPException(status_code=400, detail="old_refresh_token required")
		h = hashlib.sha256(old_refresh_token.encode("utf-8")).hexdigest()
		rt = db.query(RefreshToken).filter(RefreshToken.token_hash == h, RefreshToken.revoked == False).first()
		# Ensure expiry comparison is timezone-aware: coerce naive DB datetimes to UTC
		expiry = rt.expires_at if rt else None
		if expiry is not None and expiry.tzinfo is None:
			# assume naive datetimes in DB are UTC
			from datetime import timezone as _tz
			expiry = expiry.replace(tzinfo=_tz.utc)
		if not rt or expiry < datetime.now(timezone.utc):
			raise HTTPException(status_code=401, detail="Invalid refresh token")
		user = db.query(User).filter(User.id == rt.user_id).first()
		if not user:
			raise HTTPException(status_code=401, detail="Invalid token")
		# revoke the used refresh token
		rt.revoked = True
		db.add(rt)
		# create a new refresh token (rotation)
		new_plain = secrets.token_urlsafe(48)
		new_hash = hashlib.sha256(new_plain.encode("utf-8")).hexdigest()
		new_expires = datetime.now(timezone.utc) + timedelta(days=30)
		new_rt = RefreshToken(user_id=user.id, token_hash=new_hash, expires_at=new_expires)
		db.add(new_rt)
		db.commit()
		access_token = security.create_access_token({"sub": str(user.id), "role": user.role})
		return {"access_token": access_token, "refresh_token": new_plain}
	finally:
		db.close()


@router.post("/logout")
def logout(payload: dict = Body(...)):
	"""Revoke the given refresh token so it cannot be used again."""
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		refresh_token = payload.get("refresh_token")
		if not refresh_token:
			return {"status": "ok"}
		h = hashlib.sha256(refresh_token.encode("utf-8")).hexdigest()
		rt = db.query(RefreshToken).filter(RefreshToken.token_hash == h).first()
		if rt:
			rt.revoked = True
			db.add(rt)
			db.commit()
		return {"status": "ok"}
	finally:
		db.close()


@router.post("/verify")
def send_verification(email: str, locale: str = Depends(get_locale)):
	"""Generate a verification token and (stub) send to user email."""
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		user = db.query(User).filter(User.email == email).first()
		if not user:
			return {"status": "ok"}
		token = security.create_access_token({"sub": str(user.id)}, expires_delta=60)
		verify_link = f"https://example.com/verify?token={token}"
		html = t_format('verify_account_html', locale, email=user.email, verify_link=verify_link)
		text = t_format('verify_account_text', locale, email=user.email, verify_link=verify_link)
		subject = t_format('verify_account_subject', locale)
		result = send_email(to=user.email, subject=subject, html_body=html, text_body=text)
		if settings.DEV_EMAIL_PREVIEW:
			# Include the verification token in dev preview to make tests deterministic
			return {"preview": result, "verification_token": token}
		return {"status": "ok"}
	finally:
		db.close()


@router.post("/verify/confirm")
def verify_confirm(token: str):
	payload = security.decode_access_token(token)
	if not payload or "sub" not in payload:
		raise HTTPException(status_code=400, detail="Invalid token")
	user_id = int(payload["sub"])
	from app.main import SessionLocal

	db: Session = SessionLocal()
	try:
		user = db.query(User).filter(User.id == user_id).first()
		if not user:
			raise HTTPException(status_code=400, detail="User not found")
		user.is_verified = True
		db.add(user)
		db.commit()
		return {"status": "ok"}
	finally:
		db.close()
