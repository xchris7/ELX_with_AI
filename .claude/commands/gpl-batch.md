# GPL Batch Test

對多個機種依序執行完整 GPL release 驗證流程：build → report → extract → re-make。

Usage: /gpl-batch
Usage: /gpl-batch EW-7786LBE EW-7896LBE

若未傳入 MODEL 清單，預設為 `EW-7786LBE EW-7896LBE`。

---

## 機種對照表

| MODEL | GPL_DIR_NAME | CUSTOMER_MODEL_NAME | BOARD_DIR |
| ----- | ------------ | ------------------- | --------- |
| EW-7476LBS | wab-be36-s-gpl | WAB-BE36-S | ELECOM_WAB-BE36-S_EW-7476LBS |
| EW-7486LBE | wab-be36-gpl | WAB-BE36-M | ELECOM_WAB-BE36-M_EW-7486LBE |
| EW-7786LBE | wab-be72-gpl | WAB-BE72-M | ELECOM_WAB-BE72-M_EW-7786LBE |
| EW-7896LBE | wab-be187-gpl | WAB-BE187-M | ELECOM_WAB-BE187-M_EW-7896LBE |

---

## Token 節費規則

**重要：build 與 make 的編譯輸出是 token 成本的最大來源（每次 100K-200K tokens）。必須嚴格控制 output 讀取量。**

- Build/make 指令一律用 `run_in_background` 執行
- 完成後**只用 `tail -20` 讀取最後 20 行**確認結果，不讀完整 log
- 僅在 exit code 非 0（失敗）時，才用 `tail -100` 讀取更多 error context
- Report 分析結果直接寫入 `.md` 檔案，對話中只輸出一行摘要狀態，不重複報告全文
- 如果機種數量 ≥ 3，可用 subagent 平行處理多個 report 分析（階段 2），每個 subagent 負責一個機種

---

## 執行流程

依序執行以下四個階段。每個階段內，依機種清單順序逐一執行。
全程追蹤結果，最終輸出摘要表。

### 階段 1 — Full Build

對每個 MODEL 依序執行：

```bash
cd /home/chris/ai && ./gpl.sh <MODEL> --mode full --protect-shell-scripts
```

- 使用 Bash tool 的 `run_in_background` 執行（build 耗時 20-40 分鐘）
- 等待完成後，**只用 `tail -20` 讀取 output 檔的最後 20 行**
- 檢查 exit code；記錄 tarball 檔名（`ls -lh /home/chris/ai/<CUSTOMER_MODEL_NAME>_*.tar.gz`）
- 失敗時 `tail -100` 讀取更多 error context，記錄錯誤訊息後**繼續下一個機種**

### 階段 2 — 產生分析報告

對每個**階段 1 成功**的機種，執行 GPL release report 分析。

分析目標為 gpl.sh 清理後的 work tree `<GPL_DIR_NAME>/`（非 .src 也非 .build）。

依照 `/gpl-report` 的報告章節規範，對 work tree 執行完整分析並將報告寫入：

```text
/home/chris/ai/<GPL_DIR_NAME>_GPL_RELEASE_REPORT.md
```

報告章節：

1. Open Source License 清單
2. Binary / Library 型態 Release 清單
3. GPL 感染性分析
4. GPL Compliance 待商榷項目
5. 內部人員修改分析（5-A 修改內容與競爭力評估 + 5-B 敏感資料偵測）
6. 敏感性資料掃描

完成後在對話中只輸出一行：`✅ <MODEL> report written to <path>` 或 `❌ <MODEL> report failed: <reason>`。

### 階段 3 — 解壓 tarball

```bash
rm -rf /home/chris/ai/gpl_verify
mkdir -p /home/chris/ai/gpl_verify
```

對每個機種的 tarball：

```bash
tar -C /home/chris/ai/gpl_verify -xzf /home/chris/ai/<CUSTOMER_MODEL_NAME>_*.tar.gz
```

### 階段 4 — 重新 make 驗證

進入解壓後的目錄，重新 make 確認可生成 firmware：

```bash
cd /home/chris/ai/gpl_verify/<GPL_DIR_NAME>/board/<BOARD_DIR> && make
```

- 使用 Bash tool 的 `run_in_background` 執行
- 完成後**只用 `tail -20` 讀取 output 檔的最後 20 行**
- 確認 firmware image 存在：

```bash
ls /home/chris/ai/gpl_verify/<GPL_DIR_NAME>/image/<MODEL>/release/UPG/*.bin
```

---

## 最終輸出

所有階段完成後，輸出摘要表：

```text
| 機種 | Build | Tarball | Report | Extract | Re-make | Firmware |
|------|-------|---------|--------|---------|---------|----------|
| <MODEL> | ✅/❌ | 檔名 (大小) | ✅/❌ | ✅/❌ | ✅/❌ | ✅ path / ❌ error |
```

若有任何階段失敗，在摘要表後列出失敗的錯誤訊息摘要。
