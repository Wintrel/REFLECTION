import QtQuick

import "../../../../core"
import "../../dynamic_island" as DI

Item {
    id: root
    
    property var theme: null
    
    // Time updating
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date();
            var h = date.getHours();
            var m = date.getMinutes();
            timeText.text = (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
            
            var options = { weekday: 'long', month: 'long', day: 'numeric' };
            dateText.text = date.toLocaleDateString(Qt.locale(), "dddd, MMMM d");
        }
    }
    
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -100
        spacing: 8
        
        Text {
            id: timeText
            text: "00:00"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 120
            font.weight: Font.Light // Thinner, elegant font
            font.letterSpacing: -2 // Tighter tracking for large numbers
            color: root.theme ? root.theme.textMain : "#FFF"
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline
            styleColor: Qt.rgba(0,0,0,0.2) // Subtle text drop shadow
        }
        
        Text {
            id: dateText
            text: "Monday, January 1"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 20
            font.weight: Font.Medium
            font.letterSpacing: 1 // Wider tracking for the date
            color: root.theme ? root.theme.textMain : "#FFF"
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline
            styleColor: Qt.rgba(0,0,0,0.2)
        }
    }
    
}
