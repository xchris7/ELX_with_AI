---
name: adminlink-auth-info
description: >
  Use this SKILL whenever the user needs to call, test, debug, validate, or
  generate code for the Authentication Information Acquisition API
  (GET /v1/devices/{dev_id}/auth).
  Triggers include: building the Authorization header, generating the SHA-256
  signature, acquiring IoT Core credentials, handling MQTT/HTTPS connection
  parameters, or diagnosing authentication errors from this API.
---

# SKILL: Authentication Information Acquisition API

## Trigger Conditions

Use this SKILL when the user asks to:
- Call or implement the Authentication Information Acquisition API
- Generate or validate the Authorization header (SHA-256 signature)
- Retrieve IoT Core connection credentials (certificates, endpoint, topics)
- Configure MQTT or HTTPS connection parameters after authentication
- Diagnose an error response from this API

---

## API Overview

| Item | Value |
|------|-------|
| URI | `https://api.admin-link.net/v1/devices/{dev_id}/auth` |
| Method | `GET` |
| Accept-Language | `jp` |
| Purpose | Called by the device to acquire authentication information to connect to the IoT Core of this service |

> `{dev_id}` in the URI must be replaced with the actual Device ID of the calling device.

---

## Execution Steps

### Step 1 — Build the Authorization Header

This API uses a custom SHA-256 signature for authentication. The Authorization header must be constructed as follows:

#### Signature Formula

```
signature = SHA-256( lowercase( dev_id + "-" + mac_adr + "-" + current_time ) )
Authorization = signature + "&se=" + current_time
```

#### Field Definitions

| Field | Description |
|-------|-------------|
| `dev_id` | Device ID (same value used in the URI path) |
| `mac_adr` | Representative MAC address of the device |
| `current_time` | Current time as UNIX timestamp (integer) |

#### Step-by-step

1. Concatenate: `{dev_id}-{mac_adr}-{current_time}`
2. Convert entire string to **lowercase**
3. Compute **SHA-256** hash of the lowercase string
4. Append `&se={current_time}` to the hash result
5. Set the full string as the `Authorization` request header

#### Example

```
dev_id       : NAS001
mac_adr      : 00:01:8E:AA:BB:CC:DD:EE
current_time : 1467298800

Step 1 — Concatenate:
  NAS001-00:01:8E:AA:BB:CC:DD:EE-1467298800

Step 2 — Lowercase:
  nas001-00:01:8e:aa:bb:cc:dd:ee-1467298800

Step 3 — SHA-256:
  0d5194de82b015d76c13a7858e835ae679312ba2e0e7640581d65e0ec85fc5c8

Step 4 — Append &se:
  0d5194de82b015d76c13a7858e835ae679312ba2e0e7640581d65e0ec85fc5c8&se=1467298800

Step 5 — Set as Authorization header:
  Authorization: 0d5194de82b015d76c13a7858e835ae679312ba2e0e7640581d65e0ec85fc5c8&se=1467298800
```

**PHP reference:**
```php
$signature = hash('sha256', strtolower($dev_id . '-' . $mac_adr . '-' . $current_time));
$authorization = $signature . '&se=' . $current_time;
```

---

### Step 2 — Send the Request

**curl example:**
```bash
DEV_ID="NAS001"
MAC_ADR="00:01:8e:aa:bb:cc:dd:ee"
CURRENT_TIME=$(date +%s)
INPUT="${DEV_ID}-${MAC_ADR}-${CURRENT_TIME}"
LOWER=$(echo -n "$INPUT" | tr '[:upper:]' '[:lower:]')
HASH=$(echo -n "$LOWER" | sha256sum | awk '{print $1}')
AUTH="${HASH}&se=${CURRENT_TIME}"

curl -X GET "https://api.admin-link.net/v1/devices/${DEV_ID}/auth" \
  -H "Authorization: ${AUTH}" \
  -H "Accept-Language: jp"
```

