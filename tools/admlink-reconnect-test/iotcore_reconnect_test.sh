#!/bin/sh
# =============================================================================
# iotcore_reconnect_test.sh
#
# Verifies that AdminLink daemon in-place refreshes certificates and reconnects
# to IoT Core without reloading the daemon when the connection is lost
# (applies to both NORMAL and ZERO-TOUCH modes).
#
# Run as root on device (not on build machine). See README.md in same directory.
#
# Method:
#   1. /etc/hosts routes IoT Core hostname to black hole IP   -> all subsequent "reconnects" fail
#   2. iptables DROP blocks current real peer IP              -> breaks "current" session
#   Neither touches api.admin-link.net, so API 2.3 (cert refresh) still reaches.
#   Observe whether daemon in-place refresh+reconnect, PID unchanged, no reload.
#
# Restoration: cleanup() is idempotent and attached to trap(INT/TERM/EXIT); Ctrl+C
#              mid-script also cleanly restores iptables rules and /etc/hosts.
# =============================================================================
set -u

# --------------------------------------------------------- tunable parameters --
MQTT_HOST="agi6e3leqqer1-ats.iot.ap-northeast-1.amazonaws.com"  # IoT Core endpoint (hardcoded in admlink_main.c)
BLACKHOLE_IP="192.0.2.1"            # TEST-NET-1, non-routable address
BLOCK_SEC="${BLOCK_SEC:-240}"       # blocking observation duration in seconds; override with `BLOCK_SEC=300 ./...`
WATCH_SEC="${WATCH_SEC:-120}"       # wait time in seconds for reconnection after unblocking
LOG="/tmp/admlink_debug.log"
HOSTS="/etc/hosts"
MARK="# iotcore-reconnect-test"     # marks the line this tool adds to /etc/hosts, used for precise removal during restoration

# ------------------------------------------------------------ internal state --
HOSTS_EXISTED=0                     # whether /etc/hosts existed before test started
APPLIED_IPS=""                      # list of IPs this tool actually added DROP rules for
CLEANED=0                           # whether cleanup() has run (ensures it runs only once)

# ---------------------------------------------------- restoration function --
cleanup() {
    [ "$CLEANED" = 1 ] && return
    CLEANED=1
    echo
    echo "--- Restoring environment ---"
    # (1) iptables: remove each DROP rule this tool added
    for ip in $APPLIED_IPS; do
        if iptables -D OUTPUT -d "$ip" -p tcp --dport 443 -j DROP 2>/dev/null; then
            echo "  iptables  : removed DROP $ip"
        fi
    done
    # (2) /etc/hosts: remove only the line with $MARK (preserve user content)
    if [ -f "$HOSTS" ] && grep -q "$MARK" "$HOSTS" 2>/dev/null; then
        grep -v "$MARK" "$HOSTS" > "${HOSTS}.rt_tmp" 2>/dev/null
        cat "${HOSTS}.rt_tmp" > "$HOSTS"
        rm -f "${HOSTS}.rt_tmp"
        echo "  /etc/hosts : removed black-hole line"
    fi
    # (3) if /etc/hosts didn't exist originally and is now empty -> delete it, fully restore to original state
    if [ "$HOSTS_EXISTED" = 0 ] && [ -f "$HOSTS" ] && [ ! -s "$HOSTS" ]; then
        rm -f "$HOSTS"
        echo "  /etc/hosts : didn't exist originally, deleted (restored to original state)"
    fi
    echo "  Restoration complete."
}
trap cleanup INT TERM EXIT

# ======================================================= 0. Pre-checks ===
echo "============================================================"
echo " AdminLink — IoT Core Disconnection and Reconnection Test"
echo "============================================================"

PID=$(pidof admlink 2>/dev/null || true)
if [ -z "$PID" ]; then
    echo "ERR: admlink is not running; ensure daemon is started first."
    exit 1
fi
echo "admlink PID = $PID"

# 0a. determine if running modified version (grep executable for fix-specific string, avoid md5 comparison)
if grep -q "refresh credentials & reconnect" "/proc/$PID/exe" 2>/dev/null; then
    echo "binary      = modified version OK (contains refresh+reconnect path)"
else
    echo "binary      = !! pristine —— does not contain this fix"
    echo "              test will only see daemon termination -> reload, expected pristine behavior."
    ans=n
    printf "              continue anyway? [y/N] "
    read ans 2>/dev/null || true
    [ "$ans" = y ] || [ "$ans" = Y ] || { echo "aborted."; exit 1; }
fi

# 0b. confirm currently connected to IoT Core (no connection = nothing to break)
PEERS=$(netstat -tn 2>/dev/null | awk '/ESTABLISHED/ && $5 ~ /:443$/ { sub(/:443$/,"",$5); print $5 }' | sort -u)
if [ -z "$PEERS" ]; then
    echo "ERR: no outbound :443 ESTABLISHED connections —— daemon not connected to IoT Core."
    echo "     connect first, then test."
    exit 1
