"""add source_ua to consent_audits

Revision ID: e5f6a7b8c9
Revises: d4e6a7b8c9
Create Date: 2025-10-04 17:10:00.000000
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'e5f6a7b8c9'
down_revision = 'd4e6a7b8c9'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('consent_audits', sa.Column('source_ua', sa.String(), nullable=True))


def downgrade() -> None:
    op.drop_column('consent_audits', 'source_ua')
