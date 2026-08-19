/* C-Shell-Fusion v8.7 [j5onrf] - Clean Geometric Dock */

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

    // --- RELIABLE BREADCRUMB TRACKER ---
    readonly property int currentWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property int previousWsId: -1
    property int _lastActiveId: 1

    onCurrentWsIdChanged: {
        if (currentWsId !== _lastActiveId) {
            previousWsId = _lastActiveId;
            _lastActiveId = currentWsId;
        }
    }

    // --- DYNAMIC INTERACTION MASK ---
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

    // TOP BUTTON: Direct Main / Root Menu
    function toggleAppMenu() {
        Quickshell.execDetached(["omarchy", "menu", "toggle", "root"]);
    }

    // BOTTOM BUTTON: Direct System / Power Menu
    function togglePowerMenu() {
        Quickshell.execDetached(["omarchy", "menu", "toggle", "system"]);
    }

    // Workspace switch handler
    function switchToWorkspace(wsId) {
        if (wsId !== currentWsId) {
            previousWsId = currentWsId;
            _lastActiveId = wsId;
        }
        try {
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })");
        } catch (e) {}
        try {
            Hyprland.dispatch("workspace " + wsId);
        } catch (e) {}
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wsId.toString()]);
    }

    // --- PERSISTENT AUTOHIDE STATE LOADER ---
    Process {
        id: autohideStateReader
        command: ["sh", "-c", "cat ~/.config/quickshell/shell-fusion/.autohide_state 2>/dev/null || echo 0"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const val = this.text.trim();
                cShellFusion.autoHideEnabled = (val === "1" || val === "true");
            }
        }
    }

    // Force read on startup & on every theme poll
    Component.onCompleted: {
        autohideStateReader.running = true;
    }

    // --- RELIABLE OMARCHY THEME READER ---
    Process {
        id: themeReader
        command: [
            "sh", "-c",
            "cat ~/.config/omarchy/current/theme/colors.toml 2>/dev/null || cat ~/.local/state/omarchy/current/theme/colors.toml 2>/dev/null"
        ]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (dynamicColorsEnabled && this.text.trim() !== "") {
                    theme.updateThemeFromFile(this.text);
                }
            }
        }
    }

    Timer {
        id: themePollTimer
        interval: 2000
        repeat: true
        running: dynamicColorsEnabled
        triggeredOnStart: true
        onTriggered: {
            if (!themeReader.running) themeReader.running = true;
            if (!autohideStateReader.running) autohideStateReader.running = true;
        }
    }

    QtObject {
        id: theme
        // --- 1. HARDCODED ADWAITA BASE (NEVER CHANGES WITH THEMES) ---
        readonly property string mSurface: "#242424"          // Dock background
        readonly property string mButtonSurface: "#2e2e2e"    // Button idle surface
        readonly property string mSurfaceVariant: "#383838"   // Button hover surface
        readonly property color mButtonBorder: "#4a4a4a"      // Button 1px solid border
        readonly property color mButtonBorderHover: "#ffffff" // Button hover border

        // --- 2. DYNAMIC THEME ACCENTS (ONLY THESE UPDATE WITH THEMES) ---
        property string mPrimary: "#ffffff"                   // Theme accent (active bubble & highlights)
        property string mOnSurface: "#ffffff"                 // Theme foreground (icons & text)
        property string mOnPrimary: "#121212"                 // Active bubble text
        property string mError: "#ff7b63"                     // Alerts / Mute

        function resetToDefaults() {
            mPrimary = "#ffffff"
            mOnSurface = "#ffffff"
            mOnPrimary = "#121212"
            mError = "#ff7b63"
        }

        function updateThemeFromFile(rawText) {
            if (!rawText || !dynamicColorsEnabled) return;
            function parse(key, fallback) {
                const pattern = new RegExp("^\\s*" + key + "\\s*=\\s*[\"']?(#[A-Fa-f0-9]{3,8})[\"']?", "m");
                const m = rawText.match(pattern);
                return m ? m[1] : fallback;
            }
            // ONLY icons, text, and active highlights change:
            mPrimary = parse("accent", "#ffffff");
            mOnSurface = parse("foreground", "#ffffff");
            mError = parse("color1", "#ff7b63");
        }
    }

    // --- GEOMETRIC MODULE COMPONENT (radius: 6) ---
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
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }

        MouseArea {
            id: mArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
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
            x: (autoHideEnabled && !isHovered) ? -34 : 0
            
            Behavior on x {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            Behavior on y {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
            
            // Clean unbordered matte dock surface
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

                // 1. TOP BUTTON: Omarchy App Menu Launcher
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
                            runCmd("kitty --class=sys-monitor -e btop");
                        } else {
                            toggleAppMenu();
                        }
                    }
                }

                // Low-Memory Memoized Workspaces (Zero Garbage Collection Churn)
                readonly property var baseWorkspaces: [1, 2, 3, 4, 5]
                readonly property var dynamicWorkspaces: {
                    let hasExtra = false;
                    const extra = [];
                    for (let i = 6; i <= 10; i++) {
                        const isActive = cShellFusion.currentWsId === i;
                        const isOccupied = Hyprland.toplevels?.values ? Hyprland.toplevels.values.some(t => t.workspace?.id === i) : false;
                        if (isActive || isOccupied) {
                            hasExtra = true;
                            extra.push(i);
                        }
                    }
                    return hasExtra ? baseWorkspaces.concat(extra) : baseWorkspaces;
                }

                // 2. Workspaces List
                Repeater {
                    model: workspaceColumn.dynamicWorkspaces
                    delegate: FusionModule {
                        id: wsModule
                        required property int modelData
                        readonly property int wsId: modelData
                        
                        readonly property var wsObj: Hyprland.workspaces.values.find(w => w && w.id === wsId)
                        readonly property bool isActive: cShellFusion.currentWsId === wsId
                        
                        // Workspace Occupied Check
                        readonly property bool isOccupied: {
                            try {
                                return Hyprland.toplevels.values.some(t => t.workspace && t.workspace.id === wsId);
                            } catch (e) {
                                return wsObj !== undefined;
                            }
                        }
                        
                        // Breadcrumb only activates if previous workspace has active windows
                        readonly property bool isBreadcrumb: cShellFusion.previousWsId === wsId && !isActive && isOccupied

                        radius: 6
                        color: hoverArea.containsMouse ? theme.mSurfaceVariant : theme.mButtonSurface
                        border.color: hoverArea.containsMouse ? theme.mButtonBorderHover : theme.mButtonBorder
                        border.width: 1

                        // Smaller Inset Active Indicator (24x24 centered)
                        Rectangle {
                            visible: wsModule.isActive
                            width: 18
                            height: 18
                            radius: 5
                            color: theme.mPrimary
                            anchors.centerIn: parent
                            z: 0
                        }

                        // SINGLE BREADCRUMB DOT (Smaller 2.5px)
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

                        // Dynamic Number with Theme-Proof Opacity & Weight
                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 0.50
                            text: wsModule.isActive ? "" : wsId.toString()
                            renderType: Text.QtRendering
                            color: wsModule.isActive ? theme.mOnPrimary : (wsModule.isOccupied ? theme.mPrimary : theme.mOnSurface)
                            
                            // Theme-proof: 1.0 for occupied, 0.35 faded for empty
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
                        property string displayStr: ""
                        property int rawUsage: displayStr ? parseInt(displayStr) : 0

                        Process {
                            id: cpuUsageRunner
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

                    // Clipboard Module
                    FusionModule {
                        Text {
                            anchors.centerIn: parent
                            text: "\ue14f"
                            renderType: Text.QtRendering
                            color: parent.hoverArea.containsMouse ? theme.mPrimary : theme.mOnSurface
                            font { family: iconFont; pixelSize: 20 }
                        }
                        hoverArea.onClicked: runCmd("omarchy-shell shell toggle omarchy.clipboard")
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
                        hoverArea.onClicked: runCmd("omarchy-toggle-nightlight")
                    }

                    // Autohide Toggle (Saves state on click)
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
                            runCmd("mkdir -p ~/.config/quickshell/shell-fusion && echo '" + (autoHideEnabled ? "1" : "0") + "' > ~/.config/quickshell/shell-fusion/.autohide_state");
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
                            togglePowerMenu();
                        } else if (mouse.button === Qt.RightButton) {
                            powerVolModule.isMuted = !powerVolModule.isMuted;
                            runCmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle");
                        } else if (mouse.button === Qt.MiddleButton) {
                            dynamicColorsEnabled = !dynamicColorsEnabled;
                            if (dynamicColorsEnabled) {
                                if (!themeReader.running) themeReader.running = true;
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
        id: mainClock; 
        precision: clockModule.showSeconds ? SystemClock.Seconds : SystemClock.Minutes 
    }
}
