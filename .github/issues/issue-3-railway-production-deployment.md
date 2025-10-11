# Railway Production Deployment Infrastructure

Labels: infrastructure, deployment, high-priority  
Milestone: Production Launch v1.0  
Assignees: @infra-lead

## Summary

Stand up production-grade deployments of the SOUL backend on Railway with a Caddy TLS reverse proxy in front of a FastAPI (Gunicorn/Uvicorn) service, backed by PostgreSQL and Redis. This issue covers environment setup (staging + production), domain/DNS configuration, container build/run settings, health checks, observability, security hardening, smoke tests, and rollback.

Repo already includes key artifacts:
- Reverse proxy: `Caddyfile`, `docker/Dockerfile.caddy`
- API service: `docker/Dockerfile.api`, `backend/app/gunicorn_conf.py`, `backend/app/main.py` (includes `/healthz`)
- Production-parity stack: `docker-compose.prod.yml`
- Runbook: `railway/README.md`
- Env examples: `railway/.env.staging.example`, `railway/.env.production.example`


---

## Target Architecture

```
[ Internet ] → [ Caddy (TLS + Security Headers) ] → [ FastAPI (Gunicorn/Uvicorn) ]
                                                     ├─→ [ PostgreSQL ]
                                                     └─→ [ Redis (rate limiting) ]
```

- Caddy terminates TLS and proxies to API (`api:8000` in container network).
- API connects to Railway-managed PostgreSQL and Redis.
- Redis is used for SlowAPI rate limiting (distributed); falls back to in-memory if not set.


---

## Acceptance Criteria

- [ ] Two Railway environments: staging and production (separate projects or isolated environments).
- [ ] Services:
  - [ ] API service built from `docker/Dockerfile.api`.
  - [ ] Caddy service built from `docker/Dockerfile.caddy` (or official image + mounted `Caddyfile`).
- [ ] Railway Postgres and Redis plugins attached; API uses their URLs via env vars.
- [ ] Domains configured and validated:
  - [ ] Staging: `api-staging.soulapp.app`
  - [ ] Production: `api.soulapp.app`
- [ ] TLS auto-provisioned; Caddy serves both domains with HSTS and security headers.
- [ ] API health endpoint returns 200 on `/healthz` in staging and production.
- [ ] CORS restricted to known client origins (no wildcard in production).
- [ ] Secrets are provided via Railway environment and not committed to the repo.
- [ ] Backups enabled for PostgreSQL; restore procedure documented.
- [ ] Rollback plan documented and tested (re-deploy previous image).
- [ ] Smoke tests pass on staging and production.


---

## Environment Variables

Set in Railway for each environment. See `railway/.env.staging.example` and `railway/.env.production.example` for full examples.

Required (both staging and production):
- `SECRET_KEY` — strong random secret (32+ chars).
- `DATABASE_URL` — Railway Postgres URL (format: `postgresql+psycopg2://...`).
- `REDIS_URL` — Railway Redis URL (format: `redis://.../0`) to enable distributed rate limits.
- `CORS_ORIGINS` — comma-separated allowed origins (no wildcard in prod).
- `ACCESS_TOKEN_EXPIRE_MINUTES` — 15–30 recommended.
- `PORT` — 8000 (API inside container).
- Optional: `SENTRY_DSN`, `LOG_LEVEL` (`info` for staging, `warn` for prod), email settings.

Staging-specific:
- `DEV_MODE=true` (enables OTP preview code and other dev conveniences by default).
- Domains reflect staging hostnames in CORS.

