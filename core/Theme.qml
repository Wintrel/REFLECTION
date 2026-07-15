import QtQuick

Item {
    // Colors.
    property color bgBezel: "#000000" // True black for OLED
    property color bgInner: "#000000" // True black for OLED
    property color textMain: "#D4D4D8" // Soft silver (avoids OLED blooming/harshness)
    property color textSub: "#82828C" // Muted ash grey
    
    // Status Colors (Ghostly Stardust Palette)
    property color colorNotification: '#3F3F4A' // Muted twilight slate (subtle glow for edges)
    property color colorMusic: '#525266' // Soft cosmic slate.
    property color accentWorkspace: '#1C1C24' // Deep void grey
    property color accentPrimary: '#8C8C9E' // Silver lavender (Interactive states)
    property color colorSystemShimmer: '#C0C0D0' // Bright starlight (Loading/Shimmer)
    property color bgBase: '#000000' // True black
    
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
    
    property int islandProgressW: 450
    property int islandProgressH: 80
    
    property int islandBatteryW: 500
    property int islandBatteryH: 220
    
    property int islandHistoryW: 600
    property int islandHistoryH: 400
    
    property int islandCiderW: 1300
    property int islandCiderH: 600
    
    property int islandSettingsW: 1100
    property int islandSettingsH: 650
    
    property int islandFilePickerW: 1000
    property int islandFilePickerH: 600
    
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
