import QtQuick

Item {
    // Colors
    property color bgBezel: "#000000" // The outer bezel border color
    property color bgInner: "#000000" // Inner content area
    property color textMain: "#CDD6F4"
    property color textSub: "#A6ADC8"
    
    // Status Colors
    property color colorNotification: '#284594' // Very dark blue
    property color colorMusic: '#445b7c' // Dark Blue/Grey
    property color accentWorkspace: '#2b4d97' // dark ish blue?
    property color accentPrimary: '#6e8fc0' // Orange accent for system is asking for something on user or its interactive/currently interacting
    property color colorSystemShimmer: '#97b3f0' // Electric blue for system loading states
    property color bgBase: '#000000' // Base black
    
    // Fonts
    property string fontMain: "Inter" // Fallback main font
    property string fontIcon: "Material Symbols Rounded"
    
    // Geometry
    property int radiusIsland: 12
    
    // Island States Sizing
    property int islandMinW: 220
    property int islandMinH: 45
    
    property int islandHoverW: 230
    property int islandHoverH: 50
    
    property int islandNotifW: 400
    property int islandNotifH: 80
    
    property int islandMaxW: 600
    property int islandMaxH: 200
    
    property int islandBatteryW: 500
    property int islandBatteryH: 220
    
    property int islandHistoryW: 600
    property int islandHistoryH: 400
    
    // Reflection State Sizing
    property int reflectionSearchW: 450
    property int reflectionSearchH: 80

    property int reflectionFocusW: 450
    property int reflectionFocusH: 220

    property int reflectionGridW: 550
    property int reflectionGridH: 350
    
    // Animation Durations
    property int animDuration: 600
    
    // Taskbar Sizing
    property int taskbarRadius: 16
    property int taskbarHeight: 52
    property real taskbarWidthPercent: 0.97 // 85% width
    property int taskbarBottomMargin: 0
    property int taskbarBorderWidth: 4
}
