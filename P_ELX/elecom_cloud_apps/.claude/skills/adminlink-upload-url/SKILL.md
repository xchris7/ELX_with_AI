---
name: adminlink-upload-url
description: >
  Use this SKILL whenever the user needs to call, test, debug, validate, or
  generate code for the URL Acquisition API for File Upload
  (GET /v1/devices/{dev_id}/uploadurl).
  Triggers include: obtaining a pre-signed S3 upload URL, retrieving a file
  upload ID, preparing to upload a file from the device to the service, or
  diagnosing errors from this API.
  This API must be called BEFORE the actual file upload (2.7 API).
---

# SKILL: URL Acquisition API for File Upload (2.6)

## Trigger Conditions

Use this SKILL when the user asks to:
- Obtain a pre-signed URL to upload a file to the service
- Retrieve a `upload_id` for tracking a file upload process
- Understand the S3 upload URL lifecycle and expiry behavior
- Diagnose an error response from this API

---

## API Overview

| Item | Value |
|------|-------|
| URI | `https://api.admin-link.net/v1/devices/{dev_id}/uploadurl` |
| Method | `GET` |
| X-NASAPI-Device-Subkey | MAC address of the device |
| Request Body | None |
| Purpose | Called by the device to obtain the URL for uploading a file to the service |

> `{dev_id}` in the URI must be replaced with the actual Device ID of the calling device.

---

## File Upload Workflow Context

This API is **Step 1 of a 2-step upload flow**:

```
Step 1 — Call this API (2.6)
  → Receive: pre-signed S3 URL + upload_id

Step 2 — Upload file using the pre-signed URL (2.7)
  → Use the URL returned in Step 1 to PUT the file to S3
  → Use upload_id to register the upload in the service
```

> ⚠️ If the 2.7 API call fails after upload, the file may remain in temporary S3 storage.
> Temporary S3 files are automatically deleted after a configured period via S3 settings.
> The upload destination S3 is a **temporary** storage location — it is copied to regular storage by the 2.7 API call.

---

## Execution Steps

### Step 1 — Build the Request

No request body required. Pass identity via:

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

curl -X GET "https://api.admin-link.net/v1/devices/${DEV_ID}/uploadurl" \
  -H "X-NASAPI-Device-Subkey: ${MAC_ADR}"
```

**Python example:**
```python
import requests

dev_id = "NAS001"
mac_adr = "AA:BB:CC:DD:EE:FF"

