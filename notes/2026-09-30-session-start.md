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

## Progress (later same morning)
- Device authorized: `ZA222KBRDB → device`. Profile: moto g34 5G, "fogos", Android 15 (SDK 35),
  arm64-v8a, 8 cores, MemTotal 7.67 GB, MemAvailable ~2.9 GB, 17 GB free storage, battery 99%.
- Both APKs downloaded (sizes match server content-length exactly) and installed → `Success`.
- Package names (v1.13.5, targetSdk 36):
  - `com.example.vad_non_streaming_asr_from_file`
  - `com.example.vad_non_streaming_asr_from_microphone`

## Recovery check (laptop died, later same day)
- Laptop rebooted; verified NOTHING was lost: all 6 git commits, all 4 recordings,
  all 4 parakeet-v2 transcripts, scores.csv (B+/A−/D/D), all 3 APKs in apks/,
  all 4 WAVs still in /sdcard/Download on phone.
- Phone still has Qwen3 as the file app (lastUpdateTime 10:39 = Qwen3 install) + Parakeet mic app.
- Next: run Qwen3 on 05_hinglish.wav + 05b_hinglish_script.wav (both already in
  /sdcard/Download), time both runs, save txts to Documents.

## Next actions (user)
1. Accept USB debugging prompt on phone → `adb devices` shows `device`
2. `./scripts/device-info.sh` → confirm model/abi/RAM
3. `adb install apks/<file-apk>.apk` (use `--bypass-low-target-sdk-block` if it refuses)
4. Record 2 min natural journaling → `./scripts/find-recordings.sh` → `./scripts/ingest-recording.sh 01_normal <index>`
5. Transcribe in app, copy text verbatim into `transcripts/parakeet-v2/01_normal.txt`
6. Score with rubric.md → `./scripts/score.sh ...`
