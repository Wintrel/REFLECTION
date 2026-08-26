#!/usr/bin/env python3
import os
import sys
import struct
import ctypes

IN_CREATE = 0x00000100
IN_DELETE = 0x00000200
IN_MOVED_TO = 0x00000080
IN_MOVED_FROM = 0x00000040

WATCH_DIR = "/var/lib/pacman"
LOCK_FILE = "db.lck"

def main():
    if not os.path.exists(WATCH_DIR):
        sys.exit(0)

    # Initial state check
    if os.path.exists(os.path.join(WATCH_DIR, LOCK_FILE)):
        print("START", flush=True)

    try:
        libc = ctypes.CDLL(None)
        inotify_init1 = libc.inotify_init1
        inotify_add_watch = libc.inotify_add_watch
        
        fd = inotify_init1(0)
        if fd < 0:
            sys.exit(1)
            
        wd = inotify_add_watch(fd, WATCH_DIR.encode('utf-8'), IN_CREATE | IN_DELETE | IN_MOVED_TO | IN_MOVED_FROM)
        if wd < 0:
            sys.exit(1)

        # inotify_event struct format: int wd, uint32_t mask, uint32_t cookie, uint32_t len
        EVENT_FMT = 'iIII'
        EVENT_SIZE = struct.calcsize(EVENT_FMT)

        while True:
            data = os.read(fd, 2048)
            if not data:
                break
            
            offset = 0
            while offset + EVENT_SIZE <= len(data):
                wd, mask, cookie, length = struct.unpack_from(EVENT_FMT, data, offset)
                name_bytes = data[offset + EVENT_SIZE : offset + EVENT_SIZE + length]
                name = name_bytes.rstrip(b'\x00').decode('utf-8', errors='ignore')
                offset += EVENT_SIZE + length

                if name == LOCK_FILE:
                    if mask & (IN_CREATE | IN_MOVED_TO):
                        print("START", flush=True)
                    elif mask & (IN_DELETE | IN_MOVED_FROM):
                        print("STOP", flush=True)

    except Exception as e:
        sys.stderr.write(f"Watcher error: {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()

