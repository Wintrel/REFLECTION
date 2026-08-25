import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: rootCard
    property var theme: null
    property string title: "Storage"
    property string subtitle: "26.2 / 103.5 GiB"
    property real usedFraction: 0.25
    property string driveName: "nvme0n1"
    property color accentColor: "#79D6A1"

    radius: 20
    color: rootCard.theme ? rootCard.theme.surfaceOverlay : Qt.rgba(1, 1, 1, 0.05)
    border.color: rootCard.theme ? Qt.lighter(rootCard.theme.surfaceOverlay, 1.2) : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    clip: true

    Item {
        anchors.fill: parent
        anchors.margins: 14

        // ── Left: Circular Progress Gauge ─────────────────────────────
        Item {
            id: gaugeContainer
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 80
            height: 80

            Canvas {
                id: gaugeCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = width / 2 - 5;

                    // Background full track
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
                    text: "hard_drive"
                    font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 13
                    color: rootCard.accentColor
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(rootCard.usedFraction * 100) + "%"
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 13
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

        // ── Right: Title, Subtitle, and Drive Pill ────────────────────
        Column {
            anchors.left: gaugeContainer.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Column {
                spacing: 2
                Text {
                    text: rootCard.title
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: rootCard.theme ? rootCard.theme.textMain : "#FFF"
                }

                Text {
                    text: rootCard.subtitle
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                }
            }

            // Drive Selector Pill
            Rectangle {
                height: 24
                width: Math.min(parent.width, 110)
                radius: 12
                color: Qt.rgba(rootCard.accentColor.r, rootCard.accentColor.g, rootCard.accentColor.b, 0.14)

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "storage"
                        font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 12
                        color: rootCard.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: rootCard.driveName
                        font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: rootCard.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "expand_more"
                        font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 13
                        color: rootCard.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}

