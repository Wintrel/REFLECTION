import re

with open("ui/panels/dynamic_island/components/PromptContent.qml", "r") as f:
    lines = f.readlines()

new_lines = []
in_std = False
in_bt = False
for i, line in enumerate(lines):
    if "Standard Prompt Layout" in line:
        in_std = True
        in_bt = False
    elif "Bluetooth Passkey Prompt Layout" in line:
        in_std = False
        in_bt = True
        
    if "isVisible ?" in line:
        if in_std:
            line = line.replace("isVisible ?", '(root.isActive && PromptService.promptType !== "bluetooth_passkey") ?')
        elif in_bt:
            line = line.replace("isVisible ?", '(root.isActive && PromptService.promptType === "bluetooth_passkey") ?')
    new_lines.append(line)

with open("ui/panels/dynamic_island/components/PromptContent.qml", "w") as f:
    f.writelines(new_lines)
