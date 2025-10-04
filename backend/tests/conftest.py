import os

# Ensure tests use a file-backed SQLite DB so tables persist across connections
# Force this to avoid hitting a local Postgres instance during test runs
os.environ['DATABASE_URL'] = 'sqlite:///./test_db.sqlite3'

# remove any existing test DB file before importing/initializing the app so the app's
# startup hooks and TestClient see a clean schema and no pre-existing users
test_db_path = os.path.join(os.path.dirname(__file__), 'test_db.sqlite3')
if os.path.exists(test_db_path):
    try:
        os.remove(test_db_path)
    except Exception:
        pass

from app.main import engine
from app.models import Base


def pytest_configure(config):
    # ensure schema matches current models: drop all and recreate
    try:
        Base.metadata.drop_all(bind=engine)
    except Exception:
        pass
    Base.metadata.create_all(bind=engine)
