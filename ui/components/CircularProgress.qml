import QtQuick

Item {
    id: root
    property real value: 0
    property real maximumValue: 100
    property color color: "white"
    property real lineWidth: 2
    
    onValueChanged: canvas.requestPaint()
    onMaximumValueChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    
    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            var centerX = width / 2;
            var centerY = height / 2;
            var radius = Math.min(centerX, centerY) - root.lineWidth / 2;
            
            var progress = root.maximumValue > 0 ? root.value / root.maximumValue : 0;
            var startAngle = -Math.PI / 2;
            var endAngle = startAngle + (progress * 2 * Math.PI);
            
            // Background track (optional, very faint)
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
            ctx.strokeStyle = Qt.rgba(root.color.r, root.color.g, root.color.b, 0.2);
            ctx.lineWidth = root.lineWidth;
            ctx.stroke();
            
            // Progress arc
            if (progress > 0) {
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, startAngle, endAngle);
                ctx.strokeStyle = root.color;
                ctx.lineWidth = root.lineWidth;
                ctx.lineCap = "round";
                ctx.stroke();
            }
        }
    }
}
