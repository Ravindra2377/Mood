"""add mood and character_count to journal_entries

Revision ID: m1_add_journal_mood_character_count
Revises: k1_add_journal_entry_date_progress
Create Date: 2025-10-19 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'm1_add_journal_mood_character_count'
down_revision = 'k1_add_journal_entry_date_progress'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create enum type for mood
    mood_enum = sa.Enum('angry', 'sad', 'neutral', 'happy', 'excited', name='journalmood')
    mood_enum.create(op.get_bind(), checkfirst=True)
    
    # Add mood column
    op.add_column(
        'journal_entries',
        sa.Column('mood', sa.Enum('angry', 'sad', 'neutral', 'happy', 'excited', name='journalmood'), 
                  nullable=False, server_default='neutral')
    )
    
    # Add character_count column
    op.add_column(
        'journal_entries',
        sa.Column('character_count', sa.Integer(), nullable=True)
    )


def downgrade() -> None:
    op.drop_column('journal_entries', 'character_count')
    op.drop_column('journal_entries', 'mood')
    
    # Drop enum type
    mood_enum = sa.Enum('angry', 'sad', 'neutral', 'happy', 'excited', name='journalmood')
    mood_enum.drop(op.get_bind(), checkfirst=True)
