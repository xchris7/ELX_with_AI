# gpl.sh / gpl_tools Reference Map

AI 索引地圖。修改 `gpl.sh` 或 `gpl_tools/` 前先讀這份。
完整流程說明見 `GPL_TEST_SOP.md`，專案脈絡見 `.claude/CLAUDE.md`。

> 行號以 `gpl.sh` 目前狀態為準（含開頭 AI 指引註解區）。
> 修改 `gpl.sh` 後若行號漂移，請執行 `grep -n "^[a-z_]*()" gpl.sh` 重新校正。

---

## 1. 函式責任表（gpl.sh）

### Helpers

| 函式 | 行號 | 責任 |
|------|------|------|
| `_ptk_meta` | 102 | 從 src 複製 LICENSE/COPYING + Makefile_1/2/3 到 dst |
| `die` | 113 | 輸出錯誤訊息並 exit 1 |
| `require_command` | 118 | 驗證指令存在於 PATH |
| `require_path` | 125 | 驗證檔案/目錄存在 |
| `validate_model` | 130 | 兩段式：per-model 設 BOARD_DIR/IMAGE_DIR/GPL_DIR_NAME/CUSTOMER_MODEL_NAME；family-level 設 MTK_VERSION_DIR/MTK_WIFI_HWIFI_KO_LIST/FREERADIUS_RESTORE_REF/HOSTAPD_*_RESTORE_REF/WL_DBOX2HOSTAPD_REVERT_METHOD |



### Test mode 專用

| 函式 | 行號 | 責任 |
|------|------|------|
| `ensure_safe_target_dir` | 194 | 防止在 TARGET_DIR 內執行（會被 rm -rf） |
| `setup_workspace` | 205 | 將 SOURCE_DIR 複製成 TARGET_DIR |
| `patch_sensitive_values` | 212 | 清除 P_ELX 內 cloud URL（dbox_nodes_cloud.c, admlink_main.c） |
| `prepare_source_for_build` | 220 | build 前還原 freeradius/hostapd（呼叫 restore_freeradius_release_version + revert_hostapd_internal_radius_patches） |
| `verify_fw_image` | 228 | 驗證 staging 內 uImage 與 FW bin 存在 |
| `build_fw_image` | 238 | 進 board/$BOARD_DIR 執行 make，成功後存 .build 快照 |

### Release 清理（main_release 執行順序）

