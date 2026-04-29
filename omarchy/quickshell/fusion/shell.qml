/* Shell-Fusion V4.9 4.29.26 Omarchy-Sync + Opmimizations */

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: shellFusion

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string omarchyConfig: homeDir + "/.config/omarchy/current/theme/colors.toml"
    readonly property string walkerScript: homeDir + "/.config/walker/launch.sh"

    anchors { left: true; top: true; bottom: true }
    margins { left: 0; right: 0; top: 0; bottom: 0 }
    implicitWidth: (autoHideEnabled && !isHovered && slidingContent.x <= -33) ? 0 : 34
    exclusionMode: autoHideEnabled ? 0 : 2
    color: "transparent"

    property bool autoHideEnabled: false
    property bool isHovered: false
    property bool drawerOpen: false

    readonly property string iconFont: "Material Symbols Rounded"
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    FileView { id: colorFileSource; path: omarchyConfig }

    QtObject {
        id: theme
        readonly property string raw: {
            try { return (typeof colorFileSource.text === "function") ? colorFileSource.text() : colorFileSource.text }
            catch(e) { return "" }
        }
        function parse(key, fallback) {
            const pattern = new RegExp("^\\s*" + key + "\\s*=\\s*[\"']?(#[A-Fa-f0-9]{6})[\"']?", "m");
            const m = raw.match(pattern);
            return m ? m[1] : fallback;
        }
        readonly property string mSurface:        parse("background", "#242424")
        readonly property string mOnSurface:      parse("foreground", "#ffffff")
        readonly property string mPrimary:        parse("accent",     "#ffffff")
        readonly property string mOnPrimary:      "#ffffff"
        readonly property string mSurfaceVariant: parse("color0",     "#303030")
        readonly property string mError:          parse("color1",     "#ff7b63")
    }

    component FusionModule : Rectangle {
        property alias hoverArea: mArea
        width: 30; height: 30; radius: 8
        anchors.horizontalCenter: parent.horizontalCenter
        color: mArea.containsMouse ? theme.mSurfaceVariant : theme.mSurface
        border { color: theme.mPrimary; width: 2 }
        Behavior on color { ColorAnimation { duration: 150 } }
        MouseArea {
            id: mArea;
            anchors.fill: parent;
            hoverEnabled: true;
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        }
    }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        onEntered: isHovered = true; onExited: isHovered = false

        Rectangle {
            id: slidingContent
            width: 34; anchors.top: parent.top; anchors.bottom: parent.bottom
            x: (autoHideEnabled && !isHovered) ? -34 : 0
            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            color: theme.mSurface

            // TOP COLUMN (Launcher)
            Column {
                anchors { top: parent.top; topMargin: 4; horizontalCenter: parent.horizontalCenter }
                spacing: 4

                FusionModule {
                    height: 30
                    Text {
                        anchors {
                            top: parent.top
                            topMargin: 2
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: "\ue5d3"
                        color: theme.mOnSurface
                        font { family: iconFont; pixelSize: 22 }
                    }

                    hoverArea.onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            Hyprland.dispatch("exec kitty --class=sys-monitor -e btop")
                        } else {
                            Hyprland.dispatch("exec omarchy-menu")
                        }
                    }
                }

                Repeater {
                    model: Hyprland.workspaces
                    FusionModule {
                        layer.enabled: true
                        layer.effect: null
                        required property var modelData
                        property bool isActive: modelData === Hyprland.focusedWorkspace
                        property bool isOccupied: Hyprland.toplevels.values.some(t => t.workspace === modelData)

                        radius: hoverArea.containsMouse ? 15 : (isActive ? 12 : 8)
                        color: isActive ? theme.mPrimary : (hoverArea.containsMouse ? theme.mSurfaceVariant : theme.mSurface)

                        Rectangle {
                            visible: parent.isOccupied && !parent.isActive
                            width: 4; height: 4; radius: 2; color: theme.mPrimary
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.left
                                horizontalCenterOffset: 2
                            }
                            z: 1
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.id
                            visible: !parent.isActive
                            color: theme.mOnSurface
                            font { weight: Font.DemiBold; family: monoFont; pixelSize: 17 }
                        }

                        hoverArea.onClicked: Hyprland.dispatch("workspace " + modelData.id)
                    }
                }
            }

            // MIDDLE ITEM (Window Title)
            Item {
                anchors.centerIn: parent; width: parent.width; height: 300
                Text {
                    anchors.centerIn: parent; width: 300; rotation: 270; horizontalAlignment: Text.AlignHCenter
                    opacity: 0.5; color: theme.mOnSurface
                    font { family: monoFont; weight: Font.DemiBold; pixelSize: 11 }
                    readonly property string title: Hyprland.activeToplevel
                        ? (Hyprland.activeToplevel.title || Hyprland.activeToplevel.class || "Desktop") : "Desktop"
                    text: title.length > 13 ? title.substring(0, 13) + "…" : title
                }
            }

            // BOTTOM COLUMN (Drawer, Clock, Power/Vol)
            Column {
                anchors {
                    bottom: parent.bottom;
                    bottomMargin: 4;
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 4

                FusionModule {
                    height: 18
                    Text {
                        anchors.centerIn: parent; text: "\ue5cf"; font { family: iconFont; pixelSize: 18 }
                        color: theme.mOnSurface; rotation: drawerOpen ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 250 } }
                    }
                    hoverArea.onClicked: drawerOpen = !drawerOpen
                }

                Column {
                    spacing: 4; clip: true
                    height: drawerOpen ? implicitHeight : 0; opacity: drawerOpen ? 1.0 : 0
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 250 } }

                    FusionModule {
                        Text { anchors.centerIn: parent; text: "\ue14f"; color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface; font { family: iconFont; pixelSize: 20 } }
                        hoverArea.onClicked: Hyprland.dispatch("exec walker -m clipboard")
                    }
                    FusionModule {
                        Text { anchors.centerIn: parent; text: "\ue3a9"; color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface; font { family: iconFont; pixelSize: 20 } }
                        hoverArea.onClicked: Hyprland.dispatch("exec omarchy-toggle-nightlight")
                    }
                    FusionModule {
                        Text {
                            anchors.centerIn: parent; text: autoHideEnabled ? "\ue898" : "\ue897"
                            color: autoHideEnabled ? theme.mOnSurface : theme.mPrimary; font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: {
                            autoHideEnabled = !autoHideEnabled;
                            shellFusion.margins.bottom = 1;
                            Qt.callLater(() => { shellFusion.margins.bottom = 0; });
                        }
                    }
                }

                FusionModule {
                    height: 40
                    border.width: 2
                    hoverArea.onClicked: Hyprland.dispatch("exec kitty --class=calendar-pwa -e sh -c 'cal -m; read -n 1'")
                    Column {
                        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
                        topPadding: 2.4; spacing: -5
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter; color: theme.mPrimary
                            text: mainClock.date ? (mainClock.date.getHours() % 12 || 12).toString().padStart(2, '0') : "--"
                            font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter; color: theme.mOnSurface
                            text: mainClock.date ? mainClock.date.getMinutes().toString().padStart(2, '0') : "--"
                            font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                        }
                    }
                }

                FusionModule {
                    id: powerVolModule
                    property bool isMuted: false
                    Text {
                        anchors.centerIn: parent; text: powerVolModule.isMuted ? "\ue04f" : "\ue8ac"
                        color: parent.hoverArea.containsMouse ? theme.mError : theme.mPrimary; font { family: iconFont; pixelSize: 18 }
                    }
                    hoverArea.onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            Hyprland.dispatch("exec pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.MiddleButton) {
                            Hyprland.dispatch("exec /home/j5/.config/hypr/scripts/f-reload.sh");
                        } else {
                            Hyprland.dispatch("exec omarchy-menu");
                        }
                    }
                    hoverArea.onWheel: (wheel) => {
                        Hyprland.dispatch("exec pactl set-sink-volume @DEFAULT_SINK@ " + (wheel.angleDelta.y > 0 ? "+5%" : "-5%"));
                        if (wheel.angleDelta.y > 0 && powerVolModule.isMuted) powerVolModule.isMuted = false;
                    }
                }
            }
        }
    }

    SystemClock { id: mainClock; precision: SystemClock.Minutes }
    Connections {
        target: Hyprland
        function onToplevelOpened() { Hyprland.refreshToplevels() }
        function onToplevelClosed() { Hyprland.refreshToplevels() }
    }
}
