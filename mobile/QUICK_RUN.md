# 🚀 Run CallCraft Mobile App - Quick Guide

## ⚡ Fastest Way (Automated)

### Windows PowerShell (Recommended)

```powershell
# Right-click setup_flutter.ps1 > Run with PowerShell
# Or:
.\setup_flutter.ps1
```

### Windows Command Prompt

```batch
# Double-click setup_flutter.bat
# Or:
setup_flutter.bat
```

**The script will automatically:**
- ✅ Check if Flutter is installed
- ✅ Download & install Flutter if needed (~600MB, 5-10 min)
- ✅ Set up Android emulator guidance
- ✅ Install dependencies
- ✅ Run the app

---

## 📋 Before Running (First Time Only)

### You Need ONE of These:

1. **Android Emulator** (recommended)
   - Install Android Studio: https://developer.android.com/studio
   - Create an emulator (script will guide you)

2. **Physical Android Device**
   - Enable USB Debugging
   - Connect via USB

3. **Chrome Browser** (for web testing)
   - Easiest for quick testing

4. **Windows Desktop**
   - Requires Visual Studio 2022

---

## 🎯 Step-by-Step (First Time)

### 1. Run the Setup Script

```powershell
.\setup_flutter.ps1
```

If Flutter is not installed, it will download it (~600MB).
**This can take 10-30 minutes depending on your internet speed.**

### 2. Follow the Prompts

The script will check for devices and guide you through:
- Creating an Android emulator (if needed)
- Selecting a device to run on
- Installing app dependencies

### 3. Wait for App to Start

First run takes ~2 minutes to build.
Subsequent runs are much faster (~30 seconds).

### 4. App Running!

You'll see the CallCraft app on your emulator/device.

---

## 🔄 Running Again (After First Setup)

Once Flutter is installed and you have a device:

```bash
# Simple way
flutter run

# Or use the script
.\setup_flutter.ps1

# Specific device
flutter run -d chrome          # Chrome
flutter run -d windows         # Windows desktop
flutter run -d <device-id>     # Specific device
```

---

## 🐛 Common Issues

### "Flutter not found"

**Solution**: Run the setup script, it will install Flutter:
```powershell
.\setup_flutter.ps1
```

### "No devices found"

**Solution**: Start an emulator or connect a device

**Quick fix**: Run on Chrome (no setup needed)
```bash
flutter run -d chrome
```

### "Android licenses not accepted"

**Solution**:
```bash
flutter doctor --android-licenses
# Press 'y' for all
```

### "Script won't run in PowerShell"

**Solution**: Enable script execution (run as Admin)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run the script again.

---

## 📱 Device Options Explained

### Option 1: Android Emulator (Best for Development)

**Pros:**
- ✅ No physical device needed
- ✅ Easy debugging
- ✅ Multiple device sizes

**Setup:**
1. Install Android Studio
2. Tools > AVD Manager > Create Virtual Device
3. Select Pixel 5 + Android 13
4. Start emulator before running app

### Option 2: Physical Android Device (Best for Testing)

**Pros:**
- ✅ Real device performance
- ✅ Test actual hardware (camera, GPS, etc.)

**Setup:**
1. Enable Developer Options (tap Build Number 7 times)
2. Enable USB Debugging
3. Connect via USB
4. Allow debugging on phone

### Option 3: Chrome (Quickest for UI Testing)

**Pros:**
- ✅ No setup needed
- ✅ Instant start
- ✅ Fast hot reload

**Cons:**
- ❌ No native features (camera, audio)
- ❌ Different performance

**Run:**
```bash
flutter run -d chrome
```

### Option 4: Windows Desktop (For Desktop App)

**Pros:**
- ✅ Native Windows app
- ✅ Fast development

**Cons:**
- ❌ Requires Visual Studio 2022

**Run:**
```bash
flutter run -d windows
```

---

## ⏱️ Expected Times

| Task | First Time | After Setup |
|------|------------|-------------|
| Run setup script | 10-30 min | 1 min |
| Flutter download | 5-10 min | - |
| Android Studio install | 10-20 min | - |
| Emulator creation | 5-10 min | - |
| First app build | 2-3 min | 30 sec |
| Hot reload | - | 1-2 sec |

---

## 🎓 Development Workflow

Once running:

1. **Hot Reload**: Press `r` in terminal (updates UI instantly)
2. **Hot Restart**: Press `R` in terminal (full restart)
3. **Quit**: Press `q` in terminal

**Tip**: Leave the app running and just press `r` after making changes!

---

## 📚 More Help

- **Detailed guide**: [FLUTTER_SETUP_GUIDE.md](FLUTTER_SETUP_GUIDE.md)
- **Flutter docs**: https://docs.flutter.dev
- **Troubleshooting**: Run `flutter doctor -v`

---

## ✅ Quick Checklist

Ready to run?

- [ ] Flutter installed (run setup script if not)
- [ ] Device available (emulator, phone, or Chrome)
- [ ] Backend running (optional, for API features)
- [ ] In mobile directory

Then run:
```bash
flutter run
```

---

## 🎉 Success Looks Like

When the app starts, you'll see:

```
Launching lib/main.dart on <device> in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app-debug.apk...
Waiting for <device> to report its views...
Synced 1.2MB.
🔥 To hot reload changes while running, press "r" or "R".
For a more detailed help message, press "h". To quit, press "q".

An Observatory debugger and profiler on <device> is available at: http://127.0.0.1:xxxxx/
The Flutter DevTools debugger and profiler on <device> is available at: http://127.0.0.1:xxxxx/
```

And the CallCraft app appears on your device! 🎉

---

**Need help?** Check [FLUTTER_SETUP_GUIDE.md](FLUTTER_SETUP_GUIDE.md) for detailed troubleshooting.