| 順序 | 函式 | 行號 | 責任 |
|------|------|------|------|
| 1 | `verify_source_tree` | 254 | 驗證 add_files/board/board_cfg/P_ELX/P_FREE/P_MTK 存在 |
| 2 | `clean_root` | 270 | 刪 DEFINE/YML/scripts/README.md/.gitlab-ci.yml |
| 3 | `clean_board_cfg_sensitive` | 277 | 從 make_feeds.conf 移除 src- feed |
| 4 | `clean_board_cfg_make_tag_unused` | 321 | 只保留目前 toolchain 的 make_tag_lib（與 NA） |
| 5 | `clean_board_dirs` | 344 | 只保留目標機種的 board/ 子目錄 |
| 6 | `clean_board_include` | 356 | 刪 board_include 與 board/$BOARD_DIR/include |
| 7 | `clean_add_files` | 410 | 只保留 etc/sysctl.d/sbin 白名單檔案；依 MODEL 選 inittab；不保留 `dl_classical.sh` / `starteth_ipq6000.sh` / `usbTest.sh` |
| 8 | `strip_add_files_script_comments` | 506 | 呼叫 strip_shell_comments.py 處理 add_files |
| 9 | `clean_p_elx` | 585 | 只保留 P_ELX 元件指定的 binary/library + Makefile_*；移除 fwConfig，且 `elecom_cloud_apps/config_manager/` 不保留 |
| 10 | `clean_web_unused` | 494 | 刪 P_ELX/web/web_elecom/usb_disp.html |
| 11 | `strip_web_comments` | 499 | 呼叫 strip_web_comments.py 處理 P_ELX/web |
| 12 | `clean_p_bsd_nginx` | 661 | P_BSD/nginx-1.24.x：只留 LICENSE + Makefile_* + .build/ 預編譯產物 |
| 13 | `clean_p_free` | 692 | P_FREE/net-snmp-5.9.x：只留 COPYING + Makefile_* + 預編譯 .so/snmpd/snmptrap |
| 14 | `clean_image_dirs` | 365 | 只保留目標機種的 image/ 子目錄 |
| 15 | `clean_image_dir_variants` | 377 | per-MODEL 移除 image/$IMAGE_DIR/ 內已廢棄的 UBI/MP helper/input、stale `release/MP` / `*-UBI.bin`，並清掉舊 `SHA256.txt` 內的 `UBI.bin` 紀錄 |
| 16 | `clean_p_mtk_standalone` | 781 | P_MTK ated_ext/mii_mgr/mwctl 只留 binary；移除 sigma_daemon/sigma_dut |
| 17 | `clean_p_mtk_kernel` | 826 | 只留 `MTK_WIFI_HWIFI_KO_LIST` 指定的 .ko + 其他模組固定 .ko + LICENSE + `Makefile_*`；`wifi7_add_files` 完整保留 |
| 18 | `clean_wifi7_add_files` | 933 | family-aware：be72 移除 MT7992 alternate EEPROMs + 模型變體；be187 移除 MT7990 iFEM/iPAiLNA 變體；sigma_test 共用刪除 |
| 19 | `clean_p_mtk_wl_radius` | 909 | family-aware：be72 用 `git checkout`；be187 用 sed（v8.2.1.5 無 clean baseline commit） |
| 20 | `strip_wifi7_wl_script_comments` | 513 | 呼叫 strip_shell_comments.py 處理 `wifi7_add_files/wl_scripts` |
| 21 | `protect_runtime_shell_scripts` | 561 | 呼叫 protect_runtime_shell_scripts.py（受 --protect-shell-scripts 控制） |
| 22 | `patch_makefiles` | 1068 | 呼叫 patch_makefiles.py |
| 23 | `save_status` | 1075 | git checkout 還原 source-shipping 套件；force-add binary-only 目錄 |
| 24 | `clean_build_artifacts` | 1134 | git clean -dfxq |
| 25 | `write_release_readme` | 1148 | 重新產生 root README.md |
| 26 | `remove_root_git_metadata` | 1214 | 刪 .git/.gitignore/.gitattributes/.gitmodules |
| 27 | `create_release_tarball` | 1266 | 打包成 `<CUSTOMER_MODEL_NAME>_<version>_<date>.tar.gz` |

### Release 清理輔助函式（不在 main_release 直接呼叫順序中）

| 函式 | 行號 | 責任 |
|------|------|------|
| `detect_active_make_tag_lib` | 284 | 從 config.product 推斷目前 toolchain 對應的 make_tag_lib_*.make |
| `resolve_shc_cc` | 521 | 找 target gcc（環境變數 `GPL_SHC_CC` > .build/toolchain 自動偵測） |
| `resolve_shc_strip` | 540 | 找 target strip（環境變數 `GPL_SHC_STRIP` > 由 cc 推導） |
| `resolve_release_version` | 1111 | 從 config.product 讀 CONFIG_VERSION_FW_MAJOR/MINOR/PATCH |
| `is_expected_release_tree` | 1130 | 檢查 SOURCE_PATH basename 是否等於 GPL_DIR_NAME |

### Test mode 額外步驟（僅 --mode full，main_release 不呼叫）

| 函式 | 行號 | 責任 |
|------|------|------|
| `restore_freeradius_release_version` | 1227 | `git checkout $FREERADIUS_RESTORE_REF -- P_GPL/freeradius-server-3.0.27/`（per-model anchor） |
| `revert_hostapd_internal_radius_patches` | 1237 | `git checkout` 兩組 hostapd 檔案（radius_client.c 與 ap/eapol_auth_sm 群組）使用 per-model anchor |
| `remove_dropbear_package` | 1255 | 刪 P_MIT/dropbear-2022.83 + 從 make_tag_pkgs.make 移除 |

