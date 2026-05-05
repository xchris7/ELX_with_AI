# 推薦閱讀順序：AI Coding Agent 知識管理（2026）

本文件整理 `INDUSTRY_PRACTICES_2026.md` 引用的外部來源，依「**理解難度遞增 + 概念依賴**」排序，幫助你快速建立完整心智模型。

**總時數：** 核心 6 篇約 60–90 分鐘讀完，可建立 80% 認知。  
**建議讀法：** 不要全文細讀，先看「Why read」決定是否值得展開細節。

---

## Stage 1：基礎（15 分鐘）—— 先知道遊戲規則

### 1.1 [agents.md spec（首頁）](https://agents.md/) ⭐⭐⭐

**閱讀時間：** 5 分鐘  
**Why read：** 三段話搞懂 AGENTS.md 是什麼、誰支援、跟 README.md / CLAUDE.md 差在哪。  
**重點抓出：**
- AGENTS.md 是 Markdown 格式的 AI 「config 檔」
- 已成為 20+ 工具的共通標準（Claude / Codex / Copilot / Cursor / Cline / Aider …）
- 60,000+ 開源專案使用
- 巢狀規則：「最靠近被編輯檔的 AGENTS.md 勝出」

**讀完你應該能回答：** 為什麼 2026 年大家漸漸不用 `.cursorrules` / `copilot-instructions.md` 而改寫 AGENTS.md？

---

### 1.2 [The Prompt Shelf — AGENTS.md vs CLAUDE.md (2026)](https://thepromptshelf.dev/blog/agents-md-vs-claude-md/) ⭐⭐

**閱讀時間：** 10 分鐘  
**Why read：** 把三個常見格式（AGENTS.md / CLAUDE.md / copilot-instructions.md）的關係講清楚——為什麼 Claude 會優先 CLAUDE.md、為什麼業界用 symlink 統一。  
**重點抓出：**
- Claude Code 載入順序：CLAUDE.md > AGENTS.md
- 解法：寫一個實體 AGENTS.md，CLAUDE.md 用 symlink 指過去
- 三個工具讀同一份檔，避免 drift

**讀完你應該能回答：** 為什麼不能直接刪掉 CLAUDE.md 只留 AGENTS.md？

---

## Stage 2：內容哲學（核心，30 分鐘）—— 真正改變寫作習慣

### 2.1 [HumanLayer — Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) ⭐⭐⭐⭐⭐

**閱讀時間：** 15 分鐘  
**Why read：** **整份報告引用最多的一篇**。提出 **Progressive Disclosure** pattern——把領域知識拆成獨立檔，AGENTS.md 只放 pointer。這正是 ELX_with_AI 的設計哲學。  
**重點抓出：**
- 「Never send an LLM to do a linter's job」
- Root CLAUDE.md 應 ≤ 300 行，**理想 ≤ 60 行**
- WHAT / WHY / HOW 三分法
- **「Prefer pointers to copies」**——把 spec、API doc 放外部檔，CLAUDE.md 只引用
- `agent_docs/` 模式（ELX_with_AI 就是這個的 repo 級放大版）

**讀完你應該能回答：** 為什麼把整份 SPEC 塞進 CLAUDE.md 是壞主意？

---

### 2.2 [Augment Code — How to Build Your AGENTS.md (2026)](https://www.augmentcode.com/guides/how-to-build-agents-md) ⭐⭐⭐⭐⭐

**閱讀時間：** 15 分鐘  
**Why read：** **2026 最完整的 AGENTS.md 寫作指南**。引用 ETH Zurich 學術研究，提供量化資料。  
**重點抓出：**
- **Non-Inferable Principle**：「Write only what agents cannot discover independently」
- 量化資料：人工 AGENTS.md +4% 成功率、LLM 自動產生 −0.5% 至 −2%（變差）
- 拆檔門檻：**150–200 行**（超過才考慮巢狀）
- 該寫的、不該寫的明確清單

**讀完你應該能回答：** 為什麼 `/init` 自動產生的 AGENTS.md 通常該重寫？

> ⏸ **讀完 Stage 2，已掌握 80% 核心觀念。** 後續是「實作技巧」與「整合」，可按需展開。

