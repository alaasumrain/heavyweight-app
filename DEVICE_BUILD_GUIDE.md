# HEAVYWEIGHT - Device Build Guide

Quick setup to get the app running on your phone for testing.

## Prerequisites

- Flutter SDK installed
- For iOS: Xcode
- For Android: Android Studio/SDK
- Your Supabase credentials

## 1. Setup Environment

Create `env.json` in project root:

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR-ANON-KEY"
}
```

## 2. iOS (Quick Dev Install)

```bash
# Check connected devices
flutter devices

# Run on iPhone (replace with your device ID)
flutter run -d <your-iphone-device-id> --dart-define-from-file=env.json
```

**If you get signing errors:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Signing & Capabilities
3. Change Bundle Identifier to something unique (e.g., `com.yourname.heavyweight`)
4. Select your Team

## 3. Android (Quick Dev Install)

```bash
# Enable Developer Options + USB debugging on your Android phone
# Connect via USB

# Check connected devices
flutter devices

# Run on Android (replace with your device ID)
flutter run -d <your-android-device-id> --dart-define-from-file=env.json
```

## 4. Quick Test Commands

```bash
# Hot reload while developing
r

# Hot restart
R

# Quit
q
```

## Troubleshooting

**"SUPABASE_URL not configured"**: Make sure `env.json` exists in project root

**iOS signing issues**: Change Bundle ID in Xcode to something unique

**Android won't connect**: Enable USB debugging in Developer Options

**App crashes on launch**: Check that your Supabase credentials are correct in `env.json`