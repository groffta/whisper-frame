# Changelog

## 0.2.0 - 2026-10-06

- A mic sits at the bottom-right of each floating window. Hold it to dictate immediately. A click shorter than about a third of a second leaves recording running until the next click, and the transcript is typed into that window.
- While a take is recording, every mic shows a circle. After release they show a spinner until the transcript has been typed. Headset Select drives the same icons.
- Select is the only hardware trigger. A hold arms after 300 ms, and the beeps are shorter. A gamepad name in the config still arms that button.
- `clear` backspaces the characters whisper typed, one for each, instead of selecting the whole field. `submit` presses Enter and drops that buffer.
- The mic eases with the window when it is dragged or resized. Both eases are 10 ms. A move past 0.35 m snaps.
- The dictation service reopens its display after the X server restarts. The mic panel starts again when SteamVR restarts.
- The release archive is still the dictation daemon. Installing from this repository also builds the window mic when `whisper-panel` and `overlay_point.c` are present.

## 0.1.0 - 2026-10-05

- Push-to-talk dictation on the Frame. Whisper Small runs on the headset and types into the focused window.
- Hold Select, or left-stick click, until the beep.
- `clear` selects the field and backspaces it. `submit` presses Enter.