### 主流程

| 函式 | 行號 | 責任 |
|------|------|------|
| `main_release` | 1294 | release 清理主流程（共 27 步，1294-1324） |
| `main_test` | 1327 | test 主流程：setup_workspace → [full: build] → main_release |
| `main` | 1353 | 解析參數，分派 release / test |

### 全域變數（由 validate_model 設定）

| 變數 | 用途 |
|------|------|
| `BOARD_DIR` | board/ 子目錄名 |
| `IMAGE_DIR` | image/ 子目錄名 |
| `GPL_DIR_NAME` | 工作樹/.src/.build 目錄名 |
| `CUSTOMER_MODEL_NAME` | tarball 內顯示的客戶機型名 |
| `MTK_VERSION_DIR` | P_MTK/ 下版本目錄名（be72: `mt7988-mt7992-MP3`，be187: `v8.2.1.5`） |
| `MTK_WIFI_HWIFI_KO_LIST` | wlan_hwifi 要保留的 .ko 列表（空格分隔，per-family） |
| `FREERADIUS_RESTORE_REF` | freeradius 還原 git ref |
| `HOSTAPD_RADIUS_CLIENT_RESTORE_REF` | hostapd radius_client.c 還原 git ref |
| `HOSTAPD_SESSION_TIMEOUT_RESTORE_REF` | hostapd session-timeout 群組還原 git ref |
| `WL_DBOX2HOSTAPD_REVERT_METHOD` | `git:<ref>` 或 `sed:radius_retry_primary_interval`（be187 因 v8.2.1.5 無 clean baseline 才走 sed） |

### gpl_tools/ Python 工具

| 檔案 | 責任 | 被誰呼叫 |
|------|------|---------|
| `strip_shell_comments.py` | 移除 shell script 註解 | `strip_add_files_script_comments`, `strip_wifi7_wl_script_comments` |
| `strip_web_comments.py` | 移除 web 檔案開發者註解 | `strip_web_comments` |
| `patch_makefiles.py` | 修補 Makefile（GPL release 適用；repo source code 的 release-output 政策修正應維護在這裡，會 rewrite `board_cfg/make_tag/*.make`、移除已清掉腳本的 board install line，以及清掉 `elecom_cloud_apps/config_manager` / `json2dbox` / `dbox2json` 殘留引用） | `patch_makefiles` |
| `protect_runtime_shell_scripts.py` | wrapper + shc 混合保護 shell scripts | `protect_runtime_shell_scripts` |
| `encrypt_shell_scripts.py` | wrapper 加密底層實作 | 由 `protect_runtime_shell_scripts.py` import |

---

## 2. 決策樹

### 2.1 新增一個 MODEL

```
新 MODEL（例：EW-XXXXLBX）
  │
  ├─ 步驟 1：gpl.sh validate_model() per-model case (line 130)
  │   定義：BOARD_DIR / IMAGE_DIR / GPL_DIR_NAME / CUSTOMER_MODEL_NAME
  │
  ├─ 步驟 2：gpl.sh validate_model() family-level case
  │   選一個既有 family 加進去（共用 MTK_VERSION_DIR / KO list / commit refs），
  │   或開新 family case 並定義：
  │     MTK_VERSION_DIR （P_MTK 子目錄名）
  │     MTK_WIFI_HWIFI_KO_LIST （從 P_MTK/$MTK_VERSION_DIR/mt_wifi7/wlan_hwifi/Makefile_1_gpl 的 KONAME 抓）
  │     FREERADIUS_RESTORE_REF （freeradius 還原 anchor）
  │     HOSTAPD_RADIUS_CLIENT_RESTORE_REF （mantis-9642 family）
  │     HOSTAPD_SESSION_TIMEOUT_RESTORE_REF （mantis-11774 family）
  │     WL_DBOX2HOSTAPD_REVERT_METHOD （git:<ref> 或 sed:...）
  │
  ├─ 步驟 3：gpl.sh clean_add_files() (line 410)
  │   新增 keep_inittab 對應（依 platform 選 inittab_ttyS0_* 變體）
  │
  ├─ 步驟 4：gpl.sh clean_wifi7_add_files() (line 933)
  │   - 若加進既有 family case：在 inner case 加分支
  │   - 若是新 family：開新 outer case 寫該 family 通用 + per-model 變體刪除
  │
  ├─ 步驟 5：repo 內準備 <NEW_GPL_DIR_NAME>.src
  │
  └─ 驗證：
      ./gpl.sh EW-XXXXLBX --mode full
      檢查 staging 內有 ${MODEL}_uImage 與 ${MODEL}-FW-*.bin
```

