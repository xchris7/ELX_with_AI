# AGENTS.md — P_ELX/elecom_cloud_apps

AdminLink cloud agent 的 AI 知識層。對應 source code 在 `$ELX_SRC/P_ELX/elecom_cloud_apps/`（admlink daemon、libadmlink、config_manager）。

## Commands

```bash
# 修改前必讀對應 SKILL（API 2.X）
ls spec/skill/2_*_SKILL.md

# 找完整需求（v2 為現行）
ls spec/v2/SPEC_v2_AGT*.md

# 對應的 source code
ls $ELX_SRC/P_ELX/elecom_cloud_apps/{admlink,libadmlink,config_manager/{dbox_to_json,json_to_dbox}}/
```

## Boundaries

- **不要**改 `spec/archive/`——v1 / SPEC.xlsx 衍生品，唯讀。
- **不要**自編 API 行為——所有 API 細節以 `spec/skill/2_<N>_*_SKILL.md` 為唯一真相。
- **改 `admlink/admlink_socket.c` 之前**：先讀 `spec/skill/` 內所有提及 `BIO_*` 的 SKILL，並理解 BIO 所有權移交陷阱（見下方反直覺第 2 條）。
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

`dic` = `dev_id_changed`。完整 state 轉換見 `spec/v2/SPEC_v2_AGT2_Agent.md`。

## SKILL 索引

| SKILL | API | 用途 |
|-------|-----|------|
| `2_2_device_registration_api_SKILL.md` | `POST /v1/devices` | 裝置註冊（手動 / 自動兩模式） |
| `2_3_auth_info_acquisition_api_SKILL.md` | Auth info 取得 | 取認證資訊 |
| `2_4_device_registration_confirmation_api_SKILL.md` | 註冊確認 | 確認註冊狀態 |
| `2_5_software_update_acquisition_api_SKILL.md` | 軟體更新查詢 | OTA 觸發 |
| `2_6_url_acquisition_file_upload_api_SKILL.md` | Upload URL 取得 | 取上傳 pre-signed URL（注意 key 名為 `Success. upload_url`，含空白） |
| `2_7_file_upload_completion_notification_api_SKILL.md` | 上傳完成通知 | 配對 2.6 |
| `2_8_url_acquisition_file_download_api_SKILL.md` | Download URL 取得 | 取下載 URL |
| `2_9_file_download_completion_notification_api_SKILL.md` | 下載完成通知 | 配對 2.8 |
| `2_10_device_unregistration_api_SKILL.md` | `DELETE /v1/devices` | 解除註冊 |

API 呼叫流程：`2.2 → 2.3 → 2.4`（註冊三部曲），檔案傳輸 `2.6 ↔ 2.7` 與 `2.8 ↔ 2.9` 各自配對。

## 子套件

| 路徑 | 內容 |
|------|------|
| `config_manager/` | **device 端 cloud config 契約**（Excel `_export_*` 衍生的機讀 spec + meta-schema）。`$ELX_SRC/.../config_manager/{dbox_to_json,json_to_dbox}/` source code 必須遵循。資料流：Excel → spec.json → source code 實作。**改 cloud UI 欄位 = 改 Excel → re-export spec.json → 跟著改兩側 source**。詳見 [`config_manager/CLAUDE.md`](config_manager/CLAUDE.md) §How source code uses this spec。 |

## Domain Knowledge（深入）

- 完整需求：`spec/v2/SPEC_v2_AGT{1..4}_*.md`（4 大 part）
- API 細節：`spec/skill/2_*_*_SKILL.md`（含 trigger conditions、error tables）
- JSON 共通格式：`spec/docs/JSON_Common_Specifications_EN.md`
- Zero-touch flowchart：`spec/docs/zero_touch_flowchart.mmd`
- 截圖佐證：`spec/skill/2.X.<name>/*.png`（各 SKILL 對應的原 SPEC.xlsx 截圖）
