# CallCraft Backend API

Production-ready FastAPI backend for call transcription analysis and follow-up generation.

## Features

- 🔐 JWT Authentication
- 📊 Call analysis with LLM (Ollama/vLLM)
- 🌐 Multi-language support (Gujarati, Hindi, Hinglish)
- 📝 WhatsApp & Email draft generation
- 🗄️ PostgreSQL database
- 🐳 Docker containerization

## Tech Stack

- **Framework**: FastAPI 0.109+
- **Database**: PostgreSQL + SQLAlchemy
- **LLM**: Ollama (Qwen2.5-7B-Instruct)
- **Auth**: JWT (python-jose)
- **Deployment**: Docker + Railway/DigitalOcean

## Setup

### Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Ollama (for LLM inference)

### Installation

1. **Clone and navigate to backend**:
   ```bash
   cd backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Set up database**:
   ```bash
   # Create PostgreSQL database
   createdb callcraft

   # Run migrations (once models are created)
   alembic upgrade head
   ```

6. **Install and run Ollama**:
   ```bash
   # Install Ollama from https://ollama.ai
   # Pull the model
   ollama pull qwen2.5:7b-instruct
   ```

### Running the API

**Development mode**:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Production mode**:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

**Docker**:
```bash
docker build -t callcraft-backend .
docker run -p 8000:8000 --env-file .env callcraft-backend
```

## API Documentation

Once running, visit:
- **Interactive docs**: http://localhost:8000/docs
- **Alternative docs**: http://localhost:8000/redoc

## Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI app entry point
│   ├── api/
│   │   └── routes/
│   │       ├── auth.py      # Authentication endpoints
│   │       └── analyze.py   # Analysis endpoints
│   ├── models/
│   │   ├── user.py          # User database model
│   │   └── call_record.py   # Call record model
│   ├── services/
│   │   ├── llm_service.py   # LLM integration
│   │   └── analysis_service.py  # Analysis logic
│   ├── core/
│   │   ├── config.py        # Configuration management
│   │   ├── security.py      # Auth utilities
│   │   └── database.py      # Database setup
│   └── schemas/
│       ├── transcript.py    # Pydantic models
│       └── analysis.py      # Response schemas
├── alembic/                 # Database migrations
├── requirements.txt         # Python dependencies
├── Dockerfile              # Container definition
└── .env.example            # Environment template
```

## API Endpoints (Planned)

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login and get JWT token

### Analysis
- `POST /api/v1/analyze` - Analyze transcript
- `POST /api/v1/generate/whatsapp` - Generate WhatsApp message
- `POST /api/v1/generate/email` - Generate email draft

### User
- `GET /api/v1/user/me` - Get current user
- `GET /api/v1/user/calls` - Get call history

## Development

### Running tests:
```bash
pytest
```

### Database migrations:
```bash
# Create new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head
```

## Deployment

See deployment guide in main project README.

## License

Proprietary - CallCraft
