# PRANA Flutter App

A production-oriented Flutter foundation for PRANA, based on the supplied prototype and revised navigation.

## Navigation
- Home
- Masterclass
  - Workshops
  - Masterclasses
- Consult
- Library
  - Static PRANA videos
  - Transcript-aware local search
  - Architecture ready for a backend-powered YouTube catalogue
- Account

## Architecture
- BLoC/Cubit only for mutable UI/application state. No `setState`.
- `go_router` under `lib/app`.
- Shared design system, errors, services and reusable widgets under `lib/core`.
- Feature-first structure under `lib/features`.
- Localization through Flutter gen-l10n.
- Light and dark themes.
- Responsive phone/tablet layout.

## Run
This package intentionally contains the app source and platform-independent Flutter project files. On any machine with Flutter installed:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter gen-l10n
flutter run
```

`flutter create` preserves the existing `lib/`, `pubspec.yaml`, tests and docs while generating the current Android/iOS host projects for your installed Flutter SDK. This is safer than shipping stale generated native host files.

## YouTube production approach
Do not put YouTube API keys or OAuth client secrets directly in the app.

Recommended production pipeline:
1. Backend syncs the PRANA YouTube channel via YouTube Data API v3.
2. Backend stores normalized video metadata.
3. Captions/transcripts are obtained only through authorized/owned-channel mechanisms and indexed server-side.
4. The app calls a `/library/search?q=...` API returning matching videos plus transcript snippets/timestamps.
5. The app plays selected videos through the YouTube player.
6. Cache recent catalogue/search responses locally if required.

The included `LibraryRepository` is deliberately abstract. `MockLibraryRepository` demonstrates the UX and transcript search today; replace it with an API-backed implementation without changing the presentation layer.

## Payments
`PaymentGateway` is an abstraction. Production checkout should be created server-side and opened through a hosted checkout or vendor SDK. Never embed payment secret keys in Flutter.
