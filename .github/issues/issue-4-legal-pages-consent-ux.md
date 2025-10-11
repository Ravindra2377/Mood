# Legal Pages & Consent Management

Labels: legal, compliance, medium-priority  
Milestone: Production Launch v1.0  
Assignees: @product-lead, @legal-team, @backend-lead, @web-lead, @mobile-lead

## Summary
Implement public legal pages (Terms of Service and Privacy Policy) and a first-login consent experience across web and mobile with a complete backend audit trail. This includes canonical URLs for legal content, a consent-gating screen that blocks app usage until acceptance, versioning and re-consent on policy updates, and a retrievable audit history for compliance.

The repository already contains:
- Privacy controller with export/delete flows and audit logging via `ConsentAudit` (backend/app/controllers/privacy.py and backend/app/models/consent_audit.py).
- Reverse proxy and security headers (Caddyfile).
- Railway runbook and production deployment scaffolding.

This issue adds legal/consent UX, endpoints, migrations, and documentation to make the app production-compliant.

---

## Acceptance Criteria
- [ ] Public legal pages are available at canonical URLs:
  - [ ] Web: `/legal/privacy` and `/legal/terms`
  - [ ] Linked in app footer and within onboarding
- [ ] Consent UX:
  - [ ] On first login, user must accept the current Terms and Privacy to continue
  - [ ] Optional research/data-use consent (opt-in) is presented and recorded
  - [ ] If legal versions change, users are prompted to re-consent before continuing
- [ ] Backend audit:
  - [ ] Each consent action creates an immutable audit record (user_id, consent type, version, timestamp, IP hash, user agent)
  - [ ] A current snapshot of user consent state is queryable per user
  - [ ] Admin or support tooling can retrieve a user’s consent history
- [ ] API endpoints:
  - [ ] `GET /api/consent/current` returns current legal versions and user acceptance state (if authenticated)
  - [ ] `POST /api/consent/submit` records acceptance and research opt-in/out (requires auth)
  - [ ] `GET /api/consent/user/{user_id}` (admin-restricted) fetches user consent history
- [ ] Mobile integration:
  - [ ] Legal pages accessible via in-app Settings → Legal (webview to canonical URLs)
  - [ ] Native consent gate that calls the backend API, identical to web behavior
- [ ] Legal content:
  - [ ] Privacy and Terms include contact info, data rights (export/delete), retention statement, subprocessors (Twilio, Railway, optional Sentry), and last updated date
- [ ] Security and compliance:
  - [ ] Minimal PII in logs, IP hashed in audit entries
  - [ ] CORS and CSP remain compatible with legal routes
  - [ ] Public routes do not leak sensitive data

---

## Scope of Work

### Backend
- [ ] Data model (Alembic migration):
  - [ ] Create `user_consents` table: fields include `user_id`, `tos_version`, `privacy_version`, `research_opt_in` (bool), `accepted_at` (UTC), `ip_hash`, `user_agent`, `consent_version` (composite or semantic version), and indexes on `user_id` and `accepted_at`
  - [ ] Continue to use `consent_audits` for immutable events; create an entry for each acceptance or change (already present model `ConsentAudit` can be reused with suitable `field` values like `tos_accept`, `privacy_accept`, `research_opt_in`)
- [ ] Endpoints (new controller, e.g., `backend/app/controllers/consent.py` or add to `privacy.py`):
  - [ ] `GET /api/consent/current`:
    - Returns the current policy versions (from env or config) and, if authenticated, the user’s latest acceptance state
  - [ ] `POST /api/consent/submit`:
    - Body includes `tos_version`, `privacy_version`, `research_opt_in` (optional), and optional `consent_version`
    - Requires auth; updates `user_consents` snapshot and writes `consent_audits`
    - Captures `ip_hash` from client IP (salted hash) and `user_agent`
  - [ ] `GET /api/consent/user/{user_id}` (admin only):
    - Returns user consent snapshot and audit history
- [ ] Config and settings:
  - [ ] Add to `Settings` (pydantic BaseSettings) the following:
    - `LEGAL_TOS_VERSION` (string)
    - `LEGAL_PRIVACY_VERSION` (string)
    - `LEGAL_RESEARCH_CONSENT_VERSION` (optional string)
    - `LEGAL_PRIVACY_URL` and `LEGAL_TERMS_URL` (canonical absolute URLs; exposed to clients)
    - `CONSENT_IP_HASH_SALT` (secret used to hash IP addresses)
- [ ] Security:
  - [ ] Hash IP addresses using a one-way hash: `hash(salt + ip)`; store only the hash
  - [ ] Ensure endpoints are rate-limited appropriately (reuse SlowAPI where applicable)
  - [ ] Avoid logging consent payloads or PII; log only event type and user id
