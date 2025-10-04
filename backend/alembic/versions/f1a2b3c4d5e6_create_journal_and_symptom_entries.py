"""create journal and symptom entries

Revision ID: f1a2b3c4d5e6
Revises: e5f6a7b8c9_add_source_ua_to_consent_audits
Create Date: 2025-10-04 00:00:00.000000
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'f1a2b3c4d5e6'
down_revision = 'e5f6a7b8c9_add_source_ua_to_consent_audits'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'journal_entries',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(), nullable=True),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
    )
    op.create_table(
        'symptom_entries',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('symptom', sa.String(), nullable=False),
        sa.Column('severity', sa.Integer(), nullable=True),
        sa.Column('note', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
    )


def downgrade():
    op.drop_table('symptom_entries')
    op.drop_table('journal_entries')
