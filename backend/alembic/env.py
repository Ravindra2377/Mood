import os
import sys
import logging

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from alembic import context
from sqlalchemy import engine_from_config, pool

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# set up simple logging
logging.basicConfig()
logger = logging.getLogger('alembic')
logger.setLevel(logging.INFO)

# add your model's MetaData object here
from app.config import settings
from app.models import __all_models__

# collect metadata from all model modules
target_metadata = None
if __all_models__:
	# pick metadata from first model module that contains classes
	# each model module defined Base.metadata via app.models.Base
	from app.models import Base
	target_metadata = Base.metadata


def run_migrations_offline():
	url = settings.DATABASE_URL
	context.configure(url=url, target_metadata=target_metadata, literal_binds=True)
	with context.begin_transaction():
		context.run_migrations()


def run_migrations_online():
	configuration = config.get_section(config.config_ini_section)
	configuration['sqlalchemy.url'] = settings.DATABASE_URL
	connectable = engine_from_config(configuration, prefix='sqlalchemy.', poolclass=pool.NullPool)
	with connectable.connect() as connection:
		context.configure(connection=connection, target_metadata=target_metadata)
		with context.begin_transaction():
			context.run_migrations()


if context.is_offline_mode():
	run_migrations_offline()
else:
	run_migrations_online()
