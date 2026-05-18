# 9. File Download Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `9.File download flow`
> **Used by**: Remote control 2010（firmware update）
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT2_Agent.md`](../../current/SPEC_v2_AGT2_Agent.md) · 對照 API SKILL：`/adminlink-download-url`, `/adminlink-download-notify`

---

## Scope & Roles

| Side | Component | Owner |
|---|---|---|
| **Device** | AdminLink Daemon | **OURS (ELECOM)** |
| **Cloud (AWS)** | Agent API + S3 | **NOT OURS** — per WebAPI spec |

## Execution Timing
- **From Flow 7 remote control**:
  - 2010 — Firmware update (params: file download ID + expected hash)

## Diagram 1 — Flowchart

```mermaid
flowchart TD
    Start([🚀 START<br/>Download request<br/>file download ID + expected hash])
    Start --> GetURL[["📡 Device side:<br/>Call File Download URL<br/>Acquisition API<br/>(with file download ID)"]]
    GetURL --> Cloud1[("☁️ Cloud AWS<br/>Agent API")]
    Cloud1 --> Status1{{"HTTP<br/>Status?"}}

    Status1 -->|"Not 200<br/>(refer to WebAPI spec)"| EndA([END / error])
    Status1 -->|"200<br/>success"| Got["📥 Received:<br/>S3 pre-signed URL"]

    Got --> GET["⬇️ Device side:<br/>HTTP GET file<br/>from received S3 URL"]
    GET --> S3[("☁️ AWS S3")]
    S3 --> GETStatus{{"GET<br/>success?"}}
    GETStatus -->|"No"| EndB([END / error])
    GETStatus -->|"Yes"| Verify

    Verify["🔍 Device side:<br/>Calculate hash of<br/>downloaded file"]
    Verify --> HashCheck{{"Calculated hash<br/>=<br/>Expected hash?"}}
    HashCheck -->|"❌ Mismatch"| Abort["⚠️ Device side:<br/>Abort / error<br/>(discard file)"]
    Abort --> EndC([END / error])
    HashCheck -->|"✅ Match"| Use["⚙️ Device side:<br/>Use file<br/>(e.g. firmware update)"]
    Use --> EndD([END / success])

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000

    class GetURL,Got,GET,Verify,Abort,Use deviceSide
    class Cloud1,S3 cloudSide
    class Status1,GETStatus,HashCheck decision
```

## Diagram 2 — Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Agent as 📱 Device Side (OURS)
    participant API as ☁️ Cloud AWS<br/>Agent API (NOT OURS)
    participant S3 as 🗄️ AWS S3 (NOT OURS)

    Note over Agent: Trigger: rc 2010 — params: file download ID + expected hash

    Agent->>+API: File Download URL Acquisition API<br/>(file download ID)
    API-->>-Agent: 200 + S3 pre-signed URL

    Agent->>+S3: HTTP GET file<br/>(using pre-signed URL)
    S3-->>-Agent: File content

    Agent->>Agent: 🔍 Calculate hash

    alt Hash matches expected
        Agent->>Agent: ⚙️ Use file (firmware update etc.)
    else Hash mismatch ❌
        Agent->>Agent: ⚠️ Abort / discard file
    end
```

## Key Notes
1. **2-step pattern**: get URL → GET from S3. No completion notification (unlike upload).
2. **⚠️ Hash verification is mandatory**: Always verify the downloaded file's hash against the expected hash received with the command. Mismatch = abort.
3. **Primary use case**: Firmware update via remote control 2010.
4. **No notification back to cloud**: The cloud already knows what file it served. Completion is reported via the Flow 7 execution completed event.
5. Detailed error handling per status / error ID → refer to WebAPI specification.

## Done When
- Pre-signed URL acquired
- File successfully downloaded from S3
- Hash verified to match expected value
- File used (e.g. firmware update applied) only after hash match
