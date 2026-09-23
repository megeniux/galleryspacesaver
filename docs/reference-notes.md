# Reference notes — Rigel Video Suite

The live sibling app lives at `D:\Work\iomovo Tools` (package
`rigel_video_converter`). It is **outside this workspace**, so it must be read
via terminal (`type`, `dir`). These are the patterns worth reusing.

## Replace originals

`lib/core/storage/output_storage.dart` → `OutputStorage.replaceOriginals`.
Proven algorithm:

1. Reject unless `inputPaths.length == outputPaths.length` and non-empty.
2. De-duplicate pairs by normalized input path.
3. **Preflight** — confirm every input *and* output exists before touching
   anything, so a missing output cannot leave the batch half-replaced.
4. Per pair:
   - copy output → `<input>.rigel_replace_<microseconds>_<index>` (staged)
   - delete the original
   - `rename()` staged → original path
   - delete the temp output (failure here is tolerated, not reported)
5. On exception: if the original was removed and the staged copy survives,
   rename it back; otherwise delete the staged file. Record as failed.
6. Returns `ReplaceOriginalsResult(replacedPaths, failedPaths)`.

Gating in `lib/presentation/widgets/tool_result_panel.dart`: the replace button
only appears when every output extension matches its input extension
(`_canReplaceOriginals`).

**What must be added for Gallery Sweeper:** this app edits real MediaStore files
rather than picker copies, so it additionally needs a `MediaStore` rescan after
rename, and a `createWriteRequest` / `createDeleteRequest` consent fallback when
`dart:io` is denied for files owned by other apps.

## Result UI

`ToolResultPanel` is the model for our results screen: Lottie success animation,
a three-column original / output / percentage-smaller comparison
(`_SizeComparison`), then save, share, delete and replace actions.

## Dependency pins that compile together

From the reference `pubspec.yaml` (Dart SDK `^3.11.5`) — these versions are
known-good with its Kotlin/Gradle toolchain, and the comments record why newer
ones were rejected:

- `ffmpeg_kit_flutter_new: ^4.6.2`
- `permission_handler: ^12.0.1` — 13.0.0 pulls an Android impl whose Kotlin DSL
  fails to compile
- `share_plus: 11.1.0` — 12.0.2 fails on this Kotlin toolchain; 13.x conflicts
  with `file_picker` 11 over win32 5/6
- `url_launcher: 6.3.2`
- `package_info_plus: ^9.0.1` — 10.1+ requires win32 6
- `file_picker: ^11.0.3`, `gal: ^2.3.3`, `lottie: ^3.3.1`,
  `flutter_riverpod: ^2.6.1`
- Firebase: `core 4.13.0`, `messaging 16.5.0`, `analytics 12.4.6`,
  `crashlytics 5.2.7`

## Structure worth copying

```
lib/core/platform/      native bridges (foreground service)
lib/core/services/      firebase, media playback
lib/core/storage/       output, recents, preferences
lib/core/theme/         colors, theme, controller
lib/features/<name>/    settings/state per feature
lib/presentation/       screens, widgets, navigation
```
