from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

# import models so their classes are registered with Base metadata
from app.models import user  # noqa: F401
from app.models import mood_entry  # noqa: F401

# expose for main.py
__all_models__ = [user, mood_entry]
