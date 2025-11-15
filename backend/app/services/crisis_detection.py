"""
Crisis detection service for identifying crisis keywords and escalation.
"""

import re
import logging
from typing import List, Tuple, Dict, Any

logger = logging.getLogger(__name__)


class CrisisDetector:
    """
    Detects crisis keywords and phrases in user messages.
    Returns severity level and matched keywords.
    """

    CRITICAL_KEYWORDS = [
        # Suicide ideation
        'kill myself', 'end my life', 'want to die', 'suicide',
        'suicidal', 'not worth living', 'better off dead',
        'no reason to live', 'take my life',

        # Self-harm
        'cut myself', 'hurt myself', 'self harm', 'self-harm',
        'overdose', 'pills to die',

        # Immediate danger
        'going to kill', 'plan to die', 'have a plan',
        'wrote a note', 'goodbye letter',
    ]

    HIGH_RISK_KEYWORDS = [
        'hopeless', 'worthless', 'burden', 'trapped',
        'no way out', 'can\'t go on', 'give up',
        'hate myself', 'wish i was dead',
        'everyone would be better without me',
    ]

    MEDIUM_RISK_KEYWORDS = [
        'thoughts of death', 'dark thoughts', 'scary thoughts',
        'intrusive thoughts about dying', 'what\'s the point',
    ]

    def detect(self, text: str) -> Tuple[str, List[str], bool]:
        """
        Detect crisis indicators in text.

        Returns:
            Tuple[severity_level, matched_keywords, is_crisis]
            - severity_level: 'critical', 'high', 'medium', 'low'
            - matched_keywords: List of matched keywords
            - is_crisis: Boolean indicating if immediate intervention needed
        """
        if not text:
            return ('low', [], False)

        text_lower = text.lower()
        matched_keywords = []

        # Check critical keywords
        for keyword in self.CRITICAL_KEYWORDS:
            if keyword in text_lower:
                matched_keywords.append(keyword)

        if matched_keywords:
            logger.warning(f"CRITICAL crisis keywords detected: {matched_keywords}")
            return ('critical', matched_keywords, True)

        # Check high-risk keywords
        for keyword in self.HIGH_RISK_KEYWORDS:
            if keyword in text_lower:
                matched_keywords.append(keyword)

        if len(matched_keywords) >= 2:  # Multiple high-risk indicators
            logger.warning(f"HIGH crisis risk - multiple keywords: {matched_keywords}")
            return ('high', matched_keywords, True)

        if matched_keywords:
            logger.info(f"HIGH crisis risk - single keyword: {matched_keywords}")
            return ('high', matched_keywords, False)

        # Check medium-risk keywords
        for keyword in self.MEDIUM_RISK_KEYWORDS:
            if keyword in text_lower:
                matched_keywords.append(keyword)

        if matched_keywords:
            logger.info(f"MEDIUM crisis risk: {matched_keywords}")
            return ('medium', matched_keywords, False)

        return ('low', [], False)

    def get_crisis_response(self) -> Dict[str, Any]:
        """Returns crisis intervention resources."""
        return {
            'is_crisis': True,
            'message': (
                "I'm really concerned about what you've shared. "
                "Your safety is the top priority right now. "
                "Please reach out to someone who can help immediately."
            ),
            'resources': {
                'suicide_prevention': {
                    'name': '988 Suicide & Crisis Lifeline',
                    'phone': '988',
                    'text': 'Text HOME to 741741',
                    'available': '24/7',
                },
                'emergency': {
                    'name': 'Emergency Services',
                    'phone': '911',
                    'note': 'Call if you\'re in immediate danger',
                },
                'crisis_text': {
                    'name': 'Crisis Text Line',
                    'text': 'Text HOME to 741741',
                    'available': '24/7',
                },
            },
            'immediate_actions': [
                'Call 988 now',
                'Reach out to a trusted friend or family member',
                'Go to your nearest emergency room',
                'Use your safety plan if you have one',
            ],
        }


# Singleton instance
crisis_detector = CrisisDetector()
