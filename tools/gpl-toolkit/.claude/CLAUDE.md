# GPL Release 專案

## 專案簡介

此目錄用於 ELECOM 無線 AP 韌體的 GPL 釋出流程，負責將 internal firmware source tree 整理成符合 GPL 授權要求的公開 release tarball。

## 支援機種

| MODEL | GPL_DIR_NAME | CUSTOMER_MODEL_NAME | P_MTK 版本 | Wi-Fi 晶片 |
|-------|-------------|---------------------|-----------|-----------|
| EW-7476LBS | wab-be36-s-gpl | WAB-BE36-S | mt7988-mt7992-MP3 | MT7992 |
| EW-7486LBE | wab-be36-gpl | WAB-BE36-M | mt7988-mt7992-MP3 | MT7992 |
| EW-7786LBE | wab-be72-gpl | WAB-BE72-M | mt7988-mt7992-MP3 | MT7992 |
| EW-7896LBE | wab-be187-gpl | WAB-BE187-M | v8.2.1.5 | MT7990 / MT7991 |

## 核心檔案

- `gpl.sh` — 主腳本，負責 GPL release 清理與 test workflow
- `gpl_tools/` — Python 輔助工具：
  - `strip_shell_comments.py` — 移除 shell script 註解
  - `strip_web_comments.py` — 移除 web 檔案開發者註解
  - `patch_makefiles.py` — 修補 Makefile
  - `protect_runtime_shell_scripts.py` — shell script 保護（wrapper + shc）
  - `encrypt_shell_scripts.py` — 加密工具
- `GPL_TEST_SOP.md` — 完整 SOP 文件（中文）

## 快速指令

```bash
# 完整驗證（第一次）
./gpl.sh EW-7786LBE --mode full

# 快速重跑 GPL 清理
./gpl.sh EW-7786LBE --mode quick

# 加 shell script 保護
./gpl.sh EW-7786LBE --mode quick --protect-shell-scripts

# 在既有 GPL tree 內直接整理
cd wab-be72-gpl
/path/to/gcp/gpl.sh EW-7786LBE
```

## 目錄約定（test mode）

- `<GPL_DIR_NAME>.src` — 原始來源樹（full 模式輸入）
- `<GPL_DIR_NAME>.build` — 成功 build 後的快照（quick 模式輸入）
- `<GPL_DIR_NAME>` — 每次執行 --mode 時重新建立的工作樹

## 相依工具

- 基本：`find`, `git`, `python3`, `tar`
- full mode 額外需要：`make`
- protect-shell-scripts 額外需要：`openssl`, `shc`（`sudo apt install shc`）

## Token 節費規則

**編譯輸出（`make`、`gpl.sh --mode full/quick`）是 token 成本最大來源，每次 100K-200K tokens。必須嚴格控制 output 讀取量。**

- `gpl.sh` 與 `make` 指令一律用 Bash tool 的 `run_in_background` 執行
- 完成後**只用 `tail -20` 讀取最後 20 行**確認結果，不讀完整 log
- 僅在 exit code 非 0（失敗）時，才用 `tail -100` 讀取更多 error context
- Report 分析結果直接寫入 `.md` 檔案，對話中只輸出摘要狀態，不重複報告全文

## 完整 SOP

詳見 `GPL_TEST_SOP.md`。

## 新機種上手指引（for Claude）

使用 `/gpl-new-model <MODEL>` 技能時，依下列順序分析 source tree：

1. 找 `P_MTK/` 子目錄名稱 → `MTK_VERSION_DIR`
2. 找 wifi_driver 目錄名稱（`mt7992`、`mt7990`、`mt7991` 等）→ 判斷 Wi-Fi chipset
3. 找 `boards/` 或 `target/linux/` 目錄 → `BOARD_DIR`（對比現有機種命名慣例）
4. 確認 `add_files/etc/inittab` 是否存在 → `clean_add_files()` 的 inittab mapping
5. 確認 `wifi7_add_files/wl_scripts/` 路徑結構 → `clean_wifi7_add_files()` 的 branch

修改 `gpl.sh` 時必須遵守：
- 不改 `main_release()` 的步驟順序（步驟順序編碼了相依關係）
- 新 MODEL 加入 `validate_model()` 時，同步更新所有 model branch
- 有不確定的欄位，先詢問使用者再繼續
- 修改完畢後展示 diff，等待使用者確認後再執行 build

### add_files/ 檔案使用確認規則

分析 `add_files/` 內的每個檔案時：

1. **確認是否有被使用**（被 inittab、rcS、其他 script 呼叫或 source）
2. **判斷 opmode 條件**（`tbox_env_get("opmode", buff, BUFFER_SIZE)`）：
   - 若該檔案**只在 opmode 非 0 且非 1** 時執行（如 opmode 10 的 usbtest.sh）→ 為測試用，列為移除候選
   - 若該檔案在 **opmode 0 或 1** 時執行，但**查無任何使用點** → 提示使用者確認：install 還是移除？
   - 若有明確使用且在 opmode 0/1 下執行 → 保留
3. **移除前必須先檢查 Makefile**：
   - grep repo source code，確認是否有 Makefile 引用該檔案做 install
   - 若有 → 同步修改 Makefile 移除對應 install 行，避免 `make` 失敗
   - 確認 Makefile 修改後，再移除檔案
