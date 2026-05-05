# docs/ — Meta 文件索引

針對「**如何規劃 / 維護 ELX_with_AI 本身**」的元層級文件。**不是** package 的 SPEC（那些在 `P_ELX/<package>/spec/`）。

| 檔案 | 一句話內容 | 對象 |
|------|-----------|------|
| [`INDUSTRY_PRACTICES_2026.md`](INDUSTRY_PRACTICES_2026.md) | 2026 業界 AI 知識管理實務報告 + ELX 推薦架構（Section 8 是核心，含目錄樹、symlink、Skills 遷移、Progressive Disclosure） | 規劃架構決策時讀 |
| [`READING_ORDER.md`](READING_ORDER.md) | 13 篇外部來源的推薦閱讀順序（Stage 1–6）+ 5 條依角色的學習路徑 | 第一次接觸 AI 知識管理時讀 |
| [`WORKSPACE_ARCHITECTURE.md`](WORKSPACE_ARCHITECTURE.md) | ⚠️ **首版（2024-2025 觀點）**——大部分已被 `INDUSTRY_PRACTICES_2026.md` 取代。保留作參考 / git history | 想知道演進脈絡時讀 |

## 何時更新本目錄

- **新增業界實務筆記** → 進 `INDUSTRY_PRACTICES_2026.md` 或新建 `INDUSTRY_PRACTICES_<year>.md`
- **新增學習資源** → 加入 `READING_ORDER.md` 對應 Stage
- **新增 ELX_with_AI repo 自身的 convention 文件**（例：SKILL_TEMPLATE.md、SPEC_TEMPLATE.md） → 直接放此目錄並更新本 README

## 何時不該放這裡

❌ 任何 package 專屬的 SPEC / SKILL → 放 `P_ELX/<package>/spec/`
❌ 任何 source code 文件 → 放 `~/wab-be187/`
❌ AGENTS.md / CLAUDE.md → 放對應的階層 root，不是 `docs/`
