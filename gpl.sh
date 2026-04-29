
#!/bin/bash
# ============================================================
# FOR AI ASSISTANTS — READ FIRST
# ============================================================
# Before modifying this script:
#   1. Read .claude/CLAUDE.md (project context) and GPL_TEST_SOP.md (full SOP)
#   2. Read gpl_tools/REFERENCE_MAP.md (function index + decision trees)
#   3. Do NOT change main_release() step ordering (see end of file).
#      Step order encodes dependencies — e.g. clean_p_mtk_kernel must run
#      before clean_wifi7_add_files; strip_*_comments must run before
#      protect_runtime_shell_scripts.
#   4. New shell scripts must be classified into WRAPPER_RULES or SHC_RULES
#      in gpl_tools/protect_runtime_shell_scripts.py
#      (sourced/library scripts → WRAPPER, direct-exec → SHC)
#   5. New MODEL: update validate_model() AND clean_add_files() inittab
#      mapping AND clean_wifi7_add_files() model branch.
#   6. New P_ELX component: add to p_elx_folders[] in clean_p_elx() with
#      explicit keep_files list (binary-only release — no source).
#   7. Verify any change with:
#        ./gpl.sh EW-7786LBE --mode quick
#      and for build-affecting changes:
#        ./gpl.sh EW-7786LBE --mode full
#   8. If unsure, STOP and ask the human. This script ships customer
#     -facing GPL artifacts; mistakes are visible externally.
# ============================================================
#
# gpl.sh — GPL release preparation
#
# Usage:
#   ./gpl.sh <MODEL>                   # release prep in current directory
#   ./gpl.sh <MODEL> --mode full       # full test workflow (see below)
#   ./gpl.sh <MODEL> --mode quick      # quick validation workflow (see below)
#   ./gpl.sh <MODEL> --mode quick --protect-shell-scripts
#   ./gpl.sh <MODEL> --protect-shell-scripts
#   MODEL: EW-7786LBE | EW-7486LBE | EW-7476LBS
#
# --mode full   First-time setup. Copies <GPL_DIR_NAME>.src → <GPL_DIR_NAME>,
#               runs patch_sensitive_values (clear cloud URLs in P_ELX source) and
#               prepare_source_for_build (revert freeradius/hostapd to release versions),
#               then builds the firmware (make) to produce <GPL_DIR_NAME>.build.
#               After a successful full run, use --mode quick for subsequent validations.
#
# --mode quick  Validation workflow. Copies the pre-built <GPL_DIR_NAME>.build →
#               <GPL_DIR_NAME> (skips the slow make step) and runs the full GPL
#               release preparation (main_release) to verify the source cleanup result.
#               Requires <GPL_DIR_NAME>.build to already exist from a prior --mode full run.
#
# --protect-shell-scripts
#               Applies hybrid runtime protection to shell scripts under add_files/
#               and wifi7_add_files/wl_scripts/. Sourced/library scripts stay as
#               self-decrypting wrappers; selected direct-exec scripts are converted
#               into target binaries with shc. Requires host python3, openssl, shc,
#               and a target cross-compiler (auto-detected or set via GPL_SHC_CC).
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MODEL=""
MODE=""
SOURCE_DIR=""
TARGET_DIR=""
SOURCE_PATH=""
BOARD_DIR=""
IMAGE_DIR=""
GPL_DIR_NAME=""
CUSTOMER_MODEL_NAME=""
MTK_VERSION_DIR=""
MTK_WIFI_HWIFI_KO_LIST=""
FREERADIUS_RESTORE_REF=""
HOSTAPD_RADIUS_CLIENT_RESTORE_REF=""
HOSTAPD_SESSION_TIMEOUT_RESTORE_REF=""
WL_DBOX2HOSTAPD_REVERT_METHOD=""
PROTECT_SHELL_SCRIPTS=0

### P_ELX Exact Binary File List (from wab-be187-gpl proven process)
# Keep all component Makefile_1_gpl  Makefile_3_def Makefile_2_bsp
# | Component | Target Files (relative to component dir) |
# |-----------|------------------------------------------|
# | cli | `cli` |
# | dbox2 | `dbox_init`, `libdbox.a`, `libdbox.so` |
# | edi_util | `edi_util` |
# | elecom_cloud_apps | `admlink/admlink`, `admlink/admlink_ctrl`, `config_manager/dbox_to_json/dbox2json`, `config_manager/json_to_dbox/json2dbox`, `libadmlink/libadminLink.so` |
# | elecom_ota | `fwd`, `fwd_cli`, `elecom/public.pem` |
# | fcgibox | `fcgibox` |
# | header_gen | `header.target`, `header.x86` |
# | mac_radius | `mac_radius`, `mac_radius_kmod.ko` |
# | netlink_monitor | `netlink_monitor` |
# | osapi | `libosapi.a`, `libosapi.so` |
# | poestat_max5995 | `poestat` |
# | snmpd_modules | `libnetsnmpObjects.so` |
# | start_all | `start_all` |
# | systemdaemon | `sd`, `sd_ctrl` |
# | system_init | `system_init` |
# | testdbox | `testdbox` |
# | toolbox | `libtbox.a`, `libtbox.so` |


# ============================================================
# Helper
# ============================================================

_ptk_meta() {
# Copy LICENSE/COPYING + Makefile_1/2/3_gpl/bsp/def from src dir into dst dir
    local src="$1" dst="$2"
    mkdir -p "$dst"
    find "$src" -maxdepth 1 \( -iname "LICENSE" -o -iname "license" -o -iname "COPYING" -o -iname "COPYRIGHT" \) \
        -exec cp -a {} "$dst/" \;
    for mf in Makefile_1_gpl Makefile_2_bsp Makefile_3_def; do
        if [ -f "$src/$mf" ]; then cp -a "$src/$mf" "$dst/"; fi
    done
}

die() {
    echo "[gpl] ERROR: $*" >&2
    exit 1
}

require_command() {
    local command_name
    for command_name in "$@"; do
        command -v "$command_name" >/dev/null 2>&1 || die "missing required command: $command_name"
    done
}

require_path() {
    local path_name="$1"
    [ -e "$path_name" ] || die "missing required path: $path_name"
}

validate_model() {
    # Per-model identity
    case "$MODEL" in
        EW-7476LBS)
            BOARD_DIR="ELECOM_WAB-BE36-S_EW-7476LBS"
            IMAGE_DIR="EW-7476LBS"
            GPL_DIR_NAME="wab-be36-s-gpl"
            CUSTOMER_MODEL_NAME="WAB-BE36-S"
            ;;
        EW-7486LBE)
            BOARD_DIR="ELECOM_WAB-BE36-M_EW-7486LBE"
            IMAGE_DIR="EW-7486LBE"
            GPL_DIR_NAME="wab-be36-gpl"
            CUSTOMER_MODEL_NAME="WAB-BE36-M"
            ;;
        EW-7786LBE)
            BOARD_DIR="ELECOM_WAB-BE72-M_EW-7786LBE"
            IMAGE_DIR="EW-7786LBE"
            GPL_DIR_NAME="wab-be72-gpl"
            CUSTOMER_MODEL_NAME="WAB-BE72-M"
            ;;
        EW-7896LBE)
            BOARD_DIR="ELECOM_WAB-BE187-M_EW-7896LBE"
            IMAGE_DIR="EW-7896LBE"
            GPL_DIR_NAME="wab-be187-gpl"
            CUSTOMER_MODEL_NAME="WAB-BE187-M"
            ;;
        *)
            die "unsupported MODEL=$MODEL"
            ;;
    esac

    # Family-level config: P_MTK version dir, Wi-Fi chip, internal patch anchors
    # Anchor refs are git refs passed to `git checkout <ref> -- <path>` to restore the
    # GPL release version (i.e. before internal mantis customizations).
    case "$MODEL" in
        EW-7476LBS|EW-7486LBE|EW-7786LBE)
            MTK_VERSION_DIR="mt7988-mt7992-MP3"
            # KONAME list from P_MTK/$MTK_VERSION_DIR/mt_wifi7/wlan_hwifi/Makefile_1_gpl
            MTK_WIFI_HWIFI_KO_LIST="connac_if.ko mtk_wed.ko mt7992.ko mtk_pci.ko mtk_hwifi.ko"
            FREERADIUS_RESTORE_REF="5ff6024ef"
            HOSTAPD_RADIUS_CLIENT_RESTORE_REF="ce7a22c69^"
            HOSTAPD_SESSION_TIMEOUT_RESTORE_REF="954db32f2^"
            WL_DBOX2HOSTAPD_REVERT_METHOD="git:ce7a22c69^"
            ;;
        EW-7896LBE)
            MTK_VERSION_DIR="v8.2.1.5"
            # be187 wlan_hwifi installs both mt7990.ko and mt7991.ko (per Makefile_1_gpl KONAME)
            MTK_WIFI_HWIFI_KO_LIST="connac_if.ko mtk_wed.ko mt7990.ko mt7991.ko mtk_pci.ko mtk_hwifi.ko"
            FREERADIUS_RESTORE_REF="553cbfff5^"
            HOSTAPD_RADIUS_CLIENT_RESTORE_REF="67e39f24d^"
            HOSTAPD_SESSION_TIMEOUT_RESTORE_REF="47132c77c^"
            # be187 mantis-9642 customization (radius_retry_primary_interval=3600) was carried
            # into v8.2.1.5/wl_dbox2hostapd.sh from v8.1.0.4 via commit 0f976a380, so no
            # clean-baseline commit exists in HEAD's history. Revert via sed.
            WL_DBOX2HOSTAPD_REVERT_METHOD="sed:radius_retry_primary_interval"
            ;;
    esac
}

