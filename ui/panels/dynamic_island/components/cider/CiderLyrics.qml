import QtQuick

Item {
    id: root
    property var theme: null
    
    Text {
        anchors.centerIn: parent
        text: "Lyrics feature coming soon."
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 16
        color: root.theme ? root.theme.textSub : "#A6ADC8"
    }
}
