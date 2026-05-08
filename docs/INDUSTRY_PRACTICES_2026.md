# 業界 AI Coding Agent 管理實務報告（2026）

> 本報告基於 2026 年 2-4 月的公開資料、官方文件與業界部落格整理，補充並修正 `WORKSPACE_ARCHITECTURE.md` 中部分 2024-2025 年觀點。

**報告日期：** 2026-04-30
**涵蓋工具：** Claude Code、OpenAI Codex、GitHub Copilot
**關鍵焦點：** 多 repo 工作流、context 管理、跨 AI 工具整合

---

## 0. 重大變化摘要（vs 2024-2025）

| 領域 | 2024-2025 觀點 | 2026 現況 |
|------|--------------|----------|
| AI 設定檔格式 | 各家獨立（CLAUDE.md / .cursorrules / copilot-instructions.md） | **AGENTS.md 已成為跨工具共通標準**，60,000+ open-source 專案使用 |
| 多 repo 工作流 | Workspace overlay、symlink、submodule | **Bootstrap repo + Virtual Monorepo pattern** 成為主流 |
| 多 AI 工具整合 | 每家獨立用、互不通知 | **GitHub Agent HQ**（2026-02 推出）讓 Claude / Codex / Copilot 共用同一 workspace 與 context |
| Copilot 多 repo | 只有 repo 層 instructions | **Organization-level custom instructions GA**（2026-04） |
| Context 管理 | 「越多越好」 | **Context engineering 成核心差異化能力**，「more per token」 |

---

## 1. AGENTS.md：跨工具標準（最重要的 2026 變化）

### 1.1 為什麼 AGENTS.md 成為標準

