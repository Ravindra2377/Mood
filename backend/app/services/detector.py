from app.config import settings
import logging

log = logging.getLogger('detector')

_model = None

def _load_model():
    global _model
    try:
        from transformers import pipeline
        _model = pipeline('text-classification', model=settings.DETECTOR_MODEL_NAME)
        log.info('Loaded detector model %s', settings.DETECTOR_MODEL_NAME)
    except Exception:
        log.exception('Failed to load detector model; falling back to keywords')
        _model = None


def predict_severity(text: str):
    # If model usage disabled, return None
    if not settings.USE_MODEL_DETECTOR:
        return None
    global _model
    if _model is None:
        _load_model()
        if _model is None:
            return None
    try:
        res = _model(text[:1000])
        # Map model outputs to severity: example mapping for sentiment labels
        # This is simplistic: for SST-2 like models, 'LABEL_1' often maps to positive.
        # For a proper production classifier, use a model trained for crisis detection.
        label = res[0].get('label')
        score = res[0].get('score', 0)
        if label and score > 0.7:
            # naive mapping
            if 'NEG' in label or 'LABEL_0' in label:
                return 'high'
            return 'medium'
        return None
    except Exception:
        log.exception('Model inference failed')
        return None
