# CallCraft - Windows Setup Guide

## Issue: psycopg2-binary Installation Error

If you see `pg_config executable not found` error on Windows, follow these solutions:

---

## Quick Fix (Choose One)

### Option 1: Let pip Find Compatible Version (Easiest)

```bash
cd backend

# Upgrade pip first
python -m pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

**✅ This should work for most cases.**

---

### Option 2: Use Windows-Specific Requirements

We've created a Windows-specific requirements file that uses `psycopg` (v3) instead of `psycopg2-binary`:

```bash
cd backend

# Use Windows requirements
pip install -r requirements-windows.txt
```

**✅ This uses pure Python packages that don't need compilation.**

---

### Option 3: Install PostgreSQL (If you need psycopg2)

If you specifically need `psycopg2-binary==2.9.9`:

1. **Download PostgreSQL**: https://www.postgresql.org/download/windows/
2. **Install PostgreSQL** (default options are fine)
3. **Add to PATH**:
   - Find `pg_config.exe` (usually in `C:\Program Files\PostgreSQL\15\bin`)
   - Add this folder to your System PATH
   - Restart terminal
4. **Try again**:
   ```bash
   pip install psycopg2-binary
   ```

---

### Option 4: Use Docker (Recommended for Development)

Skip the Python dependency issues entirely:

```bash
# Start everything with Docker
docker-compose up -d

# No need to install Python dependencies locally!
```

**✅ This is the cleanest solution for Windows development.**

---

## Verify Installation

After installing, verify it works:

```bash
cd backend

# Test import
python -c "import psycopg2; print('psycopg2 works!')"

# Or if using psycopg3:
python -c "import psycopg; print('psycopg works!')"

# Test database connection
python -c "from app.core.database import engine; print('Database config works!')"
```

---

## If Using psycopg3 (requirements-windows.txt)

**No code changes needed!** Both `psycopg2-binary` and `psycopg` work with SQLAlchemy 2.0+.

Just make sure your `DATABASE_URL` uses the correct driver:

```python
# .env file
DATABASE_URL=postgresql+psycopg://user:pass@localhost:5432/dbname
# OR
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname  # Auto-detects driver
```

---

## Troubleshooting

### Error: "Microsoft Visual C++ 14.0 or greater is required"

**Solution**: Install Microsoft C++ Build Tools
1. Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Install "Desktop development with C++"
3. Restart terminal
4. Try `pip install` again

### Error: "No module named 'psycopg2'"

**Solution**: Install explicitly
```bash
pip install psycopg2-binary --no-cache-dir
```

### Error: Still not working

**Best Solution**: Use Docker
```bash
docker-compose up -d
# Everything works out of the box!
```

---

## Python Version Compatibility

| Python Version | psycopg2-binary | psycopg (v3) |
|----------------|-----------------|--------------|
| 3.13           | ❌ May fail     | ✅ Works     |
| 3.12           | ✅ Works        | ✅ Works     |
| 3.11           | ✅ Works        | ✅ Works     |
| 3.10           | ✅ Works        | ✅ Works     |
| 3.9            | ✅ Works        | ✅ Works     |

**Recommendation**: Use Python 3.11 or 3.12 for best compatibility.

---

## Which Requirements File to Use?

### Use `requirements.txt` if:
- ✅ You're on Linux/Mac
- ✅ You're using Docker
- ✅ You have Python 3.12 or lower
- ✅ PostgreSQL is already installed

### Use `requirements-windows.txt` if:
- ✅ You're on Windows
- ✅ You have Python 3.13
- ✅ You don't want to install PostgreSQL
- ✅ You want pure Python packages

### Use Docker if:
- ✅ You want zero setup hassle
- ✅ You're developing on Windows
- ✅ You want production-like environment

---

## Recommended Approach for Windows

**Best**: Use Docker (zero dependency issues)
```bash
docker-compose up -d
```

**Good**: Use requirements-windows.txt
```bash
pip install -r requirements-windows.txt
```

**Works**: Install PostgreSQL + use requirements.txt
```bash
# Install PostgreSQL first, then:
pip install -r requirements.txt
```

---

## Docker Setup (No Python Installation Needed)

If you want to avoid all Python dependency issues:

```bash
# 1. Install Docker Desktop for Windows
# Download from: https://www.docker.com/products/docker-desktop/

# 2. Start services
docker-compose up -d

# 3. View logs
docker-compose logs -f backend

# 4. Access API
# Backend: http://localhost:8000
# API Docs: http://localhost:8000/docs

# 5. Run commands inside container
docker exec -it callcraft-backend bash
```

**✅ This is the recommended approach for Windows!**

---

## Summary

For Windows users, we recommend:

1. **Try Option 1 first** (upgrade pip + use requirements.txt)
2. **If that fails, use Option 2** (requirements-windows.txt with psycopg3)
3. **Best long-term: Use Docker** (zero setup issues)

---

## Still Having Issues?

Check these:

1. **Python version**: `python --version` (use 3.11 or 3.12)
2. **Pip version**: `pip --version` (upgrade with `python -m pip install --upgrade pip`)
3. **Virtual environment**: Make sure you're in a venv
4. **Antivirus**: Temporarily disable if blocking compilation
5. **Admin rights**: Run terminal as Administrator

---

## Alternative: Use Conda

If nothing works, try Conda (has pre-built binaries):

```bash
# Install Miniconda
# Download from: https://docs.conda.io/en/latest/miniconda.html

# Create environment
conda create -n callcraft python=3.11
conda activate callcraft

# Install dependencies
conda install -c conda-forge psycopg2
pip install -r requirements.txt
```

---

**Need help?** Open an issue with:
- Your Python version: `python --version`
- Your OS: Windows 10/11
- Full error message
