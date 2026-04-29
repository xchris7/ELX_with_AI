# GPL Release Report

在 gpl.sh 執行完成後，對清理後的 GPL work tree 進行全面分析，產出結構化報告。

Usage: /gpl-report MODEL

前提：`<GPL_DIR_NAME>/`（work tree）已由 `/gpl-full` 或 `/gpl-quick` 產生完畢。

---

## 分析目標目錄

`<GPL_DIR_NAME>/` — gpl.sh 清理後的 work tree（非 .src 也非 .build）

---

## 報告章節

### 1. Open Source License 清單

掃描 work tree 內所有 LICENSE、COPYING、NOTICE、*.md 授權文件，以及原始碼 SPDX 標頭。

輸出格式：
```
| License 類型 | 數量 | 所在目錄/套件 |
|-------------|------|--------------|
| GPL-2.0     | N    | P_KNL/, ...  |
| MIT         | N    | P_FREE/..., P_MIT/... |
| BSD-2-Clause| N    | ...          |
| ...         |      |              |
```

---

### 2. Binary / Library 型態 Release 清單

列出以 binary 或 library 型態釋出（而非 source）的元件。
參考 gpl.sh 的 `clean_p_elx()`、`p_elx_folders[]` 設定，確認哪些元件只保留 binary。

輸出格式：
```
| 元件/目錄   | Release 型態 | 說明        |
|------------|-------------|-------------|
| P_ELX/cli  | binary only | cli ELF     |
| P_ELX/dbox2| binary only | dbox_init, libdbox.a, libdbox.so |
| ...        |             |             |
```

---

### 3. GPL 感染性分析

根據第 1 節的授權分佈，分析 GPL copyleft 是否可能擴散至其他元件。

重點判斷：
- GPL / LGPL 元件是否與 proprietary 元件靜態連結？
- Kernel module（.ko）是否使用 GPL-incompatible 授權？
- P_ELX binary 與 GPL library 的連結方式？

輸出格式：
```
風險等級: 高 / 中 / 低 / 無

| 風險項目                    | 說明                  | 建議處理 |
|----------------------------|-----------------------|---------|
| ...                        |                       |         |
```

---

### 4. GPL Compliance 待商榷項目

列出可能不符合 GPL 釋出要求、或需進一步確認的事項。

檢查項目包含：
- 有無 Corresponding Source（對應原始碼）缺漏？
- 有無 Installation Information（安裝資訊）不完整？
- binary-only 元件是否有 GPL 感染疑慮未解？
- 釋出的 source 是否與 build 的 binary 版本一致？

輸出格式：
```
| 項目         | 狀態       | 說明/建議       |
|-------------|-----------|-----------------|
| ...         | 需確認 / OK|                 |
```

---

### 5. 內部人員修改分析（P_MIT / P_GPL / P_FREE / P_KNL / P_BSP）

對各 P_* 目錄執行 git log / git diff 分析，找出相對於上游 release tag 的本地修改。分成兩個子節輸出。

步驟：
1. 找出各子套件的上游版本號（從 Makefile 或 `version` 欄位）
2. 用 `git log` 或 `git diff` 找出本地 commit / 修改
3. 對每個修改：先判斷是否引入敏感資料（見 5-B），再評估競爭力影響（見 5-A）

---

#### 5-A. 修改內容與競爭力評估

列出各套件的本地修改，判斷是否可對外公開。

放行判斷標準：

- **可放行**：純功能修補（bug fix、相容性調整），不涉及 ELECOM 核心業務邏輯
- **不可放行**：修改讓 ELECOM 取得競爭優勢（獨家演算法、商業秘密、未公開 feature），或內含敏感資料

輸出格式：

```text
| 目錄/套件       | 修改檔案數 | 代表修改內容         | 競爭力影響 | 可否放行   |
|----------------|----------|----------------------|-----------|----------|
| P_KNL/linux    | N        | drivers/net/xxx.c    | 低        | ✅ 可放行  |
| P_GPL/hostapd  | N        | src/ap/radius.c      | 中        | ⚠️ 需確認  |
| P_BSP/xxx      | N        | config/xxx.h         | 高        | ❌ 不可放行 |
| ...            |          |                      |           |           |
```

競爭力影響等級：

- **低**：純 bug fix 或相容性調整，對應上游已知問題
- **中**：功能擴充，但屬通用技術範疇
- **高**：涉及 ELECOM 獨家邏輯、商業策略、或未公開 feature flag

---

#### 5-B. 修改中的敏感資料偵測

⚠️ **本節若有任何標記為「需移除」的項目，必須在發布前處理完畢。**

針對所有本地修改的檔案，掃描是否新增了敏感資料：

- 硬編碼 IP、domain、URL（非公開測試用）
- 帳號、密碼、API key、token
- 內部 server 位址、VPN endpoint
- 憑證、私鑰
- ELECOM 內部路徑或 build server 資訊

輸出格式：

```text
| 檔案路徑                   | 敏感資料類型       | 建議處理            |
|--------------------------|-------------------|---------------------|
| P_GPL/xxx/config.h       | 硬編碼內部 URL     | ⚠️ 移除或替換為佔位符 |
| P_KNL/xxx/driver.c       | 無                | ✅ OK               |
| ...                      |                   |                     |
```

如本節全部為 OK，輸出一行：`✅ 未偵測到敏感資料新增`

---

### 6. 敏感性資料掃描

掃描 work tree 所有目錄，尋找敏感資料跡象。

掃描對象：
- 硬編碼 IP address、domain、URL（非 localhost / example.com）
- 帳號、密碼、API key 關鍵字（`password`, `passwd`, `secret`, `token`, `apikey`）
- 內部 server hostname、VPN 位址
- 憑證、私鑰（`BEGIN PRIVATE KEY`、`BEGIN CERTIFICATE`）
- ELECOM 內部工具路徑或 build server 路徑

輸出格式：

```text
| 資料夾/檔案路徑              | 敏感內容類型       | 建議處理            |
|---------------------------|--------------------|---------------------|
| P_ELX/config/default.conf | 硬編碼 cloud URL   | 清除或替換為佔位符   |
| add_files/etc/init.d/xxx  | 內部 IP 位址       | 移除或 patch        |
| ...                       |                    |                     |
```

---

## 報告格式

- 各節獨立，以 `---` 分隔
- 每節開頭一行摘要（OK / 需注意 / 需處理）
- 所有清單以 Markdown 表格呈現
- 第 5 節另附「優先移除總表」（按等級 1 → 3 排序）

---

## 報告輸出

分析完成後，將完整報告以 Markdown 格式寫入與 `<GPL_DIR_NAME>/` **同層目錄**：

```
<GPL_DIR_NAME>_GPL_RELEASE_REPORT.md
```

例如 EW-7786LBE 的報告路徑為：
```
/home/chris/ai/wab-be72-gpl_GPL_RELEASE_REPORT.md
```

報告開頭須包含：
```markdown
# GPL Release Report — <CUSTOMER_MODEL_NAME> (<MODEL>)
**版本：** <firmware_version>　**日期：** <today>　**Tarball：** <tarball_filename>
```

寫入完成後，在對話中顯示報告摘要（各節狀態一行），並告知報告已寫入的完整路徑。
