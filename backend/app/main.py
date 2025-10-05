from fastapi import FastAPI, Request
from app.services.i18n import parse_accept_language
from app.services import security
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.controllers import auth, moods, profile, chat, gamification, personalization, community, crisis, i18n
from app.controllers import timers as timers_controller
from app.controllers import admin as admin_controller
from app.controllers import analytics as analytics_controller
from app.controllers import privacy as privacy_controller

DATABASE_URL = settings.DATABASE_URL

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# import models' Base for metadata
from app.models import Base

app = FastAPI(title='mh-ai-app Backend')


@app.middleware('http')
async def accept_language_middleware(request: Request, call_next):
	"""Resolve Accept-Language header and attach a normalized locale to request.state.locale.
	Middlewares should be lightweight; deeper resolution (profile override) is handled by the
	`get_locale` dependency which may query the DB.
	"""
	al = request.headers.get('accept-language')
	# prefer explicit header parsing with q-values
	try:
		from app.services.i18n import available_locales
		candidate = parse_accept_language(al, available=available_locales())
	except Exception:
		candidate = 'en'
	# if there's an Authorization bearer token, try to get profile language and cache it on request
	auth = request.headers.get('authorization')
	profile_lang = None
	if auth and auth.lower().startswith('bearer '):
		token = auth.split(' ', 1)[1].strip()
		try:
			payload = security.decode_access_token(token)
			if payload and 'sub' in payload:
				from app.main import SessionLocal
				from app.models.profile import Profile
				db = SessionLocal()
				try:
					uid = int(payload['sub'])
					p = db.query(Profile).filter(Profile.user_id == uid).first()
					if p and getattr(p, 'language', None):
						profile_lang = p.language
				finally:
					db.close()
		except Exception:
			profile_lang = None

	# precedence: profile_lang > header candidate > default
	locale = profile_lang or candidate or 'en'
	request.state.locale = locale
	# store whether the profile lang was used so get_locale can avoid another DB hit
	request.state.profile_locale_cached = True if profile_lang else False
	response = await call_next(request)
	return response

app.add_middleware(
	CORSMiddleware,
	allow_origins=["*"],
	allow_credentials=True,
	allow_methods=["*"],
	allow_headers=["*"],
)

@app.on_event('startup')
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

app.include_router(auth.router, prefix='/api/auth', tags=['auth'])
app.include_router(moods.router, prefix='/api', tags=['moods'])
app.include_router(profile.router, prefix='/api', tags=['profile'])
app.include_router(chat.router, prefix='/api', tags=['chat'])
app.include_router(gamification.router, prefix='/api', tags=['gamification'])
app.include_router(personalization.router, prefix='/api', tags=['personalization'])
app.include_router(community.router, prefix='/api', tags=['community'])
app.include_router(crisis.router, prefix='/api/crisis', tags=['crisis'])
app.include_router(i18n.router, prefix='/api', tags=['i18n'])
app.include_router(analytics_controller.router, prefix='/api/analytics', tags=['analytics'])
app.include_router(admin_controller.router, prefix='/admin', tags=['admin'])
app.include_router(privacy_controller.router, prefix='/api', tags=['privacy'])
app.include_router(timers_controller.router, prefix='/api', tags=['timers'])

@app.get('/')
def root():
	return {'status': 'ok'}
