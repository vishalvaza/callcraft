"""
Test script for CallCraft API
Run this after starting the backend to verify all endpoints work
"""
import httpx
import asyncio
import json
from datetime import datetime


BASE_URL = "http://localhost:8000"
API_V1 = f"{BASE_URL}/api/v1"


# Sample Gujarati call transcript
SAMPLE_GUJARATI_TRANSCRIPT = """
Customer: નમસ્તે, મને તમારા પ્રોડક્ટ વિશે માહિતી જોઈએ છે.
Salesperson: નમસ્તે! હું તમને મદદ કરી શકું. તમે કયા પ્રોડક્ટમાં રસ ધરાવો છો?
Customer: મને તમારા ડાયમંડ કલેક્શન જોવો છે. કિંમત શું છે?
Salesperson: અમારો નવો કલેક્શન ખૂબ સરસ છે. કિંમત ₹50,000 થી શરૂ થાય છે.
Customer: એ તો થોડી મોંઘી છે. કોઈ ડિસ્કાઉન્ટ મળી શકે?
Salesperson: હા જી, આ મહિને 10% ડિસ્કાઉન્ટ ચાલી રહ્યું છે.
Customer: સરસ! તો હું આવતીકાલે આવીશ શોરૂમમાં.
Salesperson: ખૂબ સરસ! મને તમારો નંબર આપો, હું તમને રિમાઇન્ડર મોકલીશ.
"""

# Sample Hindi call transcript
SAMPLE_HINDI_TRANSCRIPT = """
Customer: नमस्ते, मुझे आपके प्रोडक्ट के बारे में जानकारी चाहिए।
Salesperson: नमस्ते! मैं आपकी मदद कर सकता हूं। आप किस प्रोडक्ट में रुचि रखते हैं?
Customer: मुझे दवाइयों का ऑर्डर देना है। क्या होम डिलीवरी है?
Salesperson: जी हां, हम होम डिलीवरी करते हैं। कौन सी दवा चाहिए?
Customer: लेकिन पिछली बार डिलीवरी में 3 दिन लग गए थे। बहुत देर हो गई थी।
Salesperson: मुझे माफी चाहता हूं। इस बार मैं एक्सप्रेस डिलीवरी करूंगा, 24 घंटे में मिल जाएगी।
Customer: ठीक है, मैं भरोसा करता हूं। कब ऑर्डर दूं?
Salesperson: अभी दे दीजिए, मैं तुरंत प्रोसेस करूंगा।
"""


async def test_health_check():
    """Test health check endpoint"""
    print("\n1. Testing Health Check...")
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{BASE_URL}/health")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}")
        assert response.status_code == 200


async def test_register():
    """Test user registration"""
    print("\n2. Testing User Registration...")
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{API_V1}/auth/register",
            json={
                "email": "test@callcraft.in",
                "password": "TestPass123!",
                "full_name": "Test User",
                "phone": "+919876543210",
            },
        )
        print(f"   Status: {response.status_code}")
        data = response.json()
        print(f"   Response: {json.dumps(data, indent=2)}")
        return data.get("access_token")


async def test_login():
    """Test user login"""
    print("\n3. Testing User Login...")
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{API_V1}/auth/login",
            json={
                "email": "test@callcraft.in",
                "password": "TestPass123!",
            },
        )
        print(f"   Status: {response.status_code}")
        data = response.json()
        print(f"   Token: {data.get('access_token')[:50]}...")
        return data.get("access_token")


async def test_get_user(token: str):
    """Test get current user"""
    print("\n4. Testing Get Current User...")
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{API_V1}/auth/me",
            headers={"Authorization": f"Bearer {token}"},
        )
        print(f"   Status: {response.status_code}")
        print(f"   User: {json.dumps(response.json(), indent=2, default=str)}")


async def test_analyze_transcript(token: str, transcript: str, language: str):
    """Test transcript analysis"""
    print(f"\n5. Testing Transcript Analysis ({language})...")
    async with httpx.AsyncClient(timeout=120.0) as client:
        response = await client.post(
            f"{API_V1}/analyze",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "transcript": transcript,
                "language": language,
                "duration_seconds": 180,
                "recorded_at": datetime.utcnow().isoformat(),
            },
        )
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Call Record ID: {data['call_record_id']}")
            print(f"   Sentiment: {data['overall_sentiment']} (confidence: {data['confidence']})")
            print(f"   Risk Flags: {data['risk_flags']}")
            print(f"   Summary:")
            for point in data['summary']['bullet_points']:
                print(f"      - {point}")
            print(f"   Reasoning: {data['reasoning']}")
            return data['call_record_id']
        else:
            print(f"   Error: {response.text}")
            return None


async def test_generate_whatsapp(token: str, call_record_id: str):
    """Test WhatsApp message generation"""
    print("\n6. Testing WhatsApp Message Generation...")
    async with httpx.AsyncClient(timeout=120.0) as client:
        response = await client.post(
            f"{API_V1}/analyze/generate/whatsapp",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "call_record_id": call_record_id,
            },
        )
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Language: {data['language']}")
            print(f"   Message:\n   {data['content']}")
        else:
            print(f"   Error: {response.text}")


async def test_generate_email(token: str, call_record_id: str):
    """Test email draft generation"""
    print("\n7. Testing Email Draft Generation...")
    async with httpx.AsyncClient(timeout=120.0) as client:
        response = await client.post(
            f"{API_V1}/analyze/generate/email",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "call_record_id": call_record_id,
            },
        )
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Language: {data['language']}")
            print(f"   Email:\n   {data['content']}")
        else:
            print(f"   Error: {response.text}")


async def run_tests():
    """Run all tests"""
    print("=" * 60)
    print("CallCraft API Test Suite")
    print("=" * 60)

    try:
        # Test basic health
        await test_health_check()

        # Test auth flow
        token = await test_register()
        if not token:
            print("\nRegistration failed, trying login...")
            token = await test_login()

        if not token:
            print("\nERROR: Could not get auth token")
            return

        await test_get_user(token)

        # Test Gujarati call analysis
        print("\n" + "=" * 60)
        print("Testing Gujarati Call Analysis")
        print("=" * 60)
        call_id_gu = await test_analyze_transcript(token, SAMPLE_GUJARATI_TRANSCRIPT, "gu")
        if call_id_gu:
            await test_generate_whatsapp(token, call_id_gu)
            await test_generate_email(token, call_id_gu)

        # Test Hindi call analysis
        print("\n" + "=" * 60)
        print("Testing Hindi Call Analysis")
        print("=" * 60)
        call_id_hi = await test_analyze_transcript(token, SAMPLE_HINDI_TRANSCRIPT, "hi")
        if call_id_hi:
            await test_generate_whatsapp(token, call_id_hi)
            await test_generate_email(token, call_id_hi)

        print("\n" + "=" * 60)
        print("All Tests Completed!")
        print("=" * 60)

    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    print("\nMake sure:")
    print("1. Backend is running (docker-compose up or uvicorn)")
    print("2. Ollama has qwen2.5:7b-instruct model pulled")
    print("3. Database migrations have been run\n")

    input("Press Enter to start tests...")

    asyncio.run(run_tests())
