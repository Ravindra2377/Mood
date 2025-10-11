from sqlalchemy import (
    Column,
    Integer,
    String,
    DateTime,
    Boolean,
    ForeignKey,
    Text,
    Index,
)
from datetime import datetime, timezone
from app.models import Base


class ConsentEvent(Base):
    """
    Immutable consent event record for auditing user consent actions.

    Fields:
        id: Primary key.
        user_id: Reference to users.id (no FK constraints beyond ForeignKey).
        policy_version: Version string for the current legal policy set applied at acceptance (e.g., "2025-01").
        tos_accepted_at: UTC timestamp when Terms of Service were accepted.
        privacy_accepted_at: UTC timestamp when Privacy Policy was accepted.
        research_opt_in: Whether the user opted into research/data-use (optional).
        ip_hash: One-way hashed client IP with a secret salt. Never store raw IPs.
        user_agent: Raw user agent string (best-effort, can be None).
        consent_version: An application-level composite or semantic version of the consent set (optional).
        created_at: UTC timestamp when this record was created (event time).

    Notes:
        - This table is append-only to preserve an audit trail. Do not update rows in place.
        - A separate snapshot table (e.g., user_consents) can be used for the latest state if desired.
    """

    __tablename__ = "consent_events"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)

    policy_version = Column(String, nullable=False)

    tos_accepted_at = Column(DateTime(timezone=True), nullable=True)
    privacy_accepted_at = Column(DateTime(timezone=True), nullable=True)

    research_opt_in = Column(Boolean, default=False, nullable=False)

    ip_hash = Column(String, nullable=True)
    user_agent = Column(Text, nullable=True)

    consent_version = Column(String, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
        index=True,
    )

    # Composite index to speed up user-based queries ordered by recency
    __table_args__ = (
        Index("ix_consent_events_user_id_created_at", "user_id", "created_at"),
    )

    def __repr__(self) -> str:
        return (
            f"<ConsentEvent id={self.id} user_id={self.user_id} "
            f"policy_version='{self.policy_version}' consent_version='{self.consent_version}' "
            f"research_opt_in={self.research_opt_in} created_at={self.created_at}>"
        )
