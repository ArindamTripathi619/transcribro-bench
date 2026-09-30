# Reference text — 05b_hinglish_script (recorded 2026-09-30)

Ground truth for scoring. Read once, naturally.

> So aaj ka din kaafi interesting tha. Subah uthke maine journaling app ka idea
> thoda refine kiya, aur phir ONNX Runtime ke saath ek benchmark run kiya. Mujhe
> lagta hai Parakeet model honestly kaafi accurate hai, lekin abhi dekhna hai ki
> Hindi words kitne sahi capture hote hain. Kal mujhe Divya se milna tha, lekin
> uska exam tha, isliye hum Monday ko Milos Café mein milenge. Ek cheez confusing
> hai — agar main beech mein Hindi mein switch karun, jaise ki abhi kar raha
> hoon, toh model kya karta hai? Wahi test hai ye. Overall, main hopeful hoon ki
> ye project meri daily journaling ko kaafi easy bana dega. Chalo, let's see how
> this goes.

## Payload checklist (score these specifically)
- Proper nouns: ONNX Runtime · Parakeet · Divya · Milos Café
- Mid-sentence switch: "switch karun, jaise ki abhi kar raha hoon, toh…"
- Full Hindi sentence: "Wahi test hai ye"
- Numerals/temporal: Monday
- Question form: "toh model kya karta hai?"

## Expected failure modes to watch
1. Parakeet v2 (en-only): Hindi words mangled or dropped entirely
2. Hindi transliterated to Latin script vs garbled pseudo-English words
3. Switch-point words (the actual boundary words) absorbed into wrong language
4. Devanagari output would be a Qwen3-only possibility; Parakeet v2 cannot
