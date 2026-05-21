# AdminLink Daemon — IoT Core 斷線偵測與原地重連模型

> **類型**：source 推導的領域知識筆記(derived knowledge note)。
> **依據**：`$ELX_SRC/P_ELX/elecom_cloud_apps/admlink/` 的 `admlink_sm.c`、`admlink_socket.c`、`admlink_main.c`、`src/mqtt.c`(以 wab-be187 working copy 為準;行號為撰寫當下參考,以函式名為主)。
> **用途**：說明 daemon「如何**發現**斷線」與「如何**原地重連**不 reload」。規格衝突時以 `spec/current/` + EJ02 為準。
> **前置**：先讀 [`mqtt_connection_model.md`](mqtt_connection_model.md)(mqrecv / mqupld / API 2.3 的區分)。

---

## 1. 兩種「斷線」偵測難度天差地別

| 斷線型態 | 例子 | socket 行為 | daemon 多快發現 |
|---|---|---|---|
| **hard error** | 裝置 LAN 線拔掉、route 消失 | socket I/O 立即回 `EHOSTUNREACH` 等錯誤 | 幾秒內 |
| **half-open** | 上游 / router internet 斷,但裝置 LAN link 仍 up | 既有 TCP 連線**不會立即報錯**,送出的封包石沉大海;OS 一路重傳到 `tcp_retries2` 逾時(約 15–30 分鐘)才讓 socket 回錯 | **沒有 app 層看門狗的話 = 幾十分鐘** |

→ 「拔 router 網路」是 half-open。daemon **不能只靠 socket 報錯**,必須有 app 層的 liveness 偵測,否則一條死連線會被當成活的長達數十分鐘。

---

## 2. 偵測機制:兩個計數器,兩個階段(不是同一件事)

斷線復原是一條**有先後順序的管線**,由兩個獨立計數器分段負責。兩者**靠 `mqconn.status` 互斥**(同一時間只有一個在動)。

| | `mqtt_ping_request` / `mqtt_ping_request_not_reset` | `isMqttReceviedErr` |
|---|---|---|
| 宣告 | `mqtt_ping_request`:global,`src/mqtt.c`<br>`mqtt_ping_request_not_reset`:`static`,`admlink_sm.c` | `static`,`admlink_sm.c` |
| 何時動 | `mqtt_ping_request`:每送一個 PINGREQ +1、收到 PINGRESP 歸 0<br>`_not_reset`:`chk_agstatm` 每 tick,若有 ping 未回就 +1 | `check_mqrecv` **case 0**(status==0,每次重連嘗試)開頭 +1;**case 1**(已連上)歸 0 |
| 運作前提 | **只在 status==1**(自以為連著)才有意義 | **只在 status==0**(已斷、重連中)才會動 |
| 它回答 | 「這條**看似活著**的連線還有回應嗎?」 | 「我已經**連不回去**多久了?」 |
| 觸發動作 | `_not_reset >= 4`(約 90s)→ 判死、重連 | `> 2` → 呼叫 API 2.3 換 cert + 重連 |

### 兩階段管線

```
[status=1 連線中] ──連線悄悄死掉──> ping 看門狗 ~90s 偵測到 ──> 判死
        階段一:把「看似活著的死連線」(half-open) 判出來

──> status=0 ──> [status=0 重連中] ──重連一直失敗──> isMqttReceviedErr>2 ──> 換 cert
        階段二:判斷「連不回去」是否為持續性問題 → 觸發 API 2.3 換 cert
```

哪個先觸發取決於斷線時 daemon 的狀態:斷線發生在「連線中」→ 看門狗先;daemon 在「outage 期間才啟動」→ 一開始就 status==0,直接走 `isMqttReceviedErr`。**兩者互補,不是冗餘,不應合併。**

⚠️ **兩個計數器都分不出「IoT Core 斷」vs「internet 斷」** —— 它們只看到「MQTT 這條不通」。真正的區分藏在 `iotcore_refresh_credentials()` 打 API 2.3(另一個 host `api.admin-link.net`)的**成敗**:API 2.3 通 → internet 正常、是 IoT Core/cert 問題;API 2.3 也不通 → internet 全斷。

