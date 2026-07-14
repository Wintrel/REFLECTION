import QtQuick
import Quickshell

import "core/services/system"
import Quickshell.Services.Notifications

import "ui/panels/dynamic_island"
import "ui/panels/taskbar"
import "ui/panels/lockscreen"
import "ui/panels/screenshot"
import "ui/panels/ambient_idle"
import "ui/panels/edge_lighting"
import "ui/panels/wallpaper_selector"

ShellRoot {
    id: root
    
    DynamicIsland {}
    Taskbar {}
    Lockscreen { id: lockscreen }
    AmbientIdle {}
    RegionSelector {}
    EdgeLighting {}
    WallpaperSelector {}
    
    Component.onCompleted: WallpaperService
}
