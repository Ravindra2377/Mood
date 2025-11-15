"""
Shared rate limiter setup to avoid circular imports.

Usage:
    from app.limits import limiter, init_rate_limiter

    # In app.main:
    app = FastAPI(...)
    init_rate_limiter(app)

    # In controllers:
    from app.limits import limiter

    @limiter.limit("10/minute")
    @router.post("/login")
    def login(...):
        ...

This module:
- Creates a single Limiter instance configured from app settings.
- Uses Redis storage when REDIS_URL is provided; falls back to in-memory.
- Provides an initializer to register middleware and a generic 429 handler.
"""

from __future__ import annotations

from typing import Optional

from fastapi import FastAPI, Request
from fastapi.responses import PlainTextResponse
from datetime import datetime, timezone
import hashlib

from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from app.config import settings


def _storage_uri_from_settings() -> Optional[str]:
    """
    Return a storage URI for the limiter if configured, else None to use in-memory storage.

    Examples:
    - "redis://localhost:6379/0"
    - "rediss://:password@host:6379/0"
    """
    try:
        uri = getattr(settings, "REDIS_URL", None)
        if uri:
            return str(uri)
    except Exception:
        # If settings is not yet available, silently fall back to in-memory storage
        pass
    return None


# Trusted proxy and per-phone key helpers


def _parse_trusted_proxies() -> list:
    """
    Parse RATELIMIT_TRUSTED_PROXIES env (comma-separated CIDRs/IPs) into ip_network objects.
    Returns an empty list if not configured.
    """
    nets: list = []
    try:
        cidrs = getattr(settings, "RATELIMIT_TRUSTED_PROXIES", None)
        if not cidrs:
            return nets
        from ipaddress import ip_network  # local import to avoid global dependency

        for raw in str(cidrs).split(","):
            s = raw.strip()
            if not s:
                continue
            try:
                nets.append(ip_network(s, strict=False))
            except Exception:
                # Skip invalid entries rather than failing the request path
                continue
    except Exception:
        # Be conservative on errors: treat as no trusted proxies
        return []
    return nets


def _ip_in_networks(ip: str, nets: list) -> bool:
    """Return True if ip is inside any network in nets. Invalid IPs return False."""
    try:
        from ipaddress import ip_address  # local import to avoid global dependency

        ip_obj = ip_address(ip.strip())
        return any(ip_obj in n for n in nets)
    except Exception:
        return False


def _extract_xff(header_val: str) -> list[str]:
    """Split X-Forwarded-For into a cleaned list of addresses (left-to-right as received)."""
    return [p.strip() for p in header_val.split(",") if p.strip()]


def get_client_ip(request: Request) -> str:
    """
    Resolve the real client IP when behind trusted proxies.
    - Use rightmost non-trusted value in X-Forwarded-For
    - Fallback to request.client.host
    """
    try:
        xff = request.headers.get("x-forwarded-for") or request.headers.get(
            "X-Forwarded-For"
        )
        if xff:
            parts = _extract_xff(xff)
            trusted = _parse_trusted_proxies()
            # Iterate from rightmost (closest hop) to leftmost; pick first non-trusted
            for addr in reversed(parts):
                if not _ip_in_networks(addr, trusted):
                    return addr
        return request.client.host if request.client else "127.0.0.1"
    except Exception:
        return request.client.host if request.client else "127.0.0.1"


def get_phone_key(request: Request) -> str:
    """
    Best-effort per-phone key function for OTP endpoints.
    - Try to read 'phone' from query/path/header and normalize to E.164.
    - Fallback to client IP when phone is unavailable/invalid.
    """
    phone: str | None = None
    try:
        # Prefer explicit query param if provided
        if hasattr(request, "query_params") and "phone" in request.query_params:
            phone = request.query_params.get("phone")
        # Check common header override (if a proxy/controller sets it)
        if not phone:
            phone = request.headers.get("x-phone") or request.headers.get("X-Phone")
        # Path param fallback
        if not phone and hasattr(request, "path_params"):
            phone = request.path_params.get("phone")
        if phone:
            try:
                # Local import to avoid global import/circulars
                from app.services.sms import normalize_phone

                normalized = normalize_phone(phone)
                if normalized:
                    return f"phone:{normalized}"
            except Exception:
                # Normalization failed; fall through to IP
                pass
    except Exception:
        pass
    return f"ip:{get_client_ip(request)}"


