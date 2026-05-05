# ELX AI Workspace 架構規劃

本文件整理業界 AI 知識管理的常見 pattern，並針對 ELX 平台（多產品線 + 共用韌體架構）給出具體規劃建議。

---

## 1. 業界主流 Pattern（2024-2025）

### Pattern A：Co-located in source（最普遍，~70%）

AI 文件直接放原始碼 repo 裡。

**代表案例：** Anthropic 自家、Vercel、Supabase、絕大多數開源專案

```
source-repo/
├── CLAUDE.md / AGENTS.md
├── .github/copilot-instructions.md
├── .cursor/rules/
├── docs/
└── src/
    ├── api/
    │   └── CLAUDE.md       ← 子目錄階層
    └── ...
```

| 優點 | 缺點 |
|------|------|
| AI 工具自動找到 | 多 repo 共用知識難共享 |
| 隨 branch 走 | 每個 fork/checkout 都複製一份 |
| 無路徑問題 | — |

---

### Pattern B：Knowledge repo + Submodule（傳統大廠）

**代表案例：** Google internal、Android AOSP（用 `repo` tool）、Microsoft 部分產品線

```
product-repo/
├── ai-knowledge/        ← git submodule
└── src/
```

| 優點 | 缺點 |
|------|------|
| 共用知識 single source of truth | submodule 操作門檻高 |
| 版本對齊 | 新人易踩坑 |
| — | 與 AI 工具的整合不直觀 |

---

### Pattern C：Workspace overlay（新興，正在興起）

把多個 repo 用 workspace 設定組合，AI 工具看到的是合併的視圖。

**代表案例：** VS Code multi-root workspace、JetBrains workspaces、Cursor 的 `@codebase` 指向多 repo、Sourcegraph 的 cross-repo context

```
~/workspace/
├── .code-workspace          ← 設定檔指向多個 repo
├── source/   →  symlink 或 clone
└── knowledge/ → symlink 或 clone
```

| 優點 | 缺點 |
|------|------|
| 各 repo 獨立 | 環境設定要每人配一次 |
| AI 看到完整 context | — |

---

### Pattern D：Platform repo with thin product overlay（平台型公司）

**代表案例：** Shopify、Stripe、Cloudflare 的 platform engineering team

```
platform-knowledge-repo/    ← 中央 AI knowledge（CI 自動發佈）
   └── 各 product 的共用 SPEC

product-repo/
└── .ai/
    └── (CI sync 從 platform 拉下來的 subset)
```

| 優點 | 缺點 |
|------|------|
| 平台演進跟產品解耦 | 需要 CI/CD 投資 |
| 單一真相 | 小團隊不划算 |

---

## 2. ELX 情境分析

ELECOM 的 ELX 平台是**典型的「平台型嵌入式廠商」**：
- 一個共用架構（ELX = `P_ELX`、`P_GPL`、`board_cfg`）
- 多個產品線（WAB-BE36、BE72、BE187…）
- 跨產品共用大量套件知識（`elecom_cloud_apps`、`fcgibox` 等）

**不適合 Pattern A** — 每次 checkout 重複  
**最接近 Pattern D** — 但團隊規模可能不需要 CI 投資  
**實務建議：Pattern C 打底，往 Pattern D 演進**

---

## 3. 業界針對此 profile 的具體做法

### 3.1 主流：兩 repo + workspace 連結

Yocto / Buildroot / OpenWRT 生態系常見。

```
~/elx-workspace/                    ← workspace root
├── .code-workspace                 ← VS Code multi-root
├── elx.env                         ← 全域 env vars (ELX_SRC, ELX_AI)
├── CLAUDE.md → ELX_with_AI/CLAUDE.md   (symlink)
├── source/    → ~/wab-be187          (symlink 或 clone)
└── knowledge/ → ~/ELX_with_AI        (symlink 或 clone)
```

開 AI 工具時 `cd ~/elx-workspace`，CLAUDE.md 階層從這層開始往下找。

---

### 3.2 嵌入式韌體業界更常見：source 裡放 thin pointer

不把整個 ELX_with_AI 塞進 source，而是在 source 各層放一個 `CLAUDE.md` 寫：

```markdown
# P_ELX/elecom_cloud_apps/CLAUDE.md (in wab-be187)

This package's specification and SKILL files are in:
  $ELX_AI/P_ELX/elecom_cloud_apps/spec/

If $ELX_AI is not set, ask the user for the path to ELX_with_AI checkout.
Then load:
  - spec/v2/SPEC_v2_AGT*.md (requirements)
  - spec/skill/*.md (API skills)
```

