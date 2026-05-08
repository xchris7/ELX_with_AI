# AdminLink Event / Action ID Index

**用途**：集中索引 AdminLink agent 所用的 `act_id`（Action / Event ID）與 `rcid`（Remote Operation ID）。查號碼意義時直接讀此檔，避免 grep source。

**資料來源**：`wab-be187/P_ELX/elecom_cloud_apps/admlink/` 真實 source code（非 SPEC.xlsx）。SPEC 沒有集中表格，本檔由 source 抽出。

**最後更新**：2026-05-08（對應 wab-be187 source）

**真相層級**：source code > 本檔 > SPEC。本檔僅為查詢便利；source 改動時本檔需同步更新。

---

## §1 Action / Event ID Table（act_id）

所有事件的 `evt_id` 均為 `1`，差異化由 `act_id` 承擔（見 §3）。

| act_id | 觸發條件 | Source（act_id 行 / msg 行）| Message (JP) |
|---|---|---|---|
| **1050** | 系統冷啟動（`agstatus==isColdup`，`warm_start_tok=0`） | admlink_sm.c:165 / :175 | システムを開始しました。 |
| **1080** | LAN IP 變更（與 `CLOUD_ELECOM_AG_LASTIP_TOK` 不同） | admlink_sm.c:257 / :267 | IPアドレスが「X」から「Y」へ変更されました。 |
| **1090** | DNS 位址變更 | admlink_sm.c:291 / :301 | DNSアドレスが「X」から「Y」へ変更されました。 |
| **1100** | Default gateway 變更 | admlink_sm.c:330 / :340 | デフォルトゲートウェイが「X」から「Y」へ変更されました。 |
| **1120** | **FW 更新後 warm-up**（`agstatus==isFwRcWarmup\|\|isFwSysWarmup`，`warm_start_tok=3 or 4`，由 `admlink_msghdl.c:193` 設定） | admlink_sm.c:220 / :230 | ファームウェアのアップデートが実施されました。 |
| **1160** | 一般重開機 warm-up（`agstatus==isRcWarmup\|\|isSysWarmup`，`warm_start_tok=1 or 2`） | admlink_sm.c:195 / :205 | 再起動しました。 |
| **1170** | Factory reset 偵測 | admlink_ctrl_if.c:275 / :285 | 出荷時の状態へ初期化されました。 |
| **5060** | Agent 初始化完成（daemon 啟動） | admlink_sm.c:138 / :148 | エージェントによる初期化が実行されました。 |
| **5070** | 設定保存（remote control apply） | admlink_ctrl_if.c:314 / :324 | 設定が保存されました。 |
| **8010** | 遠端操作**成功**完成（`act_trg=rcid`） | admlink_msghdl.c:145 / :165 | `<rcid 名稱>` + 「が完了しました。」（見 §2 名稱）|
| **8020** | 遠端操作**失敗**完成（`act_trg=rcid`） | admlink_msghdl.c:145 / :165 | `<rcid 名稱>` + 「でエラーが発生しました。」 |
| **9010** | 測試通知（test event，由 ctrl_if 觸發） | admlink_ctrl_if.c:215 / :225 | テスト通知 |

### 額外 trigger 路徑

- **1170** 也會在 `admlink_sm.c:422` 出現 system_log（factory reset 偵測在 state machine 階段）
- **8010** 測試版本在 `admlink_ctrl_if.c:248`（msg `遠隔操作測試(<rcid>)完了しました`），與 production 8010 區分；production 來自 admlink_msghdl.c:145

### Warm-up 旗標（`CLOUD_TMP_WARM_START_TOK`）對應

| 值 | agstatus | act_id |
|---|---|---|
| 0 | isColdup | 1050 |
| 1 | isSysWarmup | 1160 |
| 2 | isRcWarmup | 1160 |
| 3 | isFwSysWarmup | 1120 |
| 4 | isFwRcWarmup | 1120 |

