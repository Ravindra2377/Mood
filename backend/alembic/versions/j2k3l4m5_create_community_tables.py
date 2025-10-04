"""create community tables

Revision ID: j2k3l4m5_create_community
Revises: i1e2f3g4_add_engagement_status
Create Date: 2025-10-05 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'j2k3l4m5_create_community'
down_revision = 'i1e2f3g4_add_engagement_status'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table('community_groups',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('key', sa.String(), nullable=False, unique=True),
        sa.Column('title', sa.String(), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('guidelines', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),)

    op.create_table('group_memberships',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('group_id', sa.Integer(), nullable=False),
        sa.Column('role', sa.String(), nullable=True, server_default='member'),
        sa.Column('joined_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
    )

    op.create_table('community_posts',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('group_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('anon', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('title', sa.String(), nullable=True),
        sa.Column('body', sa.Text(), nullable=False),
        sa.Column('removed', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('flagged', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
    )

    op.create_table('community_comments',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('post_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('anon', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('body', sa.Text(), nullable=False),
        sa.Column('removed', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('flagged', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
    )


def downgrade():
    op.drop_table('community_comments')
    op.drop_table('community_posts')
    op.drop_table('group_memberships')
    op.drop_table('community_groups')
