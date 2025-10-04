Crisis features README

- To enable ML-based detector:
  - Install optional dependencies: `pip install -r requirements-ml.txt` (ensure an appropriate torch is installed)
  - Set env var: `USE_MODEL_DETECTOR=true` (or edit `app/config.py` settings)

- Background worker:
  - An in-process worker is started by default (suitable for dev/testing). For production, replace with a proper task queue (Celery/RQ) and worker processes.
  - Configure `ENABLE_BACKGROUND_WORKER` and `BACKGROUND_TASK_MAX_RETRIES` in `app/config.py` or via env.

- Escalation:
  - Emails are sent to `ESCALATION_EMAIL` using `app/services/email.py`. In dev preview mode, preview HTML files are written to `tmp/email-previews`.

- Resources:
  - Resource list is in `app/data/crisis_resources.json`. The `/api/crisis/resources` endpoint supports `?country=XX` or will infer from user profile if available.

- Moderation & audit:
  - Admins can list unresolved alerts (`GET /api/crisis/alerts`) and resolve alerts (`POST /api/crisis/alerts/{id}/resolve`).
  - Audit entries are recorded in `crisis_audits` (model added).
