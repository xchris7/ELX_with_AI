# Zero Touch Setup Flow — 程式流程邏輯規範 (SPEC)

<!-- 原文：ゼロタッチ設定フロー — プログラムフローロジック仕様 (SPEC) -->

| 版本 Version | 更新日期 Date | 作者 Author | 說明 Description |
|--------------|---------------|-------------|------------------|
| v1.0 | 2026-03-11 | xchris7 | 初版建立，依據 Zero Touch Setup Flow 流程圖 / Initial version based on Zero Touch Setup Flow diagram |
| v1.1 | 2026-03-11 | xchris7 | 程式範例改為 C 語言 / Code examples changed to C language |
| v1.2 | 2026-03-11 | xchris7 | 附上流程圖、日文改寫為中英文並加入日文對照註解 / Added flow diagram, rewrote Japanese to Chinese and English with Japanese reference comments |
| v1.3 | 2026-03-11 | xchris7 | 依 SPEC_v1 補充 AGT.1.4 裝置註冊確認 API 詳細說明與 AGT.2.1 Agent 啟動邏輯 / Added AGT.1.4 registration confirmation API details and AGT.2.1 agent startup logic from SPEC_v1 |

---

## 📋 目的 / Purpose

<!-- 原文：目的 -->

本 SPEC 定義「Zero Touch Setup Flow」的完整程式流程邏輯，所有開發者與 GitHub Copilot 在每次新增或修改相關程式碼時，**必須依循本文件進行邏輯檢查**。

This SPEC defines the complete program flow logic for the "Zero Touch Setup Flow". All developers and GitHub Copilot **must follow this document for logic verification** whenever adding or modifying related code.

> ⚠️ 本專案使用 **C 語言**開發，所有程式範例皆以 C 語言撰寫。
> ⚠️ This project is developed in **C language**. All code examples are written in C.

---

## 🖼️ 原始流程圖 / Original Flow Diagram

<!-- 原文：ゼロタッチ設定フロー図 -->

> 以下為原始設計流程圖（ASCII 還原版），作為本 SPEC 所有邏輯判斷的依據來源。
> The following is the original design flow diagram (ASCII version), serving as the basis for all logic decisions in this SPEC.
> 📌 原始圖片檔請參閱 Repo 中的 `Zero_Touch_Flow.png` / For the original image file, see `Zero_Touch_Flow.png` in the repository.

```
■ ゼロタッチ設定フロー / Zero Touch Setup Flow
─────────────────────────────────────────────────────────────────────────────
[デバイス電源ON / Device power ON]
         │
         ▼
  ┌───────────────────────────┐
  │ レジストコードを保存している？ │  ← 原文：レジストコードを保存している？
  │ Registry Code stored?     │
  └───────────────────────────┘
       │                   │
  保存していない          保存している
  NO registry code      resist code exists
  (未保存)              (保存済み)
       │                   │
       ▼                   │
  [AGT.4.1.11]             │
  通常の起動フロー          │   ← 原文：通常の起動フロー（時刻同期できること）
  Normal startup flow      │
  (Must sync time)         │
       │                   │
       ▼                   │
  出荷時設定からの変更有無？      │   ← 原文：出荷時設定からの変更有無
  Settings changed from         │
  factory defaults?             │
    │           │               │
  変更あり    変更なし            │
  Changed    No change          │
    │           │               │
    │           ▼               │
    │    [4.3 ゼロタッチ待機]   │
    │    Zero Touch Standby ◄──┘
    │
    └──────────────────────────►
         │
         ▼
  [AGT.4.2.2]
  レジストコードとMACアドレスを指定して      ← 原文：レジストコードとMACアドレスを指定して
  「デバイス登録 API」をコールする            「デバイス登録 API」をコールする
  Call "Device Registration API"
  with resist code + MAC address
         │
    ┌────┴─────┐
    │          │
通信エラー    レスポンス確認
Comm. Error   Check Response
    │          │
   [END]   ┌───┴───┐
           │       │
         201     NOT 201
           │       │
           ▼       ▼
  [4.3 ゼロタッチ  レスポンスボディ確認
   待機処理]      Check Response Body
  Zero Touch      ← 原文：APIから返されたレスポンスボディ
  Standby         (仮登録状態かどうかを確認する)
               ┌──────┴───────┐
               │               │
       tmp_reg_expiry      tmp_reg_expiry
       NOT included          included
       (不存在)               (存在)
               │               │
               ▼               ▼
         [AGT.4.2.14]     [AGT.4.2.14]
         Device IDのみ     全登録情報を
         非揮発性メモリへ   非揮発性メモリへ
         Save Device ID    Save full reg info
         to NVRAM only     to NVRAM
         ← 原文：Device IDを含む、レスポンスボディで
                 返された登録情報を不揮発性メモリへ保存する

─────────────────────────────────────────────────────────────────────────────
■ 4.3 ゼロタッチ待機処理 / 4.3 Zero Touch Standby Processing
─────────────────────────────────────────────────────────────────────────────
  [AGT.4.3.1]
  遠隔操作受付開始                    ← 原文：遠隔操作の受付開始
  Start of Remote Operation Acceptance
         │
         ▼
  遠隔操作を受信？                    ← 原文：遠隔操作を受信？
  Received remote control?
    │                  │
  未受信               受信した
  Not received         Received
    │                  │
    ▼                  ▼
  出荷時設定           出荷時設定
  変更有無？           変更有無？
  Factory              Factory
  settings             settings
  changed?             changed?
    │       │            │        │
  変更なし 変更あり     変更なし  変更あり
  No chg  Changed      No chg   Changed
    │       │                     │
    ▼       ▼                     ▼
  仮登録   遠隔操作ID確認         遠隔操作ID確認
  有效期   Which Remote ID?       Which Remote ID?
  限內？   ← 原文：遠隔操作ID
    │   │     │           │
  期限内 期限外 5070     NOT 5070
  Within Exprd or 5080   or 5080
    │    │      │
    │   [END]   ▼
    ▼         [AGT.4.3.61]
  接続状況    遠隔操作の実行       ← 原文：遠隔操作の実行
  Conn.Status Execute Remote Op.
  ← 原文：接続状況  (Rmt Ctrl File Down Flow)
    │       │         │         │
  接続中   切断      失敗      成功
Connected Discon.  Failure   Success
    │               │         │
  [WAIT]           [ERR]   Perform Remote
                             Operation
                                 │
                                 ▼
                           [AGT.4.3.91]
                           登錄資訊を            ← 原文：登錄資訊を不揮發性メモリへ保存する
                           非揮發性メモリへ保存
                           Store reg info in
                           non-volatile memory
                                 │
                                 ▼
                           [AGT.4.3.96]
                           デバイスを再起動      ← 原文：デバイスを再起動
                           Reboot device

─────────────────────────────────────────────────────────────────────────────
■ AGT.2 AdminLink agent function
─────────────────────────────────────────────────────────────────────────────
  デバイス登録状態確認               ← 原文：デバイスの登録状態を確認する
  Check the device registration status
         │
  [AGT.2.1.21]
    │                  │
  未登録               登録済み
  NOT Registered       Registered
    │                  │
   [END]          [AGT.2.1.40]
                  ・定期処理開始        ← 原文：定期処理開始
                  ・遠隔操作受付開始    ← 原文：遠隔操作受付開始
                  Start periodical process.
                  Start remote control reception.
                        │
                        ▼
                  [End of function]
```

