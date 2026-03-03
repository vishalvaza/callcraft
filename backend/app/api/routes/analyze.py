"""
Analysis routes - Transcript analysis and content generation
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user_id
from app.models.user import User
from app.models.call_record import CallRecord, Analysis
from app.schemas.transcript import (
    AnalyzeRequest,
    AnalysisResponse,
    GenerateWhatsAppRequest,
    GenerateEmailRequest,
    GeneratedContentResponse,
)
from app.services.analysis_service import analysis_service

router = APIRouter()


@router.post("/", response_model=AnalysisResponse)
async def analyze_transcript(
    request: AnalyzeRequest,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """
    Analyze a call transcript

    Takes a transcript and returns:
    - Overall sentiment (positive/neutral/needs_attention)
    - Confidence score
    - Risk flags (pricing issues, complaints, etc.)
    - Summary bullet points
    - Key topics
    - Reasoning
    """
    # Verify user exists
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Check subscription limits (free tier = 10 calls/month)
    # TODO: Implement subscription checking logic
    # For now, allow all requests

    # Perform analysis
    try:
        analysis_result = await analysis_service.analyze_transcript(
            transcript=request.transcript,
            language=request.language,
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analysis failed: {str(e)}",
        )

    # Save call record
    call_record = CallRecord(
        user_id=user_id,
        duration_seconds=request.duration_seconds,
        language=request.language,
        transcript=request.transcript,
        segments=[seg.dict() for seg in request.segments] if request.segments else None,
        audio_format=request.audio_format,
        audio_size_bytes=request.audio_size_bytes,
        recorded_at=request.recorded_at,
    )
    db.add(call_record)
    db.flush()  # Get call_record.id

    # Save analysis
    analysis = Analysis(
        call_record_id=call_record.id,
        overall_sentiment=analysis_result["overall_sentiment"],
        confidence=analysis_result["confidence"],
        risk_flags=analysis_result["risk_flags"],
        reasoning=analysis_result["reasoning"],
        summary_points=analysis_result["summary_points"],
        key_topics=analysis_result["key_topics"],
        processing_time_ms=analysis_result.get("processing_time_ms"),
    )
    db.add(analysis)
    db.commit()
    db.refresh(analysis)

    # Return response
    return AnalysisResponse(
        call_record_id=call_record.id,
        overall_sentiment=analysis.overall_sentiment,
        confidence=analysis.confidence,
        risk_flags=analysis.risk_flags,
        summary={
            "bullet_points": analysis.summary_points,
            "key_topics": analysis.key_topics,
        },
        reasoning=analysis.reasoning,
    )


@router.get("/{call_record_id}", response_model=AnalysisResponse)
async def get_analysis(
    call_record_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Get existing analysis for a call record"""

    # Find call record
    call_record = db.query(CallRecord).filter(
        CallRecord.id == call_record_id,
        CallRecord.user_id == user_id,
    ).first()

    if not call_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Call record not found",
        )

    # Get analysis
    analysis = call_record.analysis
    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Analysis not found for this call",
        )

    return AnalysisResponse(
        call_record_id=call_record.id,
        overall_sentiment=analysis.overall_sentiment,
        confidence=analysis.confidence,
        risk_flags=analysis.risk_flags,
        summary={
            "bullet_points": analysis.summary_points,
            "key_topics": analysis.key_topics,
        },
        reasoning=analysis.reasoning,
    )


@router.post("/generate/whatsapp", response_model=GeneratedContentResponse)
async def generate_whatsapp_message(
    request: GenerateWhatsAppRequest,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Generate WhatsApp follow-up message based on call analysis"""

    # Find call record and analysis
    call_record = db.query(CallRecord).filter(
        CallRecord.id == request.call_record_id,
        CallRecord.user_id == user_id,
    ).first()

    if not call_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Call record not found",
        )

    analysis = call_record.analysis
    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Analysis not found for this call",
        )

    # Generate WhatsApp message
    try:
        analysis_dict = {
            "overall_sentiment": analysis.overall_sentiment,
            "summary_points": analysis.summary_points,
            "risk_flags": analysis.risk_flags,
        }

        whatsapp_message = await analysis_service.generate_whatsapp_message(
            transcript=call_record.transcript,
            analysis=analysis_dict,
            language=call_record.language,
            custom_instructions=request.custom_instructions,
        )

        # Save to analysis record
        analysis.whatsapp_message = whatsapp_message
        db.commit()

        return GeneratedContentResponse(
            content=whatsapp_message,
            language=call_record.language,
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Generation failed: {str(e)}",
        )


@router.post("/generate/email", response_model=GeneratedContentResponse)
async def generate_email_draft(
    request: GenerateEmailRequest,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Generate email draft based on call analysis"""

    # Find call record and analysis
    call_record = db.query(CallRecord).filter(
        CallRecord.id == request.call_record_id,
        CallRecord.user_id == user_id,
    ).first()

    if not call_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Call record not found",
        )

    analysis = call_record.analysis
    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Analysis not found for this call",
        )

    # Generate email draft
    try:
        analysis_dict = {
            "overall_sentiment": analysis.overall_sentiment,
            "summary_points": analysis.summary_points,
            "risk_flags": analysis.risk_flags,
        }

        email_draft = await analysis_service.generate_email_draft(
            transcript=call_record.transcript,
            analysis=analysis_dict,
            language=call_record.language,
            custom_instructions=request.custom_instructions,
        )

        # Save to analysis record
        analysis.email_draft = email_draft
        db.commit()

        return GeneratedContentResponse(
            content=email_draft,
            language="en" if call_record.language in ["en", "en-IN"] else "hi",
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Generation failed: {str(e)}",
        )
