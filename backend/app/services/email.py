import smtplib
from email.message import EmailMessage
from app.config import settings
from pathlib import Path
from datetime import datetime, timezone


def send_email(to: str, subject: str, html_body: str, text_body: str | None = None):
    """Send email. In dev preview mode, write a preview file under tmp/email-previews.
    In production mode, attempt to send via SMTP using configured settings.
    """
    if settings.DEV_EMAIL_PREVIEW:
        out_dir = Path('./tmp/email-previews')
        out_dir.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S')
        fname = out_dir / f"email_{timestamp}_{to.replace('@','_at_')}.html"
        with fname.open('w', encoding='utf-8') as f:
            f.write(f"<h3>To: {to}</h3>\n<h4>{subject}</h4>\n")
            f.write(html_body)
        return {'preview_file': str(fname)}

    # production send via SMTP
    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = settings.EMAIL_FROM
    msg['To'] = to
    if text_body:
        msg.set_content(text_body)
        msg.add_alternative(html_body, subtype='html')
    else:
        msg.set_content(html_body, subtype='html')

    host = settings.SMTP_HOST
    port = settings.SMTP_PORT
    user = settings.SMTP_USER
    pwd = settings.SMTP_PASSWORD

    with smtplib.SMTP(host, port, timeout=10) as s:
        if user and pwd:
            s.starttls()
            s.login(user, pwd)
        s.send_message(msg)
    return {'status': 'sent'}
