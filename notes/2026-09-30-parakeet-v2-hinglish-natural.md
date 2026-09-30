# Parakeet TDT v2 — 05_hinglish natural take, 2026-09-30

## Setup
- Audio: `recordings/05_hinglish.wav` — 72.9 s, unscripted natural Hinglish
- No ground truth; graded by ear (user's own memory of what was said)
- Processing ~15 s (warm) → RTF ≈ 0.21

## Verdict: D — NOT journal-grade for Hinglish

## What the transcript shows
English portions transcribed well:
- "I was very tense at that time" ✓
- "I just googled the symptoms and then... I started to fix this" ✓
- "it just got stuck in the boot menu" ✓ (only "uh" garbled around it)

Hindi→English switch points collapsed:
- "class mein nikal gaya" → "**classmate Nicola**" (confabulated proper noun!)
- "Egg the manta" — pure gibberish (Hindi phrase)
- "Kiawatau" — pure gibberish ("kiya wapas"?)
- "Here my laptop could charge me laga" — partial garble around the Hindi verb
- Segments 00:26→00:43 — **17 s of audio with no transcript at all**
- Ending "True Linux / Person" — mangled tail, likely "troubleshoot Linux portion"

## Pattern classification
1. Hindi confabulated into plausible-sounding ENGLISH words ("Nicola") — worst
   case: looks right, is wrong. Silent corruption of a journal.
2. Code-switch boundary = highest error density, consistent with theory.
3. Long untranscribed hole → VAD + ASR disagree on what is speech.
4. English fluency within mixed audio was fine — the model doesn't "break",
   it silently fabricates around non-English content.

## Design consequence (recorded for ROADMAP phase 3 decision)
Parakeet v2 remains the **English** engine. Hinglish journaling requires a
multilingual engine — Qwen3-ASR 0.6B INT8 (Hindi + 52 langs) is the candidate.
Journal v1 should detect degraded output (e.g. untranscribed spans) or expose a
per-entry engine choice. A "Hindi mode" toggle is the simplest v1 solution.
