"""
Database models
"""
from app.models.user import User
from app.models.call_record import CallRecord, Analysis

__all__ = ["User", "CallRecord", "Analysis"]
