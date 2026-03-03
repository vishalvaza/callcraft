@echo off
REM CallCraft Mobile - Flutter Setup & Run Script
REM This script checks for Flutter, installs it if needed, and runs the app

echo ================================================
echo CallCraft Mobile - Flutter Setup
echo ================================================
echo.

REM Check if Flutter is already installed
where flutter >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo [OK] Flutter is already installed
    flutter --version
    goto :CHECK_DEVICE
)

echo [!] Flutter not found. Starting installation...
echo.

REM Set installation directory
set FLUTTER_INSTALL_DIR=C:\flutter
set FLUTTER_VERSION=3.19.6

echo Flutter will be installed to: %FLUTTER_INSTALL_DIR%
echo Version: %FLUTTER_VERSION%
echo.
echo This may take 5-10 minutes depending on your internet connection.
echo.
pause

REM Create directory if it doesn't exist
if not exist "%FLUTTER_INSTALL_DIR%" mkdir "%FLUTTER_INSTALL_DIR%"

REM Download Flutter
echo.
echo [1/5] Downloading Flutter SDK...
set FLUTTER_ZIP=flutter_windows_%FLUTTER_VERSION%-stable.zip
set DOWNLOAD_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_%FLUTTER_VERSION%-stable.zip

powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TEMP%\%FLUTTER_ZIP%' -UseBasicParsing}"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Download failed!
    echo.
    echo Please download Flutter manually from:
    echo https://docs.flutter.dev/get-started/install/windows
    echo.
    pause
    exit /b 1
)

echo [OK] Download complete!

REM Extract Flutter
echo.
echo [2/5] Extracting Flutter...
powershell -Command "& {Expand-Archive -Path '%TEMP%\%FLUTTER_ZIP%' -DestinationPath 'C:\' -Force}"

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Extraction failed!
    pause
    exit /b 1
)

echo [OK] Extraction complete!

REM Add Flutter to PATH for this session
set PATH=%FLUTTER_INSTALL_DIR%\bin;%PATH%

REM Add Flutter to PATH permanently
echo.
echo [3/5] Adding Flutter to PATH...
setx PATH "%PATH%;%FLUTTER_INSTALL_DIR%\bin" >nul 2>&1
echo [OK] Flutter added to PATH (restart terminal for permanent effect)

REM Run Flutter doctor
echo.
echo [4/5] Running Flutter doctor...
flutter doctor

REM Accept licenses
echo.
echo [5/5] Accepting Android licenses...
echo y | flutter doctor --android-licenses >nul 2>&1

echo.
echo ================================================
echo Flutter Installation Complete!
echo ================================================
echo.
echo IMPORTANT: Close this terminal and open a new one for PATH changes to take effect.
echo.
echo Next steps:
echo 1. Install Android Studio: https://developer.android.com/studio
echo 2. Install Visual Studio Code with Flutter extension (optional)
echo 3. Run: flutter doctor
echo 4. Run: flutter devices
echo 5. Run this script again to launch the app
echo.
pause
exit /b 0

:CHECK_DEVICE
echo.
echo [2/4] Checking Flutter configuration...
flutter doctor -v

echo.
echo [3/4] Checking available devices...
flutter devices

REM Check if any device is available
flutter devices | findstr /C:"No devices" >nul
IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [WARNING] No devices found!
    echo.
    echo To run the app, you need either:
    echo   1. An Android emulator (from Android Studio)
    echo   2. A physical device connected via USB
    echo   3. Chrome browser for web testing
    echo.
    echo Starting Android Emulator creation...
    goto :SETUP_EMULATOR
) ELSE (
    goto :RUN_APP
)

:SETUP_EMULATOR
echo.
echo Would you like to create an Android emulator? (requires Android Studio)
echo.
choice /C YN /M "Create Android emulator"

IF %ERRORLEVEL% EQU 1 (
    echo.
    echo Creating Android emulator...

    REM Check if Android SDK is available
    where avdmanager >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo.
        echo [ERROR] Android SDK not found!
        echo.
        echo Please install Android Studio first:
        echo https://developer.android.com/studio
        echo.
        echo After installation:
        echo 1. Open Android Studio
        echo 2. Go to Tools ^> AVD Manager
        echo 3. Click "Create Virtual Device"
        echo 4. Select a device (e.g., Pixel 5)
        echo 5. Download a system image (e.g., Android 13)
        echo 6. Finish setup
        echo 7. Run this script again
        echo.
        pause
        exit /b 1
    )

    REM Create emulator
    echo.
    echo Creating Pixel 5 emulator with Android 33...
    avdmanager create avd -n CallCraft_Emulator -k "system-images;android-33;google_apis;x86_64" -d "pixel_5"

    echo.
    echo [OK] Emulator created: CallCraft_Emulator
    echo.
    echo Starting emulator...
    start emulator -avd CallCraft_Emulator

    echo.
    echo Waiting 30 seconds for emulator to start...
    timeout /t 30 /nobreak

    goto :RUN_APP
) ELSE (
    echo.
    echo Please start an emulator or connect a device, then run this script again.
    echo.
    pause
    exit /b 0
)

:RUN_APP
echo.
echo [4/4] Installing dependencies...
call flutter pub get

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install dependencies!
    pause
    exit /b 1
)

echo.
echo ================================================
echo Starting CallCraft Mobile App
echo ================================================
echo.

REM Ask which device to run on
flutter devices

echo.
echo Select a device to run on:
echo   1. First available device (default)
echo   2. Chrome (web)
echo   3. Windows desktop
echo   4. Specific device ID
echo.

choice /C 1234 /D 1 /T 10 /M "Select option (auto-selecting 1 in 10s)"

IF %ERRORLEVEL% EQU 1 (
    echo.
    echo Running on first available device...
    flutter run
)

IF %ERRORLEVEL% EQU 2 (
    echo.
    echo Running on Chrome...
    flutter run -d chrome
)

IF %ERRORLEVEL% EQU 3 (
    echo.
    echo Running on Windows...
    flutter run -d windows
)

IF %ERRORLEVEL% EQU 4 (
    echo.
    set /p DEVICE_ID="Enter device ID: "
    echo.
    echo Running on device: %DEVICE_ID%
    flutter run -d %DEVICE_ID%
)

echo.
echo ================================================
echo App Stopped
echo ================================================
echo.
pause
