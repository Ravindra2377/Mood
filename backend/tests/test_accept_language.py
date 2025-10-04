from app.services.i18n import parse_accept_language


def test_parse_accept_language_q_values():
    header = 'en-US,en;q=0.9,hi-IN;q=0.95,te;q=0.6'
    # available list includes hi and te
    result = parse_accept_language(header, available=['en', 'hi', 'te'])
    # en-US has implicit q=1.0 so 'en' (primary) should be selected
    assert result == 'en'


def test_parse_accept_language_primary_subtag():
    header = 'fr-CA,fr;q=0.8,en;q=0.5'
    # available only has 'en' — should return 'en' as fallback to available
    result = parse_accept_language(header, available=['en'])
    assert result == 'en'
