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
            
            AccountCards.ProfileCard { theme: root.theme }
            AccountCards.DisplayNameCard { theme: root.theme }
            AccountCards.PasswordCard { theme: root.theme }
            AccountCards.ShellSelectorCard { theme: root.theme }
            AccountCards.StorageQuotaCard { theme: root.theme }
            AccountCards.GroupMembershipCard { theme: root.theme }
            AccountCards.SshKeysCard { theme: root.theme }
            AccountCards.ActiveSessionsCard { theme: root.theme }
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
