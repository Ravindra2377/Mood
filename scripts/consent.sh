#!/usr/bin/env bash
#
# consent.sh — Exercise consent endpoints for the SOUL API.
#
# This script:
#  1) Fetches current legal versions/URLs (unauthenticated and authenticated)
#  2) Submits consent for the authenticated user (accepts TOS + Privacy, optional research)
#  3) Verifies consent state after submission
#
# Requirements:
#   - bash, curl, jq
#
# Usage:
#   # Using tokens from otp.sh output:
#   BASE=https://api-staging.soulapp.app ACCESS="$ACCESS" ./consent.sh
#
#   # Override research opt-in or consent version:
#   BASE=https://api-staging.soulapp.app ACCESS="$ACCESS" RESEARCH_OPT_IN=true CONSENT_VERSION="v1" ./consent.sh
#
# Env vars:
#   BASE             Base URL for the API (default: https://api-staging.soulapp.app)
#   ACCESS           Bearer access token (required for submit and authenticated GET)
#   TIMEOUT          Per-request timeout in seconds (default: 10)
#   POLICY_VERSION   Optional override for policy_version sent to /consent/submit
#   RESEARCH_OPT_IN  Optional research/data-use opt-in flag (default: false)
#   CONSENT_VERSION  Optional app-level consent version to send
#
set -euo pipefail

BASE="${BASE:-https://api-staging.soulapp.app}"
TIMEOUT="${TIMEOUT:-10}"
ACCESS="${ACCESS:-}"
POLICY_VERSION="${POLICY_VERSION:-}"
RESEARCH_OPT_IN="${RESEARCH_OPT_IN:-false}"
CONSENT_VERSION="${CONSENT_VERSION:-}"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: 'jq' is required but not installed. Please install jq and re-run." >&2
  exit 1
fi

info() { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"; }

curl_json() {
  # curl_json METHOD PATH [DATA] [AUTH=0|1]
  local method="$1" path="$2" data="${3:-}" auth="${4:-0}"
  if [[ "${auth}" == "1" && -z "${ACCESS}" ]]; then
    echo "ERROR: ACCESS token required for authenticated call to ${path}" >&2
    exit 2
  fi
  if [[ -n "${data}" ]]; then
    if [[ "${auth}" == "1" ]]; then
      curl -fsS -m "${TIMEOUT}" -X "${method}" \
        -H "Authorization: Bearer ${ACCESS}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "${data}" \
        "${BASE}${path}"
    else
      curl -fsS -m "${TIMEOUT}" -X "${method}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "${data}" \
        "${BASE}${path}"
    fi
  else
    if [[ "${auth}" == "1" ]]; then
      curl -fsS -m "${TIMEOUT}" -X "${method}" \
        -H "Authorization: Bearer ${ACCESS}" \
        -H "Accept: application/json" \
        "${BASE}${path}"
    else
      curl -fsS -m "${TIMEOUT}" -X "${method}" \
        -H "Accept: application/json" \
        "${BASE}${path}"
    fi
  fi
}

derive_policy_version() {
  # Derive a policy_version string from GET /api/consent/current (TOS:<v>|PRIV:<v>|RSCH:<v>)
  local current="$1"
  local tos privacy research
  tos=$(echo "${current}" | jq -r '.tos_version')
  privacy=$(echo "${current}" | jq -r '.privacy_version')
  research=$(echo "${current}" | jq -r '.research_version // empty')

  local pv="TOS:${tos}|PRIV:${privacy}"
  if [[ -n "${research}" && "${research}" != "null" ]]; then
    pv="${pv}|RSCH:${research}"
  fi
  echo "${pv}"
}

echo
info "1) GET /api/consent/current (unauthenticated)"
CURR_PUBLIC="$(curl_json GET "/api/consent/current")"
echo "${CURR_PUBLIC}" | jq .

# Optionally fetch authenticated view (user_state) if ACCESS provided
if [[ -n "${ACCESS}" ]]; then
  echo
  info "2) GET /api/consent/current (authenticated)"
  CURR_AUTH="$(curl_json GET "/api/consent/current" "" 1)"
  echo "${CURR_AUTH}" | jq .

  # Build policy_version for submission
  if [[ -z "${POLICY_VERSION}" ]]; then
    POLICY_VERSION="$(derive_policy_version "${CURR_AUTH}")"
  fi

  echo
  info "3) POST /api/consent/submit (accept TOS + Privacy; research_opt_in=${RESEARCH_OPT_IN})"
  SUBMIT_BODY="$(jq -nc \
    --arg pv "${POLICY_VERSION}" \
    --argjson tos true \
    --argjson priv true \
    --argjson rch "$( [[ "${RESEARCH_OPT_IN}" == "true" ]] && echo true || echo false )" \
    --arg cv "${CONSENT_VERSION}" \
    '{
      policy_version: $pv,
      tos_accepted: $tos,
      privacy_accepted: $priv,
      research_opt_in: $rch
    } + ( ($cv|length) > 0 ? {consent_version:$cv} : {} )')"

  SUBMIT_RESP="$(curl_json POST "/api/consent/submit" "${SUBMIT_BODY}" 1)"
  echo "${SUBMIT_RESP}" | jq .

  echo
  info "4) Verify consent state again (GET /api/consent/current)"
  CURR_AUTH_2="$(curl_json GET "/api/consent/current" "" 1)"
  echo "${CURR_AUTH_2}" | jq .

  HAS_CONSENT=$(echo "${CURR_AUTH_2}" | jq -r '.user_state.has_consented // empty')
  LAST_POLICY=$(echo "${CURR_AUTH_2}" | jq -r '.user_state.last_event.policy_version // empty')

  echo
  info "Summary:"
  echo "  Derived policy_version: ${POLICY_VERSION}"
  echo "  has_consented (server): ${HAS_CONSENT}"
  echo "  last_event.policy_version: ${LAST_POLICY}"
  if [[ "${HAS_CONSENT}" != "true" ]]; then
    echo "WARN: has_consented is not true. Ensure versions match the current policy." >&2
  fi
else
  echo
  info "ACCESS token not provided. Skipping authenticated checks and submission."
  echo "Tip: export ACCESS from otp.sh output and rerun to submit consent."
fi

echo
info "Consent endpoint checks completed."
