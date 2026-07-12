import os
import re
import glob

def process_file(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    new_lines = []
    
    # We will search for 'property bool isVisible: <expr>'
    # and then replace 'isVisible ?' with '<expr> ?' in subsequent lines until the next 'Item {' or similar, but actually we can just find the nearest 'property bool isVisible:' backwards.
    
    for i, line in enumerate(lines):
        if 'isVisible ?' in line:
            # search backwards for property bool isVisible
            expr = None
            for j in range(i-1, max(-1, i-20), -1):
                m = re.search(r'property bool isVisible:\s*(.+)', lines[j])
                if m:
                    expr = m.group(1).strip()
                    break
            
            if expr:
                line = line.replace('isVisible ?', f'({expr}) ?')
                
        new_lines.append(line)
        
    with open(filepath, 'w') as f:
        f.writelines(new_lines)

for root, _, files in os.walk('ui'):
    for f in files:
        if f.endswith('.qml'):
            process_file(os.path.join(root, f))
