#!/bin/sh
# =============================================================================
# iotcore_reconnect_test.sh
#
# 驗證 AdminLink daemon 在 IoT Core 斷線時「原地換 cert 重連、不 reload daemon」
# 的修正是否生效(NORMAL 與 ZERO-TOUCH 兩種模式皆適用)。
#
# 在「裝置」上以 root 執行(不是 build 機)。詳見同目錄 README.md。
#
# 做法:
#   1. /etc/hosts 把 IoT Core hostname 導到黑洞 IP  -> 之後每次「重連」都失敗
#   2. iptables DROP 掉目前真實 peer IP            -> 打斷「現有」這條 session
#   兩者都不碰 api.admin-link.net,所以 API 2.3(換 cert)仍打得通。
#   觀察 daemon 是否原地 refresh+reconnect、PID 不變、未 reload。
#
# 還原:cleanup() 為 idempotent,且掛在 trap(INT/TERM/EXIT);中途 Ctrl+C
#       也會把 iptables 規則與 /etc/hosts 還原乾淨。
# =============================================================================
set -u

# ----------------------------------------------------------------- 可調參數 --
MQTT_HOST="agi6e3leqqer1-ats.iot.ap-northeast-1.amazonaws.com"  # IoT Core endpoint(admlink_main.c 寫死)
BLACKHOLE_IP="192.0.2.1"            # TEST-NET-1,不可路由位址
BLOCK_SEC="${BLOCK_SEC:-240}"       # 封鎖觀察秒數;可用 `BLOCK_SEC=300 ./...` 覆寫
WATCH_SEC="${WATCH_SEC:-120}"       # 解封後等待重連的秒數
LOG="/tmp/admlink_debug.log"
HOSTS="/etc/hosts"
MARK="# iotcore-reconnect-test"     # 標記本工具加進 /etc/hosts 的那行,還原時據此精準移除

# ----------------------------------------------------------------- 內部狀態 --
HOSTS_EXISTED=0                     # 測試開始前 /etc/hosts 是否已存在
APPLIED_IPS=""                      # 本工具實際加了 DROP 的 IP 清單
CLEANED=0                           # cleanup 是否已執行(確保只跑一次)

# ----------------------------------------------------------------- 還原函式 --
cleanup() {
    [ "$CLEANED" = 1 ] && return
    CLEANED=1
    echo
    echo "--- 還原環境 ---"
    # (1) iptables:刪掉本工具加的每一條 DROP
    for ip in $APPLIED_IPS; do
        if iptables -D OUTPUT -d "$ip" -p tcp --dport 443 -j DROP 2>/dev/null; then
            echo "  iptables : 已移除 DROP $ip"
        fi
    done
    # (2) /etc/hosts:只移除帶 $MARK 的那一行(不動使用者原有內容)
    if [ -f "$HOSTS" ] && grep -q "$MARK" "$HOSTS" 2>/dev/null; then
        grep -v "$MARK" "$HOSTS" > "${HOSTS}.rt_tmp" 2>/dev/null
        cat "${HOSTS}.rt_tmp" > "$HOSTS"
        rm -f "${HOSTS}.rt_tmp"
        echo "  /etc/hosts: 已移除 black-hole 那行"
    fi
    # (3) 若 /etc/hosts 原本就不存在、現在又變空 -> 刪除,完全回到原狀
    if [ "$HOSTS_EXISTED" = 0 ] && [ -f "$HOSTS" ] && [ ! -s "$HOSTS" ]; then
        rm -f "$HOSTS"
        echo "  /etc/hosts: 原本不存在,已刪除(回到原狀)"
    fi
    echo "  還原完成。"
}
trap cleanup INT TERM EXIT

# ================================================================ 0. 前置 ===
echo "============================================================"
echo " AdminLink — IoT Core 斷線重連測試"
echo "============================================================"

PID=$(pidof admlink 2>/dev/null || true)
if [ -z "$PID" ]; then
    echo "ERR: admlink 沒在跑,先確認 daemon 已啟動。"
    exit 1
fi
echo "admlink PID = $PID"

# 0a. 判斷跑的是不是改修版(直接 grep 執行檔找 fix 專屬字串,免 md5 對照)
if grep -q "refresh credentials & reconnect" "/proc/$PID/exe" 2>/dev/null; then
    echo "binary      = 修改版 OK(含 refresh+reconnect 路徑)"
else
    echo "binary      = !! pristine —— 不含本次 fix"
    echo "              測試只會看到 daemon 終止 -> reload,屬 pristine 預期行為。"
    ans=n
    printf "              仍要繼續嗎? [y/N] "
    read ans 2>/dev/null || true
    [ "$ans" = y ] || [ "$ans" = Y ] || { echo "已中止。"; exit 1; }
fi

# 0b. 確認目前確實連著 IoT Core(沒有連線就沒東西可斷)
PEERS=$(netstat -tn 2>/dev/null | awk '/ESTABLISHED/ && $5 ~ /:443$/ { sub(/:443$/,"",$5); print $5 }' | sort -u)
if [ -z "$PEERS" ]; then
    echo "ERR: 目前沒有對外 :443 ESTABLISHED 連線 —— daemon 未連上 IoT Core。"
    echo "     先讓它連上再測。"
    exit 1
