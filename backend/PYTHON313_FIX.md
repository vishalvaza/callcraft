# Python 3.13 Installation Fix

## Problem

Python 3.13 is very new (released October 2024), and some packages don't have pre-built wheels yet:
- `python-jose[cryptography]` requires Rust compiler to build `cryptography` package
- This causes installation to fail on Windows without Rust toolchain

## ✅ Solution: Use PyJWT Instead

We've created Python 3.13 compatible requirements that replace `python-jose` with `PyJWT` (no Rust needed).

---

## 🚀 Quick Fix (3 Steps)

### Step 1: Install Python 3.13 Compatible Dependencies

```bash
cd backend
pip install -r requirements-python313.txt
```

This will install all dependencies including `PyJWT==2.8.0` instead of `python-jose`.

### Step 2: Replace Security Module

```bash
# Backup original (optional)
copy app\core\security.py app\core\security_original.py

# Replace with PyJWT version
copy app\core\security_pyjwt.py app\core\security.py
```

Or manually:
1. Open `app/core/security.py`
2. Replace line 6: `from jose import JWTError, jwt`
   - With: `import jwt` and `from jwt.exceptions import InvalidTokenError`
3. Replace line 49: `except JWTError:`
   - With: `except InvalidTokenError:`

### Step 3: Verify Installation

```bash
# Test imports
python -c "import jwt; print('✓ PyJWT OK')"
python -c "import fastapi; print('✓ FastAPI OK')"
python -c "import sqlalchemy; print('✓ SQLAlchemy OK')"
python -c "from app.main import app; print('✓ App loads OK')"
```

---

## 📋 What Changed?

### Authentication Library Swap

| Before (python-jose) | After (PyJWT) |
|----------------------|---------------|
| `from jose import jwt, JWTError` | `import jwt`<br>`from jwt.exceptions import InvalidTokenError` |
| `JWTError` exception | `InvalidTokenError` exception |
| Requires Rust to compile | Pure Python + pre-built wheels |

### Why PyJWT?

✅ **No compilation needed** - pre-built wheels available for Python 3.13
✅ **Actively maintained** - Last updated 2024
✅ **Feature equivalent** - Same JWT encode/decode functionality
✅ **Well tested** - Used by millions of projects
✅ **Smaller dependency tree** - No cryptography compilation required

---

## 🔧 Alternative Solutions

### Option 1: Use Python 3.11 or 3.12 (Recommended for Simplicity)

If you don't specifically need Python 3.13:

```bash
# Uninstall Python 3.13
# Download Python 3.12 from python.org
# Install with default requirements
pip install -r requirements.txt
```

**Pros**: All packages have pre-built wheels, no issues
**Cons**: Not using latest Python features

### Option 2: Install Rust Toolchain (Advanced)

If you want to keep python-jose on Python 3.13:

1. Download Rust installer: https://rustup.rs/
2. Run installer and restart terminal
3. Verify: `cargo --version`
4. Install with original requirements: `pip install -r requirements.txt`

**Pros**: Use original requirements
**Cons**: 500MB+ download, longer install time, requires Rust knowledge

### Option 3: Use Docker (Zero Hassle) ⭐

```bash
docker-compose up -d
```

**Pros**: Works on any Python version, no dependency issues
**Cons**: Requires Docker installed

---

## 🧪 Testing After Fix

### 1. Test JWT Authentication

```python
# test_jwt.py
from app.core.security import create_access_token, decode_access_token

# Create token
token = create_access_token({"sub": "user123"})
print(f"✓ Token created: {token[:50]}...")

# Decode token
payload = decode_access_token(token)
print(f"✓ Token decoded: {payload}")

print("\n✅ PyJWT authentication working!")
```

Run: `python test_jwt.py`

### 2. Test API Server

```bash
# Start server
uvicorn app.main:app --reload

# In another terminal
curl http://localhost:8000/health
```

Expected: `{"status":"healthy"}`

### 3. Test Authentication Endpoints

```bash
# Register user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'
```

Expected: Receive access token

---

## 📊 Comparison: python-jose vs PyJWT

| Feature | python-jose | PyJWT |
|---------|-------------|-------|
| JWT encode/decode | ✅ | ✅ |
| HS256 algorithm | ✅ | ✅ |
| RS256 algorithm | ✅ | ✅ |
| Token expiration | ✅ | ✅ |
| Python 3.13 wheels | ❌ | ✅ |
| Requires Rust | ✅ (via cryptography) | ❌ |
| Install time | ~2 minutes | ~10 seconds |
| Package size | 50MB+ | 5MB |
| Active maintenance | Moderate | Very active |

**Verdict**: PyJWT is better for Python 3.13 and equally capable.

---

## 🐛 Troubleshooting

### Error: "No module named 'jwt'"

**Fix**: Install PyJWT
```bash
pip install PyJWT==2.8.0
```

### Error: "cannot import name 'InvalidTokenError'"

**Fix**: You're using old security.py
```bash
copy app\core\security_pyjwt.py app\core\security.py
```

### Error: "ImportError: DLL load failed"

**Fix**: Reinstall cryptography with pre-built wheel
```bash
pip uninstall cryptography
pip install cryptography>=41.0.0 --only-binary :all:
```

### Tests Failing After Switch

**Check**: Run pytest to identify specific failures
```bash
pytest tests/ -v
```

Most tests should pass unchanged. If auth tests fail, verify security.py was updated correctly.

---

## ✅ Success Checklist

After applying the fix:

- [ ] `pip install -r requirements-python313.txt` completes without errors
- [ ] `import jwt` works in Python console
- [ ] `from app.core.security import create_access_token` works
- [ ] `python test_jwt.py` passes
- [ ] `uvicorn app.main:app` starts without errors
- [ ] `/api/v1/auth/register` endpoint works
- [ ] `/api/v1/auth/login` returns valid token
- [ ] All tests pass: `pytest tests/ -v`

---

## 📚 Additional Resources

- **PyJWT Documentation**: https://pyjwt.readthedocs.io/
- **Python 3.13 Release Notes**: https://docs.python.org/3.13/whatsnew/3.13.html
- **FastAPI Security**: https://fastapi.tiangolo.com/tutorial/security/

---

## 💡 Recommendation

For **production deployment**, we recommend:

1. **Use Docker** - Eliminates all dependency issues
2. **Pin Python version** in Dockerfile: `FROM python:3.12-slim`
3. **Use PyJWT** - Faster installs, smaller images

For **local development**, choose based on your needs:

- **Python 3.13** → Use requirements-python313.txt + PyJWT
- **Python 3.11/3.12** → Use requirements.txt + python-jose
- **Any Python** → Use Docker

---

## 🎯 Next Steps

1. ✅ Install Python 3.13 compatible dependencies
2. ✅ Replace security.py with PyJWT version
3. ✅ Verify installation with test commands
4. 🚀 Continue with main setup:
   - Copy `.env.example` to `.env`
   - Start PostgreSQL: `docker-compose up -d postgres`
   - Run migrations: `alembic upgrade head`
   - Start API: `uvicorn app.main:app --reload`

---

**🎉 You're now ready to develop on Python 3.13!**

The rest of the setup process is identical to the main README.md.
