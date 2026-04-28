#!/usr/bin/env python3

import argparse
import os
import shutil
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import cast

from encrypt_shell_scripts import is_shell_script, protect_script


WRAPPER_RULES = {
    "add_files": {
        "sbin/fw_upgrade.sh",
    },
    "wl_scripts": {
        "wl_define.sh",
        "wl_define.sh.BE5040",
        "wl_define.sh.BE7200",
    },
}

SHC_RULES = {
    "add_files": {
        "sbin/automount.sh",
        "sbin/dl.sh",
        "sbin/dropbear_for_root.sh",
        "sbin/dropbear_for_root_elx.sh",
        "sbin/emergency_mode.sh",
        "sbin/evtest.sh",
        "sbin/guest_network.sh",
        "sbin/guest_network_add.sh",
        "sbin/guest_network_auth.sh",
        "sbin/guest_network_check.sh",
        "sbin/guest_network_mail.sh",
        "sbin/guest_network_release.sh",
        "sbin/mount_storage_manufacture.sh",
        "sbin/mt7988d-smp.sh",
        "sbin/smp.sh",
        "sbin/state.sh",
        "sbin/sysctl.sh",
        "sbin/udhcpc_watchdog.sh",
        "sbin/wifi_bridge_port_checker.sh",
        "sbin/wifi_if_info.sh",
    },
    "wl_scripts": {
        "mtkwifi.sh",
        "mtkwifi.sh.BE5040",
        "mtkwifi.sh.BE7200",
        "owe_transition_ie.sh",
        "wl_dbox2dat.sh",
        "wl_dbox2hostapd.sh",
        "wl_dbox2wpasupplicant.sh",
        "wl_wps_action.sh",
        "wpsd.sh",
    },
}


def die(message: str) -> None:
    print(f"[protect_runtime_shell_scripts] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def detect_domain(root: Path) -> str:
    name = root.name
    if name == "add_files":
        return "add_files"
    if name == "wl_scripts":
        return "wl_scripts"
    die(f"unsupported protection root: {root}")
    raise AssertionError("unreachable")


def iter_shell_scripts(root: Path):
    for path in sorted(root.rglob("*")):
        if is_shell_script(path):
            yield path


def classify_script(domain: str, rel_path: str) -> str:
    if rel_path in WRAPPER_RULES[domain]:
        return "wrapper"
    if rel_path in SHC_RULES[domain]:
        return "shc"
    return "wrapper"


def compile_with_shc(path: Path, shc_path: str, cc_path: str, strip_path: str | None) -> None:
    current_mode = stat.S_IMODE(path.stat().st_mode)

    with tempfile.TemporaryDirectory(prefix="gpl-shc-") as tmp_dir_name:
        tmp_dir = Path(tmp_dir_name)
        input_path = tmp_dir / path.name
        output_path = tmp_dir / f"{path.name}.out"
        shutil.copy2(path, input_path)

        # shc calls "$CC file.x.c -o output" via system().  We use a wrapper
        # script as CC so we can patch `#define BUSYBOXON 0` to 1 *inside* the
        # generated .x.c before the real target gcc sees it.  A compiler -D flag
        # alone cannot override a #define that appears later in the source.
        #
        # With BUSYBOXON=1 the generated binary calls:
        #   execvp("/bin/sh", ["busybox", "sh", <script>, ...])
        # instead of:
        #   execvp("/bin/sh", ["automount.sh", <script>, ...])
        # which avoids the BusyBox "applet not found" error that occurs when
        # BusyBox receives a non-applet name as argv[0].
        wrapper_path = tmp_dir / "cc.sh"
        wrapper_path.write_text(
            "#!/bin/sh\n"
            "for _a; do\n"
            "  if [ -f \"$_a\" ]; then\n"
            "    sed -i 's/define BUSYBOXON[[:space:]]*0/define BUSYBOXON    1/' \"$_a\"\n"
            "  fi\n"
            "done\n"
            f"exec {cc_path} \"$@\"\n"
        )
        wrapper_path.chmod(0o755)

        env = os.environ.copy()
        env["CC"] = str(wrapper_path)

        result = subprocess.run(
            [shc_path, "-r", "-f", str(input_path), "-o", str(output_path)],
            text=True,
            capture_output=True,
            env=env,
        )
        if result.returncode != 0:
            stderr = result.stderr.strip()
            stdout = result.stdout.strip()
            detail = stderr or stdout or "unknown shc failure"
            die(f"shc failed for {path}: {detail}")

        if not output_path.exists():
            die(f"shc did not produce output for {path}")

        if strip_path is not None:
            strip_result = subprocess.run(
                [strip_path, str(output_path)],
                text=True,
                capture_output=True,
            )
            if strip_result.returncode != 0:
                stderr = strip_result.stderr.strip()
                stdout = strip_result.stdout.strip()
                detail = stderr or stdout or "unknown strip failure"
                die(f"strip failed for {path}: {detail}")

        path.write_bytes(output_path.read_bytes())
        os.chmod(path, current_mode)


def protect_root(root: Path, shc_path: str, cc_path: str, strip_path: str | None, dry_run: bool) -> None:
    domain = detect_domain(root)

    for path in iter_shell_scripts(root):
        rel_path = path.relative_to(root).as_posix()
        action = classify_script(domain, rel_path)
        print(f"[protect_runtime_shell_scripts] {action:7s} {path}")

        if dry_run:
            continue

        if action == "wrapper":
            protect_script(path)
        elif action == "shc":
            compile_with_shc(path, shc_path, cc_path, strip_path)
        else:
            die(f"unknown action {action} for {path}")


def main(argv: list[str]) -> None:
    parser = argparse.ArgumentParser(
        description="Protect runtime shell scripts with a mix of wrapper encryption and shc binaries."
    )
    parser.add_argument("roots", nargs="+", help="script roots to protect")
    parser.add_argument("--shc", required=True, help="path to shc executable")
    parser.add_argument("--cc", required=True, help="target compiler for shc output")
    parser.add_argument("--strip", help="target strip tool for shc output")
    parser.add_argument("--dry-run", action="store_true", help="show actions without modifying files")
    args = parser.parse_args(argv[1:])

    if not args.shc.strip():
        die("missing shc executable")

    shc_path = cast(str | None, shutil.which(args.shc))
    if shc_path is None:
        shc_candidate = Path(args.shc)
        if not shc_candidate.exists() or not os.access(shc_candidate, os.X_OK):
            die(f"missing shc executable: {args.shc}")
        shc_path = str(shc_candidate)

    assert shc_path is not None

    if not os.access(shc_path, os.X_OK):
        die(f"missing shc executable: {args.shc}")

    cc_path = Path(args.cc)
    if not cc_path.exists() or not os.access(cc_path, os.X_OK):
        die(f"missing compiler: {args.cc}")

    strip_path: str | None = None
    if args.strip:
        strip_candidate = Path(args.strip)
        if not strip_candidate.exists() or not os.access(strip_candidate, os.X_OK):
            die(f"missing strip tool: {args.strip}")
        strip_path = str(strip_candidate)

    for root_arg in args.roots:
        root = Path(root_arg)
        if not root.exists():
            die(f"missing path: {root}")
        protect_root(root, shc_path, str(cc_path), strip_path, args.dry_run)


if __name__ == "__main__":
    main(sys.argv)