#!/usr/bin/env python3

import re
import sys
from pathlib import Path
from typing import Callable, TypeAlias


AlreadyCheck: TypeAlias = Callable[[str], bool]
RegexReplacement: TypeAlias = str | Callable[[re.Match[str]], str]
PatchStep: TypeAlias = Callable[[Path], None]


MAKEFILE_COMMENT_TARGETS = (
    "**/Makefile_1_gpl",
    "**/Makefile_2_bsp",
    "**/Makefile_3_def",
    "board_cfg/make_tag/*.make",
)
PRESERVED_COPYRIGHT_NAMES = (
    "elx development team",
    "edimax development team",
    "edimiax development team",
)


class PatchFailure(RuntimeError):
    pass


class FileEditor:
    def __init__(self, root: Path, relpath: str):
        self.root = root
        self.relpath = relpath
        self.path = root / relpath
        if not self.path.exists():
            raise PatchFailure(f"missing file: {relpath}")
        self.text = self.path.read_text(encoding="utf-8")
        self.original = self.text

    def replace_literal(self, old: str, new: str, description: str, *, already_check: AlreadyCheck | None = None, optional: bool = False) -> None:
        if old in self.text:
            self.text = self.text.replace(old, new, 1)
            print(f"[gpl] patched {self.relpath}: {description}")
            return
        if already_check and already_check(self.text):
            print(f"[gpl] already patched {self.relpath}: {description}")
            return
        if optional:
            print(f"[gpl] unchanged {self.relpath}: {description}")
            return
        raise PatchFailure(f"pattern not matched in {self.relpath}: {description}")

    def replace_regex(self, pattern: str, repl: RegexReplacement, description: str, *, flags: int = 0, count: int = 0, already_check: AlreadyCheck | None = None, optional: bool = False) -> None:
        compiled = re.compile(pattern, flags)
        if compiled.search(self.text):
            def replacement(match: re.Match[str]) -> str:
                if isinstance(repl, str):
                    return match.expand(repl)
                return repl(match)

            self.text, applied = compiled.subn(replacement, self.text, count=count)
            if applied == 0:
                raise PatchFailure(f"substitution failed in {self.relpath}: {description}")
            print(f"[gpl] patched {self.relpath}: {description}")
            return
        if already_check and already_check(self.text):
            print(f"[gpl] already patched {self.relpath}: {description}")
            return
        if optional:
            print(f"[gpl] unchanged {self.relpath}: {description}")
            return
        raise PatchFailure(f"pattern not matched in {self.relpath}: {description}")

    def delete_matching_lines(self, pattern: str, description: str) -> None:
        compiled = re.compile(pattern)
        lines = self.text.splitlines(keepends=True)
        new_lines = [line for line in lines if not compiled.search(line)]
        if len(new_lines) != len(lines):
            self.text = "".join(new_lines)
            print(f"[gpl] patched {self.relpath}: {description}")
        else:
            print(f"[gpl] unchanged {self.relpath}: {description}")

    def insert_after_matching_line(self, pattern: str, new_line: str, description: str) -> None:
        if new_line in self.text:
            print(f"[gpl] already patched {self.relpath}: {description}")
            return

        lines = self.text.splitlines()
        for index, line in enumerate(lines):
            if re.search(pattern, line):
                lines.insert(index + 1, new_line)
                self.text = "\n".join(lines) + "\n"
                print(f"[gpl] patched {self.relpath}: {description}")
                return

        raise PatchFailure(f"anchor not found in {self.relpath}: {description}")

    def save(self) -> None:
        if self.text != self.original:
            self.path.write_text(self.text, encoding="utf-8")


def iter_comment_cleanup_targets(root: Path):
    seen: set[Path] = set()
    for pattern in MAKEFILE_COMMENT_TARGETS:
        for path in sorted(root.glob(pattern)):
            if path.is_file() and path not in seen:
                seen.add(path)
                yield path


def extract_top_comment_block(text: str) -> tuple[str, str]:
    lines = text.splitlines(keepends=True)
    index = 0

    while index < len(lines) and lines[index].strip() == "":
        index += 1

    if index >= len(lines) or not lines[index].lstrip().startswith("#"):
        return "", text

    start = index
    while index < len(lines):
        stripped = lines[index].strip()
        if stripped == "" or lines[index].lstrip().startswith("#"):
            index += 1
            continue
        break

    return "".join(lines[start:index]), "".join(lines[index:])


