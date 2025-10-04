import logging
import base64
from typing import Tuple, Optional
from app.config import settings

log = logging.getLogger('envelope_crypto')


def _get_kms_client():
    try:
        import importlib
        boto3 = importlib.import_module('boto3')
        return boto3.client('kms', aws_access_key_id=getattr(settings, 'AWS_ACCESS_KEY_ID', None),
                            aws_secret_access_key=getattr(settings, 'AWS_SECRET_ACCESS_KEY', None),
                            region_name=getattr(settings, 'AWS_REGION', None))
    except Exception:
        return None


def generate_data_key(kms_key_id: str) -> Optional[Tuple[bytes, bytes]]:
    """Requests KMS to generate a data key. Returns (plaintext_key_bytes, encrypted_key_bytes) or None.
    encrypted_key_bytes is the ciphertext blob from KMS and plaintext_key_bytes is the raw key.
    """
    client = _get_kms_client()
    if not client:
        log.info('KMS client not available; falling back to local Fernet key generation')
        try:
            from cryptography.fernet import Fernet
            key_b64 = Fernet.generate_key()
            # key_b64 is urlsafe base64; decode to raw 32 bytes for plaintext
            import base64
            plaintext = base64.urlsafe_b64decode(key_b64)
            # for fallback, return plaintext as both plaintext and "encrypted" blob
            return (plaintext, plaintext)
        except Exception:
            log.exception('Failed to generate local key')
            return None

    try:
        resp = client.generate_data_key(KeyId=kms_key_id, KeySpec='AES_256')
        plaintext = resp['Plaintext']
        ciphertext = resp['CiphertextBlob']
        return plaintext, ciphertext
    except Exception:
        log.exception('KMS generate_data_key failed')
        return None


def encrypt_with_data_key(plaintext: str, data_key_plain: bytes) -> str:
    # use Fernet-like (URL-safe base64) wrapper around AES key
    try:
        from cryptography.fernet import Fernet
        # If the data_key_plain is 32 bytes AES key, Fernet expects 32 urlsafe base64 bytes
        import base64
        if len(data_key_plain) == 32:
            fkey = base64.urlsafe_b64encode(data_key_plain)
        else:
            fkey = base64.urlsafe_b64encode(data_key_plain)
        f = Fernet(fkey)
        return f.encrypt(plaintext.encode('utf-8')).decode('utf-8')
    except Exception:
        log.exception('Local encrypt_with_data_key failed; returning plaintext')
        return plaintext


def decrypt_with_data_key(ciphertext: str, data_key_plain: bytes) -> str:
    try:
        from cryptography.fernet import Fernet
        import base64
        fkey = base64.urlsafe_b64encode(data_key_plain)
        f = Fernet(fkey)
        return f.decrypt(ciphertext.encode('utf-8')).decode('utf-8')
    except Exception:
        log.exception('Local decrypt_with_data_key failed; returning ciphertext')
        return ciphertext


def encrypt_for_kms(plaintext: str, kms_key_id: str) -> Optional[Tuple[str, str]]:
    """Creates a data key via KMS, encrypts plaintext with the data key, and returns
    (ciphertext_str, base64_encrypted_data_key) where encrypted data key is base64-encoded.
    """
    res = generate_data_key(kms_key_id)
    if not res:
        return None
    plaintext_key, encrypted_key = res
    try:
        ciphertext = encrypt_with_data_key(plaintext, plaintext_key)
        enc_key_b64 = base64.b64encode(encrypted_key).decode('utf-8')
        return ciphertext, enc_key_b64
    finally:
        # zeroing plaintext_key in memory is difficult in Python; rely on scope
        pass


def decrypt_from_kms(ciphertext: str, encrypted_key_b64: str) -> Optional[str]:
    """Decrypt encrypted_key via KMS to obtain plaintext data key, then decrypt ciphertext.
    encrypted_key_b64 is the base64-encoded KMS CiphertextBlob stored in DB.
    """
    client = _get_kms_client()
    try:
        enc_blob = base64.b64decode(encrypted_key_b64)
    except Exception:
        log.exception('Invalid encrypted_key_b64')
        return ciphertext

    if not client:
        # if no KMS, we assume encrypted_key_b64 actually contains raw key bytes base64
        try:
            data_plain = base64.b64decode(encrypted_key_b64)
            return decrypt_with_data_key(ciphertext, data_plain)
        except Exception:
            log.exception('Failed fallback decrypt without KMS')
            return ciphertext

    try:
        resp = client.decrypt(CiphertextBlob=enc_blob)
        plain = resp['Plaintext']
        return decrypt_with_data_key(ciphertext, plain)
    except Exception:
        log.exception('KMS decrypt failed')
        return ciphertext


def rotate_journal_keys(kms_key_id: str, batch: int = 100):
    """Re-encrypt journal entries with a newly generated data key under kms_key_id.
    This scans journal_entries and for each row with encryption_key present, decrypts using
    the current key and re-encrypts using a new data key. Returns counts.
    """
    from app.main import SessionLocal
    from app.models.journal_entry import JournalEntry
    db = SessionLocal()
    try:
        items = db.query(JournalEntry).filter(JournalEntry.content != None).limit(batch).all()
        changed = 0
        for it in items:
            if not it.encryption_key:
                continue
            try:
                # decrypt with existing encrypted_key
                plaintext = decrypt_from_kms(it.content, it.encryption_key)
                # create new data key and re-encrypt
                res = encrypt_for_kms(plaintext, kms_key_id)
                if res:
                    new_ct, new_enc_key_b64 = res
                    it.content = new_ct
                    it.encryption_key = new_enc_key_b64
                    db.add(it)
                    changed += 1
            except Exception:
                log.exception('Failed rotating journal id %s', getattr(it, 'id', None))
        db.commit()
        return changed
    finally:
        db.close()
