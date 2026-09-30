# Parakeet TDT v2 — first benchmark, 2026-09-30

## Setup
- Audio: `recordings/01_normal.wav` — 72.4 s, 16 kHz mono (Motorola Recorder m4a → ffmpeg)
- Engine: Parakeet TDT 0.6B v2 (en), sherpa-onnx file app v1.13.5
- Processing time: ~30 s (user stopwatch) → **RTF ≈ 0.41**
- RAM while loaded: **~1.02 GB** TOTAL PSS

## Verdict: B+ — would use for journaling
All five numbers survived (0.4%, 1%, 2016, 2026, 10). Every proper noun survived
(Marxism, India, Delhi, Mumbai, Bengaluru, ONNX-class terms were not in this take
but Manifesto/Communism came out lowercase-only). Punctuation and capitalization
are impressively natural (em-dash-level sentence flow, commas, %).

### Error tally (details in results/summary-01_normal.md)
| W | M | H | N | ~ |
|---|---|---|---|---|
| 3 | 1 | 1 | 0 | 7 |

### The only real problems
1. **One hallucination**: "has faced **off** historic decline" — "off" was invented
   at a VAD pause boundary (13.6→20.1 s segment split mid-sentence). The original
   was "has faced a historic decline" (a→off substitution + dropped article).
2. **One invented word**: "divorce **fillings**" (should be "filings") — real-word
   substitution, homophone-class error.
3. **One mangle**: "joint family **interface**" (should be "interference") — again a
   real-word homophone-adjacent error.
4. ~7 punctuation/capitalization marks — cosmetic only.

### Observations
- VAD split a 72 s take into 6 chunks; timestamps look sane (13.6 s, 12 s chunks).
- Chunk boundaries are where both word-level errors cluster → for Journal v1,
  prefer **fewer, longer VAD chunks** (raise min-silence / padding) for accuracy;
  chunking only matters for UI feedback.
- Output includes timestamps → free segmentation data for the journal UI later.
- RTF 0.41 on SD695 means a 10-min journal entry ≈ 4 min processing — fine for
  post-hoc transcription; good enough even for near-live use.

### Implications for model choice
This is already journal-grade for English. Whisper Small comparison is still
worth one run (multilingual baseline + hallucination behavior), but Parakeet v2
is the frontrunner. Next differentiators: 02_pauses (endpointing), 04_technical
(names), 05_hinglish (Parakeet v2 is en-only → expect failure → that's Qwen3's test).
