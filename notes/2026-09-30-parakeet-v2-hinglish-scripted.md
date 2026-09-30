# Parakeet TDT v2 — 05b_hinglish_scripted, 2026-09-30

## Setup
- Audio: `recordings/05b_hinglish_script.wav` — 50.7 s, scripted read of the
  reference in `notes/reference-05b_hinglish.md` (ground truth)
- Processing: 6.99 s → **RTF 0.138** (warm, fastest yet)

## Verdict: D — silent massive omission (worse than gibberish)

## Reference vs output

| Reference (ground truth) | Parakeet output |
|---|---|
| So aaj ka din kaafi interesting tha. Subah uthke maine journaling app ka idea thoda refine kiya, aur phir ONNX Runtime ke saath ek benchmark run kiya. | "So, then interesting journaling appeared to refine ONX." |
| Mujhe lagta hai Parakeet model honestly kaafi accurate hai, lekin abhi dekhna hai ki Hindi words kitne sahi capture hote hain. | "Runtime benchmark model honestly accurate." |
| **Kal mujhe Divya se milna tha, lekin uska exam tha, isliye hum Monday ko Milos Café mein milenge.** | *(nothing — entire 18 s untranscribed: 21.6 → 39.7)* |
| Ek cheez confusing hai — agar main beech mein Hindi mein switch karun, jaise ki abhi kar raha hoon, toh model kya karta hai? Wahi test hai ye. | *(nothing — inside the same hole)* |
| Overall, main hopeful hoon ki ye project meri daily journaling ko kaafi easy bana dega. Chalo, let's see how this goes. | "Overall, my hopeful project daily journaling is easy. So let's see how this goes." |

## Score: W:2 · M:65 · H:0 · N:1 · ~:1 → D

## Why this is more dangerous than the natural take
With gibberish you at least SEE the failure. Here Parakeet emitted short,
plausible English sentences and **silently discarded ~60% of the words**,
including the entire Divya/Milos Café/mid-sentence-switch section. For a
journal, that's data loss that looks like a finished entry.

## Payload checklist results
- ONNX Runtime → "ONX" (N), Runtime survived
- Parakeet → dropped
- Divya, Milos Café → dropped (whole span)
- Monday → dropped (whole span)
- Mid-sentence switch sentence → dropped (whole span)
- Full Hindi sentence "Wahi test hai ye" → dropped (whole span)

## Decision impact (Phase 3)
Hinglish journaling is **out of scope for Parakeet v2** — confirmed twice
(natural: confabulation; scripted: silent omission). Two viable paths:
1. **Qwen3-ASR 0.6B INT8** (Hindi + 52 langs) as a second engine — APK
   (950 MB, same package id as Parakeet file app, swapped in place) is now
   installed and ready to test with the SAME two Hinglish WAVs.
2. Keep journaling English-only in v1; revisit multilingual later.

## APK logistics note
Parakeet-file and Qwen3-file share package id `com.example.vad_non_streaming_asr_from_file`
(different signatures) → mutually exclusive. Swap via
`adb uninstall` + `adb install apks/<apk>`. Parakeet APK retained in `apks/`.
