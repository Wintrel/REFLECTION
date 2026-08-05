#!/usr/bin/env python3
"""Private atomic storage helper for Reflection assistant conversations."""

import json
import os
from pathlib import Path
import sys
import tempfile


def atomic_write(path: Path, contents: str) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(path.parent, 0o700)
    descriptor, temporary_name = tempfile.mkstemp(
        dir=path.parent, prefix=f".{path.name}.", text=True
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as temporary_file:
            temporary_file.write(contents)
            temporary_file.flush()
            os.fsync(temporary_file.fileno())
        os.chmod(temporary_name, 0o600)
        os.replace(temporary_name, path)
    finally:
        try:
            os.unlink(temporary_name)
        except FileNotFoundError:
            pass

1
def validated_conversation_path(storage_root: Path, requested_path: str) -> Path:
    conversations_root = (storage_root / "conversations").resolve()
    path = Path(requested_path).resolve()
    if path.parent != conversations_root or path.suffix != ".json":
        raise ValueError("refusing path outside the conversations directory")
    return path


def main() -> None:
    storage_root = Path(sys.argv[1]).expanduser().resolve()
    conversations_root = storage_root / "conversations"
    conversations_root.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(storage_root, 0o700)
    os.chmod(conversations_root, 0o700)
    print('{"type":"ready"}', flush=True)

    for line in sys.stdin:
        try:
            command = json.loads(line)
            operation = command.get("operation")
            requested_path = command.get("path", "")

            if operation == "write-index":
                path = Path(requested_path).resolve()
                if path != (storage_root / "index.json").resolve():
                    raise ValueError("invalid index path")
                atomic_write(path, command.get("contents", "{}"))
            elif operation == "write-conversation":
                path = validated_conversation_path(storage_root, requested_path)
                atomic_write(path, command.get("contents", "{}"))
            elif operation == "delete-conversation":
                path = validated_conversation_path(storage_root, requested_path)
                path.unlink(missing_ok=True)
            elif operation == "rename-conversation":
                path = validated_conversation_path(storage_root, requested_path)
                conversation = json.loads(path.read_text(encoding="utf-8"))
                conversation["title"] = str(command.get("title", "Conversation"))
                atomic_write(path, json.dumps(conversation, indent=2, ensure_ascii=False))
            else:
                raise ValueError("unknown storage operation")

            print(json.dumps({"type": "complete", "operation": operation}), flush=True)
        except Exception as error:  # Keep the helper alive after a bad command.
            print(json.dumps({"type": "error", "message": str(error)}), flush=True)


if __name__ == "__main__":
    main()
