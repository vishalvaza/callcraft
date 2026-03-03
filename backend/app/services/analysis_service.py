"""
Analysis Service - Business logic for call transcript analysis
"""
import logging
from typing import Dict, List
from datetime import datetime
import time

from app.services.llm_service import llm_service

logger = logging.getLogger(__name__)


class AnalysisService:
    """Service for analyzing call transcripts"""

    # Risk flags to detect
    RISK_FLAGS = [
        "pricing_objection",
        "customer_unhappy",
        "complaint",
        "payment_delay",
        "delivery_issue",
        "competitor_mention",
        "cancellation_request",
        "quality_concern",
        "urgent_attention",
    ]

    def __init__(self):
        self.llm = llm_service

    async def analyze_transcript(
        self,
        transcript: str,
        language: str,
    ) -> Dict:
        """
        Analyze a call transcript

        Args:
            transcript: The call transcript text
            language: Language code (gu, hi, en-IN)

        Returns:
            Analysis results dict with sentiment, risk_flags, summary, etc.
        """
        start_time = time.time()

        # Build analysis prompt
        system_prompt = self._build_system_prompt(language)
        user_prompt = self._build_analysis_prompt(transcript, language)

        # Get LLM analysis
        analysis_result = await self.llm.generate_json(
            prompt=user_prompt,
            system_prompt=system_prompt,
            temperature=0.7,
        )

        # Validate and normalize result
        normalized_result = self._normalize_analysis_result(analysis_result)

        # Calculate processing time
        processing_time_ms = int((time.time() - start_time) * 1000)
        normalized_result["processing_time_ms"] = processing_time_ms

        return normalized_result

    def _build_system_prompt(self, language: str) -> str:
        """Build system prompt for the LLM"""
        lang_names = {
            "gu": "Gujarati",
            "hi": "Hindi",
            "en": "English",
            "en-IN": "Hinglish (English-Hindi mix)",
        }
        lang_name = lang_names.get(language, "the call language")

        return f"""You are an expert sales call analyst for Indian businesses. You analyze call transcripts in {lang_name} and provide actionable insights.

Your task is to:
1. Determine the overall sentiment (positive, neutral, or needs_attention)
2. Identify any risk flags (pricing issues, complaints, delays, etc.)
3. Generate a concise summary with 3-5 key bullet points
4. Extract key topics discussed
5. Provide reasoning for your sentiment assessment

Be culturally aware and understand Indian business contexts, regional language nuances, and common sales scenarios."""

    def _build_analysis_prompt(self, transcript: str, language: str) -> str:
        """Build analysis prompt with transcript"""
        risk_flags_list = ", ".join(self.RISK_FLAGS)

        return f"""Analyze this sales call transcript:

---
{transcript}
---

Provide analysis in the following JSON format:

{{
  "overall_sentiment": "positive|neutral|needs_attention",
  "confidence": 0.0-1.0,
  "risk_flags": ["risk1", "risk2"],
  "summary_points": ["point1", "point2", "point3"],
  "key_topics": ["topic1", "topic2"],
  "reasoning": "Brief explanation of sentiment assessment"
}}

Sentiment definitions:
- "positive": Call went well, customer satisfied, likely to close
- "neutral": Normal discussion, no strong positive or negative indicators
- "needs_attention": Issues detected, requires follow-up, customer concerns

Risk flags (select all that apply from this list):
{risk_flags_list}

Summary points: 3-5 concise bullet points capturing key information
Key topics: 2-5 main topics discussed
Reasoning: 1-2 sentences explaining your sentiment assessment

Respond ONLY with valid JSON, no additional text."""

    def _normalize_analysis_result(self, result: Dict) -> Dict:
        """Normalize and validate LLM analysis result"""
        # Ensure required fields
        normalized = {
            "overall_sentiment": result.get("overall_sentiment", "neutral"),
            "confidence": float(result.get("confidence", 0.5)),
            "risk_flags": result.get("risk_flags", []),
            "summary_points": result.get("summary_points", []),
            "key_topics": result.get("key_topics", []),
            "reasoning": result.get("reasoning", ""),
        }

        # Validate sentiment
        valid_sentiments = ["positive", "neutral", "needs_attention"]
        if normalized["overall_sentiment"] not in valid_sentiments:
            normalized["overall_sentiment"] = "neutral"

        # Clamp confidence
        normalized["confidence"] = max(0.0, min(1.0, normalized["confidence"]))

        # Validate risk flags
        normalized["risk_flags"] = [
            flag for flag in normalized["risk_flags"] if flag in self.RISK_FLAGS
        ]

        return normalized

    async def generate_whatsapp_message(
        self,
        transcript: str,
        analysis: Dict,
        language: str,
        custom_instructions: str = None,
    ) -> str:
        """
        Generate WhatsApp follow-up message

        Args:
            transcript: Original call transcript
            analysis: Analysis results
            language: Language code
            custom_instructions: Optional custom instructions

        Returns:
            WhatsApp message text
        """
        lang_names = {
            "gu": "Gujarati",
            "hi": "Hindi",
            "en": "English",
            "en-IN": "Hinglish",
        }
        lang_name = lang_names.get(language, "the same language as the call")

        system_prompt = f"""You are a professional sales assistant. Generate a friendly, conversational WhatsApp follow-up message in {lang_name} based on a sales call."""

        summary_text = "\n".join(f"- {point}" for point in analysis["summary_points"])
        custom_text = f"\n\nAdditional instructions: {custom_instructions}" if custom_instructions else ""

        user_prompt = f"""Based on this sales call:

Sentiment: {analysis["overall_sentiment"]}
Key points:
{summary_text}

Risk flags: {", ".join(analysis["risk_flags"]) if analysis["risk_flags"] else "None"}
{custom_text}

Generate a short, friendly WhatsApp message (2-4 sentences) in {lang_name} to follow up with the customer.
- Be warm and conversational
- Reference specific points from the call
- End with a clear next step or call to action
- Keep it under 150 words
- Use appropriate greetings for Indian business culture

Provide ONLY the message text, no formatting, no quotes, no explanation."""

        message = await self.llm.generate(
            prompt=user_prompt,
            system_prompt=system_prompt,
            temperature=0.8,
        )

        return message.strip()

    async def generate_email_draft(
        self,
        transcript: str,
        analysis: Dict,
        language: str,
        custom_instructions: str = None,
    ) -> str:
        """
        Generate email draft

        Args:
            transcript: Original call transcript
            analysis: Analysis results
            language: Language code
            custom_instructions: Optional custom instructions

        Returns:
            Email draft text
        """
        # Email is typically in English or Hindi for professional communication
        email_lang = "Hindi or English" if language in ["gu", "hi"] else "English"

        system_prompt = f"""You are a professional business communication assistant. Generate a professional email draft in {email_lang}."""

        summary_text = "\n".join(f"- {point}" for point in analysis["summary_points"])
        custom_text = f"\n\nAdditional instructions: {custom_instructions}" if custom_instructions else ""

        user_prompt = f"""Based on this sales call:

Sentiment: {analysis["overall_sentiment"]}
Key points:
{summary_text}

Risk flags: {", ".join(analysis["risk_flags"]) if analysis["risk_flags"] else "None"}
{custom_text}

Generate a professional email draft in {email_lang} to follow up with the customer.
- Use professional tone
- Include subject line
- Reference call discussion
- Provide clear action items
- Professional closing
- Keep it concise (200-300 words)

Format:
Subject: [subject line]

[email body]

Provide ONLY the email text (subject + body), no explanation."""

        email = await self.llm.generate(
            prompt=user_prompt,
            system_prompt=system_prompt,
            temperature=0.7,
        )

        return email.strip()


# Global instance
analysis_service = AnalysisService()
