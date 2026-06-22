import QtQuick
import Quickshell

import "core/services/system"
import Quickshell.Services.Notifications

import "ui/panels/dynamic_island"
import "ui/panels/taskbar"
import "ui/panels/lockscreen"
import "ui/panels/screenshot"

ShellRoot {
    id: root
    
    DynamicIsland {}
    Taskbar {}
    Lockscreen { id: lockscreen }
    RegionSelector {}
    Component.onCompleted: WallpaperService
}
