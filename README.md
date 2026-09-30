# transcribro-bench

Local, offline STT evaluation + prototype workspace for a personal voice-journal app.
Target device: **Moto G34 5G** (Snapdragon 695, arm64-v8a, 8 GB RAM, Android 15).

## Goal

Answer one question with evidence from *your own voice*:

> Which local ASR pipeline gives the most accurate, most forgiving transcription
> for 2–10 minute natural journal entries — and can the G34 run it comfortably?

**Answered** — see [Findings](#findings). Short version: a two-engine split,
Parakeet for English, Qwen3-ASR for Hinglish.

## Why this design

- **No streaming requirement.** A journal is *record → stop → transcribe → save*.
  Non-streaming models (Parakeet, Qwen3) are accurate and simpler.
- **Same audio for every model.** Record once on the phone, pull the file, convert
  to 16 kHz mono WAV, feed the identical WAV to each engine. Only then is a
  comparison meaningful.
- **Audio is never thrown away.** Transcript quality can be re-scored later with a
  bigger model; audio is the permanent asset.
- **Qualitative scoring over WER.** rubric.md classifies errors the way a journal
  user feels them: wrong words, missing words, hallucinations, mangled names.

## Layout

```
├── README.md            ← you are here
├── ROADMAP.md           ← phases 0-5, model shortlist, journal v1 architecture
├── rubric.md            ← qualitative transcript scoring (W/M/H/N/✓)
├── PROTOCOL.md          ← benchmark procedure + results template
├── scripts/             ← one-command helpers (run from repo root)
├── notes/               ← dated observation log + decision record + bug report
├── apks/                ← downloaded APKs            (gitignored)
├── recordings/          ← personal audio             (gitignored)
├── transcripts/         ← per-engine transcripts     (gitignored)
├── results/             ← scores.csv + summaries     (gitignored)
└── models/              ← laptop-side Qwen3 bench rig (gitignored)
    ├── sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25/   # official tarball, tokenizer included
    ├── transcribe_qwen3.py                           # sherpa-onnx python transcription
    └── venv/                                         # sherpa-onnx 1.13.8 + numpy
```

## Quick start (from repo root)

```bash
# 0. phone setup
adb devices                                  # accept prompt on phone

# 1. device profile
./scripts/device-info.sh

# 2. install the Parakeet v2 test apps
adb install --bypass-low-target-sdk-block apks/flutter-vad-non-streaming-asr-from-file-nemo-parakeet-v2-en-arm64-v8a.apk
adb install apks/flutter-vad-non-streaming-asr-from-microphone-nemo-parakeet-v2-en-arm64-v8a.apk

# 3. record in the phone's Recorder app (saves to /sdcard/Music/Recorder/records/),
#    then locate + ingest it (pull + convert to 16 kHz mono WAV)
./scripts/find-recordings.sh
./scripts/ingest-recording.sh 01_normal 1    # ARGV: name, index in the list above

# 4. transcribe on the phone (from-file app) or on the laptop (Qwen3):
adb shell monkey -p com.example.vad_non_streaming_asr_from_file -c android.intent.category.LAUNCHER 1
./models/venv/bin/python models/transcribe_qwen3.py recordings/01_normal.wav

# 5. watch RAM while a phone app has its model loaded
./scripts/memwatch.sh com.example.vad_non_streaming_asr_from_file 20

# 6. score with rubric.md
./scripts/score.sh parakeet-v2 01_normal 72.4 30 1025 3 1 1 0 7 "B+" "notes"
```

## Findings

Full data in `results/scores.csv` and `notes/`. Headlines:

| Engine | English | Hinglish | Speed (measured) |
|---|---|---|---|
| **Parakeet TDT 0.6B v2** (G34, INT8 APK) | **A− / B+** | **D** — silent drops + English confabulations | RTF 0.14 warm · 0.41 cold · 1.0–1.14 GB RAM |
| **Qwen3-ASR 0.6B INT8** (laptop, sherpa-onnx) | — | **A− / C+** — mixed Devanagari+Latin output | RTF 0.32–0.85 |

Key learnings:

1. **Parakeet v2 is journal-grade for English** — all numerals and proper nouns
   survived; errors are homophone-class, plus first-word loss and mid-sentence
   splits at VAD boundaries.
2. **Parakeet v2 must not be used for Hinglish** — it doesn't produce gibberish;
   it silently omits ~60% of words and confabulates plausible English
   ("class mein nikal gaya" → "classmate Nicola"). Worst possible failure mode
   for a journal.
3. **Qwen3-ASR 0.6B handles the same takes** — recovered every dropped span,
   outputs Hindi in Devanagari; errors are visible, not fake-plausible.
4. **Warm-start matters**: cold runs are dominated by model load (2.4× slower).
   Journal apps should keep the engine resident.
5. **The official Qwen3 Flutter APK is broken as published** — it ships without
   tokenizer assets, so init always fails. Bug report draft:
   `notes/bug-report-sherpa-onnx-qwen3-apk.md`. On-device Qwen3 therefore ran on
   the laptop rig instead; same model files, same WAVs.

## Engine decision

- **English journaling → Parakeet TDT 0.6B v2** (proven on-device, RTF 0.14 warm)
- **Hinglish journaling → Qwen3-ASR 0.6B INT8** (proven on laptop; on-device
  integration pending the upstream APK fix or a custom build)
- Journal v1 implements an `ASREngine` interface with a per-entry engine choice.

## Status

- [x] Device profiled (moto g34 5G, arm64-v8a, 7.67 GB RAM, Android 15)
- [x] Parakeet v2 APKs installed; benchmarks run (01_normal, 01b_short)
- [x] Hinglish tested on Parakeet → verdict D (natural + scripted, with GT)
- [x] Qwen3-ASR 0.6B validated on laptop against the same WAVs → A− / C+
- [x] Qwen3 APK init failure root-caused (missing tokenizer assets upstream)
- [x] Engine decision recorded (two-engine split, see above)
- [ ] Optional: 02_pauses / 03_fast / 04_technical takes for completeness
- [ ] On-device Qwen3 (blocked on upstream APK fix, or custom build / Muesli-style integration)
- [ ] Journal v1 build (ROADMAP.md phase 4)
