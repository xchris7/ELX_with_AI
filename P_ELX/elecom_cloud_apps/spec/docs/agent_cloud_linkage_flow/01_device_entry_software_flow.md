# 1. Device Entry / Software Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `1.Device entry_software flow`
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT2_Agent.md`](../../current/SPEC_v2_AGT2_Agent.md) · 對照 API SKILL：`/adminlink-confirm-registration`, `/adminlink-software-update`

---

## Scope & Roles

| Side | Component | Owner | Notes |
|---|---|---|---|
| **Device** | AdminLink Daemon (Agent) | **OURS (ELECOM)** — design & implement | Runs on **WAB-BE series** which follows the **AP flow** |
| **Cloud (AWS)** | Agent API + Database | **NOT OURS** — designed by third party | We only call APIs and conform to the WebAPI specification; we do not design or modify cloud behavior |

> ⚠️ **Implementation boundary**: Only the device-side daemon is in our scope. All Cloud (AWS) endpoints, error semantics, and DB behavior are governed by the WebAPI specification document.

> ⚠️ **WAB-BE series rule**: WAB-BE is an AP product. It **must follow the AP flow**:
> - Hourly periodic execution applies
> - Execution when user opens System Information screen (with AdminLink "Enabled") applies
> - **PART 2 (software version confirmation) is NOT applicable**

---

## Execution Timing

This flow is expected to be executed at the following timing (verbatim from spec):

- At startup of the agent
- Daily processing by schedule
- (AP and Switch) Hourly periodical process by schedule
- (AP and Switch) When the user opens the system information screen with AdminLink Function "Enable"

---

## Diagram 1 — Flowchart (Main: Decision Logic)

```mermaid
flowchart TD
    Start([🚀 START])
    Start --> T["Trigger:<br/>① Agent startup<br/>② Daily schedule<br/>③ Hourly schedule (AP/SW only)<br/>④ Open System Info screen (AP/SW, AdminLink=Enabled)"]
    T --> P1_Check

    subgraph PART1["🔷 PART 1 — Device Registration Confirmation"]
        P1_Check{{"Local<br/>Device ID<br/>exists?"}}
        P1_Call[["📡 Device side:<br/>Call Device Registration<br/>Confirmation API"]]
        P1_Cloud[("☁️ Cloud AWS<br/>Agent API + DB<br/>⚠️ NOT our scope")]
        P1_Resp{{"HTTP<br/>Status?"}}
        P1_ClearID["🗑️ Device side:<br/>Clear local Device ID"]
        P1_FlagCheck{{"Device ID<br/>change flag<br/>in response?"}}
        P1_Overwrite["✏️ Device side:<br/>Overwrite local Device ID<br/>with API response value"]

        P1_Check -->|"No Device ID"| EndA([END])
        P1_Check -->|"Device ID exists"| P1_Call
        P1_Call --> P1_Cloud
        P1_Cloud --> P1_Resp
        P1_Resp -->|"Other status<br/>(refer to WebAPI spec)"| EndB([END])
        P1_Resp -->|"401<br/>not registered"| P1_ClearID
        P1_ClearID --> EndC([END])
        P1_Resp -->|"200 success <br/>registered"| P1_FlagCheck
        P1_FlagCheck -->|"Flag = 0<br/>no change"| APCheck
        P1_FlagCheck -->|"Flag = 1<br/>changed"| P1_Overwrite
        P1_Overwrite --> APCheck
    end

    APCheck{{"Device type:<br/>AP or Switch?<br/>(WAB-BE = AP)"}}
    APCheck -->|"Yes → AP / Switch / WAB-BE<br/>PART 2 NOT applicable"| EndD([END])
    APCheck -->|"No → other models"| P2_Call

    subgraph PART2["🔶 PART 2 — Software Latest Version Confirmation"]
        P2_Call[["📡 Device side:<br/>Call Latest Software<br/>Information Acquisition API"]]
        P2_Cloud[("☁️ Cloud AWS<br/>Product/Software Version DB<br/>⚠️ NOT our scope")]
        P2_Resp{{"HTTP<br/>Status?"}}
        P2_VerCheck{{"Retained version<br/>=<br/>Retrieved version?"}}
        P2_Guide["💬 Device side:<br/>Provide guidance to encourage<br/>version upgrade<br/><br/>※ Whether to display the upgrade<br/>guidance is determined by the<br/>calling program"]

        P2_Call --> P2_Cloud
        P2_Cloud --> P2_Resp
        P2_Resp -->|"Not 200<br/>(refer to WebAPI spec)"| EndE([END])
        P2_Resp -->|"200 success"| P2_VerCheck
        P2_VerCheck -->|"Equal ✅"| EndF([END])
        P2_VerCheck -->|"Not equal ⚠️"| P2_Guide
        P2_Guide --> EndG([END])
    end

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000
    classDef endNode fill:#e0e0e0,stroke:#666,color:#000

    class P1_Call,P1_ClearID,P1_Overwrite,P2_Call,P2_Guide deviceSide
    class P1_Cloud,P2_Cloud cloudSide
    class P1_Check,P1_Resp,P1_FlagCheck,P2_Resp,P2_VerCheck,APCheck decision
    class EndA,EndB,EndC,EndD,EndE,EndF,EndG endNode
