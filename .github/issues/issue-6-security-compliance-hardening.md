# Security & Compliance Hardening

Labels: security, compliance, high-priority  
Milestone: Production Launch v1.0  
Assignees: @security-lead, @backend-lead, @infra-lead

## Summary
Raise the SOUL platform to a production-grade security and compliance baseline. This issue implements and verifies HTTP security headers, TLS/HSTS posture, strict CORS, JWT hardening (TTL/rotation/revocation), dependency and container scanning, secret hygiene, audit logging, and basic error monitoring. It also documents procedures and adds CI checks to prevent regressions.

Repository already includes strong building blocks:
- Reverse proxy with headers/TLS: `Caddyfile`
- Backend: FastAPI app, JWT, refresh tokens, SlowAPI limiter: `backend/app/main.py`, `backend/app/limits.py`, `backend/app/controllers/auth.py`
- Railway deployment guide with env examples: `railway/README.md`, `railway/.env.*.example`
- Optional field encryption and privacy endpoints: `backend/app/services/crypto.py`, `backend/app/controllers/privacy.py`

This issue completes the hardening plan and verifies it end-to-end.

---

## Acceptance Criteria
- [ ] TLS enforced end-to-end; HSTS enabled with preload candidate after staging soak (no mixed content)
- [ ] HTTP security headers in responses (via Caddy), including:
  - [ ] Strict-Transport-Security (HSTS)
  - [ ] X-Content-Type-Options: nosniff
  - [ ] X-Frame-Options: DENY (API must not be framed)
  - [ ] Referrer-Policy: strict-origin-when-cross-origin (or no-referrer)
  - [ ] Content-Security-Policy suitable for APIs (see below)
- [ ] CORS restricted to explicit origins from environment (no wildcard in prod)
- [ ] JWTs:
  - [ ] Access token TTL set to 15–30 minutes (from env) and enforced
  - [ ] Refresh tokens rotated on use and revocation on logout confirmed
  - [ ] No secrets/tokens logged; Authorization headers redacted in logs
- [ ] Rate limiting:
  - [ ] Redis-backed limits active in staging/prod; health/admin endpoints exempt
  - [ ] Trusted proxy handling validates real client IP
- [ ] Dependency and image scanning:
  - [ ] Backend dependencies scanned (pip-audit)
  - [ ] Container images scanned (Trivy) in CI
  - [ ] CodeQL security analysis enabled
- [ ] Secret hygiene:
  - [ ] All secrets managed via environment only (Railway)
  - [ ] Pre-commit or CI secret scanning (gitleaks) enforced
  - [ ] Rotation procedure documented for SECRET_KEY and third-party credentials
- [ ] Audit logging:
  - [ ] Authentication, consent, and privilege changes logged with request IDs and masked identifiers
  - [ ] Logs avoid PII beyond minimal masked phone and user ID; no OTP/tokens
- [ ] Error monitoring (optional but recommended):
  - [ ] Sentry wired (DSN via env) and sampling configured
  - [ ] PII scrubbing enabled
- [ ] Documentation and runbook updated with checks, procedures, and rollback

---

## Scope of Work

### 1) HTTP Security Headers (Caddy)
- [ ] Update `Caddyfile` headers:
  - [ ] `X-Frame-Options "DENY"` (change from SAMEORIGIN)
  - [ ] Add CSP tailored for API responses, e.g.:
    - `Content-Security-Policy: "default-src 'none'; frame-ancestors 'none'; base-uri 'none'"`  
    Rationale: APIs should not load active content; this hardens responses without impacting clients.
  - [ ] Confirm HSTS present: `Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"`
- [ ] Keep gzip/zstd enabled and upstream timeouts as configured
- [ ] Verify headers applied on all routes including 4xx/5xx

### 2) CORS Lockdown (Backend)
- [ ] Parse `CORS_ORIGINS` env (comma-separated) and apply in `backend/app/main.py` instead of `["*"]`
- [ ] Validate preflight behavior for web/mobile origins in staging/prod
- [ ] Ensure credentials and headers as needed by clients (minimize exposure)

