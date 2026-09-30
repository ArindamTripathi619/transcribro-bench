#!/usr/bin/env bash
# Pull a recording from the phone and convert it to the benchmark format.
#   ./scripts/ingest-recording.sh <name> <index>
#     <name>   short name, e.g. 01_normal  (becomes recordings/<name>.wav)
#     <index>  index in the list printed by find-recordings.sh (1 = newest)
set -euo pipefail
cd "$(dirname "$0")/.."

NAME="${1:?usage: ingest-recording.sh <name> <index>}"
IDX="${2:?usage: ingest-recording.sh <name> <index>}"

mapfile -t FILES < <(
  adb shell 'find /sdcard/Record /sdcard/Records /sdcard/Music/Recorder/records /sdcard/Download /sdcard/Movies /sdcard/DCIM -type f \( -iname "*.m4a" -o -iname "*.mp3" -o -iname "*.wav" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.mp4" \) -printf "%T@ %s %p\n" 2>/dev/null' \
    | sort -rn | head -15 \
    | awk '{ $1=""; $2=""; sub(/^ +/, ""); print }'
)

[ "${FILES[$((IDX-1))]:-}" ] || { echo "no file at index $IDX (run find-recordings.sh)"; exit 1; }
REMOTE="${FILES[$((IDX-1))]}"

mkdir -p recordings
RAW="recordings/${NAME}_raw"
echo ">> pulling: $REMOTE"
adb pull "$REMOTE" "$RAW" >/dev/null

echo ">> converting to 16 kHz mono PCM s16le WAV"
ffmpeg -y -loglevel error -i "$RAW" -ar 16000 -ac 1 -c:a pcm_s16le "recordings/${NAME}.wav"
rm -f "$RAW"

ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 "recordings/${NAME}.wav"
echo ">> done: recordings/${NAME}.wav"
