"""
Monitoring and analytics configuration
"""
import logging
from datetime import datetime
from typing import Optional
from enum import Enum


class EventType(Enum):
    """Analytics event types"""
    USER_REGISTERED = "user_registered"
    USER_LOGGED_IN = "user_logged_in"
    CALL_ANALYZED = "call_analyzed"
    WHATSAPP_GENERATED = "whatsapp_generated"
    EMAIL_GENERATED = "email_generated"
    ERROR_OCCURRED = "error_occurred"


class Analytics:
    """
    Analytics service for tracking events
    In production, integrate with PostHog, Mixpanel, or similar
    """

    def __init__(self):
        self.logger = logging.getLogger("analytics")

    def track_event(
        self,
        event: EventType,
        user_id: Optional[str] = None,
        properties: Optional[dict] = None,
    ):
        """Track an analytics event"""
        event_data = {
            "event": event.value,
            "user_id": user_id,
            "timestamp": datetime.utcnow().isoformat(),
            "properties": properties or {},
        }

        # Log event (in production, send to analytics service)
        self.logger.info(f"Analytics Event: {event_data}")

        # TODO: Send to PostHog or analytics service
        # posthog.capture(user_id, event.value, properties)

    def track_user_registered(self, user_id: str, subscription_tier: str):
        """Track user registration"""
        self.track_event(
            EventType.USER_REGISTERED,
            user_id=user_id,
            properties={"subscription_tier": subscription_tier},
        )

    def track_user_logged_in(self, user_id: str):
        """Track user login"""
        self.track_event(EventType.USER_LOGGED_IN, user_id=user_id)

    def track_call_analyzed(
        self,
        user_id: str,
        language: str,
        sentiment: str,
        duration_seconds: int,
    ):
        """Track call analysis"""
        self.track_event(
            EventType.CALL_ANALYZED,
            user_id=user_id,
            properties={
                "language": language,
                "sentiment": sentiment,
                "duration_seconds": duration_seconds,
            },
        )

    def track_generation(
        self,
        user_id: str,
        generation_type: str,  # whatsapp or email
        language: str,
    ):
        """Track content generation"""
        event = (
            EventType.WHATSAPP_GENERATED
            if generation_type == "whatsapp"
            else EventType.EMAIL_GENERATED
        )

        self.track_event(
            event,
            user_id=user_id,
            properties={"language": language},
        )

    def track_error(
        self,
        error_type: str,
        error_message: str,
        user_id: Optional[str] = None,
    ):
        """Track error"""
        self.track_event(
            EventType.ERROR_OCCURRED,
            user_id=user_id,
            properties={
                "error_type": error_type,
                "error_message": error_message,
            },
        )


# Global analytics instance
analytics = Analytics()


# Application monitoring
class HealthMetrics:
    """Track application health metrics"""

    def __init__(self):
        self.total_requests = 0
        self.total_errors = 0
        self.total_analyses = 0
        self.average_response_time = 0.0

    def increment_requests(self):
        """Increment total requests counter"""
        self.total_requests += 1

    def increment_errors(self):
        """Increment error counter"""
        self.total_errors += 1

    def increment_analyses(self):
        """Increment analyses counter"""
        self.total_analyses += 1

    def update_response_time(self, response_time_ms: float):
        """Update average response time"""
        # Simple moving average
        self.average_response_time = (
            self.average_response_time * 0.9 + response_time_ms * 0.1
        )

    def get_metrics(self) -> dict:
        """Get current metrics"""
        return {
            "total_requests": self.total_requests,
            "total_errors": self.total_errors,
            "total_analyses": self.total_analyses,
            "average_response_time_ms": round(self.average_response_time, 2),
            "error_rate": (
                (self.total_errors / self.total_requests * 100)
                if self.total_requests > 0
                else 0
            ),
        }


# Global health metrics
health_metrics = HealthMetrics()
