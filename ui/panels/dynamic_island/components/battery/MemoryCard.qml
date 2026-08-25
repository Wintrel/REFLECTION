import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: rootCard
    property var theme: null
    property string title: "Memory"
    property string subtitle: "3.6 / 22.8 GiB"
    property real usedFraction: 0.16
    property color accentColor: "#79D6A1"

    radius: 20
    color: rootCard.theme ? rootCard.theme.surfaceOverlay : Qt.rgba(1, 1, 1, 0.05)
    border.color: rootCard.theme ? Qt.lighter(rootCard.theme.surfaceOverlay, 1.2) : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    clip: true

    Item {
        anchors.fill: parent
        anchors.margins: 14

        // ── Top: Icon + Memory Title ──────────────────────────────────
        Row {
            id: headerRow
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 6

            Text {
                text: "memory_alt"
                font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 16
                color: rootCard.accentColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: rootCard.title
                font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: rootCard.theme ? rootCard.theme.textMain : "#FFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── Center: Circular Progress Meter ───────────────────────────
        Item {
            id: meterContainer
            anchors.centerIn: parent
            width: 72
            height: 72

            Canvas {
                id: meterCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = width / 2 - 5;

                    // Light track
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                    ctx.strokeStyle = Qt.rgba(rootCard.accentColor.r, rootCard.accentColor.g, rootCard.accentColor.b, 0.15);
                    ctx.lineWidth = 4;
                    ctx.stroke();

                    // Progress arc
                    var startAngle = -Math.PI / 2;
                    var endAngle = startAngle + (Math.max(0, Math.min(1, rootCard.usedFraction)) * 2 * Math.PI);
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, startAngle, endAngle);
                    ctx.strokeStyle = rootCard.accentColor;
                    ctx.lineWidth = 4.5;
                    ctx.lineCap = "round";
                    ctx.stroke();
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 1

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(rootCard.usedFraction * 100) + "%"
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: rootCard.theme ? rootCard.theme.textMain : "#FFF"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Used"
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 9
                    color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                }
            }
        }

        // ── Bottom: Subtitle (Capacity) ───────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: rootCard.subtitle
            font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
            font.pixelSize: 11
            font.weight: Font.Medium
            color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
        }
    }
}

