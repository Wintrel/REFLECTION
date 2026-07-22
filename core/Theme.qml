import QtQuick
import "./services/system"

Item {
    // Colors.
    property color bgBezel: ThemeService.bgBezel
    property color bgInner: ThemeService.bgInner
    property color textMain: ThemeService.textMain
    property color textSub: ThemeService.textSub
    
    // Status Colors
    property color colorNotification: ThemeService.colorNotification
    property color colorMusic: ThemeService.colorMusic
    property color accentWorkspace: ThemeService.accentWorkspace
    property color accentPrimary: ThemeService.accentPrimary
    property color colorSystemShimmer: ThemeService.colorSystemShimmer
    property color bgBase: ThemeService.bgBase
    
    // Fonts
    property string fontMain: "Inter" // Fallback main font
    property string fontIcon: "Material Symbols Rounded"
    
    // Geometry
    property int radiusIsland: ThemeService.radiusIsland
    
    // Island States Sizing
    property int islandMinW: 220
    property int islandMinH: 45
    
    property int islandHoverW: 230
    property int islandHoverH: 50
    
    property int islandNotifW: 400
    property int islandNotifH: 100
    
    property int islandMaxW: 600
    property int islandMaxH: 200
    
    property int islandProgressW: 450
    property int islandProgressH: 80
    
    property int islandBatteryW: 600
    property int islandBatteryH: 260 + (BatteryService.peripheralCount * 46)
    
    property int islandHistoryW: 600
    property int islandHistoryH: 400
    
    property int islandCiderW: 1300
    property int islandCiderH: 600
    
    property int islandSettingsW: 1200
    property int islandSettingsH: 680
    
    property int islandFilePickerW: 1000
    property int islandFilePickerH: 600
    
    property int islandClipboardW: 600
    property int islandClipboardH: 400
    
    // Overview Panel
    property real overviewScale: 0.18
    property int overviewRows: 2
    property int overviewColumns: 5
    
    // Reflection State Sizing
    property int reflectionSearchW: 450
    property int reflectionSearchH: 80

    property int reflectionFocusW: 450
    property int reflectionFocusH: 220

    property int reflectionGridW: 550
    property int reflectionGridH: 350
    
    // Animation Durations
    property int animDuration: ThemeService.animDuration
    
    // Effects
    property real edgeLightingIntensity: ThemeService.edgeLightingIntensity
    
    // Taskbar Sizing
    property int taskbarRadius: ThemeService.taskbarRadius
    property int taskbarHeight: 52
    property real taskbarWidthPercent: 0.97 // 85% width
    property int taskbarBottomMargin: 0
    property int taskbarBorderWidth: 4
}
