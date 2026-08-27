import QtQuick
import "./services/system"

Item {
    // Colors.
    property color bgBezel: ThemeService.bgBezel
    property color bgInner: ThemeService.bgInner
    property color textMain: ThemeService.textMain
    property color textSub: ThemeService.textSub
    
    // Status Colors
    property color accentNotification: ThemeService.accentNotification
    property color accentMusic: ThemeService.accentMusic
    property color accentWorkspace: ThemeService.accentWorkspace
    property color accentPrimary: ThemeService.accentPrimary
    property color colorSystemShimmer: ThemeService.colorSystemShimmer
    property color bgBase: ThemeService.bgBase
    property color surfaceCard: ThemeService.surfaceCard
    property color surfaceOverlay: ThemeService.surfaceOverlay
    property color textMuted: ThemeService.textMuted
    property color accentSecondary: ThemeService.accentSecondary
    property bool useGradients: ThemeService.useGradients
    property color bgInnerGradientEnd: ThemeService.bgInnerGradientEnd
    property color surfaceCardGradientEnd: ThemeService.surfaceCardGradientEnd
    property color accentPrimaryGradientEnd: ThemeService.accentPrimaryGradientEnd
    
    // Fonts
    property string fontMain: "Inter" // Fallback main font
    property string fontIcon: "Material Symbols Rounded"
    
    // Geometry
    property int radiusIsland: ThemeService.radiusIsland
    property bool floatingIsland: ShellService.floatingIsland
    property int islandTopMargin: ShellService.islandTopMargin
    property int radiusIslandFloating: ShellService.radiusIslandFloating
    
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
    
    property int islandBatteryW: 1080
    property int islandBatteryH: 380
    
    property int islandHistoryW: 600
    property int islandHistoryH: 500
    
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

    property int reflectionAssistantW: 700
    property int reflectionAssistantH: 420
    
    // Animation Durations & Motion Tokens
    property int animDuration: ThemeService.animDuration
    property int durationMorph: ThemeService.durationMorph
    property int durationContentIn: ThemeService.durationContentIn
    property int durationContentOut: ThemeService.durationContentOut
    property int durationFast: ThemeService.durationFast

    // Easing Curves (Material 3 Expressive)
    property var easingMorph: Easing.OutBack
    property real morphOvershoot: ShellService.islandBounceIntensity
    property var easingStandard: Easing.OutQuad
    property var easingEmphasized: Easing.OutBack
    property var easingExit: Easing.InQuad
    
    // Effects
    property real edgeLightingIntensity: ThemeService.edgeLightingIntensity
    
    // Taskbar Sizing
    property bool floatingTaskbar: ShellService.floatingTaskbar
    property int taskbarRadius: ShellService.floatingTaskbar ? ShellService.radiusTaskbarFloating : ThemeService.taskbarRadius
    property int taskbarHeight: ShellService.taskbarHeight
    property real taskbarWidthPercent: ShellService.taskbarWidthPercent
    property int taskbarBottomMargin: ShellService.floatingTaskbar ? ShellService.taskbarBottomMargin : 0
    property int taskbarBorderWidth: 1
    property int islandBorderWidth: 1
}
