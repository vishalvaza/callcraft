# CallCraft Backend - Quick Start Guide

Choose your installation method based on your Python version:

## 🚀 Quick Decision Tree

```
Do you have Python 3.13?
├─ YES → Use requirements-python313.txt + run install_python313.bat
├─ NO → Do you have Python 3.11 or 3.12?
│  ├─ YES → Use requirements.txt + run install_windows.bat
│  └─ NO → Install Python 3.12 OR use Docker
└─ Don't know? → Run: python --version
```

---

## Method 1: Python 3.13 (YOU ARE HERE) ⭐

**If you're on Python 3.13.x:**

```bash
cd backend
install_python313.bat
```

This automatically:
- Installs PyJWT instead of python-jose (no Rust needed)
- Updates authentication module
- Verifies everything works

**Manual installation:**
```bash
pip install -r requirements-python313.txt
copy app\core\security_pyjwt.py app\core\security.py
python test_pyjwt.py
```

**📖 Full guide**: [PYTHON313_FIX.md](PYTHON313_FIX.md)

---

## Method 2: Python 3.11 or 3.12 (Recommended)

**If you're on Python 3.11.x or 3.12.x:**

```bash
cd backend
install_windows.bat
```

This tries multiple installation methods automatically.

**Manual installation:**
```bash
pip install -r requirements.txt
```

If that fails, try Windows-specific requirements:
```bash
pip install -r requirements-windows.txt
```

**📖 Full guide**: [INSTALL_FIX.md](INSTALL_FIX.md)

---

## Method 3: Docker (Works with Any Python) 🐳

**Best option if you have Docker installed:**

```bash
docker-compose up -d
```

**Pros:**
- Works regardless of Python version
- No dependency issues
- Includes PostgreSQL and Ollama
- Production-ready setup

**Cons:**
- Requires Docker Desktop
- Larger resource usage

**📖 Full guide**: [README.md](README.md#docker-setup)

---

## Method 4: Downgrade Python (If All Else Fails)

If you're having issues with Python 3.13:

1. Uninstall Python 3.13
2. Download Python 3.12 from: https://www.python.org/downloads/
3. Install with "Add to PATH" checked
4. Verify: `python --version` (should show 3.12.x)
5. Continue with Method 2

---

## 🧪 Verify Your Installation

After any method, run these checks:

```bash
# Check Python version
python --version

# Test imports
python -c "import fastapi; print('✓ FastAPI')"
python -c "import sqlalchemy; print('✓ SQLAlchemy')"
python -c "import ollama; print('✓ Ollama')"

# For Python 3.13, also test PyJWT
python test_pyjwt.py

# Test the app
python -c "from app.main import app; print('✓ App loads')"
```

**Expected**: All checks pass with ✓

---

## ⚡ After Installation

### 1. Set up environment

```bash
copy .env.example .env
```

Edit `.env` and set:
- `DATABASE_URL` - PostgreSQL connection string
- `SECRET_KEY` - Random string for JWT signing
- `OLLAMA_BASE_URL` - Ollama API URL (default: http://localhost:11434)

### 2. Start services

**With Docker:**
```bash
docker-compose up -d
```

**Without Docker:**
- Install PostgreSQL separately
- Install Ollama separately
- Start both services

### 3. Run database migrations

```bash
alembic upgrade head
```

### 4. Start the API server

```bash
uvicorn app.main:app --reload
```

### 5. Test the API

Open browser: http://localhost:8000/docs

Or run test script:
```bash
python test_api.py
```

---

## 📁 Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI application
│   ├── api/
│   │   └── routes/          # API endpoints
│   ├── core/
│   │   ├── config.py        # Configuration
│   │   ├── database.py      # Database setup
│   │   ├── security.py      # Authentication
│   │   └── security_pyjwt.py # Python 3.13 version
│   ├── models/              # SQLAlchemy models
│   ├── services/            # Business logic
│   └── schemas/             # Pydantic schemas
├── tests/                   # Test suite
├── alembic/                 # Database migrations
├── requirements.txt         # Python 3.11/3.12
├── requirements-python313.txt # Python 3.13
├── requirements-windows.txt # Windows fallback
├── install_windows.bat      # Auto installer (3.11/3.12)
├── install_python313.bat    # Auto installer (3.13)
├── test_pyjwt.py           # PyJWT verification
└── docker-compose.yml      # Docker setup
```

---

## 🐛 Common Issues

### "ModuleNotFoundError: No module named 'app'"

**Fix**: Make sure you're in the `backend` directory:
```bash
cd backend
python -m app.main
```

### "Could not connect to database"

**Fix**: Start PostgreSQL:
```bash
# With Docker
docker-compose up -d postgres

# Or check your DATABASE_URL in .env
```

### "Ollama API connection failed"

**Fix**: Start Ollama:
```bash
# With Docker
docker-compose up -d ollama

# Or install Ollama: https://ollama.ai/download
ollama serve
```

### "RuntimeError: Python 3.13 requires Rust compiler"

**Fix**: You're using the wrong requirements file!
```bash
# Use Python 3.13 requirements
pip install -r requirements-python313.txt
```

### Tests failing after Python 3.13 fix

**Fix**: Make sure you updated security.py:
```bash
copy app\core\security_pyjwt.py app\core\security.py
python test_pyjwt.py
```

---

## 📊 Installation Comparison

| Method | Time | Complexity | Compatibility |
|--------|------|------------|---------------|
| Python 3.13 (PyJWT) | 2 min | Easy | Python 3.13 only |
| Python 3.11/3.12 | 1 min | Easiest | Python 3.11/3.12 |
| Docker | 5 min | Medium | Any OS |
| Downgrade Python | 10 min | Easy | Windows |

---

## 🎯 Recommended Path

1. **For beginners**: Use Docker (Method 3)
2. **For Python 3.13 users**: Use install_python313.bat (Method 1)
3. **For Python 3.11/3.12 users**: Use install_windows.bat (Method 2)
4. **For production**: Use Docker always

---

## 📚 Documentation Index

- **[README.md](README.md)** - Main documentation
- **[PYTHON313_FIX.md](PYTHON313_FIX.md)** - Python 3.13 detailed guide
- **[INSTALL_FIX.md](INSTALL_FIX.md)** - Installation troubleshooting
- **[WINDOWS_SETUP.md](WINDOWS_SETUP.md)** - Windows-specific guide
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment
- **[API.md](API.md)** - API documentation

---

## ✅ Success Checklist

- [ ] Python version checked: `python --version`
- [ ] Dependencies installed (no errors)
- [ ] Import tests pass
- [ ] Environment configured (.env file)
- [ ] PostgreSQL running (Docker or local)
- [ ] Ollama running (Docker or local)
- [ ] Migrations applied: `alembic upgrade head`
- [ ] API server starts: `uvicorn app.main:app --reload`
- [ ] API docs accessible: http://localhost:8000/docs
- [ ] Test script passes: `python test_api.py`

---

**🎉 Once all checks pass, you're ready to develop!**

Need help? Check the specific guides above or see [INSTALL_FIX.md](INSTALL_FIX.md) for troubleshooting.
