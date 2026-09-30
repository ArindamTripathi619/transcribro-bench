# ROADMAP

## Phase 0 — device + tooling — ✅ DONE

- [x] ADB authorized
- [x] Device profiled: moto g34 5G ("fogos"), arm64-v8a, 8 cores, 7.67 GB RAM,
      Android 15, 15+ GB free storage
- [x] Parakeet v2 APKs installed (file + microphone apps)

## Phase 1 — qualitative smoke test — ✅ DONE

Done implicitly via 01b_short (29 s natural take): A−, zero word errors,
obviously better than Gboard. Bar met.

## Phase 2 — benchmark — ✅ DONE (English + Hinglish complete)

Same audio → every engine. Scored with rubric.md → results/scores.csv.

Measured on the G34 (Parakeet v2 INT8) and laptop CPU (Qwen3 0.6B INT8):

| Take | Parakeet v2 | Qwen3 0.6B |
|---|---|---|
| 01_normal (72 s en) | B+ · RTF 0.41 cold | — |
| 01b_short (29 s en) | A− · RTF 0.17 warm | — |
| 05_hinglish (natural) | **D** — confabulation | C+ · RTF 0.32 |
| 05b_hinglish (scripted, GT) | **D** — 60% silent omission | **A−** · RTF 0.85 |

Not run (optional): 02_pauses, 03_fast, 04_technical.
Whisper Small dropped from the plan — Parakeet's English results made the
comparison moot; Qwen3 covers the multilingual axis.

## Phase 3 — decision — ✅ DONE (see notes/2026-09-30-qwen3-laptop-bench.md)

- **English → Parakeet TDT 0.6B v2** (on-device, RTF 0.14 warm, ~1.1 GB RAM)
- **Hinglish → Qwen3-ASR 0.6B INT8** (laptop-validated; on-device blocked by the
  upstream APK packaging bug — notes/bug-report-sherpa-onnx-qwen3-apk.md)
- Moonshine dropped: streaming is not needed for journaling.
- Thresholds all met for the chosen path (RTF ≤ 1.0 usable · RAM ≤ 1.5 GB).

## Phase 4 — Journal v1 (tiny on purpose) — NEXT UP

```
record → stop → transcribe → edit → save (audio + text + metadata)
```

- **No** AI summaries, no embeddings, no RAG, no cloud, no accounts in v1.
- Kotlin + Jetpack Compose + Room
- `AudioRecord` (16 kHz mono PCM) → VAD (Silero) as *segmenter, not terminator*
  → ASR engine behind an interface → Room (transcript + audio path + timestamp
  + model_used + duration)
- `ASREngine` interface so Parakeet/Whisper/Qwen3 are swappable

```
interface ASREngine {
    fun load(model: ModelHandle)
    fun transcribe(pcm16kMono: ShortArray, sampleRate: Int = 16000): String
    fun release()
}
```

Reference code to study before writing UI: **Muesli android** (voice notes →
Parakeet → Room, source-only, build from source) and **Dicta** (Moonshine).

On-device Qwen3 options, in order of preference:
1. Upstream fixes the Qwen3 APK packaging bug → install fixed APK, measure RTF/RAM
2. Custom APK: sherpa-onnx AAR + model files with tokenizer bundled correctly
3. Ship v1 English-only with Parakeet; add Hindi mode when (1) or (2) lands

## Phase 5 — later

- Re-transcription of old entries with a better engine (audio retained)
- Local LLM cleanup pass (titles/mood/topics, filler-word removal) — skipped in v1
  (note: Parakeet keeps "uh"s verbatim; cleanup is a language-model job)
- Qwen3 `hotwords` parameter to fix proper-noun errors (ONNX, Parakeet, names)
- VAD tuning from benchmark evidence: fewer/longer segments, lead-in padding to
  stop first-word loss

## Model shortlist (final, with measured data)

| Model | Size | Status |
|---|---|---|
| Parakeet TDT 0.6B v2 | ~640 MB INT8 | **CHOSEN (English)** — G34: RTF 0.14–0.41, 1.0–1.14 GB RAM |
| Qwen3-ASR 0.6B INT8 | ~880 MB compressed / ~960 MB disk | **CHOSEN (Hinglish)** — laptop RTF 0.32–0.85; on-device pending |
| Whisper Small | ~180–490 MB | dropped — no remaining question it answers |
| Whisper Large-v3-Turbo Q5 | ~547 MB | dropped — stretch experiment, not needed |
| Moonshine Small/Med Streaming | 158/289 MB | dropped — streaming not required for journaling |
