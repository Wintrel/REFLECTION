import "../../../../../core/state" as State
import QtQuick

Row {
    id: root

    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null
    
    signal previousClicked()
    signal playPauseClicked()
    signal nextClicked()
    
    spacing: 16
    
    property bool isVisible: root.islandState === State.IslandState.expanded
    opacity: (root.islandState === State.IslandState.expanded) ? 1 : 0
    transform: Translate {
        y: (root.islandState === State.IslandState.expanded) ? 0 : 10
        Behavior on y { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
    }
    Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
    
    Text { 
        id: btnPrev
        text: "skip_previous"
        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
        font.pixelSize: 32
        color: maPrev.pressed ? (root.theme ? root.theme.accentMusic : "#5611f8") : (maPrev.containsMouse ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : (root.theme ? root.theme.textMain : "#FFF"))
        anchors.verticalCenter: parent.verticalCenter 
        
        scale: maPrev.pressed ? 0.85 : (maPrev.containsMouse ? 1.1 : 1)
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 150 } }
        
        MouseArea { 
            id: maPrev
            anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.previousClicked()
        }
    }
    
    Text { 
        id: btnPlay
        text: (root.mprisPlayer && root.mprisPlayer.isPlaying) ? "pause_circle" : "play_circle"
        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
        font.pixelSize: 42
        color: maPlay.pressed ? (root.theme ? root.theme.accentMusic : "#5611f8") : (maPlay.containsMouse ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : (root.theme ? root.theme.textMain : "#FFF"))
        anchors.verticalCenter: parent.verticalCenter 
        
        scale: maPlay.pressed ? 0.85 : (maPlay.containsMouse ? 1.05 : 1)
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 150 } }
        
        MouseArea { 
            id: maPlay
            anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.playPauseClicked()
        }
    }
    
    Text { 
        id: btnNext
        text: "skip_next"
        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
        font.pixelSize: 32
        color: maNext.pressed ? (root.theme ? root.theme.accentMusic : "#5611f8") : (maNext.containsMouse ? (root.theme ? root.theme.accentPrimary : "#00FFCC") : (root.theme ? root.theme.textMain : "#FFF"))
        anchors.verticalCenter: parent.verticalCenter 
        
        scale: maNext.pressed ? 0.85 : (maNext.containsMouse ? 1.1 : 1)
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 150 } }
        
        MouseArea { 
            id: maNext
            anchors.fill: parent; anchors.margins: -10; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.nextClicked()
        }
    }
}
