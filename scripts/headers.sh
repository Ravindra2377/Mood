#!/usr/bin/env bash
#
# headers.sh — Validate security and CORS headers for the SOUL API.
#
# This script checks required security headers and (optionally) CORS preflight behavior
# against a staging or production endpoint.
#
# Required headers:
#   - Strict-Transport-Security: max-age >= 31536000, includeSubDomains (preload recommended)
#   - X-Content-Type-Options: nosniff
#   - X-Frame-Options: DENY
#   - Content-Security-Policy: present (recommended: default-src 'none'; frame-ancestors 'none'; connect-src as needed)
# Also checks (recommended):
#   - Referrer-Policy (e.g., strict-origin-when-cross-origin, no-referrer)
#   - Cache-Control: no-store (for API responses)
#
# Optional CORS preflight (set ORIGIN to enable):
#   - Sends an OPTIONS request to PRELIGHT_PATH (default: /api/moods)
#   - Asserts Access-Control-Allow-Origin equals ORIGIN
#   - Asserts Access-Control-Allow-Headers include Authorization and Content-Type (or *)
#
# Usage:
#   BASE=https://api-staging.soulapp.app ./headers.sh
#   ORIGIN=https://staging.web.app BASE=https://api-staging.soulapp.app ./headers.sh
#
# Env:
#   BASE           Base URL to test (default: https://api-staging.soulapp.app)
#   PATHS          Space-separated list of paths to test (default: "/ /nonexistent-404-path")
#   PRELIGHT_PATH  Path for CORS preflight (default: /api/moods)
#   TIMEOUT        Curl timeout in seconds (default: 10)
#
set -uo pipefail

BASE="${BASE:-https://api-staging.soulapp.app}"
PATHS="${PATHS:-/ /nonexistent-404-path}"
PRELIGHT_PATH="${PRELIGHT_PATH:-/api/moods}"
TIMEOUT="${TIMEOUT:-10}"
ORIGIN="${ORIGIN:-}"

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

