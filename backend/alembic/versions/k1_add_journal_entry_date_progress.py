"""add entry_date and progress to journal_entries

Revision ID: k1_add_journal_entry_date_progress
Revises: f1a2b3c4d5e6
Create Date: 2025-10-05 00:00:00.000000
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'k1_add_journal_entry_date_progress'
down_revision = 'f1a2b3c4d5e6'
branch_labels = None
depends_on = None


def upgrade():
    # Add entry_date (date) and progress (integer) to journal_entries
    op.add_column('journal_entries', sa.Column('entry_date', sa.Date(), nullable=True))
    op.add_column('journal_entries', sa.Column('progress', sa.Integer(), nullable=True))


def downgrade():
    op.drop_column('journal_entries', 'progress')
    op.drop_column('journal_entries', 'entry_date')
