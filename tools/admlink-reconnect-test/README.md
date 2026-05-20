# admlink-reconnect-test — IoT Core 斷線重連驗證工具

`iotcore_reconnect_test.sh`：在裝置上驗證 **AdminLink daemon 在 IoT Core 斷線時「原地換 cert 重連、不 reload daemon」** 的修正是否生效。

---

## 1. 它在驗證什麼

ELECOM 的需求(image.png / 40_receiver 範例、Mantis #12366/#13133）：IoT Core 的認證資訊（client cert，約 24h 過期）失效造成斷線時，daemon 應**重呼 API 2.3 換 cert + 與 IoT Core 再接続**，而**不是**整個 reload。

對應的 source 修正(`$ELX_SRC/P_ELX/elecom_cloud_apps/admlink/`，以 `~/ELX_with_AI/wab-be187` 為編輯目標）：

- `admlink_socket.c` — `open_nb_socket()` 內 cert/TLS 失敗的 4 個 `exit_link/exit` 改為 graceful return（含 `:219` handshake 失敗、`:237` x509 verify 失敗），不再讓 process 自殺。
- `admlink_sm.c` — 新增 `iotcore_refresh_credentials()`（呼叫 API 2.3 `get_endpoint_info()`、寫回 `/etc/iotcore*`，dev_id 來源 **mode-aware**：ZERO-TOUCH 讀 `/tmp/temporary_dev_id` 第 1 行、NORMAL 讀 dbox token）；slow-path 由 `exit_link` 改為「換 cert → `close_conn` → 既有 `check_mqrecv` 原地重連」，並保留「API 2.3 連 3 次失敗才 fallback `exit_link`」當最後 safety net。
- 觸發/狀態機背景見 [`spec/docs/mqtt_connection_model.md`](../../P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md)。

**通過 = 斷線後 daemon PID 不變、log 出現 `refresh credentials & reconnect.`、無 `reload_module("AdminLink")`。**

---

## 2. 測試原理：為什麼要「雙重封鎖」

斷線重連要能驗，必須同時做到三件事：

| 要 | 做法 | 為什麼 |
|---|---|---|
| 打斷**現有**這條 MQTT session | `iptables -d <現有 peer IP> ... DROP` | 注入假 cert 不會動到既有 TLS session（cert 只在 handshake 時讀）；要主動把現有連線弄斷 |
| 讓**之後每次重連**都失敗 | `/etc/hosts` 把 IoT Core hostname 導到黑洞 IP `192.0.2.1` | AWS IoT endpoint 會輪詢多個 IP，只封單一 IP，daemon 重連會換到別的 IP 又連上；改在 DNS 層攔截才擋得住所有重連 |
| 讓 **API 2.3 仍可達** | 上面兩者都只針對 IoT Core 的 host/IP，**不碰** `api.admin-link.net` | refresh 必須打得出去，daemon 才能換到新 cert；若連 API 也擋掉，只會測到 fallback reload |

> IoT Core 與 API 2.3 是**不同 host、同樣 443 port** —— 只能靠 host/IP 區分，不能靠 port。詳見 [`mqtt_connection_model.md`](../../P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md)。

封鎖期間 daemon 的預期行為：refresh 成功（API 通）→ 取得新 cert → 但重連仍失敗（IoT Core 被 `/etc/hosts` 黑洞）→ 下一輪再 refresh …… **持續迴圈、PID 不變、不 reload**。解封後下一次重連即接回。

---

## 3. 前置需求

- 在**裝置**上以 **root** 執行（不是 build 機）。
- 需要 `iptables`、`netstat`、`ping`、`pidof`、`grep`、`awk`（busybox 內建即可）。
- daemon 目前**已連上** IoT Core（腳本會檢查；沒有連線就沒東西可斷）。
- daemon log 在 `/tmp/admlink_debug.log`。
- 修改版 binary 已部署 —— 腳本會 `grep /proc/<pid>/exe` 自動判斷；若是 pristine 會警告並詢問是否續跑。

---

## 4. 用法

```sh
# 複製到裝置(例如 scp 到 /tmp),然後:
chmod +x iotcore_reconnect_test.sh
./iotcore_reconnect_test.sh
```

可用環境變數調整：

```sh
BLOCK_SEC=300 ./iotcore_reconnect_test.sh   # 封鎖觀察時長,預設 240s
WATCH_SEC=180 ./iotcore_reconnect_test.sh   # 解封後等待重連時長,預設 120s
```

腳本流程：`0 前置檢查 → 1 雙重封鎖 → 2 觀察 BLOCK_SEC → 3 解封還原 → 4 等待重連 → 5 判定`。
建議另開一個 console 同步 `tail -F /tmp/admlink_debug.log` 看細節。

---

## 5. 如何判讀結果

腳本最後印 `PASS / FAIL / UNCERTAIN`。對照 log 關鍵字:

| log 關鍵字 | 意義 |
|---|---|
| `MQTT recv error; refresh credentials & reconnect.` | **修正版 slow-path 觸發** —— 要看到這行 |
| `bio_do_conect failed` | 重連嘗試到黑洞 IP 失敗（封鎖期間正常會反覆出現） |
| `conn[N] closed` | refresh 成功後 `close_conn(mqrecv/mqupld)` |
| `AdminLink shutdown` / `Zero Touch check flow` | **整包 reload** —— PASS 情境下不該出現 |
| `set mqtt_subscribe ... ret is 1` | 重新訂閱成功（解封後應出現） |

- **PASS**：`refresh credentials & reconnect.` 有出現、PID 全程不變、無 `AdminLink shutdown`。
- **FAIL**：PID 改變或出現 `AdminLink shutdown`。若 binary 是 pristine 屬預期；若是修改版需檢查。
- **UNCERTAIN**：未觀察到預期事件 —— 多半是封鎖沒打中（看步驟 1 的 ping 驗證）或 `BLOCK_SEC` 太短。

NORMAL 與 ZERO-TOUCH 兩種模式都適用；ZERO-TOUCH 下 refresh 成功即同時驗證了「mode-aware dev_id（讀 `/tmp/temporary_dev_id`）」正確。

---

## 6. 它改動什麼、如何還原（安全性）

腳本只做兩種**可還原**的改動：

1. **`/etc/hosts`** —— 附加一行帶標記 `# iotcore-reconnect-test` 的黑洞紀錄。
2. **iptables OUTPUT** —— 對現有 peer IP 各加一條 `DROP tcp dport 443`。

還原由 `cleanup()` 負責，且：

- 掛在 `trap ... INT TERM EXIT` —— **即使中途 Ctrl+C 也會還原**。
- **idempotent** —— 重複呼叫安全。
- `/etc/hosts` 採**標記行精準移除**（`grep -v "$MARK"`），不動使用者原有內容；若該檔原本不存在、移除後變空，會把整個檔刪掉，完全回到原狀。
  （這修正了早期版本的 bug：原機沒有 `/etc/hosts` 時 `cp` 備份失效，導致黑洞那行殘留、daemon 一直連不回。）

若腳本被強制中斷（`kill -9`）未跑到 cleanup，手動還原：

```sh
# 移除 /etc/hosts 黑洞那行
grep -v 'iotcore-reconnect-test' /etc/hosts > /tmp/h && cat /tmp/h > /etc/hosts
[ -s /etc/hosts ] || rm -f /etc/hosts          # 原本不存在就刪掉
# 清掉殘留 iptables 規則
iptables -L OUTPUT -n --line-numbers | grep ':443'   # 找出 line number 後 iptables -D OUTPUT <n>
```

---

## 7. 已知限制 / 注意事項

- **`/etc/hosts` 須被 resolver 採用**：腳本步驟 1 會 `ping` 驗證並顯示是否導向 `192.0.2.1`。若此機有 DNS cache（dnsmasq 等）不吃 `/etc/hosts`，會警告 —— 此時 daemon 重連可能仍連得上、測不準。
- **netstat 抓 peer 的假設**：busybox `netstat` 無 `-p`，腳本以「對外 :443 ESTABLISHED」當作 admlink 的 MQTT 連線。閒置時這通常成立（API 2.3 是短命連線、平常不在）；若剛好有其他程式在連 :443，會被一併短暫封鎖。
- **AWS IP 輪詢**:正因如此才用 `/etc/hosts` 攔 DNS,而非單純封 IP。
- 觀察時間：MQTT keepalive 60s，斷線偵測到 slow-path 觸發約需 1–3 分鐘，`BLOCK_SEC` 預設 240s 已含餘裕；環境慢可調大。

---

## 8. 參照

- 連線模型背景：[`P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md`](../../P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md)
- API 2.3 規格：`P_ELX/elecom_cloud_apps/.claude/skills/adminlink-auth-info/SKILL.md`
- ZERO-TOUCH 待機/重連規格：`P_ELX/elecom_cloud_apps/spec/current/SPEC_v2_AGT4_ZeroTouch.md`（AGT.4.3.50/.52 斷線→重連、AGT.4.3.103 待機結束才回 AGT.2.1.0）
- 修正涉及的 source：`$ELX_SRC/P_ELX/elecom_cloud_apps/admlink/admlink_socket.c`、`admlink_sm.c`
