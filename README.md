# SOUL (formerly Mood)

A cross-platform mental wellness application that helps people track moods, practice guided exercises, and stay on top of self-care routines. The project pairs a Flutter mobile client with a FastAPI backend and production-ready DevOps tooling.

## ✨ Core Features
- Mood logging with history, triggers, and personalized insights
- Guided breathing, mindfulness, and self-help exercises
- Secure journal storage with optional encryption helpers
- Analytics dashboards and progress reporting
- OTP-based authentication and rate-limited public endpoints
- Docker-based deployment workflow with Caddy reverse proxy

## 🏗 Architecture at a Glance
```
project-root/
├── soul_fresh/        # Flutter application (Android/iOS)
├── backend/           # FastAPI backend services & scripts
├── docker/            # Deployment Dockerfiles (API, Caddy)
├── android-app/       # Gradle project & build artifacts
├── docs (*.md)        # Extensive documentation set
└── docker-compose.*   # Local and production compose stacks
```
// Detailed navigation: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

## 🛠 Tech Stack
- **Mobile:** Flutter (Dart), Riverpod, custom design system
- **Backend:** FastAPI, SQLAlchemy, Alembic, PostgreSQL/SQLite
- **Infrastructure:** Docker, docker-compose, Caddy, GitHub Actions (planned)
- **Tooling:** PowerShell helper scripts, pytest, Flutter test

## 🚀 Getting Started

### Prerequisites
| Tool | Notes |
| ---- | ----- |
| Flutter SDK | Stable channel (3.x recommended). Verify with `flutter doctor`. |
| Python 3.10+ | Used for the FastAPI backend. |
| Node.js (optional) | Only required for certain tooling scripts. |
| Docker & Docker Compose | For containerized development & deployment. |

### Clone the repository
```powershell
git clone https://github.com/Ravindra2377/Mood.git
cd Mood
```

### Option 1: Run everything with Docker (recommended)
```powershell
# Copy or create your environment file
Copy-Item example.env .env   # adjust if your template differs

# Build & start the stack
docker compose -f docker-compose.prod.yml up --build
```
Services:
- `api` → FastAPI backend (default http://localhost:8000)
- `frontend` → Flutter web preview (optional
- `caddy` → Reverse proxy/SSL termination
- `db` → PostgreSQL instance (configured in compose file)

### Option 2: Run manually

#### Backend (FastAPI)
```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# configure environment (see .env.example)
uvicorn app.main:app --reload --port 8000
```
Helpful scripts:
- `start_db_and_migrate.ps1` → spins up Postgres via docker-compose and runs Alembic migrations
- `fix_docker_and_start.ps1` → local convenience script to rebuild the stack

#### Mobile app (Flutter)
```powershell
cd soul_fresh
flutter pub get
flutter run   # pick your emulator or physical device
```
PowerShell build helpers (run from repo root or `soul_fresh/`):
- `build_apk_final.ps1`
- `build_apk_v2.ps1`
- `build_apk_simple_v2.ps1`
- `build_apk.ps1`

To produce a release APK manually:
```powershell
cd soul_fresh
flutter build apk --release
```
Artifacts are copied to `android-app/app/dist-apk/` via build scripts.

## 🔐 Environment Variables
Create a `.env` file in `backend/` (and root for Docker) using `.env.example` as a guide. Common keys:
- `DATABASE_URL`
- `SECRET_KEY`
- `OTP_SERVICE_KEY`
- `SEGMENT_WRITE_KEY`
- `KMS_KEY_ID`, `DATA_ENCRYPTION_KEY` (optional encryption helpers)

Do **not** commit secret values. For Windows PowerShell, you can set temporary values with `setx` or pass them through the environment before starting services.

## 🧪 Testing
- **Backend:**
  ```powershell
  cd backend
  .\.venv\Scripts\Activate.ps1  # if using a venv
  python -m pytest -q
  ```
- **Mobile:**
  ```powershell
  cd soul_fresh
  flutter test
  ```
Add integration tests for new endpoints or widgets before merging feature branches.

## 📦 Deployment Notes
- Docker images are prepared via `docker-compose.prod.yml` and `docker/Dockerfile.api` / `docker/Dockerfile.caddy`.
- Configure your target environment (e.g., VPS, ECS) to provide secrets and persistent storage for PostgreSQL.
- Caddy handles TLS and rate limiting; review `Caddyfile` for domain and certificate configuration.
- Mobile releases: use `android-app/build-apk-docker.ps1` or GitHub Actions (planned) to generate signed artifacts.

## 📚 Additional Documentation
This repository includes a large documentation suite. Start here:
- [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
- [QUICK_START_CHECKLIST.md](QUICK_START_CHECKLIST.md)
- [FRONTEND_INTEGRATION_GUIDE.md](FRONTEND_INTEGRATION_GUIDE.md)
- [FRONTEND_BUILD_COMPLETE.md](FRONTEND_BUILD_COMPLETE.md)
- [COMPLETE_FRONTEND_STRUCTURE.md](COMPLETE_FRONTEND_STRUCTURE.md)

Each file dives deeper into architecture, APIs, feature maps, and rollout plans.

## 🤝 Contributing
1. Create a descriptive branch (e.g., `feat/mood-offline-sync`).
2. Keep changes focused and accompanied by tests.
3. Run `flutter analyze`, `flutter test`, and backend test suites before opening a PR.
4. Document notable decisions in the relevant `docs/*.md` file and update this README if setup steps change.

## 📄 License
Project licensing is still under review. Until confirmed, treat the code as **All Rights Reserved**. Reach out to the maintainers before reusing or redistributing.

---
**Maintainers:** @Ravindra2377 and collaborators. For questions, open an issue or contact the team via the channels listed in project documentation.
