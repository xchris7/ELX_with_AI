# AdminLink Daemon — IoT Core / MQTT 連線模型

> **類型**：source 推導的領域知識筆記(derived knowledge note)。
> **依據**：`$ELX_SRC/P_ELX/elecom_cloud_apps/admlink/` 的 `admlink_main.c`、`admlink_sm.c`、`admlink_socket.c`(以 wab-be187 為準,行號為撰寫當下參考,以函式名為主)。
> **用途**：釐清兩個常見誤解,供日後 review。規格衝突時以 `spec/current/` + EJ02 為準。

---

## 1.「IoT Core 連線」和「MQTT 連線」是同一條東西

不是二選一,是同一條連線的不同層次:

| 名詞 | 它是什麼 |
|---|---|
| **AWS IoT Core** | 雲端的服務 / MQTT broker。端點:`agi6e3leqqer1-ats.iot.ap-northeast-1.amazonaws.com` |
| **MQTT** | 裝置連到 IoT Core 所用的**協定** |
| 傳輸 | **MQTT over TLS,port 443**,ALPN = `x-amzn-mqtt-ca`(AWS「MQTT 走 443」模式;見 `admlink_socket.c` `alpnclt`、`admlink_main.c` `cfg_agInit()` 的 `port="443"`) |

→「連到 IoT Core」≡「那條 MQTT 連線」。一個是目的地、一個是交通工具,不是兩種連線。

⚠️ **與 API 2.3 區分**:API 2.3(認證資訊取得)是**另一條連線** —— HTTPS 到 `api.admin-link.net`(或 `CLOUD_SERVER_URL_TOK`),**不是** IoT Core。兩者**同樣 443**,差別在 **host**。用 iptables 做網路隔離測試時,只能靠 host(IP)區分,不能靠 port。

---

## 2. daemon 內有兩條 MQTT-to-IoT-Core 連線:mqrecv 與 mqupld

兩條都連**同一個** IoT Core 端點、都是 MQTT over TLS,但角色、生命週期不同。在 `cfg_agInit()`(`admlink_main.c`)初始化。

| | `p->mqrecv` | `p->mqupld` |
|---|---|---|
| 用途 | **接收**遠控指令(待機 / 受診待ち) | **上傳**狀態 / 事件 JSON |
| Client ID | `<devid>` | `<devid>_uploader` |
| Topic | sub `$aws/things/<devid>/shadow/update/accepted` | pub `devices/<devid>_uploader/message` |
| **連線形態** | **常駐**:連一次、長期掛著 | **on-demand**:要送才連,閒置 timeout 就斷 |
| 維護邏輯 | `check_mqrecv()`,`chk_agstatm()` 每個 SM tick 巡檢 | `check_mqupld()` 按需呼叫;`chk_agstatm()` 內 `mqupld idle timeout → close_conn` |
| log 關鍵字 | `chkrecvconn:...`、`set mqtt_subscribe to $aws/things/...` | `chkupldconn:...`、`mqupld on-demand:...` |

⚠️ 兩條的 **Client ID 必須不同**,否則 AWS IoT Core 會踢掉重複 ID(見 `agent_cloud_linkage_flow/INDEX.md` Rule 3)。

### 「定期」這個詞要用對

- **mqrecv 不是「定期連線」,是「常駐連線」**。定期發生的是 SM 的**巡檢**(每 tick 呼叫 `check_mqrecv` 看還在不在、斷了才重連),連線本身是一條長壽連線。mqrecv 只在出問題時才主動斷(90s ping 無回應 reset、credential refresh),沒有排程性的定期重連。
- **mqupld 是 on-demand**:連→送→閒置→斷。觸發它的「上傳」雖然有排程(`agt_upload_sec` 每小時定期狀態上傳 + 事件觸發),但**連線形態仍是按需**——「定期」形容的是上傳排程,不是連線。

---

## 3. 怎麼判斷眼前看到的是哪一條

- **看 log 前綴 / topic**:`chkrecvconn` 或 `$aws/things/.../shadow/update/accepted` → **mqrecv**;`mqupld on-demand` 或 `chkupldconn` → **mqupld**。
- **不要靠 fd 號碼**:`conn[7]` / `conn[8]` 只是 OS 當下分配的,重啟會重排。判斷靠 log 前綴或 topic。
- **`ss -tnp` 分不出來**:兩條都連同一個 AWS host:443,peer 位址相同。只能靠「常駐那條 = mqrecv;時有時無那條 = mqupld」,或比對 local port 與 log。

---

## 一句話總結

> 「IoT Core 連線」就是「MQTT 連線」。daemon 真正要區分的是 **mqrecv(常駐、收遠控)** 與 **mqupld(on-demand、送狀態)** 兩條 MQTT-to-IoT-Core 連線,以及它們和 **API 2.3(HTTPS 到 api.admin-link.net)** 這條完全不同的連線。
