# AGENTS.md — P_ELX/elecom_cloud_apps

AdminLink cloud agent 的 AI 知識層。對應 source code 在 `$ELX_SRC/P_ELX/elecom_cloud_apps/`（admlink daemon、libadmlink、config_manager）。

## Commands

```bash
# 修改前必讀對應 SKILL（API 2.X）
ls .claude/skills/

# 找完整需求（current 為現行；檔名仍保留 v2）
ls spec/current/SPEC_v2_AGT*.md

# 對應的 source code
ls $ELX_SRC/P_ELX/elecom_cloud_apps/{admlink,libadmlink,config_manager/{dbox_to_json,json_to_dbox}}/
```

## Boundaries

- **不要**改 `spec/archive/`——v1 / SPEC.xlsx 衍生品，唯讀。
- **不要**自編 API 行為——所有 API 細節以 `.claude/skills/<skill-name>/SKILL.md` 為唯一真相。
- **改 `admlink/admlink_socket.c` 之前**：先讀 `.claude/skills/` 內所有提及 `BIO_*` 的 SKILL，並理解 BIO 所有權移交陷阱（見下方反直覺第 2 條）。
- **新增 SKILL 檔**：必對應 SPEC.xlsx 已定義的 API。憑空造的「想像 API」不收。

## Counterintuitive: AdminLink 領域陷阱

1. **`dev_id_changed = 1` 不是錯誤，是「裝置被 factory reset 過」**
   API 回傳 `dev_id_changed=1` 代表此裝置之前已註冊、現在被重置——不是失敗，而是觸發 `re-registerable` 狀態。

