import QtQuick
import QtQuick.Layouts

// CategoryStage — shared layout component for all immersive settings pages.
// Provides: ambient background layer (z:0), page header (title + subtitle),
// and a content area (z:1) that fills the remaining space.
//
// Usage: set ambientContent and pageContent to Item instances; they are
// reparented at runtime into the correct layers.
Item {
    id: stageRoot

    property var theme
    property int categoryIndex
    property string categoryTitle: ""
    property string categorySubtitle: ""
    property bool isCurrentPage: false
    readonly property real workspaceWidth: Math.min(Math.max(0, width - 64), 1120)
    readonly property real workspaceGutter: Math.max(32, (width - workspaceWidth) / 2)

    // These are set by each concrete stage as inline Item { ... } children.
    // They get reparented into ambientLayer / contentLayer on assignment.
    property Item ambientContent: null
    property Item pageContent: null

    anchors.fill: parent

    // Cross-dissolve when switching categories
    opacity: stageRoot.isCurrentPage ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

    // ── Ambient layer (behind header and content) ──────────────────
    Item {
        id: ambientLayer
        anchors.fill: parent
        z: 0
    }

    onAmbientContentChanged: {
        if (ambientContent) {
            ambientContent.parent = ambientLayer;
            ambientContent.anchors.fill = ambientLayer;
        }
    }

    // ── Page header ────────────────────────────────────────────────
    Item {
        id: stageHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        z: 1

        Rectangle {
            id: titleAccentBar
            anchors.left: parent.left
            anchors.leftMargin: stageRoot.workspaceGutter
            anchors.verticalCenter: titleCol.verticalCenter
            width: 3
            height: 32
            radius: 2
            color: stageRoot.theme ? stageRoot.theme.accentPrimary : "#5151AD"
        }

        Column {
            id: titleCol
            anchors.left: titleAccentBar.right
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: stageRoot.categoryTitle
                font.family: stageRoot.theme ? stageRoot.theme.fontMain : "Inter"
                font.pixelSize: 30
                font.weight: Font.Bold
                color: stageRoot.theme ? stageRoot.theme.textMain : "#FFF"
            }

            Text {
                text: stageRoot.categorySubtitle
                font.family: stageRoot.theme ? stageRoot.theme.fontMain : "Inter"
                font.pixelSize: 13
                color: stageRoot.theme ? stageRoot.theme.textSub : "#888"
                visible: stageRoot.categorySubtitle !== ""
            }
        }

        // Thin bottom separator
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: stageRoot.workspaceGutter
            anchors.rightMargin: stageRoot.workspaceGutter
            height: 1
            color: Qt.rgba(255, 255, 255, 0.05)
        }
    }

    // ── Content area (below header) ────────────────────────────────
    Item {
        id: contentLayer
        anchors.top: stageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: stageRoot.workspaceGutter
        anchors.rightMargin: stageRoot.workspaceGutter
        anchors.bottomMargin: 32
        anchors.topMargin: 24
        z: 1
    }

    onPageContentChanged: {
        if (pageContent) {
            pageContent.parent = contentLayer;
            pageContent.anchors.fill = contentLayer;
        }
    }
}
