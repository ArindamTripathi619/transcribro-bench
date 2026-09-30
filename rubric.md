# Transcript scoring rubric

Per 2-minute recording, mark each error type with a running tally. Do NOT
correct the transcript — judge it exactly as the engine produced it.

## Error categories

| Mark | Type | Meaning | Example |
|---|---|---|---|
| ✓ | correct | word-for-word right | — |
| ~ | punctuation | right words, wrong/missing punctuation or capitalization | "i was experimenting" |
| W | wrong word | real word, wrong choice | "difficult" → "deficit" |
| M | missing | word(s) dropped | "I was working on" → "I working on" |
| H | hallucination | words that were never spoken | repeated phrase, inserted sentence |
| N | name/term | proper noun or technical term mangled | "ONNX" → "onyx", "Gradle" → "graddle" |

## Rules

1. Count **per-word**: a 3-word wrong phrase = 3 marks (category of the worst one).
2. Punctuation issues (~) are tallied but ranked **below** all word errors — a
   journal can be edited; wrong words cannot be trusted.
3. Any H (hallucination) is an automatic red flag regardless of count.
4. Names (N) matter more than common-word errors (W) for journaling.
5. Hinglish recording (E): also note **which language each error came from**.

## Worked example

Spoken: "I was experimenting with ONNX Runtime and trying to compare Parakeet with Whisper"
Output: "I was experimenting with onyx runtime and trying to compare parakeets with whisper"

| Word | Mark |
|---|---|
| ONNX → onyx | N |
| Runtime | ✓ |
| Parakeet → parakeets | N |
| Whisper → whisper | ~ (capitalization) |

→ N:2, ~:1. Verdict: name errors, otherwise clean.

## Verdict scale (per recording, per engine)

| Verdict | Meaning |
|---|---|
| **A** | I'd trust this as-is for a journal |
| **B** | small fixes needed, I'd use it |
| **C** | I'd need to re-listen and fix; not worth it |
| **D** | would corrupt my journal; reject |
