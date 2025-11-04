"""add sentiment metadata to journal entries

Revision ID: n1_add_journal_sentiment_columns
Revises: m1_add_journal_mood_character_count
Create Date: 2025-11-04 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'n1_add_journal_sentiment_columns'
down_revision = 'm1_add_journal_mood_character_count'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('journal_entries', sa.Column('sentiment', sa.String(length=32), nullable=True))
    op.add_column('journal_entries', sa.Column('sentiment_score', sa.Float(), nullable=True))
    op.add_column('journal_entries', sa.Column('keywords', sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column('journal_entries', 'keywords')
    op.drop_column('journal_entries', 'sentiment_score')
    op.drop_column('journal_entries', 'sentiment')
