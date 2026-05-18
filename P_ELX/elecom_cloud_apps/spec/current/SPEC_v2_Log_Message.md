# AdminLink Log Message Specification Reference
**Version:** v2.00 DRAFT  
**Date:** 2025-11-11  
**Source:** EJ100_AdminLinkRequestSpecifications_APSW_v2.00Draft_20251111.xlsx

> **Note:** Regardless of the language setting on device, display ENGLISH MESSAGE as log message.  
> **Web API Error Common Format:** `error_id=%d, error_msg=%s, error_field=%s, error_value=%s`

---

## AGT.1 — Device Registration Management

### AGT.1.4 — Device Registration Status Check

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.1.4.1.3 | Information | `[AdminLink] No device ID. AdminLink service unregistered.` |
| AGT.1.4.12 | Information | `[AdminLink] Device registration result : Registered` |
| AGT.1.4.23 | Information | `[AdminLink] Device registration result : Unregistered (re-registered enabled)` |
| AGT.1.4.33 | Information | `[AdminLink] Device registration result : Unregistered` |
| AGT.1.4.42 | Error | `[AdminLink] Device registration result : Error（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.1.4.52 | Error | `[AdminLink] Device registration result : Communication error` |

**Trigger conditions:**
- `AGT.1.4.12`: Response status 200 & `dev_id_changed=0` (already registered)
- `AGT.1.4.23`: Response status 200 & `dev_id_changed=1` (can be re-registered)
- `AGT.1.4.33`: Response status 401 (unregistered)
- `AGT.1.4.42`: Response status other than 200 or 401
- `AGT.1.4.52`: Cannot call Web API due to communication error

---

### AGT.1.5 — Device Registration to AdminLink Service

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.1.5.12 | Information | `[AdminLink] Device registration succeeded` |
| AGT.1.5.12 | Debug | `[AdminLink] agt_upload_sec=%d, agt_daily_sec=%d` |
| AGT.1.5.12.4 | Error | `[AdminLink] AdminLink agent disabled because of Initialization failure. Enable again after rebooted.` |
| AGT.1.5.22 | Error | `[AdminLink] Device registration failed（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.1.5.32 | Error | `[AdminLink] Communication error occurred while registering device` |

**Trigger conditions:**
- `AGT.1.5.12`: Response status 201 (registration succeeded)
- `AGT.1.5.12.4`: Failed to delete unsent old JSON data
- `AGT.1.5.22`: Response status other than 201
- `AGT.1.5.32`: Cannot call Web API due to communication error

---

