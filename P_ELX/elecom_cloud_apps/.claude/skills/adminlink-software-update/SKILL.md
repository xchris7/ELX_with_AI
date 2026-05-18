---
name: adminlink-software-update
description: >
  Use this SKILL whenever the user needs to call, test, debug, validate, or
  generate code for the Software Update Acquisition API
  (GET /v1/devices/{dev_id}/software).
  Triggers include: retrieving the latest software/agent version information,
  getting download URLs for management software or agent programs, handling
  event definition data, or diagnosing errors from this API.
  Note: This API is a change from the current Device Registration API for NAS.
---

# SKILL: Software Update Acquisition API

## Trigger Conditions

Use this SKILL when the user asks to:
- Retrieve the latest management software or agent version from the service
- Get download URLs for the latest management software or agent program
- Check event definition information returned from the server
- Diagnose an error response from this API

---

## API Overview

| Item | Value |
|------|-------|
| URI | `https://api.admin-link.net/v1/devices/{dev_id}/software` |
| Method | `GET` |
| X-NASAPI-Device-Subkey | MAC address of the device |
| Request Body | None |
| Purpose | Called by a device to acquire the latest software information of the device from the Service |

> `{dev_id}` in the URI must be replaced with the actual Device ID of the calling device.

---

## Execution Steps

### Step 1 — Build the Request

No request body required. Pass identity via:

| Header | Value |
|--------|-------|
| `X-NASAPI-Device-Subkey` | Representative MAC address of the device |

> No SHA-256 Authorization signature required (unlike Auth Info Acquisition API 2.3).

---

### Step 2 — Send the Request

**curl example:**
```bash
DEV_ID="NAS001"
MAC_ADR="AA:BB:CC:DD:EE:FF"

curl -X GET "https://api.admin-link.net/v1/devices/${DEV_ID}/software" \
  -H "X-NASAPI-Device-Subkey: ${MAC_ADR}"
```

**Python example:**
```python
import requests

dev_id = "NAS001"
mac_adr = "AA:BB:CC:DD:EE:FF"

url = f"https://api.admin-link.net/v1/devices/{dev_id}/software"
headers = {
    "X-NASAPI-Device-Subkey": mac_adr
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    data = response.json()
    print("Software info acquired successfully")
    print(f"Management software version : {data['ms_ver']}")
    print(f"Agent version               : {data['agt_ver']}")
    print(f"Management software URL     : {data['ms_url']}")
    print(f"Agent download URL          : {data['agt_url']}")
    print(f"Event definition            : {data['event_def']}")  # expected empty
else:
    error = response.json()
    print(f"Error {response.status_code}: [{error['error_id']}] {error['error_msg']}")
```

---

### Step 3 — Handle the Response

#### HTTP Status Codes

| Status | Description | Meaning |
|--------|-------------|---------|
| `200` | OK | Success in obtaining the latest software information |
| `400` | Bad Request | Either the device ID or MAC address is unspecified or the format is incorrect |
| `401` | Unauthorized | Failed to confirm registration by device ID or MAC address (device not registered) |
| `405` | Method Not Allowed | Error in the API invocation method |
| `500` | Internal Server Error | Program error or database error |

---

#### Success (HTTP 200) — Response Body (JSON)

| Key | Required | Description | KC Note |
|-----|----------|-------------|---------|
| `ms_ver` | ○ | The latest version of the management software program | |
| `agt_ver` | ○ | The latest version of the agent program | |
| `ms_url` | ○ | The URL for downloading the latest management software program | |
| `agt_url` | ○ | URL to download the latest agent program | |
| `event_def` | ○ | Event definition information | **Currently not in use — key must be present in response but value must be returned empty** |

> ⚠️ `event_def` handling: The key itself must always be present in the response. The value must be returned as empty (`""` or `null`) since it is not currently in use. Do not omit the key entirely.

---

#### Error (non-200) — Response Body (JSON)

> **KC Note:** `error_msg` is not currently consumed by the agent.
> Return both `error_id` and `error_msg` in all error responses regardless.

| Key | Required | Description |
|-----|----------|-------------|
| `error_id` | ○ | ID to notify the agent of the error details when an error occurs |
| `error_msg` | ○ | Error message when an error occurs *(not currently consumed by agent — include anyway)* |
| `error_field` | — | ID of the item where an error occurs in the request parameter item check |
| `error_value` | — | Value of the item where an error occurs in the request parameter item check |

