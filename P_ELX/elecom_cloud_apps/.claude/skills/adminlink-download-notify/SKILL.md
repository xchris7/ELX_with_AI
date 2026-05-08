---
name: adminlink-download-notify
description: >
  Use this SKILL whenever the user needs to call, test, debug, validate, or
  generate code for the File Download Completion Notification API
  (POST /v1/devices/{dev_id}/downloadnotify).
  Triggers include: notifying the service that a file download from S3 is
  complete, submitting download_id after a successful S3 GET, or diagnosing
  errors from this API.
  This API is Step 2 of the 2-step file download flow — must be called AFTER
  the file has been successfully downloaded from S3 using the URL from the
  2.8 API.
  NextGiga support: No changes to specifications, but file download targets
  are added.
---

# SKILL: File Download Completion Notification API (2.9)

## Trigger Conditions

Use this SKILL when the user asks to:
- Notify the service that a file download from S3 is complete
- Submit `download_id` after a successful S3 file GET
- Trigger deletion of the temporary S3 file after download
- Diagnose an error response from this API

---

## API Overview

| Item | Value |
|------|-------|
| URI | `https://api.admin-link.net/v1/devices/{dev_id}/downloadnotify` |
| Method | `POST` |
| X-NASAPI-Device-Subkey | MAC address of the device |
| Content-Type | `application/json` |
| Purpose | Called by the device to notify the Service that the file download is complete |

> `{dev_id}` in the URI must be replaced with the actual Device ID of the calling device.
> This API shall be called after each file download performed on the device side by remote control instructions for firmware update, remote setting, and setting restoration.

---

## File Download Workflow Context

This API is **Step 2 of a 2-step download flow**:

```
Step 1 — Call 2.8 API → get download_url
Step 2 — GET file from S3 using download_url
Step 3 — Call THIS API (2.9) with download_id
  → Notifies service of download completion
  → Service deletes file from temporary S3
  → If this call fails → file remains in temporary S3
     → Auto-deleted after a period per S3 settings
```

> ⚠️ Always call this API immediately after a successful S3 file download.

---

## Execution Steps

### Step 1 — Prepare the Request Body

| Key | Required | Max Length | Description |
|-----|----------|------------|-------------|
| `download_id` | ○ | 255 half-width chars | File download ID. Must be the same ID set when requesting the URL Acquisition API for file download (2.8 API). |

---

### Step 2 — Build the Request

| Header | Value |
|--------|-------|
| `X-NASAPI-Device-Subkey` | Representative MAC address of the device |
| `Content-Type` | `application/json` |

---

### Step 3 — Send the Request

**curl example:**
```bash
DEV_ID="NAS001"
MAC_ADR="AA:BB:CC:DD:EE:FF"
DOWNLOAD_ID="DOWNLOAD_ID_FROM_CLOUD"

curl -X POST "https://api.admin-link.net/v1/devices/${DEV_ID}/downloadnotify" \
  -H "X-NASAPI-Device-Subkey: ${MAC_ADR}" \
  -H "Content-Type: application/json" \
  -d '{
    "download_id": "DOWNLOAD_ID_FROM_CLOUD"
  }'
```

**Python example:**
```python
import requests

dev_id = "NAS001"
mac_adr = "AA:BB:CC:DD:EE:FF"
download_id = "DOWNLOAD_ID_FROM_CLOUD"

url = f"https://api.admin-link.net/v1/devices/{dev_id}/downloadnotify"
headers = {
    "X-NASAPI-Device-Subkey": mac_adr,
    "Content-Type": "application/json"
}
payload = {
    "download_id": download_id
}

response = requests.post(url, json=payload, headers=headers)

if response.status_code == 200:
    print("File download completion notification successful")
    # Response body is empty JSON {} — no fields to read
else:
    error = response.json()
    print(f"Error {response.status_code}: [{error['error_id']}] {error['error_msg']}")
```

---

### Step 4 — Handle the Response

#### HTTP Status Codes

| Status | Description | Meaning |
|--------|-------------|---------|
| `200` | OK | File download completion notification succeeds |
| `400` | Bad Request | One of the input parameters is not specified or the format is invalid |
| `401` | Unauthorized | Failed to confirm registration by device ID and MAC address (device not registered) |
| `405` | Method Not Allowed | Error in the API invocation method |
| `500` | Internal Server Error | Program error or database error |