**為什麼業界偏好這種：**
- Source repo 不被外部知識污染（cleaner git history）
- 知識層獨立演進、可以版本獨立
- 換產品時 source repo 不變，knowledge 換一份就好
- 多個 AI 工具都能讀到 thin pointer

**代表案例：** Linux kernel 的 `Documentation/` 目錄結構、Yocto 的 `meta-*` layers、AOSP 的 `OWNERS` + `METADATA` 檔案模式

---

### 3.3 AI 工具 config 分層的業界共識

| 層級 | 放什麼 | 範例 |
|------|--------|------|
| **Global**（`~/.claude/CLAUDE.md`） | 個人偏好、跨專案習慣 | 「我用 zsh、編輯器是 nvim」 |
| **Workspace root** | 跨 repo 連結、env vars、團隊規範 | ELX_SRC / ELX_AI 設定、commit message 規則 |
| **Repo root** | 該 repo 的架構、build 指令 | `make menuconfig && make build` |
| **Package level** | 該 package 的領域知識、API 慣例 | AdminLink state machine |
| **Tool subdirs** | 工具專屬規則 | gpl-toolkit 的 token 節費規則 |

**業界共識：**
- `.claude/settings.json` 只放 **permissions / hooks / env**，不放內容
- `CLAUDE.md` 放**內容**，不放設定
- 每層只寫該層獨有的，不重複父層

---

## 4. 具體 Workspace 目錄樹

### 4.1 完整目錄樹（推薦配置）

```
~/elx-workspace/                                ← AI workspace root（cd 此處啟動 AI）
│
├── .code-workspace                             ← VS Code multi-root 設定檔
├── elx.env                                     ← 全域 env vars（source 後再啟動 AI）
├── README.md                                   ← workspace 使用說明
│
├── CLAUDE.md                                   ← workspace 層 AI 指引（symlink → knowledge/CLAUDE.md）
├── AGENTS.md                                   ← Codex 用（symlink → knowledge/AGENTS.md）
│
├── .claude/                                    ← workspace 層 Claude Code 設定
│   ├── settings.json                           ← env vars (ELX_SRC, ELX_AI)、permissions
│   └── commands/                               ← workspace 全域 slash commands
│       ├── new-skill.md                        ← /new-skill <package>
│       └── sync-skills.md                      ← /sync-skills（Pattern D 演進時用）
│
├── .github/
│   └── copilot-instructions.md                 ← Copilot 指引（symlink → knowledge/.github/...）
│
├── source/                                     ← symlink → ~/wab-be187（或當下機種）
│   │
│   │  以下是 source repo 內可選擇放置的 thin pointer（演進階段）
│   │
│   ├── CLAUDE.md                               ← 「此 repo 的 AI knowledge 在 $ELX_AI」
│   ├── P_ELX/
│   │   ├── CLAUDE.md                           ← thin pointer → $ELX_AI/P_ELX/
│   │   ├── elecom_cloud_apps/
│   │   │   └── CLAUDE.md                       ← thin pointer → $ELX_AI/P_ELX/elecom_cloud_apps/spec/
│   │   ├── web/
│   │   │   └── CLAUDE.md
│   │   └── fcgibox/
│   │       └── CLAUDE.md
│   ├── P_GPL/
│   │   └── CLAUDE.md
│   └── ...（其他 source 內容不變）
│
├── knowledge/                                  ← symlink → ~/ELX_with_AI
│   │
│   ├── CLAUDE.md                               ← knowledge repo 全域指引
│   ├── AGENTS.md
│   ├── .github/
│   │   └── copilot-instructions.md
│   │
│   ├── .claude/
│   │   ├── settings.json                       ← knowledge repo 的 permissions
│   │   └── commands/                           ← knowledge 操作專屬指令
│   │
│   ├── docs/
│   │   ├── WORKSPACE_ARCHITECTURE.md           ← 本文件
│   │   ├── SKILL_TEMPLATE.md                   ← 撰寫 SKILL 的範本
│   │   └── SPEC_TEMPLATE.md
│   │
│   ├── P_ELX/
│   │   ├── CLAUDE.md                           ← P_ELX 群組共通規則
│   │   │
│   │   ├── elecom_cloud_apps/
│   │   │   ├── CLAUDE.md                       ← package 層指引
│   │   │   └── spec/
│   │   │       ├── README.md
│   │   │       ├── v2/
│   │   │       │   ├── SPEC_v2_AGT1_WebUI.md
│   │   │       │   ├── SPEC_v2_AGT2_Agent.md
│   │   │       │   ├── SPEC_v2_AGT3_RemoteControl.md
│   │   │       │   └── SPEC_v2_AGT4_ZeroTouch.md
│   │   │       ├── skill/
│   │   │       │   └── 2_*_*_SKILL.md
│   │   │       ├── docs/
│   │   │       └── archive/
│   │   │
│   │   ├── web/                                ← 規劃中
│   │   │   ├── CLAUDE.md
│   │   │   └── spec/
│   │   ├── fcgibox/
│   │   │   ├── CLAUDE.md
│   │   │   └── spec/
│   │   ├── cli/
│   │   ├── osapi/
│   │   └── dbox2/
│   │
│   ├── P_GPL/
│   │   └── CLAUDE.md                           ← GPL 套件修改原則
│   │
│   ├── P_KNL/
│   ├── P_MTK/
│   │
│   ├── board_cfg/                              ← build system 知識
│   │   └── CLAUDE.md
│   │
│   └── tools/
│       └── gpl-toolkit/                        ← ai_test 移到這裡
│           ├── CLAUDE.md
│           ├── README.md
│           ├── GPL_TEST_SOP.md
│           ├── CONTRIBUTING.md
│           ├── CHANGELOG.md
│           ├── .claude/
│           │   ├── settings.local.json
│           │   └── commands/
│           │       ├── gpl-batch.md
│           │       ├── gpl-full.md
│           │       ├── gpl-new-model.md
│           │       ├── gpl-quick.md
│           │       ├── gpl-release.md
│           │       └── gpl-report.md
│           ├── gpl.sh
│           └── gpl_tools/
│               ├── encrypt_shell_scripts.py
│               ├── patch_makefiles.py
│               ├── protect_runtime_shell_scripts.py
│               ├── strip_shell_comments.py
│               ├── strip_web_comments.py
│               └── REFERENCE_MAP.md
│
└── .gitignore                                  ← workspace 本身不入版控（symlink、env 因人而異）
```