def extract_preserved_copyright_header(text: str) -> str:
    comment_block, _ = extract_top_comment_block(text)
    lowered = comment_block.lower()

    if "copyright" not in lowered:
        return ""
    if not any(name in lowered for name in PRESERVED_COPYRIGHT_NAMES):
        return ""

    lines = comment_block.splitlines(keepends=True)
    preserved: list[str] = []
    separator_seen = False

    for line in lines:
        if not separator_seen:
            preserved.append(line)
            if "----------------------------------------------------------------" in line:
                separator_seen = True
            continue

        if line.strip() == "#":
            preserved.append(line)
            continue

        break

    if not preserved:
        return ""

    return "".join(preserved)


def strip_comment_lines(text: str) -> str:
    kept_lines = [line for line in text.splitlines(keepends=True) if not line.lstrip().startswith("#")]
    return "".join(kept_lines).lstrip("\n")


def normalize_target_makefile_comments(root: Path):
    for path in iter_comment_cleanup_targets(root):
        relpath = str(path.relative_to(root))
        editor = FileEditor(root, relpath)
        preserved_header = extract_preserved_copyright_header(editor.text)
        body = strip_comment_lines(editor.text)
        editor.text = f"{preserved_header}{body}"

        if editor.text and not editor.text.endswith("\n"):
            editor.text += "\n"

        if editor.text != editor.original:
            print(f"[gpl] patched {editor.relpath}: normalize makefile comments")
        else:
            print(f"[gpl] unchanged {editor.relpath}: normalize makefile comments")
        editor.save()


# board_cfg/make_tag
def patch_board_cfg_make_tag_kernel_release_flag(root: Path):
    editor = FileEditor(root, "board_cfg/make_tag/make_tag_kernel.make")
    editor.insert_after_matching_line(r"^C_UTIL_CHK_y \+=", "IS_RELEASE_GPL = y", "insert GPL release flag")
    editor.save()


def patch_board_cfg_make_tag_pkgs(root: Path):
    editor = FileEditor(root, "board_cfg/make_tag/make_tag_pkgs.make")
    editor.delete_matching_lines(r"PKGS_CROSS_APP_S4.*sigma_daemon", "remove sigma_daemon package line")
    editor.delete_matching_lines(r"PKGS_CROSS_APP_S4.*sigma_dut", "remove sigma_dut package line")
    editor.delete_matching_lines(r"PKGS_CROSS_INITRD_ADDED_.*wifi7_add_files/sigma_test/", "remove sigma_test install lines")
    editor.delete_matching_lines(r"PKGS_CROSS_INITRD_ADDED_.*elecom_ota/elecom", "remove elecom OTA public key install line")
    editor.save()


def patch_board_cfg_make_tag_kernel(root: Path):
    relpath = "board_cfg/make_tag/make_tag_kernel.make"
    editor = FileEditor(root, relpath)
    loop_pattern = r"\t\((\$\(MAKE\) -C \$\$PKG -f Makefile_1_gpl build [^\n]+)\) \|\| exit 1; " + r"\\"
    editor.replace_regex(
        loop_pattern,
        lambda match: f"\t$(if $(filter y,$(IS_RELEASE_GPL)),true,({match.group(1)})) || exit 1; \\",
        "wrap kernel package build loop with GPL guard",
        already_check=lambda text: "$(if $(filter y,$(IS_RELEASE_GPL)),true,(" in text,
    )
    editor.replace_literal(
        "\t$(ENV_Q)$(call target_make,$(PKG_KERNEL_y),kernel_module\\\n        ,INSTALL_PATH=\"$(E_P_STAGING)\"\\\n\t\t,CONFIG_DEBUG_SECTION_MISMATCH=y\\\n\t)",
        "\t$(if $(filter y,$(IS_RELEASE_GPL)),,$(ENV_Q)$(call target_make,$(PKG_KERNEL_y),kernel_module\\\n        ,INSTALL_PATH=\"$(E_P_STAGING)\"\\\n\t\t,CONFIG_DEBUG_SECTION_MISMATCH=y\\\n\t))",
        "wrap kernel_module target call with GPL guard",
        already_check=lambda text: "$(if $(filter y,$(IS_RELEASE_GPL)),,$(ENV_Q)$(call target_make,$(PKG_KERNEL_y),kernel_module" in text,
    )
    editor.save()


def patch_board_cfg_make_tag_init(root: Path):
    editor = FileEditor(root, "board_cfg/make_tag/make_tag_init.make")
    editor.delete_matching_lines(r"#include <cfg_board_variables\.h>", "remove cfg_board_variables include from generated cfg_board.h")
    editor.save()


