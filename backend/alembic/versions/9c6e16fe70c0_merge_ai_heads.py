"""merge ai heads

Revision ID: 9c6e16fe70c0
Revises: 20251011_01_create_consent_events, h6b9c0d1, j2k3l4m5_create_community, n1_add_journal_sentiment_columns
Create Date: 2025-11-04 22:10:27.990990
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '9c6e16fe70c0'
down_revision = ('20251011_01_create_consent_events', 'h6b9c0d1', 'j2k3l4m5_create_community', 'n1_add_journal_sentiment_columns')
branch_labels = None
depends_on = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
