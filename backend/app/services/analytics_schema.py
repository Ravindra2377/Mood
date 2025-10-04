import re
from typing import Dict, Any, Tuple
import logging

log = logging.getLogger('analytics_schema')


# simple allowed event definitions. In production this would be a configurable schema
EVENT_SCHEMAS = {
    'signup': {'required': [], 'allowed': ['method']},
    'login': {'required': [], 'allowed': ['method']},
    'mood.create': {'required': ['score'], 'allowed': ['score', 'source']},
    'community.post': {'required': ['group', 'post_id'], 'allowed': ['group', 'post_id', 'anon']},
    'community.comment': {'required': ['post_id', 'comment_id'], 'allowed': ['post_id', 'comment_id', 'anon']},
    'crisis.detected': {'required': ['severity'], 'allowed': ['severity', 'match']},
}


def _scrub_value(v: Any) -> Any:
    """Scrub obvious PII values: emails, phone numbers, long strings.

    This is intentionally conservative: we replace with placeholders when likely PII.
    """
    if isinstance(v, str):
        # email
        if re.search(r"\b[\w.-]+@[\w.-]+\.[A-Za-z]{2,6}\b", v):
            return '<REDACTED_EMAIL>'
        # phone (very loose)
        if re.sub(r"\D", "", v) and len(re.sub(r"\D", "", v)) >= 7:
            return '<REDACTED_PHONE>'
        # long free-form text -> truncate
        if len(v) > 200:
            return v[:200] + '...'
    return v


def validate_and_scrub(event_type: str, props: Dict[str, Any]) -> Tuple[bool, Dict[str, Any], str | None]:
    """Validate props against EVENT_SCHEMAS and scrub PII.

    Returns (ok, cleaned_props, error_message)
    """
    schema = EVENT_SCHEMAS.get(event_type)
    if not schema:
        # unknown events are allowed but flagged
        log.warning('Unknown analytics event type: %s', event_type)
        cleaned = {k: _scrub_value(v) for k, v in (props or {}).items()}
        return True, cleaned, None

    cleaned = {}
    for k, v in (props or {}).items():
        if k in schema['allowed']:
            cleaned[k] = _scrub_value(v)
        else:
            # ignore disallowed keys
            log.warning('Dropping disallowed analytics prop %s for event %s', k, event_type)

    # check required
    for req in schema.get('required', []):
        if req not in cleaned:
            return False, cleaned, f'missing required prop: {req}'

    return True, cleaned, None