---

### 4.2 關鍵設定檔範例

#### `~/elx-workspace/elx.env`

```bash
# 來源樹位置（換機種時改這個）
export ELX_SRC="$HOME/wab-be187"

# AI knowledge 位置
export ELX_AI="$HOME/ELX_with_AI"

# gpl-toolkit 位置（從 ELX_AI 衍生）
export ELX_GPL_TOOLKIT="$ELX_AI/tools/gpl-toolkit"

# 當前產品（用於 gpl-toolkit 預設值等）
export ELX_MODEL="EW-7896LBE"
```

使用方式：
```bash
cd ~/elx-workspace
source elx.env
claude          # 或其他 AI 工具
```

---

#### `~/elx-workspace/.claude/settings.json`

```json
{
  "env": {
    "ELX_SRC": "/home/chris/wab-be187",
    "ELX_AI": "/home/chris/ELX_with_AI"
  },
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Read(//home/chris/wab-be187/**)",
      "Read(//home/chris/ELX_with_AI/**)"
    ]
  }
}
```

---

#### `~/elx-workspace/.code-workspace`（VS Code）

```json
{
  "folders": [
    { "name": "source (wab-be187)", "path": "source" },
    { "name": "knowledge (ELX_with_AI)", "path": "knowledge" }
  ],
  "settings": {
    "terminal.integrated.env.linux": {
      "ELX_SRC": "${workspaceFolder:source (wab-be187)}",
      "ELX_AI": "${workspaceFolder:knowledge (ELX_with_AI)}"
    }
  }
}
```

---

#### Source 裡的 thin pointer 範例

`~/wab-be187/P_ELX/elecom_cloud_apps/CLAUDE.md`：

