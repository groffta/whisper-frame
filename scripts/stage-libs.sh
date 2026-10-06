#!/bin/bash
# On a Steam Frame, copy the Vulkan whisper.cpp build and point RPATH at $ORIGIN.
# Usage: scripts/stage-libs.sh [build-vk/bin] [stage-dir]
set -euo pipefail

SRC=${1:-$HOME/.local/src/whisper.cpp/build-vk/bin}
STAGE=${2:-/tmp/whisper-frame-lib}

if [ ! -x "$SRC/whisper-cli" ]; then
    echo "No whisper-cli in $SRC" >&2
    exit 1
fi
if ! command -v patchelf >/dev/null; then
    echo "patchelf is required on the Frame." >&2
    exit 1
fi

rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -a "$SRC/whisper-cli" "$STAGE/"
cp -a "$SRC"/libwhisper.so* "$SRC"/libggml.so* "$SRC"/libggml-base.so* \
    "$SRC"/libggml-cpu.so* "$SRC"/libggml-vulkan.so* "$STAGE/"

for f in "$STAGE"/*; do
    if [ -L "$f" ] || [ ! -f "$f" ]; then
        continue
    fi
    if readelf -d "$f" | grep -q 'R\(UN\)\?PATH'; then
        patchelf --set-rpath '$ORIGIN' "$f"
    fi
done

echo "Staged $STAGE"
readelf -d "$STAGE/whisper-cli" | grep RUNPATH
ldd "$STAGE/whisper-cli"
