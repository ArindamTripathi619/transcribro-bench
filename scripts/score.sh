#!/usr/bin/env bash
# Append one benchmark row to results/scores.csv.
#   ./scripts/score.sh <engine> <recording> <audio_s> <proc_s> <ram_mb> <W> <M> <H> <N> <tilde> <verdict> [notes]
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results
CSV=results/scores.csv
[ -f "$CSV" ] || echo "engine,recording,audio_s,proc_s,rtf,ram_mb,W,M,H,N,tilde,verdict,notes" > "$CSV"

ENG="$1"; REC="$2"; AUD="$3"; PROC="$4"; RAM="${5:-}"; W="${6:-}"; M="${7:-}"; H="${8:-}"; N="${9:-}"; T="${10:-}"; V="${11:-}"; NOTES="${12:-}"

RTF=$(python3 -c "print(f'{$PROC/$AUD:.3f}' if $AUD else '')" 2>/dev/null || echo "")

echo "$ENG,$REC,$AUD,$PROC,$RTF,$RAM,$W,$M,$H,$N,$T,$V,$NOTES" >> "$CSV"
tail -1 "$CSV"
