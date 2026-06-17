/* C-Shell-Fusion v7.8 [j5onrf] */

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland 
import QtQuick

PanelWindow {
    id: cShellFusion

    WlrLayershell.namespace: "c-shell-fusion"
    WlrLayershell.layer: WlrLayer.Top
    
    exclusiveZone: autoHideEnabled ? 0 : 34

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string omarchyConfig: homeDir + "/.config/omarchy/current/theme/colors.toml"

    anchors {
        left: true
        top: true
        bottom: true
    }
    
    // Kept static at 34 to avoid costly Wayland surface resizes.
    // The active interaction area is managed dynamically by the input mask.
    implicitWidth: 34
    color: "transparent"

    property bool autoHideEnabled: false
    
    // Declarative state binding: tracks the mouse via native observers
    readonly property bool isHovered: mainMouseArea.containsMouse
    property bool drawerOpen: false

    // --- DYNAMIC INTERACTION MASK ---
    // Defines the active input/hover region. Clicks outside of this mask
    // pass directly through to underlying application windows.
    Item {
        id: interactionMask
        width: (autoHideEnabled && !isHovered) ? 2 : 34
        height: slidingContent ? slidingContent.height : 0
        y: slidingContent ? slidingContent.y : 0
        x: 0
    }

    mask: Region {
        item: interactionMask
    }

    readonly property string iconFont: "Material Symbols Rounded"
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    // --- OMARCHY COMPATIBLE SHELL RUNNER ---
    function runCmd(cmdStr) {
        Quickshell.execDetached(["sh", "-c", cmdStr]);
    }

    // --- AUTOMATED FILE WATCHER BACKEND ---
    // Restored exactly as originally written to properly handle FileView's text() function.
    FileView {
        id: colorFileSource
        path: omarchyConfig
        
        onTextChanged: {
            const rawText = (typeof text === "function") ? text() : text;
            if (rawText) {
                theme.updateThemeFromFile(rawText);
            }
        }
    }

    QtObject {
        id: theme
        
        property string mSurface: "#242424"
        property string mOnSurface: "#ffffff"
        property string mPrimary: "#ffffff"
        property string mOnPrimary: "#ffffff"
        property string mSurfaceVariant: "#303030"
        property string mError: "#ff7b63"

        // Restored exactly as originally written to preserve local regex scope parsing.
        function updateThemeFromFile(rawText) {
            if (!rawText) return;
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
        id: mainMouseArea
        anchors.fill: parent
        hoverEnabled: true

        Rectangle {
            id: slidingContent
            width: 34
            
            // Dynamic sizing height for the container pill
            height: workspaceColumn.implicitHeight + dateItem.height + toolsColumn.implicitHeight + 32
            radius: 10
            
            // Calculate stationary height (workspaces + date + non-drawer tools + padding)
            readonly property int stationaryHeight: workspaceColumn.implicitHeight + dateItem.height + 94 + 32

            // Center the stationary bar safely on the vertical axis
            y: Math.max(8, (parent.height - stationaryHeight) / 2)
            x: (autoHideEnabled && !isHovered) ? -34 : 0
            
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
            color: theme.mSurface

            // --- TOP SECTION (Workspaces) ---
            Column {
                id: workspaceColumn
                anchors {
                    top: parent.top
                    topMargin: 8
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
                    hoverArea.onClicked: {
                        if (mouse.button === Qt.RightButton) {
                            runCmd("kitty --class=sys-monitor -e btop");
                        } else {
                            runCmd("omarchy-menu");
                        }
                    }
                }

                Repeater {
                    model: Hyprland.workspaces
                    FusionModule {
                        layer.enabled: isActive || hoverArea.containsMouse
                        required property var modelData
                        
                        // ID integer comparison avoids dynamic dangling pointer issues in the engine
                        property bool isActive: {
                            if (!modelData || !Hyprland.focusedWorkspace) return false;
                            try {
                                return modelData.id === Hyprland.focusedWorkspace.id;
                            } catch (e) {
                                return false;
                            }
                        }

                        property bool isOccupied: {
                            if (!modelData) return false;
                            try {
                                const wsId = modelData.id;
                                return Hyprland.toplevels.values.some(t => t.workspace && t.workspace.id === wsId);
                            } catch (e) {
                                return false;
                            }
                        }

                        radius: hoverArea.containsMouse ? 15 : (isActive ? 12 : 8)
                        color: isActive ? theme.mPrimary : (hoverArea.containsMouse ? theme.mSurfaceVariant : theme.mSurface)

                        Rectangle {
                            visible: {
                                try {
                                    return parent.isOccupied && !parent.isActive;
                                } catch (e) {
                                    return false;
                                }
                            }
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
                            anchors.verticalCenterOffset: 0.50
                            text: {
                                if (parent.isActive) return "";
                                if (!modelData) return "";
                                try {
                                    if (modelData.id === 9) return "\uf084";
                                    if (modelData.id === 10) return "\uf001";
                                    return modelData.id;
                                } catch (e) {
                                    return "";
                                }
                            }
                            renderType: Text.QtRendering
                            color: parent.isActive ? theme.mOnPrimary : theme.mOnSurface
                            font {
                                family: monoFont
                                weight: Font.DemiBold
                                pixelSize: {
                                    try {
                                        return (modelData && (modelData.id === 9 || modelData.id === 10)) ? 20 : 17;
                                    } catch (e) {
                                        return 17;
                                    }
                                }
                            }
                        }
                        hoverArea.onClicked: {
                            if (modelData) {
                                try {
                                    // Utilizes Quickshell's native C++ Wayland/Hyprland IPC connection
                                    modelData.activate();
                                } catch (e) {
                                    // Robust fallback to manual process execution if binding fails
                                    runCmd("hyprctl dispatch workspace " + modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // --- CENTER SECTION (Date) ---
            Item {
                id: dateItem
                width: 30
                height: 80
                anchors {
                    top: workspaceColumn.bottom
                    topMargin: 8
                    horizontalCenter: parent.horizontalCenter
                }
                
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
                id: toolsColumn
                anchors {
                    top: dateItem.bottom
                    topMargin: 8
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

                    // --- REALTIME CPU LOOP MODULE ---
                    FusionModule {
                        id: cpuModule
                        property bool showUsage: false
                        property string displayStr: ""
                        property int rawUsage: displayStr ? parseInt(displayStr) : 0

                        Process {
                            id: cpuUsageRunner
                            // Optimized: Uses built-in POSIX shell arithmetic to parse /proc/stat
                            command: [
                                "sh", "-c", 
                                "read -r _ u1 n1 s1 i1 io1 ir1 si1 st1 _ < /proc/stat; sleep 0.2; read -r _ u2 n2 s2 i2 io2 ir2 si2 st2 _ < /proc/stat; t1=$((u1+n1+s1+i1+io1+ir1+si1+st1)); t2=$((u2+n2+s2+i2+io2+ir2+si2+st2)); id=$((i2-i1)); total=$((t2-t1)); [ $total -le 0 ] && echo 0 || echo $(( (total - id) * 100 / total ))"
                            ]
                            running: false
                            stdout: StdioCollector {
                                onStreamFinished: cpuModule.displayStr = this.text.trim();
                            }
                        }

                        Timer {
                            id: cpuTicker
                            interval: 2000
                            repeat: true
                            running: cpuModule.showUsage
                            onTriggered: {
                                if (!cpuUsageRunner.running) cpuUsageRunner.running = true;
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            renderType: Text.QtRendering
                            
                            color: {
                                if (parent.hoverArea.containsMouse) return theme.mPrimary;
                                if (!cpuModule.showUsage) return theme.mOnSurface;
                                
                                if (cpuModule.rawUsage >= 80) return theme.mError;          
                                if (cpuModule.rawUsage >= 40) return theme.mPrimary;        
                                return theme.mOnSurface;                                    
                            }
                            
                            text: cpuModule.showUsage 
                                ? (cpuModule.displayStr ? cpuModule.displayStr.padStart(2, '0') : "00") 
                                : "\ue322"
                            
                            font {
                                family: cpuModule.showUsage ? monoFont : iconFont
                                pixelSize: cpuModule.showUsage ? 15 : 20
                                weight: Font.DemiBold
                            }
                        }

                        hoverArea.onClicked: {
                            cpuModule.showUsage = !cpuModule.showUsage;
                            if (cpuModule.showUsage) {
                                cpuModule.displayStr = "";
                                if (!cpuUsageRunner.running) cpuUsageRunner.running = true;
                            }
                        }
                    }

                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: "\ue14f"
                            renderType: Text.QtRendering
                            color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                            font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: runCmd("walker -m clipboard")
                    }
                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: "\ue3a9"
                            renderType: Text.QtRendering
                            color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                            font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: runCmd("omarchy-toggle-nightlight")
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

                // --- CLOCK MODULE ---
                FusionModule {
                    id: clockModule
                    property bool showSeconds: false
                    height: 40
                    border.width: 2
                    
                    hoverArea.onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            clockModule.showSeconds = !clockModule.showSeconds;
                        } else if (mouse.button === Qt.RightButton) {
                            runCmd("kitty --class=calendar-pwa -e sh -c 'cal -s; read -n 1'");
                        }
                    }

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
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        spacing: 0

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
                                text: clockModule.bottomString.charAt(1)
                                font { weight: Font.DemiBold; pixelSize: 15; family: monoFont }
                            }
                        }
                    }
                }

                // --- POWER / VOLUME MODULE ---
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
                    
                    hoverArea.onClicked: {
                        if (mouse.button === Qt.RightButton) {
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            runCmd("pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.MiddleButton) {
                            runCmd(homeDir + "/.config/hypr/scripts/f-reload.sh");
                        } else {
                            runCmd("omarchy-menu");
                        }
                    }
                    hoverArea.onWheel: {
                        runCmd("pactl set-sink-volume @DEFAULT_SINK@ " + (wheel.angleDelta.y > 0 ? "+5%" : "-5%"));
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
