"""create consent_audits table

Revision ID: d4e6a7b8c9
Revises: c3a9f4b7d2a1
Create Date: 2025-10-04 16:40:00.000000
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'd4e6a7b8c9'
down_revision = 'c3a9f4b7d2a1'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        'consent_audits',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('field', sa.String(), nullable=False),
        sa.Column('old_value', sa.Text(), nullable=True),
        sa.Column('new_value', sa.Text(), nullable=True),
        sa.Column('changed_at', sa.DateTime(), nullable=True),
        sa.Column('source_ip', sa.String(), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_consent_audits_id'), 'consent_audits', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_consent_audits_id'), table_name='consent_audits')
    op.drop_table('consent_audits')
