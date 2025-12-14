# Flutter Project Setup Guide

## Required Flutter Version

This project requires:
- **Flutter**: `3.29.3` (stable channel)
- **Dart**: `3.7.2`
- **SDK constraint**: `^3.7.2`

## Setup Instructions

### 1. Install Flutter

Download and install Flutter 3.29.3:
```bash
# Check current Flutter version
flutter --version

# If needed, switch to stable channel
flutter channel stable

# Update to specific version (if not already on 3.29.3)
flutter upgrade
```

### 2. Clone Project

```bash
git clone <repository-url>
cd EnglishApp/mobile
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

**For Web:**
```bash
flutter run -d chrome
# or
flutter run -d edge
```

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

## Important Notes

### Backend Configuration
Before running, check `lib/core/constants/api_config.dart`:

```dart
// For local development with ngrok
static const bool useLocalBackend = true;

// For production
static const bool useLocalBackend = false;
```

### Common Issues

**Issue: Version mismatch**
```bash
# Clean and rebuild
flutter clean
flutter pub get
```

**Issue: Platform-specific errors**
```bash
# For Android
cd android
./gradlew clean
cd ..

# For iOS
cd ios
pod install
cd ..
```

## Build for Production

**Web:**
```bash
flutter build web --release
```

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Dependencies

Key packages used (see `pubspec.yaml` for full list):
- `provider: ^6.1.5` - State management
- `go_router: ^16.2.0` - Navigation
- `http: ^1.4.0` - API calls
- `cached_network_image: ^3.3.1` - Image caching
- `syncfusion_flutter_calendar: ^31.1.19` - Calendar
- `flutter_quill: ^11.0.0` - Rich text editor
- And more...

## Troubleshooting

If you encounter issues after cloning:

1. **Clean everything:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Check Flutter doctor:**
   ```bash
   flutter doctor -v
   ```

3. **Ensure correct Flutter version:**
   ```bash
   flutter --version
   # Should show: Flutter 3.29.3
   ```

4. **For web issues:**
   ```bash
   flutter config --enable-web
   ```
