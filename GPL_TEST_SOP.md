# gpl.sh 測試與釋出 SOP

本文件整合原 `GPL_TEST_SOP.md`、`GPL_TEST_CUSTOMER_ONE_PAGE.md`、`GPL_SCRIPT_OVERVIEW_ZH.md`，改以 `gpl.sh` 為唯一說明來源。

## 1. 腳本定位

`gpl.sh` 現在同時負責：

1. GPL release 清理流程
2. GPL 測試工作樹重建與驗證流程

舊的 `gpl_test.sh` 仍在 repo 中，但目前應以 `gpl.sh` 為主入口。

## 2. 支援機種

| MODEL | BOARD_DIR | IMAGE_DIR | GPL_DIR_NAME | CUSTOMER_MODEL_NAME | P_MTK | Wi-Fi |
| --- | --- | --- | --- | --- | --- | --- |
| `EW-7476LBS` | `ELECOM_WAB-BE36-S_EW-7476LBS` | `EW-7476LBS` | `wab-be36s-gpl` | `WAB-BE36-S` | `mt7988-mt7992-MP3` | MT7992 |
| `EW-7486LBE` | `ELECOM_WAB-BE36-M_EW-7486LBE` | `EW-7486LBE` | `wab-be36-gpl` | `WAB-BE36-M` | `mt7988-mt7992-MP3` | MT7992 |
| `EW-7786LBE` | `ELECOM_WAB-BE72-M_EW-7786LBE` | `EW-7786LBE` | `wab-be72-gpl` | `WAB-BE72-M` | `mt7988-mt7992-MP3` | MT7992 |
| `EW-7896LBE` | `ELECOM_WAB-BE187-M_EW-7896LBE` | `EW-7896LBE` | `wab-be187-gpl` | `WAB-BE187-M` | `v8.2.1.5` | MT7990 / MT7991 |

## 3. 兩種執行方式

另外，`gpl.sh` 目前支援一個可選參數：

- `--protect-shell-scripts`
   針對 `add_files/` 與 `P_MTK/mt7988-mt7992-MP3/wifi7_add_files/wl_scripts/` 內的 shell script，套用「wrapper + shc」混合保護。
   被 `source` 的 library script 會保留為自解密 wrapper；可直接執行的腳本會優先轉成 target binary。
   目的是提高閱讀與直接抄用 source 的門檻。
   這不是強安全邊界；因為裝置端仍需能解密執行，具備分析能力的對手仍可還原邏輯。
   `shc` 本身只安裝在建置機，不會被安裝到 device 上。

### 3.1 建置機先安裝 `shc`

目前這台建置機是 Ubuntu 25.04，官方套件源已有 `shc`，建議直接安裝：

```bash
sudo apt update
sudo apt install -y shc

# 驗證
command -v shc
apt-cache policy shc
```

若未來換到沒有 `shc` 套件的 Linux 建置機，再使用 upstream source build：

```bash
sudo apt install -y build-essential autoconf automake
git clone https://github.com/neurobin/shc.git
cd shc
./configure
make
sudo make install

# 若 make 遇到 autotools 版本問題
./autogen.sh
./configure
make
sudo make install
```

補充：

- `shc` upstream: `https://github.com/neurobin/shc`
- `gpl.sh` 在保護模式下除了 `shc` 以外，還需要 host 端 `openssl`
- `gpl.sh` 會自動找 target cross-compiler 與 target strip；若找不到，可手動指定 `GPL_SHC_CC=/path/to/target-gcc` 與 `GPL_SHC_STRIP=/path/to/target-strip`

### 3.2 `shc` 與 device 相容性的實際做法

目前已驗證的做法如下：

1. 建置機安裝的是 host 版 `shc`
2. `shc` 在建置機上把 shell script 轉成 C stub
3. `gpl.sh` 會自動從 `wab-be72-gpl.build/toolchain/.../bin/` 找出 target gcc
4. `gpl.sh` 也會自動找出對應的 target `strip`
5. `shc` 產生的 C stub 不是用 host gcc 編，而是用 target gcc 編成給 device 的 ELF
6. 產物再經過 target `strip`，減少符號與 debug 資訊暴露

也就是說：

- `shc` 不需要存在於 device 上
- device 上真正執行的是建置階段產出的 target binary
- 對於 wrapper 類腳本，device 端仍需要 `openssl`
- 對於 `shc` 類腳本，device 端仍需要原 shebang 指向的 shell，例如 `/bin/sh`
- `shc` 4.0.x 預設 `BUSYBOXON=0`，此時 `argv[0]` 會是腳本名稱（如 `automount.sh`），BusyBox 會把它當作 applet 名稱查不到而噴 `applet not found`。`gpl.sh` 的保護工具透過 CC wrapper script 在 compile 前把 `.x.c` 內的 `#define BUSYBOXON 0` patch 成 `1`，讓 binary 改用 `execvp("/bin/sh", ["busybox", "sh", ...])`

