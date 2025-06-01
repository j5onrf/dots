#!/bin/bash

# --- Configuration ---
CSS_FILE_TO_PARSE="$HOME/.config/waybar/colors.css"
VSCODIUM_SETTINGS_FILE="$HOME/.config/VSCodium/User/settings.json"

# --- Sanity Checks ---
if [ ! -f "$CSS_FILE_TO_PARSE" ]; then
    echo "Error: CSS file not found at $CSS_FILE_TO_PARSE"
    exit 1
fi
if ! command -v jq &> /dev/null; then echo "Error: jq is not installed."; exit 1; fi
if ! command -v awk &> /dev/null; then echo "Error: awk is not installed."; exit 1; fi

# --- Helper function to extract colors ---
get_color_from_css() {
    local color_name_to_find="$1"
    awk -v name="$color_name_to_find" '$1 == "@define-color" && $2 == name {gsub(/#|;/, "", $3); print $3; exit}' "$CSS_FILE_TO_PARSE"
}

# --- Comprehensive Color Extraction ---
echo "DEBUG: Comprehensive Color Extraction Starting..."

BACKGROUND=$(get_color_from_css "background")
ERROR=$(get_color_from_css "error")
ERROR_CONTAINER=$(get_color_from_css "error_container")
INVERSE_ON_SURFACE=$(get_color_from_css "inverse_on_surface")
INVERSE_PRIMARY=$(get_color_from_css "inverse_primary")
INVERSE_SURFACE=$(get_color_from_css "inverse_surface")
ON_BACKGROUND=$(get_color_from_css "on_background")
ON_ERROR=$(get_color_from_css "on_error")
ON_ERROR_CONTAINER=$(get_color_from_css "on_error_container")
ON_PRIMARY=$(get_color_from_css "on_primary")
ON_PRIMARY_CONTAINER=$(get_color_from_css "on_primary_container")
ON_PRIMARY_FIXED=$(get_color_from_css "on_primary_fixed")
ON_PRIMARY_FIXED_VARIANT=$(get_color_from_css "on_primary_fixed_variant")
ON_SECONDARY=$(get_color_from_css "on_secondary")
ON_SECONDARY_CONTAINER=$(get_color_from_css "on_secondary_container")
ON_SECONDARY_FIXED=$(get_color_from_css "on_secondary_fixed")
ON_SECONDARY_FIXED_VARIANT=$(get_color_from_css "on_secondary_fixed_variant")
ON_SURFACE=$(get_color_from_css "on_surface")
ON_SURFACE_VARIANT=$(get_color_from_css "on_surface_variant")
ON_TERTIARY=$(get_color_from_css "on_tertiary")
ON_TERTIARY_CONTAINER=$(get_color_from_css "on_tertiary_container")
ON_TERTIARY_FIXED=$(get_color_from_css "on_tertiary_fixed")
ON_TERTIARY_FIXED_VARIANT=$(get_color_from_css "on_tertiary_fixed_variant")
OUTLINE=$(get_color_from_css "outline")
OUTLINE_VARIANT=$(get_color_from_css "outline_variant")
PRIMARY=$(get_color_from_css "primary")
PRIMARY_CONTAINER=$(get_color_from_css "primary_container")
PRIMARY_FIXED=$(get_color_from_css "primary_fixed")
PRIMARY_FIXED_DIM=$(get_color_from_css "primary_fixed_dim")
SCRIM=$(get_color_from_css "scrim")
SECONDARY=$(get_color_from_css "secondary")
SECONDARY_CONTAINER=$(get_color_from_css "secondary_container")
SECONDARY_FIXED=$(get_color_from_css "secondary_fixed")
SECONDARY_FIXED_DIM=$(get_color_from_css "secondary_fixed_dim")
SHADOW=$(get_color_from_css "shadow")
SOURCE_COLOR=$(get_color_from_css "source_color") # Likely not used in VSCodium theme directly
SURFACE=$(get_color_from_css "surface")
SURFACE_BRIGHT=$(get_color_from_css "surface_bright")
SURFACE_CONTAINER=$(get_color_from_css "surface_container")
SURFACE_CONTAINER_HIGH=$(get_color_from_css "surface_container_high")
SURFACE_CONTAINER_HIGHEST=$(get_color_from_css "surface_container_highest")
SURFACE_CONTAINER_LOW=$(get_color_from_css "surface_container_low")
SURFACE_CONTAINER_LOWEST=$(get_color_from_css "surface_container_lowest")
SURFACE_DIM=$(get_color_from_css "surface_dim")
SURFACE_TINT=$(get_color_from_css "surface_tint") # Often same as primary, used for tinting surfaces
SURFACE_VARIANT=$(get_color_from_css "surface_variant")
TERTIARY=$(get_color_from_css "tertiary")
TERTIARY_CONTAINER=$(get_color_from_css "tertiary_container")
TERTIARY_FIXED=$(get_color_from_css "tertiary_fixed")
TERTIARY_FIXED_DIM=$(get_color_from_css "tertiary_fixed_dim")

