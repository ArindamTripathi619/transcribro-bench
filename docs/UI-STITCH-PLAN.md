# Journal v1 — UI Plan for Google Stitch

Companion to `journal-v1-plan.md` (engineering). This document is the complete
UI plan: a reusable design system, six screen prompts ready to paste into
Stitch, targeted edit prompts for iteration, and the workflow for keeping six
screens visually consistent.

Design north star: **stock Android** — the app should feel like it was written
by Google for a Pixel. Material 3 components, no custom chrome, no skeuomorphism,
no "app-like" theming. If a component exists in Material 3, we use it verbatim.

## 0. How to use this with Stitch

1. Generate screen 1 with the full prompt from §2.1 (includes the DESIGN SYSTEM
   block — Stitch carries it across screens in the same project).
2. Check the result against the acceptance criteria in §4.
3. Iterate with the **targeted edit** prompts in §3 (one change per prompt —
   Stitch follows single-change edits much better than bundled ones).
4. If colors drift between screens, re-paste the DESIGN SYSTEM block from §1
   into the edit prompt.
5. Export code (Flutter) as reference for the Compose implementation — copy the
   layout/spacing logic, not the widgets.

Screen generation order = §2 order. Each screen's prompt is self-contained.

## 1. Design system (paste into every first-generation prompt)

Named "Pixel Stock" — a device-default Material 3 look. Semantic Material roles
(`primary`/`surface`/`onSurface`) so Compose theming maps 1:1.

- Platform: Mobile, Android-first
- Theme: Light, **follow system dark mode** (request both variants)
- Style: stock Android / Pixel default look, Material 3, calm and quiet —
  **zero decorative styling**, no illustrations, no gradients, no rounded-card
  collage, no playful shapes. Plain surfaces, hairline dividers.