### 3.1 Release mode

在「要被整理的 GPL source tree 根目錄」執行 `gpl.sh`，腳本會直接對目前目錄做 GPL 清理：

```bash
cd /path/to/wab-be72-gpl
/path/to/gcp/gpl.sh EW-7786LBE
```

重點：

- `SOURCE_PATH` 會取目前工作目錄 `pwd`
- `gpl_tools/` 會從 `gpl.sh` 所在目錄尋找
- 目前目錄必須仍是可用的 git working tree，因為流程會執行 `git checkout`、`git add`、`git clean`
- 這個模式不會重建工作樹，也不會先做原始韌體 build

### 3.2 Test mode

在 repo root 執行 `gpl.sh <MODEL> --mode full|quick`，腳本會先重建工作樹，再跑同一套 GPL 清理流程：

```bash
cd /path/to/gcp
./gpl.sh EW-7786LBE --mode full
./gpl.sh EW-7786LBE --mode quick
./gpl.sh EW-7786LBE --mode quick --protect-shell-scripts
```

重點：

- 參數順序固定為 `./gpl.sh <MODEL> --mode <full|quick>`
- `full` 使用 `<GPL_DIR_NAME>.src`
- `quick` 使用 `<GPL_DIR_NAME>.build`
- 目標工作樹永遠是 `<GPL_DIR_NAME>`

## 4. Repo 目錄約定

Test mode 依賴下列目錄命名：

- `<GPL_DIR_NAME>.src`
  - 原始來源樹
  - 尚未做 GPL 清理
  - `full` 模式的輸入
- `<GPL_DIR_NAME>.build`
  - 已成功 build 過的來源樹快照
  - `quick` 模式的輸入
- `<GPL_DIR_NAME>`
  - 每次執行 `--mode` 時重新建立的工作樹

以 `EW-7786LBE` 為例：

- `wab-be72-gpl.src`
- `wab-be72-gpl.build`
- `wab-be72-gpl`

## 5. `--mode full` 流程

`./gpl.sh <MODEL> --mode full` 的實際步驟如下：

1. 將 `<GPL_DIR_NAME>.src` 複製成 `<GPL_DIR_NAME>`
2. 清掉敏感雲端值
   - `P_ELX/dbox2/nodes/dbox_nodes_cloud.c`
   - `P_ELX/elecom_cloud_apps/admlink/admlink_main.c`
3. 在 build 前還原指定 GPL 套件內容（per-MODEL anchor，由 `validate_model()` 設定）
   - `P_GPL/freeradius-server-3.0.27/` 還原到 `$FREERADIUS_RESTORE_REF`
     - be72 family: `5ff6024ef`
     - be187: `553cbfff5^`
   - `hostapd` radius_client.c 還原到 `$HOSTAPD_RADIUS_CLIENT_RESTORE_REF`
     - be72 family: `ce7a22c69^`（mantis-9642）
     - be187: `67e39f24d^`（mantis-9642）
   - `hostapd` ap/eapol_auth_sm 群組還原到 `$HOSTAPD_SESSION_TIMEOUT_RESTORE_REF`
     - be72 family: `954db32f2^`（mantis-11774）
     - be187: `47132c77c^`（mantis-11774）
4. 移除 `P_MIT/dropbear-2022.83`，並同步清掉 `board_cfg/make_tag/make_tag_pkgs.make` 內對應項目
5. 進入 `board/$BOARD_DIR` 執行 `make`
6. 驗證：
   - `staging/${MODEL}_uImage`
   - `staging/${MODEL}-FW-*.bin`
7. 將成功 build 的 `<GPL_DIR_NAME>` 複製成 `<GPL_DIR_NAME>.build`
8. 接著執行 release 清理流程 `main_release()`

用途：

- 第一次建立可驗證的 GPL 工作樹
- 建出後續 `quick` 模式要重複使用的 `.build` 快照

## 6. `--mode quick` 流程

`./gpl.sh <MODEL> --mode quick` 的實際步驟如下：

1. 將 `<GPL_DIR_NAME>.build` 複製成 `<GPL_DIR_NAME>`
2. 直接執行 release 清理流程 `main_release()`

