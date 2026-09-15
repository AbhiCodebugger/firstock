# Setup — mindorigin

First-run notes for the Mindorigin Portfolio app. Architecture and stack live in **[README.md](README.md)** and **[AGENTS.md](AGENTS.md)**. UI tokens live in **[DESIGN.md](DESIGN.md)**.

Package: `com.example.mindorigin`. Flutter **3.41.x** (CI pin) or current stable with **Dart ≥ 3.5**. Android and iOS.

---

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) **3.41.x** or current stable (**Dart ≥ 3.5**)
- Xcode (iOS) or Android Studio / SDK (Android API 21+)
- A device or emulator (`flutter devices`)
- Optional for **prod**: a [Finnhub](https://finnhub.io) API token — never commit it

```bash
flutter doctor
```

---

## Install

```bash
git clone <repo-url>
cd mindorigin
flutter pub get
```

No `build_runner` step is required. On iOS, native plugins resolve via Swift Package Manager when you run `flutter pub get` or `flutter run`.

---

## Flavors and env

Do **not** create a generic `.env` or run `lib/main.dart` as the flavor. Each flavor loads its own file:

| Config | Flavor | Entry | Env | Feed |
| ------ | ------ | ----- | --- | ---- |
| `dev` | `Flavor.dev` | `lib/main_dev.dart` | `.env.dev` | Simulated ticks, Kill socket, rebuild counters |
| `beta` | `Flavor.qa` | `lib/main_qa.dart` | `.env.qa` | Simulated ticks, different `WS_URL` / backoff |
| `prod` | `Flavor.prod` | `lib/main_prod.dart` | `.env.prod` | Finnhub snapshot + `wss://ws.finnhub.io` |

Those env files are already in the repo. They set `API_BASE_URL`, `WS_URL`, `FEED_TYPE`, backoff knobs, and feature flags. `.env.prod` has an empty `FINNHUB_TOKEN=` placeholder only.

Prod reads the token from `--dart-define=FINNHUB_TOKEN=...` (or the IDE env). Do **not** put a real token in `.env.prod`.

Keys used by `Env` / `FlavorConfig`:

| Key | Purpose |
| --- | ------- |
| `API_BASE_URL` | Finnhub REST base (`https://finnhub.io/api/v1`) |
| `WS_URL` | Simulated URL on dev/qa; `wss://ws.finnhub.io` on prod |
| `FEED_TYPE` | `simulated` or `finnhub` |
| `BACKOFF_INITIAL_MS` / `BACKOFF_MAX_MS` / `BACKOFF_JITTER` | Reconnect backoff |
| `SIMULATE_DISCONNECT` | Random drop/restore on simulated feed |
| `SHOW_KILL_SOCKET` | Header **Kill socket** (dev) |
| `SHOW_REBUILD_COUNTERS` | In-app rebuild counters (dev) |
| `FINNHUB_TOKEN` | Placeholder only — real value via dart-define |

---

## Run

CLI:

```bash
flutter run -t lib/main_dev.dart
flutter run -t lib/main_qa.dart
flutter run -t lib/main_prod.dart --dart-define=FINNHUB_TOKEN=your_token
```

In Cursor / VS Code / IntelliJ pick **dev**, **beta**, or **prod** from `.vscode/launch.json`. Use **dev (profile)** / **beta (profile)** / **prod (profile)** when measuring FPS.

Dev **Kill socket** drops the feed so reconnect can be demoed without airplane mode. The chip must show `Reconnecting…`, then `Live` after snapshot + resubscribe.

---

## Permissions

The app only needs network access for quote snapshots and the live price feed. No camera, photos, location, or other device permissions.

**Android** — already declared in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** — no extra `Info.plist` usage-description keys.

---

## Localization

English only (`assets/translations/en.json`). After adding or changing strings:

```bash
flutter pub run easy_localization:generate -S assets/translations -O lib/src/core/i18n -o locale_keys.g.dart
```

---

## Native splash (optional)

`flutter_native_splash` is in the project. Bootstrap preserves and removes the native splash. There is no splash image checked in; `flutter_native_splash.yaml` still has a placeholder color.

To apply a custom launch screen:

1. Add a transparent logo at `assets/images/splash.png`.
2. Set `color` to the navy canvas `#051424` (not a leftover purple).
3. Uncomment the `image:` paths in `flutter_native_splash.yaml`.
4. Run:

```bash
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

---

## Firebase App Distribution (optional)

`lib/firebase_options.dart` exists for Android/iOS App Distribution. Bootstrap does **not** call `Firebase.initializeApp`. Local **dev** / **qa** / **prod** runs do not require Firebase.

To ship an APK:

```bash
flutter build apk -t lib/main_prod.dart --dart-define=FINNHUB_TOKEN=your_token
```

Upload the APK in Firebase App Distribution. Do not commit `google-services.json`, `GoogleService-Info.plist`, keystores, or a real `FINNHUB_TOKEN`.

---

## Verify

```bash
flutter analyze
flutter test
```

CI (`.github/workflows/ci.yml`) runs the same commands on Flutter `3.41.x`.
