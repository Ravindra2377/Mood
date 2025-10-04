import importlib
import sys
import traceback
from pathlib import Path


def main():
    # Ensure project root (backend/) is on sys.path so 'app' package is importable
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    sys.path.insert(0, str(project_root))
    try:
        importlib.import_module('app.main')
        print('App import OK')
    except Exception:
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