# --- Comprehensive Debug Output ---
echo "-----------------------------------------------------"
echo "COMPREHENSIVE DEBUG - Values for JSON construction:"
echo "-----------------------------------------------------"
echo "BACKGROUND: '${BACKGROUND}'"
echo "ERROR: '${ERROR}'"
echo "ERROR_CONTAINER: '${ERROR_CONTAINER}'"
echo "INVERSE_ON_SURFACE: '${INVERSE_ON_SURFACE}'"
echo "INVERSE_PRIMARY: '${INVERSE_PRIMARY}'"
echo "INVERSE_SURFACE: '${INVERSE_SURFACE}'"
echo "ON_BACKGROUND: '${ON_BACKGROUND}'"
echo "ON_ERROR: '${ON_ERROR}'"
echo "ON_ERROR_CONTAINER: '${ON_ERROR_CONTAINER}'"
echo "ON_PRIMARY: '${ON_PRIMARY}'"
echo "ON_PRIMARY_CONTAINER: '${ON_PRIMARY_CONTAINER}'"
echo "ON_PRIMARY_FIXED: '${ON_PRIMARY_FIXED}'"
echo "ON_PRIMARY_FIXED_VARIANT: '${ON_PRIMARY_FIXED_VARIANT}'"
echo "ON_SECONDARY: '${ON_SECONDARY}'"
echo "ON_SECONDARY_CONTAINER: '${ON_SECONDARY_CONTAINER}'"
echo "ON_SECONDARY_FIXED: '${ON_SECONDARY_FIXED}'"
echo "ON_SECONDARY_FIXED_VARIANT: '${ON_SECONDARY_FIXED_VARIANT}'"
echo "ON_SURFACE: '${ON_SURFACE}'"
echo "ON_SURFACE_VARIANT: '${ON_SURFACE_VARIANT}'"
echo "ON_TERTIARY: '${ON_TERTIARY}'"
echo "ON_TERTIARY_CONTAINER: '${ON_TERTIARY_CONTAINER}'"
echo "ON_TERTIARY_FIXED: '${ON_TERTIARY_FIXED}'"
echo "ON_TERTIARY_FIXED_VARIANT: '${ON_TERTIARY_FIXED_VARIANT}'"
echo "OUTLINE: '${OUTLINE}'"
echo "OUTLINE_VARIANT: '${OUTLINE_VARIANT}'"
echo "PRIMARY: '${PRIMARY}'"
echo "PRIMARY_CONTAINER: '${PRIMARY_CONTAINER}'"
echo "PRIMARY_FIXED: '${PRIMARY_FIXED}'"
echo "PRIMARY_FIXED_DIM: '${PRIMARY_FIXED_DIM}'"
echo "SCRIM: '${SCRIM}'"
echo "SECONDARY: '${SECONDARY}'"
echo "SECONDARY_CONTAINER: '${SECONDARY_CONTAINER}'"
echo "SECONDARY_FIXED: '${SECONDARY_FIXED}'"
echo "SECONDARY_FIXED_DIM: '${SECONDARY_FIXED_DIM}'"
echo "SHADOW: '${SHADOW}'"
echo "SOURCE_COLOR: '${SOURCE_COLOR}'"
echo "SURFACE: '${SURFACE}'"
echo "SURFACE_BRIGHT: '${SURFACE_BRIGHT}'"
echo "SURFACE_CONTAINER: '${SURFACE_CONTAINER}'"
echo "SURFACE_CONTAINER_HIGH: '${SURFACE_CONTAINER_HIGH}'"
echo "SURFACE_CONTAINER_HIGHEST: '${SURFACE_CONTAINER_HIGHEST}'"
echo "SURFACE_CONTAINER_LOW: '${SURFACE_CONTAINER_LOW}'"
echo "SURFACE_CONTAINER_LOWEST: '${SURFACE_CONTAINER_LOWEST}'"
echo "SURFACE_DIM: '${SURFACE_DIM}'"
echo "SURFACE_TINT: '${SURFACE_TINT}'"
echo "SURFACE_VARIANT: '${SURFACE_VARIANT}'"
echo "TERTIARY: '${TERTIARY}'"
echo "TERTIARY_CONTAINER: '${TERTIARY_CONTAINER}'"
echo "TERTIARY_FIXED: '${TERTIARY_FIXED}'"
echo "TERTIARY_FIXED_DIM: '${TERTIARY_FIXED_DIM}'"
echo "-----------------------------------------------------"

