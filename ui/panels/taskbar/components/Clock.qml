import QtQuick
import Quickshell

Row {
    id: root
    spacing: 8
    
    property var theme
    
    property string timeStr: "00:00"
    property string dateStr: "1 Jan"
    
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.timeStr
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 15
        font.bold: true
        color: root.theme ? root.theme.textMain : "#FFF"
    }
    
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "•"
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 12
        color: root.theme ? root.theme.textSub : "#AAA"
        opacity: 0.5
    }
    
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.dateStr
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.weight: Font.Medium
        color: root.theme ? root.theme.textSub : "#AAA"
        opacity: 0.9
    }
    
    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            updateTime()
            if (interval === 1000 && new Date().getSeconds() === 0) {
                interval = 60000;
            }
        }
        Component.onCompleted: updateTime()
    }
    
    function updateTime() {
        var d = new Date();
        var hrs = d.getHours().toString().padStart(2, '0');
        var mins = d.getMinutes().toString().padStart(2, '0');
        root.timeStr = hrs + ":" + mins;
        
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        root.dateStr = d.getDate() + " " + months[d.getMonth()];
    }
}
