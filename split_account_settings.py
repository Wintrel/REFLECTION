import re

with open("/home/fuyumi/.config/quickshell/reflection/ui/panels/dynamic_island/components/AccountSettings.qml", "r") as f:
    content = f.read()

# The common header for components
header = """import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

Rectangle {
    id: root
    property var theme
    Layout.fillWidth: true
    radius: 12
    color: Qt.rgba(255, 255, 255, 0.03)
    border.width: 1
    border.color: Qt.rgba(255, 255, 255, 0.05)
"""

sections = {
    "ProfileCard": "1. Unified Profile Card",
    "DisplayNameCard": "2. Display Name",
    "PasswordCard": "3. Password",
    "ShellSelectorCard": "4. Default Shell Selector",
    "StorageQuotaCard": "5. Storage Quota",
    "GroupMembershipCard": "6. Group Membership",
    "SshKeysCard": "7. SSH Public Keys",
    "ActiveSessionsCard": "8. Active Login Sessions"
}

def extract_section(content, section_marker, next_marker=None):
    # Find start
    start_idx = content.find(f"// {section_marker}")
    if start_idx == -1: return ""
    
    # We want to extract the Rectangle that starts right after the marker
    rect_start = content.find("Rectangle {", start_idx)
    
    # We need to find the matching closing brace for this Rectangle
    brace_count = 0
    in_rect = False
    end_idx = -1
    for i in range(rect_start, len(content)):
        if content[i] == '{':
            brace_count += 1
            in_rect = True
        elif content[i] == '}':
            brace_count -= 1
            if in_rect and brace_count == 0:
                end_idx = i + 1
                break
                
    if end_idx == -1:
        return ""
        
    return content[rect_start:end_idx]

for card_name, marker in sections.items():
    card_content = extract_section(content, marker)
    
    # Remove the outer Rectangle { ... } properties that we already put in the header
    # We'll just replace the first 'Rectangle {' and its properties with the header
    # But wait, some cards might have custom implicitHeight. 
    # Let's just make the root a clean Rectangle and paste the contents inside?
    # No, it's easier to just take the whole Rectangle, and replace its top-level 'Rectangle {' with the header (without the Rectangle { part, just import).
    
    # Actually, the best way is to keep the original Rectangle exactly as is, and just prepend the imports.
    # The original Rectangle has `Layout.fillWidth: true`, `radius: 12`, etc.
    # So we just prepend the imports.
    
    imports = """import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../../../../core/services/system"
import "../../../../../core/state" as State

"""
    
    # We need to inject `property var theme` into the top level Rectangle.
    # Find the first '{' and insert it after
    first_brace = card_content.find('{')
    if first_brace != -1:
        card_content = card_content[:first_brace+1] + "\n    id: root\n    property var theme\n" + card_content[first_brace+1:]
        
    # For GroupMembershipCard, we need to inject commonGroups
    if card_name == "GroupMembershipCard":
        common_groups = """    property var commonGroups: [
        { name: "wheel", label: "Administrators", desc: "Allows administrative actions via sudo/pkexec", icon: "security" },
        { name: "docker", label: "Docker Engine", desc: "Allows container management without sudo", icon: "layers" },
        { name: "video", label: "Video Hardware", desc: "GPU, webcam, and direct framebuffer access", icon: "videocam" },
        { name: "audio", label: "Audio Hardware", desc: "Direct access to sound card and MIDI hardware", icon: "volume_up" },
        { name: "input", label: "Input Devices", desc: "Access raw mouse, keyboard, and controller devices", icon: "keyboard" },
        { name: "i2c", label: "System Sensors", desc: "Hardware monitor sensors and backlight control", icon: "thermostat" },
        { name: "storage", label: "Device Storage", desc: "Direct mounting of external drives/filesystems", icon: "usb" }
    ]
"""
        card_content = card_content[:first_brace+1] + "\n" + common_groups + card_content[first_brace+1:]
        
    # For PasswordCard, we need to inject passStrength
    if card_name == "PasswordCard":
        pass_strength = """    property int passStrength: {
        var pass = passInput.text;
        if (pass.length === 0) return 0;
        var score = 0;
        if (pass.length >= 8) score += 1;
        if (/[A-Z]/.test(pass)) score += 1;
        if (/[a-z]/.test(pass)) score += 1;
        if (/[0-9]/.test(pass)) score += 1;
        if (/[^A-Za-z0-9]/.test(pass)) score += 1;
        return score; // 0 to 5
    }
"""
        card_content = card_content[:first_brace+1] + "\n" + pass_strength + card_content[first_brace+1:]
        
    final_content = imports + card_content
    
    with open(f"/home/fuyumi/.config/quickshell/reflection/ui/panels/dynamic_island/components/account/{card_name}.qml", "w") as f:
        f.write(final_content)
        
print("Cards extracted successfully.")
