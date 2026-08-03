import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../core/services/system"
import "../../../../core/state" as State
import "./account" as AccountCards

Item {
    id: root
    property var theme
    Layout.fillWidth: true
    Layout.fillHeight: true

    component SectionSurface: Rectangle {
        default property alias content: sectionColumn.data
        Layout.fillWidth: true
        implicitHeight: sectionColumn.implicitHeight + 36
        radius: 16
        color: root.theme ? Qt.rgba(root.theme.surfaceCard.r, root.theme.surfaceCard.g, root.theme.surfaceCard.b, 0.68) : Qt.rgba(0.08, 0.08, 0.10, 0.68)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.06)

        ColumnLayout {
            id: sectionColumn
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12
        }
    }

    component SectionHeader: Item {
        property string number: ""
        property string icon: ""
        property string title: ""
        property string description: ""

        Layout.fillWidth: true
        implicitHeight: 62

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            spacing: 13

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 12
                color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.13) : Qt.rgba(0.4, 0.4, 1, 0.13)
                border.width: 1
                border.color: root.theme ? Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g, root.theme.accentPrimary.b, 0.20) : Qt.rgba(0.4, 0.4, 1, 0.20)
                Text {
                    anchors.centerIn: parent
                    text: parent.parent.parent.icon
                    font.family: root.theme ? root.theme.fontIcon : "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: root.theme ? root.theme.accentPrimary : "#8888DD"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: parent.parent.parent.title
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.textMain : "#FFF"
                }
                Text {
                    text: parent.parent.parent.description
                    font.family: root.theme ? root.theme.fontMain : "Inter"
                    font.pixelSize: 11
                    color: root.theme ? root.theme.textSub : "#888"
                }
            }

            Text {
                text: parent.parent.number
                font.family: root.theme ? root.theme.fontMain : "Inter"
                font.pixelSize: 10
                font.letterSpacing: 1.2
                font.weight: Font.Bold
                color: root.theme ? root.theme.textMuted : "#666"
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.rgba(255, 255, 255, 0.05)
        }
    }

    Flickable {
        id: accountFlickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentCol.implicitHeight
        clip: true
        flickDeceleration: 1000
        maximumFlickVelocity: 4000
        boundsBehavior: Flickable.StopAtBounds

        Behavior on contentY {
            enabled: !accountFlickable.dragging && !accountFlickable.flicking
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: contentCol
            width: accountFlickable.width
            spacing: 16

            AccountCards.ProfileCard { theme: root.theme }

            SectionHeader {
                number: "01"
                icon: "badge"
                title: "Identity"
                description: "Public account details and how your name appears across Reflection"
            }

            SectionSurface {
                AccountCards.DisplayNameCard { theme: root.theme }
            }

            SectionHeader {
                number: "02"
                icon: "shield_lock"
                title: "Security"
                description: "Credentials, trusted keys and sessions currently using this account"
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 820 ? 2 : 1
                columnSpacing: 16
                rowSpacing: 16

                SectionSurface {
                    Layout.fillHeight: true
                    AccountCards.PasswordCard { theme: root.theme }
                }
                SectionSurface {
                    Layout.fillHeight: true
                    AccountCards.SshKeysCard { theme: root.theme }
                }
            }

            SectionSurface {
                AccountCards.ActiveSessionsCard { theme: root.theme }
            }

            SectionHeader {
                number: "03"
                icon: "settings_account_box"
                title: "System & access"
                description: "Storage, login environment and permissions granted to this account"
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 820 ? 2 : 1
                columnSpacing: 16
                rowSpacing: 16

                SectionSurface {
                    Layout.fillHeight: true
                    AccountCards.StorageQuotaCard { theme: root.theme }
                }
                SectionSurface {
                    Layout.fillHeight: true
                    AccountCards.ShellSelectorCard { theme: root.theme }
                }
            }

            SectionSurface {
                AccountCards.GroupMembershipCard { theme: root.theme }
            }

            Item { Layout.preferredHeight: 16 }
        }
    }

    ProfilePictureCropper {
        id: avatarCropper
        anchors.fill: parent
        theme: root.theme
        onCropped: {
            AccountService.refreshInfo();
        }
    }

    BannerPictureCropper {
        id: bannerCropper
        anchors.fill: parent
        theme: root.theme
        onCropped: {
            AccountService.refreshInfo();
        }
    }
}
