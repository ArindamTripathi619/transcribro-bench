#!/usr/bin/env bash
# Full device profile in one shot. Run from anywhere (adb must be connected).
set -u
prop() { adb shell getprop "$1" | tr -d '\r'; }
hr() { printf '\n== %s ==\n' "$1"; }

hr "adb status"
adb devices

hr "model / board"
echo "model:      $(prop ro.product.model)"
echo "device:     $(prop ro.product.device)"
echo "board:      $(prop ro.product.board)"
echo "android:    $(prop ro.build.version.release) (SDK $(prop ro.build.version.sdk))"
echo "abi:        $(prop ro.product.cpu.abi)"
echo "cores:      $(adb shell nproc | tr -d '\r')"

hr "RAM"
adb shell cat /proc/meminfo | grep -E 'MemTotal|MemAvailable' | tr -d '\r'

hr "storage (/data + /sdcard)"
adb shell df -h /data /sdcard 2>/dev/null | tr -d '\r'

hr "battery"
adb shell dumpsys battery | grep -E 'level|status' | tr -d '\r'

hr "thermal hint"
adb shell dumpsys thermalservice 2>/dev/null | grep -i -m2 'status' | tr -d '\r' || true
