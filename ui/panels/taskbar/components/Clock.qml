import QtQuick
import Quickshell

Column {
    id: root
    spacing: 0
    
    property var theme
    
    property string timeStr: "00:00"
    property string dateStr: "1 Jan"
    
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.timeStr
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 14
        font.bold: true
        color: root.theme ? root.theme.textMain : "#FFF"
    }
    
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.dateStr
        font.family: root.theme ? root.theme.fontMain : "Inter"
        font.pixelSize: 10
        color: root.theme ? root.theme.textSub : "#AAA"
        opacity: 0.8
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
