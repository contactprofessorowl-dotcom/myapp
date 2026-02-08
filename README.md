# myapp

A new Flutter project.

## Firebase (Crashlytics & Analytics)

The app includes Firebase Crashlytics and Analytics. To finish setup:

1. Install the [Firebase CLI](https://firebase.google.com/docs/cli) and log in: `firebase login`
2. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. From the project root, run: **`dart run flutterfire_cli:flutterfire configure`** (or `flutterfire configure` if the CLI is on your PATH)

This will create/update `lib/firebase_options.dart` and add `android/app/google-services.json` (and iOS config if you add an `ios` folder). Replace the placeholder values in `lib/firebase_options.dart` by running this step; the app will not report to Firebase until you do.

- **Crashlytics**: Uncaught Flutter and async errors are sent automatically. Use `Provider.of<FirebaseService>(context, listen: false)` to call `recordError()`, `log()`, or `setCustomKey()` for custom reporting.
- **Analytics**: Screen views are logged automatically when navigating. Use `FirebaseService.logEvent()` for custom events.

## Release signing (Android)

A release keystore `flash-release-key.jks` is in the project root (alias: `upload`). **Change the default passwords** before use:

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Set `storePassword` and `keyPassword` to your chosen passwords (replace `changeme`).
3. To change the keystore passwords: `keytool -storepasswd -keystore flash-release-key.jks` and `keytool -keypasswd -alias upload -keystore flash-release-key.jks`.

Keep `key.properties` and `*.jks` out of version control (they are in `.gitignore`).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
