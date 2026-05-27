/* Shell-Fusion V6.5 (jetbrains-basic)(fixes + stopwatch) [j5onrf] 5.27.26 */

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland 
import QtQuick

PanelWindow {
    id: shellFusion

    WlrLayershell.namespace: "fusion-shell"
    WlrLayershell.layer: WlrLayer.Top
    
    exclusiveZone: autoHideEnabled ? 0 : 34

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string omarchyConfig: homeDir + "/.config/omarchy/current/theme/colors.toml"

    anchors {
        left: true
        top: true
        bottom: true
    }
    
    implicitWidth: (autoHideEnabled && !isHovered) ? 2 : 34
    color: "transparent"

    property bool autoHideEnabled: false
    property bool isHovered: false
    property bool drawerOpen: false

    readonly property string iconFont: "Material Symbols Rounded"
    readonly property string monoFont: "JetBrains Mono"

    // --- AUTOMATED FILE WATCHER BACKEND ---
    FileView {
        id: colorFileSource
        path: omarchyConfig
        
        // This fires automatically only when the file actually modifies on disk
        onTextChanged: {
            const rawText = (typeof text === "function") ? text() : text;
            if (rawText) {
                theme.updateThemeFromFile(rawText);
            }
        }
    }

    QtObject {
        id: theme
        
        // Observable reactive style properties
        property string mSurface: "#242424"
        property string mOnSurface: "#ffffff"
        property string mPrimary: "#ffffff"
        property string mOnPrimary: "#ffffff"
        property string mSurfaceVariant: "#303030"
        property string mError: "#ff7b63"

        function updateThemeFromFile(rawText) {
            function parse(key, fallback) {
                const pattern = new RegExp("^\\s*" + key + "\\s*=\\s*[\"']?(#[A-Fa-f0-9]{6})[\"']?", "m");
                const m = rawText.match(pattern);
                return m ? m[1] : fallback;
            }
            mSurface = parse("background", "#242424")
            mOnSurface = parse("foreground", "#ffffff")
            mPrimary = parse("accent", "#ffffff")
            mSurfaceVariant = parse("color0", "#303030")
            mError = parse("color1", "#ff7b63")
        }
    }
    // --- END AUTOMATED FILE WATCHER BACKEND ---

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

    // MAIN INTERACTION AREA
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

            // --- TOP SECTION (Workspaces) ---
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
                        layer.enabled: isActive || hoverArea.containsMouse
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
                            anchors.verticalCenterOffset: 0.25
                            text: {
                                if (parent.isActive) return "";
                                if (modelData.id === 6) return "\uf084";
                                if (modelData.id === 7) return "\uf001";
                                return modelData.id;
                            }
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

            // --- CENTER SECTION (Date) ---
            Item {
                width: 30
                height: 80
                anchors.centerIn: parent 
                
                Text {
                    id: dateLabel
                    anchors.centerIn: parent
                    rotation: 270
                    text: mainClock.date ? mainClock.date.toLocaleDateString(Qt.locale(), "ddd d") : "..."
                    color: theme.mOnSurface
                    opacity: 0.7
                    renderType: Text.QtRendering
                    font {
                        family: monoFont
                        pixelSize: 9
                        weight: Font.Regular
                    }
                }
            }

            // --- BOTTOM SECTION (Tools & Clock) ---
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
                        font { family: iconFont; pixelSize: 18 }
                        color: theme.mOnSurface
                        rotation: drawerOpen ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 250 } }
                    }
                    hoverArea.onClicked: drawerOpen = !drawerOpen
                }

                Column {
                    spacing: 2
                    clip: true
                    height: drawerOpen ? implicitHeight : 0
                    opacity: drawerOpen ? 1.0 : 0
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 250 } }

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
                        hoverArea.onClicked: autoHideEnabled = !autoHideEnabled
                    }
                }

                // --- CLOCK MODULE (HARD-ANCIENT COMPACT LAYOUT) ---
                FusionModule {
                    id: clockModule
                    property bool showSeconds: false
                    height: 40
                    border.width: 2
                    
                    hoverArea.onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            clockModule.showSeconds = !clockModule.showSeconds;
                        } else if (mouse.button === Qt.RightButton) {
                            Hyprland.dispatch("exec kitty --class=calendar-pwa -e sh -c 'cal -m; read -n 1'");
                        }
                    }

                    // Properties to break down time segments into stable strings
                    property string topString: {
                        if (!mainClock.date) return "--";
                        return showSeconds 
                            ? mainClock.date.getMinutes().toString().padStart(2, '0')
                            : (mainClock.date.getHours() % 12 || 12).toString().padStart(2, '0');
                    }

                    property string bottomString: {
                        if (!mainClock.date) return "--";
                        return showSeconds 
                            ? mainClock.date.getSeconds().toString().padStart(2, '0')
                            : mainClock.date.getMinutes().toString().padStart(2, '0');
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: -1

                        // TOP LINE Container (Locked width ensures no horizontal shifting)
                        Row {
                            width: 18
                            height: 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                width: 9
                                horizontalAlignment: Text.AlignHCenter
                                color: theme.mPrimary
                                renderType: Text.QtRendering
                                text: clockModule.topString.charAt(0)
                                font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                            }
                            Text {
                                width: 9
                                horizontalAlignment: Text.AlignHCenter
                                color: theme.mPrimary
                                renderType: Text.QtRendering
                                text: clockModule.topString.charAt(1)
                                font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                            }
                        }

                        // BOTTOM LINE Container (Locked width ensures no horizontal shifting)
                        Row {
                            width: 18
                            height: 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                width: 9
                                horizontalAlignment: Text.AlignHCenter
                                color: clockModule.showSeconds ? theme.mError : theme.mOnSurface
                                renderType: Text.QtRendering
                                text: clockModule.bottomString.charAt(0)
                                font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                            }
                            Text {
                                width: 9
                                horizontalAlignment: Text.AlignHCenter
                                color: clockModule.showSeconds ? theme.mError : theme.mOnSurface
                                renderType: Text.QtRendering
                                text: clockModule.bottomString.charAt(1)
                                font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                            }
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
                    hoverArea.onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            Hyprland.dispatch("exec pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.MiddleButton) {
                            Hyprland.dispatch("exec " + homeDir + "/.config/hypr/scripts/f-reload.sh");
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

    SystemClock { 
        id: mainClock; 
        precision: clockModule.showSeconds ? SystemClock.Seconds : SystemClock.Minutes 
    }
}
