from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.controllers import auth, moods

DATABASE_URL = settings.DATABASE_URL

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# import models' Base for metadata
from app.models import __all_models__

app = FastAPI(title='mh-ai-app Backend')

app.add_middleware(
	CORSMiddleware,
	allow_origins=["*"],
	allow_credentials=True,
	allow_methods=["*"],
	allow_headers=["*"],
)

@app.on_event('startup')
def on_startup():
	for Base in __all_models__:
		Base.metadata.create_all(bind=engine)

app.include_router(auth.router, prefix='/api/auth', tags=['auth'])
app.include_router(moods.router, prefix='/api', tags=['moods'])

@app.get('/')
def root():
	return {'status': 'ok'}
