# ROADMAP

## Phase 0 — device + tooling (tonight)

- [ ] ADB authorized (`adb devices` → `device`)
- [ ] `./scripts/device-info.sh` → confirm arm64-v8a, model, MemTotal
- [ ] Both Parakeet v2 APKs installed
- [ ] Mic permission granted to both apps on first launch

## Phase 1 — qualitative smoke test (~10 min)

1. Open the **from-file** app, load a short WAV (any speech), confirm transcription works.
2. Open the **from-microphone** app, speak naturally for ~60 s (do NOT dictate
   punctuation aloud; Gboard habits don't apply here).
3. Ask only: *would I trust this for a personal journal?*

Success bar: transcription feels obviously better than Gboard, no fight over
pauses. If not → re-evaluate engine choice before benchmarking.

## Phase 2 — 5-recording benchmark (see PROTOCOL.md)

Same audio → every engine. Score with rubric.md. Fill results/scores.csv.

| Engine | Stage 1 test | Stage 2 test | Stage 3 test |
|---|---|---|---|
| Parakeet v2 (en) | sherpa APKs | — | — |
| Whisper Small | sherpa-onnx model via Termux, or whisper.cpp Android | — | — |
| Qwen3-ASR 0.6B INT8 | — | sherpa-onnx APK | ~1.9 GB package, Hindi + 52 langs |
| Moonshine (streaming) | Dicta APK | — | feel-test only |

## Phase 3 — decision

Write `notes/<date>-decision.md`: chosen engine, scores, RTF, RAM, gut feel.
Thresholds: RTF ≤ 1.0 usable · ≤ 0.5 comfortable · RAM ≤ ~1.5 GB on 8 GB device.

## Phase 4 — Journal v1 (tiny on purpose)

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

## Phase 5 — later

- Re-transcription of old entries with a better engine (audio retained)
- Local LLM cleanup pass (titles/mood/topics) — deliberately skipped in v1
- Multilingual: Qwen3-ASR 0.6B INT8 if Hindi/code-switching matters day-to-day

## Model shortlist (evidence so far)

| Model | Size | Notes |
|---|---|---|
| Parakeet TDT 0.6B v2 | ~640 MB INT8 | en-only; Galaxy S10 RTF ≈ 0.09; runs on 2 GB phones |
| Whisper Small | ~180–490 MB | multilingual; S10 RTF ≈ 0.41 |
| Qwen3-ASR 0.6B INT8 | ~1.9 GB | 52 langs incl. Hindi; S10 RTF ≈ 0.53 (ONNX INT8 only!) |
| Whisper Large-v3-Turbo Q5 | ~547 MB | stretch experiment |
| Moonshine Small/Med Streaming | 158/289 MB | streaming feel, lower accuracy ceiling |

Numbers are comparative evidence, not G34 predictions. Measure on the G34.
