import re

with open("/home/fuyumi/.config/quickshell/reflection/ui/panels/dynamic_island/components/AccountSettings_old.qml", "r") as f:
    content = f.read()

markers = [
    ("ProfileCard", "            // 1. Unified Profile Card"),
    ("DisplayNameCard", "            // 2. Display Name"),
    ("PasswordCard", "            // 3. Password"),
    ("ShellSelectorCard", "            // 4. Default Shell Selector"),
    ("StorageQuotaCard", "            // 5. Storage Quota"),
    ("GroupMembershipCard", "            // 6. Group Membership"),
    ("SshKeysCard", "            // 7. SSH Public Keys"),
    ("ActiveSessionsCard", "            // 8. Active Login Sessions")
]

# The end of the last section is before `    ProfilePictureCropper {`
end_of_sections = "    ProfilePictureCropper {"
end_idx = content.find(end_of_sections)
# But wait, it's inside `ColumnLayout {` and `ScrollView {`. So the end of section 8 is where the ColumnLayout ends.
# Which is `        }` then `    }` then `    ProfilePictureCropper`.
# Let's just use regex or find to find the exact chunk.

for i in range(len(markers)):
    name, marker = markers[i]
    start = content.find(marker)
    if i < len(markers) - 1:
        end = content.find(markers[i+1][1])
    else:
        # For the last one, find the end of ColumnLayout
        # It's basically `        }\n    }\n\n    ProfilePictureCropper`
        end = content.rfind("        }", start, end_idx)
        
    chunk = content[start:end].strip()
    
    # We want to wrap this chunk in a component. 
    # Usually it's an Item, Rectangle, ColumnLayout, etc. 
    # Whatever it is, if we just prepend imports, it should be a valid QML file because it's a single QML object.
    # Is it a single QML object?
    # Let's check! 
    
    imports = """import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

"""
    # Let's inject `property var theme` and `id: root` into the top-level item of the chunk
    # The chunk should start with `Rectangle {` or `ColumnLayout {`
    first_brace = chunk.find('{')
    
    # Inject properties
    injected_props = "\n    id: root\n    property var theme\n"
    
    if name == "GroupMembershipCard":
        injected_props += """    property var commonGroups: [
        { name: "wheel", label: "Administrators", desc: "Allows administrative actions via sudo/pkexec", icon: "security" },
        { name: "docker", label: "Docker Engine", desc: "Allows container management without sudo", icon: "layers" },
        { name: "video", label: "Video Hardware", desc: "GPU, webcam, and direct framebuffer access", icon: "videocam" },
        { name: "audio", label: "Audio Hardware", desc: "Direct access to sound card and MIDI hardware", icon: "volume_up" },
        { name: "input", label: "Input Devices", desc: "Access raw mouse, keyboard, and controller devices", icon: "keyboard" },
        { name: "i2c", label: "System Sensors", desc: "Hardware monitor sensors and backlight control", icon: "thermostat" },
        { name: "storage", label: "Device Storage", desc: "Direct mounting of external drives/filesystems", icon: "usb" }
    ]\n"""
    
    if name == "PasswordCard":
        injected_props += """    property int passStrength: {
        var pass = passInput.text;
        if (pass.length === 0) return 0;
        var score = 0;
        if (pass.length >= 8) score += 1;
        if (/[A-Z]/.test(pass)) score += 1;
        if (/[a-z]/.test(pass)) score += 1;
        if (/[0-9]/.test(pass)) score += 1;
        if (/[^A-Za-z0-9]/.test(pass)) score += 1;
        return score; // 0 to 5
    }\n"""

    chunk = chunk[:first_brace+1] + injected_props + chunk[first_brace+1:]
    
    with open(f"/home/fuyumi/.config/quickshell/reflection/ui/panels/dynamic_island/components/account/{name}.qml", "w") as f:
        f.write(imports + chunk + "\n")
        
print("Extracted successfully.")