---

## 3. ⚠️ 反直覺:mode gating —— 看門狗曾經只在 NORMAL 模式跑

`chk_agstatm()` 內 90s ping 看門狗**原本**整段包在 `if(is_zero_touch_mode == ADMINLINK_NORMAL_MODE)` 裡。後果:**zero-touch 待機模式對 half-open 斷線完全無感**,只能枯等 OS TCP 逾時(數十分鐘)。

修正:看門狗已移出 mode gate,**兩模式共用**;只有 `admlink_fail_JSON_and_reSend`(NORMAL 專屬的失敗 JSON 重送)留在 gate 內。判斷某段邏輯該不該分模式時,原則是「**斷線復原(SPEC AGT.4.3.50/.52)兩模式都要;NORMAL 專屬上傳邏輯才 gate**」。

---

## 4. 原地重連如何發生(PID 不變)

`check_mqrecv()` 是個 `switch(status)` 狀態機:

- **case 0**(unconnected):呼叫 `open_nb_socket()` 重讀 `/etc/iotcore*` cert 檔 + 重新 connect/subscribe;成功 → `status=1`。
- **case 1**(connected):什麼都不做。

→ **任何把 `status` 設成 0 的動作,下一個 SM tick 就會自動原地重連**,PID 不變、不 reload。`close_conn()`(`admlink_main.c`)會釋放 BIO/關 fd 並把 `status=0`,是觸發重連的正規手段。

cert 檔是**每次 connect 才從磁碟讀**(不是 init 時快取),所以「換 cert 檔 → `close_conn` → 原地重連」即可吃到新 cert,**不需要 reload daemon**。

---

## 5. ⚠️ 反直覺:`close_conn` 該關幾條,看「原因影響到誰」

`chk_agstatm` 內不同情境關閉的連線範圍不同,**取決於觸發原因影響到哪幾條**:

| 情境 | 關閉範圍 | 原因 |
|---|---|---|
| 換 cert 成功(`iotcore_refresh_credentials()` 後) | **mqrecv + mqupld 兩條** | 兩條共用**同一組 cert 檔**;cert 一換,兩條都是舊憑證 |
| ping 看門狗逾時 | **只 mqrecv** | 此訊號只說明 mqrecv 死;mqupld 是 on-demand,有自己的生命週期 |
| mqupld idle 逾時 | 只 mqupld | mqupld 自身生命週期 |
| 單條 sync/connect 出錯(`ag_handle_clttraffic` / `check_mqupld`) | 出錯的那一條 | `close_conn(p)`,`p` 即出錯的 conn |

mqupld 即使被某情境漏關,也會被自己的 idle countdown(約 45s)或 in-flight 上傳的 sync error 收掉 —— **有上限、會自癒,不是 leak**。

---

## 6. ⚠️ 反直覺:daemon 何時自行終止、reload 不是「失敗」

### 6.1 運行中的 admlink 只在這些時機自行終止

`exit_link()`(`admlink_main.c`)是乾淨關閉包裝:deinit 控制介面 → `eloop_destroy` → `close_conn` 兩條 → `exit()`。

**正常終止(設計上就該終止):**

| 時機 | 路徑 | 退出碼 |
|---|---|---|
| 收到 **SIGTERM**(systemd / system_monitor / 使用者) | `handle_stop` → `exit_link` | 0 |
| 控制介面收到 **`stop` 指令** | `admlink_cmd_stop` → `eloop_set_exit` → `exit_link` | 0 |
| **zero-touch 暫時註冊窗到期** | `check_zero_touch_expiry` → `exit_link` | 1 |

前兩者是「真正的停止」。第三者是「計畫性換身分」—— 到期時 dev_id 由暫時換永久,daemon 必須結束讓 system_monitor 用新 dev_id 重啟(`cltid`/`topics` 在 `cfg_agInit` 依 dev_id 定版,原地續跑會用錯身分被 IoT Core 拒)。

**安全網(異常卡死才觸發):**

| 時機 | 路徑 |
|---|---|
| SIGTERM/SIGINT 後 10s 還沒關成功(eloop busy-loop) | `eloop_handle_alarm` → `exit(1)` |