Production-specific:
- `DEV_MODE=false` (mandatory).
- Twilio credentials present and valid for real OTP:
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_VERIFY_SERVICE_SID`


---

## Infrastructure Tasks

1) Staging Project
- [ ] Create Railway project: “soul-staging”.
- [ ] Add Postgres plugin; copy the generated `DATABASE_URL` into API env.
- [ ] Add Redis plugin; copy `REDIS_URL` into API env.
- [ ] Add API service from GitHub:
  - [ ] Build using `docker/Dockerfile.api`.
  - [ ] Start command:
    - Option A (inline migrations): `python -m alembic upgrade head && gunicorn -c app/gunicorn_conf.py app.main:app`
    - Option B (separate job): run Alembic as a one-off job before deploy, then default CMD.
- [ ] Add Caddy service from GitHub:
  - [ ] Build using `docker/Dockerfile.caddy` (ensures repo `Caddyfile` is in place).
- [ ] Configure environment variables per `railway/.env.staging.example`.
- [ ] Add custom domain `api-staging.soulapp.app`; set DNS CNAME to Railway target and validate.
- [ ] Verify TLS is provisioned and live.

2) Production Project
- [ ] Create Railway project: “soul-production”.
- [ ] Repeat plugin setup (Postgres, Redis) and services (API, Caddy).
- [ ] Configure environment variables per `railway/.env.production.example` (ensure `DEV_MODE=false`).
- [ ] Add custom domain `api.soulapp.app`; configure DNS and validate TLS.

3) Health and Scaling
- [ ] Confirm `/healthz` returns 200 (includes DB/Redis flags).
- [ ] Set min/max instances and appropriate service size (CPU/memory) for API and Caddy.
- [ ] Tune Gunicorn via env overrides if needed (`GUNICORN_WORKERS`, `GUNICORN_TIMEOUT`, `GUNICORN_KEEPALIVE`).

4) Backups and Rollback
- [ ] Enable PostgreSQL backups (Railway or external).
- [ ] Document restore steps and test on staging.
- [ ] Rollback plan: re-deploy previously successful image; note DB migration compatibility strategy.

5) Observability and Alerts
- [ ] Verify logs reachable for API and Caddy.
- [ ] Optionally set `SENTRY_DSN` in staging/prod and confirm error capture.
- [ ] Add external uptime checks for `/healthz` (staging and prod).
- [ ] Define alerts for elevated 5xx rates and error spikes.


---

## Caddy Configuration

- Uses the repo `Caddyfile`:
  - Serves `api-staging.soulapp.app` and `api.soulapp.app`.
  - Adds security headers (HSTS, X-Content-Type-Options, X-Frame-Options).
  - Forwards `X-Forwarded-Proto`, `X-Forwarded-For`, `X-Forwarded-Host` to API.
  - Enables `gzip`/`zstd` and reasonable upstream timeouts.
- Confirm the upstream matches the API service address in Railway’s internal network.
- Verify HTTP/2 and automatic HTTPS are active.


---

## Docker Requirements (API)

- Multi-stage build (`docker/Dockerfile.api`) with minimal runtime image.
- Non-root user for app process (present in Dockerfile).
- Gunicorn with Uvicorn workers (config in `backend/app/gunicorn_conf.py`).
- Health endpoint `/healthz` used by platform checks and external monitors.
- Migrations run before app is started (inline or separate job).


---

## Security Hardening

- [ ] Enforce TLS via Caddy; enable HSTS (already in `Caddyfile`).
- [ ] CORS lockdown to known origins; no wildcard in production.
- [ ] Secrets provided only via Railway environment (never in repo or logs).
- [ ] Keep `DEV_MODE=false` in production.
- [ ] Ensure Redis URL is set in production for distributed rate limiting.
- [ ] Consider CSP updates if/when serving a web app from same proxy.


---

## Smoke Tests

Run after each deploy (staging first):

- Health:
  - [ ] `GET https://api-staging.soulapp.app/healthz` returns 200 and JSON with `"status": "ok"`.
- Auth (staging, `DEV_MODE=true`):
  - [ ] `POST /api/auth/otp/request` with test phone returns `{status:"ok", preview_code:"123456"}`.
  - [ ] `POST /api/auth/verify-otp` with preview code returns access + refresh tokens.
  - [ ] `GET /api/moods` with Bearer token returns 200 (or empty list if no data).
- CORS:
  - [ ] Preflight passes for expected client origins; browser requests succeed.
- Rate limiting:
  - [ ] Exceed OTP request limits briefly and confirm 429 with “Too Many Requests”.

Repeat on production with real Twilio SMS (ensure `DEV_MODE=false`).


---

## Rollback

- [ ] Use Railway deploy history to redeploy the last known-good image for API and Caddy.
- [ ] If a DB migration is incompatible, either:
  - [ ] Run down migration, or
  - [ ] Keep new code paths behind flags and disable them until forward migration is corrected.
- [ ] Communicate status if user-impacting (status page / incident notes).


---

## Testing & Verification

- [ ] Staging: Soak for at least 24 hours without critical errors.
- [ ] Verify logs show masked sensitive values and no secrets.
- [ ] Confirm Redis-backed rate limits apply (issue #2 owns limit policy; this issue validates infra wiring).
- [ ] Validate backup snapshot exists and is restorable (on staging).


---

## Definition of Done

- [ ] Staging and production environments operational on Railway with TLS and domains.
- [ ] API and Caddy services healthy; `/healthz` returns 200 consistently.
- [ ] Env vars configured per environment; secrets rotated and stored only in Railway.
- [ ] Redis-backed rate limiting enabled in production (Redis URL set).
- [ ] CORS restricted to intended origins.
- [ ] Backups enabled; rollback documented and tested.
- [ ] Smoke tests pass in staging and production.
- [ ] Runbook updated with any changes discovered during setup (`railway/README.md`).


---

## References

- Reverse proxy: `Caddyfile`, `docker/Dockerfile.caddy`
- API service: `docker/Dockerfile.api`, `backend/app/gunicorn_conf.py`, `backend/app/main.py`
- Production-parity compose: `docker-compose.prod.yml`
- Deployment guide: `railway/README.md`
- Env examples: `railway/.env.staging.example`, `railway/.env.production.example`
- Rate limiting setup: `backend/app/limits.py` (integrates SlowAPI; Redis via `REDIS_URL`)