# CallCraft - Smart Call Analysis Application

Production-ready mobile application for transcribing and analyzing sales calls in regional languages (Gujarati, Hindi, Hinglish).

## 🎯 Overview

CallCraft helps sales professionals and teams in India analyze their calls, get instant sentiment analysis, and generate follow-up messages automatically.

### Key Features

- 🎤 **On-Device Transcription**: Audio never leaves your device (Whisper.cpp)
- 🌐 **Multi-Language**: Gujarati, Hindi, Hinglish support
- 🤖 **AI Analysis**: Sentiment, risk flags, smart summaries (100% open-source LLM)
- 📱 **WhatsApp Integration**: Auto-generate follow-up messages
- 📧 **Email Drafts**: Professional email templates
- 🔒 **Privacy-First**: Audio stays local, only text goes to server
- 💰 **Zero LLM Costs**: Open-source models (Ollama/vLLM)

## 🏗️ Architecture

**Hybrid On-Device + Server Architecture**:

- **Mobile App** (Flutter): Audio recording, transcription (Whisper), local storage
- **Backend API** (FastAPI): LLM analysis, draft generation, user management
- **Database** (PostgreSQL): User data, call history, analytics
- **LLM** (Ollama/vLLM): 100% open-source (Qwen2.5-7B-Instruct)

## 🚀 Quick Start

### Backend Setup

```bash
cd backend

# Install dependencies
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Set up environment
cp .env.example .env
# Edit .env with your settings

# Run the API
uvicorn app.main:app --reload
```

Visit: http://localhost:8000/docs

### Mobile App Setup

```bash
cd mobile

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Docker Setup (Full Stack)

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## 📁 Project Structure

```
CallCraft/
├── backend/               # FastAPI backend
│   ├── app/
│   │   ├── main.py       # FastAPI app
│   │   ├── api/          # API routes
│   │   ├── models/       # Database models
│   │   ├── services/     # Business logic
│   │   ├── core/         # Config & security
│   │   └── schemas/      # Pydantic models
│   ├── alembic/          # DB migrations
│   ├── requirements.txt
│   └── Dockerfile
│
├── mobile/               # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/      # UI screens
│   │   ├── services/     # API & audio services
│   │   ├── models/       # Data models
│   │   └── widgets/      # Reusable components
│   └── pubspec.yaml
│
├── docker-compose.yml    # Local development
└── README.md
```

## 🛠️ Technology Stack

### Backend
- **Language**: Python 3.11+
- **Framework**: FastAPI
- **Database**: PostgreSQL + SQLAlchemy
- **LLM**: Ollama (Qwen2.5-7B-Instruct)
- **Auth**: JWT (python-jose)
- **Deployment**: Docker + Railway/DigitalOcean

### Mobile
- **Framework**: Flutter 3.19+
- **Language**: Dart
- **Speech-to-Text**: whisper.cpp (multilingual)
- **Storage**: SQLite + Hive
- **State Management**: Riverpod
- **Platforms**: Android 8+ & iOS 13+

### AI/ML (100% Open Source)
- **Transcription**: Whisper small/medium
- **Analysis**: Qwen2.5-7B-Instruct (via Ollama)
- **Production**: vLLM for high-throughput inference
- **Cost**: $0 for LLM API calls (self-hosted)

## 📊 Implementation Phases

| Phase | Timeline | Tasks |
|-------|----------|-------|
| **Phase 1**: Foundation | Week 1-2 | Backend setup, mobile setup, basic UI |
| **Phase 2**: Core Features | Week 3-4 | Audio handling, transcription, LLM analysis |
| **Phase 3**: Output Generation | Week 5 | WhatsApp/email drafts, results UI |
| **Phase 4**: Sharing & Polish | Week 6 | Sharing, offline support, UX improvements |
| **Phase 5**: Testing | Week 7 | Unit tests, integration tests, optimization |
| **Phase 6**: Launch | Week 8 | Deployment, app store submission, beta |

**Total MVP Time**: 8 weeks

## 💰 Pricing Strategy

### B2C (Individual Users)
- **Free**: 10 calls/month
- **Basic**: ₹299/month (~$3.60) - 100 calls
- **Pro**: ₹999/month (~$12) - Unlimited

### B2B (Teams)
- **Starter**: ₹2,999/month (~$36) - 5 users, 500 calls
- **Growth**: ₹9,999/month (~$120) - 20 users, 2000 calls
- **Enterprise**: Custom pricing

## 🎯 Target Market

**Primary**: Sales professionals in Gujarat and Maharashtra
- Diamond traders (Surat)
- Textile businesses (Ahmedabad)
- Pharma distributors (Mumbai)
- Real estate agents
- Insurance agents

**Languages**: Gujarati, Hindi, Hinglish (English-Hindi mix)

## 📈 Success Metrics

- **DAU** (Daily Active Users)
- **Calls per user per week**
- **Free → Paid conversion**: Target 5%
- **Churn rate**: Target <5% monthly
- **LTV/CAC ratio**: Target 10:1

## 🚀 Deployment

### Backend (Railway - Recommended for MVP)
```bash
# Connect Railway
railway login

# Create project
railway init

# Deploy
railway up
```

**Cost**: $0-20/month (MVP) → $50-100/month (100 users)

### Mobile (App Stores)
- **Android**: Google Play Store ($25 one-time)
- **iOS**: Apple App Store ($99/year)

**CI/CD**: Codemagic or Bitrise

## 🔐 Security & Privacy

- ✅ Audio **never** leaves device
- ✅ Only transcripts sent to server
- ✅ End-to-end encryption option
- ✅ GDPR & India DPDP Act compliant
- ✅ User consent for call recording

## 📝 License

Proprietary - CallCraft

## 👥 Team

- **Founder**: [Your Name]
- **Tech Stack**: FastAPI + Flutter + Ollama
- **Location**: India (Gujarat focus)

## 📞 Contact

- **Email**: contact@callcraft.app
- **Website**: https://callcraft.app
- **Support**: support@callcraft.app

---

**Built with ❤️ for Indian sales professionals**