### AGT.1.6 — Remove Device Registration

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.1.6.11 | Information | `[AdminLink] Deleted device registration` |
| AGT.1.6.22 | Information | `[AdminLink] Failed to delete registration device（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.1.6.32 | Error | `[AdminLink] Communication error occurred while deleting registration device` |

**Trigger conditions:**
- `AGT.1.6.11`: Response status 200 (deletion succeeded)
- `AGT.1.6.22`: Response status other than 200
- `AGT.1.6.32`: Cannot call Web API due to communication error

---

### AGT.1.10 — Advanced Settings Change

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.1.10.22 | Information | `[AdminLink] Advanced Settings of AdminLink agent changed` |

---

## AGT.2 — Agent Continuous Operation

### AGT.2.1 / AGT.2.2 — Start / Stop Agent Function

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.2.1.2 / AGT.2.1.12 | Information | `[AdminLink] Start AdminLink agent function` |
| AGT.2.1.14 | Information | `[AdminLink] Registration information deleted. The MAC address on the configuration is different from the one of the device.` |
| AGT.2.2.2 | Information | `[AdminLink] Stop AdminLink agent function` |

---

### AGT.2.3 — Daily Processing (every 24 hours)

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.2.3.3 | Information | `[AdminLink] Start AdminLink daily processing` |
| AGT.2.3.42 | Information | `[AdminLink] Stop AdminLink agent function caused by device not registered` |
| AGT.2.3.53 | Error | `[AdminLink] Stop AdminLink agent function caused by failed to delete JSON data` |

---

### AGT.2.5 — Event Polling (every 1 minute)

| Spec ID | Level | English Log Message | Note |
|---|---|---|---|
| AGT.2.5.4 | Information | `[AdminLink] AdminLink agent detected event「xx」` | `xx` = Action ID of detected event |
| AGT.2.5.11 | Error | `[AdminLink] Failed to detect the event（Action ID=%d）` | `%d` = Action ID of failed event |

---

### AGT.2.6 — Send JSON Data to Server

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.2.6.32 | Error | `[AdminLink] Failed to send JSON data` |

---

### AGT.2.7 — Connection Client File Upload

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.2.7.21 | Error | `[AdminLink] Failed to create connection client file` |
| AGT.2.7.41B | Error | `[AdminLink] Connection client file : Failed to get upload URL（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.2.7.61 | Error | `[AdminLink] Failed to upload connection client file` |
| AGT.2.7.71 | Error | `[AdminLink] Connection client file : Failed to notice upload completion（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |

---

### AGT.2.8 — Configuration File Upload

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.2.8.31 | Error | `[AdminLink] Device configuration file : Failed to get upload URL（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.2.8.42 | Information | `[AdminLink] Configuration file upload completion` |
| AGT.2.8.51 | Error | `[AdminLink] Device configuration file : Failed to upload` |
| AGT.2.8.61 | Error | `[AdminLink] Device configuration file : Failed to notice upload completion（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.2.8.101 | Error | `[AdminLink] Configuration status JSON file : Failed to get upload URL（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.2.8.121 | Error | `[AdminLink] Configuration status JSON file : Failed to upload` |
| AGT.2.8.131 | Error | `[AdminLink] Configuration status JSON file : Failed to notice upload completion（error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |

---

## AGT.3 — Remote Control Request Handling

### AGT.3.1 — Remote Control Reception

| Spec ID | Level | English Log Message | Note |
|---|---|---|---|
| AGT.3.1.11 | Information | `[AdminLink] Start to accept remote operations` | |
| AGT.3.1.22 | Error | `[AdminLink] Failed to start accepting remote operations` | |
| AGT.3.1.41 | Information | `[AdminLink] Stop to accept remote operations` | |
| AGT.3.1.51 | Error | `[AdminLink] Failed to stop accepting remote operations` | |
| AGT.3.1.61 | Error | `[AdminLink] Disconnected the acceptance remote operations` | |
| AGT.3.1.81 | Information | `[AdminLink] Completed execution remote operations（ID=%d）` | `%d` = Remote control ID |
| AGT.3.1.91 | Error | `[AdminLink] Failed execution remote operations（ID=%d）` | `%d` = Remote control ID |

---

### AGT.3.2 — Remote Control with File Download

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.3.2.21 | Error | `[AdminLink] Failed to get file download URL（status_code=%d, error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.3.2.21 | Error | `[AdminLink] Failed to get file download URL(communication error）.` |
| AGT.3.2.41 (ID:2010 F/W update) | Error | `[AdminLink] Failed to download firmware update file` |
| AGT.3.2.41 (ID:5070 Change Config) | Error | `[AdminLink] Failed to download Configuration data JSON file.` |
| AGT.3.2.41 (ID:5080 Config Restore) | Error | `[AdminLink] Failed to download Configuration information file.` |
| AGT.3.2.61 | Error | `[AdminLink] Download file is not correct hash` |
| AGT.3.2.71 | Error | `[AdminLink] Failed to notice file download completion（status_code=%d, error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.3.2.71 | Error | `[AdminLink] Failed to notice file download completion(communication error).` |
| AGT.3.2.91 | Error | `[AdminLink] Failed to upgrade FW` |
| AGT.3.2.91.1 | Error | `[AdminLink] Failed to change device settings using the "Configuration Data JSON" file.` |
| AGT.3.2.91.2 | Error | `[AdminLink] Failed to restore device settings using the "Configuration Information" file.` |

---

### AGT.3.3 — Remote Control with File Upload

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.3.3.21 | Error | `[AdminLink] Failed to get file upload URL（status_code=%d, error_id=%d, error_msg=%s, error_field=%s, error_value=%s）.` |
| AGT.3.3.21 | Error | `[AdminLink] Failed to get file upload URL（communication error）.` |
| AGT.3.3.41 (ID:4020 Log file) | Error | `[AdminLink] Failed to upload log file` |
| AGT.3.3.41 (ID:4030 Config info) | Error | `[AdminLink] Failed to upload Configuration information file.` |
| AGT.3.3.41 (ID:4040 Conn client) | Error | `[AdminLink] Failed to upload Connection client file.` |
| AGT.3.3.41 (ID:5060 Config JSON) | Error | `[AdminLink] Failed to upload Configuration data JSON file.` |
| AGT.3.3.61 | Error | `[AdminLink] Failed to notice file upload completion（status_code=%d, error_id=%d, error_msg=%s, error_field=%s, error_value=%s）` |
| AGT.3.3.61 | Error | `[AdminLink] Failed to notice file upload completion（communication error）.` |

---

### AGT.3.4 — Emergency Mode (Remote Control)

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.3.4.21 | Information | `[AdminLink] Emergency Mode changed to "Disabled".` |
| AGT.3.4.21 | Information | `[AdminLink] Emergency Mode changed to "Enabled, Available ports: No Restriction".` |
| AGT.3.4.21 | Information | `[AdminLink] Emergency Mode changed to "Enabled, Available ports: Web/Mail only".` |
| AGT.3.4.31 | Error | `[AdminLink] Failed to set Emergency Mode.` |

---

## AGT.4 — Zero Touch / Auto Registration

### AGT.4.2 — Automatic Registration Flow

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.4.2.11 | Information | `[AdminLink] Device has been temporarily registered (regist code=%s, MAC address=%s, dev_id_changed=%d, agt_upload_sec=%d, agt_daily_sec=%d, tmp_reg_expiry=YYYY/MM/DD hh:mm:ss).` |
| AGT.4.2.11 (no expiry) | Information | `[AdminLink] Device has been temporarily registered (regist code=%s, MAC address=%s, dev_id_changed=%d, agt_upload_sec=%d, agt_daily_sec=%d, tmp_reg_expiry=non).` |
| AGT.4.2.21 | Error | `[AdminLink] Device temporary registration failed (regist code=%s, MAC address=%s, status_code=%d, error_id=%d, error_msg=%s, error_field=%s, error_value=%s).` |
| AGT.4.2.31 | Error | `[AdminLink] Device temporary registration failed (regist code=%s, MAC address=%s, communication error).` |

> **AGT.4.2.31 Note:** Log only on first attempt; do NOT log on retries.

---

### AGT.4.3 — Zero Touch Standby Process

| Spec ID | Level | English Log Message |
|---|---|---|
| AGT.4.3.22 / AGT.4.3.41 | Information | `[AdminLink] Temporary registration expiration date (YYYY/MM/DD hh:mm:ss) has passed.` |
| AGT.4.3.94 | Information | `[AdminLink] Device successfully auto-registered.` |

---

## Appendix — Log Level Reference

| Level (Japanese) | Level (English) |
|---|---|
| 情報 | Information |
| エラー | Error |
| デバッグ | Debug |

---

## Appendix — Format Placeholder Reference

| Placeholder | Description |
|---|---|
| `%d` | Integer value (e.g. error_id, status_code, remote control ID) |
| `%s` | String value (e.g. error_msg, error_field, error_value, MAC address) |
| `YYYY/MM/DD hh:mm:ss` | Date/time format |
| `xx` | Action ID of detected event (AGT.2.5.4) |