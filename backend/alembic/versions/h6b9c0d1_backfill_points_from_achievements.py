"""backfill points ledger from existing achievements

Revision ID: h6b9c0d1
Revises: g5a7b8c9d0
Create Date: 2025-10-04 17:45:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import table, column, select

# revision identifiers, used by Alembic.
revision = 'h6b9c0d1'
down_revision = 'g5a7b8c9d0'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Backfill the points_ledger table by summing current achievements per user.
    conn = op.get_bind()
    # create shorthand tables
    achievements = sa.table('achievements',
        sa.column('id', sa.Integer),
        sa.column('user_id', sa.Integer),
        sa.column('points', sa.Integer),
    )

    # compute sum per user
    stmt = sa.select(
        achievements.c.user_id,
        sa.func.coalesce(sa.func.sum(achievements.c.points), 0).label('total')
    ).group_by(achievements.c.user_id)

    results = conn.execute(stmt).fetchall()
    # prepare insert into points_ledger
    for row in results:
        user_id = row[0]
        total = int(row[1] or 0)
        if total == 0:
            continue
        conn.execute(
            sa.text("INSERT INTO points_ledger (user_id, change, reason, created_at) VALUES (:u, :c, :r, CURRENT_TIMESTAMP)"),
            {'u': user_id, 'c': total, 'r': 'backfill:achievements'}
        )


def downgrade() -> None:
    # remove backfill entries (best-effort: those with reason 'backfill:achievements')
    conn = op.get_bind()
    conn.execute(sa.text("DELETE FROM points_ledger WHERE reason = :r"), {'r': 'backfill:achievements'})
