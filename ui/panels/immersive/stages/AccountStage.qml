import QtQuick
import QtQuick.Layouts
import "../../../../core/services/system"

// Account category stage
CategoryStage {
    id: root
    categoryTitle: "Account"
    categorySubtitle: "Profile & account details"

    ambientContent: Item {
        // Left accent radial wash
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: root.theme ?
                        Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.07) :
                        Qt.rgba(0.3, 0.3, 0.7, 0.07)
                }
                GradientStop { position: 0.6; color: "transparent" }
            }
        }

        // Profile banner as subtle ambient wash
        Image {
            anchors.fill: parent
            source: AccountService.bannerPicture
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: 0.12
            visible: source.toString() !== ""
        }
    }

    pageContent: Item {
        Text {
            anchors.centerIn: parent
            text: "Account settings coming soon"
            font.family: root.theme ? root.theme.fontMain : "Inter"
            font.pixelSize: 14
            color: root.theme ? root.theme.textSub : "#888"
        }
    }
}