- Background: Neutral surface white (#FEF7FF — M3 default light surface)
- Primary Accent: M3 purple (#6750A4) for primary buttons, FAB, active states
- Text Primary: near-black (#1D1B20) for headlines and body
- Text Secondary: gray (#49454F) for timestamps, subtitles, metadata
- Dividers: outline variant (#CAC4D0) hairlines only — no card shadows
- Typography: Roboto (system default) — headlines medium-weight, body regular,
  timestamps 12–13 sp secondary color
- Components: standard Material 3 — FAB for record, top app bar (back arrow,
  title, overflow menu), plain ListItems with hairline dividers, chips for
  filters, bottom sheet for edits. Small shapes (12 dp corners max). **No cards
  with shadows, no bottom navigation.**
- Motion: standard Android (Material motion, nothing custom)
- Density: comfortable-default list density, 16 dp screen padding

## 2. The six screens (generation prompts)

### 2.1 Home — "Today" screen (entry list)

A calm, minimal stock-Android journal home screen: a personal voice journal
that feels like the Google Recorder app's list view, light theme, Material 3.

**DESIGN SYSTEM (REQUIRED):** *(paste §1 here)*

**Page Structure:**
1. **Top app bar:** small title "Journal" left-aligned (center-aligned is
   non-stock), overflow menu icon (3 dots) right
2. **Date group header:** "Today" — small gray label, 16 dp top padding
3. **Entry list:** plain ListItems, each with:
   - time ("9:55 AM") in secondary gray, 13 sp, single line
   - title-or-first-line preview in primary text, 2 lines max, ellipsis
   - duration ("2:14") in secondary gray, right-aligned
   - hairline divider between items (no cards, no shadows)
4. **Floating action button:** standard Material FAB, bottom-right, mic icon,
   label "Record" — the single primary action of the app
5. **Empty state** (separate variant prompt): centered mic icon in a soft
   circle, text "No entries yet", sub-text "Tap Record to start your first
   journal entry", no button inside the empty state

Behavior notes (for review, not rendering): tapping an entry opens detail;
search lives in the overflow menu route (screen 2.2).

### 2.2 Search screen

A minimal stock-Android search screen for a voice journal: full-screen search
over transcript text, Material 3, light theme.

**DESIGN SYSTEM (REQUIRED):** *(paste §1 here)*

**Page Structure:**
1. **Search app bar:** back arrow, pill-shaped search input (Material 3
   SearchBar style, gray track #ECE6F0, hint "Search entries"), no overflow
2. **Query state:** below bar, "12 results for 'onnx'" — small gray text
3. **Results list:** same ListItem anatomy as Home, but:
   - the matched substring is **bold**, not colored
   - one extra metadata line: "Today · 9:55 AM · 2:14"
4. **Empty query state:** recent searches as plain ListItems with history icon
5. **No results state:** centered gray text "No entries match 'xyz'"

### 2.3 Record screen

A focused, distraction-free stock-Android recording screen for a voice
journal: one job — record and stop. Feels like the Google Recorder's capture
mode, light theme, Material 3.

**DESIGN SYSTEM (REQUIRED):** *(paste §1 here)*

**Page Structure:**
1. **Minimal top bar:** back/close (X) icon left — no title
2. **Language chip row** (top center, below bar): two filter chips — "EN"
   (selected state) and "HI·EN" (unselected; show disabled/grayed with tooltip
   "coming soon") — subtle, not a form control
3. **Elapsed time:** large centered timer text "00:00" (56 sp, light weight)
   that reads as the hero element of the screen
4. **Live waveform:** a thin, calm live audio waveform across the middle third
   of the screen, single-color primary purple, minimal — Recorder-style, not a
   party visualizer
5. **Speech indicator:** tiny dot + label "listening" in secondary gray under
   the waveform (lit when VAD detects speech)
6. **Stop button:** large centered circular button (72 dp) at bottom third —
   primary purple filled, white square stop icon inside. It is the only button
   on the screen. No pause button in v1.
7. **Status line:** bottom, small gray text that cycles: "Recording…" →
   "Transcribing…" (with a thin linear progress bar under it) → done

### 2.4 Transcribing / review screen

A transcript review screen for a voice journal: the fresh transcript with
segments, minimal chrome, Material 3 light — feels like reading a clean notes
document.

**DESIGN SYSTEM (REQUIRED):** *(paste §1 here)*

**Page Structure:**
1. **Top app bar:** back arrow, overflow menu (share, delete, re-transcribe)
2. **Entry header block:** date ("Wednesday, 30 September") as headline small,
   full timestamp + duration + engine chip ("Parakeet EN") in one secondary
   metadata line — this is the only metadata shown
3. **Transcript body:** readable document layout — 16 sp body text, 1.6 line
   height, comfortable measure; segments separated by subtle paragraph spacing
   (NOT chat bubbles, NOT card list)
4. **Segment timestamps:** inline, tiny gray "[00:13]" before each segment,
   styled like quiet footnote markers — tappable later (M4) to seek audio
5. **Edit affordance:** floating "Edit" text button bottom-right (or pencil
   FAB, small variant) — enters edit mode
6. **Edit mode state** (variant): body becomes a plain borderless multiline
   text field, top bar gains "Save" and "Cancel" text buttons, segment
   markers hidden

### 2.5 Entry detail (existing entry + playback)

An audio playback screen for a journal entry: transcript synced to audio,
stock Android media affordances, Material 3 light.

**DESIGN SYSTEM (REQUIRED):** *(paste §1 here)*

**Page Structure:**
1. **Top app bar:** back arrow, overflow menu
2. **Entry header:** same as 2.4 plus a playback row:
3. **Playback bar:** horizontal row — play/pause filled icon button,
   thin Material 3 slider with elapsed/total time labels ("0:42 / 2:14"),
   playback-speed text button ("1×", cycles 1×/1.5×/2×)
4. **Transcript:** identical body style to 2.4; the segment nearest playhead
   gets **primary-color text** (or bold) — quiet karaoke effect, no background
   highlight bars
5. **Bottom:** nothing else — playback + text is the screen

### 2.6 Settings

A minimal settings screen for an offline voice journal, stock Android style,
Material 3 light — should feel like a page from Android system settings.

**DESIGN SYSTEM (REQUIRED):** *(paste §1 here)*

**Page Structure:**
1. **Top app bar:** back arrow, title "Settings"
2. **Group: Engine** — ListItems with static values:
   - "English engine — Parakeet TDT v2"
   - "Hinglish engine — Qwen3 0.6B" (with "Not installed" label until M5)
   - "Model storage — 640 MB used" 
3. **Group: Recording** — "Audio format — WAV (16 kHz mono)" (static info),
   "Pre-roll padding — 300 ms" (static info; not user-editable in v1)
4. **Group: Data** — "Export entry audio" (opens share sheet), "Delete all
   data" (red text, destructive confirm dialog)
5. **Group: About** — "Version 1.0", "All processing happens on this device"
   as a quiet reassurance line

## 3. Targeted edit prompts (iteration patterns)

Use one change per prompt. Template: *"Add/Change [what] to [where]. [style
spec]. Context: this is a targeted edit, preserve everything else."*

- "Change the FAB to an extended FAB with mic icon and 'Record' label."
- "Make the entry preview text exactly two lines with ellipsis; timestamps
  should use 13 sp secondary gray."
- "Replace the waveform with a flat single-line amplitude bar, primary color,
  thin (2 dp), minimal — not a visualizer."
- "The timer should be 56 sp, light weight, tabular figures so digits don't
  shift width."
- "Add hairline dividers between list items; remove any card shadows — this
  must look like plain Android settings list, not a card dashboard."
- "Show the disabled chip as 40% opacity with a lock icon and 'coming soon'
  tooltip."
- "Make transcript body 16 sp with 1.6 line height; segment timestamps as tiny
  gray inline markers like footnotes."

## 4. Acceptance criteria (per screen)

The stock-Android bar — reject any Stitch output that fails these:

- Looks native next to Google Recorder / Settings / Keep — not "an app"
- **No cards with shadows** on lists; hairline dividers only
- Roboto, M3 purple #6750A4, correct grays (#1D1B20 / #49454F)
- Exactly one primary action per screen (FAB / Stop / Save)
- Timestamps/metadata in secondary gray; no decorative color anywhere
- Empty states are quiet text + icon, never marketing illustrations
- Dark variant exists and follows M3 dark roles (#1C1B1F surface, #D0BCFF primary)

## 5. Screen → engineering mapping

| Stitch screen | Implements | Plan ref |
|---|---|---|
| 2.1 Home | Entry list + search route + FAB → Record | M3 |
| 2.2 Search | transcript LIKE search | M4 |
| 2.3 Record | AudioRecord + VAD + language chip → engineId | M1/M2 |
| 2.4 Review | TranscriptResult → entry + segments save; edit mode | M3 |
| 2.5 Detail | Playback + segment sync (tap timestamp → seek) | M4 |
| 2.6 Settings | Engine status, storage, export, delete-all | M6 |

Design tokens in §1 map directly to the Compose `MaterialTheme` in
`core/design` — one source of truth, so Stitch's Flutter output is copied for
layout/spacing only.