fi
echo "對外 :443 連線(將封鎖以打斷現有 session):"
for ip in $PEERS; do echo "    $ip"; done

LOG_AT_START=$(wc -l < "$LOG" 2>/dev/null || echo 0)

# ============================================ 1. 製造斷線(雙重封鎖)=======
echo
echo "--- 1. 封鎖 IoT Core(api.admin-link.net / API 2.3 不受影響)---"

# 1a. /etc/hosts 黑洞:讓「之後每一次重連」的 DNS 解析都導向不可路由位址
[ -f "$HOSTS" ] && HOSTS_EXISTED=1
echo "$BLACKHOLE_IP  $MQTT_HOST  $MARK" >> "$HOSTS"
RES=$(ping -c1 -w3 "$MQTT_HOST" 2>/dev/null | head -1)
echo "  /etc/hosts : $MQTT_HOST -> $BLACKHOLE_IP"
echo "  ping 驗證  : $RES"
case "$RES" in
    *"$BLACKHOLE_IP"*) echo "  -> /etc/hosts 生效" ;;
    *) echo "  -> !! /etc/hosts 似乎沒生效(此機 resolver 可能不吃 /etc/hosts);"
       echo "        結果可能不準,但仍繼續(iptables 那層仍會擋現有連線)。" ;;
esac

# 1b. iptables:DROP 掉現有 peer IP,打斷「現在這條」live session
for ip in $PEERS; do
    iptables -I OUTPUT -d "$ip" -p tcp --dport 443 -j DROP
    APPLIED_IPS="$APPLIED_IPS $ip"
done
echo "  iptables   : 已 DROP$APPLIED_IPS (tcp dport 443)"

# ============================================ 2. 觀察(封鎖期間)===========
echo
echo "--- 2. 封鎖中,觀察 ${BLOCK_SEC}s ---"
echo "  期望(修改版):log 反覆出現 'MQTT recv error; refresh credentials & reconnect.'"
echo "                 PID 全程 = $PID,且無 'AdminLink shutdown'"
t=0
while [ "$t" -lt "$BLOCK_SEC" ]; do
    sleep 20; t=$((t+20))
    NOW=$(pidof admlink 2>/dev/null || true)
    if [ "$NOW" != "$PID" ]; then
        echo "  t+${t}s  !! PID 改變:$PID -> $NOW(daemon 被 reload)"
    else
        echo "  t+${t}s  PID=$NOW(不變)"
    fi
done

# ============================================ 3. 解封 + 還原 ===============
echo
echo "--- 3. 解除封鎖 ---"
cleanup            # 明確呼叫;EXIT trap 之後因 CLEANED=1 不會再跑

# ============================================ 4. 確認重連成功 =============
echo
echo "--- 4. 等待重連(最多 ${WATCH_SEC}s)---"
t=0; RECONNECTED=0
while [ "$t" -lt "$WATCH_SEC" ]; do
    sleep 15; t=$((t+15))
    if netstat -tn 2>/dev/null | awk '/ESTABLISHED/ && $5 ~ /:443$/' | grep -q .; then
        echo "  t+${t}s  已重新連上 IoT Core,PID=$(pidof admlink 2>/dev/null || true)"
        RECONNECTED=1
        break
    fi
    echo "  t+${t}s  尚未連上..."
done

# ============================================ 5. 判定 =====================
echo
echo "============================================================"
echo " 結果"
echo "============================================================"
NEW=$(tail -n +"$((LOG_AT_START+1))" "$LOG" 2>/dev/null || true)
echo "--- 測試期間新增的 log ---"
echo "$NEW"
echo "--------------------------"

PID_END=$(pidof admlink 2>/dev/null || true)
SAW_REFRESH=0; SAW_RELOAD=0
echo "$NEW" | grep -q "refresh credentials & reconnect" && SAW_REFRESH=1
echo "$NEW" | grep -q "AdminLink shutdown"             && SAW_RELOAD=1

echo
if [ "$SAW_REFRESH" = 1 ] && [ "$SAW_RELOAD" = 0 ] && [ "$PID_END" = "$PID" ]; then
    echo "PASS  斷線時 daemon 原地 refresh+reconnect,PID 不變($PID),未 reload。"
elif [ "$SAW_RELOAD" = 1 ] || [ "$PID_END" != "$PID" ]; then
    echo "FAIL  daemon 被 reload(PID $PID -> $PID_END)。"
    echo "      binary 若為 pristine 屬預期;若為修改版需檢查。"
else
    echo "UNCERTAIN  未觀察到預期事件,可能封鎖沒打中、或 BLOCK_SEC 太短。"
    echo "           檢查上方 log,並確認步驟 1 的 ping 驗證是否生效。"
fi
if [ "$RECONNECTED" = 1 ]; then
    echo "      解封後已重新連上 IoT Core。"
else
    echo "      !! 解封後 ${WATCH_SEC}s 內尚未重連,請續看 $LOG。"
fi
echo "============================================================"