---

## 📐 流程總覽 / Flow Overview

<!-- 原文：フロー概要 -->

```
設備電源 ON / Device Power ON
  └─► 確認是否儲存 Registry Code / Check if Registry Code is stored
        ├─► 未儲存 / NOT stored (NO registry code exists)
        │     └─► 執行正常啟動流程 / Execute Normal Startup Flow (AGT.4.1.11)
        │           └─► 確認出廠設定是否有變更 / Check if settings changed from factory defaults
        │                 ├─► 有變更 Changed → 呼叫裝置註冊 API / Call Device Registration API
        │                 └─► 無變更 No change → 進入零觸控待機處理 / Enter Zero Touch Standby (4.3)
        └─► 已儲存 / Stored (resist code exists)
              └─► 呼叫裝置註冊 API / Call Device Registration API (AGT.4.2.2)
                    ├─► 通訊錯誤 / Communication Error → 重試 / Retry → 結束 / End
                    └─► 確認回應狀態碼 / Check Response Status
                          ├─► NOT 201 → 確認回應本文 / Check Response Body
                          │     ├─► tmp_reg_expiry 不存在 / NOT included
                          │     │     └─► 僅儲存 Device ID 至 NVRAM (AGT.4.2.14)
                          │     └─► tmp_reg_expiry 存在 / included
                          │           └─► 儲存完整註冊資訊至 NVRAM (AGT.4.2.14)
                          └─► 201 → 進入零觸控待機處理 / Enter Zero Touch Standby (4.3)
```

---

## 📌 第 1 節：設備啟動與 Registry Code 檢查 / Section 1: Device Startup and Registry Code Check

<!-- 原文：第1節：デバイス起動とレジストコード確認 -->

### AGT.4.1.11 — 正常啟動流程 / Normal Startup Flow

<!-- 原文：通常起動フロー -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 觸發條件 Trigger | 設備電源 ON，且**無** registry code 儲存 / Device power ON with **no** registry code stored <!-- 原文：デバイス電源 ON かつレジストコード未保存 --> |
| 前提條件 Precondition | 必須能夠進行時間同步 / Must be able to synchronize time <!-- 原文：時刻同期できること --> |
| 動作 Action | 執行正常啟動流程 / Execute normal startup flow <!-- 原文：通常起動フローを実行 --> |
| 後續判斷 Next | 確認出廠設定是否有變更 / Check if factory default settings have been changed <!-- 原文：出荷時設定からの変更有無を確認 --> |

**邏輯檢查 Checklist / Logic Check Checklist：**
<!-- 原文：ロジックチェックリスト -->

- [ ] 啟動時第一步必須檢查 registry code 是否存在 / At startup, the first step must check whether registry code exists <!-- 原文：起動時の最初のステップでレジストコードの存在を確認すること -->
- [ ] registry code 不存在時，**不得**直接呼叫 Device Registration API / When registry code does not exist, **must NOT** directly call Device Registration API <!-- 原文：レジストコードが存在しない場合、直接デバイス登録 API を呼び出してはならない -->
- [ ] 正常啟動流程中，時間同步失敗時必須有對應的錯誤處理 / Time sync failure during normal startup must have corresponding error handling <!-- 原文：通常起動フロー中に時刻同期が失敗した場合、対応するエラー処理が必要 -->
- [ ] 出廠設定檢查結果必須為二元判斷：「有變更 Changed」或「無變更 No change」 / Factory settings check result must be binary: "Changed" or "No change" <!-- 原文：出荷時設定確認の結果は「変更あり」または「変更なし」の二択であること -->

**✅ 正確範例 / Correct Example：**
```c
int startup_flow(void)
{
    int ret = 0;

    /* 第一步：確認 registry code 是否存在                          */
    /* Step 1: Check if registry code exists                        */
    /* 原文：レジストコードの存在確認（最初のステップ）             */
    if (check_registry_code() == REGISTRY_CODE_NOT_EXIST) {

        /* AGT.4.1.11: 執行正常啟動流程 / Execute normal startup flow */
        /* 原文：通常起動フローを実行                               */
        ret = normal_startup_flow();
        if (ret != 0) {
            log_error("normal_startup_flow failed: %d", ret);
            return ret;
        }

        /* 確認出廠設定是否有變更 / Check if factory default settings changed */
        /* 原文：出荷時設定からの変更有無を確認                     */
        if (check_factory_default_settings() == SETTINGS_CHANGED) {
            /* 有變更：呼叫裝置註冊 API / Changed: call Device Registration API */
            /* 原文：変更あり：デバイス登録 API を呼び出す          */
            ret = call_device_registration_api();
        } else {
            /* 無變更：進入零觸控待機 / No change: enter Zero Touch Standby */
            /* 原文：変更なし：ゼロタッチ待機処理へ移行             */
            ret = enter_zero_touch_standby_mode();
        }
    } else {
        /* AGT.4.2.2: registry code 已儲存，直接呼叫 API             */
        /* AGT.4.2.2: Registry code stored, call API directly        */
        /* 原文：レジストコードあり → 直接デバイス登録 API を呼び出す */
        ret = call_device_registration_api();
    }

    return ret;
}
```

**❌ 錯誤範例 / Wrong Example：**
```c
int startup_flow(void)
{
    /* ❌ 未檢查 registry code 直接呼叫 API                         */
    /* ❌ Calling API without checking registry code first           */
    /* 原文：レジストコードを確認せずに直接 API を呼び出している    */
    return call_device_registration_api();
}
```

---

## 📌 第 2 節：裝置註冊 API 呼叫 / Section 2: Device Registration API Call (AGT.4.2.2)

<!-- 原文：第2節：デバイス登録 API 呼び出し -->

### AGT.4.2.2 — 指定 Resist Code 與 MAC 位址呼叫裝置註冊 API / Call Device Registration API with Resist Code and MAC Address

<!-- 原文：レジストコードとMACアドレスを指定して「デバイス登録 API」をコールする -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 觸發條件 Trigger | registry code 已儲存，**或**出廠設定有變更 / Registry code stored **or** factory settings changed <!-- 原文：レジストコードあり、または出荷時設定に変更あり --> |
| 請求內容 Request | 指定 **Resist Code** + **MAC 位址** / Specify **resist code** + **MAC address** <!-- 原文：レジストコードと MAC アドレスを指定 --> |
| 成功回應 Success | HTTP 201 |
| 失敗路徑 1 Failure 1 | 通訊錯誤 / Communication Error <!-- 原文：通信エラー --> |
| 失敗路徑 2 Failure 2 | NOT 201 回應 / NOT 201 Response |

