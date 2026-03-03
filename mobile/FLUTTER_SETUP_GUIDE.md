# CallCraft Mobile - Flutter Setup Guide

## 🚀 Quick Start (Automated)

We've created automated scripts to install Flutter and run the app!

### Option 1: PowerShell Script (Recommended)

```powershell
# Right-click setup_flutter.ps1 > Run with PowerShell
# Or in PowerShell:
.\setup_flutter.ps1
```

### Option 2: Batch Script

```batch
# Double-click setup_flutter.bat
# Or in Command Prompt:
setup_flutter.bat
```

**That's it!** The script will:
1. ✅ Check if Flutter is installed
2. ✅ Download and install Flutter if needed (~600 MB)
3. ✅ Configure Flutter for Windows
4. ✅ Check for available devices/emulators
5. ✅ Install app dependencies
6. ✅ Run the CallCraft app

---

## 📋 Prerequisites

### Required
- **Windows 10/11** (64-bit)
- **10 GB free disk space** (for Flutter + Android Studio)
- **Internet connection** (for downloads)

### Optional but Recommended
- **Android Studio** (for Android emulator)
- **Visual Studio Code** (for development)
- **Chrome** (for web testing)

---

## 🛠️ Manual Installation (If Scripts Don't Work)

### Step 1: Install Flutter

#### Download Flutter

1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Download Flutter SDK (latest stable version)
3. Extract to `C:\flutter` (or any location without spaces)

#### Add to PATH

1. Search Windows for "Environment Variables"
2. Click "Environment Variables" button
3. Under "User variables", find "Path"
4. Click "Edit" > "New"
5. Add: `C:\flutter\bin` (or your Flutter location)
6. Click "OK" to save

#### Verify Installation

```bash
# Open a NEW terminal/command prompt
flutter --version
flutter doctor
```

### Step 2: Install Android Studio (for Android development)

1. Download: https://developer.android.com/studio
2. Install with default options
3. Open Android Studio
4. Go to: Settings > Appearance & Behavior > System Settings > Android SDK
5. Install latest SDK (Android 13 or 14)

#### Create Android Emulator

1. In Android Studio, go to: Tools > AVD Manager
2. Click "Create Virtual Device"
3. Select a device (e.g., **Pixel 5** or **Pixel 7**)
4. Click "Next"
5. Download a system image (e.g., **Android 13 (Tiramisu)**)
6. Click "Next" > "Finish"
7. Click the ▶️ Play button to start the emulator

### Step 3: Install Visual Studio (for Windows desktop development)

**Optional - only if you want to run on Windows desktop**

1. Download: https://visualstudio.microsoft.com/downloads/
2. Install "Visual Studio 2022 Community Edition"
3. Select "Desktop development with C++"
4. Complete installation (may take 30+ minutes)

### Step 4: Configure Flutter

```bash
# Accept Android licenses
flutter doctor --android-licenses
# Press 'y' to accept all licenses

# Check configuration
flutter doctor -v

# You should see:
# [√] Flutter (Channel stable, version X.X.X)
# [√] Android toolchain
# [√] Chrome (for web development)
# [√] Visual Studio (for Windows development) - optional
```

### Step 5: Run the App

```bash
# Navigate to mobile folder
cd C:\Users\vvaza\work\examples\CallCraft\mobile

# Get dependencies
flutter pub get

# Check available devices
flutter devices

# Run on first available device
flutter run

# Or run on specific device
flutter run -d chrome          # Chrome browser
flutter run -d windows         # Windows desktop
flutter run -d <device-id>     # Specific device
```

---

## 📱 Running on Different Platforms

### Android Emulator

```bash
# List emulators
emulator -list-avds

# Start emulator
emulator -avd <emulator-name>

# Or start from Android Studio:
# Tools > AVD Manager > Click ▶️ on your emulator

# Wait for emulator to boot (~30 seconds)

# Run app
flutter run
```

### Physical Android Device

1. Enable Developer Options on your device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options

2. Enable USB Debugging:
   - In Developer Options, enable "USB Debugging"

3. Connect device via USB

4. Check device is detected:
   ```bash
   flutter devices
   # You should see your device listed
   ```

5. Run app:
   ```bash
   flutter run
   ```

### Chrome (Web)

```bash
# Run in Chrome
flutter run -d chrome

# Or with hot reload
flutter run -d chrome --hot
```

### Windows Desktop

```bash
# Run on Windows
flutter run -d windows

# Build release version
flutter build windows --release
```

---

## 🔧 Troubleshooting

### Issue: "flutter: command not found"

**Fix**: Flutter not in PATH

1. Close and reopen terminal
2. Or manually add to PATH (see manual installation above)
3. Or run with full path: `C:\flutter\bin\flutter`

---

### Issue: "No devices found"

**Fix**: No emulator or device available

```bash
# Check what's available
flutter devices

# For Android:
# - Start an emulator from Android Studio
# - Or connect a physical device

# For web:
flutter run -d chrome

# For Windows:
flutter run -d windows
```

---

### Issue: "Android license status unknown"

**Fix**: Accept Android licenses

```bash
flutter doctor --android-licenses
# Press 'y' for all licenses
```

---

### Issue: "Gradle build failed"

**Fix**: Android SDK issue

