#!/usr/bin/env bash
#
# smoke.sh — Basic health and readiness checks for the SOUL API.
#
# Usage:
#   BASE=https://api-staging.soulapp.app ./smoke.sh
#
# Env vars:
#   BASE           Base URL for the API (default: https://api-staging.soulapp.app)
#   TIMEOUT        Per-request timeout in seconds (default: 10)
#   STRICT_READY   If "true", fail the script when /readyz != "ready" (default: false)
#
set -euo pipefail

BASE="${BASE:-https://api-staging.soulapp.app}"
TIMEOUT="${TIMEOUT:-10}"
STRICT_READY="${STRICT_READY:-false}"

have_jq() { command -v jq >/dev/null 2>&1; }

curl_json() {
  local path="$1"
  curl -fsS -m "${TIMEOUT}" -H "Accept: application/json" "${BASE}${path}"
}

print_section() {
  echo
  echo "=== $* ==="
}

assert_equals() {
  local actual="$1"
  local expected="$2"
  local msg="$3"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "FAIL: ${msg} (expected: ${expected}, got: ${actual})" >&2
    exit 1
  fi
}

# 1) Health check (/healthz): expect status == "ok"
print_section "Health check (${BASE}/healthz)"
HEALTH=$(curl_json "/healthz")

if have_jq; then
  echo "${HEALTH}" | jq .
  H_STATUS=$(echo "${HEALTH}" | jq -r '.status // empty')
  DB_OK=$(echo "${HEALTH}" | jq -r '.db // empty')
  REDIS_OK=$(echo "${HEALTH}" | jq -r '.redis // empty')
else
  echo "${HEALTH}"
  H_STATUS=$(echo "${HEALTH}" | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' || true)
  DB_OK=$(echo "${HEALTH}" | sed -n 's/.*"db"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' || true)
  REDIS_OK=$(echo "${HEALTH}" | sed -n 's/.*"redis"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' || true)
fi

if [[ -z "${H_STATUS}" ]]; then
  echo "WARN: Unable to parse health status; proceeding as long as HTTP succeeded."
else
  assert_equals "${H_STATUS}" "ok" "/healthz .status"
fi

# 2) Readiness check (/readyz): expect status == "ready" (if STRICT_READY=true)
print_section "Readiness check (${BASE}/readyz)"
READY=$(curl_json "/readyz")

if have_jq; then
  echo "${READY}" | jq .
  R_STATUS=$(echo "${READY}" | jq -r '.status // empty')
  R_DB=$(echo "${READY}" | jq -r '.db // empty')
  R_REDIS=$(echo "${READY}" | jq -r '.redis // empty')
  R_TWILIO=$(echo "${READY}" | jq -r '.twilio // empty')
else
  echo "${READY}"
  R_STATUS=$(echo "${READY}" | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' || true)
  R_DB=$(echo "${READY}" | sed -n 's/.*"db"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' || true)
  R_REDIS=$(echo "${READY}" | sed -n 's/.*"redis"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' || true)
  R_TWILIO=$(echo "${READY}" | sed -n 's/.*"twilio"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' || true)
fi

if [[ "${STRICT_READY}" == "true" ]]; then
  if [[ -z "${R_STATUS}" ]]; then
    echo "FAIL: STRICT_READY=true and unable to parse /readyz .status" >&2
    exit 1
  fi
  assert_equals "${R_STATUS}" "ready" "/readyz .status (STRICT_READY)"
else
  if [[ "${R_STATUS:-}" != "ready" ]]; then
    echo "NOTE: /readyz status = '${R_STATUS:-unknown}'. Proceeding (STRICT_READY=false)."
  fi
fi

print_section "Summary"
echo "Healthz: status=${H_STATUS:-unknown} db=${DB_OK:-unknown} redis=${REDIS_OK:-unknown}"
echo "Readyz:  status=${R_STATUS:-unknown} db=${R_DB:-unknown} redis=${R_REDIS:-unknown} twilio=${R_TWILIO:-unknown}"
echo
echo "Smoke checks completed successfully."
