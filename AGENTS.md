# AGENTS.md — ELX_with_AI

ELX 韌體平台的 **AI 知識層**。**不是 source code repo**——映射 `~/wab-be187/` 的目錄結構，每個 package 提供 SKILL（AI 可呼叫流程）與 SPEC（需求規格）。給 Claude Code / Codex / Copilot / Cursor 使用。

## Commands

```bash
# 寫新 package 的 SKILL/SPEC 前，先讀對應 source code
ls $ELX_SRC/P_ELX/<package>/

# 找此 repo 內某個 API 的 SKILL（例：API 2.5）
ls P_ELX/elecom_cloud_apps/.claude/skills/adminlink-software-update/SKILL.md

# 寫新 SKILL 檔的命名慣例：<chapter>_<id>_<snake_case_name>_SKILL.md
# 例：3_1_wifi_config_api_SKILL.md
```

無 build / test / lint——這是文件 repo。`ELX_SRC` 預設指向 `~/wab-be187/`，未設定時詢問 user。

## Boundaries

- **不要**改 `archive/`——v1 歷史版本，唯讀。
- **不要**自動產生 SPEC / SKILL 內容（[研究](https://www.augmentcode.com/guides/how-to-build-agents-md)：LLM 自動產生使任務成功率 -0.5 至 -2%）。所有 SKILL / SPEC 必須對照 `$ELX_SRC` 的真實 source code 人工撰寫。
- **不要**新增 package 目錄，除非 `$ELX_SRC/P_ELX/<package>/` 真實存在。
- **不要**把 SPEC 完整內容貼進 AGENTS.md / CLAUDE.md——按 [Progressive Disclosure](docs/INDUSTRY_PRACTICES_2026.md#88-progressive-disclosure-與-non-inferable-principle)，spec/ 才是詳細內容的家。
- 修改 `docs/INDUSTRY_PRACTICES_2026.md` 第 8 節時，**先讀 [READING_ORDER.md](docs/READING_ORDER.md) 的 Stage 1+2**，避免違反業界 2026 共識。
- **Do not** recursively grep the whole `wab-be187/` — narrow to a single P_ELX package first (see [`docs/SEARCH_PROTOCOL.md`](docs/SEARCH_PROTOCOL.md) for domain routing).
- **Do not** read `wab-be72/` — different hardware target; only enter when the user explicitly asks.

## Commit Rules

- **絕不** commit `wab-be187/`、`wab-be72/`（或任何 `wab-be*/`）資料夾——這些是 source code worktree，屬於另一個 repo，**不屬於** ELX_with_AI。

  ```bash
  # 正確：只 stage 知識層檔案
  git add P_ELX/ docs/ tools/ AGENTS.md CLAUDE.md
  # 錯誤：git add wab-be187/  ← 嚴禁
  ```

- commit 前先執行 `git status`，確認 staged 清單內無 `wab-be*/` 路徑。

## Counterintuitive: Read These Before Editing SPEC/SKILL

這些反直覺規則 AI 不可能自己推出來，違反會錯得很離譜：

1. **`- [ ]` checkbox = 驗收標準，不是 TODO**
   v2 SPEC 中的所有勾選框是 acceptance criteria，**絕不要「完成」它們**。看到未勾選的 box 不代表沒做，而是「客戶要求須符合此條件」。

2. **`⚠️ DEPRECATED` 與 `<del>` 標記的需求不要實作**
   這些是被刪除的需求，留下來只為 audit trail。實作它們會引入已被 reject 的 feature。

3. **英文是 authoritative，`<details>` 內的日文是翻譯**
   雖然客戶是 ELECOM（日商），SPEC 衝突時以英文為準。日文段落只是輔助參考，**不要**因日文不同而改英文。

4. **此 repo 結構鏡像 `$ELX_SRC`**
   在 `P_ELX/elecom_cloud_apps/` 工作 = 描述 `$ELX_SRC/P_ELX/elecom_cloud_apps/` 的 source code。**新增此處的檔案前，必先確認 source 端對應目錄存在。**

5. **`(Refer AGT.x.y)` 是檔案內 cross-ref，不是外部連結**
   只在同一份 SPEC 內查找，不要去 grep 整個 repo。

## Domain Knowledge

- **SPEC / SKILL 撰寫慣例與業界依據**：[`docs/INDUSTRY_PRACTICES_2026.md`](docs/INDUSTRY_PRACTICES_2026.md)
- **學習路線（first-time）**：[`docs/READING_ORDER.md`](docs/READING_ORDER.md)
- **GPL release 工具**：[`tools/gpl-toolkit/`](tools/gpl-toolkit/)（從 `~/ai_test` 以 `git subtree` 匯入）
- **AdminLink 斷線重連測試工具**：[`tools/admlink-reconnect-test/`](tools/admlink-reconnect-test/)（裝置上驗證 IoT Core 斷線時原地換 cert 重連、不 reload daemon）
- **Source code 真相來源**：`$ELX_SRC/`（即 `~/wab-be187/`，未來含 `~/wab-be72/`）
- **新 package 模板**：[`docs/PACKAGE_AGENTS_TEMPLATE.md`](docs/PACKAGE_AGENTS_TEMPLATE.md)
- **Search protocol**: [`docs/SEARCH_PROTOCOL.md`](docs/SEARCH_PROTOCOL.md) — domain routing table, cross-package search rules, single-shot grep recipes.

### Package 入口（Layer 3）

需要某 package 的細節 → **直接讀 `P_ELX/<package>/AGENTS.md`**（SKILL 索引、反直覺規則、狀態機均在此）。

- `elecom_cloud_apps` — source: `$ELX_SRC/P_ELX/elecom_cloud_apps/`；索引入口：`P_ELX/elecom_cloud_apps/AGENTS.md` → `config_manager/CLAUDE.md`；狀態：✅ SKILL 2.2–2.10 + SPEC v2

新 source repo 加入時：在此表新增一列 + 建立 `P_ELX/<package>/AGENTS.md`（依模板）。