# --- Fallback alias for FG (Foreground) if ON_BACKGROUND is preferred ---
FG=${ON_BACKGROUND}
BG=${BACKGROUND} # Ensure BG is also aliased if used generally

# --- More Robust Fallbacks for key UI elements (Examples) ---
EDITOR_BG=${SURFACE_DIM:-${SURFACE_CONTAINER_LOWEST:-${SURFACE_CONTAINER_LOW:-${SURFACE:-${BG:-1c1c1c}}}}}
EDITOR_FG=${ON_SURFACE:-${FG:-c0c0c0}}

SIDEBAR_BG=${SURFACE_CONTAINER_LOW:-${SURFACE:-${BG:-1c1c1c}}}
SIDEBAR_FG=${ON_SURFACE:-${FG:-c0c0c0}}

ACTIVITYBAR_BG=${SURFACE_CONTAINER:-${PRIMARY_CONTAINER:-${PRIMARY:-3b3b3b}}}
ACTIVITYBAR_FG=${ON_PRIMARY_CONTAINER:-${ON_PRIMARY:-${FG:-c0c0c0}}}

STATUSBAR_BG=${PRIMARY:-${SURFACE_CONTAINER_HIGH:-${BG:-1c1c1c}}}
STATUSBAR_FG=${ON_PRIMARY:-${ON_SURFACE:-${FG:-c0c0c0}}}

TABS_CONTAINER_BG=${SURFACE_CONTAINER_LOW:-${SIDEBAR_BG}}
ACTIVE_TAB_BG=${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-${EDITOR_BG}}}
INACTIVE_TAB_BG=${SURFACE_CONTAINER_LOWEST:-${TABS_CONTAINER_BG}}
INPUT_BG=${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-${SURFACE:-2a2a2a}}}

# Check if essential colors for base theming are extracted (BG, FG, PRIMARY)
if [ -z "$BG" ] || [ -z "$FG" ] || [ -z "$PRIMARY" ]; then
    echo "FATAL ERROR: Essential colors (BACKGROUND, ON_BACKGROUND, PRIMARY) could not be extracted."
    echo "BG: '${BG}', FG: '${FG}', PRIMARY: '${PRIMARY}'"
    echo "Script cannot proceed without these. Check $CSS_FILE_TO_PARSE and color names."
    exit 1 # Exit because base theming will be impossible
fi

