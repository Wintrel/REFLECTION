import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: rootCard
    property var theme: null
    property string title: "CPU"
    property string subtitle: "AMD Ryzen 5 5600H with Radeon..."
    property string icon: "memory"
    property string usageText: "8%"
    property string tempText: "67°C"
    property real usageFraction: 0.08
    property color accentColor: "#79D6A1"

    radius: 20
    color: rootCard.theme ? rootCard.theme.surfaceOverlay : Qt.rgba(1, 1, 1, 0.05)
    border.color: rootCard.theme ? Qt.lighter(rootCard.theme.surfaceOverlay, 1.2) : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    clip: true

    Item {
        anchors.fill: parent
        anchors.margins: 16

        // ── Top Left: Icon with circular ring ─────────────────────────
        Item {
            id: iconContainer
            anchors.left: parent.left
            anchors.top: parent.top
            width: 38
            height: 38

            // Subtle outer decorative ring/arc
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = width / 2 - 2;

                    // Light track
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                    ctx.strokeStyle = Qt.rgba(rootCard.accentColor.r, rootCard.accentColor.g, rootCard.accentColor.b, 0.2);
                    ctx.lineWidth = 1.5;
                    ctx.stroke();

                    // Short accent arc
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, -Math.PI * 0.8, -Math.PI * 0.2);
                    ctx.strokeStyle = rootCard.accentColor;
                    ctx.lineWidth = 2;
                    ctx.lineCap = "round";
                    ctx.stroke();
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 30
                height: 30
                radius: 15
                color: Qt.rgba(rootCard.accentColor.r, rootCard.accentColor.g, rootCard.accentColor.b, 0.12)

                Text {
                    anchors.centerIn: parent
                    text: rootCard.icon
                    font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 17
                    color: rootCard.accentColor
                }
            }
        }

        // ── Title / Subtitle ──────────────────────────────────────────
        Column {
            anchors.left: iconContainer.right
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.right: usageBadge.left
            anchors.rightMargin: 12
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
                width: parent.width
                elide: Text.ElideRight
            }
        }

        // ── Top Right: Usage Badge ────────────────────────────────────
        Rectangle {
            id: usageBadge
            anchors.right: parent.right
            anchors.top: parent.top
            width: 58
            height: 52
            radius: 16
            color: Qt.rgba(rootCard.accentColor.r, rootCard.accentColor.g, rootCard.accentColor.b, 0.14)

            Column {
                anchors.centerIn: parent
                spacing: 1

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Usage"
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: rootCard.usageText
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    color: rootCard.accentColor
                }
            }
        }

        // ── Bottom Area: Temp + Progress Bar ──────────────────────────
        Column {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            spacing: 6

            Row {
                spacing: 4
                Text {
                    text: "device_thermostat"
                    font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 14
                    color: rootCard.accentColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: rootCard.tempText
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: rootCard.theme ? rootCard.theme.textMain : "#FFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                id: progressTrack
                width: parent.width * 0.65
                height: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.08)

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: progressTrack.width * Math.max(0, Math.min(1, rootCard.usageFraction))
                    radius: 2
                    color: rootCard.accentColor

                    Behavior on width {
                        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
