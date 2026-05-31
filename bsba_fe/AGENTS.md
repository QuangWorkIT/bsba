# AGENTS.md

Instructions for AI coding agents (Claude Code, Cursor, Copilot, Codex, etc.) working in this repository. Human contributors should read this too.

## Project

BoardNest — a Flutter mobile app for booking board-game spaces. Course project for FPTU PRM393. The Dart package name is `project` (see [pubspec.yaml](pubspec.yaml)), so imports use `package:project/...`.

The codebase follows a structured **MVVM (Model-View-ViewModel)** architecture pattern, separating data services, models, and repositories from the UI presentation layer.

## Environment

- Dart SDK: `^3.12.0` (see [pubspec.yaml](pubspec.yaml))
- Flutter: any version compatible with Dart 3.12+
- Target platforms configured: Android, iOS (no web/desktop scaffolding present)
- Primary developer OS: Windows 11 + PowerShell. Use PowerShell-compatible syntax for shell commands you suggest.

## Setup

```bash
flutter pub get
```

## Commands

| Task | Command |
| --- | --- |
| Run on connected device/emulator | `flutter run` |
| Hot-reload during `flutter run` | press `r` in the terminal |
| Static analysis / lint | `flutter analyze` |
| Run all tests | `flutter test` |
| Run a single test file | `flutter test test/widget_test.dart` |
| Run tests matching a name | `flutter test --plain-name "<substring>"` |
| Format code | `dart format .` |
| Android release APK | `flutter build apk` |
| iOS release | `flutter build ios` |

Run `flutter analyze` and `flutter test` before declaring a task done. Do not silence lint rules to make analyze pass — fix the underlying issue.

## Architecture

The application's directory structure is organized as follows:

```text
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── dependencies.dart
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   │
│   ├── utils/
│   └── constants/
│
├── data/
│   ├── services/
│   │   ├── api_client.dart
│   │   ├── auth_service.dart
│   │   ├── booking_service.dart
│   │   └── boardgame_service.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── booking_repository.dart
│   │   └── boardgame_repository.dart
│   │
│   └── models/
│       ├── user.dart
│       ├── booking.dart
│       └── boardgame.dart
│
└── ui/
    ├── auth/
    │   ├── login_screen.dart
    │   └── login_viewmodel.dart
    │
    ├── home/
    │   ├── home_screen.dart
    │   └── home_viewmodel.dart
    │
    ├── booking/
    │   ├── booking_screen.dart
    │   └── booking_viewmodel.dart
    │
    ├── admin/
    ├── staff/
    └── shared/
```

### Component Guidelines

- **`lib/app/`**: Holds app-shell concerns, entry points, top-level widget wrapper, route definitions (`router.dart`), and global dependency injection configuration (`dependencies.dart`).
  - [lib/main.dart](lib/main.dart) — Entry point. Only calls `runApp(const BoardGameBookingApp())`.
  - [lib/app/app.dart](lib/app/app.dart) — Root `BoardGameBookingApp` widget. Owns the primary theme and global configurations.
- **`lib/core/`**: Houses app-wide theme tokens (`app_colors.dart`, `app_theme.dart`), constants, and utilities shared across the app.
- **`lib/data/`**: Manages all data layer concerns:
  - **`models/`**: Domain entity models representing the core data structures (e.g., `user.dart`, `booking.dart`, `boardgame.dart`).
  - **`services/`**: Low-level database client, REST API client, local persistence services, and third-party API clients.
  - **`repositories/`**: Aggregates models and services to expose a unified data API to the UI layer.
- **`lib/ui/`**: Houses all screens, presentation widgets, and view models organized by feature subdirectory (e.g. `auth/`, `home/`, `booking/`):
  - **Views (`*_screen.dart`)**: Render UI components. Keep these as declarative and stateless as possible, delegating layout concerns to widgets.
  - **ViewModels (`*_viewmodel.dart`)**: Own screen-specific state, trigger service or repository calls, and emit reactive state updates.
  - **`shared/`**: Reusable generic UI components (e.g., shared buttons, custom AppBars, navigation menus) that are utilized across multiple feature screens.

### Brand palette (defined once in `lib/app/app.dart` or `lib/core/theme/app_colors.dart`)

- Scaffold background: `#F9F9FFFF` (light off-white)
- Primary: `#1275e2` · Secondary: `#5f78a3` · Tertiary: `#C55B00`
- Surface (cards): `#F9F9FFFF`
- Card radius: 12px · ElevatedButton radius: 12px

If you need a new semantic color, extend `ColorScheme` or add an extension on `ThemeData` — do not inline new hex literals in feature code.

## Conventions

- **Imports**: use `package:project/...` for cross-file imports inside `lib/`. Relative imports only within the same feature folder.
- **Widgets**: prefer `StatelessWidget` + `const` constructors; reach for `StatefulWidget` only when local mutable state is genuinely required.
- **Linting**: project uses `package:flutter_lints/flutter.yaml` (see [analysis_options.yaml](analysis_options.yaml)). No custom rule overrides yet — discuss before adding any.
- **Comments**: code should be self-explanatory via naming. Only add a comment when the *why* is non-obvious (workaround, invariant, surprising constraint).
- **No new top-level docs** (`README` additions, design docs) unless explicitly requested.

## Testing

- Tests live in [test/](test/) mirroring `lib/` paths.
- [test/widget_test.dart](test/widget_test.dart) is the navigation smoke test that verifies transitions between the Explore and Map tabs.

## Git workflow

- Default branch: `main`. Feature branches: `feature/<short-kebab-description>`.
- Never push directly to `main` — open a PR.
- Never use `--no-verify`, `--force` on `main`, or `--amend` on already-pushed commits.
- Keep commits scoped; if you find yourself writing "and also" in a commit message, split it.

## When you're unsure

If a request is ambiguous (e.g. "add a login screen" with no spec), ask before scaffolding hundreds of lines. Small, reversible code changes are fine to attempt; architectural choices (state management library, routing package, backend client) should be confirmed with the human first — none of those are picked yet for this project.
