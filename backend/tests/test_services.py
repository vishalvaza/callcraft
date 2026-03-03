"""
Tests for LLM and Analysis services
"""
import pytest
from unittest.mock import Mock, patch, AsyncMock

from app.services.llm_service import LLMService
from app.services.analysis_service import AnalysisService


class TestLLMService:
    """Test LLM Service"""

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.post")
    async def test_generate_success(self, mock_post):
        """Test successful text generation"""
        # Mock the response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "message": {"content": "Generated response"}
        }
        mock_post.return_value = mock_response

        llm_service = LLMService()
        result = await llm_service.generate(
            prompt="Test prompt",
            system_prompt="You are a helpful assistant",
        )

        assert result == "Generated response"
        assert mock_post.called

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.post")
    async def test_generate_json(self, mock_post):
        """Test JSON generation"""
        # Mock the response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "message": {"content": '{"sentiment": "positive", "confidence": 0.9}'}
        }
        mock_post.return_value = mock_response

        llm_service = LLMService()
        result = await llm_service.generate_json(
            prompt="Analyze this",
        )

        assert result["sentiment"] == "positive"
        assert result["confidence"] == 0.9

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.post")
    async def test_generate_json_with_markdown(self, mock_post):
        """Test JSON generation with markdown code blocks"""
        # Mock the response with markdown
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "message": {
                "content": '```json\n{"sentiment": "positive"}\n```'
            }
        }
        mock_post.return_value = mock_response

        llm_service = LLMService()
        result = await llm_service.generate_json(prompt="Test")

        assert result["sentiment"] == "positive"

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.get")
    async def test_health_check_success(self, mock_get):
        """Test health check success"""
        mock_response = Mock()
        mock_response.status_code = 200
        mock_get.return_value = mock_response

        llm_service = LLMService()
        result = await llm_service.health_check()

        assert result is True

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.get")
    async def test_health_check_failure(self, mock_get):
        """Test health check failure"""
        mock_get.side_effect = Exception("Connection failed")

        llm_service = LLMService()
        result = await llm_service.health_check()

        assert result is False


