import logging
import sys

# Configure structured security logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] SECURITY: %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('security_audit.log')
    ]
)

security_logger = logging.getLogger("snapsolve_security")

def log_security_event(event_type: String, details: dict):
    """
    Logs sensitive security events with redaction.
    """
    # Redact sensitive info before logging
    sanitized_details = {k: (v if k not in ['password', 'token', 'key'] else '[REDACTED]') for k, v in details.items()}
    security_logger.info(f"Event: {event_type} | Details: {sanitized_details}")
