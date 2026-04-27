/* Shell-Fusion V4.3 4.26.26 Omarchy-Sync */

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
    implicitWidth: (autoHideEnabled && !isHovered && slidingContent.x <= -33) ? 0 : 34
    exclusionMode: autoHideEnabled ? 0 : 2
    color: "transparent"

    // State Variables
    property bool autoHideEnabled: false
    property bool isHovered: false
    property bool drawerOpen: false

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
            // Explicitly allow Right Clicks globally for all modules
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

        Rectangle {
            id: slidingContent
            width: 34
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            x: (autoHideEnabled && !isHovered) ? -34 : 0
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

            // Center Section
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: 300
                Text {
                    anchors.centerIn: parent
                    width: 300
                    rotation: 270
                    horizontalAlignment: Text.AlignHCenter
                    opacity: 0.5
                    color: theme.mOnSurface
                    font {
                        family: monoFont
                        weight: Font.DemiBold
                        pixelSize: 11
                    }
                    readonly property string title: Hyprland.activeToplevel ? (Hyprland.activeToplevel.title || Hyprland.activeToplevel.class || "Desktop") : "Desktop"
                    text: title.length > 13 ? title.substring(0, 13) + "…" : title
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

                FusionModule {
                    height: 42
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
                }

                // THE POWER / VOL BUTTON
                FusionModule {
                    id: powerVolModule
                    height: 30
                    property bool isMuted: false

                    FusionIcon {
                        activeHover: parent.isHovered
                        // \ue04f = volume_off, \ue8ac = power
                        text: powerVolModule.isMuted ? "\ue04f" : "\ue8ac"
                        size: 18
                        baseColor: powerVolModule.isMuted ? theme.mError : theme.mPrimary
                        hoverColor: theme.mError
                    }

                    hoverArea.onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            console.log("Right click detected! Toggling mute...");
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            Hyprland.dispatch("exec pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.LeftButton) {
                            console.log("Left click detected! Opening menu...");
                            Hyprland.dispatch("exec omarchy-menu");
                        }
                    }

                    hoverArea.onWheel: wheel => {
                        const step = wheel.angleDelta.y > 0 ? "+5%" : "-5%";
                        Hyprland.dispatch("exec pactl set-sink-volume @DEFAULT_SINK@ " + step);
                        if (wheel.angleDelta.y > 0 && powerVolModule.isMuted) {
                            powerVolModule.isMuted = false;
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
