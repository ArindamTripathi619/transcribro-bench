# Parakeet TDT v2 — second benchmark (01b_short), 2026-09-30

## Setup
- Audio: `recordings/01b_short.wav` — 29.3 s (morning take, same phrase style as
  the suggested smoke-test script)
- Engine: Parakeet TDT 0.6B v2 (en), sherpa-onnx file app, model warm in memory
- Processing: **5 s** → **RTF ≈ 0.17** (vs 0.41 cold on 01_normal)
- RAM: ~1.14 GB TOTAL PSS (native heap up while buffers grow — normal)

## Verdict: A− — best run so far

### Word-level: essentially perfect
| Original | Output | Mark |
|---|---|---|
| So today I spent | Today I spent | M (opening "So" dropped) |
| uh most of the morning | uh most of the morning | ✓ (filler KEPT) |
| figure out uh whether | figure out uh whether | ✓ (filler KEPT) |
| or miss things that I said. | or miss things that I said. | ✓ |
| "randomly change words **or miss** things" | "randomly change words. or miss things" | ~ (period mid-sentence at VAD split) |

**Zero wrong words, zero hallucinations, zero name errors.** The only word-level
issue is the dropped opening "So" — a classic first-word-under-VAD-ramp loss,
consistent with chunk-boundary behavior. Not an accuracy problem; an audio
front-end problem.

### Key discoveries
1. **Warm-start RTF 0.17** — once the model is loaded, transcription is ~6×
   real-time. First-run 0.41 was mostly model load. For Journal v1: keep the
   engine process resident → near-instant transcription after Stop.
2. **Filler words are preserved verbatim** ("uh" ×2 kept). Parakeet does NOT
   sanitize disfluencies. Great for a raw journal archive; if the user wants
   clean prose later, that's the cleanup pass's job (ROADMAP phase 5).
3. VAD again split mid-sentence ("...change words. / or miss things...") —
   confirms phase-1 note: tune VAD for longer segments in Journal v1.

### Updated engine comparison so far
| Run | Audio | RTF | Verdict | Word errors |
|---|---|---|---|---|
| 01_normal (cold) | 72.4 s | 0.41 | B+ | 3W/1M/1H |
| 01b_short (warm) | 29.3 s | 0.17 | A− | 0W/1M/0H |

## Next
Remaining differentiators: 02_pauses, 04_technical, 05_hinglish (→ Qwen3 test).
Whisper Small comparison now lower priority: Parakeet warm RTF 0.17 with ~zero
word errors is a strong result on this device.
