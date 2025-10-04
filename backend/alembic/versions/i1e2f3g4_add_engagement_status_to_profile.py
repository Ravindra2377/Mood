"""add engagement_status to profiles

Revision ID: i1e2f3g4_add_engagement_status
Revises: 4fd1da309f17_initial
Create Date: 2025-10-04 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'i1e2f3g4_add_engagement_status'
down_revision = '4fd1da309f17_initial'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('profiles', sa.Column('engagement_status', sa.String(), nullable=True, server_default='inactive'))


def downgrade():
    op.drop_column('profiles', 'engagement_status')
