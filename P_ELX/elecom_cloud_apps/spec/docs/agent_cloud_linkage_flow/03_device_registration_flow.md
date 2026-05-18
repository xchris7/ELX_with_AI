# 3. Device Registration Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `3.Device registration flow`
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT2_Agent.md`](../../current/SPEC_v2_AGT2_Agent.md) · 對照 API SKILL：`/adminlink-register-device`

---

## Scope & Roles

| Side | Component | Owner |
|---|---|---|
| **Device** | AdminLink Daemon | **OURS (ELECOM)** — WAB-BE follows AP flow |
| **Cloud (AWS)** | Agent API + Database | **NOT OURS** — per WebAPI spec |

## Execution Timing
- When the user presses the **registration button** on the device registration UI
- **Prerequisite**: Flow 2 (Device entry startup) has completed, and required input items are entered

## Diagram 1 — Flowchart

```mermaid
flowchart TD
    Start([🚀 START<br/>Registration button pressed])
    Start --> Check1["✅ Device side:<br/>Mandatory / digits /<br/>character type check"]
    Check1 --> Check2["✅ Device side:<br/>Product serial number check"]
    Check2 --> Num["🆕 Device side:<br/>Device ID numbering"]
    Num --> Auto["📦 Device side:<br/>Get MAC etc.<br/>auto-setting items"]
    Auto --> CallAPI[["📡 Device side:<br/>Call Device Registration API<br/><br/>Send: device reg code,<br/>product serial number,<br/>management name, device ID,<br/>auto-setting items"]]

    CallAPI --> Cloud[("☁️ Cloud AWS<br/>Agent API + DB<br/>⚠️ NOT our scope")]
    Cloud --> Status{{"HTTP<br/>Status?"}}

    Status -->|"Other status<br/>(refer to WebAPI spec)"| Err["⚠️ Device side:<br/>Error indication"]
    Err --> Clear["🗑️ Device side:<br/>Clear Device ID"]
    Clear --> EndA([END])

    Status -->|"201<br/>created/success"| Flag{{"Device ID<br/>change flag?"}}
    Flag -->|"Flag = 0<br/>no change"| Timing
    Flag -->|"Flag = 1<br/>changed"| Overwrite["✏️ Device side:<br/>Overwrite local Device ID"]
    Overwrite --> Timing

    Timing["⏱️ Device side:<br/>Calculate and retain<br/>periodic info transmission timing"]
    Timing --> EndB([END])

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000

    class Check1,Check2,Num,Auto,CallAPI,Err,Clear,Overwrite,Timing deviceSide
    class Cloud cloudSide
    class Status,Flag decision
```

## Diagram 2 — Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant User as 👤 User
    participant Agent as 📱 Device Side<br/>AdminLink Daemon (OURS)
    participant API as ☁️ Cloud AWS<br/>Agent API (NOT OURS)
    participant DB as 🗄️ Cloud AWS<br/>Database (NOT OURS)

    User->>Agent: Press registration button
    Agent->>Agent: ✅ Mandatory / digits / character type check
    Agent->>Agent: ✅ Product serial number check
    Agent->>Agent: 🆕 Device ID numbering
    Agent->>Agent: 📦 Get MAC etc. auto-setting items

    Agent->>+API: Device Registration API<br/>(reg code, serial, mgmt name,<br/>device ID, auto-set items)
    API->>+DB: Register device
    DB-->>-API: Result + change flag
    API-->>-Agent: Response

    alt HTTP 201 (success) + Flag=0
        Agent->>Agent: Keep current Device ID
        Agent->>Agent: ⏱️ Calculate & retain periodic timing
    else HTTP 201 (success) + Flag=1
        Agent->>Agent: ✏️ Overwrite local Device ID
        Agent->>Agent: ⏱️ Calculate & retain periodic timing
    else Other status
        Agent->>Agent: ⚠️ Error indication
        Agent->>Agent: 🗑️ Clear Device ID
    end
```

## Key Notes
1. **Pre-API validation**: Mandatory / digits / character type check and product serial number check are performed on the device side before calling the API.
2. **Items sent**: device registration code, product serial number, management name, device ID, auto-setting items (MAC etc.).
3. **Success = HTTP 201** (not 200).
4. **On failure**: error indication + clear Device ID.
5. **On success**: calculate and retain timing for periodic info transmission (used by Flow 6).
6. Detailed error handling per status / error ID → refer to WebAPI specification.

## Done When
- All input checks pass before API call
- Device is registered in cloud DB (HTTP 201)
- Local Device ID is overwritten if change flag = 1
- Periodic transmission timing is calculated and stored for subsequent flows