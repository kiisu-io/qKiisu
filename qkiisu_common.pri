NAME = qKiisu

equals(QT_MAJOR_VERSION, 6): QT += core5compat

unix:!macx {
    DEFINES += USB_BACKEND_LIBUSB
    CONFIG += link_pkgconfig
    PKGCONFIG += libusb-1.0 zlib

    isEmpty(PREFIX): PREFIX = /usr

} else:win32 {
    CONFIG -= debug_and_release
    DEFINES += USB_BACKEND_WIN32
    INCLUDEPATH += $$[QT_INSTALL_HEADERS]/QtZlib

    !win32-g++: LIBS +=  -lSetupApi -lWinusb -lUser32
    else: LIBS += -lsetupapi -lwinusb

} else:macx {
    DEFINES += USB_BACKEND_LIBUSB
    PKG_CONFIG = /opt/homebrew/bin/pkg-config
    CONFIG += link_pkgconfig
    PKGCONFIG += libusb-1.0 zlib

} else {
    error("Unsupported OS or compiler")
}

GIT_VERSION = $$system("git describe --tags --abbrev=0","lines", HAS_VERSION)
!equals(HAS_VERSION, 0) {
    GIT_VERSION = unknown
}

GIT_COMMIT = $$system("git rev-parse --short=8 HEAD","lines", HAS_COMMIT)
!equals(HAS_COMMIT, 0) {
    GIT_COMMIT = unknown
}

GIT_TIMESTAMP = $$system("git log -1 --pretty=format:%ct","lines", HAS_TIMESTAMP)
!equals(HAS_TIMESTAMP, 0) {
    GIT_TIMESTAMP = 0
}

# Update server URLs — empty by default. Set in qkiisu_common.pri or via qmake CLI
# (e.g. qmake "KIISU_APP_UPDATES_URL=https://update.kiisu.io/qKiisu/directory.json").
# When empty, the corresponding registry stays in Unknown state and no network calls are made.
isEmpty(KIISU_APP_UPDATES_URL): KIISU_APP_UPDATES_URL = ""
isEmpty(KIISU_FW_UPDATES_URL):  KIISU_FW_UPDATES_URL  = ""
# Region provisioning API (SubGHz). Defaults to upstream Flipper endpoint, override to self-host.
isEmpty(KIISU_REGION_API_URL):  KIISU_REGION_API_URL  = "https://update.flipperzero.one/regions/api/v0/bundle"

DEFINES += APP_NAME=\\\"$$NAME\\\" \
           APP_VERSION=\\\"$$GIT_VERSION\\\" \
           APP_COMMIT=\\\"$$GIT_COMMIT\\\" \
           APP_TIMESTAMP=$$GIT_TIMESTAMP \
           KIISU_APP_UPDATES_URL=\\\"$$KIISU_APP_UPDATES_URL\\\" \
           KIISU_FW_UPDATES_URL=\\\"$$KIISU_FW_UPDATES_URL\\\" \
           KIISU_REGION_API_URL=\\\"$$KIISU_REGION_API_URL\\\" \
           PB_ENABLE_MALLOC

