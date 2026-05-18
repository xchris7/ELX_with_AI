# 2. Device Entry Startup Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `2.Device entry startup flow`
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT2_Agent.md`](../../current/SPEC_v2_AGT2_Agent.md) · 對照 API SKILL：`/adminlink-confirm-registration`, `/adminlink-software-update`

---

## Scope & Roles

| Side | Component | Owner |
|---|---|---|
| **Device** | AdminLink Daemon | **OURS (ELECOM)** — WAB-BE follows AP flow |
| **Cloud (AWS)** | Agent API + Database | **NOT OURS** — per WebAPI spec |

## Execution Timing

- When NAS opens the device registration UI
- When AP / Switch / **WAB-BE** opens the basic screen with AdminLink = "Enable"
- When AP / Switch / **WAB-BE** changes AdminLink from "Disable" → "Enable"

## Diagram 1 — Flowchart

```mermaid
flowchart TD
    Start([🚀 START])
    Start --> Check{{"Local<br/>Device ID<br/>exists?"}}
    Check -->|"No"| TempNum["🆕 Device side:<br/>Temporary Device ID numbering"]
    Check -->|"Yes"| Call

    TempNum --> Call[["📡 Device side:<br/>Call Device Registration<br/>Confirmation API"]]
    Call --> Cloud[("☁️ Cloud AWS<br/>Agent API + DB<br/>⚠️ NOT our scope")]
    Cloud --> Status{{"HTTP<br/>Status?"}}

    Status -->|"Other status<br/>(refer to WebAPI spec)"| EndA([END])
    Status -->|"401<br/>not registered"| UI_Initial["🖥️ Device side:<br/>Show UI for<br/>initial registration"]
    Status -->|"200<br/>registered"| FlagCheck{{"Device ID<br/>change flag?"}}

    FlagCheck -->|"Flag = 0<br/>no change"| UI_Registered["🖥️ Device side:<br/>Show UI for<br/>registered device"]
    FlagCheck -->|"Flag = 1<br/>changed"| UI_ReReg["🖥️ Device side:<br/>Show UI for<br/>re-registration"]

    UI_Initial --> Discard["🗑️ Discard temporary<br/>Device ID"]
    UI_Registered --> APCheck
    UI_ReReg --> APCheck
    Discard --> APCheck

    APCheck{{"Device type:<br/>AP / Switch?<br/>(WAB-BE = AP)"}}
    APCheck -->|"Yes — PART 2 skipped"| EndD([END])
    APCheck -->|"No"| Call2[["📡 Device side:<br/>Call Latest Software<br/>Information Acquisition API"]]

    Call2 --> Cloud2[("☁️ Cloud AWS<br/>Version DB<br/>⚠️ NOT our scope")]
    Cloud2 --> Status2{{"HTTP<br/>Status?"}}
    Status2 -->|"Not 200"| EndE([END])
    Status2 -->|"200"| Ver{{"Retained version<br/>=<br/>Retrieved version?"}}
    Ver -->|"Equal ✅"| EndF([END])
    Ver -->|"Not equal ⚠️"| Guide["💬 Device side:<br/>Provide guidance to encourage<br/>version upgrade<br/>(display decision by calling program)"]
    Guide --> EndG([END])

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000

    class TempNum,Call,UI_Initial,UI_Registered,UI_ReReg,Discard,Call2,Guide deviceSide
    class Cloud,Cloud2 cloudSide
    class Check,Status,FlagCheck,APCheck,Status2,Ver decision
```

## Diagram 2 — Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Agent as 📱 Device Side<br/>AdminLink Daemon (OURS)
    participant API as ☁️ Cloud AWS<br/>Agent API (NOT OURS)
    participant DB as 🗄️ Cloud AWS<br/>Database (NOT OURS)

    Note over Agent: Trigger: NAS opens reg UI / AP・SW・WAB-BE opens basic screen with AdminLink=Enable / AdminLink Disable→Enable

    alt No local Device ID
        Agent->>Agent: 🆕 Temporary Device ID numbering
    end

    Agent->>+API: Device Registration Confirmation API
    API->>+DB: Query registration status
    DB-->>-API: Status + change flag
    API-->>-Agent: Response

    alt HTTP 401 (not registered)
        Agent->>Agent: 🖥️ Show UI for initial registration
        Agent->>Agent: 🗑️ Discard temporary Device ID
    else HTTP 200 + Flag=0 (no change)
        Agent->>Agent: 🖥️ Show UI for registered device
    else HTTP 200 + Flag=1 (changed)
        Agent->>Agent: 🖥️ Show UI for re-registration
    else Other status
        Note over Agent: END (refer to WebAPI spec)
    end

    Note over Agent,DB: PART 2 — NOT applicable to AP / SW / WAB-BE
    Agent->>+API: Latest Software Information Acquisition API
    API->>+DB: Query version DB
    DB-->>-API: Latest version
    API-->>-Agent: Response

    alt 200 + version mismatch
        Agent->>Agent: 💬 Provide upgrade guidance
    else 200 + version match
        Note over Agent: END
    else Other status
        Note over Agent: END
    end
```

## Key Notes
1. **Temporary Device ID**: Numbered locally before calling the API when no Device ID exists. Discarded after the registration UI flow completes (initial registration case).
2. **Three UI branches**: initial registration / registered / re-registration — decided by HTTP status + change flag.
3. **PART 2 not applicable to AP / Switch / WAB-BE**.
4. Detailed error handling per status / error ID → refer to WebAPI specification.

## Done When
- Correct UI (initial / registered / re-registration) is displayed based on API response
- Temporary Device ID is discarded after initial registration UI flow
- For non-AP/SW models, version upgrade guidance is provided when versions differ