# 4. Device Deregistration Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `4.Device deregistration flow`
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT2_Agent.md`](../../current/SPEC_v2_AGT2_Agent.md) · 對照 API SKILL：`/adminlink-unregister-device`

---

## Scope & Roles

| Side | Component | Owner |
|---|---|---|
| **Device** | AdminLink Daemon | **OURS (ELECOM)** — WAB-BE follows AP flow |
| **Cloud (AWS)** | Agent API + IoT Core + DB | **NOT OURS** — per WebAPI spec |

## Execution Timing
- When the user presses the **deregistration button**

## Diagram 1 — Flowchart

```mermaid
flowchart TD
    Start([🚀 START<br/>Deregistration button pressed])
    Start --> Check{{"Local<br/>Device ID<br/>exists?"}}
    Check -->|"No"| EndA([END])
    Check -->|"Yes"| Call[["📡 Device side:<br/>Call Device Unregister API"]]

    Call --> Cloud[("☁️ Cloud AWS<br/>⚠️ NOT our scope<br/><br/>Deletes:<br/>• AWS IoT Core auth info<br/>• Database records")]
    Cloud --> Status{{"HTTP<br/>Status?"}}

    Status -->|"Other status<br/>(refer to WebAPI spec)"| Err["⚠️ Device side:<br/>Error indication"]
    Err --> EndB([END])

    Status -->|"200<br/>success"| Clear["🗑️ Device side:<br/>Clear local Device ID"]
    Clear --> EndC([END])

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000

    class Call,Err,Clear deviceSide
    class Cloud cloudSide
    class Check,Status decision
```

## Diagram 2 — Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant User as 👤 User
    participant Agent as 📱 Device Side<br/>AdminLink Daemon (OURS)
    participant API as ☁️ Cloud AWS<br/>Agent API (NOT OURS)
    participant IoT as 🔐 AWS IoT Core (NOT OURS)
    participant DB as 🗄️ Database (NOT OURS)

    User->>Agent: Press deregistration button
    Agent->>Agent: Check local Device ID

    alt No Device ID
        Note over Agent: END
    else Device ID exists
        Agent->>+API: Device Unregister API
        API->>IoT: 🗑️ Delete authentication info
        API->>DB: 🗑️ Delete device records
        API-->>-Agent: Response

        alt HTTP 200 (success)
            Agent->>Agent: 🗑️ Clear local Device ID
        else Other status
            Agent->>Agent: ⚠️ Error indication
        end
    end
```

## Key Notes
1. **Cloud-side cleanup is automatic**: When the Unregister API is called, the cloud deletes both AWS IoT Core authentication info **and** database records. We do not manage this.
2. **Local cleanup is our responsibility**: Clear the local Device ID only on HTTP 200 success.
3. **No local clear on error**: Keep the local Device ID so the user can retry.
4. Detailed error handling per status / error ID → refer to WebAPI specification.

## Done When
- Cloud-side IoT Core auth and DB records are deleted (cloud responsibility)
- Local Device ID is cleared on success
- Error is indicated to user on failure (local Device ID retained for retry)