def patch_board_cfg_make_tag_release_outputs(root: Path):
    # Keep release-output policy in the GPL rewrite path so repo source
    # fixes live in gpl.sh-related tooling and are reapplied consistently
    # when GPL trees or copied make_tag*.make files are regenerated.
    image_editor = FileEditor(root, "board_cfg/make_tag/make_tag_image.make")
    image_editor.replace_literal(
        "\t\tif [ ! -d $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release ]; then \\\n\t\t\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release; \\\n\t\t\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG; \\\n\t\t\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/MP; \\\n\t\tfi; \\\n\t\tif [ ! -f $(E_P_TOP)/image/$(E_PRODUCT_NAME)/ubi-layout.cfg ]; then \\\n\t\t\tcp $(E_P_TOP)/image/$(E_PRODUCT_NAME)/ubi-layout.cfg.d4 $(E_P_TOP)/image/$(E_PRODUCT_NAME)/ubi-layout.cfg; \\\n\t\tfi; \\\n\t\tcp -f $(E_F_IMAGE_FW_WO_H_HEADER) $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-UPG.bin; \\\n\t\tcp -f $(E_F_IMAGE_FW_WO_H) $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-TFTP.bin; \\\n\t\tsed -i 's|image=uboot-env.bin|image=$(E_P_TOP)/image/$(E_PRODUCT_NAME)/uboot-env.bin|g' $(E_P_TOP)/image/$(E_PRODUCT_NAME)/ubi-layout.cfg; \\\n\t\tsed -i 's|image=uImage|image=$(PKG_KERNEL_y)/arch/$(CROSS_ARCH)/boot/uImage|g' $(E_P_TOP)/image/$(E_PRODUCT_NAME)/ubi-layout.cfg; \\\n\t\tsed -i 's|image=root.squashfs|image=$(PKG_KERNEL_y)/arch/$(CROSS_ARCH)/boot/root.squashfs|g' $(E_P_TOP)/image/$(E_PRODUCT_NAME)/ubi-layout.cfg; \\\n\t\t$(E_F_UBINIZE) -o $(E_P_TOP)/image/$(E_PRODUCT_NAME)/mt7988-spim-nand-ubi-image.bin -p 128KiB -m 2048 -E 5 $(E_P_TOP)/image/$(E_PRODUCT_NAME)/ubi-layout.cfg; \\\n\t\tcd $(E_P_TOP)/image/$(E_PRODUCT_NAME); \\\n\t\t./createImage.sh; \\\n\t\tmv mt7988-spim-nand-ubi-image.bin ./release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-UBI.bin; \\\n\t\tmv mt7988-spim-nand-single-image.bin ./release/MP/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-MP.bin; \\\n\t\tsha256sum ./release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)* > ./release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256.txt; \\\n\t\tsha256sum ./release/MP/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)* > ./release/MP/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256-MP.txt; \\\n\t\tcat ./release/*/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256*.txt; \\\n\t\tcd -; \\\n",
        "\t\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG; \\\n\t\tcp -f $(E_F_IMAGE_FW_WO_H_HEADER) $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-UPG.bin; \\\n\t\tcp -f $(E_F_IMAGE_FW_WO_H) $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-TFTP.bin; \\\n\t\tcd $(E_P_TOP)/image/$(E_PRODUCT_NAME); \\\n\t\tsha256sum ./release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)* > ./release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256.txt; \\\n\t\tcat ./release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256.txt; \\\n\t\tcd -; \\\n",
        "remove UBI/MP packaging outputs from make_tag_image.make",
        already_check=lambda text: "-UBI.bin" not in text and "/release/MP" not in text and "uboot-env.bin" not in text and "createImage.sh" not in text,
    )
    image_editor.save()

    tag_editor = FileEditor(root, "board_cfg/make_tag/make_tag.make")
    tag_editor.replace_literal(
        "\trm -rf $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release\n\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release\n\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG\n\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/MP\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-UPG.bin\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-TFTP.bin\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256.txt\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/MP/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-MP.bin\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/MP/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256-MP.txt\n",
        "\trm -rf $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release\n\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release\n\tmkdir -p $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-UPG.bin\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-TFTP.bin\n\ttouch $(E_P_TOP)/image/$(E_PRODUCT_NAME)/release/UPG/$(E_CUSTOMER_MODEL_NAME)-FW-$($(E_C)VERSION_FW_MAJOR)-$($(E_C)VERSION_FW_MINOR)-$($(E_C)VERSION_FW_PATCH)-SHA256.txt\n",
        "remove MP placeholders from make_tag.make",
        already_check=lambda text: "/release/MP" not in text and "SHA256-MP.txt" not in text,
    )
    tag_editor.save()


