# Rigel Space Saver

Free, offline, privacy-first gallery compression for Android. By Tech Rigel.

Find and compress the photos, videos and audio filling your phone — sorted
biggest first — then optionally replace the originals and strip metadata.
Nothing is ever uploaded; every byte is processed on your device.

## Status

Under active development. See [`PLAN.md`](PLAN.md) for the phase-by-phase
roadmap and current progress.

## Requirements

- Flutter 3.41.7 / Dart 3.11.5
- Android 8.0 (API 26) or newer

## Getting started

```bash
flutter pub get
flutter run
```

## Useful commands

```bash
flutter analyze        # static analysis
flutter test           # unit tests
flutter build apk      # release build
```

## Project layout

```
lib/
  app.dart                  MaterialApp + dynamic theming
  main.dart                 entry point
  core/
    theme/                  palette, themes, appearance settings
    utils/                  formatting and path helpers
  presentation/
    screens/                top-level screens
    widgets/                shared UI components
```
