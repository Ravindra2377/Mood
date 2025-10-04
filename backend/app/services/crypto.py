import logging
from app.config import settings

log = logging.getLogger('crypto')


def _get_fernet():
    key = getattr(settings, 'DATA_ENCRYPTION_KEY', None)
    if not key:
        return None
    try:
        from cryptography.fernet import Fernet
        return Fernet(key.encode('utf-8'))
    except Exception:
        log.exception('cryptography.Fernet not available or invalid key')
        return None


def encrypt_text(plaintext: str) -> str:
    # prefer envelope encryption with KMS when configured
    kms_key = getattr(settings, 'KMS_KEY_ID', None)
    if kms_key:
        try:
            from app.services.envelope_crypto import encrypt_for_kms
            res = encrypt_for_kms(plaintext, kms_key)
            if res:
                ciphertext, enc_key_b64 = res
                # return a JSON-like container with ciphertext and wrapped key so callers can store both
                import json
                return json.dumps({'ct': ciphertext, 'ek': enc_key_b64})
        except Exception:
            log.exception('Envelope encryption failed; falling back to local Fernet')

    f = _get_fernet()
    if not f:
        return plaintext
    try:
        return f.encrypt(plaintext.encode('utf-8')).decode('utf-8')
    except Exception:
        log.exception('Failed to encrypt text; returning plaintext')
        return plaintext


def decrypt_text(ciphertext: str) -> str:
    # detect envelope payload format
    try:
        import json
        doc = json.loads(ciphertext)
        if isinstance(doc, dict) and 'ct' in doc and 'ek' in doc:
            # use KMS to decrypt ek then decrypt ct
            kms_key = getattr(settings, 'KMS_KEY_ID', None)
            try:
                from app.services.envelope_crypto import decrypt_from_kms
                return decrypt_from_kms(doc['ct'], doc['ek'])
            except Exception:
                log.exception('Failed to decrypt using KMS envelope; falling back to Fernet')
    except Exception:
        # not JSON, continue to Fernet
        pass

    f = _get_fernet()
    if not f:
        return ciphertext
    try:
        return f.decrypt(ciphertext.encode('utf-8')).decode('utf-8')
    except Exception:
        log.exception('Failed to decrypt text; returning ciphertext')
        return ciphertext
