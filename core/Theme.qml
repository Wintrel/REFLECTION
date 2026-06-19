import QtQuick

Item {
    // Colors
    property color bgBezel: "#000000" // The outer bezel border color
    property color bgInner: "#000000" // Inner content area
    property color accentBlue: "#89B4FA"
    property color textMain: "#CDD6F4"
    property color textSub: "#A6ADC8"
    
    // Status Colors
    property color colorNotification: '#710cee' // Purple/Indigo
    property color colorMusic: '#5611f8' // indigo
    property color accentWorkspace: '#5611f8' // Indigo purple for workspace dots
    
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
    
    property int islandHistoryW: 600
    property int islandHistoryH: 400
    
    // Animation Durations
    property int animDuration: 600
    
    // Taskbar Sizing
    property int taskbarRadius: 16
    property int taskbarHeight: 52
    property real taskbarWidthPercent: 0.97 // 85% width
    property int taskbarBottomMargin: 0
    property int taskbarBorderWidth: 4
}
