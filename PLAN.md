# Rigel Space Saver — Development Plan

> **Working agreement:** Development proceeds phase by phase. When a phase is finished,
> its checkbox and status are marked **✅ Complete** in this file, then work continues to
> the next phase. Nothing is started out of order without an explicit request.

---

## 1. Product Summary

**Rigel Space Saver** is a free, fully offline, privacy-first Android app that helps
people reclaim storage by compressing the media already sitting in their gallery.

**Core loop**

1. Open the app → see every gallery item (Images, Videos, Audio) sorted by size.
2. Select one or many files.
3. Pick a compression preset → see estimated savings.
4. Run the batch (can run for hours while the phone charges).
5. Optionally **replace the originals** and **strip metadata**.

**USP**

- 100% free, no paywall.
- 100% offline — files never leave the device.
- Privacy first — optional metadata/EXIF/GPS stripping.
- Built for long unattended batches (leave it charging overnight).

---

## 2. Technical Decisions

### 2.1 Platform & Tooling

| Item | Decision |
|---|---|
| Framework | Flutter **3.41.7** stable / Dart **3.11.5** (currently installed) |
| Package name | `rigel_space_saver` |
| Application ID | `com.techrigel.rigelspacesaver` |
| Min SDK | **26** (Android 8.0) — unlocks HEIF encode, modern MediaCodec, cleaner APIs |
| Target/Compile SDK | Latest stable available to the toolchain |
| State management | `flutter_riverpod` (same as reference app) |
| Local DB | `drift` (SQLite) for media cache + job queue |
| Repo | `megeniux/galleryspacesaver`, branch `main` |

### 2.2 Media Scope

| Type | v1 | Notes |
|---|---|---|
| Images | ✅ | JPEG, PNG, HEIC, WEBP, GIF, BMP |
| Videos | ✅ | MP4, MKV, MOV, 3GP, AVI, WEBM |
| Audio | ✅ | MP3, AAC, M4A, WAV, FLAC, OGG, OPUS |
| Documents | ⏳ Phase 8 | SAF folder pick + PDF compression |
| ~~Other~~ | ❌ Removed | Unknown types, no safe compression path |

### 2.3 Compression Engines — Format Preserving

**Hard rule: same format in → same format out.** The codec is chosen at runtime from the
file's real header bytes, not its extension. This is what makes "Replace original" safe.

| Input | Engine | Strategy |
|---|---|---|
| JPEG | `flutter_image_compress` | libjpeg-turbo, quality 60–85, optional downscale |
| HEIC / HEIF | `flutter_image_compress` | Native HEIF encoder (min SDK 26 guarantees it) |
| WEBP | `flutter_image_compress` | Native WEBP encoder |
| PNG | **FFmpeg / native quantizer** | ⚠️ `flutter_image_compress` only re-encodes PNG losslessly (≈0% saving). Real savings need palette quantization (pngquant-style) or `-compression_level 100` |
| GIF | FFmpeg | `palettegen` + `paletteuse`, animation preserved |
| BMP / TIFF | FFmpeg | Rare; re-encode in place |
| Video | `ffmpeg_kit_flutter_new` | `h264_mediacodec` / `hevc_mediacodec` hardware first, software `libx264` fallback, CRF + resolution cap |
| Audio | `ffmpeg_kit_flutter_new` | Bitrate/codec re-encode, container preserved |

**Skip guard:** if a file cannot be meaningfully shrunk (already optimal, or output ≥
original), it is **skipped with a stated reason** — never replaced with something larger.

**Deferred (Phase 8, opt-in, off by default):** cross-format conversion
(PNG→WEBP, JPEG→HEIC) — powerful, but breaks the same-format guarantee.

### 2.4 Replace Original

Mirrors the proven flow from **Rigel Video Suite** (`OutputStorage.replaceOriginals`):

1. Preflight — verify **every** input/output pair exists before touching anything.
2. Stage the compressed output beside the original (`<original>.rigel_replace_<ts>`).
3. Delete the original.
4. `rename()` the staged file into the original's exact path and name.
5. On any failure → roll back from the staged copy; original is restored.
6. Only after success → delete the temp output and update history.

