# whisper-frame

Push-to-talk dictation for the Steam Frame. Whisper Small runs on the headset, on the Adreno 750, and types into the window gamescope already has focused.

This is a user-local install. SteamOS keeps the root filesystem read-only, and files under your home directory stay in place across system updates.

## Install

Copy `whisper-frame-0.1.0-aarch64.tar.gz` to the Frame, then from a terminal in the desktop session:

```sh
tar -xzf whisper-frame-0.1.0-aarch64.tar.gz
cd whisper-frame-0.1.0
./install.sh
```

The archive is about 46 MB and contains the aarch64 Vulkan build of whisper.cpp 1.9.4. The installer downloads `ggml-small-q8_0.bin` (264,464,607 bytes) from the whisper.cpp Hugging Face repo if you do not already have it. Vulkan, PipeWire, and XTest come with SteamOS.

Installed paths:

- `~/.local/bin/whisper-ptt`
- `~/.local/lib/whisper-frame/` (`whisper-cli` and its libraries, RPATH `$ORIGIN`)
- `~/.local/share/whisper/ggml-small-q8_0.bin`
- `~/.config/systemd/user/whisper-ptt.service`

## Use

Hold the headset Select button, or Y on the right controller, for about a third of a second. The beep means recording has started. Speak, then release. The transcript is typed into the focused window. A short click is left for Steam Input and does not beep.

Y is the top face button. Pointer mode leaves it free: the trigger and bumper click, the stick click is right-click, A is home, B is back, and X is middle-click. Left-stick click does not reach whisper on the desktop. The Frame's desktop config is empty, so the virtual gamepad never sees that hold.

`clear` and `submit` are commands when they are the whole transcript, or the first or last word.

- `clear` selects the focused field and backspaces it.
- `submit` presses Enter.
- `clear buy milk submit` clears, types `buy milk`, then presses Enter.
- A `clear` or `submit` in the middle of the sentence is typed as a normal word.

## Config

`~/.config/whisper-ptt/config` is created on first run.

```
button=both
language=en
threads=4
append_space=yes
enter=no
min_ms=280
arm_ms=300
max_ms=28000
silence_rms=30
```

`button` can be `both`, `select`, `y`, or a gamepad name (`a`, `b`, `x`, `y`, `lb`, `rb`, `view`, `menu`, `guide`, `l3`, `r3`). `both` is Select plus Y. `arm_ms` is how long a hold lasts before the beep. After editing the file:

```sh
systemctl --user restart whisper-ptt
```

## Uninstall

```sh
systemctl --user disable --now whisper-ptt
rm -f ~/.local/bin/whisper-ptt ~/.config/systemd/user/whisper-ptt.service
rm -rf ~/.local/lib/whisper-frame
systemctl --user daemon-reload
```

The model in `~/.local/share/whisper/` is left in place.

## Build the archive

On the Frame, from this repository, with the Vulkan whisper.cpp build at `~/.local/src/whisper.cpp/build-vk`:

```sh
scripts/pack.sh
```

That writes `dist/whisper-frame-<version>-aarch64.tar.gz` from the local binaries. `patchelf` has to be installed. `WHISPER_CPP_BIN` overrides the build directory.

## License

The installer, service, and `whisper-ptt` script are MIT, in `LICENSE`. The bundled `whisper-cli` and ggml libraries are whisper.cpp, also MIT, in `LICENSES/whisper.cpp`.
