# CallCraft Mobile App

Flutter mobile application for CallCraft - Smart call analysis for sales professionals.

## Features

- 🎤 **Audio Recording**: Record calls directly in the app
- 📁 **Import Audio**: Import existing audio files
- 🔤 **On-Device Transcription**: Whisper.cpp for privacy-first transcription (planned)
- 📊 **AI Analysis**: Get sentiment, risk flags, and summaries
- 💬 **WhatsApp Integration**: Generate and share follow-up messages
- 📧 **Email Drafts**: Auto-generate professional emails
- 🌐 **Multi-Language**: Gujarati, Hindi, Hinglish support
- 📱 **Cross-Platform**: Android & iOS

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                # App entry point
│   ├── screens/
│   │   ├── home_screen.dart     # Call history list
│   │   ├── recording_screen.dart # Record/import audio
│   │   ├── analysis_screen.dart  # Show analysis results
│   │   └── auth/
│   │       └── login_screen.dart # Authentication
│   ├── services/
│   │   ├── api_service.dart     # Backend API client
│   │   ├── audio_service.dart   # Audio recording (TODO)
│   │   └── transcription_service.dart # Whisper.cpp (TODO)
│   ├── models/
│   │   ├── user.dart            # User & auth models
│   │   └── call_record.dart     # Call & analysis models
│   ├── providers/               # Riverpod state management
│   └── widgets/                 # Reusable UI components
├── assets/                      # Images, animations
├── test/                        # Unit & widget tests
└── pubspec.yaml                 # Dependencies
```

## Prerequisites

- **Flutter** 3.19+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart** 3.0+
- **Android Studio** or **Xcode** (for platform-specific development)
- **CallCraft Backend** running (see backend/README.md)

## Setup

### 1. Install Flutter

Follow the official guide: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

### 2. Get Dependencies

```bash
cd mobile
flutter pub get
```

### 3. Configure Backend URL

Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL:8000';
```

For local development:
- **Android Emulator**: Use `http://10.0.2.2:8000`
- **iOS Simulator**: Use `http://localhost:8000`
- **Physical Device**: Use your computer's local IP (e.g., `http://192.168.1.100:8000`)

### 4. Run Code Generation (for JSON serialization)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running the App

### Android Emulator

```bash
# List devices
flutter devices

# Run on Android
flutter run
```

### iOS Simulator

```bash
# Open simulator
open -a Simulator

# Run on iOS
flutter run
```

### Physical Device

1. **Android**:
   - Enable USB debugging
   - Connect device via USB
   - Run: `flutter run`

2. **iOS**:
   - Connect device
   - Trust computer on device
   - Run: `flutter run`

## Development

### Hot Reload

- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Code Generation

When you modify models with JSON serialization:
```bash
flutter pub run build_runner watch
```

### Testing

Run all tests:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/widget_test.dart
```

## Building for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload.

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `record` | Audio recording |
| `just_audio` | Audio playback |
| `http` / `dio` | API calls |
| `hive` | Local storage |
| `sqflite` | SQLite database |
| `share_plus` | Sharing functionality |
| `url_launcher` | Open WhatsApp/URLs |
| `permission_handler` | Runtime permissions |

## TODO Features

- [ ] Integrate Whisper.cpp for on-device transcription
- [ ] Implement actual audio recording (currently placeholder)
- [ ] Add offline queue for analyses
- [ ] Implement call history sync
- [ ] Add push notifications
- [ ] Profile screen with subscription info
- [ ] Settings screen
- [ ] Dark mode toggle
- [ ] Export transcripts as PDF
- [ ] Search and filter call history
- [ ] Call tags and categories

## Platform-Specific Setup

### Android Permissions

Already configured in `android/app/src/main/AndroidManifest.xml`:
- `RECORD_AUDIO`
- `WRITE_EXTERNAL_STORAGE`
- `READ_EXTERNAL_STORAGE`
- `INTERNET`

### iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record calls</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need library access to import audio files</string>
```

## Troubleshooting

### "Unable to connect to backend"

- Verify backend is running: `curl http://localhost:8000/health`
- Check API URL in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`

### Permission errors on iOS

- Delete app from simulator
- Run `flutter clean && flutter pub get`
- Rebuild app

### Build errors

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Contributing

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and test: `flutter test`
3. Commit: `git commit -m "Add feature"`
4. Push: `git push origin feature/my-feature`
5. Create pull request

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design](https://m3.material.io/)

## License

Proprietary - CallCraft
