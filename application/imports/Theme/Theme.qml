pragma Singleton

import QtQuick 2.15

QtObject {
    readonly property var color: QtObject {
        readonly property color transparent: Qt.rgba(0, 0, 0, 0)

        readonly property color lightorange1: "#00e676"
        readonly property color lightorange2: "#00d96a"
        readonly property color lightorange3: "#009950"
        readonly property color darkorange1: "#1a0a35"
        readonly property color darkorange2: "#15082d"
        readonly property color mediumorange1: "#2b7048"
        readonly property color mediumorange2: "#1a5235"
        readonly property color mediumorange3: "#14462c"
        readonly property color mediumorange4: "#1f5e3a"
        readonly property color mediumorange5: "#226540"

        readonly property color lightgreen: "#2ed832"
        readonly property color mediumgreen1: "#285b12"
        readonly property color mediumgreen2: "#203812"
        readonly property color darkgreen: "#0c160c"

        readonly property color lightblue: "#228cff"
        readonly property color mediumblue: "#143c66"
        readonly property color darkblue1: "#11355c"
        readonly property color darkblue2: "#152b47"

        readonly property color lightred1: "#ff3b8a"
        readonly property color lightred2: "#ff2480"
        readonly property color lightred3: "#d81b60"
        readonly property color lightred4: "#ff5599"
        readonly property color mediumred1: "#8a1c4a"
        readonly property color mediumred2: "#5e1230"
        readonly property color darkred1: "#3d0a1f"
        readonly property color darkred2: "#2e0816"
    }

    readonly property var timing: QtObject {
        readonly property int toolTipDelay: 500
    }
}
