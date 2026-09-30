# Journal v1 — Engineering Plan

The evaluation phase (see README.md) decided the stack: **Parakeet TDT v2 for
English entries, Qwen3-ASR 0.6B for Hinglish (pending on-device fix)**.
This document plans the app that wraps them. Companion doc: `UI-STITCH-PLAN.md`.

## 1. Scope discipline

### v1 IS
- Record → stop → transcribe (on-device) → edit → save (audio + text + metadata)
- Entries list with search; entry detail with playback
- Two-language support: English (Parakeet) + Hinglish (Qwen3, per-entry toggle)
- 100% offline, local-only, single-user

### v1 IS NOT (deliberately deferred)
- No cloud, accounts, sync, telemetry, ads
- No AI summaries / cleanup pass / filler removal (Parakeet keeps "uh"s; that's
  a phase-5 language-model job)
- No on-device Qwen3 yet if the upstream APK stays broken (ship English-only
  v1.0, add Hindi mode when the engine lands)
- No streaming/live partials in v1 — post-hoc transcription only (proven design)

## 2. Module layout (Gradle)

```
app/                    Compose UI, ViewModels, DI wiring
core:model/             Entry, TranscriptSegment, EngineId — pure Kotlin
core:database/          Room: entities, DAOs, migrations
core:audio/             AudioRecord capture, WAV writer, Silero VAD
core:asr/               ASREngine interface + engines
core:design/            Material 3 theme (stock-Android look), shared components
```

Why modules: the ASR engine boundary stays honest, `core:*` are unit-testable
without a device, and a future desktop/tablet build reuses them.

## 3. Data model (Room)

```kotlin
@Entity(tableName = "entries")
data class EntryEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val createdAt: Long,            // epoch millis
    val durationMs: Long,
    val audioPath: String,          // files/entry-audio/<id>.m4a (AAC 48k) or .wav
    val transcript: String,         // full text, edited copy is source of truth
    val rawTranscript: String,      // engine output, never edited — audit trail
    val engineId: String,           // "parakeet-v2" | "qwen3-0.6b"
    val languageMode: String,       // "en" | "hi-en"
    val title: String?,             // optional, user-set; default null (shows date)
    val wordCount: Int,
    val updatedAt: Long,
)

@Entity(tableName = "segments")     // VAD/engine segment timestamps for playback sync
data class SegmentEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val entryId: Long,
    val startMs: Long,
    val endMs: Long,
    val text: String,
    val orderIndex: Int,
)
```

- Search: `SELECT * FROM entries WHERE transcript LIKE '%' || :q || '%' ORDER BY createdAt DESC`
  — FTS4 is a v2 upgrade; LIKE is fine at journal scale (a few thousand rows).
- **Both** `transcript` (edited) and `rawTranscript` (engine truth) are stored —
  this is what makes re-transcription and diffing possible later.
- Audio: AAC in `.m4a` (small) or WAV 16 kHz mono (re-transcription-friendly).
  v1 stores WAV; ~2 MB/min is acceptable for a personal journal and keeps the
  "feed the exact same file to any engine" invariant from the benchmark phase.

## 4. ASR abstraction

```kotlin
interface ASREngine {
    val id: EngineId
    suspend fun ensureLoaded(): Result<Unit>        // idempotent, keeps engine warm
    suspend fun transcribe(wav: File, onProgress: (Float) -> Unit): TranscriptResult
    fun release()
}

data class TranscriptResult(
    val fullText: String,
    val segments: List<TranscriptSegment>,          // start/end/text per VAD chunk
    val rtf: Float,                                 // measured, stored as metadata
)
```

### ParakeetEngine (v1.0 — proven path)
- sherpa-onnx AAR (`sherpa-onnx-1.13.8.aar` from the k2-fsa GitHub release —
  verified present; not on Maven Central, so it lives in `app/libs/` as a local
  dependency: `implementation(files("libs/sherpa-onnx.aar"))`)
- Model files: `sherpa-onnx-nemo-parakeet-tdt-0.6b-v2-int8` (~640 MB) shipped in
  `assets/` v1.0 (APK ≈ 700 MB, matches the sherpa demo APKs the user already
  ran) OR downloaded on first launch to `filesDir/models/` with a progress bar —
  decision: **ship in APK for v1.0** (simplest, one-install offline guarantee),
  asset-extraction pattern already proven by the sherpa example apps
- Init config mirrors the sherpa file app exactly (the config that produced the
  A− results): OfflineRecognizer + transducer decode, 16 kHz mono, greedy search
