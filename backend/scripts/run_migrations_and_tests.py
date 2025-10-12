import os
import subprocess
import sys

# Force test DB
os.environ['DATABASE_URL'] = 'sqlite:///./test_db.sqlite3'
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

def run(cmd, env=None):
    res = subprocess.run(cmd, cwd=ROOT, env=env or os.environ, capture_output=True, text=True)
    if res.returncode != 0:
        sys.exit(res.returncode)

# Apply alembic migrations
run([sys.executable, '-m', 'alembic', '-c', 'alembic.ini', 'upgrade', 'head'])
# Run pytest
run([sys.executable, '-m', 'pytest', '-q'])