def patch_board_makefile_unused_scripts(root: Path):
    board_files = [
        "board/ELECOM_WAB-BE187-M_EW-7896LBE/Makefile",
        "board/ELECOM_WAB-BE187-M_EW-7896LBE/Makefile_1_gpl",
        "board/ELECOM_WAB-BE72-M_EW-7786LBE/Makefile",
        "board/ELECOM_WAB-BE72-M_EW-7786LBE/Makefile_1_gpl",
        "board/ELECOM_WAB-BE36-M_EW-7486LBE/Makefile",
        "board/ELECOM_WAB-BE36-M_EW-7486LBE/Makefile_1_gpl",
        "board/ELECOM_WAB-BE36-S_EW-7476LBS/Makefile",
        "board/ELECOM_WAB-BE36-S_EW-7476LBS/Makefile_1_gpl",
    ]

    unused_install_lines = [
        r"\$\(E_P_TOP_ADD_FILES\)/sbin/dl_classical\.sh:sbin/dl\.sh",
        r"\$\(E_P_TOP_ADD_FILES\)/sbin/starteth_ipq6000\.sh:sbin/starteth\.sh",
        r"\$\(E_P_TOP_ADD_FILES\)/sbin/dropbear_for_root\.sh:sbin/dropbear_for_root\.sh",
        r"\$\(E_P_TOP_ADD_FILES\)/sbin/dropbear_for_root_elx\.sh:sbin/dropbear_for_root_elx\.sh",
        r"\$\(E_P_TOP_ADD_FILES\)/sbin/usbTest\.sh:sbin/usbTest\.sh",
    ]

    for relpath in board_files:
        if not (root / relpath).exists():
            continue
        editor = FileEditor(root, relpath)
        for line_pattern in unused_install_lines:
            editor.delete_matching_lines(line_pattern, f"remove unused install line: {line_pattern}")
        editor.save()


# P_ELX
def patch_p_elx_makefile_1_gpl_include_installs(root: Path):
    path_create_line = "\t$(ENV_Q)$(call target_path_create,$(addprefix $(INSTALL_PATH_INCLUDE_TARGET)/,$(INSTALL_INC_RELATED_DIR)))"
    path_create_replacement = (
        "\t# GPL: include install removed\n"
        "\t# $(ENV_Q)$(call target_path_create,$(addprefix $(INSTALL_PATH_INCLUDE_TARGET)/,$(INSTALL_INC_RELATED_DIR)))"
    )
    install_line = "\t$(ENV_Q)$(call target_file_install,$(INCLUDE),$(INSTALL_PATH_INCLUDE_TARGET)/$(INSTALL_INC_RELATED_DIR),644)"
    install_replacement = "\t# $(ENV_Q)$(call target_file_install,$(INCLUDE),$(INSTALL_PATH_INCLUDE_TARGET)/$(INSTALL_INC_RELATED_DIR),644)"

    for path in sorted(root.glob("P_ELX/*/Makefile_1_gpl")):
        editor = FileEditor(root, str(path.relative_to(root)))
        editor.replace_literal(
            path_create_line,
            path_create_replacement,
            "comment out include path install line",
            already_check=lambda text: "# GPL: include install removed" in text,
            optional=True,
        )
        editor.replace_literal(
            install_line,
            install_replacement,
            "comment out include file install line",
            already_check=lambda text: install_replacement in text,
            optional=True,
        )
        editor.save()


def patch_p_elx_makefile_2_bsp_build_blocks(root: Path):
    components = ("dbox2", "osapi", "toolbox", "cli", "edi_util", "fcgibox", "start_all", "system_init", "testdbox")
    pattern = r"\t\$\(ENV_Q\)\$\(call _make_do,[^\n]*\\\n(?:[ \t]*[^\n]*\\\n)*[ \t]*\)\n"

    for component in components:
        relpath = f"P_ELX/{component}/Makefile_2_bsp"
        editor = FileEditor(root, relpath)
        editor.replace_regex(
            pattern,
            "",
            "remove _make_do build block",
            already_check=lambda text: "$(call _make_do,all\\" not in text and "$(call _make_do,build\\" not in text,
            count=1,
            optional=True,
        )
        editor.save()


