# Akili TV app

Watch Akili TV, Kenya's family channel, live on Android phones, tablets,
Android TV / Google TV and Amazon Fire TV. One Flutter codebase, one design
system, one app listing on Google Play.

## How it's built

```
lib/
  main.dart                    App entry: theme, TV remote setup
  config/app_config.dart       Stream URLs and app settings (edit here)
  theme/akili_theme.dart       All colours and text styles
  services/device_service.dart Detects TV; keeps screen awake during playback
  player/
    live_stream_controller.dart  Stream health: fallback URLs, auto-reconnect,
                                 stall detection, pauses when app is hidden
    live_player_view.dart        Video + overlays + touch/remote controls
  screens/
    shell_screen.dart          Bottom tabs (phone) / side rail (tablet, TV)
    home_screen.dart, live_screen.dart, about_screen.dart,
    fullscreen_player_screen.dart
  widgets/                     Shared button, focus ring, LIVE badge
android/                       Android + Android TV packaging
.github/workflows/build.yml    Automatic builds on GitHub
```

Phones get bottom tabs. Tablets and TVs get a side rail and larger type.
On TV, everything is reachable with the D-pad, the focused item shows a
white ring, and "Watch Live" opens straight into full-screen playback.

## Getting a build (no Flutter install needed)

Every push to GitHub builds the app automatically:

1. Open the repo on GitHub → **Actions** tab → latest **Build Android app** run.
2. Under **Artifacts**, download `akili-tv-apk-…`.
3. Install the `.apk` on a phone or Android TV to test.

## Release signing (one-time setup, required for Google Play)

Google Play only accepts builds signed with Akili's **upload key**. The key
lives in GitHub secrets, never in the code.

Add these under **Settings → Secrets and variables → Actions**:

| Secret | What it is |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | The upload keystore file, base64-encoded |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias (e.g. `upload`) |
| `ANDROID_KEY_PASSWORD` | Key password |

Once set, each build also produces `akili-tv-play-bundle-…` (`.aab`), which
is what you upload to Google Play Console. Enrol in **Play App Signing** so a
lost upload key can be reset by Google.

## For developers

```bash
flutter pub get
flutter run                      # phone or emulator
flutter run -d <android-tv-id>   # Android TV emulator or device
flutter analyze && flutter test
```

Change the stream without touching code:
`flutter build apk --dart-define=STREAM_URL=https://.../playlist.m3u8`
