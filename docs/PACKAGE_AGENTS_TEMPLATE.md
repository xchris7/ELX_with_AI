# AGENTS.md — P_ELX/<package>

<!-- 複製此模板到 P_ELX/<package>/AGENTS.md，填入對應內容。
     CLAUDE.md 為 symlink 指向 AGENTS.md（見 docs/INDUSTRY_PRACTICES_2026.md §8.1）。
     對應 source 必須先確認存在：ls $ELX_SRC/P_ELX/<package>/ -->

<一行說明此 package 的職責>。對應 source code 在 `$ELX_SRC/P_ELX/<package>/`。

## Commands

```bash
# 修改前必讀對應 SKILL
ls spec/skill/*_SKILL.md

# 找完整需求
ls spec/v2/SPEC_*.md

# 對應的 source code
ls $ELX_SRC/P_ELX/<package>/
```

## Boundaries

- **不要**改 `spec/archive/`——歷史版本，唯讀。
- **不要**自編行為——所有細節以 `spec/skill/` 為唯一真相。
- <!-- 填入此 package 專屬的 "改 X 之前必做 Y" 規則 -->

## Counterintuitive: <package> 領域陷阱

<!-- 只寫 AI 無法從 code 推出的反直覺規則（Non-Inferable Principle）。
     每條格式：**粗體標題**＋1–2 行說明。沒有反直覺規則就留空此節。 -->

1. **<標題>**
   <說明>

## 核心概念

| 詞 | 意義 |
|----|------|
| <!-- 填入 domain 術語 --> | |

## SKILL 索引

| SKILL 檔 | 對應 API / 功能 | 用途 |
|----------|----------------|------|
| <!-- 填入，格式參考 elecom_cloud_apps/AGENTS.md --> | | |

## 子套件（如有）

| 路徑 | 內容 |
|------|------|
| <!-- 填入子目錄與說明 --> | |

## Domain Knowledge（深入）

- 完整需求：`spec/v2/SPEC_*.md`
- API 細節：`spec/skill/*_SKILL.md`
- <!-- 其他補充文件 -->
