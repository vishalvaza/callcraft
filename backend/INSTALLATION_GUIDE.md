# CallCraft Backend - Complete Installation Guide

## 📋 Table of Contents

1. [Quick Installation Decision Tree](#quick-installation-decision-tree)
2. [Python 3.13 Installation](#python-313-windows)
3. [Python 3.11/3.12 Installation](#python-31112-windows)
4. [Docker Installation](#docker-any-platform)
5. [Verification Steps](#verification-steps)
6. [Troubleshooting](#troubleshooting)
7. [Documentation Index](#documentation-index)

---

## Quick Installation Decision Tree

```
START HERE
    |
    v
┌─────────────────────────────────┐
│  What's your Python version?    │
│  Run: python --version          │
└─────────────────────────────────┘
    |
    ├── Python 3.13.x
    │   │
    │   └── ✅ SOLUTION: Use PyJWT (no Rust needed)
    │       │
    │       └── Run: install_python313.bat
    │           │
    │           ├── ✓ Installs PyJWT instead of python-jose
    │           ├── ✓ Updates security module automatically
    │           └── ✓ Takes 1-2 minutes
    │
    ├── Python 3.11.x or 3.12.x
    │   │
    │   └── ✅ SOLUTION: Standard installation
    │       │
    │       └── Run: install_windows.bat
    │           │
    │           ├── ✓ Installs all dependencies
    │           ├── ✓ Falls back to Windows-specific if needed
    │           └── ✓ Takes 1-2 minutes
    │
    ├── Other Python version or don't have Python
    │   │
    │   └── Choose:
    │       ├── Option A: Install Python 3.12
    │       │   └── Download from python.org
    │       │       └── Then use install_windows.bat
    │       │
    │       └── Option B: Use Docker
    │           └── Run: docker-compose up -d
    │               └── ✓ No Python installation needed!
    │
    └── Already have Docker?
        │
        └── ✅ RECOMMENDED: Use Docker
            │
            └── Run: docker-compose up -d
                │
                ├── ✓ Works with any Python version
                ├── ✓ Includes PostgreSQL + Ollama
                ├── ✓ Production-ready setup
                └── ✓ Takes 5 minutes
```

---

## Python 3.13 (Windows)

### ⚡ Automated Installation (Recommended)

```bash
cd backend
install_python313.bat
```

This script will:
1. ✅ Upgrade pip
2. ✅ Install Python 3.13 compatible dependencies (using PyJWT)
3. ✅ Update security module to use PyJWT
4. ✅ Backup original files
5. ✅ Verify installation

**Time**: 1-2 minutes

### 📖 Manual Installation

If you prefer manual control:

```bash
# Step 1: Upgrade pip
python -m pip install --upgrade pip

# Step 2: Install dependencies
pip install -r requirements-python313.txt

# Step 3: Update security module
copy app\core\security_pyjwt.py app\core\security.py

# Step 4: Verify
python test_pyjwt.py
```

### 🔍 Why Different from Other Versions?

Python 3.13 is very new (Oct 2024). The `python-jose[cryptography]` package requires Rust compiler to build on Python 3.13 because pre-built wheels aren't available yet.

**Our solution**: Use `PyJWT` instead - it has pre-built wheels and is functionally identical.

### 📚 Detailed Documentation

- **[PYTHON313_SOLUTION_SUMMARY.md](PYTHON313_SOLUTION_SUMMARY.md)** - Complete explanation of the fix
- **[PYTHON313_FIX.md](PYTHON313_FIX.md)** - Detailed technical guide
- **[test_pyjwt.py](test_pyjwt.py)** - Verification test suite

---

## Python 3.11/3.12 (Windows)

### ⚡ Automated Installation (Recommended)

```bash
cd backend
install_windows.bat
```

This script will:
1. ✅ Upgrade pip
2. ✅ Try installing with requirements.txt
3. ✅ Fall back to requirements-windows.txt if needed
4. ✅ Verify installation

**Time**: 1-2 minutes

### 📖 Manual Installation

```bash
# Step 1: Upgrade pip
python -m pip install --upgrade pip

# Step 2: Install dependencies
pip install -r requirements.txt

# If that fails:
pip install -r requirements-windows.txt
```

### 📚 Detailed Documentation

- **[INSTALL_FIX.md](INSTALL_FIX.md)** - Installation troubleshooting
- **[WINDOWS_SETUP.md](WINDOWS_SETUP.md)** - Windows-specific guide

---

## Docker (Any Platform)

### ⚡ Quick Start

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f backend
```

### 🎯 What Gets Installed

- ✅ FastAPI backend (Python 3.12)
- ✅ PostgreSQL database
- ✅ Ollama LLM server
- ✅ All dependencies pre-installed
- ✅ Auto-restart on failure

### 🔧 Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Rebuild after code changes
docker-compose up -d --build

# View logs
docker-compose logs -f backend

# Run migrations
docker-compose exec backend alembic upgrade head

# Access backend shell
docker-compose exec backend bash

# Stop and remove everything
docker-compose down -v
```

### 📚 Detailed Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment guide
- **[README.md](README.md)** - Main documentation

---

## Verification Steps

After installation (any method), verify everything works:

### 1. Test Imports

```bash
python -c "import fastapi; print('✓ FastAPI')"
python -c "import sqlalchemy; print('✓ SQLAlchemy')"
python -c "import ollama; print('✓ Ollama')"
python -c "from app.main import app; print('✓ App loads')"
```

**Expected**: All checks pass with ✓

### 2. Test Authentication (Python 3.13 only)

```bash
python test_pyjwt.py
```

**Expected**:
```
🎉 All tests passed! PyJWT authentication is working correctly.
```

### 3. Start API Server

```bash
uvicorn app.main:app --reload
```

**Expected**:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
INFO:     Application startup complete.
```

### 4. Check API Documentation

Open browser: http://localhost:8000/docs

**Expected**: Swagger UI with all endpoints visible

### 5. Run Test Suite

```bash
pytest tests/ -v
```

**Expected**: 85/85 tests passing

---

## Troubleshooting

### Issue: "Rust compiler required"

**You're on Python 3.13!**

**Solution**:
```bash
cd backend
install_python313.bat
```

See: [PYTHON313_FIX.md](PYTHON313_FIX.md)

---

### Issue: "pg_config executable not found"

**Problem**: psycopg2-binary needs PostgreSQL dev files

**Solution 1** (Easiest): Use requirements-windows.txt
```bash
pip install -r requirements-windows.txt
```

**Solution 2**: Use Docker
```bash
docker-compose up -d
```

See: [INSTALL_FIX.md](INSTALL_FIX.md)

---

### Issue: "No module named 'xxx'"

**Solution**: Force reinstall
```bash
pip install --force-reinstall -r requirements.txt
```

---

### Issue: "Could not find a version that satisfies requirement python-cors"

**Problem**: You're using an old requirements.txt

**Solution**: Pull latest version or remove the line:
```bash
git pull origin main
# OR manually remove python-cors==1.0.0 from requirements.txt
```

See: [INSTALL_FIX.md](INSTALL_FIX.md)

---

### Issue: "ModuleNotFoundError: No module named 'app'"

**Solution**: Ensure you're in the backend directory
```bash
cd backend
python -m app.main
```

---

### Issue: "Database connection failed"

**Solution**: Start PostgreSQL
```bash
# With Docker
docker-compose up -d postgres

# Check .env has correct DATABASE_URL
```

---

### Issue: "Ollama API connection failed"

**Solution**: Start Ollama
```bash
# With Docker
docker-compose up -d ollama

# Or install Ollama: https://ollama.ai/download
ollama serve
```

---

## Documentation Index

### 🎯 Start Here

- **[QUICK_START.md](QUICK_START.md)** - Quick decision tree and reference

### 🐍 Python-Specific Guides

- **[PYTHON313_SOLUTION_SUMMARY.md](PYTHON313_SOLUTION_SUMMARY.md)** - Python 3.13 complete guide
- **[PYTHON313_FIX.md](PYTHON313_FIX.md)** - Python 3.13 detailed technical guide
- **[INSTALL_FIX.md](INSTALL_FIX.md)** - General installation troubleshooting
- **[WINDOWS_SETUP.md](WINDOWS_SETUP.md)** - Windows-specific instructions

### 🐳 Docker

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment (Railway, DO, AWS)
- **[docker-compose.yml](docker-compose.yml)** - Docker configuration

### 📖 General Documentation

- **[README.md](README.md)** - Main project documentation
- **[API.md](API.md)** - API endpoint documentation
- **[TEST_VALIDATION.md](TEST_VALIDATION.md)** - Test suite documentation

### 🧪 Test Files

- **[test_pyjwt.py](test_pyjwt.py)** - PyJWT authentication verification
- **[test_api.py](test_api.py)** - API endpoint testing
- **[tests/](tests/)** - Full test suite (85 tests)

---

## Installation Comparison

| Method | Time | Complexity | Best For |
|--------|------|------------|----------|
| **Python 3.13** | 2 min | Easy | Python 3.13 users |
| **Python 3.11/3.12** | 1 min | Easiest | Most users |
| **Docker** | 5 min | Medium | Production, consistency |
| **Downgrade Python** | 10 min | Easy | If other methods fail |

---

## Success Checklist

After installation, verify:

- [ ] Python version checked: `python --version`
- [ ] Dependencies installed without errors
- [ ] Import tests pass
- [ ] Environment configured (`.env` file exists)
- [ ] Database accessible (PostgreSQL running)
- [ ] LLM accessible (Ollama running)
- [ ] Migrations applied: `alembic upgrade head`
- [ ] API server starts: `uvicorn app.main:app --reload`
- [ ] API docs accessible: http://localhost:8000/docs
- [ ] Test suite passes: `pytest tests/ -v` (85/85)

---

## Next Steps After Installation

### 1. Configure Environment

```bash
copy .env.example .env
```

Edit `.env`:
```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/callcraft

# Security
SECRET_KEY=your-secret-key-here-change-in-production

# LLM
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=qwen2.5:7b-instruct

# API
API_V1_STR=/api/v1
ACCESS_TOKEN_EXPIRE_MINUTES=43200
```

### 2. Start Services

**With Docker:**
```bash
docker-compose up -d
```

**Without Docker:**
- Install and start PostgreSQL
- Install and start Ollama
- Pull LLM model: `ollama pull qwen2.5:7b-instruct`

### 3. Run Database Migrations

```bash
alembic upgrade head
```

### 4. Start Development Server

```bash
uvicorn app.main:app --reload
```

### 5. Test the API

```bash
python test_api.py
```

Or open: http://localhost:8000/docs

### 6. Start Mobile App Development

See: [../mobile/README.md](../mobile/README.md)

---

## 🎉 Installation Complete!

Once all verification steps pass, you're ready to develop CallCraft!

**Recommended workflow**:
1. Backend running: `uvicorn app.main:app --reload`
2. Database running: `docker-compose up -d postgres ollama`
3. Mobile app development: See mobile/README.md
4. API docs open: http://localhost:8000/docs
5. Tests passing: `pytest tests/ -v`

---

## 💡 Tips

### For Development

- Use `--reload` flag with uvicorn for auto-reload on code changes
- Keep API docs open for reference: http://localhost:8000/docs
- Run tests frequently: `pytest tests/ -v`
- Check logs: `docker-compose logs -f backend`

### For Python 3.13 Users

- Your installation uses `PyJWT` instead of `python-jose`
- Functionality is identical - no changes needed in your code
- If you see issues, refer to [PYTHON313_FIX.md](PYTHON313_FIX.md)

### For Production

- Always use Docker for deployment
- Use environment-specific .env files
- Enable proper logging and monitoring
- See [DEPLOYMENT.md](DEPLOYMENT.md) for full guide

---

**Need help?** Check the specific guides linked above or see [TROUBLESHOOTING.md](INSTALL_FIX.md) for common issues.
