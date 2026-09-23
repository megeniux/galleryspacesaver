# Rigel Space Saver — Futuristic UI System

`Design.png` was the first visual reference. This specification supersedes its
generic white Material treatment and defines the product direction that is now
being implemented: a calm, futuristic storage control room built around the
supplied planet logo at `assets/logo/android/playstore-icon.png`.

## Product feeling

Rigel should feel like a personal spacecraft console: focused, spacious, and
quietly technical. It is not a neon game UI. Glow is reserved for status and
action affordances; content remains readable and centered.

## Tokens

### Dark mode (brand-first default)

- Space background: `#071321`
- Elevated surface: `#0D2038`
- Panel surface: `#112D4B`
- Primary brand: `#153462`
- Brand gradient highlight: `#0B6FD3`
- Secondary signal: `#E7B549`
- Electric blue: `#4C8DFF`
- Violet: `#9D7BFF`
- Text: `#EAF5FF`
- Muted text: `#A9C0D8`

### Light mode

- Background: `#F2F7FC`
- Surface: `#FFFFFF`
- Panel: `#E8F1FA`
- Primary: `#123B6D`
- Accent: `#4C8DFF`
- Text: `#10243D`
- Muted text: `#5A7088`

The two modes use the same geometry and semantic colors. No dynamic color,
wallpaper-derived accent, analytics opt-out control, or user-selected accent
color is part of the product UI.

## Geometry and motion

- Screen padding: 16dp; compact controls may use 12dp.
- Main cards: 22dp radius, thin outline, low shadow; no arbitrary elevation.
- Buttons and chips: 16dp and 12dp radii respectively.
- Use one strong heading per screen, small uppercase system labels for metadata,
  and normal-case user actions.
- Logo surfaces receive a restrained accent glow.
- Splash: logo scale/fade entrance.
- Storage ring and dashboard sectors: eased reveal on load.
- Lists: stable item identity and animated state changes; no flicker when
  selection, filtering, or thumbnails update.
- Progress: always show percentage, current file, completed/pending counts,
  savings, ETA where available, and Pause/Continue/Cancel actions.

## Navigation

The persistent shell has five destinations:

1. Home
2. Files
3. Compress
4. History
5. Settings

Home uses the drawer menu. Secondary screens use a back arrow. The bottom bar
is visible on shell destinations and is not shown on pushed Settings, Results,
File Details, or Compression Options screens.

## Screen rules

### Splash and onboarding

Use the planet logo, deep-space surface, orbit-like spacing, and short status
copy. Onboarding uses three compact benefit cards, a progress indicator, one
primary entry action, and a quiet skip action.

### Home

The first content block is a centered storage signal: animated ring, total
capacity in the clear center, and Used/Available values beside it. Below it,
show four equal media-sector cards for Photos, Videos, Audio, and Documents.
The main CTA is the only full-width action and says `Start a compression sweep`.

### Files

Show a back arrow, search, media filter chips, filter/sort controls, and stable
rounded file rows. A selected file uses the primary signal color. The persistent
selection bar must remain above the bottom navigation and show count, total
size, estimated savings, clear, and Next.

### Compression Options

Use four radio cards: High Compression, Balanced (Recommended), High Quality,
and Custom. Radio controls, switches, sliders, and the estimated-savings CTA
share the primary action color. Destructive replacement remains opt-in and
confirmed.

### Compress / Processing

Use a high-contrast progress panel with a large percentage ring, current file,
queue counts, Space Saved, Time Remaining, and explicit Start, Pause, Continue,
and Cancel states. Completed jobs expose results and safe replacement actions.

### Results and File Details

Keep the success state focused: animated success mark, headline, saved amount,
before/after size comparison, processed/skipped/failed counts, and file-level
details. File Details uses a large preview, metadata rows, and a clear saved
state.

### History

Lead with lifetime savings and use compact session rows with date, files,
savings, and success/failure state. Tapping a session opens its results.

### Settings

Use the same dark/light surfaces, compact grouped rows, readable labels, and
clear controls for Theme, Default Compression, notifications, privacy, recycle
bin, and cache management. Both Light and Dark modes must maintain contrast.

## Behavior that must not change

The existing scan, selection, compression, queue, pause/resume/cancel,
verification gate, cache staging, recycle bin, metadata stripping, history,
and explicit replacement confirmation remain intact. Original files are never
touched before a verified smaller output exists.