# ============================================================
# Test mode
# ============================================================

ensure_safe_target_dir() {
    local current_dir target_dir_real
    current_dir=$(pwd -P)
    target_dir_real="$(cd "$(dirname "$TARGET_DIR")" && pwd -P)/$(basename "$TARGET_DIR")"
    case "$current_dir" in
        "$target_dir_real"|"$target_dir_real"/*)
            die "current directory is inside $TARGET_DIR — cd to $SCRIPT_DIR and run again"
            ;;
    esac
}

setup_workspace() {
    echo "[gpl] setup_workspace: $SOURCE_DIR → $TARGET_DIR"
    require_path "$SOURCE_DIR"
    rm -rf "$TARGET_DIR"
    cp -a "$SOURCE_DIR" "$TARGET_DIR"
}

patch_sensitive_values() {
    echo "[gpl] patch_sensitive_values"
    sed -i 's|defaultStr = G_DEF_CLOUD_URL;|defaultStr = "";|' \
        "$TARGET_DIR/P_ELX/dbox2/nodes/dbox_nodes_cloud.c"
    sed -i 's|char addr\[128\]="agi6e3leqqer1-ats.iot.ap-northeast-1.amazonaws.com";|char addr[128]="";|' \
        "$TARGET_DIR/P_ELX/elecom_cloud_apps/admlink/admlink_main.c"
}

prepare_source_for_build() {
    echo "[gpl] prepare_source_for_build: restore GPL packages to release versions"
    # In test mode, main_test sets SOURCE_PATH=TARGET_DIR before calling this,
    # so reuse the same restore helpers used by main_release.
    restore_freeradius_release_version
    revert_hostapd_internal_radius_patches
}

verify_fw_image() {
    local uimage_path="$TARGET_DIR/staging/${MODEL}_uImage"
    local fw_image_path
    require_path "$uimage_path"
    fw_image_path=$(find "$TARGET_DIR/staging" -maxdepth 1 -type f -name "${MODEL}-FW-*.bin" | head -n 1)
    [ -n "$fw_image_path" ] || die "FW image not found under $TARGET_DIR/staging"
    echo "[gpl] Verified uImage: $uimage_path"
    echo "[gpl] Verified FW image: $fw_image_path"
}

build_fw_image() {
    echo "[gpl] build_fw_image: board/$BOARD_DIR"
    cd "$TARGET_DIR/board/$BOARD_DIR"
    make
    verify_fw_image
    echo "[gpl] Firmware build successful"

    echo "[gpl] Saving build result to ${TARGET_DIR}.build for future quick test runs"
    rm -rf ${TARGET_DIR}.build
    cp -a $TARGET_DIR ${TARGET_DIR}.build
}

# ============================================================
# Step functions
# ============================================================

verify_source_tree() {
    local required_paths=(
        add_files
        board
        board_cfg
        P_ELX
        P_FREE
        P_MTK
    )
    local path_name

    for path_name in "${required_paths[@]}"; do
        require_path "$SOURCE_PATH/$path_name"
    done
}

clean_root() {
    echo "[gpl] clean_root"
    cd "$SOURCE_PATH"
    rm -rf DEFINE YML scripts
    rm -f README.md .gitlab-ci.yml
}

clean_board_cfg_sensitive() {
    echo "[gpl] clean_board_cfg_sensitive"
    cd "$SOURCE_PATH/board_cfg"
    if [ -f make_feeds.conf ]; then
        sed -i '/^[[:space:]]*src-/d' make_feeds.conf
    fi
    find "$SOURCE_PATH/board" -name "config.product.elx" -delete
    find "$SOURCE_PATH/board" -name "README.ELX" -delete
}

detect_active_make_tag_lib() {
    local config_product="$SOURCE_PATH/board/$BOARD_DIR/config/config.product"

    [ -f "$config_product" ] || return 1

    if grep -q '^CONFIG_IS_CROSSTOOL_AARCH64_GCC740_GLIBC228=y$' "$config_product"; then
        echo "make_tag_lib_aarch64-glibc228-a53-gcc740.make"
        return 0
    fi
    if grep -q '^CONFIG_IS_CROSSTOOL_AARCH64_GCC540_GLIBC224=y$' "$config_product"; then
        echo "make_tag_lib_aarch64_cortex-a53+neon-vfpv4_gcc-5.4.0_glibc-2.24.make"
        return 0
    fi
    if grep -q '^CONFIG_IS_CROSSTOOL_AARCH64_GCC520_MUSL_1_1_16=y$' "$config_product"; then
        echo "make_tag_lib_aarch64_cortex-a53_gcc-5.2.0_musl-1.1.16.make"
        return 0
    fi
    if grep -q '^CONFIG_IS_CROSSTOOL_AARCH64_GCC840_MUSL_1_1_24=y$' "$config_product"; then
        echo "make_tag_lib_aarch64_cortex-a53_gcc-8.4.0_musl-1.1.24.make"
        return 0
    fi
    if grep -q '^CONFIG_IS_CROSSTOOL_QCA_IPQ40XX_ARMV7_GCC48_UCLIBC_1_0_14=y$' "$config_product"; then
        echo "make_tag_lib_QCA_ARMV7_GCC48_UCLIBC_1_0_14.make"
        return 0
    fi
    if grep -q '^CONFIG_IS_CROSSTOOL_MIPS32R2_GCC73_UCLIBC_1_0_30=y$' "$config_product"; then
        echo "make_tag_lib_MIPS32R2_GCC73_UCLIBC_1_0_30.make"
        return 0
    fi
    if grep -q '^CONFIG_IS_CROSSTOOL_OTHER=y$' "$config_product"; then
        echo "make_tag_lib_OTHER.make"
        return 0
    fi

    return 1
}

clean_board_cfg_make_tag_unused() {
    echo "[gpl] clean_board_cfg_make_tag_unused"

    local make_tag_dir="$SOURCE_PATH/board_cfg/make_tag"
    local active_lib
    local path_name
    local base_name

    active_lib=$(detect_active_make_tag_lib) || {
        echo "[gpl] keep all make_tag_lib variants: unable to resolve active toolchain"
        return 0
    }

    for path_name in "$make_tag_dir"/make_tag_lib_*.make; do
        [ -e "$path_name" ] || return 0
        base_name=$(basename "$path_name")
        case "$base_name" in
            make_tag_lib_NA.make|"$active_lib") ;;
            *) rm -f "$path_name" ;;
        esac
    done
}

clean_board_dirs() {
    echo "[gpl] clean_board_dirs"
    cd "$SOURCE_PATH/board"

    local board_path

    for board_path in *; do
        [ -d "$board_path" ] || continue
        [ "$board_path" = "$BOARD_DIR" ] || rm -rf "$board_path"
    done
}

clean_board_include() {
    echo "[gpl] clean_board_include"
    cd "$SOURCE_PATH"

    rm -rf board_include

    [ -d "board/$BOARD_DIR/include" ] && rm -rf "board/$BOARD_DIR/include"
}

clean_image_dirs() {
    echo "[gpl] clean_image_dirs"
    cd "$SOURCE_PATH/image"

    local image_path

    for image_path in *; do
        [ -d "$image_path" ] || continue
        [ "$image_path" = "$IMAGE_DIR" ] || rm -rf "$image_path"
    done
}

clean_image_dir_variants() {
    # Remove obsolete image packaging helpers/inputs, stale UBI/MP release
    # artifacts, and date-stamped historical/test variant files in
    # image/$IMAGE_DIR/ that are not part of the shipped UPG/TFTP firmware
    # flow.
    # Verified via: grep -rln "<filename>" --include="*.sh" --include="Makefile*" --include="*.make"
    echo "[gpl] clean_image_dir_variants"
    local image_dir_path="$SOURCE_PATH/image/$IMAGE_DIR"
    [ -d "$image_dir_path" ] || return 0
    cd "$image_dir_path"

    rm -f createImage.sh
    rm -f mk_image.sh
    rm -f ubi-layout.cfg
    rm -f ubi-layout.cfg.d4
    rm -f uboot-env.bin
    rm -rf release/MP
    rm -f release/UPG/*-UBI.bin

    local sha_file
    for sha_file in release/UPG/*-SHA256.txt; do
        [ -f "$sha_file" ] || continue
        sed -i '/-UBI\.bin/d' "$sha_file"
    done

    case "$MODEL" in
        EW-7476LBS)
            rm -f MT7991B_MT7976C_BE3600_iPAiLNA_20240925_ES1_2.bin
            rm -f MT7991B_MT7976C_BE3600_iPAiLNA_20250122_TELEC.bin
            rm -f MT7991B_MT7976C_BE3600_iPAiLNA_20250307_TELEC2.bin
            ;;
        EW-7486LBE)
            rm -f EW-7486LBE_20240807.bin
            rm -f EW-7486LBE_20250110.bin
            ;;
        EW-7786LBE)
            rm -f EW-7786LBE_20240807.bin
            rm -f EW-7786LBE_20250109.bin
            ;;
        EW-7896LBE)
            rm -f 20240801_MT7990_iPAiLNA_EEPROM_TELEC_v4.bin
            rm -f bl2-187m.img
            rm -f bl2-20240702.img
            rm -f fip-187m.bin
            rm -f fip-20240702.bin
            ;;
    esac
}

clean_add_files() {
    echo "[gpl] clean_add_files"
    cd "$SOURCE_PATH/add_files"

    local keep_inittab
    local keep_etc_files=(
        mdev.conf
        openssl.cnf
    )
    local keep_sysctl_files=(
        00-disable_ipv6.conf
        10-default.conf
        sysctl-br-netfilter.conf
        sysctl-nf-conntrack.conf
    )
    local keep_sbin_files=(
        automount.sh
        dropbear_for_root.sh
        dropbear_for_root_elx.sh
        emergency_mode.sh
        evtest.sh
        fw_upgrade.sh
        guest_network.sh
        guest_network_add.sh
        guest_network_auth.sh
        guest_network_check.sh
        guest_network_mail.sh
        guest_network_release.sh
        mount_storage_manufacture.sh
        mt7988d-smp.sh        # be72: smp script (chip-specific name)
        smp.sh                # be187: smp script
        sysctl.sh
        udhcpc_watchdog.sh
        wifi_bridge_port_checker.sh
        wifi_if_info.sh
    )
    local path_name
    local base_name

    case "$MODEL" in
        EW-7476LBS)
            keep_inittab="inittab_ttyS0_elecom_be36s"
            ;;
        EW-7486LBE|EW-7786LBE|EW-7896LBE)
            keep_inittab="inittab_ttyS0_elx7"
            ;;
        *)
            die "unsupported MODEL=$MODEL"
            ;;
    esac

    keep_etc_files+=("$keep_inittab")

    for path_name in etc/*; do
        [ -e "$path_name" ] || continue
        base_name=$(basename "$path_name")

        if [ -d "$path_name" ]; then
            [ "$base_name" = "sysctl.d" ] || rm -rf "$path_name"
            continue
        fi

        case " ${keep_etc_files[*]} " in
            *" $base_name "*) ;;
            *) rm -f "$path_name" ;;
        esac
    done

    for path_name in etc/sysctl.d/*; do
        [ -e "$path_name" ] || continue
        base_name=$(basename "$path_name")
        case " ${keep_sysctl_files[*]} " in
            *" $base_name "*) ;;
            *) rm -f "$path_name" ;;
        esac
    done

    for path_name in sbin/*; do
        [ -e "$path_name" ] || continue
        base_name=$(basename "$path_name")
        case " ${keep_sbin_files[*]} " in
            *" $base_name "*) ;;
            *) rm -f "$path_name" ;;
        esac
    done
}

clean_web_unused() {
    echo "[gpl] clean_web_unused"
    rm -f "$SOURCE_PATH/P_ELX/web/web_elecom/usb_disp.html"
}

strip_web_comments() {
    echo "[gpl] strip_web_comments"
    require_command python3
    require_path "$SCRIPT_DIR/gpl_tools/strip_web_comments.py"
    python3 "$SCRIPT_DIR/gpl_tools/strip_web_comments.py" "$SOURCE_PATH/P_ELX/web"
}

strip_add_files_script_comments() {
    echo "[gpl] strip_add_files_script_comments"
    require_command python3
    require_path "$SCRIPT_DIR/gpl_tools/strip_shell_comments.py"
    python3 "$SCRIPT_DIR/gpl_tools/strip_shell_comments.py" "$SOURCE_PATH/add_files"
}

strip_wifi7_wl_script_comments() {
    echo "[gpl] strip_wifi7_wl_script_comments"
    require_command python3
    require_path "$SCRIPT_DIR/gpl_tools/strip_shell_comments.py"
    python3 "$SCRIPT_DIR/gpl_tools/strip_shell_comments.py" \
        "$SOURCE_PATH/P_MTK/$MTK_VERSION_DIR/wifi7_add_files/wl_scripts"
}

resolve_shc_cc() {
    if [ -n "${GPL_SHC_CC:-}" ]; then
        [ -x "$GPL_SHC_CC" ] || die "GPL_SHC_CC is not executable: $GPL_SHC_CC"
        echo "$GPL_SHC_CC"
        return 0
    fi

    local candidate
    for candidate in \
        "$SCRIPT_DIR/${GPL_DIR_NAME}.build"/toolchain/toolchain-*/bin/*-openwrt-linux-musl-gcc \
        "$SCRIPT_DIR/${GPL_DIR_NAME}.build"/toolchain/toolchain-*/bin/*-openwrt-linux-gcc; do
        [ -x "$candidate" ] || continue
        echo "$candidate"
        return 0
    done

    die "unable to find target compiler for shc; set GPL_SHC_CC=/path/to/target-gcc"
}

resolve_shc_strip() {
    if [ -n "${GPL_SHC_STRIP:-}" ]; then
        [ -x "$GPL_SHC_STRIP" ] || die "GPL_SHC_STRIP is not executable: $GPL_SHC_STRIP"
        echo "$GPL_SHC_STRIP"
        return 0
    fi

    local shc_cc shc_strip_candidate
    shc_cc="$(resolve_shc_cc)"

    for shc_strip_candidate in \
        "${shc_cc%-gcc}-strip" \
        "${shc_cc%-gcc-*}-strip"; do
        [ -x "$shc_strip_candidate" ] || continue
        echo "$shc_strip_candidate"
        return 0
    done

    die "unable to find target strip for shc; set GPL_SHC_STRIP=/path/to/target-strip"
}

protect_runtime_shell_scripts() {
    if [ "$PROTECT_SHELL_SCRIPTS" != "1" ]; then
        echo "[gpl] protect_runtime_shell_scripts: skipped (use --protect-shell-scripts to enable)"
        return 0
    fi

    echo "[gpl] protect_runtime_shell_scripts"
    require_command python3 openssl shc
    require_path "$SCRIPT_DIR/gpl_tools/protect_runtime_shell_scripts.py"

    local shc_cc
    shc_cc="$(resolve_shc_cc)"

    local shc_strip
    shc_strip="$(resolve_shc_strip)"

    python3 "$SCRIPT_DIR/gpl_tools/protect_runtime_shell_scripts.py" \
        --shc "$(command -v shc)" \
        --cc "$shc_cc" \
        --strip "$shc_strip" \
        "$SOURCE_PATH/add_files" \
        "$SOURCE_PATH/P_MTK/$MTK_VERSION_DIR/wifi7_add_files/wl_scripts"
}

clean_p_elx() {
    echo "[gpl] clean_p_elx"
    cd "$SOURCE_PATH/P_ELX"
# clear P_ELX
local p_elx_remove_folders=(fwConfig)
local p_elx_folders=(
    cli
    edi_util
    elecom_ota
    mac_radius
    osapi
    snmpd_modules
    systemdaemon
    testdbox
    web
    dbox2
    elecom_cloud_apps
    fcgibox
    toolbox
    header_gen
    netlink_monitor
    poestat_max5995
    start_all
    system_init
)
for folder in "${p_elx_remove_folders[@]}"; do
    rm -rf "$folder"
done
for folder in "${p_elx_folders[@]}"; do
    case $folder in
        cli)               keep_files="cli" ;;
        dbox2)             keep_files="dbox_init libdbox.a libdbox.so" ;;
        edi_util)          keep_files="edi_util" ;;
            elecom_cloud_apps) keep_files="admlink/admlink admlink/admlink_ctrl libadmlink/libadminLink.so" ;;
        elecom_ota)        keep_files="fwd fwd_cli" ;;
        fcgibox)           keep_files="fcgibox" ;;
        mac_radius)        keep_files="mac_radius mac_radius_kmod.ko" ;;
        osapi)             keep_files="libosapi.a libosapi.so" ;;
        snmpd_modules)     keep_files="libnetsnmpObjects.so" ;;
        systemdaemon)      keep_files="sd sd_ctrl" ;;
        testdbox)          keep_files="testdbox" ;;
        toolbox)           keep_files="libtbox.a libtbox.so" ;;
        system_init)       keep_files="system_init" ;;
        start_all)         keep_files="start_all" ;;
        netlink_monitor)   keep_files="netlink_monitor" ;;
        header_gen)        keep_files="header.target header.x86" ;;
        poestat_max5995)   keep_files="poestat" ;;
        web)               continue ;;
        *)                 keep_files="" ;;
    esac

    tmpdir=$(mktemp -d)
    cd "$SOURCE_PATH/P_ELX/$folder"

    # Preserve Makefiles
    for mf in Makefile_1_gpl Makefile_2_bsp Makefile_3_def; do
        [ -f "$mf" ] && cp -a "$mf" "$tmpdir/"
    done

    # Preserve target binary files
    for f in $keep_files; do
        if [ -f "$f" ]; then
            mkdir -p "$tmpdir/$(dirname "$f")"
            cp -a "$f" "$tmpdir/$f"
        fi
    done

    # Wipe folder and restore kept files
    cd "$SOURCE_PATH/P_ELX"
    rm -rf "$folder"
    mkdir "$folder"
    cp -a "$tmpdir/." "$folder/"
    rm -rf "$tmpdir"
done
}

strip_p_elx_binaries() {
    echo "[gpl] strip_p_elx_binaries"
    local cross_strip
    if ! cross_strip="$(resolve_shc_strip 2>/dev/null)"; then
        echo "[gpl] strip_p_elx_binaries: skipped (no cross-strip found; set GPL_SHC_STRIP or GPL_SHC_CC)"
        return 0
    fi

    local f file_type
    find "$SOURCE_PATH/P_ELX" -type f | while read -r f; do
        [[ "$f" == *.a ]] && continue
        file_type=$(file -b "$f" 2>/dev/null)
        [[ "$file_type" == *"ELF"*"ARM aarch64"* ]] || continue
        if [[ "$f" == *.ko ]]; then
            "$cross_strip" --strip-debug "$f"
            echo "[gpl] stripped debug: ${f#$SOURCE_PATH/}"
        else
            "$cross_strip" "$f"
            echo "[gpl] stripped: ${f#$SOURCE_PATH/}"
        fi
    done
}

clean_p_bsd_nginx() {
    echo "[gpl] clean_p_bsd_nginx: keep pre-built binary only for P_BSD/nginx-1.24.x"
    local dir="$SOURCE_PATH/P_BSD/nginx-1.24.x"
    [ -d "$dir" ] || return 0
    local tmpdir="${dir}.tmp"
    rm -rf "$tmpdir"
    mkdir -p "$tmpdir"

    # Preserve: ELX build system files + LICENSE (BSD allows binary-only distribution)
    for f in Makefile_1_gpl Makefile_2_bsp Makefile_3_def LICENSE; do
        [ -f "$dir/$f" ] && cp -a "$dir/$f" "$tmpdir/"
    done

    # Preserve: pre-built files under .build/<CROSS_PATH_NAME>/<bsp_id>/
    # includes nginx binary ($(PROG)) and config.default
    if [ -d "$dir/.build" ]; then
        local build_file
        local rel
        while IFS= read -r -d '' build_file; do
            rel="${build_file#$dir/}"
            mkdir -p "$tmpdir/$(dirname "$rel")"
            cp -a "$build_file" "$tmpdir/$rel"
        done < <(find "$dir/.build" -type f -print0)
    fi

    # Replace entire directory with only the kept files
    # Removes all source code (src/, auto/, contrib/, etc.) and build artifacts (objs/, Makefile)
    rm -rf "$dir"
    mv "$tmpdir" "$dir"
}

clean_p_free() {
    echo "[gpl] clean_p_free: keep pre-built binaries/libraries only for P_FREE/net-snmp-5.9.x"
    local dir="$SOURCE_PATH/P_FREE/net-snmp-5.9.x"
    local tmpdir
    tmpdir="${dir}.tmp"  # same filesystem as dir — avoid cross-device mv error
    rm -rf "$tmpdir"
    mkdir -p "$tmpdir"

    # Preserve: ELX build system files + copyright
    for f in Makefile_1_gpl Makefile_2_bsp Makefile_3_def COPYING; do
        [ -f "$dir/$f" ] && cp -a "$dir/$f" "$tmpdir/"
    done

    # Preserve: pre-built shared libraries (used by install_lib) and binaries (used by install)
    # Reference: wab-be187-gpl P_FREE/net-snmp-5.9.x
    mkdir -p "$tmpdir/snmplib/.libs" \
             "$tmpdir/agent/.libs" \
             "$tmpdir/agent/helpers/.libs" \
             "$tmpdir/apps/.libs"
    cp -a "$dir/snmplib/.libs"/libnetsnmp.so*              "$tmpdir/snmplib/.libs/"       2>/dev/null || true
    cp -a "$dir/agent/.libs"/libnetsnmpagent.so*           "$tmpdir/agent/.libs/"         2>/dev/null || true
    cp -a "$dir/agent/.libs"/libnetsnmpmibs.so*            "$tmpdir/agent/.libs/"         2>/dev/null || true
    cp -a "$dir/agent/helpers/.libs"/libnetsnmphelpers.so* "$tmpdir/agent/helpers/.libs/" 2>/dev/null || true
    cp -a "$dir/agent/.libs/snmpd"                         "$tmpdir/agent/.libs/"         2>/dev/null || true
    cp -a "$dir/apps/.libs/snmptrap"                       "$tmpdir/apps/.libs/"          2>/dev/null || true

    # Replace entire directory with only the kept files
    rm -rf "$dir"
    mv "$tmpdir" "$dir"
}

# ## Step 1.3: Add P_MTK Standalone Binaries

# | Component | Target Files |
# |-----------|-------------|
# | ated_ext | `ated_ext`, `ated_ext_cli` |
# | mii_mgr | `mii_mgr` |
# | mwctl | `mwctl` |
# ## Step 1.4: Add P_MTK Kernel Modules

# Kernel modules (.ko) and Module.symvers are under the MTK version directory (auto-detected as `MTK_VERSION_DIR`, e.g., `v8.2.1.5` or `mt7988-mt7992-MP3`).

# ### Exact Module File List

# | Module Path | Target Files (relative to module dir) |
# |-------------|---------------------------------------|
# | `<ver>/backports-5.15.81-1` | `compat/compat.ko`, `net/wireless/cfg80211.ko` |
# | `<ver>/mt_wifi7/wlan_hwifi` | `connac_if.ko`, `mt7992.ko`, `mtk_hwifi.ko`, `mtk_pci.ko`, `mtk_wed.ko` |
# | `<ver>/mt_wifi7/mt_wifi_ap` | `mt_wifi.ko` |
# | `<ver>/mt_wifi_cmn` | `mt_wifi_cmn.ko` |
# | `<ver>/mtfwd` | `mtfwd.ko` |
# | `<ver>/mapfilter` | `mapfilter.ko` |
# | `<ver>/warp` | `mtk_warp.ko` |
# | `<ver>/mtqos`           | (no .ko built/installed — IS_MTK_MTQIS typo in make_tag_pkgs.make; keep LICENSE + Makefiles) |

# ============================================================
# P_MTK Install File List (verified against board/ config.product)
# All 3 boards: EW-7486LBE, EW-7476LBS, EW-7786LBE — identical flags
# ============================================================
#
# --- Standalone Apps (make_tag_app.make) ---
# INSTALL_PATH_BIN  = $(E_P_STAGING_APP)/bin  → rootfs: /bin
# INSTALL_PATH_SBIN = $(E_P_STAGING_APP)/sbin → rootfs: /sbin
#
# | Component | config.product flag    | Source Binary | Installed As  |
# |-----------|------------------------|---------------|---------------|
# | ated_ext  | IS_PKG_ATED=y          | ated_ext      | /bin/ated     |
# | mii_mgr   | IS_PKG_MII_MGR=y       | mii_mgr       | /sbin/mii_mgr |
# | mwctl     | IS_PKG_MWCTL=y         | mwctl         | /sbin/mwctl   |
# | sigma_daemon | IS_PKG_SIGMA_DAEMON=y | (pre-built) | /sbin/*       |  ← all boards enable, but excluded from GPL
# | sigma_dut | IS_PKG_SIGMA_DUT=y     | (pre-built)   | /sbin/*       |  ← all boards enable, but excluded from GPL
#
# --- Kernel Modules (make_tag_kernel.make) ---
# INSTALL_PATH_LIB = $(E_P_STAGING_LIB)/modules → rootfs: /lib/modules/
# Each LIBKO is installed flat into /lib/modules/
#
# | Component (mt7988-mt7992-MP3/...)  | config.product flag           | KONAME (from Makefile_1_gpl / Makefile)             | FW Install Path |
# |------------------------------------|-------------------------------|-----------------------------------------------------|-----------------|
# | backports-5.15.81-1                | IS_MTK_WIFI7_BACKPORT=y (all) | compat/compat.ko, net/wireless/cfg80211.ko           | /lib/modules/   |
# | mapfilter                          | IS_MTK_MAPFILTER=y (all)      | mapfilter.ko                                        | /lib/modules/   |
# | mt_wifi_cmn                        | IS_MTK_WIFI_CMN=y (all)       | mt_wifi_cmn.ko                                      | /lib/modules/   |
# | mt_wifi7                           | IS_MTK_WIFI7_DRIVER=y (all)   | mt_wifi_ap/mt_wifi.ko                               | /lib/modules/   |
# | mt_wifi7/wlan_hwifi                | IS_MTK_WIFI7_HWIFI=y (all)    | connac_if.ko, mtk_wed.ko, mt7992.ko, mtk_pci.ko, mtk_hwifi.ko | /lib/modules/ |
# | warp                               | IS_MTK_WARP=y (all)           | mtk_warp.ko                                         | /lib/modules/   |
# | mtfwd                              | IS_MTK_MTFWD=y (all)          | mtfwd.ko                                            | /lib/modules/   |
# | mtqos                              | IS_MTK_MTQOS=y (all)          | (no .ko built) — note: make_tag_pkgs.make uses      | —               |
# |                                    |                               | IS_MTK_MTQIS (typo), so module is never installed.  |                 |
# |                                    |                               | LICENSE + Makefile_1_gpl preserved only.            |                 |

clean_p_mtk_standalone() {
    echo "[gpl] clean_p_mtk_standalone"
    cd "$SOURCE_PATH/P_MTK"
# clear P_MTK
local p_mtk_standalone=(ated_ext mii_mgr mwctl)
local p_mtk_remove_folders=(sigma_daemon sigma_dut)

# Remove unwanted standalone components
for folder in "${p_mtk_remove_folders[@]}"; do
    rm -rf "$folder"
done

# Clean standalone components (keep Makefiles + LICENSE + binaries only)
for folder in "${p_mtk_standalone[@]}"; do
    case $folder in
        ated_ext) keep_files="ated_ext ated_ext_cli" ;;
        mii_mgr)  keep_files="mii_mgr" ;;
        mwctl)    keep_files="mwctl" ;;
        *)        keep_files="" ;;
    esac

    tmpdir=$(mktemp -d)
    cd "$SOURCE_PATH/P_MTK/$folder"

    # Preserve Makefiles
    for mf in Makefile_1_gpl Makefile_2_bsp Makefile_3_def; do
        [ -f "$mf" ] && cp -a "$mf" "$tmpdir/"
    done

    # Preserve LICENSE / COPYING (top-level only)
    find . -maxdepth 1 \( -iname "LICENSE" -o -iname "license" -o -iname "COPYING" -o -iname "COPYRIGHT" \) -exec cp -a {} "$tmpdir/" \;

    # Preserve target binaries
    for f in $keep_files; do
        [ -f "$f" ] && cp -a "$f" "$tmpdir/"
    done

    cd "$SOURCE_PATH/P_MTK"
    rm -rf "$folder"
    mkdir "$folder"
    cp -a "$tmpdir/." "$folder/"
    rm -rf "$tmpdir"
done
}

clean_p_mtk_kernel() {
    echo "[gpl] clean_p_mtk_kernel"
# Clean kernel module version directory (per-MODEL via MTK_VERSION_DIR)
# Keeps per-subdir: installed .ko files + LICENSE/COPYING + Makefile_1_gpl/2_bsp/3_def
local mtk_ver_path="$SOURCE_PATH/P_MTK/$MTK_VERSION_DIR"
if [ -d "$mtk_ver_path" ]; then
    tmpdir=$(mktemp -d)
    VER="$mtk_ver_path"
    VER_DIR_NAME="$MTK_VERSION_DIR"

    # backports-5.15.81-1: compat/compat.ko, net/wireless/cfg80211.ko + COPYING + inner LICENSE
    for ko in compat/compat.ko net/wireless/cfg80211.ko; do
        f="$VER/backports-5.15.81-1/$ko"
        if [ -f "$f" ]; then
            mkdir -p "$tmpdir/backports-5.15.81-1/$(dirname "$ko")"
            cp -a "$f" "$tmpdir/backports-5.15.81-1/$ko"
        fi
    done
    _ptk_meta "$VER/backports-5.15.81-1" "$tmpdir/backports-5.15.81-1"
    # Marvell libertas LICENSE is nested deeper
    _lib="$VER/backports-5.15.81-1/drivers/net/wireless/marvell/libertas/LICENSE"
    if [ -f "$_lib" ]; then
        mkdir -p "$tmpdir/backports-5.15.81-1/drivers/net/wireless/marvell/libertas"
        cp -a "$_lib" "$tmpdir/backports-5.15.81-1/drivers/net/wireless/marvell/libertas/"
    fi

    # mapfilter: mapfilter.ko
    mkdir -p "$tmpdir/mapfilter"
    if [ -f "$VER/mapfilter/mapfilter.ko" ]; then cp -a "$VER/mapfilter/mapfilter.ko" "$tmpdir/mapfilter/"; fi
    _ptk_meta "$VER/mapfilter" "$tmpdir/mapfilter"

    # mt_wifi_cmn: mt_wifi_cmn.ko
    mkdir -p "$tmpdir/mt_wifi_cmn"
    if [ -f "$VER/mt_wifi_cmn/mt_wifi_cmn.ko" ]; then cp -a "$VER/mt_wifi_cmn/mt_wifi_cmn.ko" "$tmpdir/mt_wifi_cmn/"; fi
    _ptk_meta "$VER/mt_wifi_cmn" "$tmpdir/mt_wifi_cmn"

    # mt_wifi7/wlan_hwifi: keep list from MTK_WIFI_HWIFI_KO_LIST (per-model in validate_model)
    # be72 family: connac_if mtk_wed mt7992 mtk_pci mtk_hwifi
    # be187:       connac_if mtk_wed mt7990 mt7991 mtk_pci mtk_hwifi
    mkdir -p "$tmpdir/mt_wifi7/wlan_hwifi"
    for ko in $MTK_WIFI_HWIFI_KO_LIST; do
        if [ -f "$VER/mt_wifi7/wlan_hwifi/$ko" ]; then cp -a "$VER/mt_wifi7/wlan_hwifi/$ko" "$tmpdir/mt_wifi7/wlan_hwifi/"; fi
    done
    _ptk_meta "$VER/mt_wifi7/wlan_hwifi" "$tmpdir/mt_wifi7/wlan_hwifi"

    # mt_wifi7/mt_wifi_ap: mt_wifi.ko
    mkdir -p "$tmpdir/mt_wifi7/mt_wifi_ap"
    if [ -f "$VER/mt_wifi7/mt_wifi_ap/mt_wifi.ko" ]; then cp -a "$VER/mt_wifi7/mt_wifi_ap/mt_wifi.ko" "$tmpdir/mt_wifi7/mt_wifi_ap/"; fi

    # mt_wifi7 top-level: Makefiles only (no .ko at top level)
    _ptk_meta "$VER/mt_wifi7" "$tmpdir/mt_wifi7"
    # mt_wifi7/mt_wifi/license (nested license)
    if [ -f "$VER/mt_wifi7/mt_wifi/license" ]; then
        mkdir -p "$tmpdir/mt_wifi7/mt_wifi"
        cp -a "$VER/mt_wifi7/mt_wifi/license" "$tmpdir/mt_wifi7/mt_wifi/"
    fi

    # mtfwd: mtfwd.ko
    mkdir -p "$tmpdir/mtfwd"
    if [ -f "$VER/mtfwd/mtfwd.ko" ]; then cp -a "$VER/mtfwd/mtfwd.ko" "$tmpdir/mtfwd/"; fi
    _ptk_meta "$VER/mtfwd" "$tmpdir/mtfwd"

    # warp: mtk_warp.ko
    mkdir -p "$tmpdir/warp"
    if [ -f "$VER/warp/mtk_warp.ko" ]; then cp -a "$VER/warp/mtk_warp.ko" "$tmpdir/warp/"; fi
    _ptk_meta "$VER/warp" "$tmpdir/warp"

    # mtqos: no .ko file (IS_MTK_MTQIS typo in make_tag_pkgs.make prevents install)
    # Preserve LICENSE + Makefiles only for GPL compliance
    _ptk_meta "$VER/mtqos" "$tmpdir/mtqos"

    # wifi7_add_files is cleaned separately later — preserve as-is now
    cp -a "$VER/wifi7_add_files" "$tmpdir/"

    # Wipe version dir and restore kept files
    cd "$SOURCE_PATH/P_MTK"
    rm -rf "$VER_DIR_NAME"
    mkdir "$VER_DIR_NAME"
    cp -a "$tmpdir/." "$VER_DIR_NAME/"
    rm -rf "$tmpdir"
fi
}

clean_p_mtk_wl_radius() {
    echo "[gpl] clean_p_mtk_wl_radius: revert wl_dbox2hostapd.sh to pre-mantis-9642 state ($WL_DBOX2HOSTAPD_REVERT_METHOD)"
    local target_path="P_MTK/$MTK_VERSION_DIR/wifi7_add_files/wl_scripts/wl_dbox2hostapd.sh"
    cd "$SOURCE_PATH"
    case "$WL_DBOX2HOSTAPD_REVERT_METHOD" in
        git:*)
            # mantis-9642 added radius_retry_primary_interval to wl_dbox2hostapd.sh.
            # Restore to the parent commit so strip_wifi7_wl_script_comments processes the clean version.
            local ref="${WL_DBOX2HOSTAPD_REVERT_METHOD#git:}"
            git checkout "$ref" -- "$target_path"
            ;;
        sed:radius_retry_primary_interval)
            # No clean baseline commit exists in HEAD's history (be187 v8.2.1.5 inherited
            # the patch when it was forked from v8.1.0.4). Revert just the active line.
            require_path "$SOURCE_PATH/$target_path"
            sed -i 's|^\([[:space:]]*\)w_conf radius_retry_primary_interval=3600\(.*\)|\1#radius_retry_primary_interval=600\2|' \
                "$SOURCE_PATH/$target_path"
            ;;
        *)
            die "unsupported WL_DBOX2HOSTAPD_REVERT_METHOD=$WL_DBOX2HOSTAPD_REVERT_METHOD"
            ;;
    esac
}

clean_wifi7_add_files() {
    echo "[gpl] clean_wifi7_add_files"
# wifi7_add_files File Usage Analysis (P_MTK/mt7988-mt7992-MP3/wifi7_add_files/)
# All files installed via PKGS_CROSS_INITRD_ADDED_$(IS_MTK_WIFI7_DRIVER) in make_tag_pkgs.make
#
# INSTALLED — all 3 boards (EW-7476LBS, EW-7486LBE, EW-7786LBE):
# | File                                    | FW Install Path                                     |
# |-----------------------------------------|-----------------------------------------------------|
# | 7988_WOCPU0_RAM_CODE_release.bin        | /lib/firmware/7988_WOCPU0_RAM_CODE_release.bin      |
# | 7988_WOCPU1_RAM_CODE_release.bin        | /lib/firmware/7988_WOCPU1_RAM_CODE_release.bin      |
# | 7988_WOCPU2_RAM_CODE_release.bin        | /lib/firmware/7988_WOCPU2_RAM_CODE_release.bin      |
# | mtk_wo_0.bin                            | /lib/firmware/mediatek/mtk_wo_0.bin                 |
# | mtk_wo_1.bin                            | /lib/firmware/mediatek/mtk_wo_1.bin                 |
# | mtk_wo_2.bin                            | /lib/firmware/mediatek/mtk_wo_2.bin                 |
# | regulatory.db                           | /lib/firmware/regulatory.db                         |
# | MT7992_EEPROM.bin                       | /lib/firmware/MT7992_EEPROM.bin                     |
# | WIFI_MT7992_PATCH_MCU_1_1_hdr.bin       | /lib/firmware/WIFI_MT7992_PATCH_MCU_1_1_hdr.bin     |
# | WIFI_MT7992_PHY_RAM_CODE_1_1.bin        | /lib/firmware/WIFI_MT7992_PHY_RAM_CODE_1_1.bin      |
# | WIFI_MT7992_WACPU_RAM_CODE_1_1.bin      | /lib/firmware/WIFI_MT7992_WACPU_RAM_CODE_1_1.bin    |
# | WIFI_RAM_CODE_MT7992_1_1.bin            | /lib/firmware/WIFI_RAM_CODE_MT7992_1_1.bin          |
# | WIFI_RAM_CODE_MT7992_1_1_TESTMODE.bin   | /lib/firmware/WIFI_RAM_CODE_MT7992_1_1_TESTMODE.bin |
# | hostapd/hostapd-ra0.conf               | /etc/wireless/hostapd-ra0.conf                      |
# | hostapd/hostapd-rai0.conf              | /etc/wireless/hostapd-rai0.conf                     |
# | wpa_supplicant/wpa_supplicant-apcli0.conf  | /etc/wireless/wpa_supplicant-apcli0.conf        |
# | wpa_supplicant/wpa_supplicant-apclii0.conf | /etc/wireless/wpa_supplicant-apclii0.conf       |
# | wpa_supplicant/supplicant_scan_action.sh   | /etc/wireless/supplicant_scan_action.sh         |
# | wl_scripts/wl_dbox2hostapd.sh          | /etc/wireless/wl_scripts/wl_dbox2hostapd.sh         |
# | wl_scripts/wl_dbox2dat.sh              | /etc/wireless/wl_scripts/wl_dbox2dat.sh             |
# | wl_scripts/wl_dbox2wpasupplicant.sh    | /etc/wireless/wl_scripts/wl_dbox2wpasupplicant.sh   |
# | wl_scripts/owe_transition_ie.sh        | /etc/wireless/wl_scripts/owe_transition_ie.sh       |
# | wl_scripts/wl_wps_action.sh            | /etc/wireless/wl_scripts/wl_wps_action.sh           |
# | wl_scripts/wpsd.sh                     | /etc/wireless/wl_scripts/wpsd.sh                    |
#
# NOT INSTALLED — sigma_test/ (Wi-Fi certification test files — REMOVED from GPL):
# | sigma_test/hostapd-phy0.conf           | Wi-Fi cert sigma testing only — REMOVED             |
# | sigma_test/hostapd-phy1.conf           | Wi-Fi cert sigma testing only — REMOVED             |
# | sigma_test/hostapd-phy2.conf           | Wi-Fi cert sigma testing only — REMOVED             |
# | sigma_test/wifi_cert.1.dat             | Wi-Fi cert sigma testing only — REMOVED             |
# | sigma_test/wifi_cert.2.dat             | Wi-Fi cert sigma testing only — REMOVED             |
# | sigma_test/wifi_cert_b0.dat            | Wi-Fi cert sigma testing only — REMOVED             |
# | sigma_test/wifi_cert_b1.dat            | Wi-Fi cert sigma testing only — REMOVED             |
# | sigma_test/wifi_cert_b2.dat            | Wi-Fi cert sigma testing only — REMOVED             |
#
# INSTALLED — EW-7476LBS only (BE5040):
# | l1profile.BE5040.dat                   | /etc/wireless/l1profile.dat                         |
# | mediatek/mt7992.5040.1.dat             | /etc/wireless/mediatek/mt7992.5040.1.dat            |
# | mediatek/mt7992.5040.b0.dat            | /etc/wireless/mediatek/mt7992.5040.b0.dat           |
# | mediatek/mt7992.5040.b1.dat            | /etc/wireless/mediatek/mt7992.5040.b1.dat           |
# | wl_scripts/mtkwifi.sh.BE5040           | /etc/wireless/wl_scripts/mtkwifi.sh                 |
# | wl_scripts/wl_define.sh.BE5040         | /etc/wireless/wl_scripts/wl_define.sh               |
#
# INSTALLED — EW-7786LBE and EW-7486LBE (BE7200):
# | l1profile.BE7200.dat                   | /etc/wireless/l1profile.dat                         |
# | mediatek/mt7992.1.dat                  | /etc/wireless/mediatek/mt7992.1.dat                 |
# | wl_scripts/mtkwifi.sh.BE7200           | /etc/wireless/wl_scripts/mtkwifi.sh                 |
# | wl_scripts/wl_define.sh.BE7200         | /etc/wireless/wl_scripts/wl_define.sh               |
#
# INSTALLED — EW-7786LBE only:
# | mediatek/mt7990.b0.dat                 | /etc/wireless/mediatek/mt7992.b0.dat                |
# | mediatek/mt7990.b1.dat                 | /etc/wireless/mediatek/mt7992.b1.dat                |
#
# INSTALLED — EW-7486LBE only:
# | mediatek/mt7990.b0.be36.dat            | /etc/wireless/mediatek/mt7992.b0.dat                |
# | mediatek/mt7990.b1.be36.dat            | /etc/wireless/mediatek/mt7992.b1.dat                |
#
# NOT INSTALLED (no reference in make_tag_pkgs.make for any board in this repo):
# | MT7992_MT7975_MT7977_EEPROM_BE7200_2i5e_sky_nonlinear.bin | alternate EEPROM variant — unused  |
# | MT7992_MT7975_MT7979_EEPROM_BE7200_iPAiLNA.bin            | alternate EEPROM variant — unused  |
# | MT7992_MT7976_MT7977_EEPROM_BE7200_ePAeLNA_midFEM.bin     | alternate EEPROM variant — unused  |
# | MT7992_MT7978_MT7979_EEPROM_BE6500_iPAiLNA.bin            | alternate EEPROM variant — unused  |
# | mediatek/mt7990.1.dat                                     | EW-7896LBE only — not in this repo |

cd "$SOURCE_PATH/P_MTK/$MTK_VERSION_DIR/wifi7_add_files"

# sigma_test/ is Wi-Fi certification only, not installed by any board — remove for all
rm -rf sigma_test

case "$MODEL" in
    EW-7476LBS|EW-7486LBE|EW-7786LBE)
        # be72 family (MT7992): remove unreferenced alternate EEPROM variants
        rm -f MT7992_MT7975_MT7977_EEPROM_BE7200_2i5e_sky_nonlinear.bin
        rm -f MT7992_MT7975_MT7979_EEPROM_BE7200_iPAiLNA.bin
        rm -f MT7992_MT7976_MT7977_EEPROM_BE7200_ePAeLNA_midFEM.bin
        rm -f MT7992_MT7978_MT7979_EEPROM_BE6500_iPAiLNA.bin
        rm -f mediatek/mt7990.1.dat                # EW-7896LBE only, not in this repo

        # Per-model variant cleanup
        case "$MODEL" in
            EW-7476LBS)
                # Keep: BE5040 files only; remove BE7200 common + others
                rm -f l1profile.BE7200.dat
                rm -f mediatek/mt7992.1.dat
                rm -f wl_scripts/mtkwifi.sh.BE7200
                rm -f wl_scripts/wl_define.sh.BE7200
                rm -f mediatek/mt7990.b0.dat          # EW-7786LBE only
                rm -f mediatek/mt7990.b1.dat          # EW-7786LBE only
                rm -f mediatek/mt7990.b0.be36.dat     # EW-7486LBE only
                rm -f mediatek/mt7990.b1.be36.dat     # EW-7486LBE only
                ;;
            EW-7786LBE)
                # Keep: BE7200 common + EW-7786LBE-only; remove BE5040 + EW-7486LBE-only
                rm -f l1profile.BE5040.dat
                rm -f mediatek/mt7992.5040.1.dat
                rm -f mediatek/mt7992.5040.b0.dat
                rm -f mediatek/mt7992.5040.b1.dat
                rm -f wl_scripts/mtkwifi.sh.BE5040
                rm -f wl_scripts/wl_define.sh.BE5040
                rm -f mediatek/mt7990.b0.be36.dat     # EW-7486LBE only
                rm -f mediatek/mt7990.b1.be36.dat     # EW-7486LBE only
                ;;
            EW-7486LBE)
                # Keep: BE7200 common + EW-7486LBE-only; remove BE5040 + EW-7786LBE-only
                rm -f l1profile.BE5040.dat
                rm -f mediatek/mt7992.5040.1.dat
                rm -f mediatek/mt7992.5040.b0.dat
                rm -f mediatek/mt7992.5040.b1.dat
                rm -f wl_scripts/mtkwifi.sh.BE5040
                rm -f wl_scripts/wl_define.sh.BE5040
                rm -f mediatek/mt7990.b0.dat          # EW-7786LBE only
                rm -f mediatek/mt7990.b1.dat          # EW-7786LBE only
                ;;
        esac
        ;;
    EW-7896LBE)
        # be187 (MT7990): single product, no BE5040/BE7200 variants.
        # Remove unreferenced alternate EEPROM variants (only iFEM233 / iPAiLNA exist).
        rm -f MT7990_EEPROM_iFEM233.bin
        rm -f MT7990_iPAiLNA_EEPROM.bin
        ;;
    *)
        echo "WARNING: unknown MODEL=$MODEL, skipping model-specific wifi7_add_files cleanup"
        ;;
esac
}

patch_makefiles() {
    echo "[gpl] patch_makefiles"
    require_command python3
    require_path "$SCRIPT_DIR/gpl_tools/patch_makefiles.py"
    python3 "$SCRIPT_DIR/gpl_tools/patch_makefiles.py" "$SOURCE_PATH"
}

save_status() {
    cd "$SOURCE_PATH"

    # Packages released as binary-only (source stripped by clean_p_* steps).
    # Add new entries here when a package ships pre-built files instead of source.
    local binary_only_dirs=(
        P_ELX
        P_MTK
        P_FREE
        P_BSD/nginx-1.24.x
    )

    # Packages removed entirely from GPL release (deleted by clean_p_* steps).
    # Excluded from source restore so deletions are preserved for git add -u below.
    local removed_pkg_dirs=(
        P_MIT/dropbear-2022.83
    )

    # Restore source-shipping open-source packages to committed state
    # (undo build-time generated files: configure, Makefile.in, aclocal.m4, etc.)
    # binary-only and removed-pkg dirs are excluded — must not be restored.
    local exclude_args=()
    for dir in "${binary_only_dirs[@]}" "${removed_pkg_dirs[@]}"; do
        exclude_args+=(":(exclude)$dir")
    done
    git checkout HEAD -- P_BSD P_GPL P_KNL P_MIT P_OTH P_RTL \
        "${exclude_args[@]}" 2>/dev/null || true

    # Stage all tracked changes (includes removed_pkg_dirs deletions and board_cfg edits)
    # and force-add binary-only dirs (gitignored by default)
    git add -u
    for dir in "${binary_only_dirs[@]}"; do
        git add -f "$dir"
    done
}

resolve_release_version() {
    local config_product="$SOURCE_PATH/board/$BOARD_DIR/config/config.product"
    local version_major
    local version_minor
    local version_patch

    require_path "$config_product"

    version_major=$(sed -n 's/^CONFIG_VERSION_FW_MAJOR="\([^"]*\)"$/\1/p' "$config_product" | head -n 1)
    version_minor=$(sed -n 's/^CONFIG_VERSION_FW_MINOR="\([^"]*\)"$/\1/p' "$config_product" | head -n 1)
    version_patch=$(sed -n 's/^CONFIG_VERSION_FW_PATCH="\([^"]*\)"$/\1/p' "$config_product" | head -n 1)

    [ -n "$version_major" ] || die "unable to resolve CONFIG_VERSION_FW_MAJOR from $config_product"
    [ -n "$version_minor" ] || die "unable to resolve CONFIG_VERSION_FW_MINOR from $config_product"
    [ -n "$version_patch" ] || die "unable to resolve CONFIG_VERSION_FW_PATCH from $config_product"

    printf '%s.%s.%s\n' "$version_major" "$version_minor" "$version_patch"
}

is_expected_release_tree() {
    [ "$(basename "$SOURCE_PATH")" = "$GPL_DIR_NAME" ]
}

clean_build_artifacts() {
    echo "[gpl] clean_build_artifacts"

    if ! is_expected_release_tree; then
        echo "[gpl] skip build artifact cleanup: expected release tree $GPL_DIR_NAME, current $(basename "$SOURCE_PATH")"
        return 0
    fi

    cd "$SOURCE_PATH"
    [ -d .git ] || die "missing root .git before git clean"
    git clean -dfxq
    echo "[gpl] clean_build_artifacts done"
}

write_release_readme() {
    echo "[gpl] write_release_readme"

    local release_version
    local release_version_dashed
    local firmware_dir
    local firmware_name

    if ! is_expected_release_tree; then
        echo "[gpl] skip README generation: expected release tree $GPL_DIR_NAME, current $(basename "$SOURCE_PATH")"
        return 0
    fi

    release_version=$(resolve_release_version)
    release_version_dashed=${release_version//./-}
    firmware_dir="image/${IMAGE_DIR}/release/UPG"
    firmware_name="${CUSTOMER_MODEL_NAME}-FW-${release_version_dashed}-UPG.bin"

    cat > "$SOURCE_PATH/README.md" <<'EOF'
# __CUSTOMER_MODEL_NAME__ GPL Package

This package contains the GPL release source for __CUSTOMER_MODEL_NAME__.

## Package Extraction

Extract the delivered archive and enter the package root directory:

```bash
tar -xzf <package-name>.tar.gz
cd __GPL_DIR_NAME__
```

## Firmware Build Procedure

Run the build from the board directory below:

```bash
cd board/__BOARD_DIR__
make
```

## Firmware Output Location

After the build completes successfully, the upgrade firmware image is generated at:

__FIRMWARE_DIR__/__FIRMWARE_NAME__

Firmware naming rule:

__CUSTOMER_MODEL_NAME__-FW-<major>-<minor>-<patch>-UPG.bin

Example:

__FIRMWARE_NAME__

EOF

    sed -i \
        -e "s|__CUSTOMER_MODEL_NAME__|$CUSTOMER_MODEL_NAME|g" \
        -e "s|__GPL_DIR_NAME__|$GPL_DIR_NAME|g" \
        -e "s|__BOARD_DIR__|$BOARD_DIR|g" \
        -e "s|__FIRMWARE_DIR__|$firmware_dir|g" \
        -e "s|__FIRMWARE_NAME__|$firmware_name|g" \
        "$SOURCE_PATH/README.md"
}

remove_root_git_metadata() {
    echo "[gpl] remove_root_git_metadata"

    if ! is_expected_release_tree; then
        echo "[gpl] skip root git metadata removal: expected release tree $GPL_DIR_NAME, current $(basename "$SOURCE_PATH")"
        return 0
    fi

    cd "$SOURCE_PATH"
    rm -rf .git
    rm -f .gitignore .gitattributes .gitmodules
}

restore_freeradius_release_version() {
    echo "[gpl] restore_freeradius_release_version (ref=$FREERADIUS_RESTORE_REF)"
    cd "$SOURCE_PATH"

    # freeradius-server-3.0.27: restore to a clean baseline before internal
    # session-management patches and mantis-10161 customization. Per-model anchor
    # set in validate_model (FREERADIUS_RESTORE_REF).
    git checkout "$FREERADIUS_RESTORE_REF" -- P_GPL/freeradius-server-3.0.27/
}

revert_hostapd_internal_radius_patches() {
    echo "[gpl] revert_hostapd_internal_radius_patches (radius_client=$HOSTAPD_RADIUS_CLIENT_RESTORE_REF, session_timeout=$HOSTAPD_SESSION_TIMEOUT_RESTORE_REF)"
    cd "$SOURCE_PATH"

    # hostapd: revert non-official internal RADIUS commits
    # mantis-9642: RADIUS server failover fix in radius_client.c
    git checkout "$HOSTAPD_RADIUS_CLIENT_RESTORE_REF" -- \
        P_GPL/hostapd-2022-07-29-b704dc72/src/radius/radius_client.c
    # mantis-11774: RADIUS session-timeout syslog in wpa_auth / eapol_auth_sm
    git checkout "$HOSTAPD_SESSION_TIMEOUT_RESTORE_REF" -- \
        P_GPL/hostapd-2022-07-29-b704dc72/src/ap/ieee802_1x.c \
        P_GPL/hostapd-2022-07-29-b704dc72/src/ap/wpa_auth.c \
        P_GPL/hostapd-2022-07-29-b704dc72/src/ap/wpa_auth.h \
        P_GPL/hostapd-2022-07-29-b704dc72/src/ap/wpa_auth_glue.c \
        P_GPL/hostapd-2022-07-29-b704dc72/src/eapol_auth/eapol_auth_sm.c \
        P_GPL/hostapd-2022-07-29-b704dc72/src/eapol_auth/eapol_auth_sm.h
}

remove_dropbear_package() {
    echo "[gpl] remove_dropbear_package"
    cd "$SOURCE_PATH"

    # dropbear-2022.83: remove entire directory (internal SSH customization, MIT license)
    rm -rf P_MIT/dropbear-2022.83

    # remove dropbear entry from make_tag_pkgs.make to prevent build failure
    sed -i '/dropbear-2022\.83/d' board_cfg/make_tag/make_tag_pkgs.make
}

create_release_tarball() {
    echo "[gpl] create_release_tarball"

    if ! is_expected_release_tree; then
        echo "[gpl] skip tarball creation: expected release tree $GPL_DIR_NAME, current $(basename "$SOURCE_PATH")"
        return 0
    fi

    local release_version
    local release_date
    local output_dir
    local tarball_name

    release_version=$(resolve_release_version)
    release_date=$(date +%Y%m%d)
    output_dir=$(dirname "$SOURCE_PATH")
    tarball_name="${CUSTOMER_MODEL_NAME}_${release_version}_${release_date}.tar.gz"

    rm -f "$output_dir/$tarball_name"
    tar -C "$output_dir" -czf "$output_dir/$tarball_name" "$(basename "$SOURCE_PATH")"
    echo "[gpl] Created tarball: $output_dir/$tarball_name"
}


# ============================================================
# Main
# ============================================================

main_release() {
    echo "[gpl] Starting GPL release preparation: MODEL=$MODEL"
    require_command find git python3 tar
    verify_source_tree
    clean_root
    clean_board_cfg_sensitive
    clean_board_cfg_make_tag_unused
    clean_board_dirs
    clean_board_include
    clean_add_files
    strip_add_files_script_comments
    clean_p_elx
    strip_p_elx_binaries
    clean_web_unused
    strip_web_comments
    clean_p_bsd_nginx
    clean_p_free
    clean_image_dirs
    clean_image_dir_variants
    clean_p_mtk_standalone
    clean_p_mtk_kernel
    clean_wifi7_add_files
    clean_p_mtk_wl_radius
    strip_wifi7_wl_script_comments
    protect_runtime_shell_scripts
    patch_makefiles
    save_status
    clean_build_artifacts
    write_release_readme
    remove_root_git_metadata
    create_release_tarball
    echo "[gpl] All steps complete."
}

main_test() {
    echo "[gpl] Starting GPL test workflow: MODEL=$MODEL MODE=$MODE"
    require_command find git python3 tar make

    case "$MODE" in
        full)  SOURCE_DIR="$SCRIPT_DIR/${GPL_DIR_NAME}.src" ;;
        quick) SOURCE_DIR="$SCRIPT_DIR/${GPL_DIR_NAME}.build" ;;
    esac
    TARGET_DIR="$SCRIPT_DIR/$GPL_DIR_NAME"
    SOURCE_PATH="$TARGET_DIR"

    ensure_safe_target_dir
    setup_workspace

    if [ "$MODE" = "full" ]; then
        patch_sensitive_values
        prepare_source_for_build
        restore_freeradius_release_version
        revert_hostapd_internal_radius_patches
        remove_dropbear_package
        build_fw_image
    fi

    main_release
}

parse_args() {
    MODEL="${1:-EW-7786LBE}"
    shift || true

    while [ $# -gt 0 ]; do
        case "$1" in
            --mode)
                [ -n "${2:-}" ] || die "--mode requires an argument (full|quick)"
                MODE="$2"
                case "$MODE" in
                    full|quick) ;;
                    *) die "unsupported --mode=$MODE (use full or quick)" ;;
                esac
                shift 2
                ;;
            --protect-shell-scripts)
                PROTECT_SHELL_SCRIPTS=1
                shift
                ;;
            *)
                die "unknown argument: $1"
                ;;
        esac
    done

    # full mode implies protect-shell-scripts
    if [ "$MODE" = "full" ] && [ "$PROTECT_SHELL_SCRIPTS" != "1" ]; then
        PROTECT_SHELL_SCRIPTS=1
        echo "[gpl] --mode full: enabling --protect-shell-scripts by default"
    fi
}

main() {
    parse_args "$@"
    validate_model

    if [ -n "$MODE" ]; then
        main_test
    else
        SOURCE_PATH=$(pwd)
        main_release
    fi
}

main "$@"