### 2.1 通訊錯誤處理 / Communication Error Handling

<!-- 原文：通信エラー処理 -->

**邏輯檢查 Checklist / Logic Check Checklist：**

- [ ] 網路通訊失敗必須捕捉錯誤，不得讓程式崩潰 / Network communication failure must be caught; program must not crash <!-- 原文：通信失敗時はエラーをキャッチし、プログラムがクラッシュしないこと -->
- [ ] 通訊錯誤時須記錄 log，並依據重試策略處理 / On communication error, log must be recorded and retry strategy applied <!-- 原文：通信エラー時はログを記録し、リトライ戦略に従って処理すること -->
- [ ] 不得無限重試，必須設定最大重試次數（`MAX_RETRY_COUNT`）/ Must not retry infinitely; max retry count (`MAX_RETRY_COUNT`) must be set <!-- 原文：無限リトライは禁止。最大リトライ回数（MAX_RETRY_COUNT）を設定すること -->

**✅ 正確範例 / Correct Example：**
```c
#define MAX_RETRY_COUNT  3  /* 最大重試次數 / Max retry count / 原文：最大リトライ回数 */

int call_device_registration_api(void)
{
    int   ret        = 0;
    int   retry      = 0;
    char  resist_code[RESIST_CODE_LEN];
    char  mac_addr[MAC_ADDR_LEN];

    /* 取得 Resist Code 與 MAC 位址 / Get resist code and MAC address */
    /* 原文：レジストコードと MAC アドレスを取得                    */
    get_resist_code(resist_code);
    get_mac_address(mac_addr);

    for (retry = 0; retry < MAX_RETRY_COUNT; retry++) {
        ret = api_post_device_register(resist_code, mac_addr);
        if (ret != ERR_COMMUNICATION) {
            /* 通訊成功 / Communication success                      */
            /* 原文：通信成功（HTTP レスポンスあり）                */
            break;
        }
        log_error("AGT.4.2.2: Communication error, retry %d/%d",
                  retry + 1, MAX_RETRY_COUNT);
    }

    if (ret == ERR_COMMUNICATION) {
        /* 所有重試均失敗 / All retries failed / 原文：全リトライ失敗 */
        log_error("AGT.4.2.2: All retries failed");
        return ERR_COMMUNICATION;
    }

    return handle_registration_response(ret);
}
```

**❌ 錯誤範例 / Wrong Example：**
```c
int call_device_registration_api(void)
{
    /* ❌ 無錯誤處理，未確認回傳值 / No error handling, return value not checked */
    /* 原文：エラー処理なし、戻り値も確認していない                */
    api_post_device_register(NULL, NULL);
    return 0;
}
```

### 2.2 回應狀態碼判斷 / Response Status Check

<!-- 原文：レスポンスステータス判定 -->

**邏輯檢查 Checklist / Logic Check Checklist：**

- [ ] 必須明確判斷 HTTP 狀態碼 / HTTP status code must be explicitly checked <!-- 原文：HTTP ステータスコードを明確に判定すること -->
- [ ] **201** → 進入零觸控待機處理 4.3 / Enter Zero Touch Standby 4.3 <!-- 原文：201 → ゼロタッチ待機処理 4.3 へ移行 -->
- [ ] **NOT 201** → 進入回應本文內容判斷 / Proceed to response body check <!-- 原文：201 以外 → レスポンスボディの内容確認へ -->
- [ ] 任何未預期的狀態碼必須記錄 log / Any unexpected status code must be logged <!-- 原文：想定外のステータスコードはログに記録すること -->

**✅ 正確範例 / Correct Example：**
```c
int handle_registration_response(int http_status)
{
    if (http_status == HTTP_STATUS_201) {
        /* 201: 進入零觸控待機模式 / Enter Zero Touch Standby mode  */
        /* 原文：201: ゼロタッチ待機モードへ移行                   */
        return enter_zero_touch_standby_mode();
    }

    /* NOT 201: 確認回應本文 / Check response body                  */
    /* 原文：201 以外: レスポンスボディを確認                       */
    log_info("handle_registration_response: status=%d, check body",
             http_status);
    return handle_non201_response();
}
```

### 2.3 回應本文判斷（NOT 201 時）/ Response Body Check (when NOT 201)

<!-- 原文：レスポンスボディ判定（201 以外の場合） -->

| 條件 Condition | 動作 Action | 對應規格 Spec |
|----------------|-------------|---------------|
| `tmp_reg_expiry` **不存在 / NOT included** | 僅儲存 Device ID 至 NVRAM / Save Device ID only to NVRAM <!-- 原文：Device ID のみ非揮発性メモリへ保存 --> | AGT.4.2.14 |
| `tmp_reg_expiry` **存在 / included** | 儲存完整註冊資訊（含 Device ID）至 NVRAM / Save full registration info (incl. Device ID) to NVRAM <!-- 原文：登録情報（Device ID 含む）を非揮発性メモリへ保存 --> | AGT.4.2.14 |

**邏輯檢查 Checklist / Logic Check Checklist：**

- [ ] 必須明確判斷 `tmp_reg_expiry` 欄位是否存在 / Must explicitly check whether `tmp_reg_expiry` field exists <!-- 原文：tmp_reg_expiry フィールドの有無を明確に判定すること -->
- [ ] 註冊資訊必須寫入**非揮發性記憶體（NVRAM）**，不得只存 RAM / Registration info must be written to **NVRAM**; RAM only is not acceptable <!-- 原文：登録情報は必ず非揮発性メモリへ保存すること（RAM のみは不可） -->
- [ ] 儲存失敗時必須輸出錯誤日誌並中斷處理 / On save failure, error log must be output and processing must be aborted <!-- 原文：保存失敗時はエラーログを出力し、処理を中断すること -->

**✅ 正確範例（AGT.4.2.14）/ Correct Example：**
```c
int handle_non201_response(void)
{
    int             ret  = 0;
    RESPONSE_BODY_T body;

    /* 解析回應本文 / Parse response body / 原文：レスポンスボディを解析 */
    ret = get_response_body(&body);
    if (ret != 0) {
        log_error("AGT.4.2.14: Failed to parse response body: %d", ret);
        return ret;
    }

    if (body.has_tmp_reg_expiry == TRUE) {
        /* tmp_reg_expiry 存在：儲存完整註冊資訊                    */
        /* tmp_reg_expiry included: save full registration info      */
        /* 原文：tmp_reg_expiry あり：全登録情報を保存              */
        ret = nvram_save_registration_info(&body.device_id,
                                           &body.tmp_reg_expiry);
    } else {
        /* tmp_reg_expiry 不存在：僅儲存 Device ID                  */
        /* tmp_reg_expiry NOT included: save Device ID only          */
        /* 原文：tmp_reg_expiry なし：Device ID のみ保存            */
        ret = nvram_save_device_id(&body.device_id);
    }

    if (ret != 0) {
        log_error("AGT.4.2.14: Failed to save to non-volatile memory: %d",
                  ret);
    }

    return ret;
}
```

