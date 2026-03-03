"""
Pydantic schemas for transcripts and analysis
"""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class TranscriptSegment(BaseModel):
    """A segment of transcript with timestamp"""

    text: str
    start: float  # seconds
    end: float  # seconds


class AnalyzeRequest(BaseModel):
    """Request to analyze a transcript"""

    transcript: str = Field(..., min_length=10)
    language: str = Field(..., pattern="^(gu|hi|en|en-IN)$")
    duration_seconds: int = Field(..., gt=0)
    segments: Optional[List[TranscriptSegment]] = None

    # Optional call metadata
    audio_format: Optional[str] = None
    audio_size_bytes: Optional[int] = None
    recorded_at: Optional[datetime] = None


class AnalysisResponse(BaseModel):
    """Analysis results"""

    call_record_id: str
    overall_sentiment: str  # positive, neutral, needs_attention
    confidence: float
    risk_flags: List[str]
    summary: dict  # {bullet_points: [...], key_topics: [...]}
    reasoning: str

    class Config:
        from_attributes = True


class GenerateWhatsAppRequest(BaseModel):
    """Request to generate WhatsApp message"""

    call_record_id: str
    custom_instructions: Optional[str] = None


class GenerateEmailRequest(BaseModel):
    """Request to generate email draft"""

    call_record_id: str
    custom_instructions: Optional[str] = None


class GeneratedContentResponse(BaseModel):
    """Response with generated content"""

    content: str
    language: str
