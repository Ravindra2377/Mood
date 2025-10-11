#!/usr/bin/env bash
#
# jwt.sh — Test refresh token rotation and logout behavior for the SOUL API.
#
# Steps:
#   1) Exchanges REFRESH for new access/refresh tokens via /api/auth/refresh
#   2) Verifies the old REFRESH can no longer be used (expects 401)
#   3) Calls a protected endpoint using the new ACCESS token
#   4) Logs out to revoke the new refresh token via /api/auth/logout
#   5) Verifies the revoked (new) refresh token can no longer be used (expects 401)
#
# Requirements:
#   - bash, curl, jq
#
# Usage:
#   BASE=https://api-staging.soulapp.app ACCESS=<access_from_otp> REFRESH=<refresh_from_otp> ./jwt.sh
#
# Env vars:
#   BASE            Base URL for the API (default: https://api-staging.soulapp.app)
#   ACCESS          Current access token (required; from otp.sh)
#   REFRESH         Current refresh token (required; from otp.sh)
#   PROTECTED_PATH  Protected endpoint path to test (default: /api/moods)
#   TIMEOUT         Per-request timeout in seconds (default: 10)
#
set -euo pipefail

BASE="${BASE:-https://api-staging.soulapp.app}"
TIMEOUT="${TIMEOUT:-10}"
PROTECTED_PATH="${PROTECTED_PATH:-/api/moods}"

ACCESS="${ACCESS:-}"
REFRESH="${REFRESH:-}"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: 'jq' is required but not installed. Please install jq and re-run." >&2
  exit 1
fi

if [[ -z "${ACCESS}" || -z "${REFRESH}" ]]; then
  echo "ERROR: ACCESS and REFRESH env vars are required (export them from otp.sh output)." >&2
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

curl_status() {
  local method="$1" path="$2" data="${3:-}"
  if [[ -n "${data}" ]]; then
    curl -s -o /dev/null -w "%{http_code}" -m "${TIMEOUT}" -X "${method}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      --data "${data}" \
      "${BASE}${path}"
  else
    curl -s -o /dev/null -w "%{http_code}" -m "${TIMEOUT}" -X "${method}" \
      -H "Accept: application/json" \
      "${BASE}${path}"
  fi
}

echo
info "1) Refreshing access token using /api/auth/refresh ..."
REFRESH_REQ=$(jq -nc --arg rt "${REFRESH}" '{old_refresh_token:$rt}')
REFRESH_RESP="$(curl_json POST "/api/auth/refresh" "${REFRESH_REQ}")" || {
  echo "ERROR: Refresh request failed." >&2
  exit 2
}
echo "${REFRESH_RESP}" | jq .

NEW_ACCESS=$(echo "${REFRESH_RESP}" | jq -r '.access_token // empty')
NEW_REFRESH=$(echo "${REFRESH_RESP}" | jq -r '.refresh_token // empty')

if [[ -z "${NEW_ACCESS}" || -z "${NEW_REFRESH}" ]]; then
  echo "ERROR: Missing access_token or refresh_token in refresh response." >&2
  exit 3
fi

echo
info "Export commands for convenience (copy/paste if desired):"
echo "  export ACCESS=\"${NEW_ACCESS}\""
echo "  export REFRESH=\"${NEW_REFRESH}\""

echo
info "2) Verifying the OLD refresh token is revoked (expect 401) ..."
OLD_REUSE_REQ=$(jq -nc --arg rt "${REFRESH}" '{old_refresh_token:$rt}')
OLD_REUSE_STATUS="$(curl_status POST "/api/auth/refresh" "${OLD_REUSE_REQ}")"
echo "Old refresh reuse HTTP status: ${OLD_REUSE_STATUS}"
if [[ "${OLD_REUSE_STATUS}" != "401" ]]; then
  echo "ERROR: Expected 401 when reusing old refresh token; got ${OLD_REUSE_STATUS}" >&2
  exit 4
fi
info "Old refresh properly revoked ✅"

echo
info "3) Calling protected endpoint with NEW access token: ${PROTECTED_PATH}"
PROTECTED_STATUS=$(
  curl -s -o /tmp/jwt_protected_resp.json -w "%{http_code}" -m "${TIMEOUT}" \
    -H "Authorization: Bearer ${NEW_ACCESS}" \
    -H "Accept: application/json" \
    "${BASE}${PROTECTED_PATH}"
)
echo "Protected endpoint status: ${PROTECTED_STATUS}"
if [[ "${PROTECTED_STATUS}" != "200" ]]; then
  echo "WARN: Protected endpoint did not return 200. Body follows:"
  cat /tmp/jwt_protected_resp.json
else
  cat /tmp/jwt_protected_resp.json | jq . || cat /tmp/jwt_protected_resp.json
fi

echo
info "4) Logging out to revoke the NEW refresh token ..."
LOGOUT_REQ=$(jq -nc --arg rt "${NEW_REFRESH}" '{refresh_token:$rt}')
LOGOUT_RESP="$(curl_json POST "/api/auth/logout" "${LOGOUT_REQ}")" || {
  echo "ERROR: Logout request failed." >&2
  exit 5
}
echo "${LOGOUT_RESP}" | jq .

echo
info "5) Verifying revoked (NEW) refresh token can no longer be used (expect 401) ..."
REVOKED_STATUS="$(curl_status POST "/api/auth/refresh" "${LOGOUT_REQ}")"
echo "Revoked refresh reuse HTTP status: ${REVOKED_STATUS}"
if [[ "${REVOKED_STATUS}" != "401" ]]; then
  echo "ERROR: Expected 401 when reusing revoked refresh token; got ${REVOKED_STATUS}" >&2
  exit 6
fi
info "Revoked refresh properly blocked ✅"

echo
info "Summary:"
echo "  - New access token acquired and used on protected endpoint (status: ${PROTECTED_STATUS})"
echo "  - Old refresh token rejected post-rotation (401)"
echo "  - New refresh token rejected post-logout (401)"
echo
info "JWT refresh & logout tests completed successfully."
