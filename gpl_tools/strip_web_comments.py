#!/usr/bin/env python3

import re
import sys
from pathlib import Path


COMMENT_PATTERNS = [
    (re.compile(r"<!--.*?-->", re.DOTALL), ""),
    (re.compile(r"/\*.*?\*/", re.DOTALL), ""),
    (re.compile(r"(^|\s)//[^\n]*", re.MULTILINE), lambda match: "" if match.group(1) == "" else match.group(1)),
]

TARGET_SUFFIXES = {".html", ".htm", ".js", ".css"}


def strip_comments(text: str) -> str:
    updated = text
    for pattern, replacement in COMMENT_PATTERNS:
        updated = pattern.sub(replacement, updated)
    updated = re.sub(r"\n{3,}", "\n\n", updated)
    return updated


def process_file(path: Path) -> None:
    original = path.read_text(encoding="utf-8", errors="ignore")
    updated = strip_comments(original)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        print(f"[gpl] stripped comments: {path}")


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: strip_web_comments.py <web-root>", file=sys.stderr)
        return 2

    root = Path(sys.argv[1]).resolve()
    if not root.exists():
        print(f"[gpl] ERROR: path does not exist: {root}", file=sys.stderr)
        return 2

    for path in sorted(root.rglob("*")):
        if path.is_file() and path.suffix.lower() in TARGET_SUFFIXES:
            process_file(path)

    return 0


if __name__ == "__main__":
    sys.exit(main())