import QtQuick
import QtQuick.Layouts
import "../../dynamic_island/components/rog" as Rog

// ROG category stage — diagonal chevrons + corner red glows (no RadialGradient)
CategoryStage {
    id: root
    categoryTitle: "ROG"
    categorySubtitle: "Performance, power & Aura lighting"

    ambientContent: Item {
        // Bottom-right red glow — linear gradient approximation
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.width * 0.55
            height: parent.height * 0.55
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0.8, 0.1, 0.1, 0.07) }
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.width * 0.55
            height: parent.height * 0.55
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0.8, 0.1, 0.1, 0.07) }
            }
        }

        // Diagonal chevron lines — ASUS geometric motif
        Canvas {
    anchors.fill: parent
            opacity: 0.06
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#CC2200";
                ctx.lineWidth = 1.5;
                var step = 60;
                for (var i = -height; i < width + height; i += step) {
                    ctx.beginPath();
                    ctx.moveTo(i, 0);
                    ctx.lineTo(i + height * 0.5, height);
                    ctx.stroke();
                }
            }
        }

        // Top-left counter accent glow
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width * 0.4
            height: parent.height * 0.4
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(0.6, 0.05, 0.05, 0.06) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    pageContent: Item {
        Rog.RogSettings {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
