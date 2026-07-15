#!/usr/bin/env -S python3 -u
import os
import sys
import json
import math

def format_size(bytes_size):
    if bytes_size == 0:
        return "0 B"
    size_name = ("B", "KB", "MB", "GB", "TB")
    i = int(math.floor(math.log(bytes_size, 1024)))
    p = math.pow(1024, i)
    s = round(bytes_size / p, 2)
    return f"{s} {size_name[i]}"

def main():
    if len(sys.argv) < 2:
        path = os.path.expanduser("~")
    else:
        path = os.path.expanduser(sys.argv[1])
        
    filter_mode = sys.argv[2] if len(sys.argv) > 2 else "all"

    # Normalize path
    path = os.path.abspath(path)
    if not os.path.exists(path) or not os.path.isdir(path):
        print(json.dumps({"error": "Directory does not exist", "path": path, "items": []}))
        sys.stdout.flush()
        return

    try:
        items = []
        for item in os.listdir(path):
            if item.startswith("."):
                continue # Skip hidden files
                
            full_path = os.path.join(path, item)
            try:
                is_dir = os.path.isdir(full_path)
                
                # Apply filter
                if not is_dir and filter_mode == "images":
                    ext = os.path.splitext(item)[1].lower()
                    if ext not in (".png", ".jpg", ".jpeg", ".webp", ".gif"):
                        continue
                        
                size_val = os.path.getsize(full_path) if not is_dir else 0
                items.append({
                    "name": item,
                    "isDir": is_dir,
                    "size": format_size(size_val) if not is_dir else "",
                    "path": full_path
                })
            except Exception:
                pass
                
        # Sort directories first, then files
        items.sort(key=lambda x: (not x["isDir"], x["name"].lower()))
        print(json.dumps({"path": path, "items": items}))
        sys.stdout.flush()
    except Exception as e:
        print(json.dumps({"error": str(e), "path": path, "items": []}))
        sys.stdout.flush()

if __name__ == "__main__":
    main()
