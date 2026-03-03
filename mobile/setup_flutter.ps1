# CallCraft Mobile - Flutter Setup & Run Script (PowerShell)
# More robust than the batch script with better error handling

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "CallCraft Mobile - Flutter Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if command exists
function Test-Command($command) {
    try {
        if (Get-Command $command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Function to download file with progress
function Download-File($url, $output) {
    Write-Host "Downloading from: $url" -ForegroundColor Yellow
    Write-Host "Saving to: $output" -ForegroundColor Yellow

    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    $ProgressPreference = 'Continue'
}

# Check if Flutter is already installed
Write-Host "[1/6] Checking Flutter installation..." -ForegroundColor Yellow

if (Test-Command "flutter") {
    Write-Host "[OK] Flutter is already installed" -ForegroundColor Green
    flutter --version
    $installFlutter = $false
} else {
    Write-Host "[!] Flutter not found" -ForegroundColor Red

    $response = Read-Host "Would you like to install Flutter? (Y/n)"
    if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
        $installFlutter = $true
    } else {
        Write-Host "Please install Flutter manually from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
        exit 1
    }
}

# Install Flutter if needed
if ($installFlutter) {
    $flutterDir = "C:\flutter"
    $flutterVersion = "3.19.6"
    $flutterZip = "flutter_windows_$flutterVersion-stable.zip"
    $downloadUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$flutterVersion-stable.zip"
    $tempPath = "$env:TEMP\$flutterZip"

    Write-Host ""
    Write-Host "[2/6] Installing Flutter..." -ForegroundColor Yellow
    Write-Host "Installation directory: $flutterDir" -ForegroundColor Cyan
    Write-Host "Version: $flutterVersion" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This may take 5-10 minutes depending on your internet connection." -ForegroundColor Yellow
    Write-Host ""

    # Create directory
    if (-not (Test-Path $flutterDir)) {
        New-Item -ItemType Directory -Path $flutterDir -Force | Out-Null
    }

    # Download Flutter
    Write-Host "Downloading Flutter SDK..." -ForegroundColor Yellow
    try {
        Download-File -url $downloadUrl -output $tempPath
        Write-Host "[OK] Download complete!" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Download failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please download Flutter manually from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
        exit 1
    }

    # Extract Flutter
    Write-Host ""
    Write-Host "Extracting Flutter..." -ForegroundColor Yellow
    try {
        Expand-Archive -Path $tempPath -DestinationPath "C:\" -Force
        Write-Host "[OK] Extraction complete!" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }

    # Add to PATH
    Write-Host ""
    Write-Host "Adding Flutter to PATH..." -ForegroundColor Yellow
    $flutterBin = "$flutterDir\bin"

    # Add to user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$flutterBin*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBin", "User")
        $env:Path = "$env:Path;$flutterBin"
        Write-Host "[OK] Flutter added to PATH" -ForegroundColor Green
    } else {
        Write-Host "[OK] Flutter already in PATH" -ForegroundColor Green
    }

    # Run Flutter doctor
    Write-Host ""
    Write-Host "Running Flutter doctor..." -ForegroundColor Yellow
    & "$flutterBin\flutter.bat" doctor

    # Accept licenses
    Write-Host ""
    Write-Host "Accepting Android licenses..." -ForegroundColor Yellow
    Write-Host "y" | & "$flutterBin\flutter.bat" doctor --android-licenses

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "Flutter Installation Complete!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Close this terminal and open a new one for PATH changes to take effect." -ForegroundColor Yellow
    Write-Host ""

    $response = Read-Host "Press Enter to continue, or 'Q' to quit and restart terminal"
    if ($response -eq "Q" -or $response -eq "q") {
        exit 0
    }
}

# Check Flutter configuration
Write-Host ""
Write-Host "[3/6] Checking Flutter configuration..." -ForegroundColor Yellow
flutter doctor -v

# Check for devices
Write-Host ""
Write-Host "[4/6] Checking available devices..." -ForegroundColor Yellow
$devices = flutter devices
Write-Host $devices

# Check if any device is available
if ($devices -match "No devices") {
    Write-Host ""
    Write-Host "[WARNING] No devices found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To run the app, you need either:" -ForegroundColor Yellow
    Write-Host "  1. An Android emulator (from Android Studio)" -ForegroundColor Yellow
    Write-Host "  2. A physical device connected via USB" -ForegroundColor Yellow
    Write-Host "  3. Chrome browser for web testing" -ForegroundColor Yellow
    Write-Host ""

    $response = Read-Host "Would you like to try running on Chrome? (Y/n)"
    if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
        $selectedDevice = "chrome"
    } else {
        Write-Host ""
        Write-Host "Please start an emulator or connect a device, then run this script again." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To create an Android emulator:" -ForegroundColor Cyan
        Write-Host "1. Install Android Studio: https://developer.android.com/studio" -ForegroundColor Cyan
        Write-Host "2. Open Android Studio > Tools > AVD Manager" -ForegroundColor Cyan
        Write-Host "3. Click 'Create Virtual Device'" -ForegroundColor Cyan
        Write-Host "4. Select a device (e.g., Pixel 5)" -ForegroundColor Cyan
        Write-Host "5. Download a system image (e.g., Android 13)" -ForegroundColor Cyan
        Write-Host "6. Finish setup and start the emulator" -ForegroundColor Cyan
        exit 0
    }
} else {
    # Ask which device to use
    Write-Host ""
    Write-Host "Select a device to run on:" -ForegroundColor Cyan
    Write-Host "  1. First available device (default)" -ForegroundColor Cyan
    Write-Host "  2. Chrome (web)" -ForegroundColor Cyan
    Write-Host "  3. Windows desktop" -ForegroundColor Cyan
    Write-Host ""

    $choice = Read-Host "Enter choice (1-3, or press Enter for 1)"

    switch ($choice) {
        "2" { $selectedDevice = "chrome" }
        "3" { $selectedDevice = "windows" }
        default { $selectedDevice = $null }
    }
}

# Navigate to mobile directory if not already there
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Install dependencies
Write-Host ""
Write-Host "[5/6] Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to install dependencies!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Dependencies installed" -ForegroundColor Green

# Run the app
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "Starting CallCraft Mobile App" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

if ($selectedDevice) {
    Write-Host "Running on: $selectedDevice" -ForegroundColor Cyan
    flutter run -d $selectedDevice
} else {
    Write-Host "Running on first available device" -ForegroundColor Cyan
    flutter run
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "App Stopped" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To run again: .\setup_flutter.ps1" -ForegroundColor Yellow
