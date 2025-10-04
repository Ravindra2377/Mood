import base64
from app.services.envelope_crypto import encrypt_for_kms, decrypt_from_kms
from unittest.mock import patch


def test_local_encrypt_decrypt_no_kms(monkeypatch):
    # simulate no boto3/KMS available by ensuring _get_kms_client returns None
    from app.services import envelope_crypto
    monkeypatch.setattr(envelope_crypto, '_get_kms_client', lambda: None)
    res = encrypt_for_kms('hello world', 'dummy-kms-id')
    assert res is not None
    ct, enc = res
    assert ct != 'hello world'
    # decrypt fallback (encrypted key will actually be the plaintext key in base64)
    plain = decrypt_from_kms(ct, enc)
    assert plain == 'hello world'