fi
echo "Outbound :443 connections (will block to break current session):"
for ip in $PEERS; do echo "    $ip"; done

LOG_AT_START=$(wc -l < "$LOG" 2>/dev/null || echo 0)

# ======================== 1. Create disconnection (dual blocking) =========
echo
echo "--- 1. Block IoT Core (api.admin-link.net / API 2.3 unaffected) ---"

# 1a. /etc/hosts black hole: route all subsequent DNS resolutions to non-routable address
[ -f "$HOSTS" ] && HOSTS_EXISTED=1
echo "$BLACKHOLE_IP  $MQTT_HOST  $MARK" >> "$HOSTS"
RES=$(ping -c1 -w3 "$MQTT_HOST" 2>/dev/null | head -1)
echo "  /etc/hosts : $MQTT_HOST -> $BLACKHOLE_IP"
echo "  ping test  : $RES"
case "$RES" in
    *"$BLACKHOLE_IP"*) echo "  -> /etc/hosts active" ;;
    *) echo "  -> !! /etc/hosts may not be active (device resolver may ignore /etc/hosts);"
       echo "        results may be unreliable, but continuing (iptables layer still blocks current session)." ;;
esac

# 1b. iptables: DROP current peer IP to break the live session
for ip in $PEERS; do
    iptables -I OUTPUT -d "$ip" -p tcp --dport 443 -j DROP
    APPLIED_IPS="$APPLIED_IPS $ip"
done
echo "  iptables   : dropped$APPLIED_IPS (tcp dport 443)"

# ========================= 2. Observe (during blocking) ====================
echo
echo "--- 2. Blocking, observe for ${BLOCK_SEC}s ---"
echo "  Expected (modified version): log repeatedly shows 'MQTT recv error; refresh credentials & reconnect.'"
echo "                               PID constant = $PID, no 'AdminLink shutdown'"
t=0
while [ "$t" -lt "$BLOCK_SEC" ]; do
    sleep 20; t=$((t+20))
    NOW=$(pidof admlink 2>/dev/null || true)
    if [ "$NOW" != "$PID" ]; then
        echo "  t+${t}s  !! PID changed: $PID -> $NOW (daemon reloaded)"
    else
        echo "  t+${t}s  PID=$NOW (unchanged)"
    fi
done

# ========================= 3. Unblock and restore =========================
echo
echo "--- 3. Unblock ---"
cleanup            # explicit call; EXIT trap won't re-run because CLEANED=1

# ========================= 4. Confirm reconnection ========================
echo
echo "--- 4. Wait for reconnection (max ${WATCH_SEC}s) ---"
t=0; RECONNECTED=0
while [ "$t" -lt "$WATCH_SEC" ]; do
    sleep 15; t=$((t+15))
    if netstat -tn 2>/dev/null | awk '/ESTABLISHED/ && $5 ~ /:443$/' | grep -q .; then
        echo "  t+${t}s  reconnected to IoT Core, PID=$(pidof admlink 2>/dev/null || true)"
        RECONNECTED=1
        break
    fi
    echo "  t+${t}s  waiting for reconnection..."
done

# ========================= 5. Verdict ================================
echo
echo "============================================================"
echo " Results"
echo "============================================================"
NEW=$(tail -n +"$((LOG_AT_START+1))" "$LOG" 2>/dev/null || true)
echo "--- Log entries added during test ---"
echo "$NEW"
echo "--------------------------"

PID_END=$(pidof admlink 2>/dev/null || true)
SAW_REFRESH=0; SAW_RELOAD=0
echo "$NEW" | grep -q "refresh credentials & reconnect" && SAW_REFRESH=1
echo "$NEW" | grep -q "AdminLink shutdown"             && SAW_RELOAD=1

echo
if [ "$SAW_REFRESH" = 1 ] && [ "$SAW_RELOAD" = 0 ] && [ "$PID_END" = "$PID" ]; then
    echo "PASS  daemon in-place refresh+reconnect on disconnection, PID unchanged ($PID), no reload."
elif [ "$SAW_RELOAD" = 1 ] || [ "$PID_END" != "$PID" ]; then
    echo "FAIL  daemon reloaded (PID $PID -> $PID_END)."
    echo "      if binary is pristine, this is expected; if modified, needs investigation."
else
    echo "UNCERTAIN  expected events not observed, blocking may have missed, or BLOCK_SEC too short."
    echo "           check log above, confirm step 1 ping verification succeeded."
fi
if [ "$RECONNECTED" = 1 ]; then
    echo "      reconnected to IoT Core after unblocking."
else
    echo "      !! did not reconnect within ${WATCH_SEC}s after unblocking, check $LOG."
fi
echo "============================================================"