### 2.2 新增/修改 P_ELX 元件

```
P_ELX 元件變動（編輯 clean_p_elx() at line 585）
  │
  ├─ 移除元件
  │   → 加到 p_elx_remove_folders=()
  │
  ├─ 新增元件（保留 binary）
  │   → 加到 p_elx_folders=()
  │   → 在 case $folder 區塊新增分支，列出 keep_files（相對於元件目錄）
  │   → keep_files 可含子路徑，例如 "admlink/admlink"
  │   → 若某個子目錄 binary（例如 `elecom_cloud_apps/config_manager`）不再保留，除了從 keep_files 拿掉，也要同步清掉 `patch_makefiles.py` 內的 Makefile/install 殘留引用
  │   → 註：web 是特例（continue），不適用本流程
  │
  └─ 元件改 source-shipping（要交付原始碼）
      → 從 p_elx_folders=() 移除（不再做 binary-only 處理）
      → 確認該目錄被 git tracked（save_status 會 git add -u）
      → 注意：P_ELX 整個目錄列在 save_status() 的 binary_only_dirs[]，
        若整個 P_ELX 改 source-shipping，需同步修改 save_status()
```

### 2.3 新增受保護的 shell script

```
新 shell script 進入 add_files/ 或 wl_scripts/
  │
  ├─ 問：此腳本會被其他腳本 source 或 . 引用嗎？
  │   │
  │   ├─ YES → WRAPPER（自解密 shell wrapper）
  │   │   編輯 gpl_tools/protect_runtime_shell_scripts.py
  │   │   加入 WRAPPER_RULES["add_files"] 或 WRAPPER_RULES["wl_scripts"]
  │   │   範例：sbin/fw_upgrade.sh、wl_define.sh*
  │   │
  │   └─ NO（直接 exec / 透過 shebang 執行）→ SHC（compile 成 target binary）
  │       編輯 gpl_tools/protect_runtime_shell_scripts.py
  │       加入 SHC_RULES["add_files"] 或 SHC_RULES["wl_scripts"]
  │       範例：sbin/automount.sh、mtkwifi.sh*
  │
  ├─ 同步檢查 clean_add_files() (line 410) 的 keep_sbin_files=()
  │   （否則會在 step 7 就被刪除，到 step 21 已經沒檔案可保護）
  │
  └─ 驗證：
      ./gpl.sh EW-7786LBE --mode quick --protect-shell-scripts
      file <輸出檔> 確認：
        WRAPPER → "POSIX shell script"（仍是 shell）
        SHC     → "ELF 64-bit LSB executable, ARM aarch64, stripped"
```

---

## 3. 「不要碰」清單

以下改動極易造成 build 失敗、release 內容外洩、或裝置端執行錯誤。

### main_release() 步驟順序（gpl.sh:1294-1324）

27 步順序編碼了相依性，**不要重排**。關鍵相依關係：

- `verify_source_tree`（step 1）必為第 1 步（其他步驟依賴這些目錄存在）
- `clean_p_elx`（step 9）→ `clean_web_unused`（step 10）→ `strip_web_comments`（step 11）
  （web 子目錄屬於 P_ELX，所以 P_ELX 整體清理在前，web 細部清理在後）
- `clean_image_dirs`（step 14）→ `clean_image_dir_variants`（step 15）
  （前者只保留目標機種子目錄，後者再從該子目錄內刪掉未引用的歷史變體檔案）