**❌ 錯誤範例 / Wrong Example：**
```c
int handle_non201_response(void)
{
    RESPONSE_BODY_T body;
    get_response_body(&body);

    /* ❌ 未確認 tmp_reg_expiry，且只存 RAM（斷電後消失）           */
    /* ❌ tmp_reg_expiry not checked; stored in RAM only (lost on power-off) */
    /* 原文：tmp_reg_expiry の有無を確認せず、RAM にのみ保存（電源断で消える） */
    g_device_id = body.device_id;
    return 0;
}
```

---

## 📌 第 3 節：零觸控待機處理 / Section 3: Zero Touch Standby Processing (4.3)

<!-- 原文：第3節：ゼロタッチ待機処理 -->

### AGT.4.3.1 — 遠端操作受理開始 / Start of Remote Operation Acceptance

<!-- 原文：遠隔操作受付開始 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 觸發條件 Trigger | 進入零觸控待機處理 4.3 / Enter Zero Touch Standby Processing 4.3 <!-- 原文：ゼロタッチ待機処理 4.3 へ移行したとき --> |
| 功能 Function | 開始接受遠端控制 / Start accepting remote control <!-- 原文：遠隔操作の受付を開始する --> |

#### 3.1 遠端操作接收判斷 / Remote Control Reception Check

<!-- 原文：遠隔操作受信判定 -->

**流程樹 / Flow Tree：**
```
是否收到遠端操作？ / Received remote control?
  <!-- 原文：遠隔操作を受信したか？ -->
  ├─► 未收到 / Not received  <!-- 原文：未受信 -->
  │     └─► 確認出廠設定是否有變更 / Check if settings changed from factory defaults
  │           <!-- 原文：出荷時設定からの変更有無を確認 -->
  │           ├─► 無變更 / No change  <!-- 原文：変更なし -->
  │           │     └─► 臨時註冊是否在有效期限內？/ Within provisional registration period?
  │           │           <!-- 原文：仮登録有効期限内か？ -->
  │           │           ├─► 期限內 / Within period  <!-- 原文：期限内 -->
  │           │           │     └─► 確認連線狀態 / Check connection status
  │           │           │           <!-- 原文：接続状況を確認 -->
  │           │           │           ├─► 連線中 / Connected  <!-- 原文：接続中 -->
  │           │           │           └─► 已斷線 / Disconnected  <!-- 原文：切断 -->
  │           │           └─► 期限外 / Expired  <!-- 原文：期限外 -->
  │           │                 └─► 結束 / End
  │           └─► 有變更 / Changed  <!-- 原文：変更あり -->
  │                 └─► 確認遠端操作 ID / Check Remote Operation ID
  │                       <!-- 原文：遠隔操作 ID を確認 -->
  │                       ├─► 5070 or 5080 → 執行遠端操作 / Execute remote operation (AGT.4.3.61)
  │                       └─► NOT 5070 or 5080 → Remote ID 識別處理 / Remote ID identification
  └─► 已收到 / Received  <!-- 原文：受信した -->
        └─► 確認出廠設定是否有變更 / Check if settings changed from factory defaults
              <!-- 原文：出荷時設定からの変更有無を確認 -->
```

**邏輯檢查 Checklist / Logic Check Checklist：**

- [ ] 遠端操作 ID **5070** 與 **5080** 必須特別處理 / Remote operation IDs **5070** and **5080** must be handled specifically <!-- 原文：遠隔操作 ID 5070 と 5080 は必ず特別処理すること -->
- [ ] 非 5070/5080 的 Remote ID 必須有對應的識別邏輯 / Non-5070/5080 Remote IDs must have corresponding identification logic <!-- 原文：5070/5080 以外の Remote ID には対応する識別ロジックを実装すること -->
- [ ] 臨時註冊有效期限檢查必須在每次待機循環中執行 / Provisional registration expiry check must execute on every standby loop iteration <!-- 原文：仮登録有効期限チェックは待機ループの毎回実行すること -->
- [ ] 連線狀態（Connected / Disconnected）必須獨立判斷 / Connection status must be independently determined <!-- 原文：接続状況（接続中/切断）は独立して判定すること -->

**✅ 正確範例 / Correct Example：**
```c
#define REMOTE_ID_5070  5070  /* 特殊遠端操作 ID / Special remote op ID / 原文：特殊遠隔操作 ID */
#define REMOTE_ID_5080  5080  /* 特殊遠端操作 ID / Special remote op ID / 原文：特殊遠隔操作 ID */

int zero_touch_standby_loop(void)
{
    int ret       = 0;
    int remote_id = 0;

    while (1) {
        if (receive_remote_control(&remote_id) == REMOTE_NOT_RECEIVED) {
            /* 未收到遠端操作 / No remote control received           */
            /* 原文：遠隔操作未受信                                  */

            if (check_factory_default_settings() == SETTINGS_NO_CHANGE) {
                /* 無變更：確認臨時註冊有效期限                      */
                /* No change: check provisional registration expiry  */
                /* 原文：変更なし：仮登録有効期限を確認              */

                if (check_provisional_registration_expiry() == EXPIRY_EXPIRED) {
                    /* 期限外：結束待機迴圈 / Expired: exit standby loop */
                    /* 原文：期限外：ループ終了                      */
                    log_info("AGT.4.3.1: Provisional registration expired");
                    break;
                }

                /* 期限內：確認連線狀態並繼續待機                   */
                /* Within period: check connection status and continue */
                /* 原文：期限内：接続状況を確認して待機継続         */
                log_info("connection status: %d", get_connection_status());
                sleep(STANDBY_INTERVAL_SEC);
                continue;
            }

            /* 有變更：依 Remote ID 分支處理                         */
            /* Changed: branch by Remote ID                          */
            /* 原文：変更あり：Remote ID で分岐                     */
            if (remote_id == REMOTE_ID_5070 ||
                remote_id == REMOTE_ID_5080) {
                ret = execute_remote_operation(remote_id); /* AGT.4.3.61 */
            } else {
                ret = handle_other_remote_id(remote_id);
            }

        } else {
            /* 已收到遠端操作 / Remote control received              */
            /* 原文：遠隔操作受信                                    */
            ret = process_received_remote_control(remote_id);
        }

        if (ret != 0) {
            log_error("zero_touch_standby_loop: error %d", ret);
            break;
        }
    }

    return ret;
}
```

### 3.2 遠端操作執行 / Remote Operation Execution (AGT.4.3.61)

<!-- 原文：遠隔操作実行 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 操作方式 Method | 執行 Rmt Ctrl File Down Flow <!-- 原文：Rmt Ctrl File Down Flow を実行 --> |
| 成功 Success | → 執行 Perform Remote Operation <!-- 原文：成功 → Perform Remote Operation を実行 --> |
| 失敗 Failure | → 錯誤處理 / Error handling <!-- 原文：失敗 → エラー処理 --> |

