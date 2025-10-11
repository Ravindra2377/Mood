# Redis-backed SlowAPI Rate Limiting

Labels: security, rate-limiting, high-priority  
Milestone: Production Launch v1.0  
Assignees: @backend-lead

## Summary

Enforce robust API rate limiting using SlowAPI with Redis storage to protect authentication flows (especially OTP), avoid abuse, and control infrastructure/SMS cost. Ensure correct client IP extraction behind Caddy, add per-phone throttling for OTP endpoints, and document limits and operations.

Current state in repo:
- Limiter wiring exists: `backend/app/limits.py` (creates a shared `Limiter`, attaches middleware/handler).
- Controllers already use decorators on sensitive routes (e.g., `auth.py` has `@limiter.limit` on login, password reset, OTP).
- Deployment includes Redis and Caddy; `Caddyfile` forwards `X-Forwarded-For`.

This issue finalizes production behavior: Redis-backed storage, correct client-IP detection behind proxy, tuned limits, optional per-phone throttle, tests, and documentation.

---

## Acceptance Criteria

- [ ] Limiter storage uses Redis in staging/production when `REDIS_URL` is set; otherwise in-memory fallback for local/dev.
- [ ] Client IP is correctly derived behind Caddy using `X-Forwarded-For` and a trusted proxies list; no “all requests from proxy IP” effect.
- [ ] Rate limits tuned and documented:
  - [ ] `/api/auth/otp/request`: 5 per 15m per phone; 20 per hour per IP
  - [ ] `/api/auth/verify-otp`: 10 per hour per phone; reasonable per-IP cap
  - [ ] Default for public API endpoints: 100/min per IP (exclude health/admin as appropriate)
- [ ] Health endpoints (`/healthz`, `/readyz`) are exempt.
- [ ] OTP per-phone throttling enforced (per Redis counter) even if IP rotates.
- [ ] 429 responses return a generic body (“Too Many Requests”), no sensitive leakage; include `Retry-After` when feasible.
- [ ] Observability:
  - [ ] Structured log entries for 429s with fields: `endpoint`, `key`, `limit`, `window`.
- [ ] Failure modes:
  - [ ] If Redis is down, IP-based limits fall back to in-memory (SlowAPI default); per-phone throttle gracefully disables (OTP still protected by IP limits), with clear log warning.
- [ ] Documentation updated (limits, env vars, ops notes).

---

## Environment Variables

Required in staging/production:
- `REDIS_URL` (e.g., `redis://<host>:<port>/0`)

New (to implement in this issue):
- `RATELIMIT_TRUSTED_PROXIES` (comma-separated CIDRs/hosts for proxies/load balancers, e.g., `10.0.0.0/8,127.0.0.1/32`)
- `RATELIMIT_DEFAULT_PER_IP` (optional, default `100/minute`)
- `RATELIMIT_OTP_REQUEST_PER_IP` (optional override, default `20/hour`)
- `RATELIMIT_OTP_VERIFY_PER_IP` (optional override)
- `RATELIMIT_ENABLED` (optional feature flag; default true in non-dev)

Note: These are not yet in `Settings`. Part of this issue is to add them.

---

## Suggested Limits (initial)

- POST `/api/auth/otp/request`
  - 5 per 15 minutes per phone
  - 20 per hour per IP
- POST `/api/auth/verify-otp`
  - 10 per hour per phone
  - 60 per hour per IP
- Default (other public endpoints):
  - 100 per minute per IP
- Exemptions:
  - `/healthz`, `/readyz`, internal/admin endpoints as designated

Rationale:
- Protect Twilio spend and OTP abuse with low per-phone limits.
- Tolerate NAT/shared IPs with a lenient per-IP cap.
- Keep general API limits broad to avoid product friction.

---

## Implementation Tasks

1) Settings and configuration
- [ ] Extend `backend/app/config.py (Settings)` with:
  - `RATELIMIT_TRUSTED_PROXIES: str | None = None`
  - `RATELIMIT_DEFAULT_PER_IP: str = "100/minute"`
  - `RATELIMIT_OTP_REQUEST_PER_IP: str = "20/hour"`
  - `RATELIMIT_OTP_VERIFY_PER_IP: str = "60/hour"`
  - `RATELIMIT_ENABLED: bool = True`
- [ ] Ensure `.env` consumption remains via Pydantic BaseSettings.
- [ ] Document new env vars in `railway/README.md`.

2) Proxy-aware client IP extraction
- [ ] Implement a custom `ip_key_func(request)` in `backend/app/limits.py`:
  - Parse `X-Forwarded-For` (left-most untrusted hop as client IP).
  - Trust IPs/nets from `RATELIMIT_TRUSTED_PROXIES`.
  - Fallback to `request.client.host`.