若要在 `quick` mode 驗證 shell script 保護，仍必須明確加上 `--protect-shell-scripts`。
只跑 `./gpl.sh <MODEL> --mode quick` 不會自動啟用保護。

`quick` 會跳過：

- 敏感值清理
- build 前的 source 還原
- `dropbear` 移除
- 韌體 build 與 image 驗證

用途：

- 在已有 `.build` 快照的前提下快速重跑 GPL 清理
- 驗證 `gpl.sh` / `gpl_tools/` 修改後的結果
- 驗證 `--protect-shell-scripts` 的輸出結果

前提：

- `.build` 必須先由一次成功的 `--mode full` 產生
- 如果你修改了會影響 build 前工作樹內容的邏輯，例如敏感值清理、`restore_freeradius_release_version()`、`revert_hostapd_internal_radius_patches()`、`remove_dropbear_package()`，應重新執行一次 `--mode full` 來刷新 `.build`

## 7. Release 清理流程 `main_release()`

不論是 release mode、`--mode full`、或 `--mode quick`，最後都會進到 `main_release()`。依 `gpl.sh` 實際執行順序：

1. 驗證必要路徑存在：`add_files`、`board`、`board_cfg`、`P_ELX`、`P_FREE`、`P_MTK`
2. 清理 root：刪除 `DEFINE`、`YML`、`scripts`、root `README.md`、`.gitlab-ci.yml`
3. 清理 `board_cfg`：從 `make_feeds.conf` 移除 `src-` feed；只保留目前 toolchain 對應的 `make_tag_lib_*`
4. 只保留目標機種需要的 `board/` 目錄
5. 刪除 `board_include` 與 `board/$BOARD_DIR/include`
6. 清理 `add_files/`：只保留腳本中列出的 `etc/`、`etc/sysctl.d/`、`sbin/` 檔案；依機種保留對應的 `inittab`
   - 目前 GPL release policy 不保留 `sbin/dl_classical.sh`、`sbin/starteth_ipq6000.sh`、`sbin/usbTest.sh`
   - 對應 board `Makefile` / `Makefile_1_gpl` 的 install line 由後續 `patch_makefiles.py` 一併移除
7. 去除 `add_files/` shell script 註解
8. 清理 `P_ELX`：只保留指定元件的 binary / library / `Makefile_*`；移除 `fwConfig`，且 `P_ELX/elecom_cloud_apps/` 不再保留 `config_manager/`、`json2dbox`、`dbox2json`
9. 移除 `P_ELX/web/web_elecom/usb_disp.html`；去除 `P_ELX/web` 內 web 檔案的開發者註解
10. 清理 `P_BSD/nginx-1.24.x`：只保留 `LICENSE`、`Makefile_*`、`.build/` 下預編譯檔案
11. 清理 `P_FREE/net-snmp-5.9.x`：只保留 `COPYING`、`Makefile_*`、預編譯 `.so`、`snmpd`、`snmptrap`
12. 只保留目標機種需要的 `image/` 目錄
13. 清理 `image/$IMAGE_DIR/` 內不再用於 UPG/TFTP 的 image helper / input、舊版 UBI/MP 殘留產物，以及未引用的歷史日期變體檔案（per-MODEL hardcode 清單）：
   - 共用移除：`createImage.sh`、`mk_image.sh`、`ubi-layout.cfg`、`ubi-layout.cfg.d4`、`uboot-env.bin`
   - 舊版產物清理：`release/MP/`、`release/UPG/*-UBI.bin`，以及既有 `release/UPG/*-SHA256.txt` 內的 `UBI.bin` hash line
    - EW-7896LBE: `20240801_MT7990_iPAiLNA_EEPROM_TELEC_v4.bin`、`bl2-187m.img`、`bl2-20240702.img`、`fip-187m.bin`、`fip-20240702.bin`
    - EW-7786LBE: `EW-7786LBE_20240807.bin`、`EW-7786LBE_20250109.bin`
    - EW-7486LBE: `EW-7486LBE_20240807.bin`、`EW-7486LBE_20250110.bin`
    - EW-7476LBS: `MT7991B_MT7976C_BE3600_iPAiLNA_*.bin` 三個歷史版本
