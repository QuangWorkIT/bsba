# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

BoardNest — a Flutter mobile app for booking board-game spaces (FPTU PRM393 course project, package name `project`). The codebase is in an early scaffolding stage: `MaterialApp` is themed but has no `home`/routes wired yet, so running the app currently shows a blank screen.

## Common commands

```bash
flutter pub get               # install dependencies
flutter run                   # run on the connected device/emulator
flutter analyze               # lint (uses package:flutter_lints/flutter.yaml)
flutter test                  # run all tests
flutter test test/widget_test.dart -p "<test name>"  # run a single test
flutter build apk             # Android release build
```

Dart SDK: `^3.12.0` (see [pubspec.yaml](pubspec.yaml)).

## Architecture

- [lib/main.dart](lib/main.dart) — entry point, only calls `runApp(const BoardGameBookingApp())`.
- [lib/app/app.dart](lib/app/app.dart) — root `BoardGameBookingApp` widget. Holds the entire `ThemeData` (color scheme, AppBar, Card, ElevatedButton styling). The intended brand palette lives here:
  - scaffold/background: `#F7EFE5` (warm cream)
  - primary: `#1275e2`, secondary: `#5f78a3`, tertiary: `#C55B00`
  - surface (cards): `#FFF9F3`
  - Cards use 22px rounded corners; ElevatedButtons use 18px.
  When adding new screens/widgets, pull colors from `Theme.of(context).colorScheme` rather than hardcoding these hex values again.
- `lib/app/` is the intended home for app-level shell code (theme, routing, top-level widget). Feature code does not yet have an established folder convention — when introducing the first feature, set the pattern deliberately rather than scattering files into `lib/` root.

## Known gotchas

- [test/widget_test.dart](test/widget_test.dart) is the unmodified Flutter template test (looks for a counter and `Icons.add`). It will fail against the current `BoardGameBookingApp`, which renders nothing. Replace it when you add a real `home` widget rather than trying to make the counter assertions pass.
- `MaterialApp` in [lib/app/app.dart](lib/app/app.dart) has no `home`, `routes`, or `onGenerateRoute` — adding any visible UI requires wiring one of these.
