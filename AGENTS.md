# Working agreement — Rigel Gallery Sweeper

Read [`PLAN.md`](PLAN.md) first. It is the single source of truth for scope,
technical decisions and progress.

## Process

- Work **phase by phase**, in order. Do not start a later phase early.
- When a phase is finished: tick its checkboxes, set its status to
  **✅ Complete**, and add a row to the Progress Log in `PLAN.md`.
- Every phase must end with `flutter analyze` clean and `flutter test` passing.

## Code conventions

- Feature-first folders under `lib/`; shared code in `lib/core/`.
- Riverpod for state. No global singletons holding mutable state.
- Never hardcode colors in widgets — use `Theme.of(context).colorScheme` or the
  `SweeperColors` theme extension. The app uses dynamic color; hardcoded values
  break it.
- Brand seeds live in `lib/core/theme/app_colors.dart`.
- Comments explain *why*, not *what*. Delete commented-out code.
- Catch blocks must be meaningful; explain in a comment why swallowing is safe.

## Safety rules (non-negotiable)

- A user's original file is **only** touched after the compressed output passes
  the verification gate (exists, decodes, is smaller, dimensions/duration match).
- Compression output is always written to app cache first, never in place.
- Same format in, same format out. Replace-original is disabled otherwise.
- Every destructive action requires explicit confirmation.

## Environment

- Flutter 3.41.7 / Dart 3.11.5, `D:\flutter\bin\flutter.bat` on Windows.
- Android minSdk 26, applicationId `com.techrigel.gallerysweeper`.
- Reference project (read-only, outside this workspace):
  `D:\Work\iomovo Tools` — Rigel Video Suite. See `docs/reference-notes.md`.