**Python example:**
```python
import hashlib
import time
import requests

dev_id = "NAS001"
mac_adr = "00:01:8e:aa:bb:cc:dd:ee"
current_time = int(time.time())

raw = f"{dev_id}-{mac_adr}-{current_time}".lower()
signature = hashlib.sha256(raw.encode()).hexdigest()
authorization = f"{signature}&se={current_time}"

url = f"https://api.admin-link.net/v1/devices/{dev_id}/auth"
headers = {
    "Authorization": authorization,
    "Accept-Language": "jp"
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    data = response.json()
    print("Authentication successful")
    print(f"IoT Core endpoint : {data['iotcore_endpoint']}")
    print(f"Thing name        : {data['iotcore_thingname']}")
else:
    error = response.json()
    print(f"Error {response.status_code}: [{error['error_id']}] {error['error_msg']}")
```

---

### Step 3 — Handle the Response

#### HTTP Status Codes

| Status | Description | Meaning |
|--------|-------------|---------|
| `200` | OK | Authentication succeeded |
| `400` | Bad Request | Authorization parameter specification is incorrect |
| `401` | Unauthorized | Failed authentication |
| `405` | Method Not Allowed | Error in API invocation method |
| `500` | Internal Server Error | Program error or database error |

---

#### Success (HTTP 200) — Response Body (JSON)

| Key | Required | Description |
|-----|----------|-------------|
| `iotcore_ca_cert` | ○ | Root CA certificate string |
| `iotcore_client_cert` | ○ | Device certificate string |
| `iotcore_client_key` | ○ | Device private key string |
| `iotcore_endpoint` | ○ | Host name used to connect to IoT Core |
| `iotcore_thingname` | ○ | Thing name (device ID) used to connect to IoT Core |
| `iotcore_retry_max` | ○ | Maximum number of retries when IoT Core connection fails |
| `iotcore_retry_interval` | ○ | Retry interval (seconds) when IoT Core connection fails |
| `iotcore_x509_endpoint` | ○ | Host name to issue tokens for IoT Core connection |
| `iotcore_x509_role_alias` | ○ | Role alias used to connect to IoT Core |
| `iotcore_topic_upload` | ○ | Path of the topic used to send messages |
| `iotcore_topic_receive` | ○ | Path of the topic used to receive remote control instructions |
| `https_read_timeout_ms` | ○ | Read timeout time for HTTPS communication (ms) |
| `mqtt_read_timeout_ms` | ○ | Read timeout time for MQTT communication (ms) |
| `mqtt_command_timeout_ms` | ○ | MQTT command response wait timeout (ms) |
| `mqtt_keepalive_interval` | ○ | MQTT keep-alive interval with server |
| `mqtt_upload_qos` | ○ | QoS level when sending MQTT messages |
| `mqtt_receive_qos` | ○ | QoS level when receiving MQTT messages |

---

#### Error (non-200) — Response Body (JSON)

| Key | Required | Description |
|-----|----------|-------------|
| `error_id` | ○ | Error ID to identify the error type |
| `error_msg` | ○ | Error message when an error occurs |
| `error_field` | — | ID of the item where the error occurred in request parameter check |
| `error_value` | — | Value of the item where the error occurred in request parameter check |

---

### Step 4 — Diagnose Errors

#### HTTP 400 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4000` | 必須項目が入力されていません。 | A required field in the request header is not specified. Key Required Error | Ensure `Authorization` header is present |
| `4001` | 必須項目が入力されていません。 | ~~A required field in the request parameter (Authorization) has not been specified~~ *(deprecated — struck through in spec)* | [needs confirmation] |
| `4002` | 必須項目が入力されていません。 | The request parameter item exists, but the value is not specified. Required error for value | Ensure `Authorization` header value is not empty |
| `4005` | 入力された文字種が不正です。 | Character type error | Check for invalid characters in the Authorization string |

#### HTTP 401 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `4012` | デバイス情報が登録されていません。 | The device with the same device ID is not registered | Verify `dev_id` exists and is registered in the system |
| `4014` | 認証に失敗しました。 | Failed to authenticate by Authorization signature | Recompute the SHA-256 signature; verify `dev_id`, `mac_adr`, and `current_time` are correct |