# --- Build the JSON for workbench.colorCustomizations ---
CUSTOMIZATIONS_JSON=$(cat <<EOF
{
  "workbench.colorCustomizations": {
    "foreground": "#${EDITOR_FG}",
    "focusBorder": "#${PRIMARY:-${OUTLINE:-${SURFACE_TINT:-a8c8ff}}}",
    "widget.shadow": "#${SHADOW:-000000}33",

    "editor.background": "#${EDITOR_BG}",
    "editor.foreground": "#${EDITOR_FG}",
    "editorLineNumber.foreground": "#${ON_SURFACE_VARIANT:-${FG:-c0c0c0}90}",
    "editorLineNumber.activeForeground": "#${PRIMARY:-${SURFACE_TINT:-a8c8ff}}",
    "editorCursor.foreground": "#${PRIMARY:-${SURFACE_TINT:-a8c8ff}}",
    "editor.selectionBackground": "#${PRIMARY_CONTAINER:-${PRIMARY:-a8c8ff}}4D",
    "editor.inactiveSelectionBackground": "#${PRIMARY_CONTAINER:-${PRIMARY:-a8c8ff}}33",
    "editorWhitespace.foreground": "#${ON_SURFACE_VARIANT:-${FG:-c0c0c0}40}",
    "editorIndentGuide.background1": "#${OUTLINE_VARIANT:-${ON_SURFACE_VARIANT:-${FG:-c0c0c0}}20}",
    "editorIndentGuide.activeBackground1": "#${OUTLINE:-${PRIMARY:-${SURFACE_TINT:-a8c8ff}}70}",
    "editorHoverWidget.background": "#${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-2c2c2c}}",
    "editorHoverWidget.border": "#${OUTLINE:-${SURFACE_CONTAINER_HIGHEST:-4a4a4a}}",

    "sideBar.background": "#${SIDEBAR_BG}",
    "sideBar.foreground": "#${SIDEBAR_FG}",
    "sideBar.border": "#${OUTLINE_VARIANT:-${SURFACE_CONTAINER:-${SIDEBAR_BG}}}",
    "sideBarSectionHeader.background": "#${SURFACE_CONTAINER_LOW:-${SIDEBAR_BG}}",
    "sideBarSectionHeader.foreground": "#${SIDEBAR_FG}",
    "sideBarSectionHeader.border": "#${OUTLINE_VARIANT:-${SURFACE_CONTAINER:-${SIDEBAR_BG}}}",

    "activityBar.background": "#${ACTIVITYBAR_BG}",
    "activityBar.foreground": "#${ACTIVITYBAR_FG}",
    "activityBar.inactiveForeground": "#${ON_SURFACE_VARIANT:-${ACTIVITYBAR_FG}99}",
    "activityBar.border": "#${OUTLINE_VARIANT:-${ACTIVITYBAR_BG}}",
    "activityBarBadge.background": "#${TERTIARY_CONTAINER:-${TERTIARY:-f3b7bf}}",
    "activityBarBadge.foreground": "#${ON_TERTIARY_CONTAINER:-${ON_TERTIARY:-4b252b}}",

    "statusBar.background": "#${STATUSBAR_BG}",
    "statusBar.foreground": "#${STATUSBAR_FG}",
    "statusBar.border": "#${OUTLINE_VARIANT:-${STATUSBAR_BG}}",
    "statusBar.noFolderBackground": "#${STATUSBAR_BG}",
    "statusBarItem.remoteBackground": "#${TERTIARY_CONTAINER:-${TERTIARY:-f3b7bf}}",
    "statusBarItem.remoteForeground": "#${ON_TERTIARY_CONTAINER:-${ON_TERTIARY:-4b252b}}",

    "editorGroupHeader.tabsBackground": "#${TABS_CONTAINER_BG}",
    "editorGroupHeader.tabsBorder": "#${OUTLINE_VARIANT:-${TABS_CONTAINER_BG}}",
    "tab.activeBackground": "#${ACTIVE_TAB_BG}",
    "tab.activeForeground": "#${ON_SURFACE:-${PRIMARY:-a8c8ff}}",
    "tab.activeBorderTop": "#${PRIMARY:-${SURFACE_TINT:-a8c8ff}}",
    "tab.inactiveBackground": "#${INACTIVE_TAB_BG}",
    "tab.inactiveForeground": "#${ON_SURFACE_VARIANT:-${FG:-c0c0c0}cc}",
    "tab.border": "#${OUTLINE_VARIANT:-${SURFACE_CONTAINER_LOWEST:-${TABS_CONTAINER_BG}}}",

    "input.background": "#${INPUT_BG}",
    "input.foreground": "#${ON_SURFACE:-${FG:-c0c0c0}}",
    "input.border": "#${OUTLINE:-${SURFACE_CONTAINER_HIGHEST:-4a4a4a}}",
    "inputOption.activeBackground": "#${PRIMARY_CONTAINER:-${PRIMARY:-a8c8ff}90}",
    "inputOption.activeForeground": "#${ON_PRIMARY_CONTAINER:-${ON_PRIMARY:-05305f}}",
    "inputValidation.infoBorder": "#${PRIMARY:-${SURFACE_TINT:-a8c8ff}}",
    "inputValidation.warningBorder": "#${TERTIARY:-${SECONDARY:-f3b7bf}}",
    "inputValidation.errorBorder": "#${ERROR_CONTAINER:-${ERROR:-ffb4ab}}",

    "dropdown.background": "#${INPUT_BG}",
    "dropdown.listBackground": "#${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-2c2c2c}}",
    "dropdown.border": "#${OUTLINE:-${SURFACE_CONTAINER_HIGHEST:-4a4a4a}}",
    "dropdown.foreground": "#${ON_SURFACE:-${FG:-c0c0c0}}",

    "button.background": "#${PRIMARY_CONTAINER:-${PRIMARY:-a8c8ff}}",
    "button.foreground": "#${ON_PRIMARY_CONTAINER:-${ON_PRIMARY:-05305f}}",
    "button.hoverBackground": "#${PRIMARY_FIXED_DIM:-${PRIMARY:-a8c8ff}E6}",

    "list.hoverBackground": "#${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-2c2c2c}80}",
    "list.hoverForeground": "#${ON_SURFACE:-${FG:-c0c0c0}}",
    "list.activeSelectionBackground": "#${PRIMARY_CONTAINER:-${PRIMARY:-a8c8ff}}",
    "list.activeSelectionForeground": "#${ON_PRIMARY_CONTAINER:-${ON_PRIMARY:-05305f}}",
    "list.inactiveSelectionBackground": "#${SURFACE_CONTAINER:-${SURFACE:-221e24}cc}",
    "list.inactiveSelectionForeground": "#${ON_SURFACE_VARIANT:-${ON_SURFACE:-e8e0e8}}",
    "list.focusBackground": "#${PRIMARY_CONTAINER:-${PRIMARY:-a8c8ff}99}",
    "list.focusForeground": "#${ON_PRIMARY_CONTAINER:-${ON_PRIMARY:-05305f}}",
    "list.highlightForeground": "#${TERTIARY:-${SECONDARY:-f3b7bf}}",

    "titleBar.activeBackground": "#${SURFACE_CONTAINER:-${ACTIVITYBAR_BG}}",
    "titleBar.activeForeground": "#${ON_SURFACE:-${ACTIVITYBAR_FG}}",
    "titleBar.inactiveBackground": "#${SURFACE_CONTAINER_LOWEST:-${SIDEBAR_BG}}",
    "titleBar.inactiveForeground": "#${ON_SURFACE_VARIANT:-${SIDEBAR_FG}99}",
    "titleBar.border": "#${OUTLINE_VARIANT:-${SURFACE_CONTAINER:-${ACTIVITYBAR_BG}}}",

    "notificationCenterHeader.background": "#${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-2c2c2c}}",
    "notifications.background": "#${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-2c2c2c}}",
    "notifications.border": "#${OUTLINE:-${SURFACE_CONTAINER_HIGHEST:-4a4a4a}}",

    "extensionButton.prominentBackground": "#${PRIMARY_CONTAINER:-${PRIMARY:-a8c8ff}}",
    "extensionButton.prominentForeground": "#${ON_PRIMARY_CONTAINER:-${ON_PRIMARY:-05305f}}",
    "extensionButton.prominentHoverBackground": "#${PRIMARY_FIXED_DIM:-${PRIMARY:-a8c8ff}E6}",
    "extensionBadge.remoteBackground": "#${TERTIARY_CONTAINER:-${TERTIARY:-f3b7bf}}",
    "extensionBadge.remoteForeground": "#${ON_TERTIARY_CONTAINER:-${ON_TERTIARY:-4b252b}}",

    "peekView.border": "#${PRIMARY:-${SURFACE_TINT:-a8c8ff}}",
    "peekViewEditor.background": "#${SURFACE_CONTAINER_LOW:-${EDITOR_BG}}",
    "peekViewResult.background": "#${SURFACE_CONTAINER:-${SIDEBAR_BG}}",
    "peekViewTitle.background": "#${SURFACE_CONTAINER_HIGH:-${SURFACE_BRIGHT:-2c2c2c}}",

    "terminal.background": "#${SURFACE_CONTAINER_LOWEST:-${BG:-100d12}}",
    "terminal.foreground": "#${ON_SURFACE:-${FG:-e8e0e8}}",
    "terminal.ansiBlack": "#${SURFACE_CONTAINER:-${BG:-221e24}}",
    "terminal.ansiBrightBlack": "#${ON_SURFACE_VARIANT:-${FG:-ccc4cf}cc}",
    "terminal.ansiRed": "#${ERROR:-ffb4ab}",
    "terminal.ansiGreen": "#${TERTIARY_FIXED_DIM:-${TERTIARY:-dbbce1}}",
    "terminal.ansiYellow": "#${SECONDARY_FIXED_DIM:-${SECONDARY:-bdc7dc}}",
    "terminal.ansiBlue": "#${PRIMARY_FIXED_DIM:-${PRIMARY:-a8c8ff}}",
    "terminal.ansiMagenta": "#${TERTIARY_CONTAINER:-${TERTIARY:-563e5d}}",
    "terminal.ansiCyan": "#${SECONDARY_CONTAINER:-${SECONDARY:-3d4758}}",
    "terminal.ansiWhite": "#${ON_SURFACE:-${FG:-e8e0e8}}",
    "terminal.ansiBrightRed": "#${ERROR_CONTAINER:-${ERROR:-ffb4ab}}",
    "terminal.ansiBrightGreen": "#${TERTIARY_FIXED:-${TERTIARY_FIXED_DIM:-dbbce1}}",
    "terminal.ansiBrightYellow": "#${SECONDARY_FIXED:-${SECONDARY_FIXED_DIM:-bdc7dc}}",
    "terminal.ansiBrightBlue": "#${PRIMARY_FIXED:-${PRIMARY_FIXED_DIM:-a8c8ff}}",
    "terminal.ansiBrightMagenta": "#${TERTIARY_FIXED:-${ON_TERTIARY_CONTAINER:-f8d8fe}}",
    "terminal.ansiBrightCyan": "#${SECONDARY_FIXED:-${ON_SECONDARY_CONTAINER:-d9e3f8}}",
    "terminal.ansiBrightWhite": "#${ON_BACKGROUND:-${FG:-e8e0e8}}"
  }
}
EOF
)

