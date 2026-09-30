# transcribro-bench

Local, offline STT evaluation + prototype workspace for a personal voice-journal app.
Target device: **Moto G34 5G** (Snapdragon 695, arm64-v8a, 8 GB RAM).

## Goal

Answer one question with evidence from *your own voice*:

> Which local ASR pipeline gives the most accurate, most forgiving transcription
> for 2–10 minute natural journal entries — and can the G34 run it comfortably?

## Why this design

- **No streaming requirement.** A journal is *record → stop → transcribe → save*.
  Non-streaming models (Parakeet, Whisper) are accurate and simpler.
- **Same audio for every model.** Record once on the phone, pull the file, convert
  to 16 kHz mono WAV, feed the identical WAV to each engine. Only then is a
  comparison meaningful.
- **Audio is never thrown away.** Transcript quality can be re-scored later with a
  bigger model; audio is the permanent asset.

## Layout

```
transcribro-bench/
├── README.md            ← you are here
├── ROADMAP.md           ← phases 0-5, model shortlist, journal v1 architecture
├── rubric.md            ← qualitative transcript scoring (W/M/H/N/✓)
├── PROTOCOL.md          ← 5-recording benchmark procedure + results template
├── scripts/             ← one-command helpers (run from repo root)
├── apks/                ← downloaded APKs (gitignored)
├── recordings/          ← raw + converted personal audio (gitignored)
├── transcripts/         ← per-engine transcripts (gitignored)
├── results/             ← scores.csv + summary.md (gitignored)
└── notes/               ← dated observation log
```

## Quick start (from repo root)

```bash
# 0. phone setup (laptop side is already done)
adb devices                                  # accept prompt on phone

# 1. device profile
./scripts/device-info.sh

# 2. install the two Parakeet v2 test apps
adb install --bypass-low-target-sdk-block apks/flutter-vad-non-streaming-asr-from-file-nemo-parakeet-v2-en-arm64-v8a.apk
adb install apks/flutter-vad-non-streaming-asr-from-microphone-nemo-parakeet-v2-en-arm64-v8a.apk

# 3. record ~2 min in the phone's recorder, then locate + ingest it
./scripts/find-recordings.sh
./scripts/ingest-recording.sh 01 07            # ARGV: name, recorder index (see script)

# 4. run the 5-recording benchmark per PROTOCOL.md, score with rubric.md

# 5. after each session
./scripts/memwatch.sh com.example.vad_non_streaming_asr_from_file 20
./scripts/memwatch.sh com.example.vad_non_streaming_asr_from_microphone 20

# launch either app from laptop
adb shell monkey -p com.example.vad_non_streaming_asr_from_file -c android.intent.category.LAUNCHER 1
```

## Engines on the shortlist

| # | Engine | First test | Why |
|---|--------|-----------|-----|
| 1 | **Parakeet TDT 0.6B v2 (en)** | sherpa-onnx APKs | best speed/accuracy balance, proven on ARM phones |
| 2 | **Whisper Small** | sherpa-onnx model (Termux) or whisper.cpp Android | robust, multilingual baseline |
| 3 | **Qwen3-ASR 0.6B INT8** | sherpa-onnx (later) | Hindi + 52 languages; ~1.9 GB package |
| 4 | Moonshine Small Streaming | Dicta APK | streaming dictation feel-test, low bar |

## Status

- [x] Workspace scaffolded
- [x] Parakeet v2 APKs downloading (file + microphone variants)
- [ ] ADB authorization accepted on phone
- [ ] APKs installed
- [ ] First qualitative test (PROTOCOL.md, Recording A)
- [ ] 5-recording benchmark complete
- [ ] Engine decision logged in notes/
- [ ] Journal v1 build starts (see ROADMAP.md phase 4)
