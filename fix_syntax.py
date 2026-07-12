import os
import re

for root, _, files in os.walk('ui'):
    for f in files:
        if f.endswith('.qml'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
            
            # replace `\.\((.*?)\) \?` with `.isVisible ?`
            new_content = re.sub(r'\.\((.*?)\) \?', '.isVisible ?', content)
            
            if new_content != content:
                with open(filepath, 'w') as file:
                    file.write(new_content)