**邏輯檢查 Checklist / Logic Check Checklist：**

- [ ] 遠端操作執行結果必須明確判斷成功/失敗 / Remote operation result must be explicitly determined as success/failure <!-- 原文：遠隔操作の実行結果は必ず成功/失敗を判定すること -->
- [ ] 成功後必須呼叫 `perform_remote_operation()` / After success, `perform_remote_operation()` must be called <!-- 原文：成功後は必ず perform_remote_operation() を呼び出すこと -->
- [ ] 失敗時必須記錄 log，不得靜默失敗 / On failure, log must be recorded; silent failure is not allowed <!-- 原文：失敗時はログを記録し、サイレント失敗を避けること -->

**✅ 正確範例 / Correct Example：**
```c
int execute_remote_operation(int remote_id)
{
    int ret = 0;

    /* AGT.4.3.61: 執行 Rmt Ctrl File Down Flow                     */
    /* AGT.4.3.61: Execute Rmt Ctrl File Down Flow                   */
    /* 原文：Rmt Ctrl File Down Flow を実行                         */
    ret = rmt_ctrl_file_down_flow(remote_id);
    if (ret != 0) {
        /* 失敗 / Failure / 原文：失敗                              */
        log_error("AGT.4.3.61: rmt_ctrl_file_down_flow failed: %d", ret);
        return ret;
    }

    /* 成功：執行 Perform Remote Operation                           */
    /* Success: Execute Perform Remote Operation                     */
    /* 原文：成功：Perform Remote Operation を実行                  */
    ret = perform_remote_operation(remote_id);
    if (ret != 0) {
        log_error("AGT.4.3.61: perform_remote_operation failed: %d", ret);
    }

    return ret;
}
```

### 3.3 註冊資訊儲存與設備重新啟動 / Save Registration Info and Reboot Device

<!-- 原文：登録情報保存とデバイス再起動 -->

| 步驟 Step | 規格編號 Spec ID | 動作 Action |
|-----------|-----------------|-------------|
| 1 | AGT.4.3.91 | 將註冊資訊儲存至 NVRAM / Save registration info to NVRAM <!-- 原文：登録情報を非揮発性メモリへ保存 --> |
| 2 | AGT.4.3.96 | 重新啟動設備 / Reboot device <!-- 原文：デバイスを再起動 --> |

**邏輯檢查 Checklist / Logic Check Checklist：**

- [ ] 儲存（AGT.4.3.91）必須在重啟（AGT.4.3.96）**之前**完成 / Save (AGT.4.3.91) must complete **before** reboot (AGT.4.3.96) <!-- 原文：登録情報保存（AGT.4.3.91）は必ず再起動（AGT.4.3.96）の前に完了すること -->
- [ ] 儲存失敗時不得執行重啟 / Reboot must not execute if save fails <!-- 原文：保存失敗時は再起動を実行しないこと -->
- [ ] 需確認 NVRAM 寫入完成後才重啟 / Must confirm NVRAM write completion before rebooting <!-- 原文：非揮発性メモリへの書き込み完了を確認してから再起動すること -->

**✅ 正確範例 / Correct Example：**
```c
int finalize_registration(void)
{
    int ret = 0;

    /* AGT.4.3.91: 先儲存註冊資訊 / Save registration info first    */
    /* 原文：先に登録情報を保存                                     */
    ret = nvram_save_registration_info_full();
    if (ret != 0) {
        /* 儲存失敗：中止重啟 / Save failed: abort reboot           */
        /* 原文：保存失敗：再起動を中止                             */
        log_error("AGT.4.3.91: Failed to save registration info: %d, "
                  "abort reboot", ret);
        return ret;
    }

    /* AGT.4.3.96: 確認儲存成功後才重啟 / Reboot after confirming save success */
    /* 原文：保存成功後に再起動                                     */
    log_info("AGT.4.3.96: Rebooting device");
    device_reboot();

    return 0;
}
```

**❌ 錯誤範例 / Wrong Example：**
```c
int finalize_registration(void)
{
    /* ❌ 未確認儲存結果直接重啟 / Rebooting without checking save result */
    /* 原文：保存結果を確認せずに再起動                             */
    nvram_save_registration_info_full();
    device_reboot();
    return 0;
}
```

---

## 📌 第 4 節：AdminLink Agent 功能 / Section 4: AdminLink Agent Function (AGT.2)

<!-- 原文：第4節：AdminLink エージェント機能 -->

### AGT.2.1 — Agent 啟動條件 / Agent Start Conditions

<!-- 原文：エージェント機能開始条件 -->

#### 4.0 啟動判斷 / Startup Decision (AGT.2.1.1)

<!-- 原文：エージェント機能開始 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 觸發條件 1 Trigger 1 | 設備啟動時 AdminLink 功能為「有效 Enabled」/ AdminLink function is "Enabled" at device startup <!-- 原文：デバイス起動時にアドミリンク機能が「有効」 --> |
| 觸發條件 2 Trigger 2 | Web UI 操作將 AdminLink 從「無效」改為「有效」/ AdminLink changed from Disabled to Enabled via Web UI <!-- 原文：Web UI 操作によりアドミリンク機能が無効から有効に変化 --> |
| 不啟動條件 No-start | AdminLink 功能為「無效 Disabled」時不啟動 Agent / Agent does not start when disabled <!-- 原文：アドミリンク機能が「無効」の場合エージェント機能は開始しない --> |

### AGT.2.1.21 — 確認裝置註冊狀態 / Check Device Registration Status

<!-- 原文：デバイス登録状態確認 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 動作 Action | 執行 AGT.1.4 的處理確認裝置登録狀態 / Execute AGT.1.4 process to check device registration status <!-- 原文：AGT.1.4 の処理を実行してデバイス登録状態を確認する --> |
| 判斷結果 1 Result 1 | **未登録 / NOT Registered** → 停止定期處理與遠端操作受理 / Stop periodical process and remote control reception <!-- 原文：未登録 → 定期処理と遠隔操作受付を停止 --> |
| 判斷結果 2 Result 2 | **登録済み / Registered** → 進入定期處理與遠端操作受理啟動 / Proceed to start periodical process and remote control reception <!-- 原文：登録済み → 定期処理・遠隔操作受付へ --> |
| 判斷結果 3 Result 3 | **確認中 / Checking** → 重試最多 6 次 / Retry up to 6 times <!-- 原文：確認中 → 最大 6 回リトライ --> |

#### 4.1 「確認中」狀態重試邏輯 / "Checking" State Retry Logic (AGT.2.1.30/31)

<!-- 原文：「確認中」状態のリトライ処理 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 觸發條件 Trigger | 登録狀態確認結果為「確認中」/ Registration status result is "Checking" <!-- 原文：確認中 --> |
| 重試次數 Retries | **最多 6 次 / Up to 6 times** <!-- 原文：最大6回 --> |
| 終止條件 Stop | 狀態變為非「確認中」，或已達最大重試次數 / Status becomes non-Checking, or max retries reached <!-- 原文：「確認中」以外のステータスになるか、最大リトライ回数に達するまで --> |

