---
name: device-registration-confirmation-api
description: >
  Use this SKILL whenever the user needs to call, test, debug, validate, or
  generate code for the Device Registration Confirmation API
  (GET /v1/devices/{dev_id}).
  Triggers include: confirming whether a device is registered, retrieving
  device flags (remote control, upload permissions, intervals), checking
  MAC address update status, or diagnosing errors from this API.
  Note: Bolded response fields represent changes from the current Device
  Registration API for NAS.
---

# SKILL: Device Registration Confirmation API (2.4)

## Trigger Conditions

Use this SKILL when the user asks to:
- Confirm whether a device is registered to the service
- Retrieve device permission flags (remote control, upload config/log/client)
- Check upload interval settings returned from the server
- Diagnose an error response from this API

---

## API Overview

| Item | Value |
|------|-------|
| URI | `https://api.admin-link.net/v1/devices/{dev_id}` |
| Method | `GET` |
| X-NASAPI-Device-Subkey | MAC address of the device |
| Request Body | None |
| Purpose | Called by the device to confirm device registration to the service |

> `{dev_id}` in the URI must be replaced with the actual Device ID of the calling device.

---

## ⚠️ Critical Precondition — NextGiga Support Memo (decided 2025/07/15)

> **Devices in provisionally registered state will NOT call this API.**

```
Before calling this API:
  Is device in provisional registration state?
    YES → Do NOT call this API
    NO  → Proceed normally
```

A device is in provisional state when:
- It registered using `regist_cd` (auto registration)
- AND `tmp_reg_expiry` was returned in the Device Registration API response
- AND permanent registration has not yet been confirmed

---

## Execution Steps

### Step 1 — Verify Device is Not in Provisional State

Check registration state before proceeding. If provisional → stop and do not call this API.

---

### Step 2 — Build the Request

No request body required. Pass identity via:

| Header | Value |
|--------|-------|
| `X-NASAPI-Device-Subkey` | Representative MAC address of the device |

> No SHA-256 Authorization signature required (unlike Auth Info Acquisition API 2.3).

---

### Step 3 — Send the Request

**curl example:**
```bash
DEV_ID="NAS001"
MAC_ADR="AA:BB:CC:DD:EE:FF"

curl -X GET "https://api.admin-link.net/v1/devices/${DEV_ID}" \
  -H "X-NASAPI-Device-Subkey: ${MAC_ADR}"
```

**Python example:**
```python
import requests

dev_id = "NAS001"
mac_adr = "AA:BB:CC:DD:EE:FF"

url = f"https://api.admin-link.net/v1/devices/{dev_id}"
headers = {
    "X-NASAPI-Device-Subkey": mac_adr
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    data = response.json()
    print("Device registration confirmed")
    print(f"Device ID              : {data['dev_id']}")
    print(f"MAC address changed    : {data['mac_adr_changed']}")
    print(f"Remote control enabled : {data['remote_control_enabled']}")
    print(f"Config upload enabled  : {data['upload_config_enabled']}")
    print(f"Log upload enabled     : {data['upload_log_enabled']}")
    print(f"Client upload enabled  : {data['upload_client_enabled']}")
    print(f"Client upload interval : {data['upload_client_interval']}")
else:
    error = response.json()
    print(f"Error {response.status_code}: [{error['error_id']}] {error['error_msg']}")
```

---

### Step 4 — Handle the Response

#### HTTP Status Codes

| Status | Description | Meaning |
|--------|-------------|---------|
| `200` | OK | Confirmation of device registration succeeded |
| `400` | Bad Request | Device ID or MAC address is unspecified or format is incorrect |
| `401` | Unauthorized | Failed to confirm registration by device ID or MAC address (device not registered) |
| `405` | Method Not Allowed | Error in the API invocation method |
| `500` | Internal Server Error | Program error or database error |

---

#### Success (HTTP 200) — Response Body (JSON)

**Legend:**
- **Bold** = Changed from current Device Registration API for NAS (KC Revision 2 additions)
- ~~Strikethrough~~ = Deleted per KC revision 5/19 — do not implement

| Key | Required | Description | Status |
|-----|----------|-------------|--------|
| `dev_id` | ○ | Device ID (or device ID held by NAS try service when authenticated by MAC address) | Existing |
| ~~`dev_id_changed`~~ | ~~○~~ | ~~1 if there has been a change from the device ID passed at the time of the call, 0 otherwise~~ | **DELETED** KC 5/19 |
| `mac_adr_changed` | ○ | 1 if the MAC address held by the server side for NAS is updated by the MAC address passed at the time of the call, 0 otherwise | Existing |
| ~~`upload_dir_limit_size`~~ | ~~○~~ | ~~Maximum size of the directory where status/event information is saved~~ | **DELETED** KC 5/19 |
| ~~`upload_dir_limit_day`~~ | ~~○~~ | ~~Number of days to store status/event information in the directory~~ | **DELETED** KC 5/19 |
| **`remote_control_enabled`** | **○** | **1 if remote control is allowed, 0 otherwise** | **NEW** KC Rev.2 |
| **`upload_config_enabled`** | **○** | **1 if configuration file upload is allowed, 0 otherwise** | **NEW** KC Rev.2 |
| **`upload_log_enabled`** | **○** | **1 if log file upload is allowed, 0 otherwise** | **NEW** KC Rev.2 |
| **`upload_client_enabled`** | **○** | **1 if connection client file upload is allowed, 0 otherwise** | **NEW** KC Rev.2 |
| **`upload_client_interval`** | **○** | **0=No upload, 1=1h interval, 3=3h interval, 6=6h interval** | **NEW** KC Rev.2 |

