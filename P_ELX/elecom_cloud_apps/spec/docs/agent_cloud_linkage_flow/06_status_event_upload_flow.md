# 6. Status / Event Upload Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `6.Status_event upload flow`
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT2_Agent.md`](../../current/SPEC_v2_AGT2_Agent.md) · 對照 API SKILL：`/adminlink-auth-info`

---

## Scope & Roles

| Side | Component | Owner |
|---|---|---|
| **Device** | AdminLink Daemon | **OURS (ELECOM)** — WAB-BE follows AP flow |
| **Cloud (AWS)** | IoT Core (MQTT) + Lambda + DB | **NOT OURS** — per WebAPI spec |

## Execution Timing
- **Periodic**: per timing calculated in Flow 3 (after device registration)
- **Event-triggered**: when monitored events occur (status change, etc.)

## Diagram 1 — Flowchart

```mermaid
flowchart TD
    Start([🚀 START<br/>Periodic timer / event occurred])
    Start --> Check{{"Local<br/>Device ID<br/>exists?"}}
    Check -->|"No"| EndA([END])
    Check -->|"Yes"| AuthCheck{{"IoT Core<br/>credential<br/>available?"}}

    AuthCheck -->|"No"| GetCred[["📡 Device side:<br/>Call Credential<br/>Acquisition API"]]
    GetCred --> CloudCred[("☁️ Cloud AWS<br/>Returns IoT Core credential")]
    CloudCred --> Connect
    AuthCheck -->|"Yes"| Connect

    Connect["🔌 Device side:<br/>Connect to AWS IoT Core<br/>(MQTT)<br/>Client ID = 'DeviceID_uploader'"]
    Connect --> GenFile{{"Type?"}}

    GenFile -->|"Periodic"| GenStatus["📄 Device side:<br/>Generate Status JSON file"]
    GenFile -->|"Event"| GenEvent["📄 Device side:<br/>Generate Event JSON file"]

    GenStatus --> Publish
    GenEvent --> Publish

    Publish["📤 Device side:<br/>MQTT Publish to topic"]
    Publish --> IoT[("☁️ AWS IoT Core<br/>→ Lambda → DB<br/>⚠️ NOT our scope")]
    IoT --> EndB([END])

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000

    class GetCred,Connect,GenStatus,GenEvent,Publish deviceSide
    class CloudCred,IoT cloudSide
    class Check,AuthCheck,GenFile decision
```

## Diagram 2 — Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Agent as 📱 Device Side (OURS)
    participant API as ☁️ Cloud AWS<br/>Agent API (NOT OURS)
    participant IoT as 🔐 AWS IoT Core<br/>MQTT Broker (NOT OURS)

    Note over Agent: Trigger: periodic timer (per Flow 3 timing) or monitored event

    alt No IoT Core credential
        Agent->>+API: Credential Acquisition API
        API-->>-Agent: IoT Core credential
    end

    Agent->>+IoT: MQTT Connect<br/>Client ID = "DeviceID_uploader"
    IoT-->>-Agent: CONNACK

    alt Periodic
        Agent->>Agent: 📄 Generate Status JSON file
    else Event-triggered
        Agent->>Agent: 📄 Generate Event JSON file
    end

    Agent->>+IoT: MQTT Publish (Status / Event JSON)
    IoT-->>-Agent: PUBACK
    Note over IoT: → Lambda → DB (NOT our scope)
```

## Key Notes
1. **⚠️ Client ID uniqueness**: Use `DeviceID_uploader` — must **differ** from Flow 7's `DeviceID_remoteCtrl`. Same Device ID with different suffixes allows two parallel MQTT connections (upload + remote control reception).
2. **Credential caching**: Only call Credential Acquisition API when no credential is available locally.
3. **Two file types**: Status JSON (periodic) and Event JSON (event-triggered) — both use the same MQTT publish path.
4. **Periodic timing** comes from Flow 3 calculation.

## Done When
- MQTT connection to IoT Core is established with the `_uploader` client ID
- Status / Event JSON file is generated and published successfully
- PUBACK received from broker
