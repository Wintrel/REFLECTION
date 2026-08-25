import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: rootCard
    property var theme: null
    property string downloadSpeed: "7.2 KB/s"
    property string uploadSpeed: "5.6 KB/s"
    property string totalDown: "332.6MB"
    property string totalUp: "6.6MB"
    property color accentColor: "#79D6A1"

    radius: 20
    color: rootCard.theme ? rootCard.theme.surfaceOverlay : Qt.rgba(1, 1, 1, 0.05)
    border.color: rootCard.theme ? Qt.lighter(rootCard.theme.surfaceOverlay, 1.2) : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    clip: true

    // Graph data points history
    property var history: [0.1, 0.15, 0.8, 0.2, 0.05, 0.05, 0.05, 0.1, 0.08, 0.12, 0.05, 0.05]

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            var arr = rootCard.history.slice(1);
            var nextVal = Math.random() < 0.25 ? (0.4 + Math.random() * 0.5) : (0.02 + Math.random() * 0.15);
            arr.push(nextVal);
            rootCard.history = arr;
            chartCanvas.requestPaint();
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 14

        // ── Top Header: ⇅ Network ─────────────────────────────────────
        Row {
            id: headerRow
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 6

            Text {
                text: "swap_vert"
                font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 16
                color: rootCard.accentColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Network"
                font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: rootCard.theme ? rootCard.theme.textMain : "#FFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── Middle: Sparkline Area Chart ──────────────────────────────
        Canvas {
            id: chartCanvas
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: headerRow.bottom
            anchors.topMargin: 4
            anchors.bottom: statsColumn.top
            anchors.bottomMargin: 6

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var pts = rootCard.history;
                if (!pts || pts.length < 2) return;

                var step = width / (pts.length - 1);

                ctx.beginPath();
                ctx.moveTo(0, height - (pts[0] * (height - 4)));

                for (var i = 1; i < pts.length; i++) {
                    var x = i * step;
                    var y = height - (pts[i] * (height - 4));
                    ctx.lineTo(x, y);
                }

                // Line stroke
                ctx.strokeStyle = rootCard.accentColor;
                ctx.lineWidth = 1.5;
                ctx.stroke();

                // Area fill
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                ctx.closePath();

                var grad = ctx.createLinearGradient(0, 0, 0, height);
                grad.addColorStop(0.0, Qt.rgba(rootCard.accentColor.r, rootCard.accentColor.g, rootCard.accentColor.b, 0.25));
                grad.addColorStop(1.0, Qt.rgba(rootCard.accentColor.r, rootCard.accentColor.g, rootCard.accentColor.b, 0.0));
                ctx.fillStyle = grad;
                ctx.fill();
            }
        }

        // ── Bottom Metrics ────────────────────────────────────────────
        Column {
            id: statsColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 3

            // Download Row
            Row {
                width: parent.width
                Item {
                    width: parent.width * 0.5
                    height: 14
                    Row {
                        spacing: 4
                        Text {
                            text: "arrow_downward"
                            font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 11
                            color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                        }
                        Text {
                            text: "Download"
                            font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                        }
                    }
                }
                Text {
                    width: parent.width * 0.5
                    horizontalAlignment: Text.AlignRight
                    text: rootCard.downloadSpeed
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: rootCard.theme ? rootCard.theme.textMain : "#FFF"
                }
            }

            // Upload Row
            Row {
                width: parent.width
                Item {
                    width: parent.width * 0.5
                    height: 14
                    Row {
                        spacing: 4
                        Text {
                            text: "arrow_upward"
                            font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 11
                            color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                        }
                        Text {
                            text: "Upload"
                            font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                        }
                    }
                }
                Text {
                    width: parent.width * 0.5
                    horizontalAlignment: Text.AlignRight
                    text: rootCard.uploadSpeed
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: rootCard.theme ? rootCard.theme.textMain : "#FFF"
                }
            }

            // Total Row
            Row {
                width: parent.width
                Item {
                    width: parent.width * 0.35
                    height: 14
                    Row {
                        spacing: 4
                        Text {
                            text: "history"
                            font.family: rootCard.theme ? rootCard.theme.fontIcon : "Material Symbols Rounded"
                            font.pixelSize: 11
                            color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                        }
                        Text {
                            text: "Total"
                            font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                            font.pixelSize: 11
                            color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                        }
                    }
                }
                Text {
                    width: parent.width * 0.65
                    horizontalAlignment: Text.AlignRight
                    text: "↓" + rootCard.totalDown + " ↑" + rootCard.totalUp
                    font.family: rootCard.theme ? rootCard.theme.fontMain : "Inter"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: rootCard.theme ? rootCard.theme.textSub : "#A6ADC8"
                }
            }
        }
    }
}