- [ ] Health and docs:
  - [ ] Update backend README or API docs with the new endpoints and payloads

### Web (web-app)
- [ ] Pages:
  - [ ] Implement `/legal/privacy` and `/legal/terms` as static React routes using canonical content
  - [ ] Footer links to both pages; ensure crawlable and no auth required
- [ ] Consent gate:
  - [ ] After authentication, call `GET /api/consent/current`
  - [ ] If user has not accepted the current versions, show a blocking modal/screen:
    - Required checkboxes for Terms and Privacy
    - Optional toggle for research consent
    - “I agree” submits to `POST /api/consent/submit` then continues to app
  - [ ] Persist state locally to avoid flicker; ensure server is source of truth on reload

### Mobile (Android/iOS)
- [ ] Legal:
  - [ ] Settings → Legal → open webview to `LEGAL_PRIVACY_URL` and `LEGAL_TERMS_URL`
- [ ] Consent gate:
  - [ ] On first auth or app foreground after token acquisition, call `GET /api/consent/current`
  - [ ] If not accepted, present native consent screen mirroring web behavior and call `POST /api/consent/submit`
  - [ ] Store acceptance state locally for UX; server remains source of truth
- [ ] Error handling and offline:
  - [ ] Gracefully handle offline; block core flows until consent completes when back online

### Legal Content Requirements
- [ ] Terms of Service and Privacy Policy must include:
  - [ ] Organization name and contact details
  - [ ] Data rights: export and delete pathways (map to `/api/privacy/export` and `/api/privacy/delete`)
  - [ ] Data retention and deletion policy
  - [ ] Subprocessors list: Twilio (SMS), Railway (hosting), Redis/Postgres (infra), Sentry (if enabled)
  - [ ] Last updated date and version identifiers matching `LEGAL_*_VERSION`
- [ ] Coordinate with counsel for final copy approval

### Environment Variables
- [ ] Add and set in staging/production:
  - `LEGAL_TOS_VERSION`
  - `LEGAL_PRIVACY_VERSION`
  - `LEGAL_RESEARCH_CONSENT_VERSION` (optional)
  - `LEGAL_PRIVACY_URL` (e.g., https://app.soulapp.app/legal/privacy)
  - `LEGAL_TERMS_URL` (e.g., https://app.soulapp.app/legal/terms)
  - `CONSENT_IP_HASH_SALT` (strong, secret value; rotate cautiously)

---

## Testing Plan

### Unit
- [ ] IP hash function returns deterministic, non-reversible strings; different salts yield different hashes
- [ ] Consent model validations (required vs optional fields, version format)

### Integration (backend)
- [ ] `GET /api/consent/current` returns correct versions and user state (authed vs unauth)
- [ ] `POST /api/consent/submit`:
  - [ ] With valid payload updates snapshot and creates audit entries
  - [ ] Missing required fields → 400
  - [ ] Auth required → 401
- [ ] Admin fetch of user history returns snapshot and audit list with redacted IP (hash only)

### Web E2E
- [ ] New user first login triggers consent modal; acceptance proceeds to app
- [ ] Returning user with outdated consent sees re-consent flow
- [ ] Legal pages render and are publicly accessible

### Mobile E2E
- [ ] After OTP login, consent gate blocks until accepted
- [ ] Webview/legal links accessible from Settings
- [ ] Offline behavior: cannot proceed until consent successfully submitted

---

## Rollout
- [ ] Staging:
  - [ ] Publish legal content and set `LEGAL_*_VERSION` values
  - [ ] Test first-login consent flow end-to-end on web and mobile
- [ ] Production:
  - [ ] Promote after staging sign-off
  - [ ] Monitor logs for consent submissions and errors
  - [ ] Keep counsel-approved content in sync

---

## Definition of Done
- [ ] Legal pages live at canonical URLs and linked within the app
- [ ] Consent gating enforced on first login and on policy version changes (web and mobile)
- [ ] Backend persists snapshot and audit records; admin can retrieve history
- [ ] Environment variables configured in staging and production
- [ ] Tests passing (unit, integration, E2E) and smoke tests complete
- [ ] Documentation updated (API endpoints, runbook notes, and legal links)

---

## References (repository)
- Backend privacy controller and audit model: `backend/app/controllers/privacy.py`, `backend/app/models/consent_audit.py`
- API app entry and middleware: `backend/app/main.py`
- Reverse proxy and headers: `Caddyfile`
- Deployment runbook: `railway/README.md`
- Web app scaffold: `web-app/` (create routes for `/legal/privacy` and `/legal/terms`)