### 3) JWT Hardening
- [ ] Ensure `ACCESS_TOKEN_EXPIRE_MINUTES` default set to 30 (override in env as needed)
- [ ] Confirm refresh token rotation on use and revocation on logout is active
- [ ] Add unit tests for TTL enforcement and refresh rotation
- [ ] Sanitize logging:
  - [ ] Redact Authorization header in any request logs
  - [ ] Ensure errors never include token bodies

### 4) Rate Limiting & Proxy Awareness
- [ ] Enable Redis-backed limiter in staging/prod (ensure `REDIS_URL` set)
- [ ] Implement trusted proxy parsing for real client IP (see related rate-limit issue)
- [ ] Exempt `/healthz` and admin endpoints; enforce per-IP and per-phone OTP throttles

### 5) Dependency and Image Scanning (CI)
- [ ] Add CI steps:
  - [ ] pip-audit for Python deps (non-blocking initially, can gate on CRITICAL later)
  - [ ] Trivy image scans for `docker/Dockerfile.api` (fail on HIGH/CRITICAL once baseline is clean)
  - [ ] CodeQL analysis on backend repository
- [ ] Document remediation workflow (Dependabot + periodic audits)

### 6) Secret Hygiene
- [ ] Ensure all secrets set via environment (Railway), not in code or logs
- [ ] Add secret scan:
  - [ ] Pre-commit hook for local dev (optional) and GitHub Action (gitleaks)
- [ ] Rotation playbooks:
  - [ ] SECRET_KEY rotation (coordinate JWT invalidation/forced re-login)
  - [ ] Twilio credentials rotation
  - [ ] Database and Redis credentials rotation (Railway plugin credentials)

### 7) Audit Logging and PII Minimization
- [ ] Standardize structured logs for auth events, consent, and admin actions:
  - fields: `event`, `user_id`, `request_id`, `method`, masked `phone`, result
- [ ] Confirm consent events recorded via `ConsentAudit` and expand if necessary
- [ ] Ensure phone masking everywhere (already in SMS service); avoid email/phone full prints

### 8) Error Monitoring (Optional, Recommended)
- [ ] Integrate Sentry (DSN via env) with backend
- [ ] Ensure PII scrubbers active (remove Authorization, cookies, bodies where possible)
- [ ] Set environment tags (staging/production) and release markers

### 9) Data-at-Rest Encryption (Optional)
- [ ] If storing sensitive text (journals), set `DATA_ENCRYPTION_KEY` in staging/prod and verify encryption/decryption paths
- [ ] Confirm export/deletion flows operate with encryption enabled

---

## Environment Variables
Ensure these are set appropriately (many already exist in env examples):

Required (prod/staging):
- `SECRET_KEY` — strong random value
- `DATABASE_URL` — Postgres (Railway)
- `REDIS_URL` — Redis (Railway), required for distributed rate limiting
- `CORS_ORIGINS` — explicit list of client origins (no wildcard in prod)
- `ACCESS_TOKEN_EXPIRE_MINUTES` — 15–30 recommended
- `LOG_LEVEL` — `info` (staging), `warn` (prod)

Security/ratelimits:
- `RATELIMIT_TRUSTED_PROXIES` — comma-separated CIDRs for proxies/LBs
- `RATELIMIT_DEFAULT_PER_IP` (optional)
- `RATELIMIT_OTP_REQUEST_PER_IP` (optional)
- `RATELIMIT_OTP_VERIFY_PER_IP` (optional)
- `RATELIMIT_ENABLED` (default true)

Monitoring:
- `SENTRY_DSN` (optional, recommended)

Privacy/consent (from related issue):
- `CONSENT_IP_HASH_SALT` — for one-way IP hashing
- `LEGAL_TOS_VERSION`, `LEGAL_PRIVACY_VERSION`, `LEGAL_PRIVACY_URL`, `LEGAL_TERMS_URL`