**邏輯檢查 Checklist：**

- [ ] 「確認中」狀態時**必須**重試，不得直接以「確認中」結束 / **Must** retry when "Checking"; must not end with "Checking" state <!-- 原文：「確認中」の場合は必ずリトライし、「確認中」のまま終了しないこと -->
- [ ] 重試次數上限為 **6 次**，不得無限重試 / Max retries is **6**; infinite retry is prohibited <!-- 原文：リトライ上限は 6 回。無限リトライ禁止 -->
- [ ] 每次重試結果必須記錄 log / Every retry result must be logged <!-- 原文：リトライ結果は必ずログに記録すること -->

**✅ 正確範例 / Correct Example：**
```c
#define AGT_REG_CHECK_MAX_RETRY  6   /* AGT.2.1.31: 最大重試次數 / 原文：最大リトライ回数 */

int check_registration_with_retry(REG_STATUS_T *out_status)
{
    int          retry  = 0;
    REG_STATUS_T status = REG_STATUS_CHECKING;

    for (retry = 0; retry <= AGT_REG_CHECK_MAX_RETRY; retry++) {
        /* AGT.2.1.21: 執行 AGT.1.4 登録確認 / Execute AGT.1.4 check */
        /* 原文：AGT.1.4 の処理を実行                               */
        status = check_device_registration_status_agt14();

        if (status != REG_STATUS_CHECKING) {
            /* 狀態已確定（非確認中）/ Status determined (not Checking) */
            /* 原文：「確認中」以外のステータスが確定                */
            break;
        }

        if (retry < AGT_REG_CHECK_MAX_RETRY) {
            /* AGT.2.1.31: 記錄 log 並繼續重試 / Log and continue retry */
            /* 原文：ログを記録してリトライ継続                      */
            log_info("AGT.2.1.31: Status is Checking, retry %d/%d",
                     retry + 1, AGT_REG_CHECK_MAX_RETRY);
        }
    }

    if (status == REG_STATUS_CHECKING) {
        log_info("AGT.2.1.31: Status still Checking after max retries");
    }

    *out_status = status;
    return 0;
}
```

**❌ 錯誤範例 / Wrong Example：**
```c
int check_registration_with_retry(REG_STATUS_T *out_status)
{
    /* ❌ 「確認中」時沒有重試，直接返回                            */
    /* ❌ No retry when "Checking"; returns immediately              */
    /* 原文：「確認中」の場合にリトライしていない                   */
    *out_status = check_device_registration_status_agt14();
    return 0;
}
```

---

### AGT.2.1.40 — 啟動定期處理與遠端操作受理 / Start Periodical Process and Remote Control Reception

<!-- 原文：定期処理・遠隔操作受付開始 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 觸發條件 Trigger | 已確認為已登録狀態後 / After confirming registered status <!-- 原文：登録済みが確認された後 --> |
| 動作 1 Action 1 | 啟動定期處理 / Start periodical process <!-- 原文：定期処理開始 --> |
| 動作 2 Action 2 | 開始接受遠端操作 / Start remote control reception <!-- 原文：遠隔操作受付開始 --> |
| 結束 End | End of function |

---

### AGT.2.1.50 — 未登録時停止處理 / Stop Processes When Unregistered (AGT.2.1.50)

<!-- 原文：未登録時の停止処理 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 觸發條件 Trigger | 登録狀態確認結果為「未登録」/ Registration status is "Unregistered" <!-- 原文：デバイス登録状態が「未登録」 --> |
| 動作 1 Action 1 | 若定期處理正在執行則停止 / Stop periodical process if running <!-- 原文：定期処理を実行している場合は停止する --> |
| 動作 2 Action 2 | 若正在接受遠端操作則停止 / Stop remote control reception if active <!-- 原文：遠隔操作を受け付けている場合は停止する --> |

**邏輯檢查 Checklist：**

- [ ] 必須先執行 AGT.2.1.21 確認登録狀態才能開始處理 / AGT.2.1.21 registration status check must precede all processing <!-- 原文：登録状態は必ず AGT.2.1.21 で確認してから処理を開始すること -->
- [ ] 未登録時**不得**啟動定期處理 / Periodical process must NOT start when not registered <!-- 原文：未登録時は定期処理を開始してはならない -->
- [ ] 已登録確認後，定期處理與遠端操作受理**兩者**都必須啟動 / After confirming registered, **both** periodical process and remote control reception must start <!-- 原文：登録済み確認後、定期処理と遠隔操作受付の両方を開始すること -->
- [ ] 未登録時若定期處理或遠端操作正在執行，**必須**先停止 / When unregistered, if periodical process or remote control is running, **must** stop them first <!-- 原文：未登録時に定期処理や遠隔操作が実行中なら必ず停止すること -->
- [ ] End of function 後不得增加任何處理 / No additional processing after End of function <!-- 原文：End of function 以降に追加処理を実装しないこと -->

**✅ 正確範例 / Correct Example：**
```c
int admin_link_agent_function(void)
{
    int          ret    = 0;
    REG_STATUS_T status = REG_STATUS_CHECKING;

    /* AGT.2.1.21 + 2.1.30/31: 確認登録狀態（含確認中重試）        */
    /* AGT.2.1.21 + 2.1.30/31: Check with Checking-state retry      */
    /* 原文：登録状態確認（確認中リトライ含む）                     */
    ret = check_registration_with_retry(&status);
    if (ret != 0) {
        return ret;
    }

    if (status == STATUS_NOT_REGISTERED) {
        /* AGT.2.1.50: 未登録 → 停止定期處理與遠端操作受理         */
        /* AGT.2.1.50: Unregistered → stop both processes            */
        /* 原文：未登録 → 定期処理と遠隔操作受付を停止             */
        stop_periodical_process();
        stop_remote_control_reception();
        return 0;
    }

    if (status == STATUS_REGISTERED) {
        /* AGT.2.1.40/41: 已登録 → 啟動定期處理與遠端操作受理      */
        /* AGT.2.1.40/41: Registered → start both processes          */
        /* 原文：登録済み → 定期処理と遠隔操作受付を開始           */
        ret = start_periodical_process();
        if (ret != 0) {
            log_error("AGT.2.1.40: start_periodical_process failed: %d",
                      ret);
            return ret;
        }
        ret = start_remote_control_reception();
        if (ret != 0) {
            log_error("AGT.2.1.40: start_remote_control_reception failed: %d",
                      ret);
            return ret;
        }
    }

    log_info("AdminLink agent function: End of function");
    return 0;
    /* ✅ 此後不得新增任何處理 / No further processing after this point */
    /* 原文：以降に処理を追加しないこと                              */
}
```