**不會發生:**

- 網路斷線 / cert 過期 / API 2.3 連不到 → 一律原地重連、無限期重試,**不終止**(見 §1–§4、§6.2)。
- `agstatus==isErr → exit_link(1)`(`check_agstatus`)→ **死碼**,`isErr` 全 codebase 從未被賦值,永不觸發。
- 啟動階段 `cfg_agInit()` 失敗 → `main()` 走 cleanup 結束 process,但那是「還沒成功啟動」,不算運行中自我終止。

### 6.2 reload 機制與「為何不該靠它修斷線」

daemon `exit_link` 退出後,**`systemdaemon/system_monitor.c` 負責重啟**:每 60s 檢查 `FINDPROCID("admlink")`,發現死掉且符合條件(已註冊 / zero-touch 未到期、NTP 已同步)就 `reload_module("AdminLink")`(= `adminLink_close()` + `adminLink_open()`,PID 改變)。**有 30s grace,但無 backoff、無重試上限。**

→ 因此**不能拿 reload 當斷線修復手段**:internet 全斷時會變成「exit → 60s 後 reload → 又連不上 → 又 exit」的**無限 reload 迴圈**,而 reload 修不好「沒有網路」;每輪還丟掉 in-memory 訂閱、製造 60–90s 黑窗。

### 6.3 原則

可恢復的網路 / cert 問題 → **一律原地重連**(把 `status` 設 0,§4)。
只有三類才該結束 process:**① 明確停止(SIGTERM / `cmd_stop`) ② zero-touch 到期換身分 ③ 關閉流程卡死(安全網)**。

---

## 7. 重連計數器的兩個已知陷阱

1. **`isMqttReceviedErr` 在 `check_mqrecv` case 0 開頭就 +1,只在 case 1 歸 0** —— 「連線成功」的那個 tick 內它仍是高值(case 1 下一 tick 才進)。若同一 tick 後段的 slow-path `if(isMqttReceviedErr>2)` 沒防護,會在「剛重連成功」後立刻誤觸發、把剛建好的連線拆掉。**修正**:case 0 成功(`status=1`)的當下就把 `isMqttReceviedErr` 歸 0。

2. **把 `status` 設 0 但不 `close_conn`** —— `check_mqrecv` case 0 接著 `open_nb_socket` 會覆寫 `biofd`,**舊的 BIO/fd 沒人關 → fd 洩漏 + 殭屍 ESTABLISHED 連線**。看門狗判死務必用 `close_conn()`(它會釋放資源並自己設 `status=0`),不要寫裸 `status=0`。
## 8. 按時間序列的 Log 判讀範例

以下範例是「實際看 log 時的判讀模板」，重點不是每一行都必然出現，而是看整體時序與恢復模式。  
注意：單獨看到 `bio_do_conect failed: system lib` 仍不足以直接判成「拔線」或「cert 過期」；必須連同前後文一起看。

---

### 8.1 真拔線

**典型時序**

    T+0s
    syncerror: <mqtt_error>
    try to close conn[12]
    conn[12] closed

    T+15s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib

    T+30s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib

    T+45s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib
    [AdminLink] MQTT recv error; refresh credentials & reconnect.

    T+60s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib

    ...

    T+N  # 網路線插回後
    chkrecvconn:state is unconnected
    SSL Handshake done.
    conn is 14
    chkrecvconn:set mqtt_connect pak ret is 0
    set mqtt_subscribe to $aws/things/<devid>/shadow/update/accepted pak ret is 0

**判讀重點**

- 既有 MQTT 連線先很快在 `mqtt_sync()` 階段報錯，然後立即 `close_conn()`。
- 之後每個 SM tick 都在重連，但 TLS connect 一直失敗。
- 即使進入 `refresh credentials & reconnect` 慢路徑，仍然不會自癒。
- 必須等實體網路恢復後才重新握手成功。

**一句話判斷**

- 「先有 `syncerror`，後面一直 connect 失敗，直到插回線才好」 = 真拔線 / 全斷網路。

