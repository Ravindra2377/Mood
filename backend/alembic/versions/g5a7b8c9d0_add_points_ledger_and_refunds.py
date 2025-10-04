"""add points ledger and claimed_rewards refund fields

Revision ID: g5a7b8c9d0
Revises: c3a9f4b7d2a1
Create Date: 2025-10-04 17:30:00.000000
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'g5a7b8c9d0'
down_revision = 'c3a9f4b7d2a1'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # create points_ledger table
    op.create_table(
        'points_ledger',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('user_id', sa.Integer(), nullable=False, index=True),
        sa.Column('change', sa.Integer(), nullable=False),
        sa.Column('reason', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('(CURRENT_TIMESTAMP)')),
    )

    # add refunded and refunded_at to claimed_rewards
    op.add_column('claimed_rewards', sa.Column('refunded', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('claimed_rewards', sa.Column('refunded_at', sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column('claimed_rewards', 'refunded_at')
    op.drop_column('claimed_rewards', 'refunded')
    op.drop_table('points_ledger')