def patch_p_elx_elecom_cloud_apps_makefile_2_bsp(root: Path):
    editor = FileEditor(root, "P_ELX/elecom_cloud_apps/Makefile_2_bsp")
    editor.replace_regex(
        r"^\.PHONY: all build build_lib build_json2dbox build_dbox2json maintainer-clean init_config$",
        ".PHONY: all build build_lib maintainer-clean init_config",
        "remove config_manager phony targets",
        flags=re.MULTILINE,
        already_check=lambda text: "build_json2dbox" not in text and "build_dbox2json" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^all: clean build build_json2dbox build_dbox2json$",
        "all: clean build",
        "remove config_manager all dependencies",
        flags=re.MULTILINE,
        already_check=lambda text: "all: clean build build_json2dbox build_dbox2json" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^build: build_lib build_json2dbox build_dbox2json$",
        "build: build_lib",
        "remove config_manager build dependencies",
        flags=re.MULTILINE,
        already_check=lambda text: "build: build_lib build_json2dbox build_dbox2json" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^[ \t]*\$\(ENV_Q\)if \[ -d config_manager/json_to_dbox \]; then \\\n[ \t]*cd config_manager/json_to_dbox && \$\(MAKE\) -f Makefile clean; \\\n[ \t]*fi\n",
        "",
        "remove json2dbox clean block",
        flags=re.MULTILINE,
        already_check=lambda text: "config_manager/json_to_dbox" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^[ \t]*\$\(ENV_Q\)if \[ -d config_manager/dbox_to_json \]; then \\\n[ \t]*cd config_manager/dbox_to_json && \$\(MAKE\) -f Makefile clean; \\\n[ \t]*fi\n",
        "",
        "remove dbox2json clean block",
        flags=re.MULTILINE,
        already_check=lambda text: "config_manager/dbox_to_json" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^[ \t]*cd [^\n]+ && \\[ \t]*\n[ \t]*\$\(MAKE\)[^\n]*\n",
        "",
        "remove cd and MAKE build lines",
        flags=re.MULTILINE,
        already_check=lambda text: "$(COMMON_BUILD_VARS) || exit 1" not in text,
    )
    editor.replace_regex(
        r"^build_json2dbox: build_lib\n(?:\t[^\n]*\n)+",
        "",
        "remove json2dbox target",
        flags=re.MULTILINE,
        already_check=lambda text: "build_json2dbox:" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^build_dbox2json: build_lib init_config\n(?:\t[^\n]*\n)+",
        "",
        "remove dbox2json target",
        flags=re.MULTILINE,
        already_check=lambda text: "build_dbox2json:" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^[ \t]*config_manager/json_to_dbox/json2dbox \\\n(?:^[ \t]*config_manager/json_to_dbox/\*\.o \\\n)?(?:^[ \t]*config_manager/json_to_dbox/obj/\*\.o \\\n)?",
        "",
        "remove json2dbox clean artifacts",
        flags=re.MULTILINE,
        already_check=lambda text: "config_manager/json_to_dbox/json2dbox" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^[ \t]*config_manager/dbox_to_json/dbox2json \\\n(?:^[ \t]*config_manager/dbox_to_json/\*\.o \\\n)?(?:^[ \t]*config_manager/dbox_to_json/generator/\*\.o \\\n)?(?:^[ \t]*config_manager/dbox_to_json/generator/util/\*\.o \\\n)?",
        "",
        "remove dbox2json clean artifacts",
        flags=re.MULTILINE,
        already_check=lambda text: "config_manager/dbox_to_json/dbox2json" not in text,
        optional=True,
    )
    editor.save()


def patch_p_elx_elecom_cloud_apps_makefile_1_gpl(root: Path):
    editor = FileEditor(root, "P_ELX/elecom_cloud_apps/Makefile_1_gpl")
    editor.replace_regex(
        r"^\tcd config_manager/json_to_dbox;make clean\n",
        "",
        "remove json2dbox clean line",
        flags=re.MULTILINE,
        already_check=lambda text: "cd config_manager/json_to_dbox;make clean" not in text,
        optional=True,
    )
    editor.replace_regex(
        r'^\t\$\(ENV_Q\)\$\(call target_file_install,"config_manager/json_to_dbox/json2dbox",\$\(INSTALL_PATH_SBIN\),755,\$\(STRIP\)\)\n',
        "",
        "remove json2dbox install line",
        flags=re.MULTILINE,
        already_check=lambda text: 'config_manager/json_to_dbox/json2dbox' not in text,
        optional=True,
    )
    editor.replace_regex(
        r'^\t\$\(ENV_Q\)\$\(call target_file_install,"config_manager/dbox_to_json/dbox2json",\$\(INSTALL_PATH_SBIN\),755,\$\(STRIP\)\)\n',
        "",
        "remove dbox2json install line",
        flags=re.MULTILINE,
        already_check=lambda text: 'config_manager/dbox_to_json/dbox2json' not in text,
        optional=True,
    )
    editor.save()


