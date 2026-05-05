# tools/gpl-toolkit — GPL release automation

ELECOM 無線 AP 韌體 GPL 釋出工具組。詳細用法見此目錄下：

- [README.md](README.md) — 專案總覽 / 支援機種
- [GPL_TEST_SOP.md](GPL_TEST_SOP.md) — 完整 SOP（中文）
- [CONTRIBUTING.md](CONTRIBUTING.md) — 新增機種 / 修改規則
- [gpl_tools/REFERENCE_MAP.md](gpl_tools/REFERENCE_MAP.md) — 函式索引與決策樹
- [.claude/CLAUDE.md](.claude/CLAUDE.md) — 原 ai_test repo 的詳細指引（保留供工具內部使用）

## 與 ELX_with_AI 整合

- 來源樹路徑：`$ELX_SRC`（預設 `~/wab-be187`，由 root `AGENTS.md` 定義）
- 預設機種：`$ELX_MODEL`（見 `~/elx-workspace/elx.env`，per `docs/WORKSPACE_ARCHITECTURE.md` §4.2）
- slash commands 位於 [.claude/commands/](.claude/commands/)，需以本目錄為 cwd 才會被 Claude Code 自動載入

## Boundaries

- **不要**把 gpl-toolkit 的 token-saving 規則套到此 repo 其他位置——它是工具內部約定，外面沒這個前提。
- **修改 `gpl.sh` 前**：先讀 `gpl_tools/REFERENCE_MAP.md` 找對應函式區塊；新增機種看 `CONTRIBUTING.md` 的 6 步驟。
- **不要**自行對 `gpl_tools/*.py` 加抽象層——這些是 single-purpose 腳本，刻意保持平。

## Counterintuitive

1. **`<NEW_GPL_DIR_NAME>.src` 必須與 gpl-toolkit 同層**——不是子目錄，是 sibling。新增機種時若放錯層級 `gpl.sh` 找不到。
2. **`--mode full` 才需要 `make`**——`--mode quick` / 單機種驗證跑得起來不代表 full 跑得起來，release 前一定要 full。
3. **此目錄歷史以 `git subtree` 從 `~/ai_test` 匯入**——若需把改動同步回 ai_test，用 `git subtree push --prefix=tools/gpl-toolkit <ai_test-remote> main`，**不要**直接複製檔案。
