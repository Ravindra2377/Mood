try:
    from jinja2 import Environment, meta, StrictUndefined
    from jinja2 import select_autoescape
    _JINJA_AVAILABLE = True
    _ENV = Environment(autoescape=select_autoescape(['html', 'xml']), undefined=StrictUndefined)
except Exception:
    _JINJA_AVAILABLE = False

from app.services.i18n import t, t_format, bundle


def render_template(key: str, locale: str = 'en', **context) -> dict:
    """Render a subject/html/text template for the given key and locale.
    Returns a dict with keys: subject, html, text (values may be None).
    If Jinja2 isn't available, falls back to t_format which uses str.format.
    """
    # keys we expect in i18n: {key}_subject, {key}_html, {key}_text
    subj_key = f"{key}_subject"
    html_key = f"{key}_html"
    text_key = f"{key}_text"

    # load raw templates (DB overrides take precedence via t/bundle)
    raw_subj = t(subj_key, locale)
    raw_html = t(html_key, locale)
    raw_text = t(text_key, locale)

    out = {"subject": None, "html": None, "text": None}

    if _JINJA_AVAILABLE:
        try:
            if raw_subj and raw_subj != subj_key:
                tmpl = _ENV.from_string(raw_subj)
                out['subject'] = tmpl.render(**context)
        except Exception:
            out['subject'] = t_format(subj_key, locale, **context)
        try:
            if raw_html and raw_html != html_key:
                tmpl = _ENV.from_string(raw_html)
                out['html'] = tmpl.render(**context)
        except Exception:
            out['html'] = t_format(html_key, locale, **context)
        try:
            if raw_text and raw_text != text_key:
                tmpl = _ENV.from_string(raw_text)
                out['text'] = tmpl.render(**context)
        except Exception:
            out['text'] = t_format(text_key, locale, **context)
    else:
        # fallback: use t_format which uses str.format
        if raw_subj and raw_subj != subj_key:
            out['subject'] = t_format(subj_key, locale, **context)
        if raw_html and raw_html != html_key:
            out['html'] = t_format(html_key, locale, **context)
        if raw_text and raw_text != text_key:
            out['text'] = t_format(text_key, locale, **context)

    return out
