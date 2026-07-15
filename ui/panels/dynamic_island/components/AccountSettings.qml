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
    
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        
        ColumnLayout {
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