- `clean_p_mtk_kernel`（step 17）**必須**在 `clean_wifi7_add_files`（step 18）之前
  （前者用 `cp -a "$VER/wifi7_add_files" "$tmpdir/"` 完整保留，再交給後者處理；反過來會被 rm 掉）
- `clean_p_mtk_wl_radius`（step 19，還原 wl_dbox2hostapd.sh）**必須**在 `strip_wifi7_wl_script_comments`（step 20）之前
  （要先還原成 clean 版本再 strip，否則 strip 的是含 mantis-9642 patch 的版本）
- `strip_*_comments`（step 8/11/20）**必須**在 `protect_runtime_shell_scripts`（step 21）之前
  （保護後檔案是 wrapper 或 ELF，strip 工具會無法處理或 strip 掉錯的東西）
- `save_status`（step 23）**必須**在 `clean_build_artifacts`（step 24）之前
  （save_status 用 git add 標記要保留的 binary-only 目錄，clean_build_artifacts 才知道哪些要保留）
- `remove_root_git_metadata`（step 26）**必須**在 `create_release_tarball`（step 27）之前
  （tarball 不應含 .git）

### `save_status()` (gpl.sh:1075)

- `binary_only_dirs=()` 與 `removed_pkg_dirs=()` 列表動到會讓 `git checkout HEAD --` 把已刪除的 source 還原回來，等於洩露 internal source。
- `git checkout HEAD -- P_BSD P_GPL P_KNL P_MIT P_OTH P_RTL` 後接的 `:(exclude)` pattern 是必要的；省掉會還原 P_BSD/nginx-1.24.x 與 P_MIT/dropbear-2022.83 的 source。

### Test mode 的 internal patch 還原（per-MODEL anchor）

`prepare_source_for_build()` (line 220) 改成呼叫 `restore_freeradius_release_version()` (line 1227) + `revert_hostapd_internal_radius_patches()` (line 1237)。這兩個 helper 所用的 git ref 來自 `validate_model()` 設定的：

| 變數 | be72 family | be187 |
|------|-------------|-------|
| FREERADIUS_RESTORE_REF | `5ff6024ef` | `553cbfff5^` |
| HOSTAPD_RADIUS_CLIENT_RESTORE_REF | `ce7a22c69^` | `67e39f24d^` |
| HOSTAPD_SESSION_TIMEOUT_RESTORE_REF | `954db32f2^` | `47132c77c^` |
| WL_DBOX2HOSTAPD_REVERT_METHOD | `git:ce7a22c69^` | `sed:radius_retry_primary_interval` |

- 改 commit hash 會把 internal mantis 修改帶進公開 release。
- be72 與 be187 是**獨立 git repo**，hash 不通用。
- `clean_p_mtk_wl_radius()` 對 be187 改用 sed：因為 v8.2.1.5/wl_dbox2hostapd.sh 是從 v8.1.0.4 整個複製過來（commit 0f976a380），HEAD 史內找不到「mantis-9642 之前」的 baseline。
- 注意：上述四個函式只在 `main_test --mode full` 中呼叫（除 `clean_p_mtk_wl_radius` 在 `main_release` 也呼叫），release mode 與 quick mode 不會自動執行 freeradius/hostapd 還原。

### `clean_image_dir_variants()` 內未引用變體清單 (gpl.sh:377)

- 列表來自手動 `grep -rln "<filename>" --include="*.sh" --include="Makefile*" --include="*.make"` 確認 0 引用。
- 新增變體檔案進 image/$IMAGE_DIR/ 時，**必須先 grep 確認**是否進入目前的 UPG/TFTP 打包流程：會被消費的檔案不要加到刪除清單。
- 目前 UBI/MP 相關 helper/input 已不保留：`createImage.sh`、`mk_image.sh`、`ubi-layout.cfg*`、`uboot-env.bin`。
- 若來源 tree 先前跑過舊 packaging，`clean_image_dir_variants()` 也會額外清掉 `release/MP/`、`release/UPG/*-UBI.bin`，並從既有 `release/UPG/*-SHA256.txt` 移除 `UBI.bin` 條目。
- 反之新加進來的歷史變體要主動加入刪除清單，否則會洩漏到 GPL release。

