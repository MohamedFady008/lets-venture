# Lets Venture

Lets Venture is a Flutter mobile app with educational and interactive content
for kids, including games, stories, media playback, and profile/settings flows.

## Tech stack

- Flutter / Dart
- Firebase (Core, Auth, Firestore, Storage)
- GetX (state management + routing)
- Shared Preferences

## Project structure

- `lib/screens/` app screens (auth, splash, profile, settings)
- `lib/games/` game modules
- `lib/models/` data models
- `lib/locale/` localization and language controller
- `lib/check_network/` network state binding
- `assets/` static assets and media

## Prerequisites

- Flutter SDK (stable)
- Dart SDK (comes with Flutter)
- Android Studio/Xcode depending on target platform
- Firebase project configured for your app IDs

## Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Configure Firebase (recommended with FlutterFire CLI):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and platform Firebase config
   files locally for your environment.
3. Run the app:
   ```bash
   flutter run
   ```

## Security notes

- Do not commit secrets, keystores, signing configs, or environment files.
- This repository ignores:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `lib/firebase_options.dart`
  - signing and key material files
- Lock down Firebase access with strict Authentication, Firestore/Storage rules,
  and API key restrictions in Google Cloud Console.

## Quality checks

```bash
flutter analyze
flutter test
```

If your project has no `test/` directory yet, create one before running tests.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
