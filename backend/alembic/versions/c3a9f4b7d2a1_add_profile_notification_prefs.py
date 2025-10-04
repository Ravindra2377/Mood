"""add profile notification prefs

Revision ID: c3a9f4b7d2a1
Revises: b2f7c3e9a1d2
Create Date: 2025-10-04 16:05:00.000000
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'c3a9f4b7d2a1'
down_revision = 'b2f7c3e9a1d2'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('profiles', sa.Column('notify_email', sa.Boolean(), nullable=True, server_default=sa.sql.expression.true()))
    op.add_column('profiles', sa.Column('notify_push', sa.Boolean(), nullable=True, server_default=sa.sql.expression.false()))
    op.add_column('profiles', sa.Column('notify_sms', sa.Boolean(), nullable=True, server_default=sa.sql.expression.false()))


def downgrade() -> None:
    op.drop_column('profiles', 'notify_sms')
    op.drop_column('profiles', 'notify_push')
    op.drop_column('profiles', 'notify_email')
