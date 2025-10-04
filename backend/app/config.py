from pydantic_settings import BaseSettings

class Settings(BaseSettings):
	DATABASE_URL: str = 'sqlite:///./mh.db'
	REDIS_URL: str = 'redis://localhost:6379/0'
	SECRET_KEY: str = 'dev-secret'
	ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
	# Feature flags
	REQUIRE_ADMIN_FOR_REWARDS: bool = False

	# Community settings for member email exposure: 'full', 'masked', 'hidden'
	# - 'full': everyone sees full emails
	# - 'masked': admins see full, non-admins see masked email (default)
	# - 'hidden': only admins see emails; non-admins get None
	COMMUNITY_MEMBER_EMAIL_POLICY: str = 'hidden'

	# Email settings
	SMTP_HOST: str = 'localhost'
	SMTP_PORT: int = 1025
	SMTP_USER: str | None = None
	SMTP_PASSWORD: str | None = None
	EMAIL_FROM: str = 'no-reply@example.com'
	DEV_EMAIL_PREVIEW: bool = True

	# Escalation email for crisis alerts
	ESCALATION_EMAIL: str | None = 'alerts@example.com'

	# Optional ML-based detector
	USE_MODEL_DETECTOR: bool = False
	DETECTOR_MODEL_NAME: str = 'distilbert-base-uncased-finetuned-sst-2-english'

	# Background worker settings for notifications
	ENABLE_BACKGROUND_WORKER: bool = True
	BACKGROUND_WORKER_POLL_SECONDS: int = 1
	BACKGROUND_TASK_MAX_RETRIES: int = 3

	# Optional data encryption key (Fernet urlsafe base64). If provided, sensitive fields
	# (e.g., journal content) will be encrypted at rest. If omitted, plaintext is used.
	DATA_ENCRYPTION_KEY: str | None = None

	# Data retention defaults (days) for automated deletion policies
	DATA_RETENTION_DAYS: int | None = None

	class Config:
		env_file = '.env'

settings = Settings()