```

---

## Diagram 2 — Sequence Diagram (Supplementary: API Interaction)

```mermaid
sequenceDiagram
    autonumber
    participant Agent as 📱 Device Side<br/>AdminLink Daemon<br/>(OURS)
    participant API as ☁️ Cloud AWS<br/>Agent API<br/>(NOT OURS)
    participant DB as 🗄️ Cloud AWS<br/>Database<br/>(NOT OURS)

    Note over Agent: Trigger:<br/>• Agent startup<br/>• Daily schedule<br/>• Hourly schedule (AP/SW)<br/>• System Info screen open (AP/SW, AdminLink=Enabled)

    rect rgb(220, 240, 255)
        Note over Agent,DB: PART 1 — Device Registration Confirmation
        Agent->>Agent: Check local Device ID

        alt No Device ID
            Note over Agent: END (subsequent processing skipped)
        else Device ID exists
            Agent->>+API: Device Registration Confirmation API
            API->>+DB: Query device registration
            DB-->>-API: Registration status
            API-->>-Agent: Response (HTTP status + Device ID + change flag)

            alt HTTP 401 (not registered)
                Agent->>Agent: 🗑️ Clear locally stored Device ID
            else HTTP 200 (success) - Flag = 1 (changed)
                Agent->>Agent: ✏️ Overwrite local Device ID with response value
            else HTTP 200 (success) - Flag = 0 (no change)
                Agent->>Agent: Keep current Device ID
            else Other HTTP status
                Note over Agent: END (refer to WebAPI spec)
            end
        end
    end

    rect rgb(255, 235, 215)
        Note over Agent,DB: PART 2 — Software Latest Version Confirmation<br/>⚠️ NOT applicable to AP / Switch / WAB-BE

        Agent->>+API: Latest Software Information Acquisition API
        API->>+DB: Query Product / Software Version DB
        DB-->>-API: Latest version info
        API-->>-Agent: Response (HTTP status + version info)

        alt HTTP 200 - Retained version ≠ Retrieved version
            Agent->>Agent: 💬 Provide guidance to encourage version upgrade
            Note over Agent: ※ Display decision is made<br/>by the calling program
        else HTTP 200 - Retained version = Retrieved version
            Note over Agent: END (no action)
        else Other HTTP status
            Note over Agent: END (refer to WebAPI spec)
        end
    end
```

---

## Key Implementation Notes

### 1. Trigger conditions (verbatim from spec)
- At startup of the agent
- Daily processing by schedule
- (AP and Switch) Hourly periodical process by schedule
- (AP and Switch) When the user opens the system information screen with AdminLink Function "Enable"

### 2. WAB-BE series = AP flow
- Hourly periodic execution **applies**
- System Information screen trigger **applies**
- PART 2 (software version confirmation) **does NOT apply**

### 3. Role boundary (critical for AI / implementers)
- **Device side (OURS — implement here)**: AdminLink daemon
  - Local Device ID storage and lifecycle
  - API invocation
  - HTTP status / response handling
  - Upgrade prompt gating (the calling program decides whether to display)
- **Cloud side (NOT OURS — do not modify)**: AWS Agent API + Database
  - Governed by the WebAPI specification document
  - Conform to it; do not change behavior

### 4. Spec-faithful behavior
All wording inside the diagrams (API names, conditions, actions) is kept verbatim with the original specification. Detailed error processing per status / error ID must reference the WebAPI specification document — this flow is a summary only.

### 5. Display of upgrade guidance
Whether to display the upgrade prompt is **determined by the calling program**, not by this flow. The daemon only provides the guidance trigger.

### 6. Reference implementation
When implementing, refer to the following modules in the IoT Agent Development Sample:
- Device registration confirmation
- Get the latest software information

---

## Quick Reference Table

| API | Direction | When called | Applies to |
|---|---|---|---|
| Device Registration Confirmation API | Device → Cloud | Always (if local Device ID exists) | All models incl. WAB-BE |
| Latest Software Information Acquisition API | Device → Cloud | After PART 1 succeeds | **Excluded** for AP / Switch / WAB-BE |

| HTTP Response | Action |
|---|---|
| `200` + flag=0 | Keep current Device ID, proceed |
| `200` + flag=1 | Overwrite local Device ID, proceed |
| `401` | Clear local Device ID, END |
| Other | END (refer to WebAPI spec for detailed handling) |

---

## Done When

- Agent successfully calls Device Registration Confirmation API at each trigger
- Local Device ID is correctly updated/cleared based on HTTP status and change flag
- For non-AP/Switch models: Software version is checked and upgrade guidance is provided when versions differ
- For WAB-BE / AP / Switch: PART 2 is skipped
- All error cases follow the WebAPI specification document