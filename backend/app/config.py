from pydantic_settings import BaseSettings

class Settings(BaseSettings):
	DATABASE_URL: str = 'sqlite:///./mh.db'
	REDIS_URL: str = 'redis://localhost:6379/0'
	SECRET_KEY: str = 'dev-secret'
	ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

	class Config:
		env_file = '.env'

settings = Settings()

