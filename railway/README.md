# SOUL API — Railway Deployment Guide & Runbook

This guide describes how to deploy and operate the SOUL backend stack on Railway with a production-ready configuration.

Stack overview:
- Caddy reverse proxy (TLS, security headers)
- FastAPI app (Gunicorn + Uvicorn workers)
- PostgreSQL (primary database)
- Redis (rate limiting and future caching)
- Railway auto-build from GitHub (staging → production)

Environments:
- Staging: api-staging.soulapp.app
- Production: api.soulapp.app

Repository references:
- backend/app/gunicorn_conf.py
- backend/app/main.py (includes /healthz endpoint)
- docker/Dockerfile.api
- docker/Dockerfile.caddy
- docker-compose.prod.yml
- Caddyfile

Note on CI: This setup uses Railway’s GitHub auto-builds. You can add a CI build pipeline later (e.g., GH Actions + GHCR) if desired.


## 1) Architecture

High-level flow (left to right):

[ Clients ] → [ Caddy (TLS, HSTS, security headers) ] → [ SOUL API (Gunicorn/Uvicorn) ] → [ PostgreSQL ]
                                                                  └──────────→ [ Redis (limiter) ]

- Caddy terminates TLS and proxies HTTP to the API service.
- API uses Redis for SlowAPI rate limiting (in-memory fallback if REDIS_URL is not set).
- Alembic migrations are run during deploy/startup (recommended).


## 2) Prerequisites

- Railway account connected to your GitHub repository
- DNS control for soulapp.app (or your chosen domain)
- Twilio Verify credentials (for SMS OTP): Account SID, Auth Token, Verify Service SID
- Secrets for production (see Environment Variables section)
- Optional: staging Twilio/account or DEV_MODE=true for staging


## 3) Repository layout and key files

- backend/app/gunicorn_conf.py
  - Tuned Gunicorn config (workers, timeouts, JSON-ish access logs, proxy awareness)
- backend/app/main.py
  - FastAPI app with /healthz
  - Rate limiter initialization via app.limits
  - CORS currently permissive by default; configure properly for production
- docker/Dockerfile.api
  - Multi-stage build, non-root runtime user, installs pinned requirements
- docker/Dockerfile.caddy
  - Minimal reverse proxy image consuming the Caddyfile
- Caddyfile
  - Domains: api-staging.soulapp.app, api.soulapp.app
  - HSTS + headers, gzip/zstd, reverse_proxy api:8000
- docker-compose.prod.yml
  - Production-parity dev stack (API, Caddy, PostgreSQL, Redis)
  - Includes migrations and healthchecks


## 4) Environment variables (API service)

Set in Railway (staging and production):

Required
- SECRET_KEY: Strong random value (e.g., 32+ chars)
- DATABASE_URL: Provided by Railway Postgres plugin (format postgresql+psycopg2://...)
- REDIS_URL: Provided by Railway Redis plugin (redis://.../0)
- CORS_ORIGINS: Comma-separated allowed origins (e.g., https://api-staging.soulapp.app,https://api.soulapp.app)
- DEV_MODE: false (set true for staging if you want dev OTP fallback)

Twilio (production)
- TWILIO_ACCOUNT_SID
- TWILIO_AUTH_TOKEN
- TWILIO_VERIFY_SERVICE_SID

Optional (Gunicorn)
- PORT (default 8000)
- GUNICORN_* overrides (workers, timeouts, etc.)

Note: Never commit secrets to the repository; manage them in Railway environment settings.


## 5) Railway setup

A. Create project and services
1) Create a Railway project and connect it to your GitHub repo.
2) Add Postgres plugin:
   - Railway will generate a DATABASE_URL. Copy it into the API service environment.
3) Add Redis plugin:
   - Copy its URL into REDIS_URL for the API.
4) Add a service “api” from GitHub:
   - Use the Dockerfile at docker/Dockerfile.api
   - Start command:
     - Either rely on Docker CMD (gunicorn -c app/gunicorn_conf.py app.main:app)
     - Or prepend migrations: python -m alembic upgrade head && gunicorn -c app/gunicorn_conf.py app.main:app
5) Add a service “caddy” from GitHub:
   - Use docker/Dockerfile.caddy
   - Ensure the root-level Caddyfile is included in your build context.

B. Set environment variables (API)
- Set the variables from Section 4 for staging and production environments.
- For staging, you may set DEV_MODE=true to enable OTP preview code for testing.

C. Deploy staging
- Enable auto-deploy on push to main (or a staging branch).
- Verify /healthz returns: {"status":"ok","db":true/false,"redis":true/false}
- Run smoke tests (see Section 8).

D. Add custom domains (Caddy)
1) In Railway, set custom domains:
   - Staging: api-staging.soulapp.app
   - Production: api.soulapp.app
2) Configure DNS:
   - Point CNAME to Railway domain target provided by Railway.
   - Wait for validation; Railway will provision certificates.
3) Caddy will auto-serve TLS for those domains once they resolve.

E. Promote to production
- After staging passes smoke tests, promote to production.
- Verify /healthz and application flows.


## 6) Migrations

Recommended approaches:
- One-off migration job in Railway before starting the new app version:
  - Command: python -m alembic upgrade head
