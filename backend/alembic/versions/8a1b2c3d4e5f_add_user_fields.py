"""add user fields: verification, role, reset token

Revision ID: 8a1b2c3d4e5f
Revises: 4fd1da309f17
Create Date: 2025-10-04 13:45:00.000000
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '8a1b2c3d4e5f'
down_revision = '4fd1da309f17'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # add verification / role / reset fields to users table
    op.add_column('users', sa.Column('is_verified', sa.Boolean(), nullable=False, server_default=sa.text('false')))
    op.add_column('users', sa.Column('role', sa.String(length=50), nullable=False, server_default='user'))
    op.add_column('users', sa.Column('last_login', sa.DateTime(), nullable=True))
    op.add_column('users', sa.Column('password_reset_token', sa.String(), nullable=True))
    op.add_column('users', sa.Column('password_reset_expires', sa.DateTime(), nullable=True))


def downgrade() -> None:
    op.drop_column('users', 'password_reset_expires')
    op.drop_column('users', 'password_reset_token')
    op.drop_column('users', 'last_login')
    op.drop_column('users', 'role')
    op.drop_column('users', 'is_verified')
