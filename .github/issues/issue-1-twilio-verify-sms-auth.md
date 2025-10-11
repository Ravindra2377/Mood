# Twilio Verify SMS Authentication Integration

Labels: feature, authentication, high-priority  
Milestone: Production Launch v1.0  
Assignees: @backend-lead

## Summary
Enable production-grade SMS OTP login using Twilio Verify with a safe dev/staging fallback. This issue covers environment configuration, endpoint behavior, logging, error handling, and test/rollout steps.

Current repo already includes foundational pieces:
- Service: backend/app/services/sms.py (Twilio + dev fallback + E.164 normalization)
- Endpoints: backend/app/controllers/auth.py (`/api/auth/otp/request`, `/api/auth/verify-otp`)
- Rate limiting scaffold: backend/app/limits.py and decorators in auth controller
- Docker/infra wiring for env vars: docker-compose.prod.yml
- Reverse proxy and Railway runbook: Caddyfile and railway/README.md

This issue finalizes production readiness and documents acceptance, tests, and rollout.

---

## Acceptance Criteria
- [ ] Phone numbers are E.164 formatted and validated (using `phonenumbers`).
- [ ] Staging:
  - [ ] `DEV_MODE=true` by default to use preview OTP (`123456`) unless Twilio is fully configured.
  - [ ] When Twilio credentials are present and `DEV_MODE=false`, staging uses Twilio Verify with real SMS.
- [ ] Production:
  - [ ] `DEV_MODE=false`, Twilio Verify fully configured; real SMS sent.
- [ ] Endpoints:
  - [ ] `POST /api/auth/otp/request` accepts `{ "phone": "<number>" }` and returns a generic status; in dev returns a preview code.
  - [ ] `POST /api/auth/verify-otp` accepts `{ "phone": "<number>", "otp": "<code>" }` and returns access/refresh tokens on success.
- [ ] Error handling:
  - [ ] Invalid phone → 400 `Invalid phone number`.
  - [ ] Invalid OTP → 400 `Invalid OTP`.
  - [ ] Provider/internal errors → 500 `Failed to send verification code` or `Failed to verify code` (no provider details leaked).
- [ ] Logging:
  - [ ] No OTP values in logs, only masked phone numbers.
  - [ ] Errors log masked phone; do not log secrets.
- [ ] Rate limiting:
  - [ ] Limiter decorators present and functional for both endpoints.
  - [ ] Confirm Redis-backed limiter is active in staging/prod when `REDIS_URL` is set.
- [ ] Documentation:
  - [ ] Railway staging/prod env variables set and documented.
  - [ ] Runbook steps for testing OTP on staging and prod added/verified.

---

## Environment Variables (API)
Set in staging and production environments (Railway):
- `SECRET_KEY` (required)
- `DATABASE_URL` (Railway Postgres)
- `REDIS_URL` (Railway Redis; enables distributed rate limits)
- `DEV_MODE` (`true` for staging fallback, `false` for production)
- `ACCESS_TOKEN_EXPIRE_MINUTES` (recommend 15–30)
- `CORS_ORIGINS` (comma-separated allowed origins; no wildcard in production)
- Twilio (production; staging optional if testing real SMS):
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_VERIFY_SERVICE_SID`

Example files:
- railway/.env.staging.example
- railway/.env.production.example

---

## API Contract

1) Request OTP  
- Method: `POST /api/auth/otp/request`  
- Body: `{ "phone": "+14155550123" }`  
- Responses:
  - 200: `{ "status": "ok" }` in dev mode returns `{ "status": "ok", "preview_code": "123456" }`
  - 400: `{ "detail": "phone required" }` or `{ "detail": "Invalid phone number" }`
  - 500: `{ "detail": "Failed to send verification code" }`

2) Verify OTP  
- Method: `POST /api/auth/verify-otp`  
- Body: `{ "phone": "+14155550123", "otp": "123456" }`  
- Responses:
  - 200: `{ "access_token": "...", "token_type": "bearer", "refresh_token": "...", "user": { "id": 1, "email": "<phone>@example.com" } }`
  - 400: `{ "detail": "phone and otp required" }`, `{ "detail": "Invalid phone number" }`, `{ "detail": "Invalid OTP" }`
  - 500: `{ "detail": "Failed to verify code" }`

Notes:
- Phone is normalized to E.164 and used as a synthetic email identifier (`<phone>@example.com`) for OTP-based account.

---

## Implementation Tasks
- [ ] Confirm package dependencies exist (they do in backend/requirements.txt): `twilio`, `phonenumbers`, `slowapi`, `redis`.
- [ ] Declare Twilio and DEV_MODE settings on the `Settings` model (optional but recommended for discoverability):
  - Add fields: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_VERIFY_SERVICE_SID`, `DEV_MODE` to backend/app/config.py (BaseSettings reads `.env`).