### `patch_sensitive_values()` (gpl.sh:212)

- 清除的兩個 cloud URL（`G_DEF_CLOUD_URL`、`agi6e3leqqer1-ats.iot.ap-northeast-1.amazonaws.com`）是法務要求。**不要刪、也不要改 sed pattern**——pattern 失配會 silently 把敏感值留在 release 內。
- 注意：`patch_sensitive_values` 只在 `main_test --mode full` 中呼叫。release mode 與 quick mode **不會**清這兩個值，所以以 release mode / quick mode 處理的 tree 必須已是 clean 來源。

### `WRAPPER_RULES` / `SHC_RULES` (protect_runtime_shell_scripts.py:16, 27)

- 把 wrapper 用的腳本誤分到 SHC，會在被 `source` 時失敗（binary 無法被 source）。
- 反向（SHC 用的誤分到 wrapper）只會降低保護強度，但仍可執行。
- `mtkwifi.sh*` 與 `wl_dbox2*.sh` 是 SHC——這些被 wireless init 直接呼叫。
- `wl_define.sh*` 與 `sbin/fw_upgrade.sh` 是 WRAPPER。
- 若腳本已被 `clean_add_files()` policy 排除，就不要再留在 `SHC_RULES` / `WRAPPER_RULES`；目前 `sbin/dl_classical.sh`、`sbin/starteth_ipq6000.sh`、`sbin/usbTest.sh` 已不保留。

### `clean_p_mtk_kernel()` 內 .ko 列表 (gpl.sh:826)

- wlan_hwifi 的保留 .ko 列表來自 `MTK_WIFI_HWIFI_KO_LIST`（per-family，validate_model 內設定）。
- 列表來源：`P_MTK/$MTK_VERSION_DIR/mt_wifi7/wlan_hwifi/Makefile_1_gpl` 的 `KONAME` 變數。**漏列**會造成 boot 時 module 缺失。
- be72: `connac_if mtk_wed mt7992 mtk_pci mtk_hwifi`（mt7992.ko 取代 mt7990/7991，**不要改回**）
- be187: `connac_if mtk_wed mt7990 mt7991 mtk_pci mtk_hwifi`（mt7990.ko 與 mt7991.ko 都裝）
- 其他模組（mapfilter / mt_wifi_cmn / mt_wifi7/mt_wifi_ap / mtfwd / warp / mtqos）的 .ko 名固定，與晶片無關。
- `mtqos` 沒有 .ko 是因為 `make_tag_pkgs.make` 內 `IS_MTK_MTQIS` typo（不是 `MTQOS`），保留 LICENSE + Makefiles 即可。

### `is_expected_release_tree()` 守衛 (gpl.sh:1130)

- `clean_build_artifacts`、`write_release_readme`、`remove_root_git_metadata`、`create_release_tarball` 都靠這個守衛才不會在錯誤目錄執行 `git clean -dfxq` 或 `rm -rf .git`。**不要拿掉守衛**。

---

## 4. 快速自我驗證

| 場景 | 指令 |
|------|------|
| 改清理邏輯 | `./gpl.sh <MODEL> --mode quick` |
| 改 build 前處理（patch_sensitive_values 等） | `./gpl.sh <MODEL> --mode full` |
| 改 shell script 保護 | `./gpl.sh <MODEL> --mode quick --protect-shell-scripts` |
| 驗證 quick 產出仍可 build | `cd <GPL_DIR_NAME>/board/<BOARD_DIR> && make` |
| 檢查保護後檔案類型 | `file <path>`（WRAPPER 是 shell，SHC 是 ELF） |
| 行號漂移後重新校正 | `grep -n "^[a-z_]*()" gpl.sh` |
| 跨機種回歸（PR1 路徑通用化、PR2 model-aware 改動後） | 對 be72 三機種 + be187 全跑 quick mode |