2. **`BIO_push(sbio, cbio)` 後，cbio 的 ownership 已轉移**
   [`admlink_socket.c` 已知陷阱](https://www.openssl.org/docs/manmaster/man3/BIO_push.html)：之後若 `BIO_free_all(*bio)` 連 cbio 一起釋放，再 `BIO_free_all(cbio)` 會 double-free 把 daemon 殺掉。修改 SSL 連線程式碼前必確認此 invariant。

3. **`agt_daily_sec` 的 0 點是 22:00 不是 00:00**
   秒數 offset 從 22:00 起算到隔天 08:00，**不是從午夜起算**。`agt_upload_sec` 才是從 :00:00 起算的小時內 offset。混用會導致排程錯誤 10 小時。

4. **`sts_type` 三個值對應三種觸發來源，不是優先順序**
   `0=Periodic`（排程小時上傳）、`1=Event`（事件觸發）、`2=Optional`（手動）。**值的大小無意義**。

5. **API endpoints 的 4xx response code 各有獨特語意**
   `4002` 在 SPEC v2 仍 active（不是 deprecated，雖然某些 image 標示劃線）。錯誤碼語意以 `2_*_SKILL.md` 內 error table 為準，**不要**從 HTTP 慣例推測。

## AdminLink 核心概念

| 詞 | 意義 |
|----|------|
| `AdminLink` | Cloud 服務 (`api.admin-link.net`) |
| `Agent` | 裝置端 daemon (`admlink`) |
| `Device ID` | UUID v4，由裝置產生，所有 API 呼叫使用 |
| `Registration Code` | 9 碼 hex 註冊碼（`dev_reg_cd` 手動 / `regist_cd` 自動，**互斥**） |
| `dev_id_changed` | API 回應旗標：`1` = 裝置 factory reset 過（見上方反直覺 1） |
| `tmp_reg_expiry` | 暫時註冊過期時間（僅 Zero-touch flow） |

## 狀態機

```
Disabled ──(user enable)──> Unregistered
                                │
              ┌─────────────────┼─────────────────┐
              ▼                 ▼                 ▼
          Registered        Checking         re-registerable
       (201 / 200&dic=0)  (timeout/other)    (200 & dic=1)
              │                                   │
              └────────── factory reset ──────────┘
```

`dic` = `dev_id_changed`。完整 state 轉換見 `spec/current/SPEC_v2_AGT2_Agent.md`。

## SKILL 索引

| Slash Command | API | 用途 |
|---------------|-----|------|
| `/adminlink-register-device` | 2.2 `POST /v1/devices` | 裝置註冊（手動 / 自動兩模式） |
| `/adminlink-auth-info` | 2.3 Auth info 取得 | 取認證資訊 |
| `/adminlink-confirm-registration` | 2.4 註冊確認 | 確認註冊狀態 |
| `/adminlink-software-update` | 2.5 軟體更新查詢 | OTA 觸發 |
| `/adminlink-upload-url` | 2.6 Upload URL 取得 | 取上傳 pre-signed URL（注意 key 名為 `Success. upload_url`，含空白） |
| `/adminlink-upload-notify` | 2.7 上傳完成通知 | 配對 2.6 |
| `/adminlink-download-url` | 2.8 Download URL 取得 | 取下載 URL |
| `/adminlink-download-notify` | 2.9 下載完成通知 | 配對 2.8 |
| `/adminlink-unregister-device` | 2.10 `DELETE /v1/devices` | 解除註冊 |

API 呼叫流程：`2.2 → 2.3 → 2.4`（註冊三部曲），檔案傳輸 `2.6 ↔ 2.7` 與 `2.8 ↔ 2.9` 各自配對。

## In-Package Search Protocol（先看這張表，再決定動作）

問問題前先對照「問題類型 → 第一站」決策。第一站讀完通常就有答案；第二站才是 fallback grep source。

| 問題類型範例 | 第一站 | 第二站 |
|---|---|---|
| 「act_id N 是什麼 / 何時觸發」 | [`spec/docs/EVENT_ID_INDEX.md`](spec/docs/EVENT_ID_INDEX.md) | `grep "\"act_id\":N"` in `wab-be187/.../admlink/*.c` |
| 「Remote Operation ID（rcid）」 | [`spec/docs/EVENT_ID_INDEX.md`](spec/docs/EVENT_ID_INDEX.md) §2 | `admlink_msghdl.c` 的 `rc_hdl_tbl[]` / `rcid2namejp()` |
| 「API X 規格 / error code」 | `.claude/skills/<skill-name>/SKILL.md` | `spec/current/SPEC_v2_AGT*.md` |
| 「config 欄位 X 對應」 | [`config_manager/CLAUDE.md`](config_manager/CLAUDE.md) + `spec.json` | `config_manager/dbox_to_json/` source |
| 「狀態機 / 註冊流程」 | `spec/current/SPEC_v2_AGT2_Agent.md` State Machine | `admlink_sm.c` |
| 「JSON 共通格式」 | `spec/docs/JSON_Common_Specifications_EN.md` | — |
| 「Zero-touch 流程」 | `spec/current/SPEC_v2_AGT4_ZeroTouch.md` + `spec/docs/zero_touch_flowchart.mmd` | — |
| 「web 設定觸發 AdminLink 上傳」（跨 fcgibox）| `.claude/skills/<skill-name>/SKILL.md` | `wab-be187/P_ELX/fcgibox/modules/submit/elecom/` + `admlink_genmsg.c` |
| 「系統事件觸發 AdminLink event」（跨 systemdaemon）| `EVENT_ID_INDEX.md` 看 trigger 條件 | `wab-be187/P_ELX/systemdaemon/` 找對應 hook |

### Single-shot 搜尋慣用招式

```bash
# act_id / 常數值（限定 admlink/，不要遞迴整個 cloud_apps）
grep -n "1120" wab-be187/P_ELX/elecom_cloud_apps/admlink/*.c

# API 行為（先讀對應 SKILL，再對 source）
cat P_ELX/elecom_cloud_apps/.claude/skills/adminlink-<name>/SKILL.md

# 跨檔找函式定義（限定 admlink/）
grep -rn "function_name" wab-be187/P_ELX/elecom_cloud_apps/admlink/

# 追跨 package 觸發鏈：先在 admlink 找關鍵 token，再用 token 跨 package grep
grep -rn "CLOUD_TMP_WARM_START_TOK" wab-be187/P_ELX/{elecom_cloud_apps,fcgibox,systemdaemon}/
```

**精神**：grep 之前先想「這應該歸屬哪份索引文件？」有索引就讀索引，沒有再 fallback。跨 package 觸發鏈追蹤必須**先有具體 token / 函式名**才允許跨 package grep。

## 邏輯驗證流程（AI 用）

懷疑某 API 邏輯有問題，或需要驗證實作是否符合規格時，依序：

1. **讀對應 SKILL**：`.claude/skills/<skill-name>/SKILL.md`（或直接用上方 slash command）（規格真相、trigger conditions、error table）
2. **讀 source 實作**：`$ELX_SRC/P_ELX/elecom_cloud_apps/admlink/admlink_socket.c`（API 呼叫邏輯）
3. **對照狀態機**：`spec/current/SPEC_v2_AGT2_Agent.md` §State Machine（狀態轉換是否正確）
4. **若涉及 config payload**：讀 `config_manager/CLAUDE.md` §Field-level mapping rules（欄位對應是否正確）

**驗證結果輸出格式**：
- ✅ 符合規格：引用 SKILL 的對應段落
- ❌ 不符合：列出「SKILL 規格說 X，source 實作是 Y」，不要自行推測正確做法
- ⚠️ 無法確認：說明缺少哪個 context（SKILL？source？SPEC v2？）

## 子套件

| 路徑 | 內容 |
|------|------|
| `config_manager/` | **device 端 cloud config 契約**（Excel `_export_*` 衍生的機讀 spec + meta-schema）。`$ELX_SRC/.../config_manager/{dbox_to_json,json_to_dbox}/` source code 必須遵循。資料流：Excel → spec.json → source code 實作。**改 cloud UI 欄位 = 改 Excel → re-export spec.json → 跟著改兩側 source**。詳見 [`config_manager/CLAUDE.md`](config_manager/CLAUDE.md) §How source code uses this spec。 |

## Domain Knowledge（深入）

- 完整需求：`spec/current/SPEC_v2_AGT{1..4}_*.md`（4 大 part）
- API 細節（slash commands）：`.claude/skills/<skill-name>/SKILL.md`（含 trigger conditions、error tables）
- JSON 共通格式：`spec/docs/JSON_Common_Specifications_EN.md`
- Zero-touch flowchart：`spec/docs/zero_touch_flowchart.mmd`
- 截圖佐證：`spec/source_evidence/2.<N>.<name>/*.png`（各 SKILL 對應的原 SPEC.xlsx 截圖，保留在 spec/source_evidence/）