**❌ 錯誤範例 / Wrong Example：**
```c
int admin_link_agent_function(void)
{
    /* ❌ 未確認登録狀態直接啟動定期處理                           */
    /* ❌ Starting periodical process without checking registration status */
    /* 原文：登録状態を確認せずに定期処理を開始している            */
    start_periodical_process();
    start_remote_control_reception();
    return 0;
}
```

---

## 📌 第 5 節：裝置註冊確認 API / Section 5: Device Registration Confirmation API (AGT.1.4)

<!-- 原文：第5節：デバイス登録確認 Web API -->

### AGT.1.4 概述 / Overview

<!-- 原文：デバイス登録状態を確認できる事 -->

| 項目 Item | 規則 Rule |
|-----------|-----------|
| 目的 Purpose | 透過 Web API 確認設備在 AdminLink 服務的登録狀態 / Confirm device registration status on AdminLink service via Web API <!-- 原文：Web API をコールしてデバイス登録状態を確認する --> |
| Device ID | UUID Ver4 格式 / UUID Version 4 format <!-- 原文：デバイス ID は UUID Ver4 とする --> |
| Proxy 支援 | 若 Proxy 設定有效，必須透過 Proxy 呼叫 API / Must call API through proxy if proxy setting is enabled <!-- 原文：プロキシー設定が有効の場合プロキシー経由でコールする --> |

---

### 5.1 Device ID 取得與生成 / Device ID Acquisition and Generation (AGT.1.4.1/1.4.2)

<!-- 原文：デバイス ID 取得・生成 -->

| 條件 Condition | 動作 Action | 規格 Spec |
|----------------|-------------|-----------|
| NVRAM 中已有 Device ID / Device ID exists in NVRAM | 使用已有的 Device ID + MAC 位址呼叫 API / Use existing Device ID + MAC to call API <!-- 原文：保存済みデバイス ID と MAC アドレスを指定して API をコール --> | AGT.1.4.1 |
| NVRAM 中無 Device ID / No Device ID in NVRAM | 設定為「未登録」，不呼叫 API，輸出 log / Set to "Unregistered", do NOT call API, output log <!-- 原文：未登録とし、API をコールしない、ログ出力 --> | AGT.1.4.1.3 |

**邏輯檢查 Checklist：**

- [ ] 呼叫 API 前必須先確認 NVRAM 中是否有 Device ID / Must check NVRAM for Device ID before calling API <!-- 原文：API コール前に必ず NVRAM の Device ID 有無を確認すること -->
- [ ] Device ID 格式必須為 **UUID Ver4** / Device ID format must be **UUID Ver4** <!-- 原文：デバイス ID 形式は UUID Ver4 であること -->
- [ ] NVRAM 中無 Device ID 時，必須輸出 log / Must log when no Device ID in NVRAM <!-- 原文：NVRAM にデバイス ID がない場合はログを出力すること -->

---

### 5.2 MAC 位址選擇規則 / MAC Address Selection Rules (AGT.1.4.3)

<!-- 原文：複数MACアドレスを持つデバイスのMAC選択 -->

| 設備類型 Device Type | 使用的 MAC 位址 MAC Address to Use |
|---------------------|-------------------------------------|
| AP（無線 Access Point） | WAN 側（Internet 側）MAC 位址 / WAN (Internet side) MAC address <!-- 原文：WAN 側（Internet 側）の MAC アドレス --> |
| Switch | 系統 MAC 位址（Web UI 系統畫面顯示的） / System MAC address (shown on Web UI system screen) <!-- 原文：システム MAC アドレス（Web UI のシステム画面上に表示されるもの） --> |

> ⚠️ **注意 Note**：使用通信中的 LAN 埠 MAC 位址是**錯誤**的。/ Using the MAC address of the in-use LAN port is **WRONG**. <!-- 原文：通信中の LAN ポートの MAC アドレスは使用しないこと -->

---

### 5.3 回應狀態碼判斷 / Response Status Code Handling (AGT.1.4.10–1.4.52)

<!-- 原文：Web API レスポンスステータス判定 -->

| HTTP 狀態碼 / `dev_id_changed` | 登録狀態判定 Registration Status | 附加動作 Additional Action | 規格 Spec |
|-------------------------------|----------------------------------|---------------------------|-----------|
| **200** + `dev_id_changed = 0` | **登録済み / Registered** | 若 RAM 中 JSON 送信重試已停止（連續失敗 6 次），恢復重試 / Resume retry if stopped | AGT.1.4.10–1.4.13 |
| **200** + `dev_id_changed = 1` | **再登録可能 / Re-registerable** | 保留 response body 中的 `dev_id` 值 / Retain `dev_id` from response body | AGT.1.4.20–1.4.23 |
| **401** | **未登録 / Unregistered** | 若已持有 Device ID，必須**刪除** / Must **delete** held Device ID | AGT.1.4.30–1.4.33 |
| **200/401 以外 / Other** | **確認中 / Checking** | 記錄 log / Log result | AGT.1.4.40–1.4.42 |
| 無回應 / No response | **確認中 / Checking** | 記錄 log / Log result | AGT.1.4.50–1.4.52 |

**邏輯檢查 Checklist：**

- [ ] HTTP 狀態碼必須明確逐一判斷 / HTTP status must be explicitly checked one by one <!-- 原文：HTTP ステータスコードを明確に判定すること -->
- [ ] **200** 時必須進一步確認 `dev_id_changed` 旗標值 / When **200**, must further check `dev_id_changed` flag value <!-- 原文：200 の場合は dev_id_changed フラグを確認すること -->
- [ ] `dev_id_changed = 1` 時，必須保留 response body 中的 `dev_id` / When `dev_id_changed = 1`, must retain `dev_id` from response body <!-- 原文：dev_id_changed = 1 の場合、レスポンスボディの dev_id を保持すること -->
- [ ] **401** 時若持有 Device ID，必須**刪除** / When **401** and Device ID held, must **delete** it <!-- 原文：401 の場合、デバイス ID を保持していれば削除すること -->
- [ ] 所有回應情況都必須記錄 log / All response cases must be logged <!-- 原文：全レスポンスケースでログを記録すること -->
- [ ] 通訊錯誤（無回應）時狀態設為「確認中」/ On communication error (no response), set status to "Checking" <!-- 原文：通信エラー時は「確認中」とすること -->

