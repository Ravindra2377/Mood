"""Create consent_events table for consent audit trail

Revision ID: 20251011_01_create_consent_events
Revises: k1
Create Date: 2025-10-11 00:00:00

"""

from alembic import op
import sqlalchemy as sa


# Revision identifiers, used by Alembic.
revision = "20251011_01_create_consent_events"
down_revision = "k1"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create consent_events table (append-only audit records)
    op.create_table(
        "consent_events",
        sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("policy_version", sa.String(), nullable=False),
        sa.Column("tos_accepted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("privacy_accepted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("research_opt_in", sa.Boolean(), nullable=False),
        sa.Column("ip_hash", sa.String(), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("consent_version", sa.String(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )

    # Indexes to support common queries
    op.create_index(
        "ix_consent_events_user_id", "consent_events", ["user_id"], unique=False
    )
    op.create_index(
        "ix_consent_events_created_at", "consent_events", ["created_at"], unique=False
    )
    op.create_index(
        "ix_consent_events_user_id_created_at",
        "consent_events",
        ["user_id", "created_at"],
        unique=False,
    )


def downgrade() -> None:
    # Drop indexes then table
    op.drop_index("ix_consent_events_user_id_created_at", table_name="consent_events")
    op.drop_index("ix_consent_events_created_at", table_name="consent_events")
    op.drop_index("ix_consent_events_user_id", table_name="consent_events")
    op.drop_table("consent_events")
