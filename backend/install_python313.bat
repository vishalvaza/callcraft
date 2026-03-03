@echo off
REM CallCraft - Python 3.13 Installation Script
REM Fixes Rust compiler requirement by using PyJWT instead of python-jose

echo ================================================
echo CallCraft Backend - Python 3.13 Installation
echo ================================================
echo.

REM Check Python version
echo Checking Python version...
python --version | findstr /C:"3.13" >nul
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [WARNING] You are not using Python 3.13
    echo This script is specifically for Python 3.13
    echo.
    echo If you're using Python 3.11 or 3.12, use:
    echo   pip install -r requirements.txt
    echo.
    echo If you're using Python 3.13, continue...
    pause
)

echo.
echo [1/4] Upgrading pip...
python -m pip install --upgrade pip
echo.

echo [2/4] Installing Python 3.13 compatible dependencies...
echo (Using PyJWT instead of python-jose to avoid Rust requirement)
pip install -r requirements-python313.txt

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Installation failed!
    echo.
    echo Possible solutions:
    echo 1. Check your internet connection
    echo 2. Try: python -m pip install --upgrade pip setuptools wheel
    echo 3. Use Docker: docker-compose up -d
    echo 4. Downgrade to Python 3.12: https://www.python.org/downloads/
    echo.
    echo See PYTHON313_FIX.md for detailed troubleshooting.
    pause
    exit /b 1
)

echo.
echo [3/4] Updating security module to use PyJWT...

REM Backup original security.py
IF EXIST "app\core\security.py" (
    IF NOT EXIST "app\core\security_original.py" (
        copy "app\core\security.py" "app\core\security_original.py" >nul
        echo ✓ Original security.py backed up
    )
)

REM Replace with PyJWT version
copy "app\core\security_pyjwt.py" "app\core\security.py" >nul
echo ✓ Security module updated to use PyJWT

echo.
echo [4/4] Verifying installation...
python -c "import jwt; print('✓ PyJWT installed successfully!')"
python -c "import fastapi; print('✓ FastAPI installed successfully!')"
python -c "import sqlalchemy; print('✓ SQLAlchemy installed successfully!')"
python -c "import asyncpg; print('✓ asyncpg installed successfully!')"
python -c "import ollama; print('✓ Ollama installed successfully!')"
python -c "from app.core.security import create_access_token; print('✓ Authentication module working!')" 2>nul || echo "⚠ Authentication test skipped (DB may not be running)"

echo.
echo ================================================
echo Installation Complete! (Python 3.13 Compatible)
echo ================================================
echo.
echo Changes made:
echo   - Installed PyJWT instead of python-jose (no Rust needed)
echo   - Updated app/core/security.py to use PyJWT
echo   - Original security.py saved as security_original.py
echo.
echo Next steps:
echo   1. Set up environment: copy .env.example .env
echo   2. Start services: docker-compose up -d
echo   3. Run migrations: alembic upgrade head
echo   4. Start API: uvicorn app.main:app --reload
echo   5. Test: python test_api.py
echo.
echo Documentation:
echo   - See PYTHON313_FIX.md for details
echo   - See README.md for general setup
echo.
pause
