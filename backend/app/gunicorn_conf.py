"""
Gunicorn configuration for running FastAPI (Uvicorn workers) in production.

This file is loaded by Gunicorn with: -c app/gunicorn_conf.py

Environment overrides (all optional):
- PORT                      -> overrides listening port (default: 8000)
- GUNICORN_BIND             -> full bind string, e.g. "0.0.0.0:8000"
- GUNICORN_WORKERS          -> number of workers (default: 2*CPU + 1, min 2)
- GUNICORN_THREADS          -> threads per worker (default: 1)
- GUNICORN_WORKER_CLASS     -> worker class (default: "uvicorn.workers.UvicornWorker")
- GUNICORN_TIMEOUT          -> worker timeout seconds (default: 90)
- GUNICORN_GRACEFUL_TIMEOUT -> graceful timeout seconds (default: 30)
- GUNICORN_KEEPALIVE        -> keepalive seconds (default: 5)
- GUNICORN_MAX_REQUESTS     -> recycle workers after N requests (default: 2000)
- GUNICORN_MAX_REQUESTS_JIT -> jitter added to max_requests (default: 200)
- GUNICORN_LOG_LEVEL        -> loglevel (default: "info")
- GUNICORN_ACCESS_LOG       -> access log target (default: "-")
- GUNICORN_ERROR_LOG        -> error log target (default: "-")

Notes:
- We trust X-Forwarded-* headers from the upstream proxy (Caddy) and mark requests
  as secure when X-Forwarded-Proto is https.
- Access logs are JSON-like for easier ingestion by log processors.
"""

import os
import multiprocessing


def _getenv_int(name: str, default: int) -> int:
    try:
        return int(os.getenv(name, str(default)))
    except (TypeError, ValueError):
        return default


def _getenv_str(name: str, default: str) -> str:
    return os.getenv(name, default)


# Bind address: prefer explicit GUNICORN_BIND, else PORT, else 8000
_port = _getenv_int("PORT", 8000)
bind = _getenv_str("GUNICORN_BIND", f"0.0.0.0:{_port}")

# Workers: default to 2 * CPU + 1 (min 2)
_default_workers = max(2, multiprocessing.cpu_count() * 2 + 1)
workers = _getenv_int("GUNICORN_WORKERS", _default_workers)

# Threads per worker (keep small for asyncio worker class)
threads = _getenv_int("GUNICORN_THREADS", 1)

# Uvicorn worker class for ASGI/FastAPI
worker_class = _getenv_str("GUNICORN_WORKER_CLASS", "uvicorn.workers.UvicornWorker")

# Timeouts and connection behavior
timeout = _getenv_int("GUNICORN_TIMEOUT", 90)
graceful_timeout = _getenv_int("GUNICORN_GRACEFUL_TIMEOUT", 30)
keepalive = _getenv_int("GUNICORN_KEEPALIVE", 5)

# Proactive worker recycling to mitigate memory bloat
max_requests = _getenv_int("GUNICORN_MAX_REQUESTS", 2000)
max_requests_jitter = _getenv_int("GUNICORN_MAX_REQUESTS_JIT", 200)

# Logging
loglevel = _getenv_str("GUNICORN_LOG_LEVEL", "info")
accesslog = _getenv_str("GUNICORN_ACCESS_LOG", "-")
errorlog = _getenv_str("GUNICORN_ERROR_LOG", "-")
capture_output = True  # redirect stdout/stderr to errorlog

# JSON-like access log for easier parsing (single line)
# Fields:
#  h=client, u=user, t=time, r=request, s=status, b=bytes, f=referer, a=user-agent, D=micros, p=process
access_log_format = (
    '{"h":"%(h)s","u":"%(u)s","t":"%(t)s","r":"%(r)s","s":%(s)s,'
    '"b":%(b)s,"f":"%(f)s","a":"%(a)s","D":%(D)s,"p":"%(p)s"}'
)

# Security / proxy awareness
# Trust all proxy IPs (Caddy in front should sanitize headers)
forwarded_allow_ips = "*"
secure_scheme_headers = {"X-FORWARDED-PROTO": "https"}

# Minor optimizations
# Use tmpfs for worker tmp (if available) to reduce disk I/O
worker_tmp_dir = "/dev/shm" if os.path.isdir("/dev/shm") else None

# Process title
proc_name = "soul-api"

# Optional: tweak backlog (pending connections) if needed
backlog = _getenv_int("GUNICORN_BACKLOG", 2048)