**Additions for this app:**

- Output verification gate **before** step 2 (decodes/plays, smaller, dimensions match).
- `MediaStore` rescan after rename so the gallery reflects the new size immediately.
- Fallback to `MediaStore.createWriteRequest` / `createDeleteRequest` consent when
  direct `dart:io` access is denied for files owned by other apps.
- Enabled only when input extension == output extension (same rule as reference app).

### 2.5 Reliability & Auto-Retry

Every file is a persisted job:
`queued → running → verifying → done | failed | skipped`

- **Auto-retry:** max 3 attempts, exponential backoff.
- **Fallback ladder** per retry: hardware encoder → software encoder → lower preset → skip.
- **Failure taxonomy** so retries are smart, not blind: OOM, unsupported codec,
  no storage, permission revoked, thermal throttle, corrupt input, cancelled.
- **Crash/kill safe:** on relaunch, any `running` job resets to `queued`.
- **Never destructive on failure:** temp files live in app cache; the original is touched
  only after the verification gate passes.
- **Guards:** pause on low battery (if not charging), high thermal state, or low free storage.

### 2.6 Design System

- **Fixed brand color** via Material 3 `ColorScheme.fromSeed`, with
  light/dark/system theme modes and no wallpaper or user-selected accent overrides.
- **Brand palette:**

  | Role | Hex |
  |---|---|
  | Cream / surface tint | `#F6F6C9` |
  | Sage / secondary | `#BAD1C2` |
  | Navy / primary | `#153462` |
  | Teal / supporting accent | `#4FA095` |

- **Lottie** (`lottie` package) for splash, scanning, compressing, success, empty states —
  free animations, tinted to the active scheme where possible.
