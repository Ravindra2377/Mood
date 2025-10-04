from app.services.segment import enqueue_track


def test_enqueue_track_no_config(monkeypatch):
    # should not raise when segment not configured
    enqueue_track('test.event', user_id=1, properties={'foo': 'bar'})