hr() { echo "----------------------------------------------------------------"; }
info() { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"; }
ok() { echo "PASS: $*"; PASS_COUNT=$((PASS_COUNT+1)); }
warn() { echo "WARN: $*"; WARN_COUNT=$((WARN_COUNT+1)); }
fail() { echo "FAIL: $*"; FAIL_COUNT=$((FAIL_COUNT+1)); }

fetch_headers() {
  local url="$1"
  local hdr_file
  hdr_file="$(mktemp)"
  # -s silent, -I HEAD, -L follow redirects, -m timeout
  if ! curl -sSLI -m "${TIMEOUT}" -D "${hdr_file}" -o /dev/null "${url}"; then
    echo ""
    return 1
  fi
  echo "${hdr_file}"
}

# Case-insensitive header extract; returns value without trailing CR
get_header() {
  local hdr_file="$1"
  local name="$2"
  awk -v IGNORECASE=1 -v name="${name}:" '
    $0 ~ "^"name {
      sub(/^[^:]+:[[:space:]]*/, "", $0)
      sub(/\r$/, "", $0)
      print
    }' "${hdr_file}" | tail -n 1
}

trim() { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' ; }

check_hsts() {
  local value="$1"
  if [[ -z "${value}" ]]; then
    fail "Strict-Transport-Security header missing"
    return
  fi

  local lc
  lc="$(echo "${value}" | tr '[:upper:]' '[:lower:]')"
  # max-age=
  local max_age
  max_age="$(echo "${lc}" | sed -n 's/.*max-age=\([0-9]\+\).*/\1/p' | head -n1)"
  if [[ -z "${max_age}" ]]; then
    fail "HSTS present but missing max-age: ${value}"
  elif [[ "${max_age}" -lt 31536000 ]]; then
    fail "HSTS max-age too low (${max_age}); require >= 31536000"
  else
    ok "HSTS max-age=${max_age}"
  fi

  if echo "${lc}" | grep -qi 'includesubdomains'; then
    ok "HSTS includeSubDomains present"
  else
    fail "HSTS missing includeSubDomains"
  fi

  if echo "${lc}" | grep -qi 'preload'; then
    ok "HSTS preload present"
  else
    warn "HSTS preload not set (optional; enable after verifying readiness across subdomains)"
  fi
}

check_xcto() {
  local value="$1"
  if [[ -z "${value}" ]]; then
    fail "X-Content-Type-Options header missing"
  elif [[ "$(echo "${value}" | tr '[:upper:]' '[:lower:]' | trim)" == "nosniff" ]]; then
    ok "X-Content-Type-Options: nosniff"
  else
    fail "X-Content-Type-Options unexpected value: '${value}' (expected: nosniff)"
  fi
}

check_xfo() {
  local value="$1"
  if [[ -z "${value}" ]]; then
    fail "X-Frame-Options header missing"
  elif [[ "$(echo "${value}" | tr '[:upper:]' '[:lower:]' | trim)" == "deny" ]]; then
    ok "X-Frame-Options: DENY"
  else
    fail "X-Frame-Options unexpected value: '${value}' (expected: DENY)"
  fi
}

check_csp() {
  local value="$1"
  if [[ -z "${value}" ]]; then
    fail "Content-Security-Policy header missing"
    return
  fi
  local lc
  lc="$(echo "${value}" | tr '[:upper:]' '[:lower:]')"
  if echo "${lc}" | grep -q "default-src 'none'"; then
    ok "CSP includes default-src 'none'"
  else
    warn "CSP does not include default-src 'none' (recommended for APIs). Value: ${value}"
  fi
  if echo "${lc}" | grep -q "frame-ancestors 'none'"; then
    ok "CSP includes frame-ancestors 'none'"
  else
    warn "CSP does not include frame-ancestors 'none' (prevents embedding). Value: ${value}"
  fi
}

check_referrer_policy() {
  local value="$1"
  if [[ -z "${value}" ]]; then
    warn "Referrer-Policy header missing (recommended: strict-origin-when-cross-origin or no-referrer)"
  else
    ok "Referrer-Policy present: ${value}"
  fi
}

check_cache_control() {
  local value="$1"
  if [[ -z "${value}" ]]; then
    warn "Cache-Control header missing (recommended: no-store for APIs)"
  elif echo "${value}" | tr '[:upper:]' '[:lower:]' | grep -q 'no-store'; then
    ok "Cache-Control includes no-store"
  else
    warn "Cache-Control does not include no-store (got: ${value})"
  fi
}

check_headers_for_url() {
  local url="$1"
  hr
  info "Fetching headers: ${url}"
  local hdr_file
  hdr_file="$(fetch_headers "${url}")" || { fail "Failed to fetch headers for ${url}"; return; }

  local hsts xcto xfo csp refpol cachec
  hsts="$(get_header "${hdr_file}" "Strict-Transport-Security")"
  xcto="$(get_header "${hdr_file}" "X-Content-Type-Options")"
  xfo="$(get_header "${hdr_file}" "X-Frame-Options")"
  csp="$(get_header "${hdr_file}" "Content-Security-Policy")"
  refpol="$(get_header "${hdr_file}" "Referrer-Policy")"
  cachec="$(get_header "${hdr_file}" "Cache-Control")"

  echo "Strict-Transport-Security: ${hsts:-<missing>}"
  echo "X-Content-Type-Options:    ${xcto:-<missing>}"
  echo "X-Frame-Options:           ${xfo:-<missing>}"
  echo "Content-Security-Policy:   ${csp:-<missing>}"
  echo "Referrer-Policy:           ${refpol:-<missing>}"
  echo "Cache-Control:             ${cachec:-<missing>}"

  check_hsts "${hsts}"
  check_xcto "${xcto}"
  check_xfo "${xfo}"
  check_csp "${csp}"
  check_referrer_policy "${refpol}"
  check_cache_control "${cachec}"

  rm -f "${hdr_file}"
}

cors_preflight() {
  local origin="$1"
  local url="${BASE}${PRELIGHT_PATH}"
  hr
  info "CORS preflight: ORIGIN=${origin} OPTIONS ${url}"
  local hdr body status
  hdr="$(mktemp)"
  body="$(mktemp)"
  curl -s -o "${body}" -D "${hdr}" -m "${TIMEOUT}" -X OPTIONS \
    -H "Origin: ${origin}" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: Authorization, Content-Type" \
    "${url}" >/dev/null || true
  # Determine last HTTP status
  status="$(tac "${hdr}" | awk '/^HTTP\//{print $2; exit}')"
  local aco acrm acrh
  aco="$(get_header "${hdr}" "Access-Control-Allow-Origin")"
  acrm="$(get_header "${hdr}" "Access-Control-Allow-Methods")"
  acrh="$(get_header "${hdr}" "Access-Control-Allow-Headers")"
  echo "HTTP ${status}"
  echo "Access-Control-Allow-Origin:  ${aco:-<missing>}"
  echo "Access-Control-Allow-Methods: ${acrm:-<missing>}"
  echo "Access-Control-Allow-Headers: ${acrh:-<missing>}"

  if [[ -z "${aco}" ]]; then
    fail "CORS preflight missing Access-Control-Allow-Origin"
  elif [[ "${aco}" == "${origin}" || "${aco}" == "*" ]]; then
    ok "CORS ACO allows origin (${aco})"
  else
    fail "CORS ACO mismatch. Expected '${origin}' or '*', got '${aco}'"
  fi

  # Require Authorization and Content-Type (or wildcard)
  local acrh_lc
  acrh_lc="$(echo "${acrh}" | tr '[:upper:]' '[:lower:]')"
  if [[ -z "${acrh_lc}" ]]; then
    fail "CORS missing Access-Control-Allow-Headers"
  elif echo "${acrh_lc}" | grep -q '\*'; then
    ok "CORS allows all headers (*)"
  else
    local need_auth need_ct
    need_auth=0; need_ct=0
    echo "${acrh_lc}" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | while read -r h; do
      [[ "${h}" == "authorization" ]] && need_auth=1
      [[ "${h}" == "content-type" ]] && need_ct=1
      :
    done
    # Because of subshell, re-evaluate with grep:
    if echo "${acrh_lc}" | grep -qw "authorization"; then need_auth=1; fi
    if echo "${acrh_lc}" | grep -qw "content-type"; then need_ct=1; fi
    if [[ "${need_auth}" -eq 1 && "${need_ct}" -eq 1 ]]; then
      ok "CORS allows required headers (Authorization, Content-Type)"
    else
      fail "CORS Access-Control-Allow-Headers missing Authorization and/or Content-Type"
    fi
  fi

  rm -f "${hdr}" "${body}"
}

main() {
  echo "Security header validation for: ${BASE}"
  echo "Paths: ${PATHS}"
  if [[ -n "${ORIGIN}" ]]; then
    echo "CORS preflight origin: ${ORIGIN} (path: ${PRELIGHT_PATH})"
  fi
  hr

  for p in ${PATHS}; do
    check_headers_for_url "${BASE}${p}"
  done

  if [[ -n "${ORIGIN}" ]]; then
    cors_preflight "${ORIGIN}"
  fi

  hr
  echo "Summary: PASS=${PASS_COUNT} WARN=${WARN_COUNT} FAIL=${FAIL_COUNT}"
  if [[ "${FAIL_COUNT}" -gt 0 ]]; then
    exit 2
  fi
}
main "$@"
