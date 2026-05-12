/* Shell-Fusion V5.3 5.10.26 + Vulkan Optimizations */

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland // Required for WlrLayershell optimizations
import QtQuick

PanelWindow {
    id: shellFusion

    // --- NOCTALIA V4 / VULKAN HEADERS ---
    WlrLayershell.namespace: "noctalia-shell"
    WlrLayershell.layer: WlrLayer.Top
    
    // Reserve space on the screen only if auto-hide is off
    exclusiveZone: autoHideEnabled ? 0 : 34

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string omarchyConfig: homeDir + "/.config/omarchy/current/theme/colors.toml"
    readonly property string walkerScript: homeDir + "/.config/walker/launch.sh"

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
    color: "transparent"

    property bool autoHideEnabled: false
    property bool isHovered: false
    property bool drawerOpen: false

    readonly property string iconFont: "Material Symbols Rounded"
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    FileView {
        id: colorFileSource
        path: omarchyConfig
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
        readonly property string mSurface: parse("background", "#242424")
        readonly property string mOnSurface: parse("foreground", "#ffffff")
        readonly property string mPrimary: parse("accent", "#ffffff")
        readonly property string mOnPrimary: "#ffffff"
        readonly property string mSurfaceVariant: parse("color0", "#303030")
        readonly property string mError: parse("color1", "#ff7b63")
    }

    component FusionModule: Rectangle {
        property alias hoverArea: mArea
        width: 30
        height: 30
        radius: 8
        anchors.horizontalCenter: parent.horizontalCenter
        color: mArea.containsMouse ? theme.mSurfaceVariant : theme.mSurface
        border {
            color: theme.mPrimary
            width: 2
        }
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        MouseArea {
            id: mArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        }
    }

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
            
            // GPU-accelerated transition
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
            color: theme.mSurface

            Column {
                anchors {
                    top: parent.top
                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 2

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
                        // VULKAN OPTIMIZATION: QtRendering is faster for GPU-texture handling
                        renderType: Text.QtRendering
                        font {
                            family: iconFont
                            pixelSize: 22
                        }
                    }
                    hoverArea.onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            Hyprland.dispatch("exec kitty --class=sys-monitor -e btop");
                        } else {
                            Hyprland.dispatch("exec omarchy-menu");
                        }
                    }
                }

                Repeater {
                    model: Hyprland.workspaces
                    FusionModule {
                        // VULKAN OPTIMIZATION: Only enable layers during state changes
                        layer.enabled: isActive || hoverArea.containsMouse
                        
                        required property var modelData
                        property bool isActive: modelData === Hyprland.focusedWorkspace
                        property bool isOccupied: Hyprland.toplevels.values.some(t => t.workspace === modelData)

                        radius: hoverArea.containsMouse ? 15 : (isActive ? 12 : 8)
                        color: isActive ? theme.mPrimary : (hoverArea.containsMouse ? theme.mSurfaceVariant : theme.mSurface)

                        Rectangle {
                            visible: parent.isOccupied && !parent.isActive
                            width: 4
                            height: 4
                            radius: 2
                            color: theme.mPrimary
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.left
                                horizontalCenterOffset: 2
                            }
                            z: 1
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (parent.isActive) return "";
                                if (modelData.id === 6) return "\uf084";
                                if (modelData.id === 7) return "\uf001";
                                return modelData.id;
                            }
                            // VULKAN OPTIMIZATION: QtRendering
                            renderType: Text.QtRendering
                            color: parent.isActive ? theme.mOnPrimary : theme.mOnSurface
                            font {
                                weight: Font.DemiBold
                                family: monoFont
                                pixelSize: (modelData.id === 6 || modelData.id === 7) ? 20 : 17
                            }
                        }

                        hoverArea.onClicked: Hyprland.dispatch("workspace " + modelData.id)
                    }
                }
            }

            Item {
                anchors.centerIn: parent
                width: 20
                height: dateLabel.implicitWidth

                Text {
                    id: dateLabel
                    anchors.centerIn: parent
                    text: mainClock.date ? (function() {
                    let s = mainClock.date.toLocaleDateString(Qt.locale(), "ddd d").toLowerCase();
                    return s.charAt(0).toUpperCase() + s.slice(1);
                    })() : "..."
                    color: theme.mOnSurface
                    opacity: 0.7
                    font {
                        family: monoFont
                        pixelSize: 9
                        weight: Font.Regular
                    }
                    rotation: 270
                    // VULKAN OPTIMIZATION: QtRendering for transformed/rotated text
                    renderType: Text.QtRendering
                    antialiasing: true
                }
            }

            Column {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 2

                FusionModule {
                    height: 18
                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cf"
                        renderType: Text.QtRendering
                        font {
                            family: iconFont
                            pixelSize: 18
                        }
                        color: theme.mOnSurface
                        rotation: drawerOpen ? 180 : 0
                        Behavior on rotation {
                            NumberAnimation { duration: 250 }
                        }
                    }
                    hoverArea.onClicked: drawerOpen = !drawerOpen
                }

                Column {
                    spacing: 2
                    clip: true
                    height: drawerOpen ? implicitHeight : 0
                    opacity: drawerOpen ? 1.0 : 0
                    Behavior on height {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }

                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: "\ue14f"
                            renderType: Text.QtRendering
                            color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                            font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: Hyprland.dispatch("exec walker -m clipboard")
                    }
                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: "\ue3a9"
                            renderType: Text.QtRendering
                            color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                            font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: Hyprland.dispatch("exec omarchy-toggle-nightlight")
                    }
                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: autoHideEnabled ? "\ue898" : "\ue897"
                            renderType: Text.QtRendering
                            color: autoHideEnabled ? theme.mOnSurface : theme.mPrimary
                            font { family: iconFont; pixelSize: 20 }
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
                    height: 40
                    border.width: 2
                    hoverArea.onClicked: Hyprland.dispatch("exec kitty --class=calendar-pwa -e sh -c 'cal -m; read -n 1'")
                    Column {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                        }
                        topPadding: 2.4
                        spacing: -5
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: theme.mPrimary
                            renderType: Text.QtRendering
                            text: mainClock.date ? (mainClock.date.getHours() % 12 || 12).toString().padStart(2, '0') : "--"
                            font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: theme.mOnSurface
                            renderType: Text.QtRendering
                            text: mainClock.date ? mainClock.date.getMinutes().toString().padStart(2, '0') : "--"
                            font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                        }
                    }
                }

                FusionModule {
                    id: powerVolModule
                    property bool isMuted: false
                    Text {
                        anchors.centerIn: parent
                        text: powerVolModule.isMuted ? "\ue04f" : "\ue8ac"
                        renderType: Text.QtRendering
                        color: parent.hoverArea.containsMouse ? theme.mError : theme.mPrimary
                        font { family: iconFont; pixelSize: 18 }
                    }
                    hoverArea.onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            Hyprland.dispatch("exec pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.MiddleButton) {
                            Hyprland.dispatch("exec /home/j5/.config/hypr/scripts/f-reload.sh");
                        } else {
                            Hyprland.dispatch("exec omarchy-menu");
                        }
                    }
                    hoverArea.onWheel: wheel => {
                        Hyprland.dispatch("exec pactl set-sink-volume @DEFAULT_SINK@ " + (wheel.angleDelta.y > 0 ? "+5%" : "-5%"));
                        if (wheel.angleDelta.y > 0 && powerVolModule.isMuted)
                            powerVolModule.isMuted = false;
                    }
                }
            }
        }
    }

    SystemClock {
        id: mainClock
        precision: SystemClock.Minutes
    }
}
