import json
from pathlib import Path
from functools import lru_cache
from typing import Dict
from app.models.translation import Translation
import re
from typing import List, Tuple

_i18n_dir = Path(__file__).parent.parent / 'i18n'


@lru_cache()
def load_locale(locale: str) -> Dict[str, str]:
    p = _i18n_dir / f"{locale}.json"
    if not p.exists():
        return {}
    try:
        return json.loads(p.read_text(encoding='utf-8'))
    except Exception:
        return {}


def t(key: str, locale: str = 'en') -> str:
    # check DB overrides first
    # lazy import to avoid circular import with app.main
    try:
        from app.main import SessionLocal
    except Exception:
        SessionLocal = None
    if SessionLocal:
        db = SessionLocal()
        try:
            tr = db.query(Translation).filter(Translation.locale == locale, Translation.key == key).first()
            if tr:
                return tr.value
        finally:
            db.close()

    loc = load_locale(locale)
    return loc.get(key, key)


def t_format(key: str, locale: str = 'en', **kwargs) -> str:
    """Translate and format with kwargs using python format(). Supports simple pluralization using '||' separator.
    For pluralization, translation string can be 'one|many' or 'singular||plural' and the function will pick based on 'count' kwarg.
    """
    raw = t(key, locale)
    # basic plural handling
    if '||' in raw and 'count' in kwargs:
        parts = raw.split('||')
        try:
            c = int(kwargs.get('count', 0))
        except Exception:
            c = 0
        raw = parts[0] if c == 1 else (parts[1] if len(parts) > 1 else parts[0])
    try:
        return raw.format(**kwargs)
    except Exception:
        return raw


def bundle(locale: str = 'en') -> Dict[str, str]:
    """Return merged translations from JSON file and DB overrides."""
    out = load_locale(locale).copy()
    # lazy DB access to avoid circular imports at module import time
    try:
        from app.main import SessionLocal
    except Exception:
        SessionLocal = None
    if SessionLocal:
        db = SessionLocal()
        try:
            rows = db.query(Translation).filter(Translation.locale == locale).all()
            for r in rows:
                out[r.key] = r.value
        finally:
            db.close()
    return out


def parse_accept_language(header_value: str, available: List[str] | None = None) -> str:
    """Parse Accept-Language header with q-values and return the best matching locale.
    If available is provided, prefer matches from that list; otherwise return the primary tag.
    Examples: 'en-US,en;q=0.9,es;q=0.8' -> 'en'
    """
    if not header_value:
        return 'en'
    parts = [p.strip() for p in header_value.split(',') if p.strip()]
    parsed: List[Tuple[str, float]] = []
    for p in parts:
        if ';' in p:
            tag, rest = p.split(';', 1)
            m = re.search(r'q=([0-9\.]+)', rest)
            q = float(m.group(1)) if m else 1.0
        else:
            tag = p
            q = 1.0
        parsed.append((tag.lower(), q))
    # sort by q desc
    parsed.sort(key=lambda x: x[1], reverse=True)
    if not available:
        # return primary subtag of highest q
        top = parsed[0][0]
        if '-' in top:
            return top.split('-')[0]
        return top
    # match against available locales
    for tag, _ in parsed:
        # direct match
        if tag in available:
            return tag
        # primary subtag match
        if '-' in tag:
            primary = tag.split('-')[0]
            if primary in available:
                return primary
    # fallback to first available or 'en'
    return available[0] if available else 'en'


def available_locales() -> List[str]:
    """Return list of available locale basenames based on files in the i18n folder."""
    try:
        files = [_i18n_dir.joinpath(f).name for f in _i18n_dir.iterdir() if f.suffix == '.json']
        locales = [Path(f).stem for f in files]
        # ensure 'en' is present as fallback
        if 'en' not in locales:
            locales.insert(0, 'en')
        return locales
    except Exception:
        return ['en']