OTP:
- `DEV_MODE` — false in production
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_VERIFY_SERVICE_SID` (prod)

Encryption (optional):
- `DATA_ENCRYPTION_KEY` — Fernet key (urlsafe base64)

---

## Tests

Headers & TLS
- [ ] Verify headers on representative endpoints (200/401/404/500) include HSTS, X-Content-Type-Options, X-Frame-Options=DENY, CSP
- [ ] Confirm HSTS preload safe on staging before enabling in prod (no HTTP endpoints required by clients)

CORS
- [ ] Browser preflight from allowed origins succeeds; disallowed origin blocked
- [ ] Verify Authorization-bearing requests allowed only from configured origins

JWT
- [ ] Access token expires at configured TTL (15–30m); protected endpoint returns 401 after expiry
- [ ] Refresh token rotation on use verified; old token cannot be reused (revoked)

Rate limiting
- [ ] Exceed per-IP and per-phone OTP thresholds → 429 (with Retry-After where feasible)
- [ ] Trusted proxy handling returns correct client IP

Scanning (CI)
- [ ] pip-audit runs and reports
- [ ] Trivy image scan runs (fail on HIGH/CRITICAL after baseline)
- [ ] CodeQL completes on PRs

Secrets
- [ ] gitleaks action catches injected test secret in a sample branch (non-prod test)

Logging
- [ ] No Authorization headers or tokens appear in logs (manual grep and CI check)
- [ ] Phone numbers masked

Error monitoring (if enabled)
- [ ] Sentry captures an intentional test exception in staging; PII scrubbed

---

## Tasks

Caddy (headers/TLS)
- [ ] Update `Caddyfile` to set `X-Frame-Options "DENY"` and add CSP for API responses
- [ ] Keep/confirm HSTS configuration; consider `preload` after staging validation

Backend (CORS/JWT/logging)
- [ ] Parse `CORS_ORIGINS` env and apply to CORSMiddleware in `backend/app/main.py` (replace `["*"]`)
- [ ] Set `ACCESS_TOKEN_EXPIRE_MINUTES` default to 30 and ensure read from env
- [ ] Add log redaction for Authorization header; audit logging fields standardized

Rate limiting
- [ ] Ensure Redis-backed limiter active with `REDIS_URL`
- [ ] Implement proxy-aware client IP extraction and per-phone OTP throttles (see rate-limit issue for details)

CI/CD (security scans)
- [ ] Add workflow steps:
  - pip-audit for Python deps
  - Trivy scan for `docker/Dockerfile.api` images
  - CodeQL security analysis for backend
  - gitleaks secret scanning (on PR and push to main)

Monitoring
- [ ] Add Sentry SDK and DSN wiring (optional); enable environment/release tags and PII scrubbing

Docs/Runbook
- [ ] Update `railway/README.md` with security checks, rotation procedures, and monitoring steps
- [ ] Note how to safely enable HSTS preload and rollback if needed

---

## Definition of Done
- [ ] Security headers present and verified on staging and production
- [ ] CORS restricted to explicit origins; preflight validated
- [ ] JWT TTL and refresh rotation verified; no token/secret leakage in logs
- [ ] Redis-backed rate limiting active with proxy-aware client IP; OTP per-phone/IP throttles enforced
- [ ] CI security gates in place (pip-audit, Trivy, CodeQL, gitleaks)
- [ ] Secrets only in environment; rotation procedures documented
- [ ] Audit logging standardized with masked identifiers; consent/auth events captured
- [ ] Error monitoring wired (if adopted) with PII scrubbers
- [ ] Runbook and environment examples updated

---

## References (repository)
- Reverse proxy: `Caddyfile`
- Backend app: `backend/app/main.py`, `backend/app/limits.py`, `backend/app/controllers/auth.py`
- Requirements: `backend/requirements.txt`
- Docker: `docker/Dockerfile.api`
- Deployment: `railway/README.md`, `railway/.env.staging.example`, `railway/.env.production.example`
- Privacy & encryption: `backend/app/controllers/privacy.py`, `backend/app/services/crypto.py`
