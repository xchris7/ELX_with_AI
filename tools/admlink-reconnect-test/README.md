# admlink-reconnect-test — IoT Core Certificate Refresh and Reconnection Verification Tool

`iotcore_reconnect_test.sh`: Verifies on-device that the **AdminLink daemon in-place refreshes certificates and reconnects to IoT Core without reloading the daemon** when the connection is lost.

---

## 1. What is Being Verified

ELECOM's requirement (image.png / 40_receiver example, Mantis #12366/#13133): When IoT Core authentication information (client certificate, ~24h expiry) becomes invalid and causes a disconnection, the daemon should **re-call API 2.3 to refresh the certificate and reconnect to IoT Core**, not **reload the entire daemon**.

Corresponding source fixes (`$ELX_SRC/P_ELX/elecom_cloud_apps/admlink/`, edited in `~/ELX_with_AI/wab-be187`):

- `admlink_socket.c` — In `open_nb_socket()`, replace the 4 cert/TLS failure `exit_link/exit` calls with graceful returns (including `:219` handshake failure, `:237` x509 verify failure), preventing the process from terminating.
- `admlink_sm.c` — Add `iotcore_refresh_credentials()` (calls API 2.3 `get_endpoint_info()`, writes back to `/etc/iotcore*`, dev_id sourced **mode-aware**: ZERO-TOUCH reads `/tmp/temporary_dev_id` line 1, NORMAL reads dbox token); slow-path changes from `exit_link` to "refresh cert → `close_conn` → in-place reconnect via existing `check_mqrecv`", preserving "API 2.3 fails 3 times → fallback to `exit_link`" as final safety net.
- See [`spec/docs/mqtt_connection_model.md`](../../P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md) for trigger/state machine background.

**Pass = daemon PID unchanged after disconnection, log shows `refresh credentials & reconnect.`, no `reload_module("AdminLink")`.**

---

## 2. Test Methodology: Why "Dual Blocking"

To verify reconnection, three conditions must be met simultaneously:

| Requirement | Method | Reason |
|---|---|---|
| Break the **existing** MQTT session | `iptables -d <current peer IP> ... DROP` | Injecting a fake certificate won't affect the existing TLS session (certificate is only read during handshake); must actively terminate the existing connection |
| Make **every subsequent reconnection** fail | `/etc/hosts` routes IoT Core hostname to black hole IP `192.0.2.1` | AWS IoT endpoint polls multiple IPs; blocking a single IP allows daemon to reconnect via another IP; blocking at DNS layer blocks all reconnection attempts |
| Keep **API 2.3 reachable** | Both methods above target IoT Core host/IP only, **do not touch** `api.admin-link.net` | Refresh must succeed, so daemon can get new cert; blocking API too only tests the fallback reload |

> IoT Core and API 2.3 use **different hosts, same port 443** — can only differentiate by host/IP, not port. See [`mqtt_connection_model.md`](../../P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md) for details.

Expected daemon behavior during blocking: refresh succeeds (API reachable) → obtain new cert → but reconnection still fails (IoT Core blocked by `/etc/hosts`) → refresh again next cycle …… **continuous loop, PID unchanged, no reload**. After unblocking, next reconnection succeeds.

---

## 3. Prerequisites

- Run on **device** as **root** (not on build machine).
- Requires `iptables`, `netstat`, `ping`, `pidof`, `grep`, `awk` (built-in to busybox).
- Daemon currently **connected to** IoT Core (script checks this; no connection means nothing to break).
- Daemon log at `/tmp/admlink_debug.log`.
- Modified binary already deployed — script auto-checks via `grep /proc/<pid>/exe`; warns if pristine and asks to proceed.

---

## 4. Usage

```sh
# Copy to device (e.g., scp to /tmp), then:
chmod +x iotcore_reconnect_test.sh
./iotcore_reconnect_test.sh
```

Adjustable via environment variables:

```sh
BLOCK_SEC=300 ./iotcore_reconnect_test.sh   # blocking observation duration, default 240s
WATCH_SEC=180 ./iotcore_reconnect_test.sh   # wait time for reconnect after unblocking, default 120s
```

Script flow: `0 pre-checks → 1 dual block → 2 observe for BLOCK_SEC → 3 unblock and restore → 4 wait for reconnect → 5 verdict`.
Recommended: open another console and run `tail -F /tmp/admlink_debug.log` to monitor details.