- [ ] Initialize `Limiter` with this `key_func` globally (instead of `get_remote_address`).

3) Storage and middleware
- [ ] Confirm `Limiter(..., storage_uri=_storage_uri_from_settings())` uses Redis when `REDIS_URL` is set; otherwise in-memory.
- [ ] Keep existing `SlowAPIMiddleware` and 429 handler wiring as-is.

4) Endpoint decorators and defaults
- [ ] Review and tune existing decorators in `backend/app/controllers/auth.py`:
  - [ ] Adjust `@limiter.limit(...)` values to reflect IP caps above.
  - [ ] Ensure health/admin routes are not decorated or have exemptions.
- [ ] Optionally provide a helper to apply default API limit to groups of routes (non-auth).

5) Per-phone throttle for OTP endpoints (Redis counters)
- [ ] Add a small helper in `backend/app/services/sms.py` or a new `backend/app/services/rate_limits.py`:
  - Functions: `throttle_phone(action: str, phone: str, limit: int, window_sec: int) -> bool`
  - Key format: `rl:{action}:{e164_phone}`
  - Use `INCR` with `EXPIRE` when key is first set; return False if over limit.
- [ ] In `otp_request` and `verify_otp` handlers (auth controller), enforce per-phone throttle before calling Twilio/verify.
  - On throttle exceeded, raise 429 with generic body and set `Retry-After` header if possible.
- [ ] If Redis unavailable, log warning and skip per-phone throttle (rely on IP limits).

6) Observability and logging
- [ ] On 429 (both IP and phone throttles), log a structured event:
  - `event=rate_limit`, `endpoint`, `key_type=ip|phone`, `key`, `limit`, `window`, `retry_after`
- [ ] Ensure no PII leakage beyond masked phone (e.g., `+1415******71`).

7) Docs
- [ ] Update `railway/README.md` with:
  - How to set `REDIS_URL`, `RATELIMIT_TRUSTED_PROXIES`
  - Expected behavior and how to test rate limits
  - Failure modes and fallback behavior

---

## Tests

Unit
- [ ] `ip_key_func` correctly resolves client IP with various `X-Forwarded-For` chains and trusted proxy sets.
- [ ] Phone throttle helper:
  - [ ] First N requests within window allowed; N+1 returns rejected.
  - [ ] TTL/window expiration resets counters.
  - [ ] Redis outage path: helper raises or returns graceful “not enforced,” logged.

Integration
- [ ] With Redis enabled:
  - [ ] Exceed OTP request limits per phone → 429; `Retry-After` present.
  - [ ] Exceed OTP request limits per IP → 429.
  - [ ] Verify endpoint limits similarly enforced.
- [ ] With Redis disabled:
  - [ ] IP-based limits still apply (in-memory storage).
  - [ ] Phone-based throttle skipped gracefully; logs warn.
- [ ] Proxy simulation:
  - [ ] Requests with `X-Forwarded-For` chain respect real client IP when proxies trusted.

Manual (staging)
- [ ] Hit `/api/auth/otp/request` > 5 times in 15m with same phone → 429.
- [ ] Hit `/api/auth/otp/request` > 20 times/hour from same IP → 429.
- [ ] Verify similar behavior for `/api/auth/verify-otp`.

---

## Failure Modes and Behavior

- Redis down:
  - SlowAPI storage falls back to in-memory (already handled by config); limits apply per-instance.
  - Per-phone throttle disabled; log a warning; keep endpoints functional.
- Proxy misconfiguration:
  - If `RATELIMIT_TRUSTED_PROXIES` is wrong, multiple clients may share the proxy IP and be over-throttled.
  - Validate with proxy simulation tests; adjust CIDRs.

---

## Definition of Done

- [ ] Redis-backed IP limits active in staging/prod; verified via tests.
- [ ] Per-phone throttles active for OTP endpoints when Redis available; disabled gracefully otherwise.
- [ ] Trusted proxy handling implemented and tested.
- [ ] Decorators reviewed and tuned on auth endpoints; health/admin exempt.
- [ ] Structured logs for 429s; no sensitive data leaked.
- [ ] Docs updated (Railway guide, limits, env vars, troubleshooting).
- [ ] Smoke tests for 429 behavior completed on staging.

---

## References

- Code:
  - `backend/app/limits.py` (Limiter setup, middleware, handler)
  - `backend/app/controllers/auth.py` (OTP and auth endpoints with decorators)
  - `backend/app/services/sms.py` (OTP flow; candidate place to add phone throttle or new service)
  - `backend/requirements.txt` (slowapi, redis)
- Infra:
  - `Caddyfile` (forwards `X-Forwarded-For`)
  - `docker-compose.prod.yml` (Redis service example)
  - `railway/README.md` (deployment/runbook to update)
