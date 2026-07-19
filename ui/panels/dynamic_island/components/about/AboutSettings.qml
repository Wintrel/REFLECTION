import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: colLayout.implicitHeight
        clip: true

        flickDeceleration: 1000
        maximumFlickVelocity: 4000
        boundsBehavior: Flickable.DragAndOvershootBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: colLayout
            width: parent.width
            spacing: 32

            HeroHeader {
                theme: root.theme
                onEasterEggTriggered: easterEgg.trigger()
            }

            SystemInfoCard { theme: root.theme }

            FeaturesCard { theme: root.theme }

            CreditsCard { theme: root.theme }

            Item { Layout.preferredHeight: 40 }
        }
    }

    // Easter egg overlay (on top of everything)
    EasterEggOverlay {
        id: easterEgg
    }
}
