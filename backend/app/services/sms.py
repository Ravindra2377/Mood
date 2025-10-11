"""
Twilio SMS service helper with dev-mode fallback and phone normalization.

Usage:
    from app.services.sms import sms, normalize_phone

    # Send OTP (SMS)
    result = sms.send_otp("+14155552671")  # {"status": "pending"} or {"status":"ok","preview_code":"123456"} in dev

    # Verify OTP
    ok = sms.verify_otp("+14155552671", "123456")  # True in dev; "approved" in prod

This module is designed to be:
- Config-driven: reads Twilio and dev flags from app.config.settings
- Safe-by-default in development: falls back to mock OTP (123456) when DEV_MODE is true or Twilio is not configured
- Strict about phone numbers: normalizes to E.164 using `phonenumbers`
"""

from __future__ import annotations

import logging
from typing import Optional, Dict

from app.config import settings

log = logging.getLogger(__name__)

try:
    import phonenumbers
    from phonenumbers import PhoneNumberFormat
except Exception as _e:
    phonenumbers = None  # type: ignore


class SMSServiceError(Exception):
    """Raised for SMS service configuration or runtime errors."""


def normalize_phone(phone: str, default_region: Optional[str] = "US") -> str:
    """
    Normalize a phone number string to E.164 format.

    - default_region is used for numbers without a country code (e.g., "4155552671" -> "+14155552671" when "US").

    Raises:
        ValueError: if the phone number is invalid
        RuntimeError: if phonenumbers library is not available
    """
    if phonenumbers is None:
        raise RuntimeError(
            "Phone normalization requires the 'phonenumbers' package. "
            "Install it and try again."
        )

    if not phone or not isinstance(phone, str):
        raise ValueError("Phone number must be a non-empty string")

    try:
        parsed = phonenumbers.parse(phone, default_region)
    except Exception:
        raise ValueError("Invalid phone number format")

    if not phonenumbers.is_valid_number(parsed):
        raise ValueError("Invalid phone number")

    return phonenumbers.format_number(parsed, PhoneNumberFormat.E164)


def _mask_phone(p: str) -> str:
    """Mask a phone like +1415******71 for logs."""
    if not p or len(p) < 6:
        return "***"
    keep_prefix = 6 if p.startswith("+") else 4
    keep_suffix = 2
    core_len = max(0, len(p) - (keep_prefix + keep_suffix))
    return f"{p[:keep_prefix]}{'*' * core_len}{p[-keep_suffix:]}"


class SMSService:
    """
    Twilio Verify-backed SMS service with dev-mode fallback.

    When DEV_MODE is True (or Twilio config is incomplete), the service will:
      - send_otp: return {"status": "ok", "preview_code": "123456"}
      - verify_otp: accept "123456" as valid
    """

    DEV_PREVIEW_CODE = "123456"

    def __init__(
        self,
        account_sid: Optional[str] = None,
        auth_token: Optional[str] = None,
        verify_service_sid: Optional[str] = None,
        dev_mode: Optional[bool] = None,
        default_region: Optional[str] = "US",
    ):
        # Pull defaults from settings with safe fallbacks
        self.account_sid = account_sid or getattr(settings, "TWILIO_ACCOUNT_SID", None)
        self.auth_token = auth_token or getattr(settings, "TWILIO_AUTH_TOKEN", None)
        self.verify_service_sid = verify_service_sid or getattr(
            settings, "TWILIO_VERIFY_SERVICE_SID", None
        )
        # Default to True if not present to ease local dev
        self.dev_mode = (
            getattr(settings, "DEV_MODE", True) if dev_mode is None else dev_mode
        )
        self.default_region = default_region

        # Log minimal config state (do not log secrets)
        log.debug(
            "SMSService initialized (dev_mode=%s, verify_service_sid_set=%s)",
            self.dev_mode,
            bool(self.verify_service_sid),
        )

    @property
    def _twilio_configured(self) -> bool:
        return bool(self.account_sid and self.auth_token and self.verify_service_sid)

    def _client(self):
        """Lazily import and create Twilio client."""
        try:
            from twilio.rest import Client  # type: ignore
        except Exception as e:
            raise SMSServiceError(
                "Twilio client not available. Ensure 'twilio' is installed."
            ) from e
        return Client(self.account_sid, self.auth_token)

    def send_otp(self, phone: str) -> Dict[str, str]:
        """
        Send an OTP via Twilio Verify or return a preview code in dev mode.

        Returns:
            Dict with at least {"status": "..."} and optionally {"preview_code": "123456"} in dev.
        """
        normalized = normalize_phone(phone, self.default_region)
        masked = _mask_phone(normalized)

        # Dev-mode or missing Twilio config -> preview fallback
        if self.dev_mode or not self._twilio_configured:
            if not self._twilio_configured:
                log.warning(
                    "Twilio not fully configured; using dev fallback for %s", masked
                )
            else:
                log.info("DEV_MODE true; returning preview OTP for %s", masked)
            return {"status": "ok", "preview_code": self.DEV_PREVIEW_CODE}

        # Production path: Twilio Verify
        try:
            client = self._client()
            verification = client.verify.v2.services(
                self.verify_service_sid
            ).verifications.create(  # type: ignore[attr-defined]
                to=normalized, channel="sms"
            )
            log.info(
                "Twilio Verify sent to %s (status=%s)", masked, verification.status
            )
            return {"status": str(verification.status)}
        except Exception as e:
            # Avoid leaking sensitive details in end-user messages
            log.exception("Failed to send verification code to %s", masked)
            raise SMSServiceError("Failed to send verification code") from e

    def verify_otp(self, phone: str, code: str) -> bool:
        """
        Verify an OTP code and return True if approved.

        In dev mode (or if Twilio is not configured), accepts DEV_PREVIEW_CODE.
        """
        normalized = normalize_phone(phone, self.default_region)
        masked = _mask_phone(normalized)

        # Dev-mode or missing Twilio config -> preview fallback
        if self.dev_mode or not self._twilio_configured:
            ok = code == self.DEV_PREVIEW_CODE
            log.info("DEV verify for %s -> %s", masked, ok)
            return ok

        # Production path: Twilio Verify check
        try:
            client = self._client()
            check = client.verify.v2.services(
                self.verify_service_sid
            ).verification_checks.create(  # type: ignore[attr-defined]
                to=normalized, code=code
            )
            approved = str(check.status).lower() == "approved"
            log.info(
                "Twilio Verify check for %s -> %s (status=%s)",
                masked,
                approved,
                check.status,
            )
            return approved
        except Exception as e:
            log.exception("Verification check failed for %s", masked)
            raise SMSServiceError("Failed to verify code") from e


# Module-level singleton configured from settings
sms = SMSService()