14. 產物只保留 `release/UPG/` 下的 `*-UPG.bin`、`*-TFTP.bin`、`*-SHA256.txt`；不再產生 `*-UBI.bin` 與 `release/MP/`
15. 清理 `P_MTK` standalone：`ated_ext`、`mii_mgr`、`mwctl` 只保留 binary + `LICENSE` + `Makefile_*`；移除 `sigma_daemon`、`sigma_dut`
16. 清理 `P_MTK` kernel：依 `MTK_VERSION_DIR`（`mt7988-mt7992-MP3` 或 `v8.2.1.5`）找版本目錄，依 `MTK_WIFI_HWIFI_KO_LIST` 保留對應 `.ko`、`LICENSE`、`Makefile_*`；`wifi7_add_files` 完整保留待下一步處理
17. 清理 `wifi7_add_files`：family-aware 移除未安裝的 alternate EEPROM 檔案、`sigma_test/`、以及非本機種的 `dat` 與 `wl_scripts` 檔案
18. 將 `wl_dbox2hostapd.sh` 還原成 pre-mantis-9642 狀態（移除 RADIUS retry interval patch）
    - be72 family: `git checkout ce7a22c69^ -- ...`
    - be187: 因 v8.2.1.5 是從 v8.1.0.4 整個複製過來（commit `0f976a380`），HEAD 史內找不到 mantis-9642 之前的 baseline；改用 `sed` 把 `w_conf radius_retry_primary_interval=3600` 換回註解形式
19. 去除 `P_MTK/.../wifi7_add_files/wl_scripts` shell script 註解
20. 若指定 `--protect-shell-scripts`：
    - `wl_define.sh*`、`fw_upgrade.sh` → 自解密 wrapper（保留 shell 呼叫相容性）
    - `mtkwifi.sh*`、`wl_dbox2*.sh`、`automount.sh`、`guest_network*.sh` 等 direct-exec 腳本 → `shc` target binary
    - binary 以 `BUSYBOXON=1` 編譯，device 端 `/bin/sh`（BusyBox）呼叫正確
    - wrapper 執行時需要 target rootfs 的 `openssl`
   - 已在 step 6 移除的 `dl_classical.sh`、`starteth_ipq6000.sh`、`usbTest.sh` 不再進入保護清單
21. 執行 `gpl_tools/patch_makefiles.py`；這一步會在 GPL 工作樹內 rewrite `board_cfg/make_tag/*.make` 的 release-output 規則與 board install line，也會移除像 `P_ELX/elecom_cloud_apps/config_manager/`、`json2dbox`、`dbox2json` 這類已由 GPL policy 清掉的 Makefile 殘留參照；像 `UBI.bin` / `release/MP` 這類 repo source code 政策修正，應落在 `gpl.sh` 與相關 tooling（例如 `patch_makefiles.py`），讓 GPL 流程可重現套用
22. 以 git 整理最終狀態（`save_status`）：還原 source-shipping package 的 build 產物、`git add -u`、強制加入 binary-only 目錄
23. 執行 `git clean -dfxq` 清理 build artifact
24. 重新產生 root `README.md`
25. 移除 `.git`、`.gitignore`、`.gitattributes`、`.gitmodules`
26. 建立 release tarball：`<CUSTOMER_MODEL_NAME>_<version>_<date>.tar.gz`

目前已實測代表檔案如下（`--protect-shell-scripts`）：

- `add_files/sbin/automount.sh` → `ELF 64-bit LSB executable, ARM aarch64, stripped`
- `P_MTK/.../wl_scripts/mtkwifi.sh.BE7200` → `ELF 64-bit LSB executable, ARM aarch64, stripped`
- `add_files/sbin/fw_upgrade.sh` → 保持 shell wrapper
- `P_MTK/.../wl_scripts/wl_define.sh.BE7200` → 保持 shell wrapper

## 8. Script 保護策略

目前可行做法大致有三類：

1. 只移除註解與格式
   - 成本最低
   - 幾乎只能防止隨手閱讀，保護力弱
2. 自解密 shell wrapper
   - 適合需要被 `source` 的腳本，例如 `wl_define.sh*`
   - 交付內容仍是 shell script，但實際邏輯會以加密 payload 形式嵌入，執行時再用 `openssl` 解開
   - 優點是相容既有 shell 呼叫方式
   - 缺點是 key 與解密流程仍在裝置端，屬於混淆，不是不可逆保護
3. 改寫為 native binary（`shc`）
   - 保護力最高
   - 適合可直接執行、且不需要被 `source` 或 `sh script.sh` 呼叫的腳本
   - 需要 host 端 `shc`、target cross-compiler、target `strip`
   - 以 `BUSYBOXON=1` 編譯，確保在 BusyBox 環境下 `execvp` 時 `argv[0]` 是 `busybox` 而非腳本名稱
   - 開發、除錯、維護與跨平台移植成本也最高

目前 repo 已實作的是第 2 類與第 3 類的混合方案：能保留 shell 相依性的腳本走 wrapper，直接執行型腳本走 `shc`。這樣可在相容性與保護強度之間取平衡。