def patch_p_elx_elecom_ota_makefile_1_gpl(root: Path):
    editor = FileEditor(root, "P_ELX/elecom_ota/Makefile_1_gpl")
    editor.replace_regex(r"\trm -rf \$\(TARGET\) daemon\.log log\n", "", "remove TARGET cleanup line", already_check=lambda text: "daemon.log" not in text, optional=True)
    editor.replace_regex(r"\trm -rf autofw/\* update\.xml\n", "", "remove autofw cleanup line", already_check=lambda text: "update.xml" not in text, optional=True)
    editor.save()


def patch_p_elx_header_gen_makefile_2_bsp(root: Path):
    editor = FileEditor(root, "P_ELX/header_gen/Makefile_2_bsp")
    editor.replace_regex(
        r"\t@rm -rf \*\.o;\n\t\$\(MAKE\) -f Makefile BUILD=X86 all;\n\tmv header_gen header\.x86;\n",
        "",
        "remove x86 build block",
        already_check=lambda text: "BUILD=X86 all;" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"\t@rm -rf \*\.o;\n\t\$\(ENV_Q\)\$\(call _make_do,all\\\n(?:[^\n]*\n)*?[ \t]*\)\n\tmv header_gen header\.target;\n",
        "",
        "remove target build block",
        already_check=lambda text: "mv header_gen header.target;" not in text,
        optional=True,
    )
    editor.save()


def patch_p_elx_mac_radius_makefile_1_gpl(root: Path):
    editor = FileEditor(root, "P_ELX/mac_radius/Makefile_1_gpl")
    editor.replace_regex(
        r"\t\$\(MAKE\) -C \$\(KERNELDIR\) M=\$\(PWD\)[^\n]*\\\n(?:\t\t[^\n]*\n)+",
        "",
        "remove kernel module build invocation",
        already_check=lambda text: "$(MAKE) -C $(KERNELDIR) M=$(PWD)" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"\t\$\(CROSS_COMPILE\)gcc[^\n]*\\\n(?:\t[^\n]*\\\n)*\t[^\n]*\n",
        "",
        "remove gcc build invocation",
        already_check=lambda text: "$(CROSS_COMPILE)gcc" not in text,
        optional=True,
    )
    editor.save()


def patch_p_elx_snmpd_modules_makefile_1_gpl(root: Path):
    editor = FileEditor(root, "P_ELX/snmpd_modules/Makefile_1_gpl")
    editor.replace_regex(
        r"^(build_lib): init_config$",
        r"\1:",
        "remove build_lib init_config dependency",
        flags=re.MULTILINE,
        already_check=lambda text: "build_lib: init_config" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"\t\$\(ENV_Q\)\$\(call _make_do,all \\\n(?:[ \t]+[^\n]*\n)*\t\)\n",
        "",
        "remove build_lib _make_do block",
        already_check=lambda text: "_make_do,all" not in text,
        optional=True,
    )
    editor.save()


# P_BSD
def patch_p_bsd_nginx_makefile_2_bsp(root: Path):
    """Strip nginx build/init_config bodies so `make` becomes a no-op.

    The pre-built nginx binary is preserved by gpl.sh:clean_p_bsd_nginx() at
    .build/<CROSS_PATH_NAME>/<bsp_id>/nginx, which is exactly $(PROG). With the
    body of `build:` and `init_config:` removed, `make all` (Makefile_2_bsp)
    triggers `make -f Makefile_1_gpl` whose `install:` rule simply copies $(PROG)
    via target_file_install — no source, no configure, no compile required.
    """
    relpath = "P_BSD/nginx-1.24.x/Makefile_2_bsp"
    if not (root / relpath).exists():
        return
    editor = FileEditor(root, relpath)
    # Replace `build: init_config\n<body>` with no-op
    editor.replace_regex(
        r"^build: init_config\n"
        r"\t\$\(call TAG_INFO_START\)\n"
        r"(?:\t[^\n]*\n)+?"
        r"\t\$\(call TAG_INFO_END\)\n",
        "build:\n\t@echo '[gpl] nginx build skipped (prebuilt binary)'\n",
        "neutralize nginx build target body",
        flags=re.MULTILINE,
        already_check=lambda text: "nginx build skipped" in text,
        optional=True,
    )
    # Replace `init_config: ...` body that runs ./configure (source removed)
    editor.replace_regex(
        r"^init_config: \| isdefined-CONFIG_IS_INITIALIZED\n"
        r"\t\$\(call TAG_INFO_START\)\n"
        r"(?:\t[^\n]*\n)+?"
        r"\t\$\(call TAG_INFO_END\)\n",
        "init_config: | isdefined-CONFIG_IS_INITIALIZED\n\t@true\n",
        "neutralize nginx init_config body",
        flags=re.MULTILINE,
        already_check=lambda text: "init_config: | isdefined-CONFIG_IS_INITIALIZED\n\t@true" in text,
        optional=True,
    )
    editor.save()


