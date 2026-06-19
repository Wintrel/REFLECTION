import QtQuick
import Quickshell

import "core/services/system"
import Quickshell.Services.Notifications

import "ui/panels/dynamic_island"
import "ui/panels/taskbar"

ShellRoot {
    id: root
    
    DynamicIsland {}
    Taskbar {}
    Component.onCompleted: WallpaperService
}
