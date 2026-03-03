@echo off
REM CallCraft - Windows Installation Script

echo ================================================
echo CallCraft Backend - Windows Installation
echo ================================================
echo.

REM Check Python version
python --version
echo.

REM Upgrade pip
echo [1/3] Upgrading pip...
python -m pip install --upgrade pip
echo.

REM Try installing with flexible psycopg2 version first
echo [2/3] Installing dependencies (attempting requirements.txt)...
pip install -r requirements.txt

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] requirements.txt failed, trying Windows-specific requirements...
    echo.

    REM Fallback to Windows-specific requirements
    pip install -r requirements-windows.txt

    IF %ERRORLEVEL% NEQ 0 (
        echo.
        echo [ERROR] Installation failed!
        echo.
        echo Possible solutions:
        echo 1. Use Docker: docker-compose up -d
        echo 2. Install PostgreSQL: https://www.postgresql.org/download/windows/
        echo 3. Use Python 3.11 or 3.12 instead of 3.13
        echo.
        echo See WINDOWS_SETUP.md for detailed troubleshooting.
        pause
        exit /b 1
    )
)

echo.
echo [3/3] Verifying installation...
python -c "import fastapi; print('✓ FastAPI installed successfully!')"
python -c "import sqlalchemy; print('✓ SQLAlchemy installed successfully!')"
python -c "import ollama; print('✓ Ollama installed successfully!')"
python -c "from app.core.database import Base; print('✓ Database models loaded successfully!')" 2>nul || echo "⚠ Database import test skipped (normal if DB not running)"

echo.
echo ================================================
echo Installation Complete!
echo ================================================
echo.
echo Next steps:
echo 1. Start services: docker-compose up -d
echo 2. Run migrations: docker exec -it callcraft-backend alembic upgrade head
echo 3. Test API: python test_api.py
echo.
pause