# P_FREE
def patch_p_free_net_snmp_makefile_1_gpl(root: Path):
    editor = FileEditor(root, "P_FREE/net-snmp-5.9.x/Makefile_1_gpl")
    editor.replace_regex(
        r"^(PROG\s+=\s+)\./agent/snmpd$",
        r"\1./agent/.libs/snmpd ./apps/.libs/snmptrap",
        "point PROG to prebuilt binaries",
        flags=re.MULTILINE,
        already_check=lambda text: "./agent/.libs/snmpd ./apps/.libs/snmptrap" in text,
    )
    editor.replace_regex(
        r"(install_lib: \| isdefined-CONFIG_IS_INITIALIZED\n)"
        r"(?:#\t[^\n]*\n)*"
        r"\tmake installheaders\n"
        r"\tmake installlibs\n"
        r"(?:#\t[^\n]*\n)*"
        r"(?:\tcp [^\n]*\n)+",
        r"\1"
        r"\tcp ./snmplib/.libs/libnetsnmp.so* $(INSTALL_PATH_LIB)\n"
        r"\tcp ./agent/.libs/libnetsnmpagent.so* $(INSTALL_PATH_LIB)\n"
        r"\tcp ./agent/.libs/libnetsnmpmibs.so* $(INSTALL_PATH_LIB)\n"
        r"\tcp ./agent/helpers/.libs/libnetsnmphelpers.so* $(INSTALL_PATH_LIB)\n",
        "replace install_lib with prebuilt shared library copies",
        flags=re.MULTILINE,
        already_check=lambda text: "cp ./snmplib/.libs/libnetsnmp.so* $(INSTALL_PATH_LIB)" in text,
    )
    editor.replace_regex(
        r"(^install:\n)\tmake installsbin\n\tmake -C \./apps install\n",
        r"\1\t$(call target_file_install,$(PROG),$(INSTALL_PATH_SBIN),755,$(STRIP))\n",
        "replace install target with direct file install",
        flags=re.MULTILINE,
        already_check=lambda text: "$(call target_file_install,$(PROG),$(INSTALL_PATH_SBIN),755,$(STRIP))" in text,
    )
    editor.save()


def patch_p_free_net_snmp_makefile_2_bsp(root: Path):
    editor = FileEditor(root, "P_FREE/net-snmp-5.9.x/Makefile_2_bsp")
    editor.replace_regex(
        r"^(build_lib): init_config(\n"
        r"\t\$\(call TAG_INFO_START\)) \\\n"
        r"\t\$\(ENV_Q\)\$\(call make_do,all \\\n"
        r"\t\t,CC=\"\$\(CROSS\)gcc\"\\\n"
        r"\t\)\n",
        r"\1:\2\n",
        "remove build_lib make_do block",
        flags=re.MULTILINE,
        already_check=lambda text: "build_lib: init_config" not in text and "call make_do,all" not in text,
        optional=True,
    )
    editor.replace_regex(
        r"^(build:\n"
        r"\t\$\(call TAG_INFO_START\)) \\\n"
        r"\t\$\(ENV_Q\)\$\(call make_do, snmptrap \\\n"
        r"\t\t,-C \./apps \\\n"
        r"\t\)\n",
        r"\1\n",
        "remove build snmptrap make_do block",
        flags=re.MULTILINE,
        already_check=lambda text: "call make_do, snmptrap" not in text,
        optional=True,
    )
    editor.save()


# P_MTK
def patch_p_mtk_backports_makefile_1_gpl(root: Path):
    # Glob covers be72 family (P_MTK/mt7988-mt7992-MP3/) and be187 (P_MTK/v8.2.1.5/).
    for path in sorted(root.glob("P_MTK/*/backports-5.15.81-1/Makefile_1_gpl")):
        relpath = str(path.relative_to(root))
        editor = FileEditor(root, relpath)
        editor.replace_regex(
            # Comment line is present in be72 .src but absent in be187 .src — keep optional.
            r"(?:\t# This generate a default configuration with n on all values and kconf[^\n]*\n)?"
            r"\tCC=\"\$\(ENV_CC\)\" make -C \"\$\(E_P_PKG\)\" KLIB=\"\$\(PKG_KERNEL_y\)\" KLIB_BUILD=\"\$\(PKG_KERNEL_y\)\" allnoconfig\n",
            "",
            "remove allnoconfig step",
            already_check=lambda text: "allnoconfig" not in text,
        )
        editor.save()


