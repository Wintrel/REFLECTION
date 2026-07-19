import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../../components" as GlobalComponents

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    implicitHeight: 200

    signal easterEggTriggered()

    // --- Easter egg click tracking ---
    property int _clickCount: 0

    Timer {
        id: clickResetTimer
        interval: 3000
        onTriggered: root._clickCount = 0
    }

    Rectangle {
        id: headerBg
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(255, 255, 255, 0.02)
        border.width: 1
        border.color: headerMa.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.05)

        Behavior on border.color { ColorAnimation { duration: 300 } }

        MouseArea {
            id: headerMa
            anchors.fill: parent
            hoverEnabled: true
            z: 1
            onClicked: {
                root._clickCount++
                clickResetTimer.restart()
                if (root._clickCount >= 7) {
                    root._clickCount = 0
                    root.easterEggTriggered()
                }
            }
        }

        // Rounded mask for visual content clipping
        Rectangle {
            id: contentMask
            anchors.fill: parent
            radius: 12
            visible: false
        }

        // All background visual layers (masked to rounded rect)
        Item {
            id: bgContent
            anchors.fill: parent

            // Base fill
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(255, 255, 255, 0.02)
            }

            // Breathing radial gradient — slow nebula pulse
            RadialGradient {
                anchors.fill: parent

                property real cx: 0
                property real cy: 0

                SequentialAnimation on cx {
                    loops: Animation.Infinite
                    running: root.visible
                    NumberAnimation { to: 30; duration: 8000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: -30; duration: 8000; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on cy {
                    loops: Animation.Infinite
                    running: root.visible
                    NumberAnimation { to: 20; duration: 10000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: -20; duration: 10000; easing.type: Easing.InOutSine }
                }

                horizontalOffset: cx
                verticalOffset: cy

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: {
                            if (root.theme) {
                                var c = root.theme.accentPrimary
                                return Qt.rgba(c.r, c.g, c.b, 0.06)
                            }
                            return Qt.rgba(0.29, 0.87, 0.5, 0.06)
                        }
                    }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Back starfield layer — dim, sparse, shifts up on hover for depth
            GlobalComponents.Starfield {
                anchors.fill: parent
                starCount: 25
                starColor: root.theme ? root.theme.textSub : "#888"
                opacity: 0.25

                transform: Translate {
                    y: headerMa.containsMouse ? -3 : 0
                    Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
            }

            // Mid starfield layer — neutral, static anchor
            GlobalComponents.Starfield {
                anchors.fill: parent
                starCount: 35
                starColor: "#FFFFFF"
                opacity: 0.35
            }

            // Front starfield layer — accent-colored, shifts down on hover
            GlobalComponents.Starfield {
                anchors.fill: parent
                starCount: 20
                starColor: root.theme ? root.theme.accentPrimary : "#4ADE80"
                opacity: 0.5

                transform: Translate {
                    y: headerMa.containsMouse ? 3 : 0
                    Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: contentMask
            }
        }

        // --- Foreground content ---
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            // Animated logo icon
            Text {
                id: logoIcon
                Layout.alignment: Qt.AlignHCenter
                text: "blur_on"
                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                font.pixelSize: 64
                color: root.theme ? root.theme.accentPrimary : "#4ADE80"

                transformOrigin: Item.Center
                scale: headerMa.containsMouse ? 1.12 : 1.0
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

                // Continuous rotation — speeds up on hover
                RotationAnimator on rotation {
                    id: rotAnim
                    from: 0
                    to: 360
                    duration: 25000
                    loops: Animation.Infinite
                    running: true
                }

                Connections {
                    target: headerMa
                    function onContainsMouseChanged() {
                        rotAnim.duration = headerMa.containsMouse ? 8000 : 25000
                    }
                }

                // Glow effect with pulsing when idle, steady when hovered
                layer.enabled: true
                layer.effect: DropShadow {
                    id: logoGlow
                    transparentBorder: true
                    color: root.theme ? root.theme.accentPrimary : "#4ADE80"
                    radius: headerMa.containsMouse ? 24 : 16
                    samples: 49

                    property real pulseOpacity: 0.3
                    SequentialAnimation on pulseOpacity {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 0.8; duration: 2500; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.3; duration: 2500; easing.type: Easing.InOutSine }
                    }

                    opacity: headerMa.containsMouse ? 0.6 : pulseOpacity

                    Behavior on radius { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
                }
            }

            // Gradient title
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: titleText.implicitWidth
                height: titleText.implicitHeight

                Text {
                    id: titleText
                    text: "Reflection"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.weight: Font.Black
                    color: "white"
                    visible: false
                }

                LinearGradient {
                    anchors.fill: parent
                    source: titleText
                    start: Qt.point(0, 0)
                    end: Qt.point(width, height)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.theme ? root.theme.textMain : "#FFF" }
                        GradientStop { position: 1.0; color: root.theme ? root.theme.accentPrimary : "#4ADE80" }
                    }
                }
            }

            // Version
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "v1.1.0"
                font.family: "Inter"
                font.pixelSize: 12
                color: root.theme ? root.theme.textSub : "#888"
            }

            // Philosophy tagline
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                text: "Highlights attention. Never demands it."
                font.family: "Inter"
                font.pixelSize: 11
                font.italic: true
                color: root.theme ? root.theme.textSub : "#888"
                opacity: 0.6
            }
        }
    }
}
