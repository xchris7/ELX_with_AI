# Contributing to gpl-toolkit

開發者指引：新增機種、修改清理規則、新增受保護的 shell script。

詳細函式索引與決策樹請見 [gpl_tools/REFERENCE_MAP.md](gpl_tools/REFERENCE_MAP.md)。  
完整 SOP 請見 [GPL_TEST_SOP.md](GPL_TEST_SOP.md)。

---

## 新增機種

1. **`gpl.sh` — `validate_model()`**（per-model case）  
   定義：`BOARD_DIR` / `IMAGE_DIR` / `GPL_DIR_NAME` / `CUSTOMER_MODEL_NAME`

2. **`gpl.sh` — `validate_model()`**（family-level case）  
   加入既有 family，或開新 family 並定義：  
   `MTK_VERSION_DIR` / `MTK_WIFI_HWIFI_KO_LIST` / `FREERADIUS_RESTORE_REF` /  
   `HOSTAPD_RADIUS_CLIENT_RESTORE_REF` / `HOSTAPD_SESSION_TIMEOUT_RESTORE_REF` /  
   `WL_DBOX2HOSTAPD_REVERT_METHOD`

3. **`gpl.sh` — `clean_add_files()`**  
   新增 `keep_inittab` mapping（依 platform 選 `inittab_ttyS0_*` 變體）

4. **`gpl.sh` — `clean_wifi7_add_files()`**  
   加入 family case 或在既有 inner case 新增分支

5. **準備來源樹**  
   在工具組同層目錄準備 `<NEW_GPL_DIR_NAME>.src`

6. **驗證**
   ```bash
   ./gpl.sh <NEW_MODEL> --mode full
   ```

---

## 新增受保護的 shell script

在 `add_files/` 或 `wifi7_add_files/wl_scripts/` 新增腳本時：

**問：此腳本會被其他腳本 `source` 或 `.` 引用嗎？**

- **YES** → `WRAPPER_RULES`（自解密 shell wrapper）  
  編輯 `gpl_tools/protect_runtime_shell_scripts.py`，加入對應 rules dict

- **NO**（直接 exec）→ `SHC_RULES`（編譯為 target ELF binary）  
  同上，加入 `SHC_RULES`

同時確認腳本在 `clean_add_files()` 的 `keep_sbin_files=()` 白名單內，否則 step 7 就會被刪除。

驗證：
```bash
./gpl.sh EW-7786LBE --mode quick --protect-shell-scripts
file <輸出檔>   # WRAPPER → shell；SHC → ELF
```

---

## 修改清理規則

### 一般原則

- `main_release()` 的 **27 步順序不可重排**，步驟順序編碼了相依關係
- 修改影響 build 的部分（`prepare_source_for_build`、`patch_sensitive_values`）需跑 `--mode full`
- 其他修改用 `--mode quick` 即可驗證

### P_ELX 元件

移除元件 → 加入 `p_elx_remove_folders=()` 並清掉 `patch_makefiles.py` 內對應 install 引用  
新增 binary-only 元件 → 加入 `p_elx_folders=()` 並在 `case $folder` 列出 `keep_files`

### `.ko` 列表

`MTK_WIFI_HWIFI_KO_LIST` 來源為：  
`P_MTK/$MTK_VERSION_DIR/mt_wifi7/wlan_hwifi/Makefile_1_gpl` 的 `KONAME` 變數  
漏列會導致裝置 boot 時 module 缺失。

---

## 不可修改的項目

| 項目 | 原因 |
|------|------|
| `main_release()` 步驟順序 | 步驟間有嚴格相依關係 |
| `patch_sensitive_values()` 的 sed pattern | 失配會 silently 洩漏敏感 cloud URL |
| `save_status()` 的 `binary_only_dirs[]` | 動到會把 internal source 洩漏進 release |
| `is_expected_release_tree()` 守衛 | 防止在錯誤目錄執行 `git clean -dfxq` 或 `rm -rf .git` |
| per-model git commit hash（restore ref） | 改 hash 會把 internal patch 帶進公開 release |

詳見 [gpl_tools/REFERENCE_MAP.md § 3「不要碰」清單](gpl_tools/REFERENCE_MAP.md)。