[agents.md](https://agents.md/) 規格列出 **20+ 個支援工具**，包括所有主流 AI coding agent：

- **OpenAI Codex**（原生）
- **Anthropic Claude Code**
- **GitHub Copilot**（Coding Agent 模式）
- Google Jules / Gemini CLI
- JetBrains Junie
- Cognition Devin、Windsurf
- Cursor、Aider、goose、Zed、Warp、VS Code

**對 ELX 的意義：**  
不再需要為每個工具寫一份 CLAUDE.md / .cursorrules / copilot-instructions.md。**寫一份 AGENTS.md 即可被所有工具讀取**。

### 1.2 AGENTS.md 階層規則

- 放在 **repo 根目錄**
- **Monorepo 可放在子專案目錄**
- **「最靠近被編輯檔案的 AGENTS.md 勝出」**
- 用標準 Markdown，無強制欄位

常見 sections：
- Project overview
- Build and test commands
- Code style guidelines
- Testing instructions
- Security considerations
- PR / commit guidelines

### 1.3 與 CLAUDE.md 的關係

Claude Code 同時支援 AGENTS.md 與 CLAUDE.md：
- `CLAUDE.md` 仍然是 Claude Code 專屬最高優先
- `AGENTS.md` 是跨工具 fallback
- **2026 業界共識：寫 AGENTS.md 為主，僅在 Claude 專屬內容時才用 CLAUDE.md**

---

## 2. OpenAI Codex 的 AGENTS.md 機制（2026）

### 2.1 Discovery 順序

Codex 啟動時建立 instruction chain，順序：

```
1. 全域：~/.codex/AGENTS.override.md  →  ~/.codex/AGENTS.md（取第一個非空）
2. 專案：從 Git root 往 cwd 走，每層檢查
       AGENTS.override.md → AGENTS.md → fallback filenames
3. 合併方向：root → cwd（深層覆蓋淺層，因為出現在 prompt 後段）
```

每層**只讀一個檔案**，總大小不超過 `project_doc_max_bytes`（預設 32 KiB）。

### 2.2 AGENTS.override.md：臨時覆蓋

**2026 新特性：** `AGENTS.override.md` 在每層都優先於 `AGENTS.md`。

**用途：**
- 個人 fork 想覆蓋團隊規則：放 `AGENTS.override.md` 而不刪 `AGENTS.md`
- 機種特定設定：`source/services/payments/AGENTS.override.md` 覆蓋 root 規則

**對 ELX 的意義：** WAB-BE187 跟 WAB-BE36 共用 `wab-base/AGENTS.md`，但各自可放 `AGENTS.override.md` 微調機種專屬規則。

### 2.3 fallback filenames

支援自訂檔名（例如 `TEAM_GUIDE.md`）：

```toml
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]
```

Codex 依序檢查：`AGENTS.override.md` → `AGENTS.md` → `TEAM_GUIDE.md` → `.agents.md`

---

## 3. Claude Code 的 Multi-Repo 實務（2026）

### 3.1 Bootstrap Repo Pattern

[Karun.me 2026-03](https://karun.me/blog/2026/03/26/structuring-claude-code-for-multi-repo-workspaces/) 推廣的標準做法：

> **Bootstrap repo = workspace root，不放 application code，只放 manifest + 跨 repo 的 CLAUDE.md**

```
workspace/
├── mani.yaml                  # Imports product configs
├── CLAUDE.md                  # 組織層 context
├── mani.d/
│   ├── orders.yaml            # 各產品 manifest
│   └── shipping.yaml
├── orders/
│   ├── CLAUDE.md              # 團隊層 context（gitignore 例外保留此檔）
│   ├── order-service/         # 實際 repo（gitignored）
│   └── orders-ui/
└── shared/
    ├── CLAUDE.md
    └── react-lib/
```

**關鍵 gitignore 技巧：**
```
orders/*
!orders/CLAUDE.md
```
讓 bootstrap repo 追蹤 team-level CLAUDE.md，但不追蹤 sub-repo 內容。

### 3.2 Manifest 概念

Manifest（YAML）列出每個 repo 的 description：

```yaml
projects:
  order-service:
    desc: Order lifecycle management and fulfilment
    url: [email protected]:acme/order-service.git
    path: orders/order-service
```

**核心理念：** 「不要列細節清單，告訴 Claude 去哪裡找。」`desc` 欄位讓 AI 不用 grep 就知道哪個 repo 處理什麼。

### 3.3 三層 CLAUDE.md（業界共識）

| 層 | 位置 | 內容 |
|----|------|------|
| **Organization** | Bootstrap root | Multi-repo 警告、manifest 怎麼讀、跨 repo 操作規則 |
| **Team** | `<group>/CLAUDE.md` | 該 group 共用的技術 stack、慣例 |
| **Repository** | 各 repo 自己的 root | repo 專屬 build / 架構 |

**Karun.me 強調：「每層只放該層獨有的，不重複」**，加上 `CLAUDE.md ≤ 200 行` 規則（超過會明顯降低 instruction adherence）。

### 3.4 Virtual Monorepo Pattern（[Medium 2026-03](https://medium.com/devops-ai/the-virtual-monorepo-pattern-how-i-gave-claude-code-full-system-context-across-35-repos-43b310c97db8)）

更輕量的變形，三個檔案搞定：

```
workspace/
├── .repos              # bash script，clone 所有 repo
├── CLAUDE.md           # System map：service 之間如何互動
├── README.md           # Narrative：架構決策、技術選型理由
├── services/           # domain 分組
│   ├── event-ingestion-service/
│   ├── stream-processor/
│   └── analytics-api/
├── infrastructure/
│   ├── streaming-cluster/
│   └── database-cluster/
└── frontends/
    ├── ops-dashboard/
    └── customer-portal/
```

**關鍵差別於 README：**
> Code shows **what** a service does. CLAUDE.md shows **how services relate**.

`.repos` 是個簡單 bash script（不是 git submodule、不是工具抽象層），保持每個 repo 完全獨立。

> **規模建議：** 對「很大」系統，作者建議「**多個 virtual monorepo 各自 scoped 到不同 domain**」，而非單一巨大 workspace。

---

## 4. GitHub Copilot 的多 Repo 管理（2026）

### 4.1 Organization Custom Instructions 通用上線（2026-04）

[官方 changelog](https://github.blog/changelog/2026-04-02-copilot-organization-custom-instructions-are-generally-available/)：

- 適用於：Copilot Business、Copilot Enterprise
- 啟用範圍：Copilot Chat (github.com)、Copilot code review、Copilot cloud agent
- 設定路徑：Organization Settings → Copilot → Custom Instructions
- **目前限制：僅適用於 github.com 線上環境，IDE 端尚未完整支援**

### 4.2 三層優先順序

```
Personal instructions  >  Repository instructions  >  Organization instructions
```

（**注意方向：個人最高、組織最低**——這是要讓個人能 override 組織的設定）

### 4.3 業界做法：Central Guideline Repository

組織把 Org Custom Instructions 連到一個**內部「guideline repo」**，內含多套依語言 / 框架 / 專案類型的 instruction sets。

**對 ELX 的意義：** ELX_with_AI 本身就是這個 central guideline repo 的概念。

### 4.4 VS Code 的 Workspace 整合

VS Code 自動偵測組織層 instructions（帳號有權存取的）並顯示在 Chat Instructions menu，與 personal 和 workspace instructions 並列，**自動套用到所有 chat requests**。

---

## 5. GitHub Agent HQ：跨 AI 工具整合（2026-02 推出）

### 5.1 是什麼

[GitHub 官方 blog](https://github.blog/news-insights/company-news/pick-your-agent-use-claude-and-codex-on-agent-hq/)：

> **Claude、Codex、Copilot 在同一個 GitHub 平台上跑，共用 governance、context、memory。**

### 5.2 怎麼用

- 在 GitHub Issues / PR 中可以指派任務給 `@Copilot`、`@Claude`、`@Codex`
- 同一個 issue 可以指派給三個 agent，**比較三方輸出**
- VS Code 的 Agent Sessions view 整合三個 agent
- 公開預覽期：每個 session 消耗 1 premium request

### 5.3 對 ELX 的意義

**這改變了 multi-tool 整合的玩法。** 過去要為三個工具分別寫設定，現在的流程是：

1. 在 ELX_with_AI / source repo 寫 **AGENTS.md**（三個工具都讀）
2. 再額外寫 **CLAUDE.md**（Claude 專屬最高優先 context）
3. 寫 `.github/copilot-instructions.md`（Copilot org / repo 層）
4. 在 GitHub PR 用 `@Claude` / `@Codex` / `@Copilot` 指派任務

不再需要為每個工具獨立 maintenance 一個全文檔案。

---

## 6. Context Engineering：2026 的核心能力

[Faros.ai 2026 報告](https://www.faros.ai/blog/best-ai-coding-agents-2026)：

> 「2026 年開發者選 AI coding tool 的關鍵：哪個能 deliver more per token——更好的 context 管理、更少 retry、更強第一遍輸出。」

### 6.1 Augment Code 的 Context Engine

400K+ files 的大型 repo（典型嵌入式韌體規模）才需要：
- 提出 **incremental change** 而非 full rewrite
- 跨 repo trace dependencies
- 共用 validation library 分析

### 6.2 對 ELX 的具體做法

ELX_with_AI 的 SKILL / SPEC 檔案就是 context engineering 的產物：
- **不靠 AI 自己 grep 整個 wab-be187（高 token cost）**
- **預先寫好結構化 SKILL，AI 直接查表**
- 每個 SKILL 檔有明確 trigger conditions（讓 AI 知道何時用）
- 每個 SPEC 有 cross-reference table（不用 AI 自己推導關係）

這套做法在 2026 年被 Anthropic / OpenAI 都認證為 best practice。

---

## 7. 修正：對 ELX 架構的 2026 建議

對照 `WORKSPACE_ARCHITECTURE.md` 的建議，2026 年該調整：

### 7.1 ✅ 仍然有效

- 兩 repo 分離（source / knowledge）
- `.claude/settings.json` 放 env / permissions、CLAUDE.md 放內容
- 演進路線：workspace overlay → thin pointer → CI sync

### 7.2 ⚠️ 需要修正

| 原建議 | 2026 修正 |
|--------|----------|
| 寫 CLAUDE.md + AGENTS.md + copilot-instructions.md 三份 | **寫 AGENTS.md 為主**，僅在 Claude / Copilot 專屬時補充 |
| Workspace 用 symlink 連結 | **改用 Bootstrap repo + manifest pattern**，gitignore 例外保留 team CLAUDE.md |
| 沒提到 AGENTS.override.md | **每個機種放 `AGENTS.override.md`** 來覆寫共用的 `AGENTS.md` |
| 沒提到 GitHub Agent HQ | **如使用 GitHub PR workflow，把 ELX_with_AI 上 GitHub** 並啟用 Org Custom Instructions |

### 7.3 🆕 新增建議

1. **每層只維護 1 個 `AGENTS.md`，`CLAUDE.md` 與 `.github/copilot-instructions.md` 用 symlink 指向它**（單一真相來源，避免三檔 drift；詳見 Section 8）
2. **設定 `~/.codex/AGENTS.md`** 寫個人偏好（zsh、commit style 等）
3. **若 ELX_with_AI 推上 GitHub**，啟用 Organization Custom Instructions 把跨產品規則放在組織層
4. **Multi-AI 比較策略**：重要重構任務同時派給 `@Claude` 和 `@Codex`，比較結果再採用

---

## 8. 給 ELX 的 2026 推薦架構（最終版）

### 8.1 為何用 Symlink 而非三檔並列

最初版本曾建議每層放三份檔案（`AGENTS.md` + `CLAUDE.md` + `.github/copilot-instructions.md`）讓三家 AI 工具各自讀。**這在實務上不可維護**：

| 問題 | 後果 |
|------|------|
| 三檔內容會 drift | 改了 AGENTS 忘改 CLAUDE，AI 行為不一致 |
| 每層維護 ×3 | 套件越多成本越高（ELX 有 20+ packages） |
| 違反 single source of truth | 與本報告 Section 6 自己強調的 context engineering 矛盾 |

**業界 2026 共識做法：** 每層只寫 **1 個實體 `AGENTS.md`**，其他用 **symlink** 指過去。Git 原生追蹤 symlink，teammate clone 後自動有，無額外設定。

來源驗證：
- [Kaushik Gopal — Keep your AGENTS.md in sync](https://kau.sh/blog/agents-md/)
- [SSW Rules — Symlink AGENTS to Claude](https://www.ssw.com.au/rules/symlink-agents-to-claude)
- [tessl.io — Agents.md open standard](https://tessl.io/blog/the-rise-of-agents-md-an-open-standard-and-single-source-of-truth-for-ai-coding-agents/)

### 8.2 建立 Symlink 的標準指令

每層（root / team / package / tool）一次性執行：

```bash
# 在該層目錄下：
ln -s AGENTS.md CLAUDE.md
mkdir -p .github
ln -s ../AGENTS.md .github/copilot-instructions.md
git add AGENTS.md CLAUDE.md .github/copilot-instructions.md
git commit -m "chore: AGENTS.md as single source of truth"
```

驗證：
```bash
ls -la                            # 應見 CLAUDE.md -> AGENTS.md
git ls-files -s CLAUDE.md         # 開頭應為 120000（symlink mode）
diff AGENTS.md CLAUDE.md          # 應無輸出
```

### 8.3 例外：不 Symlink 的檔案

| 檔案 | 原因 |
|------|------|
| `AGENTS.override.md` | 機種專屬覆寫，內容本就獨立於主 `AGENTS.md` |
| `.claude/settings.json` | Claude 工具專屬（permissions / hooks / env），非通用內容 |
| `.codex/config.toml` | Codex 工具專屬 |
| `.claude/commands/*` | slash commands 是工具專屬 metaprompt |

### 8.4 完整目錄樹

```
~/elx-bootstrap/                              ← Bootstrap repo（workspace root）
│
├── AGENTS.md                                 ← 【實體】跨工具主設定（org 層）
├── CLAUDE.md ──→ AGENTS.md                   ← symlink
├── .github/
│   └── copilot-instructions.md ──→ ../AGENTS.md   ← symlink
├── README.md                                 ← Narrative：ELX 平台架構
│
├── manifest.yaml                             ← 列出所有 repo
├── .repos                                    ← bash script：clone 所有 repo
│
├── .claude/
│   ├── settings.json                         ← Claude 專屬（不 symlink）
│   └── commands/                             ← slash commands（不 symlink）
│
├── .gitignore                                ← 排除 sub-repo 但保留追蹤的 *.md
│   # source/*
│   # !source/AGENTS.md
│   # !source/CLAUDE.md
│   # knowledge/*
│   # !knowledge/AGENTS.md
│   # !knowledge/CLAUDE.md
│
├── source/                                   ← clone 進來（內容 gitignored）
│   ├── AGENTS.md                             ← 【實體】團隊層：build / 共用慣例 + 指向 knowledge 的 thin pointer
│   ├── CLAUDE.md ──→ AGENTS.md               ← symlink（追蹤）
│   └── wab-be187/                            ← gitignored
│       ├── AGENTS.md                         ← 【實體】repo 層：board 專屬 build、unusual conventions
│       ├── CLAUDE.md ──→ AGENTS.md           ← symlink
│       └── P_ELX/
│           └── elecom_cloud_apps/
│               └── AGENTS.override.md        ← ⚠️ 只在機種有覆寫需求時放（不 symlink）
│                                             ←    package 層平常不放 AGENTS.md，繼承父層即可
│                                             ←    domain 知識去 $ELX_AI 找（Progressive Disclosure，見 8.8）
│
└── knowledge/                                ← clone ELX_with_AI（內容 gitignored）
    ├── AGENTS.md                             ← 【實體】團隊層（追蹤）
    ├── CLAUDE.md ──→ AGENTS.md
    └── ELX_with_AI/                          ← gitignored
        ├── AGENTS.md                         ← 【實體】
        ├── CLAUDE.md ──→ AGENTS.md
        ├── .github/copilot-instructions.md ──→ ../AGENTS.md
        ├── P_ELX/
        │   └── elecom_cloud_apps/
        │       ├── AGENTS.md                 ← 【實體】
        │       ├── CLAUDE.md ──→ AGENTS.md
        │       └── spec/
        └── tools/gpl-toolkit/
            ├── AGENTS.md                     ← 【實體】
            ├── CLAUDE.md ──→ AGENTS.md
            └── .claude/skills/               ← 用 skills/ 而非 commands/（見 8.7）
                ├── gpl-batch/SKILL.md
                ├── gpl-full/SKILL.md
                ├── gpl-quick/SKILL.md
                ├── gpl-release/SKILL.md
                ├── gpl-report/SKILL.md
                └── gpl-new-model/SKILL.md
```

**結果：每一層維護 1 個 `AGENTS.md`，所有 AI 工具（Claude / Codex / Copilot / Cursor）都讀得到。子目錄的 skills 透過 nested auto-discovery 自動載入（見 8.7）。**

### 8.5 設定檔填寫策略：source 與 knowledge 的職責分工

依 **Progressive Disclosure** 原則（詳見 8.8）：source 端寫 *code-level* 規則，knowledge 端放 *domain* 知識，**內容不重複**。

| 檔案 | 該寫什麼 | 不該寫什麼 |
|------|---------|-----------|
| **Bootstrap root `AGENTS.md`** | workspace 結構、`manifest.yaml` / `.repos` 用法、跨 repo commit / PR 規則 | 任何 source repo 內細節 |
| **`source/AGENTS.md`** | 全 ELX 韌體共用 build 流程、`board_cfg/` 用法、哪些 P_GPL 套件不能動、token 節費規則 | API spec、商業邏輯、domain 知識（去 knowledge 找） |
| **`source/wab-be187/AGENTS.md`** | 此 board 專屬 build entry、特殊 toolchain 路徑 | 通用 ELX 規則（已在父層） |
| **`source/wab-be187/P_ELX/<package>/AGENTS.md`** | ⚠️ **平常不寫**。只在此 package 有「無法繼承的反直覺規則」時才放（例如：admlink_socket.c 的 BIO 所有權移交陷阱） | API spec、註冊流程說明（去 knowledge） |
| **`source/.../AGENTS.override.md`** | 機種專屬覆寫（例如 wab-be187 不適用 wab-be36 的某條規則） | — |
| **`knowledge/AGENTS.md`** | 此 repo 是 SKILL/SPEC 知識層的說明、SKILL 撰寫範本位置 | source 的 build 指令 |
| **`knowledge/ELX_with_AI/P_ELX/<package>/AGENTS.md`** | 此 package 的 domain overview、術語表、state machine、SKILL 索引 | code style、build 指令 |
| **`knowledge/ELX_with_AI/P_ELX/<package>/spec/`** | 完整 SPEC（v2 文件）+ 各 API 的 SKILL 檔（Progressive Disclosure 的 supporting docs） | — |

### 兩邊如何連結：thin pointer

source 端的 AGENTS.md 加一段（**只寫一次，所有 sub-package 都受惠**）：

```markdown
## Domain Knowledge

For API specs, state machines, error code tables, and SKILL files for any
package in this tree, read the corresponding directory under `$ELX_AI/`.

Examples:
- P_ELX/elecom_cloud_apps → $ELX_AI/P_ELX/elecom_cloud_apps/
- P_ELX/web → $ELX_AI/P_ELX/web/

Always load relevant SKILL files BEFORE making non-trivial changes.
```

這就是 [HumanLayer 推薦的「Prefer pointers to copies」原則](https://www.humanlayer.dev/blog/writing-a-good-claude-md)。

### 8.6 Windows 開發者注意事項

若團隊有 Windows 成員：
- 啟用 git symlink 支援：`git config --global core.symlinks true`
- 否則 symlink 在 Windows 端會變成內含路徑文字的純文字檔
- 替代方案：用「shim 模式」——`CLAUDE.md` 只寫一行 `See @AGENTS.md`（Claude Code 認得 `@` 引用語法）。維護成本略高於 symlink 但跨平台無痛

---

### 8.7 Slash Commands → Skills：2026 抉擇

**核心問題：** Section 8.4 的目錄樹中 `tools/gpl-toolkit/.claude/commands/gpl-*.md`，當 Claude Code 啟動於 bootstrap root（`~/elx-bootstrap/`）時 **無法被載入**，因為 commands 不會遞迴掃 subdirectories。

#### Commands vs Skills 行為對照

| 行為 | `.claude/commands/` | `.claude/skills/` |
|------|--------------------|--------------------|
| 從專案根載入 | ✅ | ✅ |
| **遞迴掃 nested 子目錄**（monorepo / multi-repo workspace） | ❌ | ✅ |
| 從 `--add-dir` 載入 | ❌ | ✅（**唯一例外**） |
| 完整 frontmatter（`when_to_use`、`allowed-tools`、`disable-model-invocation`、`context: fork`） | 有限 | ✅ |
| 支援 supporting files（範本、reference docs、scripts） | ❌ | ✅ |
| Live change detection（編輯不需重啟 session） | ❌ | ✅ |
cd 
來源：[Claude Code Slash Commands / Skills Docs](https://code.claude.com/docs/en/slash-commands)

> **官方原文：** "Custom commands have been merged into skills. A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way."
>
> **關鍵特性：** "When you work with files in subdirectories, Claude Code automatically discovers skills from nested `.claude/skills/` directories."

#### 為什麼 Skills 適合 ELX 多 repo workspace

```bash
cd ~/elx-bootstrap && claude
# ↑ 在 bootstrap root 啟動，當操作 tools/gpl-toolkit/ 內檔案時
#   Claude 自動發現 tools/gpl-toolkit/.claude/skills/gpl-*/SKILL.md
#   /gpl-release、/gpl-quick … 全部可呼叫
```

對比 commands 必須做以下其中一種 workaround：
1. 在 bootstrap root 把 commands 用 symlink 暴露出來（手動維護）
2. 切到 sub-folder 才啟動 Claude Code（失去 workspace context）
3. 放到 user-global `~/.claude/commands/`（污染其他專案）

**Skills 一個都不需要——nested auto-discovery 原生支援。**

#### 標準 SKILL.md 範本（以 gpl-release 為例）

```markdown
---
name: gpl-release
description: Run release-only cleanup on an existing GPL source tree (no rebuild). Use when the user is already inside a checked-out wab-*-gpl tree and wants to re-apply gpl.sh cleanup without rebuilding firmware.
argument-hint: MODEL
disable-model-invocation: true   # 只能手動 /gpl-release，避免 Claude 主動跑
allowed-tools: Bash(./gpl.sh *) Bash(/path/to/gcp/gpl.sh *)
---

# GPL Release Mode
（原本 commands/gpl-release.md 內容直接搬過來）
```

#### 從 Commands 遷移到 Skills 的步驟

```bash
# 1. 為每個 command 建立同名目錄
mkdir -p .claude/skills/<command-name>/

# 2. 把原 commands/<command-name>.md 內容搬到 .claude/skills/<command-name>/SKILL.md
mv .claude/commands/<command-name>.md .claude/skills/<command-name>/SKILL.md

# 3. 在 SKILL.md 開頭加 YAML frontmatter（name、description、disable-model-invocation 等）

# 4. 重要 frontmatter 欄位：
#    - description：Claude 用此判斷何時自動載入；用「Use when...」明確列出觸發條件
#    - disable-model-invocation: true：deploy / release 類型工作流程加這個，避免 Claude 主動跑
#    - allowed-tools：列出此 skill 需要的工具（例如 Bash(./gpl.sh *)），避免被反覆要 permission
#    - argument-hint：autocomplete 提示（例如 [MODEL] 或 [issue-number]）
```

#### 對 ELX 各層的套用建議

| 位置 | 用 commands 還是 skills | 理由 |
|------|-----------------------|------|
| `~/.claude/commands/` | 任一皆可 | 個人全域，掃 root 即可，commands 也能用 |
| `<bootstrap root>/.claude/skills/` | **Skills** | 跨 repo workflow，可能在 sub-repo 工作時被觸發 |
| `tools/gpl-toolkit/.claude/skills/` | **Skills（必須）** | nested 位置，commands 在此處 100% 不會被載入 |
| `knowledge/ELX_with_AI/.claude/skills/` | **Skills** | 同上，nested |
| Plugin 內 | Skills | Plugin 系統強制 |

**結論：除非你是個人全域工具，否則 2026 年起一律用 Skills。**

---

### 8.8 Progressive Disclosure 與 Non-Inferable Principle

業界 2026 對「AGENTS.md 該寫什麼」有明確共識，本節整合三個關鍵研究 / 指南，作為 ELX 規劃 source 與 knowledge 兩邊內容分工的依據。

#### 原則 1：Non-Inferable Principle（只寫 AI 推不出來的）

[Augment Code 2026 指南](https://www.augmentcode.com/guides/how-to-build-agents-md)（引用 ETH Zurich [arXiv 2601.20404](https://arxiv.org/html/2601.20404v1) 研究）：

> **「Write only what agents cannot discover independently.」**

實證資料：

| AGENTS.md 來源 | Cost 影響 | Success Rate 影響 |
|---------------|----------|------------------|
| LLM 自動產生 | +20–23% | **−0.5% ~ −2%**（變差） |
| **人工策展** | +19% | **+4%** |

寫錯內容會**降低**成功率還增加成本。可寫：
- ✅ 客製 build 指令、非標準工具選擇
- ✅ 反直覺架構決策（要寫 *why*，不只 *what*）
- ✅ 邊界（哪些檔不能改）、版本約束

不該寫：
- ❌ README 已有的東西
- ❌ codebase 結構（Agent 自己掃就有）
- ❌ Architectural overview（研究發現「don't provide effective overviews」）
- ❌ 程式風格 / linting（[HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)：「Never send an LLM to do a linter's job」——交給 Prettier / ESLint）

#### 原則 2：Progressive Disclosure（分層揭露）

[HumanLayer — Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)：

> **「Keep domain-specific instructions in separate markdown files with descriptive names (e.g., `agent_docs/service_architecture.md`), then reference them in CLAUDE.md. This approach allows Claude to decide which (if any) are relevant and read them before it starts working.」**
>
> Root CLAUDE.md keep under 300 lines, **ideally under 60**.
>
> **「Prefer pointers to copies.」**

**對 ELX 的對應：**

```
source/AGENTS.md（短，只放 build / 慣例 / pointer）
    └── 「Domain knowledge see $ELX_AI/<package>/」
         │
         ▼
ELX_with_AI/P_ELX/<package>/AGENTS.md（domain overview）
    └── spec/current/SPEC_v2_*.md    ← Agent 需要時才載入
    └── .claude/skills/*/SKILL.md    ← 各 API 的 SKILL（按需載入）
    └── spec/source_evidence/**/*.png ← 原始截圖證據（有疑義時再查）
```

**ELX_with_AI 整個 repo 就是 HumanLayer 講的 `agent_docs/` 的放大版**——只是放在獨立 repo，跨產品共用。

#### 原則 3：150–200 行門檻（什麼時候才拆 nested AGENTS.md）

[Augment Code](https://www.augmentcode.com/guides/how-to-build-agents-md)：

> **「Start monolithic under 150–200 lines. Split into subdirectories when:**
> - Root file exceeds 150–200 lines
> - **Different teams own different services**
> - Projects need service-specific overrides**」**

**對 ELX 的意思：**

| 情境 | 做法 |
|------|------|
| `source/AGENTS.md` 不超過 200 行 | 不需要 per-package AGENTS.md |
| 某 package 有「真的不能繼承」的反直覺規則 | 才在該 package 加 AGENTS.md |
| 機種專屬覆寫 | 用 `AGENTS.override.md` 而非新增 AGENTS.md |
| Domain 知識（API、商業邏輯） | **一律放 knowledge 端**，不放 source |

**反例：** 為了「對稱」在每個 package 寫 AGENTS.md → 違反 Non-Inferable Principle，每次 AI 載入都付 token 成本但無實質益處。

#### 整合：ELX 的 Progressive Disclosure 階層

```
Layer 1：總覽（永遠載入，必須極短）
    bootstrap/AGENTS.md ≤ 60 行
        ↓ pointer
Layer 2：source 端 code-level 規則
    source/AGENTS.md（build、共用慣例）
    source/wab-be187/AGENTS.md（board 專屬）
        ↓ pointer
Layer 3：knowledge 端 domain 概覽
    knowledge/ELX_with_AI/P_ELX/<pkg>/AGENTS.md
        ↓ 引用
Layer 4：詳細 SPEC / SKILL（按需載入）
    spec/current/SPEC_*.md
    .claude/skills/*/SKILL.md
    spec/source_evidence/**/*.png
```

**每一層只寫該層獨有、且不能繼承的內容。** 這是業界 2026 的共識做法。

#### 來源彙整

- [Augment Code — How to Build Your AGENTS.md (2026)](https://www.augmentcode.com/guides/how-to-build-agents-md)
- [HumanLayer — Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [InfoQ — New Research Reassesses the Value of AGENTS.md (2026-03)](https://www.infoq.com/news/2026/03/agents-context-file-value-review/)
- [arXiv 2601.20404 — On the Impact of AGENTS.md Files on AI Coding Agents (ETH Zurich)](https://arxiv.org/html/2601.20404v1)
- [The Prompt Shelf — AGENTS.md vs CLAUDE.md (2026)](https://thepromptshelf.dev/blog/agents-md-vs-claude-md/)

---

## 9. TL;DR — 與 2024-2025 規劃的差異

1. **每層只維護 1 個實體 `AGENTS.md`**，`CLAUDE.md` 與 `.github/copilot-instructions.md` 用 **symlink** 指向它（單一真相，避免三檔 drift）
2. **Bootstrap repo + manifest** 取代純 symlink workspace
3. **AGENTS.override.md** 解決機種變體的覆寫問題
4. **GitHub Agent HQ** 改變多工具協作方式（Issue / PR 直接 @ 不同 agent）
5. **Copilot Org Custom Instructions GA**（2026-04），ELX_with_AI 適合當「central guideline repo」
6. **每個 CLAUDE.md / AGENTS.md ≤ 200 行**（超過明顯降低 AI adherence）
7. **Context engineering 是 2026 核心競爭力**——SKILL/SPEC 結構化文件勝過讓 AI 自己 grep

---

## Sources

主要參考來源（依本報告引用順序）：

- [Structuring Claude Code for Multi-Repo Workspaces — Karun.me (2026-03)](https://karun.me/blog/2026/03/26/structuring-claude-code-for-multi-repo-workspaces/)
- [The Virtual Monorepo Pattern — DevOps×AI / Medium (2026-03)](https://medium.com/devops-ai/the-virtual-monorepo-pattern-how-i-gave-claude-code-full-system-context-across-35-repos-43b310c97db8)
- [AGENTS.md spec — agents.md](https://agents.md/)
- [Custom instructions with AGENTS.md — OpenAI Codex Docs](https://developers.openai.com/codex/guides/agents-md)
- [Codex Best Practices — OpenAI Developers](https://developers.openai.com/codex/learn/best-practices)
- [Adding organization custom instructions for Copilot — GitHub Docs](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-organization-instructions)
- [Copilot organization custom instructions GA — GitHub Changelog (2026-04-02)](https://github.blog/changelog/2026-04-02-copilot-organization-custom-instructions-are-generally-available/)
- [Pick your agent: Claude and Codex on Agent HQ — GitHub Blog](https://github.blog/news-insights/company-news/pick-your-agent-use-claude-and-codex-on-agent-hq/)
- [Claude and Codex public preview on GitHub — GitHub Changelog (2026-02-04)](https://github.blog/changelog/2026-02-04-claude-and-codex-are-now-available-in-public-preview-on-github/)
- [Multi-Agent Development — VS Code Blog (2026-02-05)](https://code.visualstudio.com/blogs/2026/02/05/multi-agent-development)
- [Best AI Coding Agents 2026 — Faros.ai](https://www.faros.ai/blog/best-ai-coding-agents-2026)
- [The State of AI Coding Agents 2026 — Medium](https://medium.com/@dave-patten/the-state-of-ai-coding-agents-2026-from-pair-programming-to-autonomous-ai-teams-b11f2b39232a)
- [How to use Claude Code with multiple repositories without losing context — DEV](https://dev.to/subprime2010/how-to-use-claude-code-with-multiple-repositories-without-losing-context-4c77)
