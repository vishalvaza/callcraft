"""
Call Record database model
"""
from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base


class CallRecord(Base):
    """Call record with transcript and metadata"""

    __tablename__ = "call_records"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)

    # Call metadata
    duration_seconds = Column(Integer, nullable=False)
    language = Column(String, nullable=False)  # gu, hi, en-IN
    recorded_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Transcript
    transcript = Column(Text, nullable=False)
    segments = Column(JSON, nullable=True)  # Array of {text, start, end} objects

    # File info (audio stays on device, but we track metadata)
    audio_format = Column(String, nullable=True)  # mp3, wav, m4a
    audio_size_bytes = Column(Integer, nullable=True)

    # Relationships
    user = relationship("User", back_populates="call_records")
    analysis = relationship("Analysis", back_populates="call_record", uselist=False, cascade="all, delete-orphan")

    def __repr__(self):
        return f"<CallRecord {self.id} - {self.language} - {self.duration_seconds}s>"


class Analysis(Base):
    """Analysis results for a call"""

    __tablename__ = "analyses"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    call_record_id = Column(String, ForeignKey("call_records.id"), nullable=False, index=True, unique=True)

    # Analysis results
    overall_sentiment = Column(String, nullable=False)  # positive, neutral, needs_attention
    confidence = Column(Float, nullable=False)
    risk_flags = Column(JSON, nullable=True)  # Array of risk flag strings
    reasoning = Column(Text, nullable=True)

    # Summary
    summary_points = Column(JSON, nullable=False)  # Array of bullet points
    key_topics = Column(JSON, nullable=True)  # Array of topic strings

    # Generated content
    whatsapp_message = Column(Text, nullable=True)
    email_draft = Column(Text, nullable=True)

    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    processing_time_ms = Column(Integer, nullable=True)

    # Relationships
    call_record = relationship("CallRecord", back_populates="analysis")

    def __repr__(self):
        return f"<Analysis {self.id} - {self.overall_sentiment}>"
