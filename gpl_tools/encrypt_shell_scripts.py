#!/usr/bin/env python3

import os
import secrets
import shlex
import stat
import subprocess
import sys
from pathlib import Path


MARKER = "# GPL-SHELL-PROTECTED v1"
PAYLOAD_TAG = "__GPL_SHELL_PROTECTED_PAYLOAD__"
SUPPORTED_INTERPRETERS = {"/bin/sh", "/bin/bash"}


def die(message: str) -> None:
    print(f"[encrypt_shell_scripts] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def is_shell_script(path: Path) -> bool:
    if not path.is_file():
        return False

    try:
        with path.open("r", encoding="utf-8") as handle:
            first_line = handle.readline()
            second_line = handle.readline()
    except UnicodeDecodeError:
        return False

    if MARKER in second_line:
        return False

    return first_line.startswith("#!") and ("sh" in first_line or "bash" in first_line)


def parse_interpreter(path: Path) -> str:
    first_line = path.read_text(encoding="utf-8").splitlines()[0]
    tokens = shlex.split(first_line[2:].strip())
    if len(tokens) != 1 or tokens[0] not in SUPPORTED_INTERPRETERS:
        die(f"unsupported shebang in {path}: {first_line.strip()}")
    return tokens[0]


def encrypt_with_openssl(text: str, passphrase: str) -> str:
    result = subprocess.run(
        [
            "openssl",
            "enc",
            "-aes-256-cbc",
            "-a",
            "-A",
            "-md",
            "sha256",
            "-pbkdf2",
            "-pass",
            f"pass:{passphrase}",
        ],
        input=text,
        text=True,
        capture_output=True,
        check=True,
    )
    return result.stdout.strip()


def build_wrapper(interpreter: str, payload: str, passphrase: str) -> str:
    lines = [
        f"#!{interpreter}",
        MARKER,
        f"__gpl_sc_interpreter={shlex.quote(interpreter)}",
        "__gpl_sc_runner=''",
        "for __gpl_sc_candidate in /usr/bin/openssl /apps/bin/openssl /bin/openssl /sbin/openssl; do",
        '    if [ -x "$__gpl_sc_candidate" ]; then',
        '        __gpl_sc_runner="$__gpl_sc_candidate"',
        "        break",
        "    fi",
        "done",
        'if [ -z "$__gpl_sc_runner" ]; then',
        '    __gpl_sc_runner="$(command -v openssl 2>/dev/null || true)"',
        "fi",
        'if [ -z "$__gpl_sc_runner" ]; then',
        '    echo "$0: missing openssl runtime" >&2',
        "    return 127 2>/dev/null || exit 127",
        "fi",
        '__gpl_sc_script="$(',
        '    "$__gpl_sc_runner" enc -d -aes-256-cbc -a -A -md sha256 -pbkdf2 \\',
        f"        -pass pass:{shlex.quote(passphrase)} <<'{PAYLOAD_TAG}'",
        payload,
        PAYLOAD_TAG,
        ')" || {',
        '    echo "$0: decrypt failed" >&2',
        "    return 127 2>/dev/null || exit 127",
        "}",
        "if ( return 0 2>/dev/null ); then",
        '    eval "$__gpl_sc_script"',
        "else",
        '    exec "$__gpl_sc_interpreter" -c "$__gpl_sc_script" "$0" "$@"',
        "fi",
        "",
    ]
    return "\n".join(lines)


def protect_script(path: Path) -> None:
    source_text = path.read_text(encoding="utf-8")
    interpreter = parse_interpreter(path)
    passphrase = secrets.token_hex(16)
    payload = encrypt_with_openssl(source_text, passphrase)
    wrapper = build_wrapper(interpreter, payload, passphrase)

    current_mode = stat.S_IMODE(path.stat().st_mode)
    path.write_text(wrapper, encoding="utf-8")
    os.chmod(path, current_mode)
    print(f"[encrypt_shell_scripts] protected {path}")


def iter_shell_scripts(root: Path):
    for path in sorted(root.rglob("*")):
        if is_shell_script(path):
            yield path


def main(argv: list[str]) -> None:
    if len(argv) < 2:
        die("Usage: encrypt_shell_scripts.py <script-root> [<script-root> ...]")

    for root_arg in argv[1:]:
        root = Path(root_arg)
        if not root.exists():
            die(f"missing path: {root}")
        for path in iter_shell_scripts(root):
            protect_script(path)


if __name__ == "__main__":
    main(sys.argv)
