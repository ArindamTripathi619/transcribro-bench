#!/usr/bin/env bash
# RAM snapshot sampler for a running app.
#   ./scripts/memwatch.sh <package> [samples] [interval_s]
# Prints TOTAL PSS per sample; use while the ASR model is loaded/transcribing.
set -euo pipefail
PKG="${1:?usage: memwatch.sh <package> [samples] [interval_s]}"
N="${2:-20}"
IV="${3:-2}"

echo "watching $PKG ($N samples, ${IV}s interval) — Ctrl-C to stop"
for i in $(seq "$N"); do
  TOTAL=$(adb shell dumpsys meminfo "$PKG" 2>/dev/null | grep -E 'TOTAL' | head -1 | awk '{print $2}')
  BAT=$(adb shell dumpsys battery | grep level | tr -dc '0-9')
  echo "$(date +%H:%M:%S)  TOTAL_PSS=${TOTAL:-?} kB  battery=${BAT}%"
  sleep "$IV"
done