---

## 5. Interpreting Results

Script prints `PASS / FAIL / UNCERTAIN` at the end. Cross-reference with log keywords:

| Log Keyword | Meaning |
|---|---|
| `MQTT recv error; refresh credentials & reconnect.` | **Modified slow-path triggered** — this line must appear |
| `bio_do_conect failed` | Reconnection attempt to black hole IP failed (normal to appear repeatedly during blocking) |
| `conn[N] closed` | `close_conn(mqrecv/mqupld)` after refresh success |
| `AdminLink shutdown` / `Zero Touch check flow` | **Full reload** — should NOT appear in PASS scenario |
| `set mqtt_subscribe ... ret is 1` | Re-subscription successful (should appear after unblocking) |

- **PASS**: `refresh credentials & reconnect.` appears, PID unchanged throughout, no `AdminLink shutdown`.
- **FAIL**: PID changed or `AdminLink shutdown` appears. If binary is pristine, this is expected; if modified, needs investigation.
- **UNCERTAIN**: Expected events not observed — usually blocking didn't hit (check step 1 ping verification) or `BLOCK_SEC` too short.

Both NORMAL and ZERO-TOUCH modes supported; in ZERO-TOUCH, refresh success also validates "mode-aware dev_id (reading `/tmp/temporary_dev_id`)" is correct.

---

## 6. Changes Made and How to Restore (Safety)

Script makes only two **reversible** changes:

1. **`/etc/hosts`** — appends a black hole record marked with `# iotcore-reconnect-test`.
2. **iptables OUTPUT** — adds `DROP tcp dport 443` rule for each existing peer IP.

Restoration handled by `cleanup()`:

- Attached to `trap ... INT TERM EXIT` — **even Ctrl+C mid-script triggers restoration**.
- **idempotent** — safe to call repeatedly.
- `/etc/hosts` uses **marked-line precise removal** (`grep -v "$MARK"`), leaving user content untouched; if file didn't exist and becomes empty after removal, entire file is deleted, returning to original state.
  (This fixes earlier bug: when device had no `/etc/hosts`, `cp` backup failed, leaving black hole line behind and preventing daemon from reconnecting.)

If script is forcibly interrupted (`kill -9`) before cleanup runs, manually restore:

```sh
# Remove /etc/hosts black hole line
grep -v 'iotcore-reconnect-test' /etc/hosts > /tmp/h && cat /tmp/h > /etc/hosts
[ -s /etc/hosts ] || rm -f /etc/hosts          # delete if originally didn't exist
# Clean up stray iptables rules
iptables -L OUTPUT -n --line-numbers | grep ':443'   # find line numbers, then iptables -D OUTPUT <n>
```

---

## 7. Known Limitations / Caveats

- **`/etc/hosts` must be consulted by resolver**: Script step 1 pings and displays whether it routes to `192.0.2.1`. If device has DNS cache (dnsmasq, etc.) that ignores `/etc/hosts`, it warns — daemon may still reconnect and test will be unreliable.
- **netstat peer assumption**: busybox `netstat` lacks `-p`; script assumes "outbound :443 ESTABLISHED" is admlink's MQTT connection. During idle this usually holds (API 2.3 is short-lived, normally absent); if another process coincidentally connects to :443, it gets briefly blocked too.
- **AWS IP polling**: This is why we block at DNS layer via `/etc/hosts`, not just by IP.
- Observation timing: MQTT keepalive 60s, disconnect detection to slow-path trigger takes ~1–3 minutes, `BLOCK_SEC` default 240s already includes margin; adjust higher for slow environments.

---

## 8. References

- Connection model background: [`P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md`](../../P_ELX/elecom_cloud_apps/spec/docs/mqtt_connection_model.md)
- API 2.3 spec: `P_ELX/elecom_cloud_apps/.claude/skills/adminlink-auth-info/SKILL.md`
- ZERO-TOUCH standby/reconnect spec: `P_ELX/elecom_cloud_apps/spec/current/SPEC_v2_AGT4_ZeroTouch.md` (AGT.4.3.50/.52 disconnect→reconnect, AGT.4.3.103 standby end returns to AGT.2.1.0)
- Source changes involved: `$ELX_SRC/P_ELX/elecom_cloud_apps/admlink/admlink_socket.c`, `admlink_sm.c`
