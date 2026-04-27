/* Shell-Fusion V4.3 4.27.26 Calendar(wip) + Omarchy-Sync */

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: shellFusion

    // ── CONFIGURATION & PATHS ───────────────────────────────
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string omarchyConfig: homeDir + "/.config/omarchy/current/theme/colors.toml"
    readonly property string walkerScript: homeDir + "/.config/walker/launch.sh"

    // Window Setup
    anchors {
        left: true
        top: true
        bottom: true
    }
    margins {
        left: 0
        right: 0
        top: 0
        bottom: 0
    }

    // NOTE: This line is what causes the bar to "jump" (resize) when opening the calendar.
    implicitWidth: calendarOpen ? 250 : ((autoHideEnabled && !isHovered && slidingContent.x <= -33) ? 0 : 34)
    exclusionMode: (autoHideEnabled || calendarOpen) ? 0 : 2
    color: "transparent"

    // State Variables
    property bool autoHideEnabled: false
    property bool isHovered: false
    property bool drawerOpen: false
    property bool calendarOpen: false

    readonly property string iconFont: "Material Symbols Rounded"
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    // ── Omarchy Theme Sync ──────────────────────────────────
    readonly property string colorsFile: homeDir + "/.config/omarchy/current/theme/colors.toml"

    FileView {
        id: colorFileSource
        path: colorsFile
    }

    QtObject {
        id: theme
        readonly property string raw: {
            try {
                return (typeof colorFileSource.text === "function") ? colorFileSource.text() : colorFileSource.text;
            } catch (e) {
                return "";
            }
        }

        function parse(key, fallback) {
            const pattern = new RegExp("^\\s*" + key + "\\s*=\\s*[\"']?(#[A-Fa-f0-9]{6})[\"']?", "m");
            const m = raw.match(pattern);
            return m ? m[1] : fallback;
        }

        readonly property string mSurface: parse("background", "#060B1E")
        readonly property string mOnSurface: parse("foreground", "#ffcead")
        readonly property string mPrimary: parse("accent", "#7d82d9")
        readonly property string mOnPrimary: "#060B1E"
        readonly property string mSurfaceVariant: parse("color0", "#333333")
        readonly property string mError: parse("color1", "#ED5B5A")
    }

    // ── UI COMPONENTS ───────────────────────────────────────

    component FusionModule: Rectangle {
        property alias hoverArea: mArea
        property bool isHovered: mArea.containsMouse
        width: 30
        height: 30
        radius: 8
        anchors.horizontalCenter: parent.horizontalCenter
        color: isHovered ? theme.mSurfaceVariant : theme.mSurface
        border {
            color: theme.mPrimary
            width: 2
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }

        MouseArea {
            id: mArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }
    }

    component FusionIcon: Text {
        property bool activeHover: false
        property string baseColor: theme.mOnSurface
        property string hoverColor: theme.mPrimary
        property int size: 20
        anchors.centerIn: parent
        color: activeHover ? hoverColor : baseColor
        font {
            family: iconFont
            pixelSize: size
        }
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    // ── MAIN UI LAYOUT ──────────────────────────────────────

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: isHovered = true
        onExited: isHovered = false

        // Main Bar Container
        Rectangle {
            id: slidingContent
            width: 34
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            x: (autoHideEnabled && !isHovered && !calendarOpen) ? -34 : 0
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
            color: theme.mSurface

            // Top Section
            Column {
                anchors {
                    top: parent.top
                    topMargin: 6
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 4

                FusionModule {
                    FusionIcon {
                        text: "\ue5d3"
                        size: 22
                    }
                    hoverArea.onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            Hyprland.dispatch("exec " + walkerScript);
                        } else {
                            Hyprland.dispatch("exec omarchy-menu");
                        }
                    }
                }

                Repeater {
                    model: Hyprland.workspaces
                    FusionModule {
                        required property var modelData
                        property bool isActive: modelData === Hyprland.focusedWorkspace
                        property bool isOccupied: Hyprland.toplevels.values.some(t => t.workspace === modelData)
                        radius: isHovered ? 15 : (isActive ? 12 : 8)
                        color: isActive ? theme.mPrimary : (isHovered ? theme.mSurfaceVariant : theme.mSurface)

                        // ── WORKSPACE DOT INDICATOR (From Backup) ──
                        Rectangle {
                            visible: parent.isOccupied && !parent.isActive
                            width: 4
                            height: 4
                            radius: 2
                            color: theme.mPrimary
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.left
                            anchors.horizontalCenterOffset: 2
                            z: 1
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.id
                            color: parent.isActive ? theme.mOnPrimary : theme.mOnSurface
                            font {
                                weight: Font.DemiBold
                                family: monoFont
                                pixelSize: 17
                            }
                        }
                        hoverArea.onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton)
                                Hyprland.dispatch("workspace " + modelData.id);
                        }
                    }
                }
            }

            // Bottom Section
            Column {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 6
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 4

                FusionModule {
                    height: 18
                    FusionIcon {
                        text: "\ue5cf"
                        size: 18
                        rotation: drawerOpen ? 180 : 0
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 250
                            }
                        }
                    }
                    hoverArea.onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton)
                            drawerOpen = !drawerOpen;
                    }
                }

                Column {
                    clip: true
                    spacing: 6
                    height: drawerOpen ? implicitHeight : 0
                    opacity: drawerOpen ? 1.0 : 0
                    Behavior on height {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                        }
                    }

                    FusionModule {
                        FusionIcon {
                            activeHover: parent.isHovered
                            text: "\ue14f"
                        }
                        hoverArea.onClicked: Hyprland.dispatch("exec walker -m clipboard")
                    }
                    FusionModule {
                        FusionIcon {
                            activeHover: parent.isHovered
                            text: "\ue3a9"
                        }
                        hoverArea.onClicked: Hyprland.dispatch("exec omarchy-toggle-nightlight")
                    }
                    FusionModule {
                        FusionIcon {
                            text: autoHideEnabled ? "\ue898" : "\ue897"
                            baseColor: autoHideEnabled ? theme.mOnSurface : theme.mPrimary
                        }
                        hoverArea.onClicked: {
                            autoHideEnabled = !autoHideEnabled;
                            shellFusion.margins.bottom = 1;
                            Qt.callLater(() => {
                                shellFusion.margins.bottom = 0;
                            });
                        }
                    }
                }

                // VERTICAL CLOCK (Integrated Calendar Toggle)
                FusionModule {
                    height: 42
                    border.color: calendarOpen ? theme.mPrimary : "transparent"
                    Column {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                        }
                        topPadding: 2
                        spacing: -2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: theme.mPrimary
                            text: mainClock.date ? (mainClock.date.getHours() % 12 || 12).toString().padStart(2, '0') : "--"
                            font {
                                weight: Font.DemiBold
                                pixelSize: 15
                                family: monoFont
                            }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: theme.mOnSurface
                            text: mainClock.date ? mainClock.date.getMinutes().toString().padStart(2, '0') : "--"
                            font {
                                weight: Font.DemiBold
                                pixelSize: 15
                                family: monoFont
                            }
                        }
                    }
                    hoverArea.onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton)
                            calendarOpen = !calendarOpen;
                    }
                }

                // POWER / VOL BUTTON
                FusionModule {
                    id: powerVolModule
                    height: 30
                    property bool isMuted: false
                    FusionIcon {
                        activeHover: parent.isHovered
                        text: powerVolModule.isMuted ? "\ue04f" : "\ue8ac"
                        size: 18
                        baseColor: powerVolModule.isMuted ? theme.mError : theme.mPrimary
                        hoverColor: theme.mError
                    }
                    hoverArea.onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            Hyprland.dispatch("exec pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.LeftButton) {
                            Hyprland.dispatch("exec omarchy-menu");
                        }
                    }
                    hoverArea.onWheel: wheel => {
                        const step = wheel.angleDelta.y > 0 ? "+5%" : "-5%";
                        Hyprland.dispatch("exec pactl set-sink-volume @DEFAULT_SINK@ " + step);
                        if (wheel.angleDelta.y > 0 && powerVolModule.isMuted)
                            powerVolModule.isMuted = false;
                    }
                }
            }
        }

        // ── INTEGRATED CALENDAR POPUP ──────────────────────────
        Item {
            anchors {
                left: slidingContent.right
                leftMargin: 6
                bottom: parent.bottom
                bottomMargin: 6
            }

            Rectangle {
                id: calendarView
                visible: calendarOpen
                // Width increased to 210 to fit the 187px grid properly
                width: 210
                height: 220

                anchors.left: parent.left
                anchors.bottom: parent.bottom

                color: theme.mSurface
                radius: 12
                border {
                    color: theme.mPrimary
                    width: 2
                }

                // Swallow mouse events inside the calendar
                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    onPressed: mouse => mouse.accepted = true
                }
                TapHandler {
                    acceptedButtons: Qt.AllButtons
                }
                DragHandler {
                    target: null
                }
                WheelHandler {
                    target: null
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Month Header
                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        color: theme.mPrimary
                        font {
                            family: monoFont
                            weight: Font.Bold
                            pixelSize: 16
                        }
                        text: mainClock.date.toLocaleString(Qt.locale(), "MMMM yyyy")
                    }

                    // Weekday Labels
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2
                        Repeater {
                            model: ["S", "M", "T", "W", "T", "F", "S"]
                            Text {
                                width: 25
                                horizontalAlignment: Text.AlignHCenter
                                color: theme.mOnSurface
                                opacity: 0.5
                                font {
                                    family: monoFont
                                    pixelSize: 10
                                }
                                text: modelData
                            }
                        }
                    }

                    // Days Grid
                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: 7
                        spacing: 2
                        Repeater {
                            model: {
                                const date = mainClock.date;
                                const firstDay = new Date(date.getFullYear(), date.getMonth(), 1).getDay();
                                const daysInMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
                                return firstDay + daysInMonth;
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 4
                                color: isToday ? theme.mPrimary : "transparent"

                                readonly property int firstDayOffset: new Date(mainClock.date.getFullYear(), mainClock.date.getMonth(), 1).getDay()
                                readonly property int dayNumber: index - firstDayOffset + 1
                                readonly property bool isToday: dayNumber === mainClock.date.getDate()
                                readonly property bool isVisible: dayNumber > 0

                                Text {
                                    anchors.centerIn: parent
                                    visible: parent.isVisible
                                    text: parent.dayNumber
                                    color: parent.isToday ? theme.mOnPrimary : theme.mOnSurface
                                    font {
                                        family: monoFont
                                        pixelSize: 12
                                        weight: parent.isToday ? Font.Bold : Font.Normal
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    SystemClock {
        id: mainClock
        precision: SystemClock.Minutes
    }

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            Hyprland.refreshToplevels();
        }
    }
}
