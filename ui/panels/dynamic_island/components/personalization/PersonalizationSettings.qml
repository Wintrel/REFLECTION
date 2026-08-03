import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    property int currentTab: 0 // 0: Theme, 1: Wallpaper, 2: Geometry & Effects

    readonly property var tabModel: [
        { label: "Theme & Colors", icon: "palette", description: "Color palettes, accents and custom theme values" },
        { label: "Wallpaper", icon: "wallpaper", description: "Desktop imagery and background selection" },
        { label: "Geometry & Effects", icon: "animation", description: "Corner geometry, motion and edge illumination" }
    ]

    component SectionSurface: Rectangle {
        default property alias content: surfaceColumn.data
        Layout.fillWidth: true
        implicitHeight: surfaceColumn.implicitHeight + 40
        radius: 18
        color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.70) : Qt.rgba(0.08, 0.08, 0.10, 0.70)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.06)

        ColumnLayout {
            id: surfaceColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // Tab Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 14
            color: Qt.rgba(255, 255, 255, 0.025)
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.055)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                Repeater {
                    model: root.tabModel
                    delegate: Rectangle {
                        required property int index
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        property bool isSelected: root.currentTab === index
                        color: isSelected && root.theme
                            ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.17)
                            : (maTab.containsMouse ? Qt.rgba(255, 255, 255, 0.045) : "transparent")
                        border.width: isSelected ? 1 : 0
                        border.color: isSelected && root.theme ? root.theme.accentPrimary : "transparent"

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 7
                            Text {
                                text: modelData.icon
                                font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                                font.pixelSize: 16
                                color: isSelected && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
                            }
                            Text {
                                text: modelData.label
                                font.family: root.theme ? root.theme.fontMain : "Inter"
                                font.pixelSize: 12
                                font.weight: isSelected ? Font.DemiBold : Font.Normal
                                color: isSelected && root.theme ? root.theme.accentPrimary : (root.theme ? root.theme.textSub : "#AAA")
                            }
                        }

                        MouseArea {
                            id: maTab
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = index
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            radius: 13
            color: Qt.rgba(255, 255, 255, 0.018)
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.05)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 11
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 9
                    color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.13) : Qt.rgba(0.4, 0.4, 1, 0.13)
                    Text {
                        anchors.centerIn: parent
                        text: root.tabModel[root.currentTab].icon
                        font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                        font.pixelSize: 17
                        color: root.theme ? root.theme.accentPrimary : "#8888DD"
                    }
                }
                ColumnLayout {
                    spacing: 1
                    Text {
                        text: root.tabModel[root.currentTab].label
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: root.theme ? root.theme.textMain : "#FFF"
                    }
                    Text {
                        text: root.tabModel[root.currentTab].description
                        font.family: root.theme ? root.theme.fontMain : "Inter"
                        font.pixelSize: 10
                        color: root.theme ? root.theme.textSub : "#888"
                    }
                }
            }
        }
        
        // Content Area
        Flickable {
            id: personalizationFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentCol.implicitHeight
            clip: true
            
            flickDeceleration: 1000
            maximumFlickVelocity: 4000
            boundsBehavior: Flickable.DragAndOvershootBounds
            
            Behavior on contentY {
                enabled: !personalizationFlickable.dragging && !personalizationFlickable.flicking
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
            
            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 24
                
                // --- Tab 0: Theme & Colors ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    visible: root.currentTab === 0
                    
                    SectionSurface {
                        ThemeCard { theme: root.theme }
                        CustomThemeEditor { theme: root.theme }
                    }
                }
                
                // --- Tab 1: Wallpaper ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    visible: root.currentTab === 1
                    
                    SectionSurface { WallpaperCard { theme: root.theme } }
                }
                
                // --- Tab 2: Geometry & Effects ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    visible: root.currentTab === 2
                    
                    GridLayout {
                        Layout.fillWidth: true
                        columns: width >= 820 ? 2 : 1
                        columnSpacing: 16
                        rowSpacing: 16
                        SectionSurface {
                            Layout.alignment: Qt.AlignTop
                            GeometryCard { theme: root.theme }
                        }
                        SectionSurface {
                            Layout.alignment: Qt.AlignTop
                            EdgeLightingCard { theme: root.theme }
                        }
                    }
                }
                
                Item { Layout.preferredHeight: 16 }
            }
        }
    }
}
