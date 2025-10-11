from fastapi import FastAPI, Request
from app.services.i18n import parse_accept_language
from app.services import security
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.controllers import (
    auth,
    moods,
    profile,
    chat,
    gamification,
    personalization,
    community,
    crisis,
    i18n,
)
from app.controllers import admin as admin_controller
from app.controllers import analytics as analytics_controller
from app.controllers import privacy as privacy_controller

DATABASE_URL = settings.DATABASE_URL

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# import models' Base for metadata
from app.models import Base

app = FastAPI(title="mh-ai-app Backend")


@app.middleware("http")
async def accept_language_middleware(request: Request, call_next):
    """Resolve Accept-Language header and attach a normalized locale to request.state.locale.
    Middlewares should be lightweight; deeper resolution (profile override) is handled by the
    `get_locale` dependency which may query the DB.
    """
    al = request.headers.get("accept-language")
    # prefer explicit header parsing with q-values
    try:
        from app.services.i18n import available_locales

        candidate = parse_accept_language(al, available=available_locales())
    except Exception:
        candidate = "en"
    # if there's an Authorization bearer token, try to get profile language and cache it on request
    auth = request.headers.get("authorization")
    profile_lang = None
    if auth and auth.lower().startswith("bearer "):
        token = auth.split(" ", 1)[1].strip()
        try:
            payload = security.decode_access_token(token)
            if payload and "sub" in payload:
                from app.main import SessionLocal
                from app.models.profile import Profile

                db = SessionLocal()
                try:
                    uid = int(payload["sub"])
                    p = db.query(Profile).filter(Profile.user_id == uid).first()
                    if p and getattr(p, "language", None):
                        profile_lang = p.language
                finally:
                    db.close()
        except Exception:
            profile_lang = None

    # precedence: profile_lang > header candidate > default
    locale = profile_lang or candidate or "en"
    request.state.locale = locale
    # store whether the profile lang was used so get_locale can avoid another DB hit
    request.state.profile_locale_cached = True if profile_lang else False
    response = await call_next(request)
    return response


# Read allowed origins from settings.CORS_ORIGINS (comma-separated). Fallback to "*" in dev; empty in prod if unset.
_cors_origins = ["*"]
try:
    _configured = getattr(settings, "CORS_ORIGINS", None)
    if _configured:
        _cors_origins = [o.strip() for o in _configured.split(",") if o.strip()]
    elif not getattr(settings, "DEV_MODE", False):
        # In non-dev, default to empty list if not configured
        _cors_origins = []
except Exception:
    pass

app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    # create all tables from the Declarative Base
    Base.metadata.create_all(bind=engine)
    # start background analytics scheduler if available
    try:
        from app.services.analytics_scheduler import start_scheduler

        start_scheduler()
    except Exception:
        # scheduler optional; don't block startup
        pass
    try:
        from app.services.retention import start_retention_scheduler

        start_retention_scheduler()
    except Exception:
        pass


app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(moods.router, prefix="/api", tags=["moods"])
app.include_router(profile.router, prefix="/api", tags=["profile"])
app.include_router(chat.router, prefix="/api", tags=["chat"])
app.include_router(gamification.router, prefix="/api", tags=["gamification"])
app.include_router(personalization.router, prefix="/api", tags=["personalization"])
app.include_router(community.router, prefix="/api", tags=["community"])
app.include_router(crisis.router, prefix="/api/crisis", tags=["crisis"])
app.include_router(i18n.router, prefix="/api", tags=["i18n"])
app.include_router(
    analytics_controller.router, prefix="/api/analytics", tags=["analytics"]
)
app.include_router(admin_controller.router, prefix="/admin", tags=["admin"])
app.include_router(privacy_controller.router, prefix="/api", tags=["privacy"])


@app.get("/healthz")
def healthz():
    # Database check
    db_ok = True
    try:
        with engine.connect() as conn:
            conn.exec_driver_sql("SELECT 1")
    except Exception:
        db_ok = False

    # Redis check (true if REDIS_URL configured; adjust to actual ping if desired)
    redis_ok = True if getattr(settings, "REDIS_URL", None) else False

    return {"status": "ok", "db": db_ok, "redis": redis_ok}


@app.get("/readyz")
def readyz():
    # Readiness implies dependencies are available and configured
    # DB check
    db_ok = True
    try:
        with engine.connect() as conn:
            conn.exec_driver_sql("SELECT 1")
    except Exception:
        db_ok = False

    # Redis readiness: consider "ready" when configured (adjust to actual ping if desired)
    redis_ok = True if getattr(settings, "REDIS_URL", None) else False

    # Twilio readiness: if DEV_MODE is false, require Twilio credentials
    twilio_ok = True
    try:
        if not getattr(settings, "DEV_MODE", True):
            twilio_ok = all(
                [
                    getattr(settings, "TWILIO_ACCOUNT_SID", None),
                    getattr(settings, "TWILIO_AUTH_TOKEN", None),
                    getattr(settings, "TWILIO_VERIFY_SERVICE_SID", None),
                ]
            )
    except Exception:
        twilio_ok = False

    overall = db_ok and redis_ok and twilio_ok
    return {
        "status": "ready" if overall else "degraded",
        "db": db_ok,
        "redis": redis_ok,
        "twilio": twilio_ok,
    }


@app.get("/")
def root():
    return {"status": "ok"}
