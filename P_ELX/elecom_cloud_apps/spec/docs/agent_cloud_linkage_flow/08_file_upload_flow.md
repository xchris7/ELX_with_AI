# 8. File Upload Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `8.File upload flow`
> **Used by**: Flow 5（setting file upload）· Remote control 4010/4020/4030/4040
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT2_Agent.md`](../../current/SPEC_v2_AGT2_Agent.md) · 對照 API SKILL：`/adminlink-upload-url`, `/adminlink-upload-notify`

---

## Scope & Roles

| Side | Component | Owner |
|---|---|---|
| **Device** | AdminLink Daemon | **OURS (ELECOM)** |
| **Cloud (AWS)** | Agent API + S3 | **NOT OURS** — per WebAPI spec |

## Execution Timing
- **From Flow 5**: setting file upload, configuration status JSON upload
- **From Flow 7 remote control**:
  - 4010 — Upload debug log
  - 4020 — Upload log
  - 4030 — Upload configuration file
  - 4040 — Upload connection client file
- Any other upload need

## Diagram 1 — Flowchart

```mermaid
flowchart TD
    Start([🚀 START<br/>Upload request received])
    Start --> GetURL[["📡 Device side:<br/>Call File Upload URL<br/>Acquisition API<br/>(with file upload type)"]]
    GetURL --> Cloud1[("☁️ Cloud AWS<br/>Agent API")]
    Cloud1 --> Status1{{"HTTP<br/>Status?"}}

    Status1 -->|"Not 200<br/>(refer to WebAPI spec)"| EndA([END / error])
    Status1 -->|"200<br/>success"| Got["📥 Received:<br/>S3 pre-signed URL<br/>+ file upload ID"]

    Got --> PUT["⬆️ Device side:<br/>HTTP PUT file<br/>to received S3 URL<br/>(temp location)"]
    PUT --> S3[("☁️ AWS S3<br/>temp location")]
    S3 --> PUTStatus{{"PUT<br/>success?"}}
    PUTStatus -->|"No"| EndB([END / error])
    PUTStatus -->|"Yes"| Notify

    Notify[["📡 Device side:<br/>Call File Upload Completion<br/>Notification API<br/>(file upload ID + type)"]]
    Notify --> Cloud2[("☁️ Cloud AWS<br/>Move file from temp<br/>→ regular storage")]
    Cloud2 --> Status2{{"HTTP<br/>Status?"}}
    Status2 -->|"Not 200<br/>(refer to WebAPI spec)"| EndC([END / error])
    Status2 -->|"200<br/>success"| EndD([END / success])

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000

    class GetURL,Got,PUT,Notify deviceSide
    class Cloud1,S3,Cloud2 cloudSide
    class Status1,PUTStatus,Status2 decision
```

## Diagram 2 — Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Agent as 📱 Device Side (OURS)
    participant API as ☁️ Cloud AWS<br/>Agent API (NOT OURS)
    participant S3 as 🗄️ AWS S3 (NOT OURS)

    Note over Agent: Trigger: Flow 5 / rc 4010-4040 / other upload need

    Agent->>+API: File Upload URL Acquisition API<br/>(file upload type)
    API-->>-Agent: 200 + S3 pre-signed URL + file upload ID

    Agent->>+S3: HTTP PUT file → temp location<br/>(using pre-signed URL)
    S3-->>-Agent: 200 OK

    Agent->>+API: File Upload Completion Notification API<br/>(file upload ID + type)
    API->>S3: Move file: temp → regular storage
    API-->>-Agent: 200 OK
```

## Key Notes
1. **3-step pattern**: get URL → PUT to S3 → notify completion. All three are required.
2. **File upload type** must be specified — determines destination and post-processing on cloud side.
3. **Temp → regular** move happens only after completion notification. If you skip the notification, the file is orphaned.
4. **Reusable**: This flow is called by Flow 5 and by remote control commands 4010/4020/4030/4040.
5. Detailed error handling per status / error ID → refer to WebAPI specification.

## Done When
- Pre-signed URL acquired
- File successfully PUT to S3 temp location
- Completion notification sent and acknowledged
- Cloud has moved the file to regular storage