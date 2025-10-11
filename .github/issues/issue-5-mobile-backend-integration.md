# Mobile Apps — Backend Integration

Labels: mobile, integration, high-priority  
Milestone: Production Launch v1.0  
Assignees: @android-lead, @ios-lead, @qa-lead

## Summary
Wire Android and iOS apps to the SOUL backend for authentication (OTP), token lifecycle (access/refresh), and API usage (e.g., moods). Implement robust networking, secure token storage, rate-limit/error handling, and environment switching for staging/production.

Current backend endpoints exist:
- POST /api/auth/otp/request
- POST /api/auth/verify-otp
- POST /api/auth/refresh
- POST /api/auth/logout
- GET/POST /api/moods (and other feature endpoints)
- GET /healthz

Canonical domains (per repo config):
- Staging: https://api-staging.soulapp.app
- Production: https://api.soulapp.app

Repo references:
- Backend: backend/app/controllers/auth.py, backend/app/main.py, backend/app/limits.py
- Infra: Caddyfile, railway/README.md
- iOS: ios-app/APIClient.swift, ios-app/KeychainTokenProvider.swift, ios-app/SyncManager.swift
- Android: android-app/ (scaffold present; add Retrofit/OkHttp wiring)

---

## Acceptance Criteria
- Base URL switching:
  - Android: build flavors (staging, production) with correct API base URL.
  - iOS: build configurations/schemes for staging/production with correct base URL.
- OTP auth:
  - Send E.164 phone to POST /api/auth/otp/request.
  - Verify with POST /api/auth/verify-otp to receive tokens and minimal user object.
  - In staging with DEV_MODE=true, preview code 123456 is accepted.
- Token lifecycle:
  - Store access/refresh securely (Keychain/EncryptedSharedPreferences).
  - Attach Bearer access token on API calls.
  - On 401, perform one automatic refresh via POST /api/auth/refresh (body: {"old_refresh_token": "<token>"}), retry original request once, then logout on failure.
- Error and rate-limit handling:
  - 429 shows a user-friendly message and respects Retry-After if present; apply local cooldown to OTP resend.
  - Distinguish invalid OTP (400) vs server errors (5xx).
- Networking:
  - Timeouts: connect 5s, read 10s; limited retries for idempotent requests (no retry for OTP posts).
  - Exponential backoff for transient network failures; offline mode awareness.
- Phone formatting:
  - Use E.164 format consistently (libphonenumber/PhoneNumberKit). Validate before requests and surface helpful errors.
- QA validation:
  - Full E2E on real devices for staging and production; slow network and airplane mode scenarios; rate-limit behavior verified.

---

## Environments and Base URLs
- Staging: https://api-staging.soulapp.app
- Production: https://api.soulapp.app

Android:
- Define productFlavors: staging, production; expose BASE_URL via BuildConfig.
- Store Twilio testing notes (staging may use preview OTP 123456).

iOS:
- Define configurations: Staging, Release; set BASE_URL via xcconfig or build settings.

---

## API Contracts (reference)
1) Request OTP
- POST /api/auth/otp/request
- Body: {"phone": "+14155550123"}
- 200: {"status": "ok"}; in staging dev mode: {"status":"ok","preview_code":"123456"}
- 400: {"detail": "phone required"} or {"detail": "Invalid phone number"}
- 500: {"detail": "Failed to send verification code"}

2) Verify OTP
- POST /api/auth/verify-otp
- Body: {"phone": "+14155550123", "otp": "123456"}
- 200: { "access_token":"...", "token_type":"bearer", "refresh_token":"...", "user": { "id": 1, "email": "<phone>@example.com" } }
- 400: {"detail": "phone and otp required"} | {"detail": "Invalid phone number"} | {"detail": "Invalid OTP"}
- 500: {"detail": "Failed to verify code"}

3) Refresh token
- POST /api/auth/refresh
- Body: {"old_refresh_token": "<refresh>"}
- 200: {"access_token":"...", "refresh_token":"..."}
- 401: {"detail":"Invalid refresh token"}

4) Logout (best-effort)
- POST /api/auth/logout
- Body: {"refresh_token": "<refresh>"}
- 200: {"status":"ok"}

5) Example protected resource
- GET /api/moods with Authorization: Bearer <access_token>

---

## Android Implementation Plan
- Dependencies:
  - OkHttp, Retrofit, Moshi/Gson
  - libphonenumber for E.164 (com.googlecode.libphonenumber:libphonenumber)
  - EncryptedSharedPreferences (androidx.security:security-crypto)
- Build flavors:
  - staging: BASE_URL="https://api-staging.soulapp.app"
  - production: BASE_URL="https://api.soulapp.app"
- Token store:
  - Save access token (memory + encrypted prefs) and refresh token (encrypted prefs).
  - Provide getAccess(), getRefresh(), setTokens(), clear().
- Interceptor chain:
  - AuthInterceptor adds Authorization header if token present.
  - NetworkInterceptor inspects 401; trigger refresh flow once, retry original request once.
- OTP client:
  - requestOtp(phoneE164)
  - verifyOtp(phoneE164, code) -> persist tokens on success
  - Apply resend cooldown timers; show errors for invalid phone/code; show friendly 429 cooldown.
- Networking:
  - OkHttp timeouts connect=5s, read=10s; retry on connection failures for GET only.
- Offline handling:
  - Detect no connectivity; surface message; queue idempotent uploads as needed.

