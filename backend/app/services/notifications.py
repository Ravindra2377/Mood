from app.services.email import send_email
from app.config import settings
from app.services.task_queue import enqueue
import logging
from app.services.templates import render_template

log = logging.getLogger('notifications')


def _do_escalation_email(to: str, subject: str, html_body: str, text_body: str | None = None):
    send_email(to=to, subject=subject, html_body=html_body, text_body=text_body)


def escalate_alert_email(subject: str, html_body: str, text_body: str | None = None):
    to = settings.ESCALATION_EMAIL
    if not to:
        log.warning('No ESCALATION_EMAIL configured; skipping escalation email')
        return {'status': 'skipped'}
    # enqueue background task
    enqueue(_do_escalation_email, to, subject, html_body, text_body)
    return {'status': 'enqueued'}


def escalate_alert_for_user(template_key: str, user_id: int, locale: str = 'en', **context):
    """Render templates by key (using `app/services/templates.render_template`) and enqueue escalation email to configured address.
    This is a convenience for callers that want to provide a template key instead of composing raw strings.
    """
    rendered = render_template(template_key, locale, **context)
    subject = rendered.get('subject') or f"[ALERT] {template_key}"
    html = rendered.get('html')
    text = rendered.get('text')
    return escalate_alert_email(subject, html, text)


def _do_push_stub(user_id: int, message: str):
    log.info('Push stub to user %s: %s', user_id, message)


def push_alert_stub(user_id: int, message: str):
    enqueue(_do_push_stub, user_id, message)
    return {'status': 'enqueued'}