- Warm-engine strategy: load on app start in background, keep resident
  (~1.1 GB RAM measured, acceptable on 7.67 GB device)

### Qwen3Engine (v1.1 — Hindi mode)
- Same AAR; model = `sherpa-onnx-qwen3-asr-0.6B-int8` **with tokenizer/ included**
  (the exact files the official APK is missing — bug report drafted)
- Unblocked by: upstream fixed APK, or our own build (AAR + assets, following the
  laptop-validated config in `models/transcribe_qwen3.py`)
- Config matches the laptop benchmark: tokenizer dir, greedy, 4 threads
- Delivered as a first-launch download (~950 MB) — Hinglish users opt in

### Engine selection UX
- Record screen has a language chip: **EN** (default) / **HI·EN**
- The chip maps to engineId; entries store what they were made with
- v1.0 ships EN enabled + HI·EN visible-but-disabled with "coming soon" tooltip
  if Qwen3 isn't unblocked in time — honest state, no dead buttons

## 5. Audio pipeline

```
MediaRecorder/MediaCodec? → NO. Use AudioRecord (proven control, 16 kHz mono PCM16):
mic → AudioRecord(16 kHz, mono, PCM16) → ring buffer (100 ms frames)
  → WAV file writer (streaming to filesDir/entry-audio/<tmp>.wav)
  → Silero VAD (sherpa-onnx ships it; 200 ms windows)
      ├─ UI level meter + "speech detected" indicator
      └─ segment boundaries recorded (start/end per speech region)
STOP → finalize WAV → hand to ASREngine → TranscriptResult
     → Room insert (entry + segments) → audio renamed <id>.wav
```

VAD rules from benchmark evidence:
- **Segmenter, not terminator** — silence NEVER stops the recording
- Lead-in: keep 300 ms pre-roll before first speech sample (fixes the
  first-word loss we measured twice)
- Merge pauses < 1.2 s into one segment; hard-split > 15 s segments
- Min speech 300 ms — drops coughs/breaths from transcripts
- Thresholds configurable in-code, not user-facing in v1

## 6. Concurrency & lifecycle

- Recording: foreground Service (mediaProjection-type notification "Recording…"),
  survives screen off; STOP kills it cleanly
- Transcription: `Dispatchers.Default` coroutine, progress via StateFlow; screen
  can be left — WorkManager not needed since transcription is minutes not hours,
  but the service keeps the process alive until the save completes
- Engine load: background at app cold start; if user hits Record before warm,
  Record button shows "warming up…" state then enables (measured load: seconds)
- RAM budget: engine 1.1 GB + app + audio buffers ≤ 2 GB — safe on 7.67 GB

## 7. Testing

- Unit: DAO tests (Robolectric), WAV writer round-trip, segment merge logic,
  ASREngine fake for VM tests
- Instrumented: one end-to-end test — push a fixture WAV through
  ParakeetEngine, assert transcript contains key phrases (from our GT scripts)
- Bench harness reuse: `scripts/ingest-recording.sh` + `score.sh` stay the
  canonical way to regression-test engine quality after dependency bumps

## 8. Milestones

| M | Deliverable | Exit criteria |
|---|---|---|
| M0 | Project scaffold, modules, Room schema, design system | builds; DAO tests green |
| M1 | Audio capture + WAV + VAD segments | 5-min recording persists; segments sane |
| M2 | ParakeetEngine integrated + warm-load | benchmark WAVs transcribe in-app at A− quality |
| M3 | Record flow UI (Stitch screens) + entry list/detail | full loop: record→save→browse→play |
| M4 | Search + playback sync (segment highlight) | search finds phrases; tap transcript seeks audio |
| M5 | Qwen3Engine behind HI·EN chip (when unblocked) | 05b GT scores A− in-app |
| M6 | Polish: empty states, error handling, export (per-entry share) | dogfood daily for a week |

Dogfood rule: **the journal becomes my only journal from M3 onward** — bugs
found by daily use beat any test suite.

## 9. Risks

| Risk | Mitigation |
|---|---|
| 640 MB asset inflates install | Accept for v1 (demo APKs already proved it installs); download-on-demand is the v1.1 fallback |
| First-word loss at recording start | 300 ms pre-roll + VAD padding (evidence: two benchmark runs) |
| Long-entry transcription blocks UI | Service + StateFlow progress; benchmark RTF 0.14 means 10-min entry ≈ 90 s |
| Upstream Qwen3 APK never fixed | Custom build path is fully specified (AAR + tarball files); laptop config is the reference |
| Room schema changes later | Both transcript columns + segments from day one; migrations from M0 |
