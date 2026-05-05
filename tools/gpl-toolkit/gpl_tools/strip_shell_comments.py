#!/usr/bin/env python3

import re
import sys
from pathlib import Path


TARGET_SUFFIXES = {".sh"}


def find_comment_start(line: str) -> int | None:
    in_single = False
    in_double = False
    escaped = False

    for index, char in enumerate(line):
        if escaped:
            escaped = False
            continue

        if char == "\\" and not in_single:
            escaped = True
            continue

        if char == "'" and not in_double:
            in_single = not in_single
            continue

        if char == '"' and not in_single:
            in_double = not in_double
            continue

        if char == "#" and not in_single and not in_double:
            if index == 0 or line[index - 1].isspace():
                return index

    return None


def strip_comments(text: str) -> str:
    lines = text.splitlines(keepends=True)
    stripped_lines: list[str] = []

    for line_number, line in enumerate(lines):
        line_body = line.rstrip("\n")
        newline = "\n" if line.endswith("\n") else ""

        if line_number == 0 and line_body.startswith("#!"):
            stripped_lines.append(line)
            continue

        comment_start = find_comment_start(line_body)
        if comment_start is None:
            stripped_lines.append(line)
            continue

        kept = line_body[:comment_start].rstrip()
        if kept:
            stripped_lines.append(f"{kept}{newline}")

    updated = "".join(stripped_lines)
    updated = re.sub(r"\n{3,}", "\n\n", updated)
    return updated


def process_file(path: Path) -> None:
    original = path.read_text(encoding="utf-8", errors="ignore")
    updated = strip_comments(original)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        print(f"[gpl] stripped shell comments: {path}")


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: strip_shell_comments.py <script-root>", file=sys.stderr)
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