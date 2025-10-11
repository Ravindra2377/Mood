from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./mh.db"
    REDIS_URL: str = "redis://localhost:6379/0"
    SECRET_KEY: str = "dev-secret"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # Development mode and CORS
    DEV_MODE: bool = True
    # Comma-separated list of allowed origins (e.g., "https://app.soulapp.app,https://staging.soulapp.app")
    CORS_ORIGINS: str | None = None

    # Twilio Verify (SMS OTP) credentials
    TWILIO_ACCOUNT_SID: str | None = None
    TWILIO_AUTH_TOKEN: str | None = None
    TWILIO_VERIFY_SERVICE_SID: str | None = None

    # Feature flags

    REQUIRE_ADMIN_FOR_REWARDS: bool = False

    # Community settings for member email exposure: 'full', 'masked', 'hidden'

    # - 'full': everyone sees full emails

    # - 'masked': admins see full, non-admins see masked email (default)

    # - 'hidden': only admins see emails; non-admins get None

    COMMUNITY_MEMBER_EMAIL_POLICY: str = "hidden"

    # Email settings
    SMTP_HOST: str = "localhost"
    SMTP_PORT: int = 1025

    SMTP_USER: str | None = None

    SMTP_PASSWORD: str | None = None

    EMAIL_FROM: str = "no-reply@example.com"
    DEV_EMAIL_PREVIEW: bool = True

    # Escalation email for crisis alerts

    ESCALATION_EMAIL: str | None = "alerts@example.com"

    # Optional ML-based detector

    USE_MODEL_DETECTOR: bool = False

    DETECTOR_MODEL_NAME: str = "distilbert-base-uncased-finetuned-sst-2-english"

    # Background worker settings for notifications

    ENABLE_BACKGROUND_WORKER: bool = True

    BACKGROUND_WORKER_POLL_SECONDS: int = 1

    BACKGROUND_TASK_MAX_RETRIES: int = 3

    # Optional data encryption key (Fernet urlsafe base64). If provided, sensitive fields

    # (e.g., journal content) will be encrypted at rest. If omitted, plaintext is used.

    DATA_ENCRYPTION_KEY: str | None = None

    # Data retention defaults (days) for automated deletion policies

    DATA_RETENTION_DAYS: int | None = None

    # Rate limiting configuration
    RATELIMIT_ENABLED: bool = True
    # Comma-separated CIDRs or IPs for trusted proxies/LBs (e.g., "10.0.0.0/8,127.0.0.1/32")
    RATELIMIT_TRUSTED_PROXIES: str | None = None
    RATELIMIT_DEFAULT_PER_IP: str = "100/minute"
    RATELIMIT_OTP_REQUEST_PER_IP: str = "20/hour"

        RATELIMIT_OTP_VERIFY_PER_IP: str = "60/hour"



        # Legal and consent configuration
        LEGAL_TOS_VERSION: str = "v1"
        LEGAL_PRIVACY_VERSION: str = "v1"
        LEGAL_RESEARCH_CONSENT_VERSION: str | None = None
        LEGAL_PRIVACY_URL: str = "https://example.com/legal/privacy"
        LEGAL_TERMS_URL: str = "https://example.com/legal/terms"
        CONSENT_IP_HASH_SALT: str | None = None

        class Config:

            env_file = ".env"



settings = Settings()