```bash
# Update Flutter
flutter upgrade

# Clean project
flutter clean
flutter pub get

# Try again
flutter run
```

---

### Issue: "Unable to locate Android SDK"

**Fix**: Configure Android SDK location

1. Open Android Studio
2. Go to: File > Settings > Appearance & Behavior > System Settings > Android SDK
3. Note the "Android SDK Location" path
4. Set environment variable:
   ```bash
   setx ANDROID_HOME "C:\Users\<YourName>\AppData\Local\Android\Sdk"
   ```
5. Restart terminal

---

### Issue: PowerShell script won't run

**Fix**: Enable script execution

```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run the script again
.\setup_flutter.ps1
```

---

### Issue: "Waiting for another flutter command to release the startup lock"

**Fix**: Remove lock file

```bash
# Windows
del "%LOCALAPPDATA%\flutter\flutter_install.lock"

# Or manually delete:
# C:\Users\<YourName>\AppData\Local\flutter\flutter_install.lock
```

---

## 🎯 Quick Reference

### Common Commands

```bash
# Check Flutter installation
flutter doctor -v

# Check devices
flutter devices

# Get dependencies
flutter pub get

# Run app (debug mode)
flutter run

# Run with hot reload
flutter run --hot

# Run on specific device
flutter run -d <device-id>

# Build release APK (Android)
flutter build apk --release

# Build release app bundle (Android)
flutter build appbundle --release

# Build Windows executable
flutter build windows --release

# Clean build artifacts
flutter clean

# Update Flutter
flutter upgrade

# View Flutter logs
flutter logs

# Analyze code
flutter analyze
```

### Useful Flutter Commands

```bash
# Create new Flutter project
flutter create my_app

# Run tests
flutter test

# Format code
flutter format .

# Check for updates
flutter upgrade --verify-only

# Show performance overlay
flutter run --profile
```

---

## 📊 System Requirements

### Minimum
- **OS**: Windows 10 (64-bit)
- **Disk Space**: 10 GB
- **RAM**: 8 GB
- **Processor**: Intel i3 or equivalent

### Recommended
- **OS**: Windows 11 (64-bit)
- **Disk Space**: 20 GB (for Android Studio + emulators)
- **RAM**: 16 GB
- **Processor**: Intel i5/Ryzen 5 or better
- **SSD**: Highly recommended for faster builds

---

## 🎓 Next Steps

Once your app is running:

1. **Explore the code**:
   - `lib/main.dart` - App entry point
   - `lib/screens/` - UI screens
   - `lib/services/` - API and business logic
   - `lib/models/` - Data models

2. **Test features**:
   - Record/import audio
   - Transcribe calls
   - View analysis results
   - Generate follow-up messages

3. **Connect to backend**:
   - Update `lib/services/api_service.dart`
   - Set backend URL (http://localhost:8000)
   - Test API integration

4. **Development tips**:
   - Use hot reload: Press `r` in terminal while app is running
   - Use hot restart: Press `R` in terminal
   - Use debugger in VS Code with Flutter extension

---

## 📱 Recommended Emulator Settings

For best performance:

- **Device**: Pixel 5 or Pixel 7
- **System Image**: Android 13 (API 33)
- **RAM**: 2048 MB minimum, 4096 MB recommended
- **Graphics**: Automatic (or Hardware if available)

---

## 💡 Tips

1. **First time setup takes time**: Installing Flutter, Android Studio, and SDKs can take 30-60 minutes

2. **Use an SSD**: Flutter builds are much faster on SSD vs HDD

3. **Keep Flutter updated**: Run `flutter upgrade` periodically

4. **Use VS Code**: Install Flutter extension for better development experience

5. **Enable hot reload**: Makes development much faster

6. **Test on real device**: Some features (like audio recording) work better on physical devices

---

## 🆘 Still Having Issues?

### Check Flutter Doctor

```bash
flutter doctor -v
```

Look for any [✗] marks and follow the suggestions.

### Common Solutions

1. **Restart terminal** after PATH changes
2. **Restart Android Studio** after SDK installation
3. **Restart computer** if emulator won't start
4. **Run as Administrator** if permission issues
5. **Disable antivirus** temporarily if download fails

### Get Help

- **Flutter Docs**: https://docs.flutter.dev
- **Flutter Discord**: https://discord.gg/flutter
- **Stack Overflow**: Tag questions with `flutter`

---

## ✅ Success Checklist

Before running the app:

- [ ] Flutter installed: `flutter --version` works
- [ ] Android Studio installed (for Android)
- [ ] Android SDK installed
- [ ] Android licenses accepted: `flutter doctor --android-licenses`
- [ ] Emulator created and running OR device connected
- [ ] `flutter devices` shows at least one device
- [ ] `flutter doctor` shows mostly green checkmarks
- [ ] Dependencies installed: `flutter pub get` successful

Once all checked, run:
```bash
flutter run
```

**🎉 Your CallCraft mobile app should now be running!**

---

## 🚀 Quick Start Summary

**Easiest way (automated):**
```powershell
# Just run this!
.\setup_flutter.ps1
```

**Manual way:**
```bash
# 1. Install Flutter + add to PATH
# 2. Install Android Studio
# 3. Create emulator
# 4. Run these commands:
cd mobile
flutter pub get
flutter run
```

**That's it!** 🎉
