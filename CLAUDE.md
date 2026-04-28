# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project context

qKiisu is a Qt 6 desktop application for managing the **Kiisu V4B** board (by RainWalker OÜ). It is a fork of [qFlipper](https://github.com/flipperdevices/qFlipper) — the underlying STM32WB55 MCU and the wire protocol are unchanged, so the codebase is still pervasively "flipper-flavored": directory names like `backend/flipperzero/`, classes named `FlipperZero*`, USB VID/PID `0483:5740` with manufacturer string `Flipper Devices Inc.`, and protobuf messages from `plugins/flipperproto0/messages/*.proto`. Renaming these is **not** a goal — they reflect the firmware/protocol still in use. Only user-visible strings, branding assets, and the application/organization names (`qKiisu` / `RainWalker OÜ` / `kiisu.io`) have been rebranded.

Status: work-in-progress fork. The local helper scripts `build_mac.sh` and `build_windows.bat` still reference upstream Flipper resources (`flipperdevices/homebrew-flipper` Homebrew tap, `cdn.flipperzero.one` for the STM32 DFU driver) — see TODO comments in those files. The CI workflow does **not** depend on these.

## Build system

This project uses **qmake (Qt 6.4.2)**, not CMake. The top-level `qKiisu.pro` is a `subdirs` project; common build settings live in `qkiisu_common.pri` (USB backend selection, version macros from `git describe`, `APP_NAME`/`APP_VERSION`/`APP_COMMIT`/`APP_TIMESTAMP` defines). When changing build flags or version macros, edit `qkiisu_common.pri` so all subprojects pick them up.

Subdirectory dependency graph (from `qKiisu.pro`):
```
3rdparty (nanopb)  ──►  plugins  ──►  backend  ──►  application
                                           └──►  cli
                                  dfu  ─────┘
```

### Build commands

| Platform | Script | Notes |
|---|---|---|
| Linux | `./build_linux.sh` | Produces `build/qKiisu-x86_64.AppImage` via `linuxdeploy`. Requires `libusb-1.0-dev`, `libfuse2`, `linuxdeploy` + `linuxdeploy-plugin-qt` on `$PATH`. |
| macOS | `./build_mac.sh` | Universal binary (x86_64 + arm64). Needs `libusb_universal` and `qt_universal` from a Homebrew tap; tap may need updating for Kiisu (TODO in script). Produces `.app` and `.dmg`. |
| Windows | `build_windows.bat` | MSVC 2019 x64, Qt at `C:\Qt\6.4.2\msvc2019_64`. Uses `jom`, `windeployqt`, and NSIS. Expects STM32 DFU driver at `C:\STM32 Driver` and VC++ redistributables at `C:\Qt\vcredist`. The Windows job in CI is a much simpler reference — see below. |

GitHub-hosted CI runners (`.github/workflows/ci.yml`) build all three targets on push using a more straightforward path (plain `make`/`nmake`, no signing). The Windows job additionally produces an NSIS installer (`qKiisuSetup-64bit.exe`) — the script is a stripped-down `installer_windows.nsi` that does **not** bundle VC++ Redistributable or the STM32 DFU driver (users get the driver via the bundled `KiisuDriverTool` / Zadig). When troubleshooting build issues, the CI workflow is usually a cleaner reference than the local scripts.

### Manual build (any platform)

```sh
mkdir build && cd build
qmake ../qKiisu.pro -spec <linux-g++|macx-clang|win32-msvc> "CONFIG+=release qtquickcompiler"
make qmake_all   # generates makefiles for all subdirs (NEEDED — `make` alone won't recurse correctly the first time)
make -j$(nproc)
make install     # required on Windows; on Linux/Mac stages files for packaging
```

Required Qt modules: `qtserialport`, `qt5compat`, `qtshadertools` (plus `core5compat` referenced in `qkiisu_common.pri`).

### Initial clone

`git clone --recursive` is required — submodules are `3rdparty/nanopb` and `driver-tool/libwdi`. If you forgot, run `git submodule update --init`.

### Running tests

There is no automated test suite. The `cli` target (`qKiisu-cli`) is described in `cli/README.md` as "mostly meant for testing purposes" — use it for manual end-to-end verification against a connected board.

## Architecture overview

The codebase is a layered Qt/QML desktop app where the GUI talks to a state-machine-driven backend that drives the hardware over two distinct transports:

1. **DFU mode** (recovery) — STM32 DfuSe over USB control transfers. Code in `dfu/`. USB transport is platform-split: `dfu/libusb/` for Linux/macOS, `dfu/win32/` (WinUSB + SetupAPI) for Windows. Selected at compile time via `USB_BACKEND_LIBUSB` / `USB_BACKEND_WIN32` defines from `qkiisu_common.pri`.
2. **Normal mode** — Qt Serial over a virtual CDC-ACM port, framing protobuf-encoded RPC messages (`PB_Main`). The protobuf layer lives in `plugins/flipperproto0/` and is loaded as a **versioned Qt plugin** via the `protobufinterface` ABI in `plugins/protobufinterface/`. The plugin must be deployed to a `plugins/` directory next to the executable (see deploy steps in `build_*.sh`/`build_windows.bat` and the CI workflow); the application loads it dynamically at runtime.

### Backend operation model

`backend/` is a static library; everything is built around `AbstractOperation` + `AbstractOperationRunner` (a queue of asynchronous operations with a state machine each). Operations are layered:

- **`backend/flipperzero/rpc/`** — leaf operations that send a single protobuf request/response (`StorageReadOperation`, `GuiStartScreenStreamOperation`, `SystemRebootOperation`, …).
- **`backend/flipperzero/recovery/`** — leaf DFU operations (`FirmwareDownloadOperation`, `WirelessStackDownloadOperation`, `SetBootModeOperation`, `CorrectOptionBytesOperation`).
- **`backend/flipperzero/utility/`** — composite operations that orchestrate multiple RPC ops (`FilesUploadOperation`, `DirectoryDownloadOperation`, `RegionProvisioningOperation`, …).
- **`backend/flipperzero/toplevel/`** — user-facing flows that may switch the device between normal and recovery mode mid-flow (`FullUpdateOperation`, `FullRepairOperation`, `FactoryResetOperation`).
- **`backend/flipperzero/helper/`** — pre-flight tasks (download firmware bundles, parse manifests, init serial port).

The runner-of-runners pattern: `FlipperZero` owns a `RecoveryInterface` and a `UtilityInterface`, each running their own queue. `ApplicationBackend` (the QML-facing facade) selects which interface to push the next top-level op into based on the current `DeviceState`. When tracing a feature, follow this chain: QML signal → `ApplicationBackend` slot → top-level op enqueued on the correct interface → emits signals back up to QML.

### Frontend (QML)

- `application/main.qml` is the entry point; QML modules live under `application/components/`, `application/imports/`, `application/styles/`. Resources are bundled via `application/qml.qrc` and `qtquickcompiler` is enabled in release builds.
- `qtsingleapplication/` is the (vendored) single-instance helper — second launches forward arguments to the first.
- `screencanvas.cpp` paints frames from `ScreenStreamer` (forwarded from the `Gui_*` RPC operations).
- Translations: `application/translations/en_US.ts`, embedded via `CONFIG += embed_translations`.
- Theme palette in `application/imports/Theme/Theme.qml` keeps the upstream property names (`lightorange*`/`darkorange*`/`mediumorange*`) but the **values** are Kiisu-branded — green accents (`#00e676` family) on purple (`#1a0a35` family). Don't be fooled by the names. The `lightred*`/`mediumred*`/`darkred*` family is the error/warning palette and is magenta-tinted, not red, to read as "not OK" on the green theme without echoing the old flipper-orange.

### Update servers

Three update endpoints are configurable via qmake variables in `qkiisu_common.pri` (or on the qmake CLI):

- `KIISU_APP_UPDATES_URL` — `directory.json` for qKiisu itself (self-update). Empty by default.
- `KIISU_FW_UPDATES_URL` — `directory.json` for Kiisu firmware bundles. Empty by default.
- `KIISU_REGION_API_URL` — SubGHz region provisioning API. Defaults to the **upstream Flipper endpoint** (`https://update.flipperzero.one/regions/api/v0/bundle`) so region provisioning keeps working until we host our own.

`UpdateRegistry::check()` (in `backend/updateregistry.cpp`) treats an empty URL as "not configured" and stays in `Unknown` state — the UI shows a neutral state instead of a connection error. When a Kiisu update server is set up, override the URLs in `qkiisu_common.pri` and rebuild; no other code change is needed.

### Branding & device IDs

USB device IDs and udev rules still reference Flipper because the firmware on Kiisu V4B announces itself that way:
- Serial: `VID:0483 PID:5740` (manufacturer string `Flipper Devices Inc.`)
- DFU: `VID:0483 PID:df11` (STMicroelectronics, default STM32 DFU)
- See `setup_rules.sh` and `installer-assets/udev/42-kiisu.rules`.

If a device isn't recognized on Linux, the udev rule install is the most common fix.

## Conventions worth knowing

- `git describe --tags --abbrev=0` is invoked at qmake-time to bake the version into `APP_VERSION`. A clean clone with no tags will produce `unknown` — fine for development, breaks Windows installer/`.rc` generation (the `installer_windows.nsi` flow expects a real version).
- The `flipperproto0` plugin's filename differs by platform: `libflipperproto0.so/.dylib` on unix, `flipperproto.dll` on Windows (`win32: TARGET = flipperproto`). Deployment scripts must handle both.
- Protobuf `.proto` sources are not compiled at build time; the generated `messages/*.pb.[ch]` are committed and used directly.
- Don't rename `flipperzero`/`Flipper*` symbols, USB strings, or protobuf message names — see "Project context" above.
