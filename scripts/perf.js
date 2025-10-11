import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Trend, Rate } from 'k6/metrics';

/**
 * perf.js — k6 performance smoke for SOUL API
 *
 * Usage:
 *   # Basic smoke (25 VUs for 2m) against staging:
 *   k6 run perf.js -e BASE=https://api-staging.soulapp.app -e ACCESS=$ACCESS
 *
 *   # Heavier load / longer duration:
 *   k6 run perf.js -e BASE=$BASE -e ACCESS=$ACCESS -e VUS=50 -e DUR=3m
 *
 * Env:
 *   BASE   Base URL (default: https://api-staging.soulapp.app)
 *   ACCESS Bearer access token for protected endpoints (optional; if missing, test falls back to /healthz)
 *   VUS    Virtual users (default: 25)
 *   DUR    Duration (default: 2m)
 */

// Config
const BASE = __ENV.BASE || 'https://api-staging.soulapp.app';
const ACCESS = __ENV.ACCESS || ''; // optional; if absent we run health-only tests

const VUS = Number(__ENV.VUS || 25);
const DUR = __ENV.DUR || '2m';

// k6 options and thresholds
export const options = {
  vus: VUS,
  duration: DUR,
  thresholds: {
    http_req_failed: ['rate<0.01'],        // <1% requests should fail
    http_req_duration: ['p(95)<300'],      // p95 under 300ms overall
    success_rate: ['rate>0.99'],           // custom success rate
  },
};

// Custom metrics
const moods_duration = new Trend('moods_duration');
const healthz_duration = new Trend('healthz_duration');
const success_rate = new Rate('success_rate');

// Helper: auth headers (when ACCESS provided)
function authHeaders() {
  return ACCESS ? { Authorization: `Bearer ${ACCESS}` } : {};
}

// Default VU behavior
export default function () {
  if (ACCESS) {
    group('protected:get:/api/moods', () => {
      const res = http.get(`${BASE}/api/moods`, { headers: authHeaders() });
      const ok = check(res, {
        'status is 200': (r) => r.status === 200,
      });
      success_rate.add(ok);
      moods_duration.add(res.timings.duration);
    });
  } else {
    // Fallback when ACCESS not provided — basic health smoke
    group('public:get:/healthz', () => {
      const res = http.get(`${BASE}/healthz`);
      const ok = check(res, {
        'status is 200': (r) => r.status === 200,
        'body has status ok': (r) => {
          try {
            const j = r.json();
            return j && j.status === 'ok';
          } catch (_) {
            return false;
          }
        },
      });
      success_rate.add(ok);
      healthz_duration.add(res.timings.duration);
    });
  }

  // Gentle pacing to avoid hot-looping
  sleep(1);
}

// Optional setup / teardown for future extension
export function setup() {
  return {
    base: BASE,
    hasAccess: Boolean(ACCESS),
  };
}

export function teardown(data) {
  // No-op
  return data;
}