```markdown
# AI Context: P_ELX/elecom_cloud_apps

This package implements the AdminLink cloud agent.
Full specification and SKILL files are maintained in the ELX AI knowledge repo.

## Required Reading

Before modifying this package, load these files from `$ELX_AI`:

- `$ELX_AI/P_ELX/elecom_cloud_apps/CLAUDE.md` — package-level rules
- `$ELX_AI/P_ELX/elecom_cloud_apps/spec/v2/SPEC_v2_AGT2_Agent.md` — agent requirements
- `$ELX_AI/P_ELX/elecom_cloud_apps/spec/skill/*.md` — API skill files

If `$ELX_AI` is not set, ask the user for the ELX_with_AI checkout path.

## Key Source Files

- `admlink/admlink_main.c` — daemon entry point
- `admlink/admlink_socket.c` — TLS / BIO connection handling
- `admlink/admlink_sm.c` — state machine
- `libadmlink/` — shared library
- `config_manager/` — dbox ↔ JSON converters
```

---

### 4.3 Schema artifact 的歸屬（如 config_manager）

並非所有「.json / schema 類檔案」都屬於 `spec/` 子樹。判斷準則：

| 來源 | 放哪 | 範例 |
|------|------|------|
| **人類規格書衍生**（SPEC.xlsx → markdown） | `spec/` 子樹 | `spec/v2/SPEC_v2_AGT*.md`、`spec/skill/2_*_*_SKILL.md` |
| **source code 工具產出**（generator output） | package 同名子目錄 | `config_manager/*.spec.json`、`config_manager/ui-spec.schema.json` |

理由：spec/ 是「客戶規格的真相層」，由人讀寫；generator output 是「source 端工具的產物」，由機器產生並由 source 端編譯使用。把兩者混進 spec/ 會讓 AI 在「修改一個 cloud UI 欄位」時誤以為要改客戶規格書。

對應 source 端：`$ELX_SRC/P_ELX/elecom_cloud_apps/config_manager/{dbox_to_json,json_to_dbox}/` 是 dbox ↔ JSON 雙向轉換器，那些 `*.spec.json` 是它的輸入。

---

## 5. 演進路線

### 第一階段（現在 → 1 個月）：Pattern C（workspace overlay）

```bash
mkdir -p ~/elx-workspace
cd ~/elx-workspace
ln -s ~/wab-be187 source
ln -s ~/ELX_with_AI knowledge
ln -s knowledge/CLAUDE.md CLAUDE.md
# 編輯 elx.env、.claude/settings.json
```

低成本、立即可用。

---

### 第二階段（3-6 個月）：Source 裡放 thin pointer

在 `wab-be187/P_ELX/<package>/CLAUDE.md` 放 pointer 指向 ELX_with_AI 對應位置。  
任何人 checkout source 都自動有 AI 指引（即使沒設 workspace 也會被提示去設 `$ELX_AI`）。

---

### 第三階段（如果規模擴大）：往 Pattern D

ELX_with_AI 加 CI，自動把該 package 的 SKILL/SPEC 同步到對應 source repo 的 `.ai/` 目錄。  
此時 source repo 不依賴 ELX_AI 路徑也能用，達到 platform 與 product 解耦。

---

### 5.x 遷入既有獨立 repo（如 gpl-toolkit）

若某工具原本是獨立 git repo（例：`~/ai_test` 之於 gpl-toolkit），優先用 `git subtree add` 保留 commit 歷史：

```bash
cd ~/ELX_with_AI
git subtree add --prefix=tools/<name> <path-or-url> <branch>
# 例：git subtree add --prefix=tools/gpl-toolkit /home/chris/ai_test main
```

**為什麼不用 submodule**：見 §6 附錄；新人易踩坑、與 AI 工具整合不直觀。  
**為什麼不只是複製檔案**：失去歷史、未來雙向同步無基準。  
**遷入後**：原獨立 repo 設為 archive 或刪除，避免雙頭來源。要把改動同步回原 repo 用 `git subtree push --prefix=tools/<name> <remote> <branch>`。

---

## 6. TL;DR

業界對「平台 + 多產品 + 共用知識」這種情境，主流做法：

1. **兩 repo 分離** — knowledge 與 source 各自獨立
2. **用 workspace overlay 連起來** — 不是把 knowledge repo 變成 workspace root，而是建一個更上層的 workspace
3. **Source repo 裡放 thin pointer CLAUDE.md** — 指向 knowledge repo
4. **`.claude/settings.json` 放 env / permissions；CLAUDE.md 放內容** — 職責分離
5. **CI 同步是後期才考慮的事** — 先用 symlink + env var 解決

---

## 附錄：不建議的做法與原因

| 做法 | 為什麼不推薦 |
|------|------------|
| 把 ELX_with_AI 當成 workspace root | 隱含「AI 文件比 source 重要」的反直覺；source 變成 ELX_with_AI 的 subdirectory 不合常識 |
| 把 knowledge 直接 copy 進 source repo | 違反 single source of truth；多產品 repo 同步成本高 |
| 用 git submodule 把 knowledge 嵌入 source | 操作門檻高、新人易踩坑、與 AI 工具整合不直觀（2024 年起業界明顯減少 submodule 使用） |
| 用單一巨大 CLAUDE.md 寫所有內容 | 違反 Claude Code 階層載入設計、context window 浪費、不同 package 的 AI 都讀到無關內容 |
| 把 ELX_SRC 寫死在 CLAUDE.md 裡 | 換機種或多人共用時要逐處修改，env var 才是業界做法 |