值由 `admlink_msghdl.c:181`（reboot=2）/ `:193`（FW update=4）寫入；其他由 `systemdaemon/configs/all_modules.c:217` 寫入 1。

---

## §2 Remote Operation IDs（rcid，對應 `act_trg`）

由 `admlink_msghdl.c` 的 `rc_hdl_tbl[]`（L56-91）與 `rcid2namejp()`（L94-130）定義。

| rcid | 名稱 (JP) | Handler | V2 only |
|---|---|---|---|
| **1010** | 遠隔操作「再起動」 | `admlink_reboot_rc` | — |
| **2010** | 遠隔操作「ファームウェアアップデート」 | `admlink_fwUpd_rc` | — |
| **3010** | 遠隔操作「I'm here」 | `admlink_imhere_rc` | — |
| **3030** | 遠隔操作「ステータス更新」 | `admlink_updsts_rc` | — |
| **4020** | 遠隔操作「ログのアップロード」 | `admlink_logfile_upld_rc` | — |
| **4030** | 遠隔操作「設定ファイルのアップロード」 | `admlink_cfgfile_upld_rc` | — |
| **4040** | 遠隔操作「接続クライアントファイルのアップロード」 | `admlink_cltfile_upld_rc` | — |
| **5010** | 遠隔操作「設定変更（遠隔操作許可）」 | `admlink_rcopt_rc` | — |
| **5020** | 遠隔操作「設定変更（設定ファイルアップロード許可）」 | `admlink_ucfgfile_opt_rc` | — |
| **5030** | 遠隔操作「設定変更（ログファイルアップロード許可）」 | `admlink_ulogfile_opt_rc` | — |
| **5040** | 遠隔操作「設定変更（接続クライアントファイルアップロード許可）」 | `admlink_ucltfile_opt_rc` | — |
| **5050** | 遠隔操作「設定変更（接続クライアントファイル自動アップロード間隔）」 | `admlink_set_intvl_ucltfile_rc` | — |
| **5060** | 遠隔操作「設定取得」 | `admlink_upload_config_rc` | ✅ |
| **5070** | 遠隔操作「設定変更」 | `admlink_remote_settings_rc` | ✅ |
| **5080** | 遠隔操作「設定復元」 | `admlink_restore_config_rc` | ✅ |
| **5090** | 遠隔操作「災害モード設定」 | `admlink_set_emergency_rc` | ✅ |

`V2 only` = 只在 `CFG_IS_ELECOM_ADMINLINK_V2` 編譯條件下生效。

---

## §3 evt_id

所有事件均使用 `evt_id=1`。事件類型差異由 `act_id` 區分，`evt_id` 不承擔語意。

`act_id` 屬性（從 source 的 `evt_id`/`act_sts`/`act_trg` 模式推測）：

- **1xxx**：系統狀態類事件（boot、reboot、IP 變更、reset…）
- **5xxx**：agent 操作或設定相關（init、setting save…）
- **8xxx**：遠端操作完成回報（與 rcid 配對，`act_trg=rcid`）
- **9xxx**：測試/驗證事件

（此分類為觀察結論，非 SPEC 明文。）

---

## §4 維護注意

1. **act_id 是內聯字面值**：source 內無 `#define ACT_ID_*` 或 enum，新增 act_id 時要記得更新本索引
2. **行號重新定位**：source 改動後，可用 `grep -n '"act_id\":N'` 在 admlink/ 三檔（`admlink_sm.c`、`admlink_ctrl_if.c`、`admlink_msghdl.c`）找新行號
3. **跨 package 觸發鏈**：1120/1160 涉及 `CLOUD_TMP_WARM_START_TOK`，寫入端在 `systemdaemon/configs/all_modules.c` 與 `admlink_msghdl.c`；查整條鏈時用 `grep -rn "CLOUD_TMP_WARM_START_TOK" wab-be187/P_ELX/{elecom_cloud_apps,systemdaemon}/`
4. **rcid 表新增**：必同步更新 `rc_hdl_tbl[]` 與 `rcid2namejp()` 兩處（同一檔）
