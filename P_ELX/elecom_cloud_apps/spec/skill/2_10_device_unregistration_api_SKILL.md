---
name: device-unregistration-api
description: >
  Use this SKILL whenever the user needs to call, test, debug, validate, or
  generate code for the Device Unregistration API
  (DELETE /v1/devices/{dev_id}).
  Triggers include: unregistering a device from the service, removing a device
  record by device ID and MAC address, cleaning up IoT Core device certificates,
  or diagnosing errors from this API.
  This API can be called from either the device itself or a Web screen.
---

# SKILL: Device Unregistration API (2.10)

## Trigger Conditions

Use this SKILL when the user asks to:
- Unregister a device from the service
- Delete a device registration record
- Remove associated IoT Core certificates and S3 files for a device
- Diagnose an error response from this API

---

## API Overview

| Item | Value |
|------|-------|
| URI | `https://api.admin-link.net/v1/devices/{dev_id}` |
| Method | `DELETE` |
| X-NASAPI-Device-Subkey | MAC address of the device |
| Request Body | None |
| Purpose | Called from a device or Web screen to unregister a device registered with the service |

> `{dev_id}` in the URI must be replaced with the actual Device ID of the device to unregister.
> This API shares the same URI as the Device Registration Confirmation API (2.4) — distinguished by HTTP method (`DELETE` vs `GET`).

---

## Execution Steps

### Step 1 — Build the Request

No request body required.

| Header | Value |
|--------|-------|
| `X-NASAPI-Device-Subkey` | Representative MAC address of the device |

> No SHA-256 Authorization signature required.

---

### Step 2 — Send the Request

**curl example:**
```bash
DEV_ID="NAS001"
MAC_ADR="AA:BB:CC:DD:EE:FF"

curl -X DELETE "https://api.admin-link.net/v1/devices/${DEV_ID}" \
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

response = requests.delete(url, headers=headers)

if response.status_code == 200:
    print("Device unregistration successful")
    # Response body is empty JSON {} — no fields to read
else:
    error = response.json()
    print(f"Error {response.status_code}: [{error['error_id']}] {error['error_msg']}")
```

---

### Step 3 — Handle the Response

#### HTTP Status Codes

| Status | Description | Meaning |
|--------|-------------|---------|
| `200` | OK | Successful unregistration of a device |
| `400` | Bad Request | Either the device ID or MAC address is unspecified or the format is incorrect |
| `401` | Unauthorized | Failed to confirm registration by device ID or MAC address (device not registered) |
| `405` | Method Not Allowed | Error in the API invocation method |
| `500` | Internal Server Error | Program error or database error |

---

#### Success (HTTP 200) — Response Body

```
Empty JSON is returned. ({})
```

> No fields to parse on success. A `200` status alone confirms the device has been successfully unregistered.

---

#### Error (non-200) — Response Body (JSON)

| Key | Required | Description |
|-----|----------|-------------|
| `error_id` | ○ | ID to notify the agent of the error details when an error occurs |
| `error_msg` | ○ | Error message when an error occurs |
| `error_field` | — | ID of the item where an error occurs in the request parameter item check |
| `error_value` | — | Value of the item where an error occurs in the request parameter item check |

---

### Step 4 — Diagnose Errors

#### HTTP 400 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4000` | 必須項目が入力されていません。 | A required field in the request header is not specified. Key Required Error | Ensure `X-NASAPI-Device-Subkey` is present and `{dev_id}` is in the URI |
| `4002` | 必須項目が入力されていません。 | The request parameter item exists, but the value is not specified. Required error for value | Ensure both `dev_id` and MAC address values are non-empty |
| `4004` | 入力可能な桁数を超過しています。 | Error in the number of digits of the device ID or MAC address | Check field lengths |
| `4005` | 入力された文字種が不正です。 | Character type error in device ID or MAC address | Check for invalid characters |
| `4006` | フォーマットエラーが発生しました。 | MAC address format error | Verify MAC address format (e.g., `AA:BB:CC:DD:EE:FF`) |

#### HTTP 401 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4012` | デバイス情報が登録されていません。 | No device with the same device ID or MAC address is registered | Verify `dev_id` and MAC address match a registered device |
| `4013` | デバイスが複数登録されています。 | Two or more devices with the same device ID or MAC address exist | Duplicate record — escalate to server-side investigation; cannot be resolved programmatically |

#### HTTP 405 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `405` | 呼び出し方法に誤りがあります。 | 405 error occurred | Verify HTTP method is `DELETE` — NOT `GET` or `POST` |

#### HTTP 500 errors

| error_id | Error Message (JP) | Meaning |
|----------|--------------------|---------|
| `5000` | システムエラーが発生しました。 | A 500 error occurred |
| `5001` | システムエラーが発生しました。 | Failed to delete device information |
| `5002` | システムエラーが発生しました。 | Failed to connect to S3 |
| `5003` | システムエラーが発生しました。 | Failed to delete uploaded file information |
| `5004` | システムエラーが発生しました。 | Failed to delete device information (secondary deletion step) |
| `5005` | システムエラーが発生しました。 | Failed to delete device certificate information |
| `5006` | システムエラーが発生しました。 | Failed to delete the device certificate of IoT Core |
| `5007` | システムエラーが発生しました。 | IoT Core device deletion failed |

---

## Business Rules Summary (always enforce)

### Authentication
```
dev_id      → URI path
MAC address → X-NASAPI-Device-Subkey header
No SHA-256 signature required
Mismatch with registered record → 4012
```

### URI Method Disambiguation
```
Same URI as Device Registration Confirmation API (2.4):
  GET    /v1/devices/{dev_id}  → Confirmation (2.4)
  DELETE /v1/devices/{dev_id}  → Unregistration (2.10)
Using wrong method → 405
```

### Caller Types
```
This API can be called from:
  - The device itself (agent-initiated unregistration)
  - Web screen (admin-initiated unregistration)
Both use the same endpoint and authentication method.
```

### What Gets Deleted on Success
Based on 500-series error codes, unregistration triggers deletion of:
```
1. Device information record (DB)          ← 5001 / 5004 on failure
2. Uploaded file information in S3         ← 5003 on failure (requires S3 connect: 5002)
3. Device certificate information (DB)     ← 5005 on failure
4. Device certificate in IoT Core          ← 5006 on failure
5. IoT Core device record                  ← 5007 on failure
```

### 4013 Handling
```
4013 (duplicate device records) cannot be resolved programmatically.
→ Escalate to server-side manual investigation.
→ Do not retry the DELETE request.
```

### Success Response
```
HTTP 200 → empty JSON body {}
No fields to parse — 200 status alone confirms successful unregistration.
```

---

## Response Principles

1. Verify HTTP method is `DELETE` — the same URI used with `GET` calls a different API (2.4)
2. On `4013`, escalate to manual server-side investigation — do not retry
3. On 500-series errors, use `error_id` to identify which deletion step failed across the 5-step cleanup sequence
4. `5002` (S3 connect failure) often precedes `5003` — if both occur together, the root cause is the S3 connection
5. A `200` response with empty JSON is normal and expected — no parsing needed

---

## Related SKILLs (API Call Flow)

| Order | SKILL | File | Relationship |
|-------|-------|------|-------------|
| Reverse of | 2.2 Device Registration | `2_2_device_registration_api_SKILL.md` | Reverse operation — removes what 2.2 registered |
| Same URI | 2.4 Registration Confirmation | `2_4_device_registration_confirmation_api_SKILL.md` | Same URI `/v1/devices/{dev_id}` — distinguished by HTTP method (DELETE vs GET) |