url = f"https://api.admin-link.net/v1/devices/{dev_id}/uploadurl"
headers = {
    "X-NASAPI-Device-Subkey": mac_adr
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    data = response.json()
    upload_url = data["Success. upload_url"]
    upload_id  = data["upload_id"]
    print("Upload URL acquired successfully")
    print(f"Upload URL : {upload_url}")
    print(f"Upload ID  : {upload_id}")
    # → Proceed to Step 2: use upload_url to PUT file, use upload_id for 2.7 API
else:
    error = response.json()
    print(f"Error {response.status_code}: [{error['error_id']}] {error['error_msg']}")
```

---

### Step 3 — Handle the Response

#### HTTP Status Codes

| Status | Description | Meaning |
|--------|-------------|---------|
| `200` | OK | Acquisition of URL for file upload succeeded |
| `400` | Bad Request | Either the device ID or MAC address is unspecified or the format is incorrect |
| `401` | Unauthorized | Failed to confirm registration by device ID or MAC address (device not registered) |
| `405` | Method Not Allowed | Error in the API invocation method |
| `500` | Internal Server Error | Program error or database error |

---

#### Success (HTTP 200) — Response Body (JSON)

| Key | Required | Description |
|-----|----------|-------------|
| `Success. upload_url` | ○ | Pre-signed AWS S3 URL used when uploading a file from the device. Issued by AWS function. Includes a signature to authenticate the upload-only user. **Temporary URL — set to expire in seconds.** |
| `upload_id` | ○ | ID to uniquely identify the file upload process. Required for the 2.7 API call. |

**Pre-signed URL properties:**
```
- Issued by AWS (S3 pre-signed URL)
- Contains embedded signature → upload-only permission
- Has a configurable expiry time (in seconds)
- Points to TEMPORARY S3 storage location
- Must be used before expiry
- After successful 2.7 API call → file is copied to regular storage
- If 2.7 API call fails → file may remain in temporary S3
  → Auto-deleted after a period configured in S3 settings
```

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
| `4000` | 必須項目が入力されていません。 | A required field in the request header is not specified. Key Required Error | Ensure `X-NASAPI-Device-Subkey` header is present and `{dev_id}` is in the URI |
| `4002` | 必須項目が入力されていません。 | The request parameter item exists, but the value is not specified. Required error for value | Ensure all required field values are non-empty. |
| `4004` | 入力可能な桁数を超過しています。 | Error in the number of digits of the device ID or MAC address | Check field lengths |
| `4005` | 入力された文字種が不正です。 | Character type error in device ID or MAC address | Check for invalid characters |
| `4006` | フォーマットエラーが発生しました。 | MAC address format error | Verify MAC address format (e.g., `AA:BB:CC:DD:EE:FF`) |

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
| `5001` | システムエラーが発生しました。 | Failed to acquire constant information from the system master |
| `5002` | システムエラーが発生しました。 | Failed to generate file upload ID |
| `5003` | システムエラーが発生しました。 | Failed to connect to S3 |
| `5004` | システムエラーが発生しました。 | Failed to issue the URL for file upload |
| `5005` | システムエラーが発生しました。 | Failed to register new file upload information |

---

## Business Rules Summary (always enforce)

### Authentication
- `dev_id` (URI path) + `X-NASAPI-Device-Subkey` (MAC address header)
- No SHA-256 signature required
- Mismatch with registered record → `4012`

### Upload URL Lifecycle
```
1. Call this API → receive upload_url + upload_id
2. upload_url expires after a configured number of seconds
3. Use upload_url to PUT file to S3 BEFORE it expires
4. Call 2.7 API with upload_id to complete the process
5. If 2.7 API fails → file stuck in temporary S3 → auto-deleted per S3 config
```

### upload_url Usage Constraints
```
- upload_url is for UPLOAD ONLY (signature restricts to upload permission)
- upload_url is TEMPORARY — do not cache or reuse across sessions
- Always call this API fresh before each upload attempt
- If upload_url has expired → call this API again to get a new one
```

### upload_id Usage
```
- upload_id uniquely identifies this specific upload process
- Must be passed to the 2.7 API after completing the S3 upload
- Do not reuse upload_id across different upload attempts
```

### Temporary S3 Behavior
```
Upload destination = TEMPORARY S3 location
  → Only becomes permanent after successful 2.7 API call
  → On 2.7 failure: file remains in temporary S3
  → Temporary files auto-deleted by S3 lifecycle settings
  → No manual cleanup required from device side
```

### 4002 Status
```
4002 appears struck through in some spec revisions but is still
present in reference images → Treat as ACTIVE unless explicitly deprecated.
Ensure all required field values are non-empty when sending requests.
```

---

## Response Principles

1. Always treat `upload_url` as short-lived — never reuse across sessions or retry attempts
2. Always pair this API call with a subsequent 2.7 API call using the returned `upload_id`
3. On 500-series errors, use `error_id` to pinpoint the failed S3 operation (connect / issue URL / register)
4. If `upload_url` expiry causes upload failure, instruct caller to re-invoke this API for a fresh URL
5. Treat `4002` as active unless explicitly deprecated

> **⚠️ AI Note — Unusual Response Key Name:** The success response field key is literally `Success. upload_url` (with space and period). When parsing JSON, use `data["Success. upload_url"]` — do NOT normalize or strip the key name.

---

## Related SKILLs (API Call Flow)

| Order | SKILL | File | Relationship |
|-------|-------|------|-------------|
| Next (required) | 2.7 File Upload Completion | `/adminlink-upload-notify` | After S3 PUT, call 2.7 with `upload_id` to finalize |
| Prerequisite | 2.2 Device Registration | `/adminlink-register-device` | Device must be registered |

---

## 對照流程（Cloud Linkage Flow）

端到端流程位置（引述對照用，**非權威**；規格仍以本 SKILL 為準）：

- [`08_file_upload_flow.md`](../../../spec/docs/agent_cloud_linkage_flow/08_file_upload_flow.md) — Flow 8 STEP 1：取上傳 pre-signed URL
- [`05_change_dev_setting_flow.md`](../../../spec/docs/agent_cloud_linkage_flow/05_change_dev_setting_flow.md) — Flow 5：設定檔 / 設定狀態 JSON 上傳
- 索引：[`agent_cloud_linkage_flow/INDEX.md`](../../../spec/docs/agent_cloud_linkage_flow/INDEX.md)