**✅ 正確範例（AGT.1.4）/ Correct Example：**
```c
typedef enum {
    REG_STATUS_REGISTERED    = 0,
    REG_STATUS_REREGISTRABLE = 1,
    REG_STATUS_UNREGISTERED  = 2,
    REG_STATUS_CHECKING      = 3,
} REG_STATUS_T;

REG_STATUS_T check_device_registration_status_agt14(void)
{
    char         device_id[UUID_LEN];
    char         mac_addr[MAC_ADDR_LEN];
    int          has_device_id = 0;
    int          http_status   = 0;
    API_RESP_T   resp;
    REG_STATUS_T status = REG_STATUS_CHECKING;

    /* AGT.1.4.1: 確認 NVRAM 中是否有 Device ID                     */
    /* AGT.1.4.1: Check if Device ID exists in NVRAM                 */
    /* 原文：NVRAM にデバイス ID が保存されているか確認              */
    has_device_id = nvram_get_device_id(device_id);

    if (!has_device_id) {
        /* AGT.1.4.1.3: 無 Device ID → 未登録，不呼叫 API           */
        /* AGT.1.4.1.3: No Device ID → Unregistered, do NOT call API */
        /* 原文：デバイス ID なし → 未登録とし API をコールしない   */
        log_info("AGT.1.4.1.3: No Device ID in NVRAM, set Unregistered");
        return REG_STATUS_UNREGISTERED;
    }

    /* AGT.1.4.3: 依設備類型選擇正確的 MAC 位址                     */
    /* AGT.1.4.3: Select the correct MAC address by device type      */
    /* 原文：デバイスタイプに応じた MAC アドレスを使用              */
    get_wan_mac_address(mac_addr);   /* AP は WAN MAC / AP uses WAN MAC */

    /* AGT.1.4.4: 若 Proxy 有效，透過 Proxy 呼叫 / Via proxy if set */
    /* 原文：プロキシーが有効な場合はプロキシー経由でコール         */
    http_status = api_get_device_registration_confirm(device_id, mac_addr,
                                                       &resp);

    if (http_status == ERR_NO_RESPONSE) {
        /* AGT.1.4.50/51: 無回應 → 確認中 / No response → Checking  */
        /* 原文：レスポンスなし → 確認中                            */
        log_info("AGT.1.4.52: No response, set Checking");
        return REG_STATUS_CHECKING;
    }

    if (http_status == HTTP_STATUS_200) {
        if (resp.dev_id_changed == 0) {
            /* AGT.1.4.10/11: 200 + dev_id_changed=0 → 登録済み     */
            /* 原文：200 + dev_id_changed=0 → 登録済み              */
            log_info("AGT.1.4.12: Registered");
            /* AGT.1.4.13: 若 RAM 的 JSON 重試已停止，恢復           */
            resume_json_retry_if_stopped();
            status = REG_STATUS_REGISTERED;

        } else {
            /* AGT.1.4.20/21: 200 + dev_id_changed=1 → 再登録可能   */
            /* 原文：200 + dev_id_changed=1 → 再登録可能            */
            /* AGT.1.4.22: 保留 response body 中的 dev_id            */
            /* 原文：レスポンスボディの dev_id を保持する            */
            nvram_save_device_id_from_response(&resp.dev_id);
            log_info("AGT.1.4.23: Re-registerable, saved dev_id");
            status = REG_STATUS_REREGISTRABLE;
        }

    } else if (http_status == HTTP_STATUS_401) {
        /* AGT.1.4.30/31: 401 → 未登録                              */
        /* 原文：401 → 未登録                                       */
        /* AGT.1.4.32: 若有 Device ID 必須刪除                       */
        /* 原文：デバイス ID を保持している場合は削除すること        */
        nvram_delete_device_id();
        log_info("AGT.1.4.33: Unregistered (401), deleted Device ID");
        status = REG_STATUS_UNREGISTERED;

    } else {
        /* AGT.1.4.40/41: 其他狀態碼 → 確認中                       */
        /* 原文：200/401 以外 → 確認中                              */
        log_info("AGT.1.4.42: Unknown status %d, set Checking",
                 http_status);
        status = REG_STATUS_CHECKING;
    }

    return status;
}
```

**❌ 錯誤範例 / Wrong Example：**
```c
REG_STATUS_T check_device_registration_status_agt14(void)
{
    char       device_id[UUID_LEN];
    API_RESP_T resp;

    /* ❌ 未確認 NVRAM 是否有 Device ID 直接呼叫 API                */
    /* ❌ Calling API without checking NVRAM for Device ID           */
    /* 原文：NVRAM のデバイス ID を確認せずに API をコールしている  */
    api_get_device_registration_confirm(device_id, NULL, &resp);

    /* ❌ 未區分 dev_id_changed 旗標，統一判斷 200 為登録済み       */
    /* ❌ Not checking dev_id_changed flag; all 200 treated as Registered */
    /* 原文：dev_id_changed フラグを確認せずに 200 を登録済みと判断 */
    if (resp.http_status == HTTP_STATUS_200) {
        return REG_STATUS_REGISTERED;
    }
    return REG_STATUS_UNREGISTERED;
}
```

---

## 💬 向 GitHub Copilot 請求 SPEC 檢查的提示詞範例 / Prompt Examples for Requesting SPEC Check from GitHub Copilot

<!-- 原文：GitHub Copilot に SPEC チェックを依頼する際のプロンプト例 -->

在 Copilot Chat 中輸入以下內容 / Enter the following in Copilot Chat:
<!-- 原文：Copilot Chat に以下を入力してください -->

```
請依照 Zero_Touch_Flow SPEC 檢查以下 C 語言程式碼：
Please check the following C code against the Zero_Touch_Flow SPEC:

1. Registry Code 的確認順序是否正確？/ Is the Registry Code check order correct?
2. 裝置註冊 API 的呼叫條件是否符合？/ Are the Device Registration API call conditions met?
3. tmp_reg_expiry 的判斷邏輯是否正確？/ Is the tmp_reg_expiry logic correct?
4. NVRAM 儲存是否在重啟前執行？/ Is NVRAM save executed before reboot?
5. 所有函式回傳值是否已確認？/ Are all function return values checked?
6. AdminLink Agent 的註冊狀態確認是否在定期處理前執行？/ Is registration status check done before periodical process?
7. AGT.1.4: NVRAM 中無 Device ID 時是否直接設為未登録（不呼叫 API）？/ AGT.1.4: Is status set to Unregistered directly (no API call) when no Device ID in NVRAM?
8. AGT.1.4: HTTP 200 時是否有判斷 dev_id_changed 旗標？/ AGT.1.4: Is dev_id_changed flag checked for HTTP 200?
9. AGT.1.4: HTTP 401 時是否刪除現有 Device ID？/ AGT.1.4: Is Device ID deleted on HTTP 401?
10. AGT.2.1: MAC 位址不一致是否有觸發未登録邏輯？/ AGT.2.1: Does MAC address mismatch trigger Unregistered logic?
11. AGT.2.1: 「確認中」狀態是否有最多 6 次重試？/ AGT.2.1: Is there up to 6 retries for "Checking" state?
12. AGT.2.1: 未登録時是否停止定期處理與遠端操作受理？/ AGT.2.1: Are both processes stopped when Unregistered?

[貼上程式碼 / Paste your code here]
```

---

*本 SPEC 依據 Zero Touch Setup Flow 圖（原文：ゼロタッチ設定フロー）建立。*
*This SPEC was created based on the Zero Touch Setup Flow diagram (原文：ゼロタッチ設定フロー図)。*
*流程圖若有變更，請同步更新本文件。/ If the flow diagram changes, please update this document accordingly.*