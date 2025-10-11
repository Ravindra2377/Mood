"""
SMS/OTP service using Twilio Verify with dev-mode preview and phone normalization.

Usage (common):
    from app.services import sms

    # Normalize a user-provided phone number to E.164 (e.g., +14155550123)
    e164 = sms.normalize_phone("+1 (415) 555-0123")

    # Send OTP
    result = sms.send_otp(e164)
    # In DEV_MODE, result = {"status": "preview", "preview_code": "123456", "to": e164}
    # In production, result = {"status": "pending"|"sent"|..., "sid": "<twilio_sid>", "to": e164}

    # Verify OTP
    ok = sms.verify_otp(e164, "123456")  # True in DEV_MODE with the preview code

Behavior:
- DEV_MODE = True:
    - No SMS is actually sent. A preview code "123456" is returned, and verify_otp accepts it.
- DEV_MODE = False:
    - Requires Twilio credentials (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_VERIFY_SERVICE_SID).
    - Uses Twilio Verify v2 to send and verify OTP codes.

Environment/config (app.config.settings):
- DEV_MODE: bool
- TWILIO_ACCOUNT_SID: str | None
- TWILIO_AUTH_TOKEN: str | None
- TWILIO_VERIFY_SERVICE_SID: str | None
"""

from __future__ import annotations

from typing import Any, Dict

from app.config import settings


class SmsError(Exception):
    """Raised when SMS/OTP operations fail or are misconfigured."""


def _twilio_configured() -> bool:
    """Return True if all Twilio credentials are present."""
    try:
        return all(
            [
                getattr(settings, "TWILIO_ACCOUNT_SID", None),
                getattr(settings, "TWILIO_AUTH_TOKEN", None),
                getattr(settings, "TWILIO_VERIFY_SERVICE_SID", None),
            ]
        )
    except Exception:
        return False


def normalize_phone(raw: str, default_region: str = "US") -> str:
    """
    Normalize a phone number to E.164 format using the phonenumbers library.

    - If the number starts with '+', it will be parsed without a default region.
    - Otherwise, it will be parsed with the provided default_region (default 'US').

    Raises:
        ValueError: if the number cannot be parsed or is invalid.
    """
    if not raw or not str(raw).strip():
        raise ValueError("Phone number is required")

    import phonenumbers
    from phonenumbers import PhoneNumberFormat as PNF

    s = str(raw).strip()
    try:
        if s.startswith("+"):
            num = phonenumbers.parse(s, None)
        else:
            num = phonenumbers.parse(s, default_region or "US")
    except Exception as e:
        raise ValueError(f"Invalid phone number: {raw!r}") from e

    if not (phonenumbers.is_possible_number(num) and phonenumbers.is_valid_number(num)):
        raise ValueError(f"Invalid phone number: {raw!r}")

    return phonenumbers.format_number(num, PNF.E164)


def _preview_code() -> str:
    """
    Return the dev-mode preview code.
    Keep it simple and predictable for QA automation and scripts.
    """
    return "123456"


def send_otp(phone_e164: str) -> Dict[str, Any]:
    """
    Send an OTP code to the given E.164 phone.

    Returns:
        dict:
          - DEV_MODE=True:
              {"status": "preview", "preview_code": "123456", "to": phone_e164}
          - DEV_MODE=False (Twilio):
              {"status": "<twilio_status>", "sid": "<verification_sid>", "to": phone_e164}

    Raises:
        SmsError: if misconfigured or Twilio call fails.
        ValueError: if phone is invalid.
    """
    # Ensure phone is normalized (idempotent: normalize_phone accepts e164)
    p = normalize_phone(phone_e164)

    # Dev mode: do not send SMS; return preview code
    if getattr(settings, "DEV_MODE", True):
        return {"status": "preview", "preview_code": _preview_code(), "to": p}

    # Production path: require Twilio credentials
    if not _twilio_configured():
        raise SmsError(
            "Twilio credentials are not configured. Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_VERIFY_SERVICE_SID."
        )

    try:
        from twilio.rest import Client

        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        service_sid = settings.TWILIO_VERIFY_SERVICE_SID
        v = client.verify.v2.services(service_sid).verifications.create(
            to=p, channel="sms"
        )
        # v.status is typically "pending" or "sent" depending on Twilio flow
        return {
            "status": getattr(v, "status", "sent"),
            "sid": getattr(v, "sid", None),
            "to": p,
        }
    except Exception as e:
        raise SmsError(f"Failed to send OTP via Twilio: {e}") from e


def verify_otp(phone_e164: str, code: str) -> bool:
    """
    Verify an OTP code for the given E.164 phone.

    Returns:
        bool: True if verification is approved, else False.

    Raises:
        SmsError: on Twilio errors in production mode.
        ValueError: on invalid input.
    """
    if not code or not str(code).strip():
        raise ValueError("OTP code is required")

    p = normalize_phone(phone_e164)

    # Dev mode: accept the preview code only
    if getattr(settings, "DEV_MODE", True):
        return str(code).strip() == _preview_code()

    if not _twilio_configured():
        raise SmsError(
            "Twilio credentials are not configured. Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_VERIFY_SERVICE_SID."
        )

    try:
        from twilio.rest import Client

        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        service_sid = settings.TWILIO_VERIFY_SERVICE_SID
        chk = client.verify.v2.services(service_sid).verification_checks.create(
            to=p, code=str(code).strip()
        )
        # Twilio returns status 'approved' on success
        return getattr(chk, "status", "").lower() == "approved"
    except Exception as e:
        raise SmsError(f"Failed to verify OTP via Twilio: {e}") from e


__all__ = [
    "SmsError",
    "normalize_phone",
    "send_otp",
    "verify_otp",
]
