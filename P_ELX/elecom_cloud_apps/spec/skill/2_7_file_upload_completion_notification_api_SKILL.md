---
name: file-upload-completion-notification-api
description: >
  Use this SKILL whenever the user needs to call, test, debug, validate, or
  generate code for the File Upload Completion Notification API
  (POST /v1/devices/{dev_id}/uploadnotify).
  Triggers include: notifying the service that a file upload to S3 is complete,
  sending upload_id and upload_type after a successful S3 PUT, specifying file
  extension or auto/manual upload flag, or diagnosing errors from this API.
  This API is Step 2 of the 2-step upload flow — must be called AFTER the S3
  file upload using the pre-signed URL obtained from the 2.6 API.
---

# SKILL: File Upload Completion Notification API (2.7)

## Trigger Conditions

Use this SKILL when the user asks to:
- Notify the service that a file has been uploaded to S3
- Send upload completion metadata (upload_id, upload_type, auto_flg, extension)
- Complete the 2-step file upload flow after the 2.6 API
- Diagnose an error response from this API

---

## API Overview

| Item | Value |
|------|-------|
| URI | `https://api.admin-link.net/v1/devices/{dev_id}/uploadnotify` |
| Method | `POST` |
| X-NASAPI-Device-Subkey | MAC address of the device |
| Content-Type | `application/json` |
| Purpose | Called by the device to notify the completion of file upload to the service |

> `{dev_id}` in the URI must be replaced with the actual Device ID of the calling device.

---

## File Upload Workflow Context

This API is **Step 3 of a 3-step upload flow**:

```
Step 1 — Call 2.6 API (URL Acquisition API for File Upload)
  → Receive: pre-signed S3 URL + upload_id

Step 2 — PUT file to S3 using the pre-signed URL (outside API scope)
  → Direct upload to AWS S3

Step 3 — Call this API (2.7)
  → Send: upload_id + upload_type + auto_flg + extension
  → Service moves file from temporary S3 to regular storage
```

> ⚠️ If this API call fails, the file remains in temporary S3 and will be
> auto-deleted after a period configured in S3 lifecycle settings.

---

## Execution Steps

### Step 1 — Prepare Request Fields

Collect the following before calling this API:

| Field | Source |
|-------|--------|
| `upload_id` | Returned from 2.6 API response |
| `upload_type` | Determined by the type of file being uploaded (see table below) |
| `auto_flg` | Determined by whether upload was triggered automatically or manually |
| `extension` | File extension of the uploaded file |

#### upload_type Value Reference

| Value | File Type | Restriction | KC Note |
|-------|-----------|-------------|---------|
| `01` | Debug log file | All devices | |
| `02` | System log file | All devices | |
| `03` | Configuration information (.cfg or .bin) | All devices | |
| `04` | Connection client file | All devices | KC Version 2: added |
| `05` | Configuration status JSON file | **SW and AP only** | KC Version 2: added |
| `06` | Configuration data JSON file | NextGiga only | **KC Revision 3 / NextGiga v7**: Added for remote configuration data acquisition |

#### auto_flg Value Reference

| Value | Meaning |
|-------|---------|
| `0` | Manual — upload triggered by remote control instruction |
| `1` | Automatic — device uploaded data automatically |

> KC Version 3: `auto_flg` parameter was added. Always include — it is required (○).

---

### Step 2 — Build the Request

**Headers:**

| Header | Value |
|--------|-------|
| `X-NASAPI-Device-Subkey` | Representative MAC address of the device |
| `Content-Type` | `application/json` |

**Request Body Fields:**

| Key | Required | Max Length | Description |
|-----|----------|------------|-------------|
| `upload_id` | ○ | 255 half-width | File upload ID obtained from 2.6 API |
| `upload_type` | ○ | 2 half-width | File type code (`01`–`06`) |
| `auto_flg` | ○ | 1 half-width | `0`=Manual, `1`=Automatic |
| `extension` | ○ | 5 half-width | File extension (e.g., `zip`, `cfg`, `bin`, `json`) |

---

### Step 3 — Send the Request

**curl example:**
```bash
DEV_ID="NAS001"
MAC_ADR="AA:BB:CC:DD:EE:FF"

curl -X POST "https://api.admin-link.net/v1/devices/${DEV_ID}/uploadnotify" \
  -H "X-NASAPI-Device-Subkey: ${MAC_ADR}" \
  -H "Content-Type: application/json" \
  -d '{
    "upload_id": "UPLOAD_ID_FROM_2.6_API",
    "upload_type": "01",
    "auto_flg": "1",
    "extension": "zip"
  }'
```

**Python example:**
```python
import requests

dev_id = "NAS001"
mac_adr = "AA:BB:CC:DD:EE:FF"

url = f"https://api.admin-link.net/v1/devices/{dev_id}/uploadnotify"
headers = {
    "X-NASAPI-Device-Subkey": mac_adr,
    "Content-Type": "application/json"
}
payload = {
    "upload_id"  : "UPLOAD_ID_FROM_2.6_API",
    "upload_type": "01",   # 01=Debug log
    "auto_flg"   : "1",   # 1=Automatic
    "extension"  : "zip"
}

response = requests.post(url, json=payload, headers=headers)

if response.status_code == 200:
    print("File upload completion notified successfully")
    # Response body is empty JSON {} — no fields to parse
else:
    error = response.json()
    print(f"Error {response.status_code}: [{error['error_id']}] {error['error_msg']}")
```

---

### Step 4 — Handle the Response

#### HTTP Status Codes