# --- Merge with existing settings.json using jq ---
# Improved error handling for jq merge
if [ -n "$CUSTOMIZATIONS_JSON" ] && jq -e . >/dev/null 2>&1 <<<"$CUSTOMIZATIONS_JSON"; then
    echo "DEBUG: CUSTOMIZATIONS_JSON appears valid."
    if [ -f "$VSCODIUM_SETTINGS_FILE" ]; then
        echo "DEBUG: Backing up existing settings file to ${VSCODIUM_SETTINGS_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$VSCODIUM_SETTINGS_FILE" "${VSCODIUM_SETTINGS_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
        echo "DEBUG: Attempting to merge new customizations..."
        if jq -s '.[0] * .[1]' "$VSCODIUM_SETTINGS_FILE" <(echo "$CUSTOMIZATIONS_JSON") > tmp_settings.json; then
            mv tmp_settings.json "$VSCODIUM_SETTINGS_FILE"
            echo "VSCodium theme colors successfully updated based on $CSS_FILE_TO_PARSE."
        else
            echo "ERROR: jq merge failed. Original settings.json might be corrupt or an unexpected error occurred during merge."
            echo "       New colors were NOT applied. Check tmp_settings.json (if it exists) and the original settings file."
            # Consider not removing tmp_settings.json here for manual inspection if merge fails
            # rm -f tmp_settings.json 
        fi
    else
        echo "DEBUG: $VSCODIUM_SETTINGS_FILE not found. Creating new one with generated customizations."
        echo "$CUSTOMIZATIONS_JSON" > "$VSCODIUM_SETTINGS_FILE"
        echo "VSCodium theme colors set in new settings file based on $CSS_FILE_TO_PARSE."
    fi
else
    echo "Error: CUSTOMIZATIONS_JSON was empty or invalid. VSCodium settings not updated."
    echo "Problematic JSON content (as generated by script) was:"
    echo "$CUSTOMIZATIONS_JSON"
    echo "Attempting to validate with jq to show specific error:"
    jq . <<<"$CUSTOMIZATIONS_JSON"
fi

echo "You might need to reload VSCodium (Ctrl+Shift+P -> 'Reload Window') for all changes to take full effect."