---

#### Success (HTTP 200) — Response Body

```
Empty JSON is returned. ({})
```

> No fields to parse on success. A `200` status alone confirms the notification was received and the temporary S3 file will be deleted.

---

#### Error (non-200) — Response Body (JSON)

| Key | Required | Description |
|-----|----------|-------------|
| `error_id` | ○ | ID to notify the agent of the error details when an error occurs |
| `error_msg` | ○ | Error message when an error occurs |
| `error_field` | — | ID of the item where an error occurs in the request parameter item check |
| `error_value` | — | Value of the item where an error occurs in the request parameter item check |

---

### Step 5 — Diagnose Errors

#### HTTP 400 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4000` | 必須項目が入力されていません。 | A required field in the request header is not specified. Key Required Error | Ensure `X-NASAPI-Device-Subkey` is present and `{dev_id}` is in the URI |
| `4002` | 必須項目が入力されていません。 | The request parameter item exists, but the value is not specified. Required error for value | Ensure `download_id` has a non-empty value |
| `4004` | 入力可能な桁数を超過しています。 | Number of digits error | Check `download_id` length (≤255 chars) |
| `4005` | 入力された文字種が不正です。 | Character type error | Check for invalid characters in any field |
| `4006` | フォーマットエラーが発生しました。 | MAC address format error | Verify MAC address format (e.g., `AA:BB:CC:DD:EE:FF`) |

#### HTTP 401 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4012` | デバイス情報が登録されていません。 | Device information with the same device ID and MAC address is not registered | Verify `dev_id` and MAC address match a registered device |
| `4014` | ファイルダウンロード情報が登録されていません。 | The file download information with the same file download ID has not been registered | Verify `download_id` matches what was used in the 2.8 API; do not reuse expired or already-completed download IDs |

#### HTTP 405 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `405` | 呼び出し方法に誤りがあります。 | 405 error occurred | Verify HTTP method is `POST` |

#### HTTP 500 errors

| error_id | Error Message (JP) | Meaning |
|----------|--------------------|---------|
| `5000` | システムエラーが発生しました。 | A 500 error occurred |
| `5001` | システムエラーが発生しました。 | Failed to update the file download information |

---

## Business Rules Summary (always enforce)

### Call Order Dependency
```
MUST follow this sequence:
  1. Call 2.8 API → get download_url
  2. GET file from S3 using download_url
  3. Call THIS API (2.9) with download_id → triggers S3 cleanup

Do NOT call this API before the S3 download completes.
Do NOT skip this API after a successful S3 download.
```

### download_id Rules
```
- Must be the exact download_id received from the cloud remote control instruction
- Must match the download_id used in the 2.8 API call
- Each download_id is single-use — do not reuse
- Using an invalid or already-completed download_id → 4014
```

### Authentication
```
dev_id      → URI path
MAC address → X-NASAPI-Device-Subkey header
No SHA-256 signature required
Mismatch → 4012
```

### Success Response
```
HTTP 200 → empty JSON body {}
No fields to parse — treat 200 status alone as confirmation of success
```

### Temporary S3 Cleanup on Success
```
On successful 200 response:
  → Service deletes the file from temporary S3 storage
On failure (non-200):
  → File remains in temporary S3
  → Auto-deleted per S3 lifecycle configuration
  → Device should retry or escalate
```

### NextGiga Support Note
```
No changes to the specifications for this API.
File download targets are added on the NextGiga side.
```

---

## Response Principles

1. Always verify the S3 GET succeeded before calling this API
2. Use the `download_id` exactly as received from the cloud — no modification
3. On `4014`, do not retry with the same `download_id` — re-initiate from the 2.8 API
4. A `200` response with empty JSON is normal and expected — no parsing needed
5. On 500 `5001`, the download record update failed — escalate as the file may still be in temporary S3

---

## Related SKILLs (API Call Flow)

| Order | SKILL | File | Relationship |
|-------|-------|------|-------------|
| Prerequisite (required) | 2.8 URL Acquisition for Download | `/adminlink-download-url` | Must call 2.8 first to get `download_url` |
| Prerequisite | 2.2 Device Registration | `/adminlink-register-device` | Device must be registered |
