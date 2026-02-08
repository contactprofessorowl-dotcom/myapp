# Android SDK: sdkmanager not found

Flutter and the Android build need **Android SDK Command-line Tools** (they provide `sdkmanager`). Install them once, then restart your terminal.

## Option A: Android Studio (recommended)

1. Open **Android Studio**.
2. **Settings** (or **Android Studio → Preferences** on macOS) → **Languages & Frameworks** → **Android SDK**.
3. Open the **SDK Tools** tab.
4. Check **Android SDK Command-line tools (latest)**.
5. Click **Apply** / **OK** and wait for the install to finish.

This installs into `$ANDROID_HOME/cmdline-tools/latest/`. Your `~/.zshrc` already adds that folder to `PATH`; after installing, open a new terminal or run `source ~/.zshrc`.

## Option B: Manual install

1. Download **Command line tools only** for macOS from:  
   https://developer.android.com/studio#command-line-tools-only  
2. Unzip the archive (you get a folder named `cmdline-tools`).
3. Run (adjust paths if your SDK is elsewhere):

   ```bash
   mkdir -p $HOME/Library/Android/sdk/cmdline-tools
   mv ~/Downloads/cmdline-tools $HOME/Library/Android/sdk/cmdline-tools/latest
   ```

4. Open a new terminal or run `source ~/.zshrc`.

Then run `sdkmanager --version` to confirm it works.