- Inline migration + start (as in docker-compose.prod.yml):
  - python -m alembic upgrade head && gunicorn -c app/gunicorn_conf.py app.main:app

Always run migrations first on staging and verify application behavior before promoting to production.


## 7) CORS configuration

In production, restrict to your allowed origins:
- Set CORS_ORIGINS= https://api-staging.soulapp.app,https://api.soulapp.app
- Ensure the app respects this setting (code currently allows all; adjust if needed to parse and set allow_origins explicitly from env).
- Frontend/mobile must point to these domains.


## 8) Smoke tests (manual)

Once deployed:
- Health
  - curl -sS https://api-staging.soulapp.app/healthz
- Auth (OTP dev mode on staging)
  - Request OTP (returns preview_code in dev): POST /api/auth/otp/request {"phone":"+14155550123"}
  - Verify OTP: POST /api/auth/verify-otp {"phone":"+14155550123","otp":"123456"}
- Login (email flow): POST /api/auth/login {"email":"you@example.com","password":"..."}
- Moods
  - GET /api/moods with Authorization: Bearer {token}
  - POST /api/moods with Authorization and payload
- Rate limits
  - Exceed per-endpoint limits and confirm 429 with “Too Many Requests”


## 9) Runbook: Day-2 ops

Scaling
- Adjust Railway service size and min/max replicas for API and Caddy.
- Gunicorn workers influenced by CPU; tune GUNICORN_WORKERS and timeouts carefully.

Logs
- View logs per service in Railway.
- API logs use JSON-like access log lines for easier parsing.

Monitoring & Alerts
- Add external uptime checks (e.g., /healthz).
- Create alerts on 5xx rate, error spikes, and memory/cpu saturation.

Backups & DR
- Use Railway Postgres backup features or schedule external backups.
- For DR: document restore procedure; rehearse staging restores.
- Rollback strategy: redeploy previous image (Railway retains history), confirm migrations compatibility.

Security
- Keep DEV_MODE=false in production.
- Rotate SECRET_KEY and Twilio credentials periodically (coordinate token invalidation).
- Restrict CORS, sanitize logs, ensure PII is minimized in logs.

Redis considerations
- If REDIS_URL is unset, limiter uses in-memory storage (non-distributed).
- For horizontal scaling, ensure REDIS_URL is set in all environments.

Cost optimization
- Use smaller plan sizes on staging and enable autosleep (if acceptable for your workflow).
- Apply reasonable rate limits to reduce SMS costs and abusive traffic.


## 10) Troubleshooting

Domain doesn’t resolve / TLS invalid
- Confirm DNS CNAME points at Railway’s domain target and has propagated.
- Wait for certificate provisioning; check Railway domain status.

API returns 500 after deploy
- Check logs for migrations failing or bad env vars.
- Ensure DATABASE_URL and SECRET_KEY are set.
- Validate Twilio credentials if OTP endpoints are failing (or set DEV_MODE=true in staging).

Rate limiting not working
- Confirm REDIS_URL is set for production (shared rate limits across replicas).
- Check that limiter decorators are applied on the key auth endpoints.

CORS blocked in browser
- Ensure CORS_ORIGINS includes your frontend origins exactly (scheme + host + port).
- Verify code is parsing and applying these origins; avoid wildcard in production.

Healthz reports db=false
- Confirm Postgres plugin is healthy.
- Check DATABASE_URL env and that migrations ran successfully.


## 11) Launch checklist

- [ ] Staging environment deployed and smoke-tested (OTP, login, moods)
- [ ] Security: DEV_MODE=false on production; CORS restricted; SECRET_KEY set
- [ ] Twilio configured on production; dev fallback only on staging
- [ ] Alembic migrations run successfully
- [ ] Health checks passing consistently
- [ ] Rate limiting enforced (verified)
- [ ] DNS + TLS active on both domains
- [ ] Backups configured; rollback plan documented
- [ ] Logs verified; error tracking enabled (optional)
- [ ] Mobile apps configured to use production API domain


## 12) Appendix: useful commands

Local run (production-parity with docker-compose)
- docker compose -f docker-compose.prod.yml up --build
- API: http://localhost:8000 (proxied by Caddy if you include it locally with valid TLS only in prod)

Quick curl checks
- Health: curl -sS https://api-staging.soulapp.app/healthz
- OTP request (dev mode): curl -X POST https://api-staging.soulapp.app/api/auth/otp/request -H "Content-Type: application/json" -d "{\"phone\":\"+14155550123\"}"
- OTP verify (dev mode): curl -X POST https://api-staging.soulapp.app/api/auth/verify-otp -H "Content-Type: application/json" -d "{\"phone\":\"+14155550123\",\"otp\":\"123456\"}"

Load testing (example targets)
- Focus: /api/auth/login, /api/moods (read/write), concurrency around your expected peak
- Track p95 latency, 5xx error rate, DB connection pool utilization


---

With this setup, your SOUL app can be safely deployed to staging, validated, and promoted to production. The stack is designed for security (TLS, headers, minimal images), resilience (rate limiting, health checks), and scalability (Railway-managed infra with Redis-backed limiter).

If you add GH Actions later, you can switch to a registry-driven promotion model without changing your application architecture.