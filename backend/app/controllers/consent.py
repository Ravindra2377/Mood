from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional

import hashlib
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field

from app.dependencies import get_current_user, get_current_user_optional
from app.config import settings
from app.limits import limiter, get_client_ip

# Models
from app.models.user import User
from app.models.consent_event import ConsentEvent

router = APIRouter()


# ---------
# Schemas
# ---------
class ConsentSubmit(BaseModel):
    policy_version: str = Field(
        ...,
        description="Version identifier for the current legal policy set (e.g., 2025-01).",
    )
    tos_accepted: bool = Field(..., description="User accepted Terms of Service.")
    privacy_accepted: bool = Field(..., description="User accepted Privacy Policy.")
    research_opt_in: Optional[bool] = Field(
        default=False, description="Optional research/data-use opt-in."
    )
    consent_version: Optional[str] = Field(
        default=None, description="Application-level version of consent set (optional)."
    )


class ConsentCurrentResponse(BaseModel):
    tos_version: str
    privacy_version: str
    research_version: Optional[str] = None
    legal_urls: dict
    user_state: Optional[dict] = None


# -------------
# Helpers
# -------------
def _now_utc() -> datetime:
    return datetime.now(timezone.utc)


def _hash_ip(ip: str | None, salt: Optional[str]) -> Optional[str]:
    if not ip or not salt:
        return None
    try:
        return hashlib.sha256(f"{salt}:{ip}".encode("utf-8")).hexdigest()
    except Exception:
        return None


def _current_versions() -> tuple[str, str, Optional[str]]:
    tos_v = getattr(settings, "LEGAL_TOS_VERSION", "v1")
    privacy_v = getattr(settings, "LEGAL_PRIVACY_VERSION", "v1")
    research_v = getattr(settings, "LEGAL_RESEARCH_CONSENT_VERSION", None)
    return tos_v, privacy_v, research_v


def _legal_urls() -> dict:
    return {
        "terms": getattr(
            settings, "LEGAL_TERMS_URL", "https://example.com/legal/terms"
        ),
        "privacy": getattr(
            settings, "LEGAL_PRIVACY_URL", "https://example.com/legal/privacy"
        ),
    }


def _policy_version_from_current() -> str:
    """
    Combine current legal versions into a single policy version identifier by default.
    Applications may pass a more specific 'policy_version' from the client during submit.
    """
    tos_v, privacy_v, research_v = _current_versions()
    base = f"TOS:{tos_v}|PRIV:{privacy_v}"
    if research_v:
        base += f"|RSCH:{research_v}"
    return base


def _user_latest_event(db, user_id: int) -> Optional[ConsentEvent]:
    return (
        db.query(ConsentEvent)
        .filter(ConsentEvent.user_id == user_id)
        .order_by(ConsentEvent.created_at.desc())
        .first()
    )


# --------------------
# Endpoints
# --------------------
@limiter.limit("30/minute", key_func=get_client_ip)
@router.get("/consent/current", response_model=ConsentCurrentResponse)
def consent_current(
    request: Request,
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    """
    Return current legal versions and canonical URLs.
    If authenticated, include best-effort user state (has_consented + last event) based on most recent ConsentEvent.
    """
    from app.main import SessionLocal

    tos_v, privacy_v, research_v = _current_versions()
    urls = _legal_urls()

    user_state: Optional[dict] = None
    if current_user:
        db = SessionLocal()
        try:
            ev = _user_latest_event(db, current_user.id)
            if ev:
                # has_consented if both TOS and Privacy are accepted, and event matches current policy_version
                current_policy = _policy_version_from_current()
                has_consented = bool(
                    ev.tos_accepted_at
                    and ev.privacy_accepted_at
                    and ev.policy_version == current_policy
                )
                user_state = {
                    "has_consented": has_consented,
                    "last_event": {
                        "policy_version": ev.policy_version,
                        "consent_version": ev.consent_version,
                        "tos_accepted_at": ev.tos_accepted_at.isoformat()
                        if ev.tos_accepted_at
                        else None,
                        "privacy_accepted_at": ev.privacy_accepted_at.isoformat()
                        if ev.privacy_accepted_at
                        else None,
                        "research_opt_in": ev.research_opt_in,
                        "created_at": ev.created_at.isoformat()
                        if ev.created_at
                        else None,
                    },
                }
            else:
                user_state = {"has_consented": False, "last_event": None}
        finally:
            db.close()

    return {
        "tos_version": tos_v,
        "privacy_version": privacy_v,
        "research_version": research_v,
        "legal_urls": urls,
        "user_state": user_state,
    }


@limiter.limit("10/minute", key_func=get_client_ip)
@router.post("/consent/submit")
def consent_submit(
    payload: ConsentSubmit,
    request: Request,
    current_user: User = Depends(get_current_user),
):
    """
    Record a new immutable consent event for the authenticated user.
    - Requires acceptance of both TOS and Privacy.
    - Uses one-way IP hashing with a server-side salt (CONSENT_IP_HASH_SALT) if configured.
    """
    from app.main import SessionLocal

    if not payload.tos_accepted or not payload.privacy_accepted:
        raise HTTPException(
            status_code=400, detail="Must accept both Terms and Privacy to proceed"
        )

    # Compute timestamps only for accepted fields (required by payload contract, but stay explicit)
    ts = _now_utc()
    tos_at = ts if payload.tos_accepted else None
    priv_at = ts if payload.privacy_accepted else None

    # Hash the client IP
    client_ip = get_client_ip(request)
    ip_hash = _hash_ip(client_ip, getattr(settings, "CONSENT_IP_HASH_SALT", None))

    # Persist immutable event
    db = SessionLocal()
    try:
        ev = ConsentEvent(
            user_id=current_user.id,
            policy_version=payload.policy_version or _policy_version_from_current(),
            tos_accepted_at=tos_at,
            privacy_accepted_at=priv_at,
            research_opt_in=bool(payload.research_opt_in),
            ip_hash=ip_hash,
            user_agent=request.headers.get("user-agent"),
            consent_version=payload.consent_version,
            created_at=_now_utc(),
        )
        db.add(ev)
        db.commit()
        db.refresh(ev)

        return {
            "status": "ok",
            "event": {
                "id": ev.id,
                "policy_version": ev.policy_version,
                "consent_version": ev.consent_version,
                "research_opt_in": ev.research_opt_in,
                "tos_accepted_at": ev.tos_accepted_at.isoformat()
                if ev.tos_accepted_at
                else None,
                "privacy_accepted_at": ev.privacy_accepted_at.isoformat()
                if ev.privacy_accepted_at
                else None,
                "created_at": ev.created_at.isoformat() if ev.created_at else None,
            },
        }
    finally:
        db.close()
