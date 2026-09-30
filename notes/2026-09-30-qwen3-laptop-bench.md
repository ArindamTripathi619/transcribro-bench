# Qwen3-ASR 0.6B — laptop benchmark (same WAVs that broke Parakeet), 2026-09-30

## Why laptop
The official sherpa-onnx **Flutter APK for Qwen3 is broken as published** (no
tokenizer assets — see `bug-report-sherpa-onnx-qwen3-apk.md`). So the same two
Hinglish WAVs were transcribed on the laptop with sherpa-onnx Python 1.13.8,
Qwen3-ASR 0.6B INT8, CPU, 4 threads. This measures the MODEL; a G34 APK run is
blocked upstream (or possible later via custom-built APK / Muesli integration).

## Results

### 05b_hinglish_script (50.7 s, ground truth known) — A−
Full reference recovered with ~95% accuracy, **including everything Parakeet
silently dropped**: the entire Divya / Milos Café / mid-sentence-switch section.

Output (verbatim):
> So, आज का दिन काफी interesting था। सुबह उठ के मैंने journaling app का idea
> थोड़ा refine किया, और फिर O N N X runtime के साथ एक benchmark run किया। मुझे
> लगता है पारखित model honestly काफी accurate है, लेकिन अभी देखना है कि Hindi
> words कितने सही capture होता है। कल मुझे दिव्या से मिलना था, लेकिन उसका exam
> था। इसलिए हम model को Milos Cafe में मिलेंगे। एक चीज confusing है, अगर मैं बीच
> में Hindi में switch करूँ, या जैसे कि अभी कर रहा हूँ, तो model क्या करता है?
> वही test है ये. Overall, मैं hopeful हूँ कि ये project मेरी daily journaling
> को काफी easy बना देगा। चलो, let's see how this goes.

Payload checklist:
| Item | Result |
|---|---|
| Mid-sentence switch sentence | ✓ fully recovered |
| "Wahi test hai ye" | ✓ ("वही test है ये") |
| Divya → दिव्या | ✓ (Devanagari) |
| Milos Café | ✓ ("Milos Cafe"; Monday→"model" error inside this span) |
| ONNX | N — spelled "O N N X" |
| Parakeet | N — became "पारखित" |
| Hindi glue words | ✓ all present (aaj, kaafi, thoda, lekin, isliye…) |

Output style: **Devanagari for Hindi + Latin for English**, punctuation in both.

### 05_hinglish natural (72.9 s, graded by ear) — C+
- **Filled Parakeet's 17 s untranscribed hole with real content** ("completely
  not working… did not know what to do next")
- English portions near-perfect ("stuck in the boot menu", "googled the
  symptoms", "fix this like true Linux person" — the tail Parakeet mangled)
- Hindi verbs still garbled ("charge nahi laga" → "a dumb patty, patty thing",
  "nikal gaya" → "nikel") but **no English confabulation** — errors are visible
  as errors, not fake-plausible text
- RTF 0.32 (faster than scripted run — less Hindi decoding)

## Performance (laptop CPU, 4 threads)
| Clip | Audio | Proc | RTF |
|---|---|---|---|
| codeswitch.wav (official test) | 6.2 s | 1.7 s | 0.27 |
| 05b_hinglish_script | 50.7 s | 43.3 s | **0.85** |
| 05_hinglish | 72.9 s | 23.4 s | 0.32 |

## Engine decision (phase 3, evidence-complete)
| Engine | English | Hinglish | Verdict |
|---|---|---|---|
| Parakeet TDT v2 | A−/B+ (RTF 0.14–0.41) | D (silent drops + confabulation) | **English engine** |
| Qwen3-ASR 0.6B INT8 | (untested here) | A−/C+ (Devanagari-mixed) | **Hinglish engine** |

Journal v1: `ASREngine` interface, per-entry engine choice ("Hindi mode" toggle).
Qwen3 on-device viability on the G34 is still open (needs working APK or custom
build); laptop RTF 0.85 vs Parakeet 0.14 suggests it will be usable but slower.