**Current active fields (implement these only):**
```
dev_id                  ○  Device ID
mac_adr_changed         ○  MAC address update flag       (0 or 1)
remote_control_enabled  ○  Remote control permission     (0 or 1)  ← NEW
upload_config_enabled   ○  Config file upload permission (0 or 1)  ← NEW
upload_log_enabled      ○  Log file upload permission    (0 or 1)  ← NEW
upload_client_enabled   ○  Client file upload permission (0 or 1)  ← NEW
upload_client_interval  ○  Upload interval: 0 / 1 / 3 / 6         ← NEW
```

---

#### Error (non-200) — Response Body (JSON)

> **KC Note:** `error_msg` is not currently consumed by the agent.
> Return both `error_id` and `error_msg` in all error responses regardless.

| Key | Required | Description |
|-----|----------|-------------|
| `error_id` | ○ | ID to notify the agent of the error details |
| `error_msg` | ○ | Error message *(not currently consumed by agent — include anyway)* |
| `error_field` | — | ID of the item where error occurred in request parameter check |
| `error_value` | — | Value of the item where error occurred in request parameter check |

---

### Step 5 — Diagnose Errors

#### HTTP 400 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4000` | 必須項目が入力されていません。 | A required field in the request header is not specified. Key Required Error | Ensure `X-NASAPI-Device-Subkey` is present and `{dev_id}` is in the URI |
| `4002` | 必須項目が入力されていません。 | The request parameter item exists, but the value is not specified. Required error for value | Ensure both `dev_id` and MAC address are non-empty |
| `4004` | 入力可能な桁数を超過しています。 | Digit count error in device ID or MAC address | Check field lengths |
| `4005` | 入力された文字種が不正です。 | Character type error in device ID or MAC address | Check for invalid characters |
| `4006` | フォーマットエラーが発生しました。 | MAC address format error | Verify MAC address format (e.g., `AA:BB:CC:DD:EE:FF`) |

#### HTTP 401 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4012` | デバイス情報が登録されていません。 | No device with matching device ID or MAC address is registered | Verify `dev_id` and MAC address; also confirm device is not in provisional state |
| `4013` | デバイスが複数登録されています。 | Two or more devices share the same device ID or MAC address | Duplicate record — escalate to server-side investigation |

#### HTTP 405 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `405` | 呼び出し方法に誤りがあります。 | 405 error occurred | Verify HTTP method is `GET` |

#### HTTP 500 errors

| error_id | Error Message (JP) | Meaning |
|----------|--------------------|---------|
| `5000` | システムエラーが発生しました。 | A 500 error occurred |
| `5001` | システムエラーが発生しました。 | Failed to update device information |
| `5002` | システムエラーが発生しました。 | Failed to acquire constant information from the system master |

---

## Business Rules Summary (always enforce)

### Provisional Registration Skip Rule (decided 2025/07/15)
```
IF device registered via regist_cd AND tmp_reg_expiry was returned
  → Device is in provisional state
  → DO NOT call this API
ELSE
  → Call this API normally
```

### Authentication
- `dev_id` (URI path) + `X-NASAPI-Device-Subkey` (MAC address header)
- No SHA-256 signature required
- Mismatch with registered record → `4012`

### Deleted Fields — Do NOT Implement

These fields appeared in earlier spec versions and images but were removed per KC revision on 5/19:

| Deleted Key | Original Description | Status |
|-------------|---------------------|--------|
| `dev_id_changed` | 1 if device ID changed from the one passed at call time, 0 otherwise | **DELETED** KC 5/19 |
| `upload_dir_limit_size` | Maximum size of directory where status/event info is saved | **DELETED** KC 5/19 |
| `upload_dir_limit_day` | Number of days to store status/event info in directory | **DELETED** KC 5/19 |

### New Fields from NAS Registration API — Must Implement (KC Revision 2)
```
remote_control_enabled   ← NEW
upload_config_enabled    ← NEW
upload_log_enabled       ← NEW
upload_client_enabled    ← NEW
upload_client_interval   ← NEW
```

### upload_client_interval Value Mapping
| Value | Meaning |
|-------|---------|
| `0` | No upload |
| `1` | Upload every 1 hour |
| `3` | Upload every 3 hours |
| `6` | Upload every 6 hours |

### Binary Flag Convention
```
0 = false / not allowed / no change
1 = true  / allowed     / changed
```

### Spec Conflict Resolution
If KC revision sticky notes conflict with the main table → **KC note takes precedence**.

---

## Response Principles

1. Always verify device is not in provisional state before calling this API (2025/07/15 rule)
2. Implement only the 7 active fields — do not implement the 3 deleted fields
3. When diagnosing `4012`, confirm device is not in provisional state before concluding it is unregistered
4. `4013` cannot be resolved programmatically — escalate to manual server-side investigation
5. Always return both `error_id` and `error_msg` in error responses

---

## Related SKILLs (API Call Flow)

| Order | SKILL | File | Relationship |
|-------|-------|------|-------------|
| Prerequisite | 2.2 Device Registration | `2_2_device_registration_api_SKILL.md` | Device must be registered first |
| Prerequisite | 2.3 Auth Info Acquisition | `2_3_auth_info_acquisition_api_SKILL.md` | Auth info acquired before confirmation |
| Same URI | 2.10 Device Unregistration | `2_10_device_unregistration_api_SKILL.md` | Same URI `/v1/devices/{dev_id}` — distinguished by HTTP method (GET vs DELETE) |
