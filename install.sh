#!/bin/bash
# Install whisper-frame into the current user's home and start the user service.
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
PREFIX=${PREFIX:-$HOME/.local}
LIB="$PREFIX/lib/whisper-frame"
BINDIR="$PREFIX/bin"
SHARE="$PREFIX/share/whisper"
UNIT_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user
MODEL="$SHARE/ggml-small-q8_0.bin"
MODEL_URL=${MODEL_URL:-https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small-q8_0.bin}
MODEL_BYTES=264464607

if [ "$(uname -m)" != "aarch64" ]; then
    echo "This archive is the aarch64 Steam Frame build." >&2
    exit 1
fi
if [ ! -x "$ROOT/lib/whisper-cli" ] || [ ! -f "$ROOT/whisper-ptt" ]; then
    echo "Run install.sh from the extracted whisper-frame directory." >&2
    exit 1
fi

mkdir -p "$LIB" "$BINDIR" "$SHARE" "$UNIT_DIR"
cp -a "$ROOT/lib/." "$LIB/"
install -m 755 "$ROOT/whisper-ptt" "$BINDIR/whisper-ptt"
install -m 644 "$ROOT/whisper-ptt.service" "$UNIT_DIR/whisper-ptt.service"
chmod 755 "$LIB/whisper-cli"

have=0
if [ -f "$MODEL" ]; then
    have=$(stat -c %s "$MODEL")
fi
if [ "$have" != "$MODEL_BYTES" ]; then
    echo "Downloading ggml-small-q8_0.bin ($MODEL_BYTES bytes)"
    rm -f "$MODEL.partial"
    curl -fL --retry 3 --retry-delay 2 -o "$MODEL.partial" "$MODEL_URL"
    got=$(stat -c %s "$MODEL.partial")
    if [ "$got" != "$MODEL_BYTES" ]; then
        rm -f "$MODEL.partial"
        echo "Model download is $got bytes, expected $MODEL_BYTES." >&2
        exit 1
    fi
    mv "$MODEL.partial" "$MODEL"
fi

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
if [ ! -S "$XDG_RUNTIME_DIR/bus" ]; then
    echo "No user bus at $XDG_RUNTIME_DIR/bus. Run this inside the Frame desktop session." >&2
    exit 1
fi
systemctl --user daemon-reload
systemctl --user enable whisper-ptt
systemctl --user restart whisper-ptt
systemctl --user --no-pager --full status whisper-ptt
echo "Installed. Hold Select or left-stick click until the beep."
