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


# Create a single shared Limiter instance
limiter: Limiter = Limiter(
    key_func=get_client_ip,
    storage_uri=_storage_uri_from_settings(),
)


def rate_limit_handler(request: Request, exc: RateLimitExceeded):
    """
    Default exception handler for rate limiting. Attach this in app to return a generic 429.
    """
    # Keep response minimal and generic; avoid leaking internals
    return PlainTextResponse("Too Many Requests", status_code=429)


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
]