| Status | Description | Meaning |
|--------|-------------|---------|
| `200` | OK | Successful file upload completion notification |
| `400` | Bad Request | One of the input parameters is not specified or the format is invalid |
| `401` | Unauthorized | Failed to confirm registration by device ID and MAC address (device not registered) |
| `405` | Method Not Allowed | Error in the API invocation method |
| `500` | Internal Server Error | Program error or database error |

---

#### Success (HTTP 200) — Response Body

> **Empty JSON `{}` is returned.**
> No fields to parse — treat HTTP 200 as full confirmation of upload completion.
> File has been moved from temporary S3 to regular storage.

---

#### Error (non-200) — Response Body (JSON)

| Key | Required | Description |
|-----|----------|-------------|
| `error_id` | ○ | ID to notify the agent of the error details when an error occurs |
| `error_msg` | ○ | Error message when an error occurs |
| `error_field` | — | ID of the item where an error occurs in request parameter check |
| `error_value` | — | Value of the item where an error occurs in request parameter check |

---

### Step 5 — Diagnose Errors

#### HTTP 400 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4000` | 必須項目が入力されていません。 | A required field in the request header is not specified. Key Required Error | Ensure `X-NASAPI-Device-Subkey` and `{dev_id}` are present |
| `4002` | 必須項目が入力されていません。 | The request parameter item exists, but the value is not specified. Required error for value | Ensure all four body fields have non-empty values |
| `4004` | 入力可能な桁数を超過しています。 | Number of digits error | Check field lengths against max length constraints |
| `4005` | 入力された文字種が不正です。 | Character type error | Check for invalid characters in any request field |
| `4006` | フォーマットエラーが発生しました。 | MAC address or file upload type format error | Verify MAC address format and `upload_type` is a valid 2-digit code (`01`–`06`) |

#### HTTP 401 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4012` | デバイス情報が登録されていません。 | Device with the same device ID and MAC address is not registered | Verify `dev_id` and MAC address match a registered device |
| `4014` | ファイルアップロード情報が登録されていません。 | File upload information with the same upload ID is not registered | `upload_id` is invalid, expired, or already consumed — re-call 2.6 API to get a new one |

#### HTTP 405 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `405` | 呼び出し方法に誤りがあります。 | 405 error occurred | Verify HTTP method is `POST` |

#### HTTP 500 errors

| error_id | Error Message (JP) | Meaning | Retry? |
|----------|--------------------|---------|--------|
| `5000` | システムエラーが発生しました。 | A 500 error occurred | Yes |
| `5001` | システムエラーが発生しました。 | Failed to acquire constant information from system master | Yes |
| `5002` | システムエラーが発生しました。 | Failed to connect to S3 | Yes — file still in temporary S3 |
| `5003` | システムエラーが発生しました。 | Failed to move file to S3 file destination | Yes — file still in temporary S3 |
| `5004` | システムエラーが発生しました。 | Failed to update the file upload information | Yes — file may have moved but DB not updated |

---

## Business Rules Summary (always enforce)

### Upload Flow Dependency
```
MUST call this API only after:
  1. Successfully obtaining upload_id from 2.6 API
  2. Successfully PUT-ting the file to S3 using the pre-signed URL

DO NOT call this API if the S3 PUT failed.
```

### upload_id Rules
```
- MUST come from the 2.6 API response for this specific upload
- Single-use — consumed after a successful 200 response
- Do NOT reuse across upload attempts
- If 4014 → re-call 2.6 API to get a fresh upload_id
```

### upload_type Rules
```
01 → Debug log                          (all devices)
02 → System log                         (all devices)
03 → Configuration info (.cfg or .bin)  (all devices)
04 → Connection client file             (all devices)    KC v2
05 → Configuration status JSON          (SW and AP only) KC v2
06 → Configuration data JSON            (NextGiga only)  KC Revision 3 / v7

- Type 05: only send from SW or AP devices
- Type 06: NextGiga remote config data acquisition only
- Invalid type code → 4006
```

### auto_flg Rules
```
0 = Upload triggered by remote control instruction (Manual)
1 = Upload triggered automatically by device       (Automatic)

Always send — required field. KC Version 3 addition.
```

### Success Response Handling
```
HTTP 200 → returns empty JSON {}
→ Parse no fields
→ File successfully moved from temporary S3 to regular storage
→ Upload process is complete
```

### 500-Series Retry Strategy
```
5002 / 5003 → file still in temporary S3 → retry this API
5004        → file may have moved, DB not updated → retry this API
All retries should use the SAME upload_id (still valid on server error)
```

### Authentication
```
dev_id (URI path) + X-NASAPI-Device-Subkey (MAC address header)
No SHA-256 signature required.
Mismatch → 4012
```

---

## Response Principles

1. Always call this API only after a confirmed successful S3 PUT
2. Always use the `upload_id` from the paired 2.6 API call for the same upload session
3. On `4014`, the upload_id is invalid — do not retry with same ID; re-invoke 2.6 API
4. On 500-series S3 errors (`5002`, `5003`, `5004`), retry with the same upload_id
5. HTTP 200 returns empty JSON — do not attempt to parse response fields
6. For `upload_type 05`, verify device is SW or AP before sending
7. For `upload_type 06`, verify device is NextGiga before sending

---

## Related SKILLs (API Call Flow)

| Order | SKILL | File | Relationship |
|-------|-------|------|-------------|
| Prerequisite (required) | 2.6 URL Acquisition for Upload | `2_6_url_acquisition_file_upload_api_SKILL.md` | Must call 2.6 first to get `upload_id` and pre-signed URL |
| Prerequisite | 2.2 Device Registration | `2_2_device_registration_api_SKILL.md` | Device must be registered |
