"""add points ledger and claimed_rewards refund fields

Revision ID: g5a7b8c9d0
Revises: c3a9f4b7d2a1
Create Date: 2025-10-04 17:30:00.000000
"""

from alembic import op
import sqlalchemy as sa


def _has_table(table: str) -> bool:
    inspector = sa.inspect(op.get_bind())
    return inspector.has_table(table)


def _column_names(table: str) -> set[str]:
    inspector = sa.inspect(op.get_bind())
    return {col["name"] for col in inspector.get_columns(table)}

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

    # Ensure claimed_rewards table exists before altering it
    if not _has_table('claimed_rewards'):
        op.create_table(
            'claimed_rewards',
            sa.Column('id', sa.Integer(), primary_key=True, nullable=False),
            sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False),
            sa.Column('reward_id', sa.Integer(), sa.ForeignKey('rewards.id'), nullable=False),
            sa.Column('metadata', sa.Text(), nullable=True),
            sa.Column('refunded', sa.Integer(), nullable=False, server_default='0'),
            sa.Column('refunded_at', sa.DateTime(timezone=True), nullable=True),
            sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('(CURRENT_TIMESTAMP)')),
        )
    else:
        existing = _column_names('claimed_rewards')
        if 'refunded' not in existing:
            op.add_column('claimed_rewards', sa.Column('refunded', sa.Integer(), nullable=False, server_default='0'))
        if 'refunded_at' not in existing:
            op.add_column('claimed_rewards', sa.Column('refunded_at', sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    if _has_table('claimed_rewards'):
        existing = _column_names('claimed_rewards')
        if 'refunded_at' in existing:
            op.drop_column('claimed_rewards', 'refunded_at')
        if 'refunded' in existing:
            op.drop_column('claimed_rewards', 'refunded')
    if _has_table('points_ledger'):
        op.drop_table('points_ledger')