---

## Stage 3：研究背景（選讀，20 分鐘）—— 想看實證資料才讀

### 3.1 [InfoQ — New Research Reassesses the Value of AGENTS.md (2026-03)](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) ⭐⭐⭐

**閱讀時間：** 8 分鐘  
**Why read：** ETH Zurich 研究的記者整理版，比原 paper 易讀。  
**重點抓出：**
- 研究方法論摘要
- 為何 LLM 自動產生 AGENTS.md 通常無效
- 行業專家對研究結論的反應

---

### 3.2 [arXiv 2601.20404 — On the Impact of AGENTS.md Files](https://arxiv.org/html/2601.20404v1) ⭐⭐

**閱讀時間：** 30+ 分鐘（學術 paper）  
**Why read：** 想看完整實驗設計與數字。**只在你要說服老闆 / 同事時才需要。**  
**重點抓出：** 實驗設計、controlled variables、coding agent 測試矩陣。

---

## Stage 4：Multi-Repo / Workspace 實務（30 分鐘）—— ELX 直接相關

### 4.1 [Karun.me — Structuring Claude Code for Multi-Repo Workspaces (2026-03)](https://karun.me/blog/2026/03/26/structuring-claude-code-for-multi-repo-workspaces/) ⭐⭐⭐⭐

**閱讀時間：** 10 分鐘  
**Why read：** **Bootstrap repo + manifest pattern** 的代表作。直接對應 ELX 的 `~/elx-bootstrap/` 設計。  
**重點抓出：**
- Bootstrap repo 不放 source code，只放 manifest
- 三層 CLAUDE.md：org → team → repo
- gitignore 例外保留 team-level CLAUDE.md（`orders/*` 配 `!orders/CLAUDE.md`）
- mani.yaml 的角色

**讀完你應該能回答：** 為什麼不要把 source code clone 進 ELX_with_AI repo？

---

### 4.2 [Virtual Monorepo Pattern — Medium (2026-03)](https://medium.com/devops-ai/the-virtual-monorepo-pattern-how-i-gave-claude-code-full-system-context-across-35-repos-43b310c97db8) ⭐⭐⭐

**閱讀時間：** 10 分鐘  
**Why read：** Bootstrap pattern 的更輕量變形。「You don't need a monorepo. You need a monorepo *view*.」  
**重點抓出：**
- `.repos` 腳本：簡單 bash，clone 所有 repo
- CLAUDE.md = system map（service 之間關係）
- README.md = narrative（架構決策）
- 對 35 repos 的實戰經驗

---

### 4.3 [Kaushik Gopal — Keep your AGENTS.md in sync](https://kau.sh/blog/agents-md/) ⭐⭐⭐

**閱讀時間：** 10 分鐘  
**Why read：** symlink 統一三檔的最佳實作教學。  
**重點抓出：**
- 確切 symlink 指令：`ln -s AGENTS.md CLAUDE.md`
- Makefile setup 範本
- Windows 的 `core.symlinks=true` 設定

---

### 4.4 [SSW Rules — Symlink AGENTS to Claude](https://www.ssw.com.au/rules/symlink-agents-to-claude) ⭐⭐

**閱讀時間：** 5 分鐘  
**Why read：** 簡短 rule 形式，當作 cheatsheet。  
**重點抓出：**
- Git 原生追蹤 symlink
- `.claude/settings.json` **不該** symlink

---

## Stage 5：工具整合（20 分鐘）—— 想跨工具用才讀

### 5.1 [OpenAI Codex — Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md) ⭐⭐⭐

**閱讀時間：** 10 分鐘  
**Why read：** Codex 對 AGENTS.md 的 hierarchy 規則最完整。  
**重點抓出：**
- `~/.codex/AGENTS.override.md` 全域覆寫
- `project_doc_max_bytes`（預設 32 KiB）
- `project_doc_fallback_filenames` 自訂檔名
- 走訪順序：Git root → cwd

---

### 5.2 [Claude Code — Slash commands / Skills 文件](https://code.claude.com/docs/en/slash-commands) ⭐⭐⭐⭐

