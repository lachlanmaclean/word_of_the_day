# Sid's Word of the Day

A Flutter mobile app that delivers one vocabulary word per day—with definition, example sentence, pronunciation, and part of speech. Made with love in New Zealand.

## About

Sid's Word helps you expand your vocabulary with clear, focused learning: one new word every calendar day. The app is inspired by Sid, a cat who appreciates a good book.

## Features

- **One word a day** — One new word per day with definition, example sentence, pronunciation, and part of speech
- **Daily reminder** — Optional local notification at a time you choose (set in Settings)
- **Previous words** — Browse the last 7 days and tap any word to view full details in a bottom sheet
- **Settings** — "Who's Sid?" section, reminder time picker, and quick access to previous words

## Technologies

| Area | Technologies |
|------|--------------|
| **Framework** | [Flutter](https://flutter.dev/) (cross-platform) |
| **Language** | [Dart](https://dart.dev/) (SDK ^3.10.7) |
| **Android** | Kotlin, Gradle (Kotlin DSL), Android SDK |
| **Fonts** | [Google Fonts](https://pub.dev/packages/google_fonts) (Playfair Display, Source Sans 3) |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications), [timezone](https://pub.dev/packages/timezone), [flutter_timezone](https://pub.dev/packages/flutter_timezone) |
| **Persistence** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Web / docs** | HTML, CSS (GitHub Pages in `/docs`) |

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.7 or compatible)
- Android Studio / Xcode for device or emulator

### Run the app

```bash
flutter pub get
flutter run
```

### Build release (Android)

```bash
flutter build appbundle
```

The AAB is output to `build/app/outputs/bundle/release/app-release.aab`.

## Project structure

- `lib/` — Flutter app (main UI, notification service, word bank)
- `android/` — Android native project (Kotlin, Gradle)
- `ios/` — iOS native project
- `docs/` — Static site for GitHub Pages (landing, privacy, terms)

## Author

**Lachlan Maclean**

- GitHub: [@lachlanmaclean](https://github.com/lachlanmaclean)
- Repo: [github.com/lachlanmaclean/word_of_the_day](https://github.com/lachlanmaclean/word_of_the_day)

## License

Private project. All rights reserved.