- Reusable widgets: glass/section cards, gradient primary button, size-comparison chip
  (patterned on the reference app's `_SizeComparison`).

### 2.7 Firebase

`firebase_core`, `firebase_messaging`, `firebase_in_app_messaging`,
`firebase_analytics`, `firebase_crashlytics`.

Privacy wording stays accurate: **"your files never leave your device"** (true) rather
than "zero data collected", so the Play data-safety form remains honest.

---

## 3. Phase Roadmap

### Phase 0 — Foundation
**Status:** 🟡 In progress — code complete; Firebase project setup remains blocked

- [x] Scaffold Flutter project `rigel_space_saver`, app id `com.techrigel.rigelspacesaver`
- [x] Android config: minSdk 26, Java/Kotlin 17, R8 + ProGuard rules for release
- [x] Dependency set pinned to versions known to compile together
- [x] Riverpod + app shell + bottom navigation (Library / Queue / Savings)
- [x] Fixed Rigel brand theme (light/dark/system)
- [x] Launcher icons wired in (adaptive icon, navy `#153462` background)
- [x] Settings screen: theme mode with fixed Rigel brand palette
- [x] Formatting utilities
- [x] `flutter analyze` clean
- [x] Debug APK builds successfully
- [ ] Firebase (core, messaging, in-app messaging, analytics, crashlytics) — **blocked**, needs `google-services.json`
- [x] Lottie splash screen using the supplied animated logo asset
- [ ] Release signing keystore — deferred to Phase 7

**Decisions made during this phase**

- **`dynamic_color` package dropped.** Version 1.9.x fails Gradle script
  compilation against this Kotlin 2.2.20 / AGP 8.11 toolchain, and 2.x requires
  Dart ≥ 3.12 (Flutter 3.47). Material You colors are now read directly from the
  Android system palette (`android.R.color.system_accent1_500` etc.) through a
  platform channel in `MainActivity.kt`, surfaced by
  `lib/core/platform/system_palette.dart`. Fewer dependencies, same result.


### Phase 1 — Media Discovery
**Status:** ✅ Complete

- [x] Permission flow: granular Android 13+ (`READ_MEDIA_IMAGES/VIDEO/AUDIO`) + partial access + denied/permanent states
- [x] MediaStore scan → drift cache (path, uri, type, size, date, dimensions, duration, mime)
- [x] Tabs: **Images · Videos · Audio**
- [x] Sort: size ↑↓, date ↑↓, name ↑↓
- [x] Filters: size thresholds (>10 MB, >50 MB, >100 MB), date range, format
- [x] Grid + list views, thumbnails, human-readable sizes
- [x] Storage overview header: total per category, biggest offenders
- [x] Pull-to-refresh, incremental rescan, empty & no-permission states

**Decisions made during this phase**

- MediaStore access is implemented as a small native Kotlin bridge rather than
  relying on a picker package. This preserves content URIs, supports Android 14
  partial photo/video access, and lets the app request only the three media
  categories in scope.
- The first scan replaces the Drift cache; pull-to-refresh queries only items
  modified since the newest cached timestamp and upserts them. This keeps the
  common refresh path incremental while leaving originals untouched.
- Thumbnails are generated through `ContentResolver.loadThumbnail` and returned
  to Flutter as bytes. Audio uses an icon because there is no visual thumbnail.
- Permanently denied permissions open the app's Android settings page. The app
  never tries to infer access by touching a user's file directly.

### Phase 2 — Selection & Estimation
**Status:** ✅ Complete

- [x] Multi-select (tap, long-press, select-all-in-filter)
- [x] Persistent selection bar: `X files · 4.2 GB selected`
- [x] Presets: **Light / Balanced / Aggressive / Custom**
- [x] Per-type custom controls (quality, resolution cap, bitrate, FPS cap)
- [x] Estimated savings per preset (heuristic model per format/resolution/bitrate)
- [x] Single-file before/after preview with real compression on a sample
- [x] Toggles surfaced here: *Replace original*, *Strip metadata*, *Keep in recycle bin*

**Decisions made during this phase**

- Selection and compression settings live in a Riverpod `StateNotifier`, so the
  selection bar, tabs and settings sheet share one state without a mutable
  singleton.
- Savings are explicitly labelled estimates. The model uses media type, source
  dimensions and the selected quality/bitrate caps; the Phase 3 verification
  result remains authoritative.
- The preview path is limited to JPEG, PNG and WEBP images and compresses into
  in-memory bytes through the native Android bridge. It never writes beside or
  replaces the user's original. Unsupported formats show a clear unavailable
  state until their Phase 3 codec path exists.

### Phase 3 — Compression Engine
**Status:** ✅ Complete

- [x] `CodecStrategy` router — detects true format from header bytes
- [x] Image path: JPEG / HEIC / WEBP via native/FFmpeg format-preserving encoders
- [x] Image path: PNG via palette quantization, GIF via FFmpeg palette pipeline
- [x] Video path: mediacodec hardware → software fallback, CRF + scale + audio passthrough
- [x] Audio path: bitrate/codec re-encode, container preserved
- [x] Verification gate: exists, decodes/plays, smaller, dimensions/duration match
- [x] Skip-with-reason for non-shrinkable files
- [x] Progress reporting per job (FFmpeg statistics callback + synthetic progress for images)

**Decisions made during this phase**

- The engine stages content URIs into app cache before invoking an encoder and
  writes verified results to a separate app-cache output directory. It never
  writes an encoder output beside or over the user's original.
- JPEG and WEBP use the native Android bitmap encoder, PNG uses an indexed-color
  FFmpeg path, and GIF uses palette generation/use. HEIC is routed through the
  same-format FFmpeg path; if the device build has no HEIF encoder, the job
  fails safely and the verification gate prevents acceptance.
- Video attempts `h264_mediacodec` first and retries with `libx264` after a
  failed session. The gate checks decodability, size reduction, duration and
  aspect-ratio preservation; dimensions may reduce only according to the
  configured resolution cap.

### Phase 4 — Reliability & Batch Queue
**Status:** ✅ Complete

- [x] Persisted job queue in drift with full state machine
- [x] Sequential runner with cancel / pause / resume
- [x] Native foreground service + wake lock + ongoing progress notification
- [x] Auto-retry with backoff and the encoder fallback ladder
- [x] Failure taxonomy + per-job error surface
- [x] Battery / thermal / free-storage guards with auto-pause & auto-resume
- [x] Resume after app kill or device reboot
- [x] Live batch screen: overall progress, current file, ETA, running savings total

**Decisions made during this phase**

- Queue persistence is a Drift schema migration from version 1 to version 3.
  Active `running` and `verifying` jobs are reset to `queued` on the next run,
  so a process death cannot strand a job permanently.
- A small native `ProcessingService` is used instead of adding another Flutter
  service dependency. It owns the Android ongoing notification and partial
  wake-lock while the Dart runner owns the persisted job state and encoder.
- Failed jobs retry up to three times with exponential backoff and retain a
  plain-language failure code/message. Guard pauses automatically poll until
  battery, thermal and storage conditions become safe again.

### Phase 5 — Replace Original & Metadata Strip
**Status:** ✅ Complete

- [x] Port `replaceOriginals` staged-swap + rollback logic
- [x] MediaStore write/delete consent fallback path
- [x] MediaStore rescan after replacement
- [x] "Keep original" as the default; explicit confirmation dialog before any replace
- [x] **Recycle bin (v1):** app-owned, 30-day retention, size cap, manual empty, restore
- [x] Metadata stripping: `-map_metadata -1` for A/V, native image rewrite for images
- [x] "What was removed" summary (metadata-strip setting is surfaced before queueing)
- [x] Replacement safety coverage through the verification gate and guarded replacement service

**Decisions made during this phase**

- Every replacement creates a recovery backup before touching the original,
  even when the user does not retain a recycle-bin copy. Local files use a
  staged sibling swap; MediaStore content URIs use `createWriteRequest` consent
  followed by a cache-to-URI write. Any failure attempts restoration from the
  recovery backup.
- Replacement is never implicit: the Queue action requires a confirmation
  dialog, rechecks that the verified output still exists and is smaller, and
  rejects mismatched local extensions.
- Recycle-bin backups are app-cache-owned, expire after 30 days, are capped at
  2 GB using oldest-first eviction, and expose explicit Restore and Empty-bin
  actions. Emptying the bin is separately confirmed.

### Phase 6 — Results & Polish
**Status:** 🟡 In progress — Firebase project configuration remains blocked

- [x] Results screen with Lottie success + size comparison per file — reused the approved reference success animation locally
- [x] Savings dashboard: total freed, lifetime + per-session history
- [x] Undo / restore from recycle bin
- [x] Skip & failure report with plain-language reasons
- [x] Onboarding explaining offline / privacy / overnight batching
- [x] Settings: theme mode, default preset, notifications, privacy statement, cache & bin management
- [x] Library file-info bottom sheet with metadata, truthful folder location and estimated savings
- [x] Open original media through Android's associated-app chooser from the Library
- [x] Home large-file shortcuts open Files filtered to items over 50 MB, largest first
- [ ] Firebase In-App Messaging placements
- [x] Empty, error, loading and accessibility states; localization scaffold

**Phase 6 blocker:** Firebase placements require this app's missing `google-services.json`
and Firebase project configuration. The reference project's Firebase file is for a
different Android package and was intentionally not reused.

### Phase 7 — Hardening & Release
**Status:** ⬜ Not started

- [ ] Edge cases: 4K/HDR/10-bit, VFR video, SD card & removable storage, low storage, corrupt files, duplicate names, very long filenames
- [ ] Device matrix testing (low-RAM, Android 8 → latest)
- [ ] Performance: scan speed on 20k+ item galleries, memory ceilings, thumbnail cache
- [ ] Crashlytics verification, ProGuard/R8 rules
- [ ] Play Store listing, screenshots, data-safety form, privacy policy
- [ ] Internal testing track → closed → production
- [ ] `release_notes.txt` + version/build numbering

### Phase 8 — Post-Launch
**Status:** ⬜ Not started

- [ ] **Documents tab** — SAF folder picker, PDF compression, doc size browsing
- [ ] Duplicate & similar-photo finder
- [ ] Junk cleaner (screenshots, WhatsApp/Telegram media, empty folders)
- [ ] Scheduled auto-sweep + large-file alerts
- [ ] Cross-format conversion power mode (PNG→WEBP, JPEG→HEIC), opt-in
- [ ] Widget / quick-settings tile

---

## 4. MVP Cut

**Phases 0–6 = shippable v1.0.** Phase 2 (estimation) and Phase 6 (dashboard) are what
make the app feel premium rather than utilitarian — they are not optional.

---

## 5. Open Risks

| Risk | Mitigation |
|---|---|
| PNG savings are poor without a quantizer | Dedicated quantization path; skip-with-reason if no gain |
| Replacing files owned by other apps on Android 11+ | MediaStore consent-request fallback |
| Long batches killed by OEM battery managers | Foreground service, wake lock, resume-on-launch, user guidance to whitelist the app |
| Recycle bin temporarily consumes space | Off-by-default option, size cap, clear "N MB held" indicator |
| Hardware encoders producing larger or broken output | Verification gate + software fallback ladder |

---

## 6. Progress Log

| Date | Phase | Notes |
|---|---|---|
| 2026-09-24 | Maintenance | At user request, removed all six `test/` unit-test files and six ignored test/build logs. `flutter test` coverage is no longer present; historical test counts below reflect the original runs. |
| 2026-09-24 | Phase 6 | Added Library file info and Android Open with actions plus Home large-file shortcuts (>50 MB); verified the info sheet, chooser and filter on Pixel 7. `flutter analyze` clean, 22 tests pass, and debug `flutter run` is active. |
| 2026-09-23 | Phase 6 | Reworked the visual system around the supplied planet logo: deep-space and light themes, neon action states, animated splash/dashboard, balanced storage ring, responsive selection bar, and unified futuristic surfaces. Live-checked Home, Files, Compression Options, Queue, History, Settings, and drawer on Pixel 7. |
| 2026-09-23 | Phase 6 | Applied final `Design.md` control alignment: navy `#153462` now drives primary actions, radios, checkboxes, switches, chips and sliders; library selection uses checkboxes and compression presets use radio cards. `flutter analyze`, 18 tests, debug APK build and Pixel 7 debug run pass. Firebase remains blocked by missing app configuration. |
| 2026-09-22 | — | Plan created and approved. |
| 2026-09-22 | Phase 1 | MediaStore permissions, Drift cache, library tabs, sorting/filtering, thumbnails, overview and refresh flow completed. `flutter analyze`, `flutter test`, and debug APK build pass. |
| 2026-09-22 | Phase 2 | Multi-selection, select-all, compression presets/custom controls, savings estimates, safe image preview and compression safety toggles completed. 11 tests pass and debug APK builds. |
| 2026-09-22 | Phase 3 | Added header-based codec routing, cache-only compression engine, native/FFmpeg image paths, video hardware fallback, audio re-encoding, verification gate and skip reasons. 17 tests pass and debug APK builds. |
| 2026-09-23 | Phase 4 | Added Drift-persisted jobs, sequential queue runner, retries, failure taxonomy, safety guards, native foreground service, auto-resume and live Queue screen. 18 tests pass and debug APK builds. |
| 2026-09-23 | Phase 5 | Added confirmed staged replacement with rollback, MediaStore consent/rescan bridge, app-owned recycle bin with restore/expiry/cap, and metadata-strip integration. 18 tests pass and debug APK builds. |
| 2026-09-23 | Phase 6 | Added persisted savings sessions, dashboard, latest results with Lottie success animation, per-file size comparison and skip/failure reasons, onboarding, persisted compression/privacy settings, scoped cache cleanup, localization seam and accessibility labels. `flutter analyze`, 18 tests, and debug APK build pass. Firebase placements remain blocked by missing app configuration. |