**閱讀時間：** 15 分鐘  
**Why read：** 直接解答「為什麼 commands 不會被 nested 載入、改用 skills 就會」。  
**重點抓出：**
- 「Custom commands have been merged into skills」
- Skills 的 nested auto-discovery（commands 沒有）
- `--add-dir` 對 skills 是例外（會載入）
- 完整 frontmatter 欄位（disable-model-invocation、allowed-tools、context: fork…）

---

### 5.3 [GitHub Blog — Pick your agent: Claude and Codex on Agent HQ](https://github.blog/news-insights/company-news/pick-your-agent-use-claude-and-codex-on-agent-hq/) ⭐⭐

**閱讀時間：** 5 分鐘  
**Why read：** 了解 2026 多工具協作的新玩法（在 GitHub PR 內 `@Claude` / `@Codex` / `@Copilot`）。  
**重點抓出：**
- 三個 agent 共用 GitHub 的 governance
- 同一 issue 可指派多個 agent 比較結果
- VS Code Agent Sessions view

---

### 5.4 [GitHub Docs — Organization custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-organization-instructions) ⭐

**閱讀時間：** 5 分鐘  
**Why read：** 若 ELX 上 GitHub，組織層 instructions GA 後可作為「central guideline repo」。  
**重點抓出：**
- 三層優先順序：personal > repository > organization
- 適用範圍：Copilot Chat / code review / cloud agent on github.com

---

## Stage 6：補充選讀（依需求）

### 6.1 [Faros.ai — Best AI Coding Agents 2026](https://www.faros.ai/blog/best-ai-coding-agents-2026) ⭐⭐

**Why read：** 想知道「AGENTS.md 之外，市場上的 AI coding agent 全景」。提供 context engineering 的市場視角。

### 6.2 [tessl.io — The Rise of Agents.md](https://tessl.io/blog/the-rise-of-agents-md-an-open-standard-and-single-source-of-truth-for-ai-coding-agents/) ⭐⭐

**Why read：** AGENTS.md 為何 2026 變主流的脈絡與背景。歷史視角。

### 6.3 [VS Code Blog — Multi-Agent Development (2026-02-05)](https://code.visualstudio.com/blogs/2026/02/05/multi-agent-development) ⭐

**Why read：** VS Code 端的 multi-agent UX，補充 GitHub Agent HQ。

---

## 推薦學習路徑（依角色）

### 🎯 「我只想快速上手寫好 AGENTS.md」
讀：**1.1 → 2.1 → 2.2** = 35 分鐘  
產出：能為任何專案寫出符合業界最佳實踐的 AGENTS.md

### 🏗 「我要規劃 ELX 的 multi-repo workspace」
讀：**1.1 → 2.1 → 2.2 → 4.1 → 4.2 → 5.2** = 70 分鐘  
產出：完整 workspace 架構決策能力

### 🔧 「我要實際把現有專案改成 symlink + skills」
讀：**1.1 → 4.3 → 4.4 → 5.2** = 35 分鐘  
產出：可動手改檔

### 📊 「我要說服團隊 / 老闆採用」
讀：**2.2 → 3.1 → 3.2** = 50 分鐘（含 paper）  
產出：有研究數據可引用（+4% 成功率、35-55% bug 減少）

### 🌐 「我要整合 Claude / Codex / Copilot 三家」
讀：**1.2 → 5.1 → 5.2 → 5.3 → 5.4** = 45 分鐘  
產出：跨工具策略

---

## 已涵蓋本報告引用的所有來源

對應 `INDUSTRY_PRACTICES_2026.md` 文末 Sources 段，本文重新依「閱讀順序」組織。每篇都標記：

- **閱讀時間**：實測平均
- **Why read**：一句話告訴你值不值得
- **重點抓出**：抓 3–5 個 key takeaways
- **讀完你應該能回答**：自我檢驗的問題（部分項目）
- **星等**：⭐ = 補充、⭐⭐⭐⭐⭐ = 必讀

---

**最後建議：** Stage 1 + 2（45 分鐘）讀完後就動手改一份 AGENTS.md 試試。**實作中遇到問題再回頭查 Stage 3-5**——不要先讀完所有再動手，會疲乏。