def patch_p_mtk_backports_makefile_2_bsp(root: Path):
    for path in sorted(root.glob("P_MTK/*/backports-5.15.81-1/Makefile_2_bsp")):
        relpath = str(path.relative_to(root))
        editor = FileEditor(root, relpath)
        editor.replace_regex(
            r"\t\$\(ENV_Q\) CC=\"\$\(ENV_CC\)\" make -C \"\$\(E_P_PKG\)/kconf\" conf\n",
            "",
            "remove kconf init_config step",
            already_check=lambda text: "/kconf\" conf" not in text,
            optional=True,
        )
        editor.replace_regex(
            r"(install:\n)"
            r"\tmkdir -p [^\n]+include/mac80211[^\n]+\n"
            r"\tcp -fpR[^\n]+mac80211[^\n]+\n"
            r"\tcp -fpR[^\n]+backport-include[^\n]+\n"
            r"\trm[^\n]+\n"
            r"\tcp -fpR[^\n]+mac80211/rate\.h[^\n]+\n"
            r"\tcp -fpR[^\n]+ath[^\n]+\n",
            r"\1"
            r"\tmkdir -p $(INSTALL_PATH_LIB)\n"
            r"\tcp -fp $(E_P_PKG)/compat/compat.ko $(INSTALL_PATH_LIB)/\n"
            r"\tcp -fp $(E_P_PKG)/net/wireless/cfg80211.ko $(INSTALL_PATH_LIB)/\n",
            "replace header install block with module copies",
            flags=re.MULTILINE,
            already_check=lambda text: "cp -fp $(E_P_PKG)/compat/compat.ko $(INSTALL_PATH_LIB)/" in text,
        )
        editor.save()


# shared cleanup sweep
def patch_shared_generic_build_commands(root: Path):
    pattern = r"(build:[^\n]*\n\t\$\(call TAG_INFO_START\)\n)(\t(?!\$\(call TAG_INFO_END\))[^\n]*\n)+"
    for path in sorted(list(root.glob("P_MTK/*/Makefile_1_gpl")) + list(root.glob("P_ELX/*/Makefile_1_gpl"))):
        relpath = str(path.relative_to(root))
        editor = FileEditor(root, relpath)
        editor.replace_regex(
            pattern,
            r"\1",
            "strip generic build body",
            flags=re.MULTILINE,
            optional=True,
        )
        editor.save()


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: patch_makefiles.py <source-path>", file=sys.stderr)
        return 2

    root = Path(sys.argv[1]).resolve()
    if not root.exists():
        print(f"[gpl] ERROR: source path does not exist: {root}", file=sys.stderr)
        return 2

    patch_steps: list[PatchStep] = [
        # board_cfg/make_tag
        patch_board_cfg_make_tag_kernel_release_flag,
        patch_board_cfg_make_tag_pkgs,
        patch_board_cfg_make_tag_kernel,
        patch_board_cfg_make_tag_init,
        patch_board_cfg_make_tag_release_outputs,

        # board
        patch_board_makefile_unused_scripts,

        # P_ELX
        patch_p_elx_makefile_1_gpl_include_installs,
        patch_p_elx_makefile_2_bsp_build_blocks,
        patch_p_elx_elecom_cloud_apps_makefile_1_gpl,
        patch_p_elx_elecom_cloud_apps_makefile_2_bsp,
        patch_p_elx_elecom_ota_makefile_1_gpl,
        patch_p_elx_header_gen_makefile_2_bsp,
        patch_p_elx_mac_radius_makefile_1_gpl,
        patch_p_elx_snmpd_modules_makefile_1_gpl,

        # P_BSD
        patch_p_bsd_nginx_makefile_2_bsp,

        # P_FREE
        patch_p_free_net_snmp_makefile_1_gpl,
        patch_p_free_net_snmp_makefile_2_bsp,

        # P_MTK
        patch_p_mtk_backports_makefile_1_gpl,
        patch_p_mtk_backports_makefile_2_bsp,

        # shared cleanup sweep
        patch_shared_generic_build_commands,

        # final normalization
        normalize_target_makefile_comments,
    ]

    try:
        for step in patch_steps:
            step(root)
    except PatchFailure as error:
        print(f"[gpl] ERROR: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())