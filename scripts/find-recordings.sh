#!/usr/bin/env bash
# List recent audio recordings on the phone so you can find the file you just made.
set -u
echo "== newest media files on /sdcard (Record, Download, Movies, DCIM) =="
adb shell 'find /sdcard/Record /sdcard/Records /sdcard/Download /sdcard/Movies /sdcard/DCIM -type f \( -iname "*.m4a" -o -iname "*.mp3" -o -iname "*.wav" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.mp4" \) -printf "%T@ %s %p\n" 2>/dev/null' \
  | sort -rn | head -15 \
  | awk '{ printf "%2d  %6.1f MB  %s\n", NR, $2/1048576, substr($0, index($0,$3)) }'
echo
echo "ingest with: ./scripts/ingest-recording.sh <name> <index>"
