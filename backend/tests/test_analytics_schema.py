from app.services.analytics_schema import validate_and_scrub


def test_validate_and_scrub_known_event():
    ok, cleaned, err = validate_and_scrub('mood.create', {'score': 5, 'extra': 'no'})
    assert ok
    assert cleaned['score'] == 5
    assert 'extra' not in cleaned


def test_scrub_email_and_phone():
    ok, cleaned, err = validate_and_scrub('signup', {'method': 'email', 'contact': 'user@example.com'})
    assert ok
    # contact is not allowed for signup so it's dropped
    assert 'contact' not in cleaned

