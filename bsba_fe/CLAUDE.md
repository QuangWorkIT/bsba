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
- `lib/app/` is the home for app-level shell code (theme, routing, top-level widget).
- `lib/data/` holds the data layer, split into `models/`, `services/`, and `repositories/`.
- `lib/ui/` holds feature UI, one folder per feature (`auth/`, `cart/`, `checkout/`, `explore/`, `inbox/`, `map/`, `profile/`). Extracted presentation pieces live in a `widgets/` subfolder of the feature; screen state lives in `*_viewmodel.dart`; cross-feature widgets live in `lib/ui/shared/`. Don't scatter files into `lib/` root.

## UI code structure requirements (PRM393 rubric)

The course grades *how* the UI is built, not just that screens render. Follow these when adding or editing feature UI:

- **Widget decomposition** — never put a whole screen in one `build()`. Split into small, named, reusable widgets: one public widget per file under `lib/ui/<feature>/widgets/`, with tightly-coupled sub-widgets kept as private classes in the same file. [lib/ui/inbox/widgets/chat/](lib/ui/inbox/widgets/chat/) is the reference pattern.
- **State management** — use a viewmodel/Provider per screen; don't drive cross-screen state with scattered `setState`. UI reads data from models/repositories, never hardcoded.
- **Data-driven UI states** — any screen backed by an API/repository handles all four states: loading, loaded, error, empty. Don't assume data is always present.
- **Validation** — validate form inputs (login, checkout, chat); block empty/invalid submits and show the error inline.
- **Error handling** — wrap async/API calls and surface failures instead of white screens; guard against null before rendering.
- **Responsive layout** — wrap scrollable forms in `SafeArea` + `SingleChildScrollView`; use `Expanded`/`Flexible`/`MediaQuery`/`LayoutBuilder` to avoid `RenderFlex overflowed`; ellipsize long text.
- **Performance** — long lists use `ListView.builder`/`GridView.builder`, never `Column(children: list.map(...))`. Prefer `const` widgets. Never call APIs from `build()`.
- **Consistency** — pull colors/text styles from `Theme.of(context).colorScheme` (see brand palette above); don't inline new hex literals in feature code.
- **Navigation** — use `Navigator`/named routes; pass typed objects/ids between screens; verify the back stack.

## Known gotchas

- [test/widget_test.dart](test/widget_test.dart) is the unmodified Flutter template test (looks for a counter and `Icons.add`). It will fail against the current `BoardGameBookingApp`, which renders nothing. Replace it when you add a real `home` widget rather than trying to make the counter assertions pass.
- `MaterialApp` in [lib/app/app.dart](lib/app/app.dart) has no `home`, `routes`, or `onGenerateRoute` — adding any visible UI requires wiring one of these.
