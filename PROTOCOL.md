# Benchmark protocol — 5 recordings × N engines

## The one rule

Record **once** on the phone. Convert **once**. Feed the **same** 16 kHz mono
WAV to every engine. Never re-speak a take for another engine.

## The 5 recordings (each ~2 min, natural voice, normal room)

| # | Name | What to do | What it tests |
|---|---|---|---|
| 01 | `01_normal` | talk exactly as you'd talk to yourself at the end of the day | baseline journaling |
| 02 | `02_pauses` | think out loud: "I think the thing that annoyed me was… hmm… actually no, maybe…" — let pauses happen | endpointing robustness |
| 03 | `03_fast` | your excited/fast pace | speed robustness |
| 04 | `04_technical` | programming vocabulary: ONNX, Gradle, Kotlin, PostgreSQL, Snapdragon, convolution, API | name/term errors (N) |
| 05 | `05_hinglish` | natural code-switching, e.g. "Aaj basically pura din class mein nikal gaya, and then…" | Hindi + switching |

Do not slow down, over-articulate, or dictate punctuation.

## Procedure per engine

```bash
# 1. record on the phone (built-in Recorder), then:
./scripts/find-recordings.sh
./scripts/ingest-recording.sh 01 07       # name + index in the file list

# 2. transcribe the converted WAV with the current engine app
#    (from-file APK: load recordings/01_normal.wav; Termux/whisper.cpp: see Whisper notes)

# 3. copy the transcript text exactly as produced →
#    transcripts/<engine>/01_normal.txt     (no corrections!)

# 4. score with rubric.md → append to results/scores.csv
```

## Per-run metrics to capture

| Metric | How |
|---|---|
| audio duration | `ffprobe recordings/01_normal.wav` |
| processing time | stopwatch while engine transcribes (or app-reported) |
| RTF | processing_time / audio_duration |
| RAM | `./scripts/memwatch.sh <package> 20` while model loaded |
| battery delta | note % before/after session |
| verdict | rubric.md A–D per recording |

## Results template — results/scores.csv

```csv
engine,recording,audio_s,proc_s,rtf,ram_mb,W,M,H,N,tilde,verdict,notes
parakeet-v2,01_normal,,,,,,,,,,,
parakeet-v2,02_pauses,,,,,,,,,,,
```

## After all engines

Write `notes/<date>-decision.md`: winner, scores table, RTF/RAM numbers,
gut feel, and the one thing you'd most want different in Journal v1.
