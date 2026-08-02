import QtQuick
import QtQuick.Layouts

// Display category stage — dot-grid scan-line ambient
CategoryStage {
    id: root
    categoryTitle: "Display"
    categorySubtitle: "Monitor & visual output"

    ambientContent: Item {
        // Dot grid motif drawn with Canvas — NVIDIA-safe
        Canvas {
            anchors.fill: parent
            opacity: 0.05
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = root.theme ? root.theme.textSub.toString() : "#ffffff";
                var spacing = 28;
                for (var x = spacing; x < width; x += spacing) {
                    for (var y = spacing; y < height; y += spacing) {
                        ctx.beginPath();
                        ctx.arc(x, y, 1.5, 0, Math.PI * 2);
                        ctx.fill();
                    }
                }
            }
        }

        // Center soft glow — horizontal gradient from edges fading to center
        // Replaces RadialGradient (not valid on Rectangle.gradient)
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: parent.height * 0.5
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: root.theme ?
                        Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.04) :
                        Qt.rgba(0.3, 0.3, 0.7, 0.04)
                }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop {
                    position: 1.0
                    color: root.theme ?
                        Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.04) :
                        Qt.rgba(0.3, 0.3, 0.7, 0.04)
                }
            }
        }
    }

    pageContent: Item {
        Text {
            anchors.centerIn: parent
            text: "Display settings coming soon"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            color: root.theme ? root.theme.textSub : "#888"
        }
    }
}