#### HTTP 405 errors

| error_id | Error Message (JP) | Meaning | Fix |
|----------|--------------------|---------|-----|
| `405` | 呼び出し方法に誤りがあります。 | 405 error occurred | Verify the HTTP method is GET, not POST or others |

#### HTTP 500 errors

| error_id | Error Message (JP) | Meaning |
|----------|--------------------|---------|
| `5000` | システムエラーが発生しました。 | A 500 error occurred |
| `5001` | システムエラーが発生しました。 | Failed to connect to IoT Core |
| `5002` | システムエラーが発生しました。 | Failed to delete the device certificate of IoT Core |
| `5003` | システムエラーが発生しました。 | Failed to register the device in IoT Core |
| `5004` | システムエラーが発生しました。 | Failed to generate device private key and CSR |
| `5005` | システムエラーが発生しました。 | Failed to issue device certificate for IoT Core |
| `5006` | システムエラーが発生しました。 | Failed to bind the device certificate of IoT Core |
| `5007` | システムエラーが発生しました。 | Failed to register new device certificate information |
| `5008` | システムエラーが発生しました。 | Failed to delete device certificate information |

---

## Business Rules Summary (always enforce)

### Authorization Signature Rules
```
Input  : dev_id + "-" + mac_adr + "-" + current_time
Process: strtolower() → sha256()
Output : {hash}&se={current_time}
```
- The concatenated string must be converted to **lowercase before** hashing
- `current_time` must be a UNIX timestamp (integer seconds)
- The same `current_time` value used in the hash must also appear in `&se=`

### URI Path Rule
- `{dev_id}` in the URI must exactly match the `dev_id` used in the Authorization signature computation
- Mismatch between URI `dev_id` and signature `dev_id` will cause `4014` authentication failure

### Common Signature Mistakes → `4014`
| Mistake | Result |
|---------|--------|
| Forgot `strtolower()` | Hash mismatch → 4014 |
| Used different `current_time` in hash vs `&se=` | Hash mismatch → 4014 |
| MAC address case mismatch (uppercase in signature) | Hash mismatch → 4014 |
| URI `dev_id` ≠ signature `dev_id` | Hash mismatch → 4014 |
| Stale `current_time` (clock skew) | May cause 4014 — use fresh timestamp per call |

### IoT Core Connection Flow (after successful 200)
Use the returned credentials in this order:
```
1. iotcore_ca_cert       → Root CA for TLS verification
2. iotcore_client_cert   → Device certificate for mutual TLS
3. iotcore_client_key    → Device private key for mutual TLS
4. iotcore_endpoint      → MQTT broker host
5. iotcore_thingname     → Client ID / Thing name
6. iotcore_topic_upload  → Publish topic
7. iotcore_topic_receive → Subscribe topic
8. mqtt_upload_qos       → QoS for publish
9. mqtt_receive_qos      → QoS for subscribe
10. mqtt_keepalive_interval → Keep-alive setting
```

---

## Response Principles

1. Always show the full Authorization header construction steps when debugging `4014` errors
2. Never assume the MAC address case — always confirm it is lowercased before hashing
3. When a 500-series error occurs, identify the specific sub-error from `error_id` to pinpoint the IoT Core operation that failed
4. `4001` is struck through in the spec (deprecated) — if encountered, flag as [needs confirmation] rather than relying on it
5. All response fields on HTTP 200 are required (○) — if any are missing, treat as a server-side error

---

## Related SKILLs (API Call Flow)

| Order | SKILL | File | Relationship |
|-------|-------|------|-------------|
| Prerequisite | 2.2 Device Registration | `/adminlink-register-device` | Device must be registered before calling this API |
| Next | 2.4 Registration Confirmation | `/adminlink-confirm-registration` | Confirm registration and get permission flags |
| Uses credentials for | MQTT/IoT Core Connection | — | Returned certs and endpoints used for MQTT messaging |