Deliverables (Android):
- Retrofit interface(s) for auth and moods.
- TokenRepository with EncryptedSharedPreferences.
- AuthInterceptor + Refresh logic.
- UI: OTP screen with resend and error states.
- Minimal consumption of protected endpoint (e.g., GET /api/moods) to validate auth path.

---

## iOS Implementation Plan
- Leverage existing:
  - ios-app/APIClient.swift (Combine-based requests)
  - ios-app/KeychainTokenProvider.swift (secure storage)
  - ios-app/SyncManager.swift (integration point)
- Add:
  - OTP API calls and simple view(s) to request and verify OTP.
  - TokenProvider to include refresh flow (if not already complete): on 401, call /api/auth/refresh with old_refresh_token, then retry once.
- Base URL:
  - Use build configuration or Info.plist key for BASE_URL (Staging vs Production).
- Phone formatting:
  - Prefer PhoneNumberKit or pass already-normalized user input; validate E.164 client-side.
- Networking:
  - URLSession timeouts: 5s connect-equivalent (via timeoutIntervalForRequest=10 and sensible resource timeout).
  - Retry idempotent GETs; avoid retry for OTP POSTs.
- Rate-limit UX:
  - Handle 429; parse Retry-After (if present); display cooldown timer on OTP resend.

Deliverables (iOS):
- OTPRequest and OTPVerify functions in API layer.
- TokenProvider refresh implementation that returns new tokens to APIClient.
- OTP UI flow integrated before accessing protected features.
- Protected endpoint call (e.g., upload mood) verified with valid Bearer token.

---

## Error Handling & UX
- 400 invalid phone/code: display precise input guidance; do not reveal internal details.
- 401 on protected endpoints:
  - Auto-refresh once, retry once; on failure, logout and show session expired.
- 429 rate limit:
  - Show message like “Too many attempts. Please try again in a moment.”
  - If Retry-After header exists, use it for a countdown.
- 5xx server errors: graceful message; encourage retry later.
- Offline: detect and show offline banner; queue non-critical operations where safe.

---

## Security
- Token storage:
  - Android: EncryptedSharedPreferences for refresh; in-memory + encrypted for access.
  - iOS: Keychain for refresh; ephemeral memory for access.
- Do not log tokens, OTP codes, or phone numbers in full; mask values where logged.
- Use HTTPS-only endpoints; reject cleartext.
- Validate phone as E.164 before sending; never attempt to “fix” silently.

---

## Testing Plan
Staging (DEV_MODE=true default; OTP preview code 123456):
- OTP flow:
  - Request OTP → preview_code available in response.
  - Verify OTP → tokens stored; protected GET /api/moods succeeds.
- Token refresh:
  - Invalidate access token (manually shorten TTL or simulate) → refresh path invoked → original request retried.
- Rate limits:
  - Exceed OTP request threshold quickly → 429 appears; UI displays cooldown.
- Network:
  - Airplane mode, recover → retry behavior; offline messaging.
  - Slow network profile; confirm timeouts and UX messaging.

Production:
- Real device and number:
  - Receive SMS; verify OTP; tokens stored; protected requests succeed.
- Negative cases:
  - Wrong code → 400 surfaced correctly.
  - 429 from backend → handled with cooldown.

Device matrix:
- Android: min supported SDK to latest; a mid-tier and a low-memory device.
- iOS: latest major iOS - 1 version; at least one older device.

Analytics (optional):
- Track funnel: otp_request → otp_verify → first_protected_call.

---

## Tasks

Android
- [ ] Add libphonenumber and E.164 validation utility.
- [ ] Implement Retrofit service(s): AuthService (otpRequest, verifyOtp, refresh, logout), MoodsService.
- [ ] Implement TokenRepository with EncryptedSharedPreferences.
- [ ] Implement AuthInterceptor and refresh-on-401 retry (single attempt).
- [ ] Build flavors and BASE_URL wiring (staging/production).
- [ ] OTP UI (request, verify, resend cooldown, error states).
- [ ] Protected call demo (GET /api/moods).
- [ ] Unit tests: token repo; refresh interceptor; phone validation.
- [ ] Instrumentation/E2E: OTP flow on staging and production.

iOS
- [ ] Add OTP APIs to APIClient layer (request, verify).
- [ ] Ensure KeychainTokenProvider supports refresh flow; integrate with APIClient.refreshPublisher.
- [ ] Configure BASE_URL per configuration (Staging/Production).
- [ ] OTP UI flow and consent to continue using app after verify.
- [ ] Protected call demo (upload or fetch moods).
- [ ] Unit tests: token refresh path; API error mapping; phone validation helpers.
- [ ] E2E on devices for staging and production.

QA
- [ ] Create test cases for OTP, refresh, rate-limit, offline, and error mapping.
- [ ] Execute matrix runs; capture logs and screenshots.
- [ ] Sign-off criteria met for both platforms.

---

## Definition of Done
- Android and iOS apps authenticate against staging and production backends with OTP.
- Secure token storage implemented; automatic refresh on 401 with single retry.
- Rate-limit (429), offline, and error states gracefully handled.
- Base URL switching via build config; environments documented.
- E2E tests pass on staging and production devices.
- Documentation updated in platform READMEs (Android/iOS) with setup steps and troubleshooting.

---

## References
- Backend endpoints and behavior: backend/app/controllers/auth.py, backend/app/main.py
- Rate limiting and 429 behavior: backend/app/limits.py
- Infra/domains: Caddyfile, railway/README.md
- iOS API scaffolding: ios-app/APIClient.swift, ios-app/KeychainTokenProvider.swift
- Android project scaffold: android-app/