class TestAnalysisService:
    """Test Analysis Service"""

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate_json")
    async def test_analyze_transcript_gujarati(self, mock_generate):
        """Test Gujarati transcript analysis"""
        # Mock LLM response
        mock_generate.return_value = {
            "overall_sentiment": "positive",
            "confidence": 0.85,
            "risk_flags": [],
            "summary_points": [
                "Customer interested in product",
                "Pricing discussed",
                "Follow-up scheduled",
            ],
            "key_topics": ["pricing", "products"],
            "reasoning": "Positive customer interaction",
        }

        analysis_service = AnalysisService()
        result = await analysis_service.analyze_transcript(
            transcript="નમસ્તે! તમારા પ્રોડક્ટ વિશે જાણવું છે.",
            language="gu",
        )

        assert result["overall_sentiment"] == "positive"
        assert result["confidence"] == 0.85
        assert len(result["summary_points"]) == 3
        assert "processing_time_ms" in result

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate_json")
    async def test_analyze_transcript_hindi(self, mock_generate):
        """Test Hindi transcript analysis"""
        mock_generate.return_value = {
            "overall_sentiment": "needs_attention",
            "confidence": 0.92,
            "risk_flags": ["complaint", "delivery_issue"],
            "summary_points": [
                "Customer complained about delivery",
                "Promised express delivery",
            ],
            "key_topics": ["delivery", "complaint"],
            "reasoning": "Customer expressed dissatisfaction",
        }

        analysis_service = AnalysisService()
        result = await analysis_service.analyze_transcript(
            transcript="डिलीवरी में बहुत देर हो गई",
            language="hi",
        )

        assert result["overall_sentiment"] == "needs_attention"
        assert "complaint" in result["risk_flags"]
        assert "delivery_issue" in result["risk_flags"]

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate_json")
    async def test_normalize_invalid_sentiment(self, mock_generate):
        """Test normalization of invalid sentiment"""
        # Mock LLM returning invalid sentiment
        mock_generate.return_value = {
            "overall_sentiment": "invalid_sentiment",
            "confidence": 0.8,
            "risk_flags": [],
            "summary_points": ["Point 1"],
            "key_topics": ["topic1"],
            "reasoning": "Test",
        }

        analysis_service = AnalysisService()
        result = await analysis_service.analyze_transcript(
            transcript="Test",
            language="en",
        )

        # Should normalize to "neutral"
        assert result["overall_sentiment"] == "neutral"

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate_json")
    async def test_filter_invalid_risk_flags(self, mock_generate):
        """Test filtering of invalid risk flags"""
        mock_generate.return_value = {
            "overall_sentiment": "neutral",
            "confidence": 0.75,
            "risk_flags": [
                "pricing_objection",  # Valid
                "invalid_flag",  # Invalid
                "complaint",  # Valid
            ],
            "summary_points": ["Point"],
            "key_topics": ["topic"],
            "reasoning": "Test",
        }

        analysis_service = AnalysisService()
        result = await analysis_service.analyze_transcript(
            transcript="Test",
            language="en",
        )

        # Should only contain valid risk flags
        assert "pricing_objection" in result["risk_flags"]
        assert "complaint" in result["risk_flags"]
        assert "invalid_flag" not in result["risk_flags"]

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate")
    async def test_generate_whatsapp_gujarati(self, mock_generate):
        """Test WhatsApp message generation in Gujarati"""
        mock_generate.return_value = "નમસ્તે! આજના કોલ માટે આભાર."

        analysis_service = AnalysisService()
        analysis = {
            "overall_sentiment": "positive",
            "summary_points": ["Point 1", "Point 2"],
            "risk_flags": [],
        }

        result = await analysis_service.generate_whatsapp_message(
            transcript="Test",
            analysis=analysis,
            language="gu",
        )

        assert len(result) > 0
        assert mock_generate.called

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate")
    async def test_generate_email_hindi(self, mock_generate):
        """Test email generation in Hindi"""
        mock_generate.return_value = """Subject: फॉलो-अप

प्रिय ग्राहक,

आज की बातचीत के लिए धन्यवाद।

सादर,
टीम"""

        analysis_service = AnalysisService()
        analysis = {
            "overall_sentiment": "neutral",
            "summary_points": ["Point 1"],
            "risk_flags": [],
        }

        result = await analysis_service.generate_email_draft(
            transcript="Test",
            analysis=analysis,
            language="hi",
        )

        assert "Subject:" in result
        assert len(result) > 0

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate")
    async def test_generate_with_custom_instructions(self, mock_generate):
        """Test generation with custom instructions"""
        mock_generate.return_value = "Custom message"

        analysis_service = AnalysisService()
        analysis = {
            "overall_sentiment": "positive",
            "summary_points": ["Point"],
            "risk_flags": [],
        }

        result = await analysis_service.generate_whatsapp_message(
            transcript="Test",
            analysis=analysis,
            language="en",
            custom_instructions="Be formal",
        )

        assert len(result) > 0
        # Check that custom instructions were passed to LLM
        call_args = mock_generate.call_args
        assert "Be formal" in call_args[1]["prompt"]


class TestRiskFlags:
    """Test risk flag detection"""

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate_json")
    async def test_detect_pricing_objection(self, mock_generate):
        """Test detection of pricing objection"""
        mock_generate.return_value = {
            "overall_sentiment": "neutral",
            "confidence": 0.8,
            "risk_flags": ["pricing_objection"],
            "summary_points": ["Customer found price too high"],
            "key_topics": ["pricing"],
            "reasoning": "Customer objected to price",
        }

        analysis_service = AnalysisService()
        result = await analysis_service.analyze_transcript(
            transcript="The price is too high",
            language="en",
        )

        assert "pricing_objection" in result["risk_flags"]

    @pytest.mark.asyncio
    @patch("app.services.analysis_service.llm_service.generate_json")
    async def test_detect_customer_unhappy(self, mock_generate):
        """Test detection of unhappy customer"""
        mock_generate.return_value = {
            "overall_sentiment": "needs_attention",
            "confidence": 0.9,
            "risk_flags": ["customer_unhappy", "quality_concern"],
            "summary_points": ["Customer dissatisfied with quality"],
            "key_topics": ["quality"],
            "reasoning": "Customer expressed dissatisfaction",
        }

        analysis_service = AnalysisService()
        result = await analysis_service.analyze_transcript(
            transcript="I'm not happy with the quality",
            language="en",
        )

        assert "customer_unhappy" in result["risk_flags"]
        assert result["overall_sentiment"] == "needs_attention"
