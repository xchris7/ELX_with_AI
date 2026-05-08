---
name: gpl-new-model
description: Onboard a new ELECOM AP hardware model for GPL release support. Analyzes source tree, modifies gpl.sh and CLAUDE.md, shows diff before executing any build. Use when adding GPL support for a model not yet in gpl.sh validate_model().
argument-hint: MODEL
disable-model-invocation: true
---

# GPL New Model Onboarding

為新機種建立完整的 GPL release 支援。Claude 自主分析 source tree、修改 gpl.sh 與 CLAUDE.md，展示 diff 給使用者確認後再執行驗證。

Usage: /new-model MODEL

前提：`<GPL_DIR_NAME>.src/` 已放置於本目錄下。

## 執行步驟

1. **讀取現有文件**
   - 閱讀 `.claude/CLAUDE.md`（機種表與上手指引）
   - 閱讀 `gpl.sh` 開頭的 `FOR AI ASSISTANTS` 段落
   - 閱讀 `GPL_TEST_SOP.md`
   - 若存在，閱讀 `gpl_tools/REFERENCE_MAP.md`

2. **推斷 GPL_DIR_NAME**
   從 MODEL 名稱對照現有命名慣例（如 EW-7786LBE → wab-be72-gpl），
   或詢問使用者確認。

3. **分析 source tree**
   探索 `<GPL_DIR_NAME>.src/` 目錄，推斷：
   - `MTK_VERSION_DIR`：`P_MTK/` 下的子目錄名稱（如 `mt7988-mt7992-MP3`、`v8.2.1.5`）
   - Wi-Fi chipset：wifi_driver 目錄名或 `mt7992`/`mt7990`/`mt7991` 等關鍵字
   - `BOARD_DIR`：對比現有機種在 boards/ 或 target/linux/ 的目錄名稱
   - `IMAGE_DIR`：韌體輸出目錄（通常與 MODEL 名稱相關）
   - `add_files/etc/inittab` 是否存在 → 決定 clean_add_files() mapping
   - `wifi7_add_files/wl_scripts/` 路徑結構

4. **對比現有機種**
   對照 `gpl.sh` 內現有 MODEL branch，確認每個變數的對應關係與差異。
   若有不確定的欄位，詢問使用者再繼續。

5. **審查 add_files/ 檔案使用狀況**
   針對 `add_files/` 內每個檔案：
   - 確認是否被 inittab、rcS 或其他 script 呼叫/source
   - 確認 opmode 條件（`tbox_env_get("opmode", ...)`）：
     - 只在 opmode 非 0 且非 1 時執行（如 opmode 10）→ 測試用，列為移除候選
     - 在 opmode 0 或 1 時執行但無任何使用點 → 提示使用者確認：install 或移除？
   - **移除前**：grep repo source code 確認 Makefile 是否有 install 該檔案；
     若有 → 同步修改 Makefile，防止 `make` 失敗

6. **修改檔案**
   - `gpl.sh`：
     - `validate_model()`：加入新 MODEL 與所有對應變數
     - `clean_add_files()`：加入 inittab mapping，含移除測試用檔案的邏輯
     - `clean_wifi7_add_files()` 或對應 Wi-Fi clean 函式：加入新 model branch
     - 若有新 P_MTK 版本：更新相關路徑對應
   - `.claude/CLAUDE.md`：機種表加一行

7. **展示 diff，等待確認**
   列出所有變更內容，**不執行任何 build**，等待使用者明確確認。

8. **使用者確認後執行驗證**

   遵守 CLAUDE.md「Token 節費規則」— 用 `run_in_background` 執行，完成後只 `tail -20` 確認結果。

   ```bash
   ./gpl.sh $MODEL --mode full
   ```
