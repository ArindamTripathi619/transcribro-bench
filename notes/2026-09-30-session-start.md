# 2026-09-30 — session start

## Context
- Device: Moto G34 5G (Snapdragon 695, arm64-v8a, 8 GB variant assumed — confirm with device-info.sh)
- Laptop: Arch, adb 35.0.2, ffmpeg + python3 present
- Goal: pick the best **local, offline** ASR for personal voice journaling, then build Journal v1

## Environment findings
- Device `ZA222KBRDB` was attached but **unauthorized** → user must accept the USB debugging prompt on the phone.
- sherpa-onnx latest release (v1.13.8) no longer bundles APKs; APKs live under the special `flutter` tag release.
- Confirmed URLs (from sherpa-onnx's own example.md, master branch):
  - file APK   (~580 MB): https://github.com/k2-fsa/sherpa-onnx/releases/download/flutter/flutter-vad-non-streaming-asr-from-file-nemo-parakeet-v2-en-arm64-v8a.apk
  - mic APK    (~522 MB): https://github.com/k2-fsa/sherpa-onnx/releases/download/flutter/flutter-vad-non-streaming-asr-from-microphone-nemo-parakeet-v2-en-arm64-v8a.apk
- Decided to download both: `from-file` = reproducible benchmark runs; `from-mic` = Gboard-feel comparison.
- Stage 2 (Whisper Small) model identified: csukuangfj/sherpa-onnx-whisper-small on HuggingFace (Termux route planned).
- Design decision locked: **same WAV for every engine** (record once, convert once, transcribe everywhere). Audio is retained permanently for later re-transcription.

## Downloads
- Started in background into apks/ (file first, then mic). Verify with:
  `ls -la apks/` → both final names present, no `.part` files, sizes ≈ 580 MB / 522 MB.

## Next actions (user)
1. Accept USB debugging prompt on phone → `adb devices` shows `device`
2. `./scripts/device-info.sh` → confirm model/abi/RAM
3. `adb install apks/<file-apk>.apk` (use `--bypass-low-target-sdk-block` if it refuses)
4. Record 2 min natural journaling → `./scripts/find-recordings.sh` → `./scripts/ingest-recording.sh 01_normal <index>`
5. Transcribe in app, copy text verbatim into `transcripts/parakeet-v2/01_normal.txt`
6. Score with rubric.md → `./scripts/score.sh ...`