---

### Step 4 — Diagnose Errors

#### HTTP 400 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4000` | 必須項目が入力されていません。 | A required field in the request header is not specified. Key Required Error | Ensure `X-NASAPI-Device-Subkey` header is present and `{dev_id}` is set in the URI |
| `4002` | 必須項目が入力されていません。 | The request parameter item exists, but the value is not specified. Required error for value | Ensure all required field values are non-empty. |
| `4004` | 入力可能な桁数を超過しています。 | Error in the number of digits of the device ID or MAC address | Check field lengths |
| `4005` | 入力された文字種が不正です。 | Character type error in device ID or MAC address | Check for invalid characters in `dev_id` or MAC address |
| `4006` | フォーマットエラーが発生しました。 | MAC address format error | Verify MAC address format (e.g., `AA:BB:CC:DD:EE:FF`) |
| `4007` | 製品情報の取得に失敗しました。 | Version and URL cannot be acquired | Server-side issue — version/URL data not retrievable for this device |
| ~~`4008`~~ | ~~イベント定義が取得できない。~~ | ~~Event definition cannot be acquired~~ | **Struck through in spec** — deprecated, do not handle |

#### HTTP 401 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4012` | デバイス情報が登録されていません。 | Device information with the same device ID and MAC address is not registered | Verify `dev_id` and MAC address match a registered device |

#### HTTP 405 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `405` | 呼び出し方法に誤りがあります。 | 405 error occurred | Verify HTTP method is `GET` |

#### HTTP 500 errors

| error_id | Error Message (JP) | Meaning |
|----------|--------------------|---------|
| `5000` | システムエラーが発生しました。 | A 500 error occurred |

---

## Business Rules Summary (always enforce)

### Authentication
- `dev_id` (URI path) + `X-NASAPI-Device-Subkey` (MAC address header)
- No SHA-256 signature required
- Mismatch with registered record → `4012`

### event_def Field Rule
```
event_def MUST always be present in the response body.
event_def value MUST be returned empty ("" or null).
Reason: field is reserved but not currently in use (KC note).
Do NOT omit the key — leave the key, empty the value.
```

### Deprecated Error Code
```
4008 (イベント定義が取得できない) ← STRUCK THROUGH in spec
→ Treat as deprecated — do not implement handling for this error code
```

### 4002 Status
```
The request parameter item exists, but the value is not specified.
→ Required error for value
→ Treat as ACTIVE — ensure all required field values are non-empty.
```

### error_msg Handling
Per KC note: `error_msg` is not currently processed by the agent.
Always return both `error_id` and `error_msg` in error responses regardless.

### Spec Conflict Resolution
If KC sticky notes conflict with the main table content → **KC note takes precedence**.

---

## Response Principles

1. Always include `event_def` key in the 200 response — return it with an empty value
2. Do not implement handling for struck-through error code `4008`
3. Treat `4002` as active unless explicitly deprecated
4. When diagnosing `4007`, this is a server-side data retrieval failure — no client-side fix applies
5. Always return both `error_id` and `error_msg` in error responses

---

## Related SKILLs (API Call Flow)

| Order | SKILL | File | Relationship |
|-------|-------|------|-------------|
| Prerequisite | 2.2 Device Registration | `/adminlink-register-device` | Device must be registered |
| Prerequisite | 2.4 Registration Confirmation | `/adminlink-confirm-registration` | Registration confirmed before polling software updates |
| Related | 2.8 File Download | `/adminlink-download-url` | Download URLs from this API are used to download software updates |

---

## 對照流程（Cloud Linkage Flow）

端到端流程位置（引述對照用，**非權威**；規格仍以本 SKILL 為準）：

- [`01_device_entry_software_flow.md`](../../../spec/docs/agent_cloud_linkage_flow/01_device_entry_software_flow.md) — Flow 1 PART 2：軟體版本確認（AP/SW/WAB-BE 不適用）
- [`02_device_entry_startup_flow.md`](../../../spec/docs/agent_cloud_linkage_flow/02_device_entry_startup_flow.md) — Flow 2 PART 2：版本確認分支
- 索引：[`agent_cloud_linkage_flow/INDEX.md`](../../../spec/docs/agent_cloud_linkage_flow/INDEX.md)
