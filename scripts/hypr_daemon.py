#!/usr/bin/env python3
import socket
import sys
import os
import subprocess
import json
import threading

def get_state():
    try:
        ws = json.loads(subprocess.check_output(["hyprctl", "workspaces", "-j"]).decode("utf-8"))
        cls = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"]).decode("utf-8"))
        aws = json.loads(subprocess.check_output(["hyprctl", "activeworkspace", "-j"]).decode("utf-8"))
        mons = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"]).decode("utf-8"))
        state = {
            "workspaces": ws,
            "clients": cls,
            "activeWorkspace": aws,
            "monitors": mons
        }
        print(json.dumps(state), flush=True)
    except Exception as e:
        pass

# Send initial state immediately
get_state()

sock_path = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/run/user/1000"), "hypr", os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", ""), ".socket2.sock")

try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(sock_path)
    f = s.makefile()
    
    for line in f:
        line = line.strip()
        if any(x in line for x in ["workspace>>", "createworkspace>>", "destroyworkspace>>", "openwindow>>", "closewindow>>", "movewindow>>", "activewindow>>"]):
            get_state()
except Exception as e:
    # If socket fails, fallback to polling every 0.5s
    import time
    while True:
        time.sleep(0.5)
        get_state()