def _extract_bearer_user_id(request: Request) -> Optional[int]:
    """Best-effort extraction of the authenticated user id from a bearer token."""
    try:
        auth_header = request.headers.get("authorization") or request.headers.get(
            "Authorization"
        )
        if not auth_header or " " not in auth_header:
            return None
        scheme, token = auth_header.split(" ", 1)
        if scheme.lower() != "bearer":
            return None
        token = token.strip()
        if not token:
            return None
        try:
            # local import to avoid circular dependency during app startup
            from app.services import security

            payload = security.decode_access_token(token)
        except Exception:
            return None
        if not payload or "sub" not in payload:
            return None
        return int(payload["sub"])
    except Exception:
        return None


def user_or_ip_rate_key(request: Request) -> str:
    """Rate-limit key preferring authenticated user id, else hashed IP.

    To reduce user enumeration risk when email-based endpoints are hit prior
    to authentication, we avoid embedding raw IP or email directly beyond the
    prefix. (Authenticated user id is already an internal integer.)
    """
    user_id = _extract_bearer_user_id(request)
    if user_id is not None:
        try:
            request.state.rate_limit_user_id = user_id
        except Exception:
            pass
        return f"user:{user_id}"
    ip = get_client_ip(request)
    try:
        h = hashlib.sha256(ip.encode('utf-8')).hexdigest()[:16]
        return f"ip:{h}"
    except Exception:
        return f"ip:{ip}"


# Create a single shared Limiter instance
limiter: Limiter = Limiter(
    key_func=get_client_ip,
    storage_uri=_storage_uri_from_settings(),
)


def rate_limit_handler(request: Request, exc: RateLimitExceeded):
    """Default exception handler for rate limiting.

    Adds Retry-After (seconds) and X-RateLimit-Reset (unix epoch seconds) headers when
    the window reset can be inferred from SlowAPI's exception state. Keeps body generic
    to avoid leaking detailed strategy information.
    """
    headers = {}
    try:
        # SlowAPI's RateLimitExceeded exposes .reset or .remaining window attributes depending on version
        reset_ts = None
        if hasattr(exc, 'reset') and exc.reset:  # reset is epoch seconds
            reset_ts = int(exc.reset)
        elif hasattr(exc, 'limit') and hasattr(exc, 'window_stats'):
            # Fallback: attempt to compute remaining window
            ws = getattr(exc, 'window_stats', None)
            if ws and isinstance(ws, dict) and 'reset' in ws:
                reset_ts = int(ws['reset'])
        if reset_ts:
            now = int(datetime.now(timezone.utc).timestamp())
            retry_after = max(0, reset_ts - now)
            headers['Retry-After'] = str(retry_after)
            headers['X-RateLimit-Reset'] = str(reset_ts)
    except Exception:
        pass

    return PlainTextResponse("Too Many Requests", status_code=429, headers=headers)


def init_rate_limiter(app: FastAPI) -> None:
    """
    Attach SlowAPI middleware, set the limiter in app.state, and register the 429 handler.

    Call this once during app startup (e.g., in app.main) before including routers.
    """
    # Make limiter available to request state if needed and for decorators imported elsewhere
    app.state.limiter = limiter

    # Middleware attaches rate-limit headers and tracks windows
    app.add_middleware(SlowAPIMiddleware)

    # Register a generic 429 handler
    app.add_exception_handler(RateLimitExceeded, rate_limit_handler)


__all__ = [
    "limiter",
    "init_rate_limiter",
    "rate_limit_handler",
    "get_client_ip",
    "get_phone_key",
    "user_or_ip_rate_key",
]
