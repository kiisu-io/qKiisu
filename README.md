## qKiisu

> **Work in progress.** This project is under active development and is not yet recommended for general use.

qKiisu is a fork of [qFlipper](https://github.com/flipperdevices/qFlipper) by Flipper Devices Inc., adapted for the [Kiisu V4B](https://kiisu.io/) development board by [RainWalker OÜ](https://store.rainwalker.ee/).

### What it does
Desktop application for updating Kiisu firmware, managing files on SD card, and streaming the device screen. Runs on Windows, macOS, and Linux.

### Download
Pre-built binaries are available on the [Releases](https://github.com/kiisu-io/qKiisu/releases) page:
- Windows: NSIS installer (`qKiisuSetup-64bit.exe`) or portable zip
- macOS: `.dmg` (universal x86_64 + arm64)
- Linux: `.AppImage`

> **Note.** Self-update / firmware-update server URLs are not yet set up — the UI shows a neutral state instead of fetching updates. To install firmware, drop a bundle on the device manually for now.

### Build from sources
```sh
git clone https://github.com/kiisu-io/qKiisu.git --recursive
```
See the [CI workflow](.github/workflows/ci.yml) for build steps per platform.

### License
GPL-3.0 — same as the original qFlipper.
