#!/usr/bin/env bash
#
# otp.sh — End-to-end OTP login flow against the SOUL API (staging by default).
#
# This script:
#  1) Requests an OTP for a given phone number
#  2) Verifies the OTP (uses preview_code from dev-mode if available, or OTP env var)
#  3) Prints access/refresh tokens and performs a sanity call to a protected endpoint
#
# Requirements:
#   - bash, curl, jq
#
# Usage:
#   # Default staging base and sample phone:
#   BASE=https://api-staging.soulapp.app PHONE=+14155550123 ./otp.sh
#
#   # Provide a custom OTP (e.g., production or Twilio sandbox real code):
#   BASE=https://api-staging.soulapp.app PHONE=+14155550123 OTP=123456 ./otp.sh
#
# Env vars:
#   BASE   Base URL for API (default: https://api-staging.soulapp.app)
#   PHONE  E.164 phone number (e.g., +14155550123). REQUIRED.
#   OTP    One-time passcode to verify. Optional; if not provided and a preview_code
#          is returned (DEV_MODE=true), the script will use that preview code.
#   TIMEOUT Request timeout in seconds (default: 10)
#
set -euo pipefail

BASE="${BASE:-https://api-staging.soulapp.app}"
TIMEOUT="${TIMEOUT:-10}"
PHONE="${PHONE:-}"
OTP_DEFAULT="${OTP:-}" # user-supplied OTP (optional)

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: 'jq' is required but not installed. Please install jq and re-run." >&2
  exit 1
fi

if [[ -z "${PHONE}" ]]; then
  echo "ERROR: PHONE is required (E.164 format like +14155550123)." >&2
  exit 1
fi

info() { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"; }
curl_json() {
  local method="$1" path="$2" data="${3:-}"
  if [[ -n "${data}" ]]; then
    curl -fsS -m "${TIMEOUT}" -X "${method}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      --data "${data}" \
      "${BASE}${path}"
  else
    curl -fsS -m "${TIMEOUT}" -X "${method}" \
      -H "Accept: application/json" \
      "${BASE}${path}"
  fi
}

# 1) Request OTP
info "Requesting OTP for ${PHONE} ..."
REQ_BODY=$(jq -nc --arg phone "${PHONE}" '{phone:$phone}')
REQ_RESP="$(curl_json POST "/api/auth/otp/request" "${REQ_BODY}")"
echo "${REQ_RESP}" | jq .
STATUS=$(echo "${REQ_RESP}" | jq -r '.status // empty')
PREVIEW_CODE=$(echo "${REQ_RESP}" | jq -r '.preview_code // empty')

if [[ -z "${STATUS}" ]]; then
  echo "ERROR: Unexpected response from /api/auth/otp/request" >&2
  exit 1
fi

# Determine OTP to use
OTP_TO_USE="${OTP_DEFAULT}"
if [[ -z "${OTP_TO_USE}" && -n "${PREVIEW_CODE}" ]]; then
  OTP_TO_USE="${PREVIEW_CODE}"
fi

if [[ -z "${OTP_TO_USE}" ]]; then
  info "No OTP provided via OTP env and no preview_code returned. If this is production, set OTP=<code>."
  echo "ERROR: Cannot proceed without an OTP code." >&2
  exit 2
fi

# 2) Verify OTP
info "Verifying OTP for ${PHONE} ..."
VERIFY_BODY=$(jq -nc --arg phone "${PHONE}" --arg otp "${OTP_TO_USE}" '{phone:$phone,otp:$otp}')
VERIFY_RESP="$(curl_json POST "/api/auth/verify-otp" "${VERIFY_BODY}")"
echo "${VERIFY_RESP}" | jq .

ACCESS_TOKEN=$(echo "${VERIFY_RESP}" | jq -r '.access_token // empty')
REFRESH_TOKEN=$(echo "${VERIFY_RESP}" | jq -r '.refresh_token // empty')
USER_ID=$(echo "${VERIFY_RESP}" | jq -r '.user.id // empty')

if [[ -z "${ACCESS_TOKEN}" || -z "${REFRESH_TOKEN}" ]]; then
  echo "ERROR: Missing access_token or refresh_token in verify response." >&2
  exit 3
fi

# Save tokens to a temp file for convenience
TOKENS_FILE="/tmp/soul_tokens_$(date +%s).json"
echo "${VERIFY_RESP}" | jq '{access_token, refresh_token, user}' > "${TOKENS_FILE}"

info "Tokens saved to: ${TOKENS_FILE}"
echo
echo "Export commands (you can copy/paste):"
echo "  export ACCESS=\"${ACCESS_TOKEN}\""
echo "  export REFRESH=\"${REFRESH_TOKEN}\""
if [[ -n "${USER_ID}" ]]; then
  echo "  export USER_ID=\"${USER_ID}\""
fi
echo

# 3) Sanity: Protected endpoint call
info "Calling protected endpoint /api/moods with access token ..."
PROT_RESP="$(curl -fsS -m "${TIMEOUT}" -H "Authorization: Bearer ${ACCESS_TOKEN}" "${BASE}/api/moods")"
echo "${PROT_RESP}" | jq . || echo "${PROT_RESP}"

echo
info "OTP flow complete."
echo "Next steps:"
echo "  - Use REFRESH token with jwt.sh to test rotation and logout."
echo "  - Run ratelimit.sh to validate per-phone throttles (429 behavior)."
echo "  - Run consent.sh to exercise consent endpoints."
