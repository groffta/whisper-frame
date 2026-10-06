#!/bin/bash
# Assemble dist/whisper-frame-<version>-aarch64.tar.gz on this machine.
# Uses the local Vulkan whisper.cpp build. Nothing is copied over SSH.
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
VERSION=$(cat "$ROOT/VERSION")
SRC=${WHISPER_CPP_BIN:-$HOME/.local/src/whisper.cpp/build-vk/bin}
NAME="whisper-frame-$VERSION"
WORK="$ROOT/build/$NAME"
ARCHIVE="$ROOT/dist/$NAME-aarch64.tar.gz"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$ROOT/dist" "$WORK/lib"
"$ROOT/scripts/stage-libs.sh" "$SRC" "$STAGE"
cp -a "$STAGE/." "$WORK/lib/"

install -m 755 "$ROOT/whisper-ptt" "$WORK/whisper-ptt"
install -m 755 "$ROOT/install.sh" "$WORK/install.sh"
install -m 644 "$ROOT/whisper-ptt.service" "$WORK/whisper-ptt.service"
install -m 644 "$ROOT/README.md" "$WORK/README.md"
install -m 644 "$ROOT/LICENSE" "$WORK/LICENSE"
install -m 644 "$ROOT/VERSION" "$WORK/VERSION"
mkdir -p "$WORK/LICENSES"
install -m 644 "$ROOT/LICENSES/whisper.cpp" "$WORK/LICENSES/whisper.cpp"

tar -C "$ROOT/build" -czf "$ARCHIVE" "$NAME"
(cd "$ROOT/dist" && sha256sum "$(basename "$ARCHIVE")" > SHA256SUMS)
echo "$ARCHIVE"
sha256sum "$ARCHIVE"
