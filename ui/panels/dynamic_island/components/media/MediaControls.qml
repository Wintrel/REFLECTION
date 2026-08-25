import "../../../../../core/state" as State
import QtQuick

Item {
    id: root

    property int islandState: State.IslandState.idle
    property var mprisPlayer: null
    property var theme: null
    
    signal previousClicked()
    signal playPauseClicked()
    signal nextClicked()
    
    width: controlsBg.width
    height: controlsBg.height
    
    property bool isVisible: root.islandState === State.IslandState.expanded
    opacity: (root.islandState === State.IslandState.expanded) ? 1 : 0
    transform: Translate {
        y: (root.islandState === State.IslandState.expanded) ? 0 : 10
        Behavior on y { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 400; easing.type: Easing.OutExpo } } }
    }
    Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 100 } NumberAnimation { duration: 300; easing.type: Easing.OutSine } } }
    
    Rectangle {
        id: controlsBg
        anchors.centerIn: parent
        width: controlsRow.width + 24
        height: controlsRow.height + 12
        radius: height / 2
        color: root.theme ? root.theme.surfaceOverlay : Qt.rgba(255, 255, 255, 0.04)
        border.color: root.theme ? Qt.lighter(root.theme.surfaceOverlay, 1.2) : Qt.rgba(255, 255, 255, 0.08)
        border.width: 1
        
        Row {
            id: controlsRow
            anchors.centerIn: parent
            spacing: 12
        
        // Previous — bare icon, recessive
        Item {
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            
            Text { 
                id: btnPrev
                text: "skip_previous"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 22
                color: maPrev.pressed ? (root.theme ? root.theme.textMain : "#FFF") : (maPrev.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#94A3B8"))
                anchors.centerIn: parent
                
                scale: maPrev.pressed ? 0.85 : (maPrev.containsMouse ? 1.1 : 1)
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            MouseArea { 
                id: maPrev
                anchors.fill: parent; anchors.margins: -6; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.previousClicked()
            }
        }
        
        // Play/Pause — filled accent circle, the primary action
        Rectangle {
            id: playPauseBg
            width: 36
            height: 36
            radius: 18
            anchors.verticalCenter: parent.verticalCenter
            
            color: root.theme ? root.theme.accentPrimary : "#5151ad"
            
            scale: maPlay.pressed ? 0.85 : (maPlay.containsMouse ? 1.08 : 1)
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 300 } }
            
            Text { 
                id: btnPlay
                text: (root.mprisPlayer && root.mprisPlayer.isPlaying) ? "pause" : "play_arrow"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 20
                color: root.theme ? root.theme.bgBase : "#000"
                anchors.centerIn: parent 
            }
            
            MouseArea { 
                id: maPlay
                anchors.fill: parent; anchors.margins: -4; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.playPauseClicked()
            }
        }
        
        // Next — bare icon, recessive
        Item {
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            
            Text { 
                id: btnNext
                text: "skip_next"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 22
                color: maNext.pressed ? (root.theme ? root.theme.textMain : "#FFF") : (maNext.containsMouse ? (root.theme ? root.theme.textMain : "#FFF") : (root.theme ? root.theme.textSub : "#94A3B8"))
                anchors.centerIn: parent
                
                scale: maNext.pressed ? 0.85 : (maNext.containsMouse ? 1.1 : 1)
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            MouseArea { 
                id: maNext
                anchors.fill: parent; anchors.margins: -6; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.nextClicked()
            }
        }
        }
    }
}
