# Bug report draft — Qwen3-ASR Flutter APKs ship without tokenizer assets

## Summary
`flutter-vad-non-streaming-asr-from-file-qwen3-asr-multi-arm64-v8a.apk`
(and presumably the from-microphone variant) fails at init with:

```
Init error: Exception: Init failed: Exception: Failed to create offline
recognizer. Please check your config
```

Root cause from `adb logcat`:

```
W sherpa-onnx: offline-qwen3-asr-model-config.cc:Validate:90
W sherpa-onnx: '/data/user/0/com.example.vad_non_streaming_asr_from_file/files/
  sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25/tokenizer/tokenizer.json/vocab.json'
  does not exist. Please check --qwen3-asr-tokenizer
W sherpa-onnx: c-api.cc:SherpaOnnxCreateOfflineRecognizer:698
W sherpa-onnx: Errors in config
```

## Evidence
1. APK asset listing shows NO tokenizer files were packaged:

```
$ unzip -l flutter-vad-non-streaming-asr-from-file-qwen3-asr-multi-arm64-v8a.apk | grep assets/flutter_assets/assets/
assets/flutter_assets/assets/silero_vad.onnx
assets/flutter_assets/assets/sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25/conv_frontend.onnx
assets/flutter_assets/assets/sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25/decoder.int8.onnx
assets/flutter_assets/assets/sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25/encoder.int8.onnx
```

`grep -ic 'vocab|merges|tokenizer'` over the full APK listing → **0**.

2. The model tarball
(`sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25.tar.bz2`, 878,702,423 bytes)
contains the required files, and the Python API works perfectly with them:

```
tokenizer/merges.txt (1.6M), tokenizer/tokenizer_config.json (12K),
tokenizer/vocab.json (2.6M)
```

3. Cleared app data (`pm clear`) and re-extracted — same failure. Reproduced
   on Moto G34 5G (arm64-v8a, Android 15, 8 GB RAM).

## Odd path in the log
The validator looked for `.../tokenizer/tokenizer.json/vocab.json` — a file
named `tokenizer.json` treated as a directory, containing `vocab.json`. That
nested path doesn't exist anywhere; correct layout is `tokenizer/vocab.json`.
Possibly the app config passes a wrong tokenizer root; either way the missing
bundled assets are the first-order bug.

## Suggested fix
Add the `tokenizer/` files (vocab.json, merges.txt, tokenizer_config.json) to
`flutter_assets/assets/sherpa-onnx-qwen3-asr-0.6B-int8-2026-03-25/` in the APK
build for both qwen3-asr-multi variants, and point
`--qwen3-asr-tokenizer` at the extracted `tokenizer` directory.

## Environment
- sherpa-onnx Flutter example APKs from release tag `flutter` (versionName 1.13.5)
- Device: moto g34 5G, Android 15, arm64-v8a
- Python API with same model files (sherpa-onnx 1.13.8) works fine on x86_64
