# Quick Install Fix for Windows

## ✅ Fixed Issues
- ❌ Removed non-existent `python-cors` package (FastAPI has CORS built-in)
- ✅ Fixed `psycopg2-binary` version flexibility
- ✅ Cleaned up duplicate dependencies
- ✅ Added Windows-specific requirements

---

## 🚀 Quick Installation (Choose One Method)

### Method 1: Automatic Install (Easiest)
```bash
cd backend
install_windows.bat
```
This will try all solutions automatically!

---

### Method 2: Manual Install (Step-by-step)

#### Step 1: Upgrade pip
```bash
python -m pip install --upgrade pip
```

#### Step 2: Install dependencies
```bash
cd backend
pip install -r requirements.txt
```

**If that fails:**
```bash
pip install -r requirements-windows.txt
```

---

### Method 3: Docker (Zero Hassle) ⭐ Recommended
```bash
# No Python installation needed!
docker-compose up -d
```

---

## 🧪 Verify Installation

After successful install:

```bash
# Test imports
python -c "import fastapi; print('✓ FastAPI OK')"
python -c "import sqlalchemy; print('✓ SQLAlchemy OK')"
python -c "import ollama; print('✓ Ollama OK')"

# Test the app
python -c "from app.main import app; print('✓ App loads OK')"
```

---

## 📦 What's Installed

### Core Dependencies (All working now!)
- ✅ FastAPI 0.109.2 - Web framework
- ✅ SQLAlchemy 2.0.25 - Database ORM
- ✅ Pydantic 2.6.1 - Data validation
- ✅ Alembic 1.13.1 - Database migrations
- ✅ psycopg2-binary (flexible version) - PostgreSQL driver
- ✅ Ollama 0.1.6 - LLM integration
- ✅ python-jose - JWT authentication
- ✅ passlib - Password hashing

### Testing Dependencies
- ✅ pytest 8.0.0
- ✅ pytest-asyncio 0.23.4
- ✅ pytest-cov 4.1.0
- ✅ pytest-mock 3.12.0

---

## 🔧 Troubleshooting

### Still getting errors?

#### Error: "Rust compiler required" or "cargo not found" (Python 3.13)
**This is the most common issue on Python 3.13!**

**Solution**: Use Python 3.13 compatible requirements
```bash
pip install -r requirements-python313.txt
copy app\core\security_pyjwt.py app\core\security.py
```

**📖 See detailed guide**: [PYTHON313_FIX.md](PYTHON313_FIX.md)

#### Error: "No module named 'xxx'"
```bash
# Force reinstall
pip install --force-reinstall -r requirements.txt
```

#### Error: "Microsoft Visual C++ required"
**Solution**: Use Docker or requirements-windows.txt
```bash
pip install -r requirements-windows.txt
```

#### Error: psycopg2 still failing
**Solution**: Use pure Python version
```bash
pip uninstall psycopg2-binary
pip install psycopg[binary]
```

---

## ✨ Next Steps After Installation

### 1. Set up environment
```bash
cd backend
cp .env.example .env
# Edit .env with your settings
```

### 2. Start database (if using Docker)
```bash
docker-compose up -d postgres ollama
```

### 3. Run migrations
```bash
alembic upgrade head
```

### 4. Start the API
```bash
uvicorn app.main:app --reload
```

### 5. Test it!
```bash
# In another terminal
python test_api.py
```

Visit: http://localhost:8000/docs

---

## 🎯 Common Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Run tests
pytest tests/ -v

# Start server
uvicorn app.main:app --reload

# Run migrations
alembic upgrade head

# Start with Docker
docker-compose up -d
```

---

## 💡 Tips

1. **Use a virtual environment**:
   ```bash
   python -m venv venv
   venv\Scripts\activate  # Windows
   ```

2. **Keep pip updated**:
   ```bash
   python -m pip install --upgrade pip
   ```

3. **For production, use Docker**:
   - Consistent environment
   - No dependency issues
   - Easy deployment

---

## ✅ Success Checklist

After installation, verify:
- [ ] No errors during pip install
- [ ] `import fastapi` works
- [ ] `import sqlalchemy` works
- [ ] `from app.main import app` works
- [ ] `uvicorn app.main:app` starts server
- [ ] http://localhost:8000/docs shows API

---

**If everything is ✅, you're ready to go!**

Start the app:
```bash
uvicorn app.main:app --reload
```

Or with Docker:
```bash
docker-compose up -d
```

🎉 **Installation Complete!**
