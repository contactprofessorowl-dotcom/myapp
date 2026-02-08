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

## Firebase AI Logic (Gemini) — no API key in the app

Quiz and vocabulary generation use the **Gemini API** via [Firebase AI Logic](https://firebase.google.com/docs/ai-logic/get-started). The API key is **not** stored in the app; it is managed in your Firebase project.

1. In the [Firebase Console](https://console.firebase.google.com/), open your project and go to **Build → Firebase AI Logic** (or the AI section).
2. Click **Get started** and complete the workflow. Choose the **Gemini Developer API**; the console will enable the required APIs and create a Gemini API key in the project.
3. **Do not** add this API key to your app code. The `firebase_ai` SDK uses your app’s Firebase configuration to authenticate.

After this one-time setup, the app’s AI features work without any API key in the codebase. For production, consider [App Check](https://firebase.google.com/docs/app-check) and [Remote Config](https://firebase.google.com/docs/ai-logic/remote-config) to protect and remotely configure the model.

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
