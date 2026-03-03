# CallCraft - Setup Guide

This guide will help you set up the CallCraft development environment.

## Prerequisites

### Required
- **Docker Desktop** (Windows/Mac) or **Docker + Docker Compose** (Linux)
- **Git** for version control
- **Python 3.11+** (for local backend development without Docker)
- **Flutter 3.19+** (for mobile app development)

### Optional
- **PostgreSQL 15+** (if running backend locally without Docker)
- **Ollama** (if running LLM locally without Docker)

## Quick Start with Docker (Recommended)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd CallCraft
```

### 2. Start All Services
```bash
docker-compose up -d
```

This will start:
- PostgreSQL database on `localhost:5432`
- Ollama LLM server on `localhost:11434`
- FastAPI backend on `localhost:8000`

### 3. Pull the LLM Model
```bash
# This downloads the Qwen 2.5 7B model (~4.7GB)
docker exec -it callcraft-ollama ollama pull qwen2.5:7b-instruct
```

### 4. Run Database Migrations
```bash
# Enter the backend container
docker exec -it callcraft-backend bash

# Run migrations
alembic upgrade head

# Exit container
exit
```

### 5. Verify Setup
Visit http://localhost:8000/docs to see the API documentation.

## Local Development (Without Docker)

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up PostgreSQL**:
   ```bash
   # Install PostgreSQL 15+
   # Create database
   createdb callcraft
   createuser -P callcraft  # Set password: callcraft
   ```

5. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

6. **Run migrations**:
   ```bash
   alembic upgrade head
   ```

7. **Install Ollama** (https://ollama.ai):
   ```bash
   # Download and install Ollama
   # Pull model
   ollama pull qwen2.5:7b-instruct
   ```

8. **Start the API**:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Mobile App Setup

1. **Navigate to mobile directory**:
   ```bash
   cd mobile
   ```

2. **Install Flutter** (https://flutter.dev/docs/get-started/install)

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run on device/emulator**:
   ```bash
   # List devices
   flutter devices

   # Run app
   flutter run
   ```

## Testing the Backend

### 1. Register a User
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpassword123",
    "full_name": "Test User"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpassword123"
  }'
```

Save the `access_token` from the response.

### 3. Get User Profile
```bash
curl -X GET http://localhost:8000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Common Commands

### Docker
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild backend
docker-compose up -d --build backend

# Enter backend container
docker exec -it callcraft-backend bash

# Enter database
docker exec -it callcraft-postgres psql -U callcraft -d callcraft
```

### Database Migrations
```bash
# Create new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1
```

### Testing
```bash
# Backend tests
cd backend
pytest

# Flutter tests
cd mobile
flutter test
```

## Troubleshooting

### Backend won't start
- Check if PostgreSQL is running: `docker ps | grep postgres`
- Check logs: `docker-compose logs backend`
- Verify .env file exists and has correct values

### Ollama model not found
- Pull the model: `docker exec -it callcraft-ollama ollama pull qwen2.5:7b-instruct`
- Check Ollama is running: `curl http://localhost:11434/api/tags`

### Database connection errors
- Verify PostgreSQL is running: `docker-compose ps postgres`
- Check DATABASE_URL in .env matches docker-compose.yml
- Try: `docker-compose restart postgres`

### Port already in use
- Backend (8000): Change port in docker-compose.yml
- PostgreSQL (5432): Change port in docker-compose.yml
- Ollama (11434): Change port in docker-compose.yml

## Next Steps

Once setup is complete:
1. ✅ Backend API is running at http://localhost:8000
2. ✅ API docs available at http://localhost:8000/docs
3. ✅ Database is initialized with tables
4. ✅ Ollama LLM is ready for inference

Now you can:
- Start implementing the analyze endpoint (Task #2)
- Begin mobile app development (Task #16)
- Test authentication flow

## Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## Need Help?

- Check the main README.md
- Review the implementation plan
- Open an issue on GitHub
