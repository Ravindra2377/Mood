Quick notes for running the backend locally with Docker (Windows PowerShell)

1) Copy the example env and edit secrets as needed:

   # In PowerShell
   cp .env.example .env

   # Edit `.env` and set a secure SECRET_KEY before using in a shared/dev environment.

2) Build and run the backend + Postgres from the backend folder:

   # From repository root (adjust path if needed):
   docker compose -f backend/docker-compose.yml up --build

   # Or from backend folder:
   cd backend; docker compose up --build

3) The web service is mapped to http://localhost:8000. Health check endpoint is /healthz.

Notes and rationale
- Using an env file avoids platform-specific inline environment variable assignment (PowerShell's syntax differs
  from Unix shells). That previously caused malformed assignment errors and immediate process shutdown.
- The compose file mounts the project into the container (read-write) for iterative development.
- If you prefer to run outside Docker, create a regular `.env` file and use your normal way to load env vars
  (for example, a VS Code launch configuration that sets environment variables, or use `set`/`$env:` in PowerShell).

---

## Alternative 1: Use a Managed PostgreSQL Service (Recommended for Production)

Instead of running PostgreSQL locally via Docker, you can use a free managed database service. This is also how you'd deploy to production.

### Option A: Supabase (Free Forever Tier)

**What you get:**
- 500 MB PostgreSQL database
- Auto-pauses after 7 days inactivity (resumes instantly on request)
- Built-in dashboard and SQL editor
- Free forever

**Setup steps:**

1. Create account at [supabase.com](https://supabase.com)
2. Create a new project (takes ~2 minutes to provision)
3. Get your connection string:
   - Go to **Project Settings → Database**
   - Copy the **Connection string** (URI format, not session pooler)
   - Example: `postgresql://postgres:[YOUR-PASSWORD]@db.abc123.supabase.co:5432/postgres`
   - Replace `[YOUR-PASSWORD]` with the password you set during project creation

4. Update your `backend/.env`:
   ```env
   DATABASE_URL=postgresql://postgres:your-actual-password@db.projectref.supabase.co:5432/postgres
   SECRET_KEY=your-secret-key-here
   DEV_MODE=true
   ```

5. Run database migrations:
   ```powershell
   cd backend
   python -m alembic upgrade head
   ```

6. Start your backend (no Docker needed):
   ```powershell
   # Set environment variables
   $env:DATABASE_URL="postgresql://postgres:your-password@db.projectref.supabase.co:5432/postgres"
   $env:DEV_MODE="True"
   $env:SECRET_KEY="your-secret-key-here"
   
   # Start uvicorn
   uvicorn app.main:app --reload
   ```

### Option B: Railway (Free $5 Credits/Month)

**What you get:**
- PostgreSQL database with ~500 hours/month runtime
- Auto-scaling and backups
- Built-in CI/CD from GitHub
- $5 free credits monthly (enough for small projects)

**Setup steps:**

1. Create account at [railway.app](https://railway.app)
2. Create a new project → Add PostgreSQL service
3. Get your connection string:
   - Click on the PostgreSQL service
   - Go to **Variables** tab
   - Copy the `DATABASE_URL` value
   - Example: `postgresql://postgres:password@containers.railway.app:1234/railway`

4. Update your `backend/.env`:
   ```env
   DATABASE_URL=postgresql://postgres:password@containers.railway.app:1234/railway
   SECRET_KEY=your-secret-key-here
   DEV_MODE=true
   ```

5. Run migrations and start (same as Supabase steps 5-6 above)

### Option C: Neon (Serverless PostgreSQL - Free Forever)

**What you get:**
- 3 GB storage
- Always-on (doesn't pause like Supabase)
- Serverless architecture
- Free forever

**Setup steps:**

1. Create account at [neon.tech](https://neon.tech)
2. Create a new project
3. Copy the connection string from the dashboard
4. Update `backend/.env` and run migrations (same as above)

### Benefits of Managed Services:
- ✅ No Docker or local PostgreSQL installation needed
- ✅ Automatic backups and high availability
- ✅ Easy to share with team members
- ✅ Same setup works for production
- ✅ Free tiers generous enough for development

---

## Alternative 2: Run Backend Without Docker (SQLite for Development)

For simple local development, you can use SQLite instead of PostgreSQL:

1. Update your `backend/.env`:
   ```env
   DATABASE_URL=sqlite:///./mh.db
   DEV_MODE=True
   SECRET_KEY=dev-secret-key-change-in-prod
   ```

2. Run migrations:
   ```powershell
   cd backend
   python -m alembic upgrade head
   ```

3. Start the backend:
   ```powershell
   # Set environment variables in PowerShell
   $env:DATABASE_URL="sqlite:///./mh.db"
   $env:DEV_MODE="True"
   $env:SECRET_KEY="dev-secret-key"
   
   # Start uvicorn with auto-reload
   uvicorn app.main:app --reload
   ```

**Note:** SQLite is great for development but use PostgreSQL (managed service or Docker) for production.

---

Troubleshooting
- If the API starts and then exits immediately, check logs for messages about missing SECRET_KEY or malformed env values.
- Ensure Docker Desktop is running and you have enough resources assigned (if using Docker).
- For managed services: verify your connection string is correct and network allows connections to the provider's servers.
- If migrations fail: ensure the database exists and credentials are correct.