## 9. 目前沒有自動做的事

`main_release()` 已包含完整的釋出流程（步驟 1–25），但下列三個函式只在 `main_test --mode full` 中被呼叫，不屬於 `main_release()` 本身：

- `restore_freeradius_release_version()`
- `revert_hostapd_internal_radius_patches()`
- `remove_dropbear_package()`

因此當你以 release mode（在既有 GPL tree 根目錄直接執行 `gpl.sh`）或 `--mode quick` 執行時，這三項操作不會被執行。若 tree 內容尚未處理這些，應先跑一次 `--mode full`。

## 10. 常用指令

```bash
# 1. 第一次完整驗證，並建立 .build 快照
./gpl.sh EW-7786LBE --mode full
./gpl.sh EW-7896LBE --mode full

# 2. 後續快速重跑 GPL 清理
./gpl.sh EW-7786LBE --mode quick
./gpl.sh EW-7896LBE --mode quick

# 3. 以 quick mode 重跑，並啟用 shell script 保護
./gpl.sh EW-7786LBE --mode quick --protect-shell-scripts
./gpl.sh EW-7896LBE --mode quick --protect-shell-scripts

# 4. 若要驗證 quick mode 產出的 tree 仍可做 FW，再進 board 目錄手動 make
cd wab-be72-gpl/board/ELECOM_WAB-BE72-M_EW-7786LBE
make
# be187:
cd wab-be187-gpl/board/ELECOM_WAB-BE187-M_EW-7896LBE
make

# 5. 直接在既有 GPL tree 內做 release 清理
cd wab-be72-gpl
/path/to/gcp/gpl.sh EW-7786LBE
# be187:
cd wab-be187-gpl
/path/to/gcp/gpl.sh EW-7896LBE
```

說明：

- `--mode quick` 本身不會自動執行 `make`
- 若要驗證加上 `--protect-shell-scripts` 之後仍能產出 FW，應先跑 `quick`，再在產出的 `board/$BOARD_DIR` 下手動 `make`

## 11. 常見錯誤

### `missing required path`

表示缺少必要輸入樹、工具或 source 目錄。先檢查：

```bash
ls -d wab-be*-gpl*
ls gpl.sh
ls gpl_tools
```

### `current directory is inside <GPL_DIR_NAME>`

表示你人在將被 `rm -rf` 重建的目標目錄內。請先切回 repo root 或其他目錄再執行。

### `FW image not found under <target>/staging`

表示 `--mode full` 的原始韌體 build 沒有產出預期檔案。請檢查：

```bash
cd <GPL_DIR_NAME>/board/<BOARD_DIR>
make
ls ../../staging
```

### `missing required command`

腳本至少需要：

- release mode: `find`、`git`、`python3`、`tar`
- `--mode full`: 額外需要 `make`
- `--protect-shell-scripts`: 額外需要 host 端 `openssl`、`shc`

若建置機是 Ubuntu 25.04，可直接安裝：

```bash
sudo apt update
sudo apt install -y shc
```

若錯誤是找不到 target compiler，可手動指定：

```bash
export GPL_SHC_CC=/path/to/aarch64-openwrt-linux-musl-gcc
export GPL_SHC_STRIP=/path/to/aarch64-openwrt-linux-musl-strip
```

### `missing root .git before git clean`

表示你是在沒有 git metadata 的目錄執行 release mode。`gpl.sh` 目前仍依賴 git 來還原 package 狀態與清理 build artifact，因此應在仍保有 `.git` 的工作樹內執行，而不是在最終交付 tarball 解開後的目錄執行。

### 目標機執行 shell wrapper 失敗

如果保護後的 shell script 在 target 上無法執行，先檢查：

- target rootfs 是否有 `openssl`
- `openssl` 是否位於 wrapper 會搜尋的位置，例如 `/usr/bin/openssl`、`/apps/bin/openssl`、`/bin/openssl`、`/sbin/openssl`
- 被保護腳本原本是否依賴非 POSIX 的 shell 行為；目前 wrapper 保留原 shebang，但仍建議優先使用 `/bin/sh` 或 `/bin/bash`

## 12. 建議使用方式

- 第一次驗證時使用 `--mode full`
- `full` 成功後，再用 `--mode quick` 驗證後續腳本調整
- 若本次要驗證 shell script 保護，直接使用 `--mode quick --protect-shell-scripts`
- 若要直接整理既有 GPL tree，請在該 tree 根目錄執行 release mode
- 雖然腳本在完全沒有參數時會預設 `EW-7786LBE`，實務上仍建議明確傳入 `MODEL`
