"""
Tests for analysis endpoints
"""
import pytest
from unittest.mock import Mock, patch, AsyncMock
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.core.database import Base, get_db

# Create test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    """Override database dependency for testing"""
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(scope="function")
def test_db():
    """Create test database tables"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client(test_db):
    """Test client"""
    return TestClient(app)


@pytest.fixture
def auth_token(client):
    """Get authentication token"""
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "test@example.com",
            "password": "testpassword123",
        },
    )
    return response.json()["access_token"]


@pytest.fixture
def mock_analysis_result():
    """Mock analysis result from LLM"""
    return {
        "overall_sentiment": "positive",
        "confidence": 0.85,
        "risk_flags": ["pricing_objection"],
        "summary_points": [
            "Customer interested in product",
            "Pricing discussion",
            "Follow-up scheduled",
        ],
        "key_topics": ["pricing", "product features"],
        "reasoning": "Customer showed interest and scheduled follow-up",
        "processing_time_ms": 1500,
    }


class TestAnalysis:
    """Test analysis endpoints"""

    @patch("app.services.analysis_service.analysis_service.analyze_transcript")
    def test_analyze_transcript_success(self, mock_analyze, client, auth_token, mock_analysis_result):
        """Test successful transcript analysis"""
        # Mock the analysis service
        mock_analyze.return_value = mock_analysis_result

        response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": "નમસ્તે! હું તમને કેવી રીતે મદદ કરી શકું?",
                "language": "gu",
                "duration_seconds": 180,
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert "call_record_id" in data
        assert data["overall_sentiment"] == "positive"
        assert data["confidence"] == 0.85
        assert len(data["risk_flags"]) > 0
        assert len(data["summary"]["bullet_points"]) > 0

    def test_analyze_without_auth(self, client):
        """Test analysis without authentication"""
        response = client.post(
            "/api/v1/analyze",
            json={
                "transcript": "Test transcript",
                "language": "en",
                "duration_seconds": 60,
            },
        )

        assert response.status_code == 403  # Forbidden

    def test_analyze_invalid_language(self, client, auth_token):
        """Test analysis with invalid language"""
        response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": "Test transcript",
                "language": "invalid",
                "duration_seconds": 60,
            },
        )

        assert response.status_code == 422  # Validation error

    def test_analyze_short_transcript(self, client, auth_token):
        """Test analysis with too short transcript"""
        response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": "Hi",
                "language": "en",
                "duration_seconds": 5,
            },
        )

        assert response.status_code == 422  # Validation error

    @patch("app.services.analysis_service.analysis_service.analyze_transcript")
    def test_analyze_gujarati(self, mock_analyze, client, auth_token, mock_analysis_result):
        """Test Gujarati transcript analysis"""
        mock_analyze.return_value = mock_analysis_result

        gujarati_transcript = """
સેલ્સપર્સન: નમસ્તે! હું તમને કેવી રીતે મદદ કરી શકું?
ગ્રાહક: નમસ્તે, મને તમારા નવા પ્રોડક્ટ વિશે જાણવું છે.
"""

        response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": gujarati_transcript,
                "language": "gu",
                "duration_seconds": 60,
            },
        )

        assert response.status_code == 200
        assert mock_analyze.called

    @patch("app.services.analysis_service.analysis_service.analyze_transcript")
    def test_analyze_hindi(self, mock_analyze, client, auth_token, mock_analysis_result):
        """Test Hindi transcript analysis"""
        mock_analyze.return_value = mock_analysis_result

        hindi_transcript = """
सेल्सपर्सन: नमस्ते! मैं आपकी कैसे मदद कर सकता हूं?
ग्राहक: नमस्ते, मुझे आपके प्रोडक्ट के बारे में जानना है।
"""

        response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": hindi_transcript,
                "language": "hi",
                "duration_seconds": 60,
            },
        )

        assert response.status_code == 200

    @patch("app.services.analysis_service.analysis_service.analyze_transcript")
    def test_get_analysis(self, mock_analyze, client, auth_token, mock_analysis_result):
        """Test getting existing analysis"""
        # First create an analysis
        mock_analyze.return_value = mock_analysis_result

        create_response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": "Test transcript",
                "language": "en",
                "duration_seconds": 60,
            },
        )

        call_record_id = create_response.json()["call_record_id"]

        # Get the analysis
        response = client.get(
            f"/api/v1/analyze/{call_record_id}",
            headers={"Authorization": f"Bearer {auth_token}"},
        )

        assert response.status_code == 200
        data = response.json()
        assert data["call_record_id"] == call_record_id

    def test_get_nonexistent_analysis(self, client, auth_token):
        """Test getting non-existent analysis"""
        response = client.get(
            "/api/v1/analyze/nonexistent-id",
            headers={"Authorization": f"Bearer {auth_token}"},
        )

        assert response.status_code == 404

    @patch("app.services.analysis_service.analysis_service.generate_whatsapp_message")
    @patch("app.services.analysis_service.analysis_service.analyze_transcript")
    def test_generate_whatsapp(self, mock_analyze, mock_whatsapp, client, auth_token, mock_analysis_result):
        """Test WhatsApp message generation"""
        # Setup mocks
        mock_analyze.return_value = mock_analysis_result
        mock_whatsapp.return_value = "નમસ્તે! આજના ફોનકોલ માટે આભાર."

        # Create analysis first
        create_response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": "Test transcript",
                "language": "gu",
                "duration_seconds": 60,
            },
        )

        call_record_id = create_response.json()["call_record_id"]

        # Generate WhatsApp message
        response = client.post(
            "/api/v1/analyze/generate/whatsapp",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={"call_record_id": call_record_id},
        )

        assert response.status_code == 200
        data = response.json()
        assert "content" in data
        assert len(data["content"]) > 0

    @patch("app.services.analysis_service.analysis_service.generate_email_draft")
    @patch("app.services.analysis_service.analysis_service.analyze_transcript")
    def test_generate_email(self, mock_analyze, mock_email, client, auth_token, mock_analysis_result):
        """Test email draft generation"""
        # Setup mocks
        mock_analyze.return_value = mock_analysis_result
        mock_email.return_value = "Subject: Follow-up\n\nDear Customer,\n\nThank you for your time..."

        # Create analysis first
        create_response = client.post(
            "/api/v1/analyze",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={
                "transcript": "Test transcript",
                "language": "en",
                "duration_seconds": 60,
            },
        )

        call_record_id = create_response.json()["call_record_id"]

        # Generate email
        response = client.post(
            "/api/v1/analyze/generate/email",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={"call_record_id": call_record_id},
        )

        assert response.status_code == 200
        data = response.json()
        assert "content" in data
        assert "Subject:" in data["content"]
