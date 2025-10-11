#!/usr/bin/env bash
#
# ratelimit.sh — Validate per-phone OTP rate limiting (429) for the SOUL API.
#
# This script exercises:
#   1) /api/auth/otp/request — 5 requests per 15 minutes per phone (expect 429 on 6th)
#   2) /api/auth/verify-otp — 10 requests per hour per phone (expect 429 on 11th)
#
# Requirements:
#   - bash, curl
#   - jq (optional; used for pretty-printing JSON)
#
# Usage:
#   BASE=https://api-staging.soulapp.app PHONE=+14155550123 ./ratelimit.sh
#
# Env vars:
#   BASE      Base URL for API (default: https://api-staging.soulapp.app)
#   PHONE     E.164 phone number, e.g., +14155550123 (required)
#   OTP       OTP code to verify (default: 123456; works in staging DEV_MODE=true)
#   TIMEOUT   Per-request timeout in seconds (default: 10)
#
set -euo pipefail

BASE="${BASE:-https://api-staging.soulapp.app}"
PHONE="${PHONE:-}"
OTP="${OTP:-123456}"
TIMEOUT="${TIMEOUT:-10}"

if [[ -z "${PHONE}" ]]; then
  echo "ERROR: PHONE env var is required (E.164 format, e.g. +14155550123)." >&2
  exit 1
fi

HAVE_JQ=0
if command -v jq >/dev/null 2>&1; then HAVE_JQ=1; fi

info()  { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"; }
hr()    { echo "------------------------------------------------------------"; }

req_json() {
  local method="$1" path="$2" data="$3" hdr_out="$4" body_out="$5"
  if [[ -n "${data}" ]]; then
    curl -s -m "${TIMEOUT}" -X "${method}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -D "${hdr_out}" \
      --data "${data}" \
      "${BASE}${path}" > "${body_out}"
  else
    curl -s -m "${TIMEOUT}" -X "${method}" \
      -H "Accept: application/json" \
      -D "${hdr_out}" \
      "${BASE}${path}" > "${body_out}"
  fi
}

http_status() {
  # Read the last HTTP status from a curl -D headers file
  # There can be multiple HTTP/ lines due to redirects/proxy. Take the last one.
  local hdr="$1"
  tac "${hdr}" | awk '/^HTTP\//{print $2; exit}'
}

retry_after_hdr() {
  local hdr="$1"
  awk 'BEGIN{IGNORECASE=1} /^Retry-After:/{print $2; exit}' "${hdr}" | tr -d '\r'
}

print_body() {
  local body="$1"
  if [[ "${HAVE_JQ}" -eq 1 ]]; then
    jq . "${body}" 2>/dev/null || cat "${body}"
  else
    cat "${body}"
  fi
}

test_send_otp_rate() {
  info "Testing per-phone rate limit for /api/auth/otp/request (expect 429 on 6th call)"
  local hdr body status ra
  for i in $(seq 1 6); do
    hr
    info "send_otp attempt #${i}"
    hdr="$(mktemp)"
    body="$(mktemp)"
    req_json POST "/api/auth/otp/request" "$(jq -nc --arg phone "${PHONE}" '{phone:$phone}')" "${hdr}" "${body}" || true
    status="$(http_status "${hdr}")"
    echo "HTTP ${status}"
    echo "Response:"
    print_body "${body}"
    if [[ "${status}" == "429" ]]; then
      ra="$(retry_after_hdr "${hdr}")"
      [[ -n "${ra}" ]] && echo "Retry-After: ${ra}s"
      if [[ "${i}" -lt 6 ]]; then
        echo "Received 429 before the 6th call — limits may be stricter than expected." >&2
      fi
      rm -f "${hdr}" "${body}"
      return 0
    fi
    rm -f "${hdr}" "${body}"
  done
  echo "ERROR: Did not receive 429 on the 6th /otp/request call. Check limiter config." >&2
  return 1
}

test_verify_otp_rate() {
  info "Testing per-phone rate limit for /api/auth/verify-otp (expect 429 on 11th call)"
  local hdr body status ra
  for i in $(seq 1 11); do
    hr
    info "verify_otp attempt #${i}"
    hdr="$(mktemp)"
    body="$(mktemp)"
    req_json POST "/api/auth/verify-otp" "$(jq -nc --arg phone "${PHONE}" --arg otp "${OTP}" '{phone:$phone,otp:$otp}')" "${hdr}" "${body}" || true
    status="$(http_status "${hdr}")"
    echo "HTTP ${status}"
    echo "Response:"
    print_body "${body}"
    if [[ "${status}" == "429" ]]; then
      ra="$(retry_after_hdr "${hdr}")"
      [[ -n "${ra}" ]] && echo "Retry-After: ${ra}s"
      if [[ "${i}" -lt 11 ]]; then
        echo "Received 429 before the 11th call — limits may be stricter than expected." >&2
      fi
      rm -f "${hdr}" "${body}"
      return 0
    fi
    rm -f "${hdr}" "${body}"
  done
  echo "ERROR: Did not receive 429 on the 11th /verify-otp call. Check limiter config." >&2
  return 1
}

main() {
  hr
  info "Base:  ${BASE}"
  info "Phone: ${PHONE}"
  info "OTP:   ${OTP}"
  hr

  test_send_otp_rate
  echo
  test_verify_otp_rate

  hr
  info "Rate-limit tests completed."
  echo "Expectations:"
  echo " - 6th /api/auth/otp/request => 429"
  echo " - 11th /api/auth/verify-otp => 429"
  hr
}

main "$@"
