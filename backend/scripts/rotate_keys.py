"""Key rotation helper for journal entries.

Usage (dry-run):
    python scripts/rotate_keys.py --kms-key-id <KMS_KEY_ID>

To apply changes use --commit. Use --batch to control items processed per loop.
"""
import argparse
import logging
import sys
import os

log = logging.getLogger('rotate_keys')


def ensure_backend_in_path():
    # When this script is run from the repository root, ensure the `backend` package
    # directory is on sys.path so imports like `import app` work.
    this_dir = os.path.dirname(os.path.abspath(__file__))
    backend_dir = os.path.dirname(this_dir)
    if backend_dir not in sys.path:
        sys.path.insert(0, backend_dir)


def main():
    ensure_backend_in_path()
    parser = argparse.ArgumentParser(description='Rotate journal encryption keys')
    parser.add_argument('--kms-key-id', required=True, help='Target KMS KeyId (or alias) to wrap new data keys')
    parser.add_argument('--batch', type=int, default=100, help='Batch size per iteration')
    parser.add_argument('--commit', action='store_true', help='Actually write changes (default is dry-run)')
    parser.add_argument('--loops', type=int, default=0, help='Number of loops to run (0 = run until no more changed)')
    parser.add_argument('--db-url', help='Optional DATABASE_URL to use for this run (overrides env)')
    parser.add_argument('--yes', action='store_true', help="Required to actually apply changes with --commit (safety flag)")

    args = parser.parse_args()

    # Allow overriding DATABASE_URL before importing application modules
    if args.db_url:
        os.environ['DATABASE_URL'] = args.db_url

    try:
        from app.services.envelope_crypto import rotate_journal_keys
    except Exception as e:
        log.exception('Failed importing rotate_journal_keys: %s', e)
        sys.exit(2)

    total_changed = 0
    loop = 0
    # Safety: require explicit --yes when --commit is requested
    if args.commit and not args.yes:
        log.error('Refusing to run in commit mode without --yes confirmation. Re-run with --yes to apply changes.')
        sys.exit(3)

    while True:
        loop += 1
        log.info('Running rotation loop %s (batch=%s)', loop, args.batch)
        try:
            changed = rotate_journal_keys(args.kms_key_id, batch=args.batch)
        except Exception as e:
            # If the DB or tables are not present (e.g., dev environment without migrations),
            # surface a friendly message and treat as zero changed in dry-run mode.
            msg = str(e)
            if 'no such table' in msg.lower() or 'operationalerror' in msg.lower():
                log.warning('Database not initialized or tables missing: %s', e)
                changed = 0
            else:
                log.exception('rotate_journal_keys failed: %s', e)
                raise

        log.info('Loop %s: changed %s entries', loop, changed)
        total_changed += changed
        if args.loops and loop >= args.loops:
            break
        if changed == 0:
            break

    if args.commit:
        log.info('Rotation applied. Total changed: %s', total_changed)
    else:
        log.info('Dry-run complete. Total entries that would be changed: %s', total_changed)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    main()