### 8.2 上游 half-open

**典型時序**

    T+0s
    # 上游 internet 斷，但 LAN link 仍為 up
    # 通常沒有立刻的 syncerror

    T+15s
    # 可能沒有明顯錯誤 log

    T+30s
    # 可能沒有明顯錯誤 log

    T+45s
    # 可能沒有明顯錯誤 log

    T+60s
    # 可能沒有明顯錯誤 log

    T+75s
    # 可能沒有明顯錯誤 log

    T+90s
    try to close conn[12]
    conn[12] closed
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib

    T+105s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib

    T+120s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib
    [AdminLink] MQTT recv error; refresh credentials & reconnect.

**判讀重點**

- 一開始不是立刻報 socket error，而是先安靜一段時間。
- 約 90 秒後，PING 看門狗才把 `mqrecv` 判死並主動 `close_conn()`。
- 之後才切換到「status=0 的重連失敗循環」。
- 這是「TCP 還假活著，但實際上封包到不了雲端」的典型樣子。

**一句話判斷**

- 「前面先沉默約 90 秒，之後才開始重連失敗」 = 上游 half-open。

### 8.3 client cert 過期

**典型時序**

    T+0s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib

    T+15s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib

    T+30s
    chkrecvconn:state is unconnected
    bio_do_conect failed: system lib
    [AdminLink] MQTT recv error; refresh credentials & reconnect.

    T+45s
    chkrecvconn:state is unconnected
    SSL Handshake done.
    conn is 17
    chkrecvconn:set mqtt_connect pak ret is 0
    set mqtt_subscribe to $aws/things/<devid>/shadow/update/accepted pak ret is 0

**判讀重點**

- 前三次失敗外觀上可能和斷網非常像，因為一樣會看到 `bio_do_conect failed: system lib`。
- 差別在於：進入 `refresh credentials & reconnect` 後，daemon 不需要重啟、不需要插回網路，就會自己恢復。
- 這表示 API 2.3 可達，新的 IoT Core cert 已重取並在下一次 connect 生效。

**一句話判斷**

- 「前面像 connect fail，但 refresh 後不靠外力自己恢復」 = client cert 過期。

### 8.4 快速判讀規則

| 觀察到的整體時序 | 優先判斷 |
|---|---|
| 先出現 `syncerror`，後面一路重連失敗，直到插回線才恢復 | 真拔線 / 全斷網路 |
| 前面先安靜約 90 秒，之後才開始重連失敗 | 上游 half-open |
| 出現 `bio_do_conect failed: system lib`，但進入 refresh 後自己恢復 | client cert 過期 |

### 8.5 注意事項

- 單獨一行 `bio_do_conect failed: system lib` 不能直接定性。
- 真正可用的是：
  1. 前面有沒有先出現 `syncerror`
  2. 失敗前是否先沉默約 90 秒
  3. 進入 `refresh credentials & reconnect` 後是否能自動恢復
- 這類長篇判讀脈絡與背景紀錄應集中維護在本文件；source 內只保留長期不變的實作 invariant，避免把歷史說明散落在 `admlink_socket.c` 等註解中。
- 若未來要把判斷精度再提高，應補：
  - API 2.3 `get_endpoint_info()` 成功 / 失敗 log
  - OpenSSL 完整 error stack 或 errno
  - PING watchdog 觸發當下的顯式 log

---

## 一句話總結

> daemon 真正難的不是「斷線後怎麼重連」(把 `status` 設 0 即可),而是「**怎麼及時發現** half-open 斷線」—— 靠 `mqtt_ping_request` 看門狗(~90s 判死)與 `isMqttReceviedErr`(連不回去 → 換 cert)兩階段管線,且兩者必須在 NORMAL 與 zero-touch 兩模式都運作。

**Cross-ref**：[`mqtt_connection_model.md`](mqtt_connection_model.md)、`spec/current/SPEC_v2_AGT4_ZeroTouch.md`(AGT.4.3.50/.52)、測試工具 `tools/admlink-reconnect-test/`、API 2.3 = `.claude/skills/adminlink-auth-info/SKILL.md`。
