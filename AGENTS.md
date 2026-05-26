# AGENTS.md

Instructions for AI coding agents (Claude Code, Cursor, Copilot, Codex, etc.) working in this repository. Human contributors should read this too.

## Project

BoardNest — a Flutter mobile app for booking board-game spaces. Course project for FPTU PRM393. The Dart package name is `project` (see [pubspec.yaml](pubspec.yaml)), so imports use `package:project/...`.

The codebase is in an early scaffolding stage: `MaterialApp` is themed but has no `home`/routes wired yet, so `flutter run` currently shows a blank screen. Feature code structure has not been established — when you add the first feature, pick a convention deliberately (e.g. `lib/features/<name>/`) rather than dumping files into `lib/` root.

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

- [lib/main.dart](lib/main.dart) — entry point. Only calls `runApp(const BoardGameBookingApp())`.
- [lib/app/app.dart](lib/app/app.dart) — root `BoardGameBookingApp` widget. Owns the entire `ThemeData` (color scheme, AppBar, Card, ElevatedButton styling). New screens and widgets must pull from `Theme.of(context).colorScheme` rather than re-hardcoding hex values.
- [lib/app/](lib/app/) — intended home for app-shell concerns (theme, routing, top-level widget). Keep cross-cutting infrastructure here.

### Brand palette (defined once in `lib/app/app.dart`)

- Scaffold background: `#F7EFE5` (warm cream)
- Primary: `#1275e2` · Secondary: `#5f78a3` · Tertiary: `#C55B00`
- Surface (cards): `#FFF9F3`
- Card radius: 22px · ElevatedButton radius: 18px

If you need a new semantic color, extend `ColorScheme` or add an extension on `ThemeData` — do not inline new hex literals in feature code.

## Conventions

- **Imports**: use `package:project/...` for cross-file imports inside `lib/`. Relative imports only within the same feature folder.
- **Widgets**: prefer `StatelessWidget` + `const` constructors; reach for `StatefulWidget` only when local mutable state is genuinely required.
- **Linting**: project uses `package:flutter_lints/flutter.yaml` (see [analysis_options.yaml](analysis_options.yaml)). No custom rule overrides yet — discuss before adding any.
- **Comments**: code should be self-explanatory via naming. Only add a comment when the *why* is non-obvious (workaround, invariant, surprising constraint).
- **No new top-level docs** (`README` additions, design docs) unless explicitly requested.

## Testing

- Tests live in [test/](test/) mirroring `lib/` paths.
- [test/widget_test.dart](test/widget_test.dart) is the **unmodified Flutter template test** — it asserts a counter and `Icons.add` that do not exist in `BoardGameBookingApp`. It will fail today. Replace it with a real test of the first screen you add; do not try to satisfy the counter assertions.

## Git workflow

- Default branch: `main`. Feature branches: `feature/<short-kebab-description>`.
- Never push directly to `main` — open a PR.
- Never use `--no-verify`, `--force` on `main`, or `--amend` on already-pushed commits.
- Keep commits scoped; if you find yourself writing "and also" in a commit message, split it.

## When you're unsure

If a request is ambiguous (e.g. "add a login screen" with no spec), ask before scaffolding hundreds of lines. Small, reversible code changes are fine to attempt; architectural choices (state management library, routing package, backend client) should be confirmed with the human first — none of those are picked yet for this project.
