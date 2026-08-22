/* C-Shell Precision — Left Rail Dock v0.9.2 [Hook-Driven Theme Sync] */

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland 
import QtQuick

PanelWindow {
    id: cShellFusion

    WlrLayershell.namespace: "c-shell-fusion"
    WlrLayershell.layer: WlrLayer.Top
    
    // Always 0 to prevent Hyprland from locking window margins
    exclusiveZone: 0

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
    
    implicitWidth: 34
    color: "transparent"

    property bool autoHideEnabled: false
    property bool dynamicColorsEnabled: true
    readonly property bool isHovered: panelHoverArea.containsMouse
    property bool drawerOpen: false

    // --- BREADCRUMB TRACKER ---
    readonly property int currentWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property int previousWsId: -1
    property int _lastActiveId: 1

    onCurrentWsIdChanged: {
        if (currentWsId !== _lastActiveId) {
            previousWsId = _lastActiveId;
            _lastActiveId = currentWsId;
        }
    }

    // --- INTERACTION MASK ---
    Item {
        id: interactionMask
        x: 0
        y: (autoHideEnabled && !isHovered) ? 0 : (slidingContent ? slidingContent.y : 0)
        width: (autoHideEnabled && !isHovered) ? 4 : 34
        height: (autoHideEnabled && !isHovered) ? cShellFusion.height : (slidingContent ? slidingContent.height : 0)
    }

    mask: Region {
        item: interactionMask
    }

    readonly property string iconFont: "Material Symbols Rounded"
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    function runCmd(cmdStr) {
        Quickshell.execDetached(["sh", "-c", cmdStr]);
    }

    // UNIVERSAL WORKSPACE SWITCHER
    function switchToWorkspace(wsId) {
        if (wsId !== currentWsId) {
            previousWsId = currentWsId;
            _lastActiveId = wsId;
        }
        try {
            Hyprland.dispatch("workspace " + wsId);
        } catch(e) {}
        try {
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })");
        } catch(e) {}
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wsId.toString()]);
    }

    // --- ONE-TIME AUTOHIDE LOADER ON STARTUP ---
    Process {
        id: autohideStateReader
        command: ["sh", "-c", "cat ~/.cache/c-shell/.autohide_state 2>/dev/null || echo 0"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const val = this.text.trim();
                cShellFusion.autoHideEnabled = (val === "1" || val === "true");
            }
        }
    }

    // --- ONE-TIME THEME LOADER ON STARTUP / RELOAD HOOK ---
    Process {
        id: themeReader
        command: [
            "sh", "-c",
            "cat ~/.config/omarchy/current/theme/colors.toml 2>/dev/null || cat ~/.local/state/omarchy/current/theme/colors.toml 2>/dev/null"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (dynamicColorsEnabled && this.text && this.text.trim() !== "") {
                    theme.updateThemeFromFile(this.text);
                }
            }
        }
    }

    QtObject {
        id: theme
        // --- 1. HARDCODED ADWAITA BASE ---
        readonly property string mSurface: "#242424"          // Dock background
        readonly property string mButtonSurface: "#2e2e2e"    // Button idle surface
        readonly property string mSurfaceVariant: "#383838"   // Button hover surface
        readonly property color mButtonBorder: "#4a4a4a"      // Button 1px border
        readonly property color mButtonBorderHover: "#ffffff" // Button hover border

        // --- 2. DYNAMIC THEME ACCENTS ---
        property string mPrimary: "#ffffff"
        property string mOnSurface: "#ffffff"
        property string mOnPrimary: "#121212"
        property string mError: "#ff7b63"

        function resetToDefaults() {
            mPrimary = "#ffffff";
            mOnSurface = "#ffffff";
            mOnPrimary = "#121212";
            mError = "#ff7b63";
        }

        function updateThemeFromFile(rawText) {
            if (!rawText || !dynamicColorsEnabled) return;
            function parse(key, fallback) {
                const pattern = new RegExp("^\\s*" + key + "\\s*=\\s*[\"']?(#[A-Fa-f0-9]{3,8})[\"']?", "m");
                const m = rawText.match(pattern);
                return m ? m[1] : fallback;
            }
            mPrimary = parse("accent", "#ffffff");
            mOnSurface = parse("foreground", "#ffffff");
            mError = parse("color1", "#ff7b63");
        }
    }

    component FusionModule: Rectangle {
        property alias hoverArea: mArea
        width: 30
        height: 30
        radius: 6
        anchors.horizontalCenter: parent.horizontalCenter
        color: mArea.containsMouse ? theme.mSurfaceVariant : theme.mButtonSurface
        
        border {
            color: mArea.containsMouse ? theme.mButtonBorderHover : theme.mButtonBorder
            width: 1
        }
        
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: mArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    // MAIN HOVER SENSOR
    MouseArea {
        id: panelHoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        Rectangle {
            id: slidingContent
            width: 34
            
            height: workspaceColumn.implicitHeight + dateItem.height + toolsColumn.implicitHeight + 20
            radius: 6
            
            readonly property int stationaryHeight: workspaceColumn.implicitHeight + dateItem.height + 94 + 20

            y: Math.max(8, (parent.height - stationaryHeight) / 2)
            x: (autoHideEnabled && !isHovered) ? -32 : 0
            
            Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            
            color: theme.mSurface

            // --- TOP SECTION (Workspaces & App Menu) ---
            Column {
                id: workspaceColumn
                anchors {
                    top: parent.top
                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 2

                // 1. TOP BUTTON: App Menu
                FusionModule {
                    height: 30
                    Text {
                        anchors {
                            top: parent.top
                            topMargin: 2
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: "\ue5d3"
                        color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                        renderType: Text.QtRendering
                        font {
                            family: iconFont
                            pixelSize: 22
                        }
                    }
                    hoverArea.onClicked: {
                        if (mouse.button === Qt.RightButton) {
                            runCmd("kitty --class=sys-monitor -e btop 2>/dev/null || btop &");
                        } else {
                            runCmd("omarchy menu toggle root 2>/dev/null || rofi -show drun || wofi --show drun");
                        }
                    }
                }

                // 1-5 persistent, 6-10 on demand
                readonly property var baseWorkspaces: [1, 2, 3, 4, 5]
                readonly property var dynamicWorkspaces: {
                    let hasExtra = false;
                    const extra = [];
                    for (let i = 6; i <= 10; i++) {
                        const isActive = cShellFusion.currentWsId === i;
                        let isOccupied = false;
                        try {
                            isOccupied = Hyprland.toplevels.values.some(t => t.workspace && t.workspace.id === i);
                        } catch(e) {}
                        if (isActive || isOccupied) {
                            hasExtra = true;
                            extra.push(i);
                        }
                    }
                    return hasExtra ? baseWorkspaces.concat(extra) : baseWorkspaces;
                }

                // 2. Workspaces Repeater
                Repeater {
                    model: workspaceColumn.dynamicWorkspaces
                    delegate: FusionModule {
                        id: wsModule
                        required property int modelData
                        readonly property int wsId: modelData
                        
                        readonly property bool isActive: cShellFusion.currentWsId === wsId
                        
                        readonly property bool isOccupied: {
                            try {
                                return Hyprland.toplevels.values.some(t => t.workspace && t.workspace.id === wsId);
                            } catch (e) {
                                const wsObj = Hyprland.workspaces.values.find(w => w && w.id === wsId);
                                return wsObj !== undefined;
                            }
                        }
                        
                        readonly property bool isBreadcrumb: cShellFusion.previousWsId === wsId && !isActive && isOccupied

                        radius: 6
                        color: hoverArea.containsMouse ? theme.mSurfaceVariant : theme.mButtonSurface
                        border.color: hoverArea.containsMouse ? theme.mButtonBorderHover : theme.mButtonBorder
                        border.width: 1

                        // Active Indicator Bubble
                        Rectangle {
                            visible: wsModule.isActive
                            width: 18
                            height: 18
                            radius: 5
                            color: theme.mPrimary
                            anchors.centerIn: parent
                            z: 0
                        }

                        // Breadcrumb Dot
                        Rectangle {
                            visible: wsModule.isBreadcrumb
                            width: 2.5
                            height: 2.5
                            radius: 1.25
                            color: theme.mPrimary
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 2.5
                            z: 2
                        }

                        // Workspace Number
                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 0.50
                            text: wsModule.isActive ? "" : wsId.toString()
                            renderType: Text.QtRendering
                            color: wsModule.isActive ? theme.mOnPrimary : (wsModule.isOccupied ? theme.mPrimary : theme.mOnSurface)
                            
                            opacity: {
                                if (wsModule.isActive) return 1.0;
                                if (hoverArea.containsMouse) return 1.0;
                                if (wsModule.isOccupied) return 1.0;
                                return 0.35;
                            }
                            
                            font {
                                family: monoFont
                                weight: (wsModule.isActive || wsModule.isOccupied) ? Font.Bold : Font.Normal
                                pixelSize: 17
                            }

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        hoverArea.onClicked: {
                            switchToWorkspace(wsId);
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

            // --- BOTTOM SECTION (Tools, Drawer, Clock & Power) ---
            Column {
                id: toolsColumn
                anchors {
                    top: dateItem.bottom
                    topMargin: 8
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 2

                // Drawer Toggle Arrow
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

                // Expandable Drawer
                Column {
                    spacing: 2
                    clip: true
                    height: drawerOpen ? implicitHeight : 0
                    opacity: drawerOpen ? 1.0 : 0
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 250 } }

                    // CPU Module
                    FusionModule {
                        id: cpuModule
                        property bool showUsage: false
                        property int rawUsage: 0
                        property real prevIdle: 0
                        property real prevTotal: 0

                        Process {
                            id: cpuUsageRunner
                            command: ["sh", "-c", "head -n 1 /proc/stat"]
                            running: false
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    const parts = this.text.trim().split(/\s+/).slice(1).map(Number);
                                    if (parts.length >= 4) {
                                        const idle = parts[3] + (parts[4] || 0);
                                        const total = parts.reduce((a, b) => a + b, 0);
                                        if (cpuModule.prevTotal > 0) {
                                            const totalDiff = total - cpuModule.prevTotal;
                                            const idleDiff = idle - cpuModule.prevIdle;
                                            cpuModule.rawUsage = totalDiff > 0 ? Math.round(((totalDiff - idleDiff) / totalDiff) * 100) : 0;
                                        }
                                        cpuModule.prevIdle = idle;
                                        cpuModule.prevTotal = total;
                                    }
                                }
                            }
                        }

                        Timer {
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
                            
                            text: cpuModule.showUsage ? cpuModule.rawUsage.toString().padStart(2, '0') : "\ue322"
                            
                            font {
                                family: cpuModule.showUsage ? monoFont : iconFont
                                pixelSize: cpuModule.showUsage ? 15 : 20
                                weight: Font.DemiBold
                            }
                        }

                        hoverArea.onClicked: {
                            cpuModule.showUsage = !cpuModule.showUsage;
                            if (cpuModule.showUsage && !cpuUsageRunner.running) {
                                cpuUsageRunner.running = true;
                            }
                        }
                    }

                    // Clipboard Module
                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: "\ue14f"
                            renderType: Text.QtRendering
                            color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                            font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: runCmd("omarchy-shell shell toggle omarchy.clipboard 2>/dev/null || cliphist list | rofi -dmenu | cliphist decode | wl-copy")
                    }

                    // Nightlight Toggle
                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: "\ue3a9"
                            renderType: Text.QtRendering
                            color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                            font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: runCmd("omarchy-toggle-nightlight 2>/dev/null || wlsunset -T 4000 &")
                    }

                    // Autohide Toggle (Saves state)
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
                            runCmd("mkdir -p ~/.cache/c-shell && echo '" + (autoHideEnabled ? "1" : "0") + "' > ~/.cache/c-shell/.autohide_state");
                        }
                    }
                }

                // Clock Module
                FusionModule {
                    id: clockModule
                    property bool showSeconds: false
                    height: 40
                    border.width: 1
                    
                    hoverArea.onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            clockModule.showSeconds = !clockModule.showSeconds;
                        } else if (mouse.button === Qt.RightButton) {
                            runCmd("kitty --class=calendar-pwa -e sh -c 'cal -s; read -n 1' 2>/dev/null || cal");
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

                // 3. BOTTOM BUTTON: Power Menu & Audio Controls
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
                        if (mouse.button === Qt.LeftButton) {
                            runCmd("omarchy menu toggle system 2>/dev/null || wlogout");
                        } else if (mouse.button === Qt.RightButton) {
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            runCmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.MiddleButton) {
                            // On-demand reload via themeReader
                            dynamicColorsEnabled = !dynamicColorsEnabled;
                            if (dynamicColorsEnabled) {
                                themeReader.running = true;
                            } else {
                                theme.resetToDefaults();
                            }
                        }
                    }
                    hoverArea.onWheel: {
                        runCmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (wheel.angleDelta.y > 0 ? "5%+" : "5%-") + " 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ " + (wheel.angleDelta.y > 0 ? "+5%" : "-5%"));
                        if (wheel.angleDelta.y > 0 && powerVolModule.isMuted) powerVolModule.isMuted = false;
                    }
                }
            }
        }
    }

    SystemClock { 
        id: mainClock 
        precision: clockModule.showSeconds ? SystemClock.Seconds : SystemClock.Minutes 
    }
}
