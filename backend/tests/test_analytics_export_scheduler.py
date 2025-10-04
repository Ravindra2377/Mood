import os
from app.services.analytics_export import export_to_csv, upload_to_s3
from app.services.analytics import _analytics_file


def test_export_to_csv_creates_file(tmp_path, monkeypatch):
    # write a small analytics JSONL
    _analytics_file.parent.mkdir(parents=True, exist_ok=True)
    with _analytics_file.open('w', encoding='utf-8') as fh:
        fh.write('{"event_type":"signup","user_id":1,"props":{},"created_at":"2020-01-01T00:00:00Z"}\n')
    target = tmp_path / 'out.csv'
    out = export_to_csv(str(target))
    assert out is not None
    assert os.path.exists(str(target))


def test_upload_to_s3_fails_without_boto(monkeypatch):
    # simulate boto3 not installed
    import sys
    sys.modules.pop('boto3', None)
    ok = upload_to_s3('bucket', 'key', __file__)
    assert not ok