- [ ] Verify `backend/app/services/sms.py` behavior:
  - [ ] Dev fallback works with `DEV_MODE=true` or when Twilio is not configured.
  - [ ] E.164 normalization raises on invalid numbers.
  - [ ] Masked logging for phone numbers.
- [ ] Verify endpoints in `backend/app/controllers/auth.py`:
  - [ ] `/otp/request` and `/verify-otp` match the API contract above.
  - [ ] Ensure no OTP values are logged or returned in production.
- [ ] Rate limiting:
  - [ ] Keep existing decorators (`@limiter.limit(...)`) on OTP routes.
  - [ ] Ensure Redis storage is used when `REDIS_URL` is set (configured in backend/app/limits.py).
- [ ] CORS:
  - [ ] Restrict allowed origins in production by reading `CORS_ORIGINS` env and applying to FastAPI CORS (currently default allows all).
- [ ] Infra:
  - [ ] Populate staging/prod variables in Railway following railway/.env.*.example.
  - [ ] Confirm docker-compose.prod.yml passes Twilio envs to the API service (it does).
- [ ] Logging:
  - [ ] Ensure log level and handlers are appropriate for production; no secrets in logs.

---

## Error Handling & Mapping
- Invalid or malformed phone: 400 `Invalid phone number` (from normalization failure).
- Provider send/verify failure (Twilio error): 500 generic message without provider details.
- Wrong/expired OTP (Twilio Verify not approved, or dev mismatch): 400 `Invalid OTP`.
- Missing params: 400 with concise detail message.

---

## Rate Limiting
- Retain current limits in code unless performance/cost data suggests otherwise.
- Confirm distributed limits with Redis in staging/prod:
  - `REDIS_URL` must be set so SlowAPI uses Redis storage (see backend/app/limits.py).
- Option (future): Add per-phone keying for OTP endpoints using a custom `key_func` if abuse detected.

---

## Security & Logging
- Do not log OTP codes.
- Mask phone numbers in logs (already implemented in sms service).
- Keep `DEV_MODE=false` in production. Use dev fallback only in staging or local dev.
- JWT access tokens short-lived; refresh tokens rotated on use (already implemented).

---

## Testing Plan

Automated:
- [ ] Unit: `SMSService` dev mode
  - `send_otp` returns preview code; `verify_otp` accepts preview code only.
- [ ] Unit: Phone normalization
  - Valid E.164, region-based formatting, and error on invalid numbers.
- [ ] Integration: OTP endpoints (dev mode)
  - Request returns preview code; verify with preview code issues tokens; invalid code → 400.
- [ ] Integration: Rate limiting
  - Exceed limits returns 429; headers include retry metadata.
- [ ] Integration: Redis outage behavior (optional)
  - Confirm API remains functional; limiter gracefully degrades or fails closed based on policy.

Manual (staging):
- [ ] With `DEV_MODE=true`, call `POST /api/auth/otp/request` with test number; confirm preview code `123456`.
- [ ] `POST /api/auth/verify-otp` with preview code returns tokens; call a protected endpoint with the access token.
- [ ] Flip staging to `DEV_MODE=false` and fill Twilio keys; verify real SMS delivery and code approval.

Manual (production):
- [ ] Real number receives SMS; correct code logs in; wrong code fails.
- [ ] Logs show masked phones only; no secrets or OTP values.

---

## Rollout
- Staging:
  - [ ] Deploy with `DEV_MODE=true` initially; validate flows end-to-end with preview OTP.
  - [ ] Optionally toggle to `DEV_MODE=false` to validate Twilio on staging with a real device/number.
- Production:
  - [ ] Ensure `DEV_MODE=false` and all Twilio envs set.
  - [ ] Run smoke test (healthz, request OTP, verify OTP) using a staff phone number.
- Post-deploy:
  - [ ] Monitor 5xx rates, Twilio error logs, and rate-limit 429s.
  - [ ] Validate cost and delivery metrics in Twilio console.

---

## Definition of Done
- [ ] Endpoints operate as specified in staging and production.
- [ ] Twilio credentials and secrets stored only in environment (Railway), not committed.
- [ ] Dev fallback works only when intended (staging/local), not in production.
- [ ] Logs are clean of OTP codes and sensitive data; phones masked.
- [ ] Tests implemented and passing (unit + integration).
- [ ] Runbook updated to include OTP testing steps for staging and production (railway/README.md).
- [ ] Team informed of preview OTP behavior in staging and real-SMS behavior in production.

---

## References
- Code:
  - backend/app/services/sms.py
  - backend/app/controllers/auth.py
  - backend/app/limits.py
  - backend/app/main.py
  - backend/requirements.txt
- Infra:
  - docker-compose.prod.yml
  - Caddyfile
  - docker/Dockerfile.api
  - railway/README.md
  - railway/.env.staging.example
  - railway/.env.production.example