# 7. Remote Control Reception Flow

> **來源 (Source)**: `EJ02.(AdminLink) 01. WebAPI Specification Supplement (Agent_Cloud Linkage Flow) v1.06`
> **Sheet**: `7.Remote control reception flow`
> **Related**: `remote_control_id_list.md`（command catalog）
> ⚠️ 衍生摘要 (derived summary)，僅供引述與對照；規格衝突時以 EJ02 spec 英文原文為準。
> 正式需求：[`SPEC_v2_AGT3_RemoteControl.md`](../../current/SPEC_v2_AGT3_RemoteControl.md) · 對照 API SKILL：`/adminlink-auth-info`

---

## Scope & Roles

| Side | Component | Owner |
|---|---|---|
| **Device** | AdminLink Daemon | **OURS (ELECOM)** — WAB-BE follows AP flow |
| **Cloud (AWS)** | IoT Core (MQTT) + Lambda | **NOT OURS** — per WebAPI spec |

## Execution Timing
- After device registration is completed (Flow 3)
- AdminLink Function = "Enable"
- **Runs continuously** — subscribes and waits for messages

## Diagram 1 — Flowchart

```mermaid
flowchart TD
    Start([🚀 START<br/>After device registration<br/>+ AdminLink = Enable])
    Start --> Check{{"Local<br/>Device ID<br/>exists?"}}
    Check -->|"No"| EndA([END])
    Check -->|"Yes"| AuthCheck{{"IoT Core<br/>credential<br/>available?"}}

    AuthCheck -->|"No"| GetCred[["📡 Device side:<br/>Call Credential<br/>Acquisition API"]]
    GetCred --> CloudCred[("☁️ Cloud AWS")]
    CloudCred --> Connect
    AuthCheck -->|"Yes"| Connect

    Connect["🔌 Device side:<br/>Connect to AWS IoT Core (MQTT)<br/>⚠️ Client ID = 'DeviceID_remoteCtrl'<br/>(must differ from uploader)"]
    Connect --> Subscribe["📥 Device side:<br/>Subscribe to remote control topic"]
    Subscribe --> Wait

    Wait{{"Remote control<br/>message received?"}}
    Wait -->|"Wait..."| Wait
    Wait -->|"Received"| Parse["🔍 Device side:<br/>Parse rc_id from message"]

    Parse --> Execute["⚙️ Device side:<br/>Execute command per<br/>Remote Control ID list<br/>(see remote_control_id_list.md)"]
    Execute --> GenEvent["📄 Device side:<br/>Generate 'remote control<br/>execution completed' event JSON"]
    GenEvent --> Upload[["📤 Device side:<br/>Upload via Flow 6<br/>(status/event upload flow)"]]
    Upload --> Wait

    classDef deviceSide fill:#cfe8ff,stroke:#0066cc,stroke-width:2px,color:#000
    classDef cloudSide fill:#ffe8cc,stroke:#cc6600,stroke-dasharray: 5 5,color:#000
    classDef decision fill:#fff0cc,stroke:#cc9900,color:#000

    class GetCred,Connect,Subscribe,Parse,Execute,GenEvent,Upload deviceSide
    class CloudCred cloudSide
    class Check,AuthCheck,Wait decision
```

## Diagram 2 — Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Cloud as ☁️ Cloud / Operator<br/>(NOT OURS)
    participant IoT as 🔐 AWS IoT Core<br/>MQTT Broker (NOT OURS)
    participant Agent as 📱 Device Side (OURS)

    Note over Agent: Startup: after registration done & AdminLink=Enable

    Agent->>+IoT: MQTT Connect<br/>Client ID = "DeviceID_remoteCtrl"
    IoT-->>-Agent: CONNACK
    Agent->>IoT: SUBSCRIBE remote control topic

    loop Wait for remote control messages
        Cloud->>IoT: Publish remote control (rc_id + params)
        IoT->>Agent: Remote control message
        Agent->>Agent: 🔍 Parse rc_id
        Agent->>Agent: ⚙️ Execute per Remote Control ID list
        Agent->>Agent: 📄 Generate execution completed event JSON
        Agent->>IoT: 📤 Publish event JSON (via Flow 6)
    end
```

## Key Notes
1. **⚠️ Client ID uniqueness**: Use `DeviceID_remoteCtrl` — must **differ** from Flow 6's `DeviceID_uploader`. AWS IoT Core rejects duplicate client IDs (causes disconnection).
2. **Continuous loop**: Subscribe once at startup, then loop forever processing incoming messages.
3. **Execution reporting**: Every executed command must generate a completion event JSON and upload via Flow 6.
4. **Command catalog**: See `remote_control_id_list.md` for the full list of rc_id values and applicable device types.
5. **File operations**: rc_id 2010 uses Flow 9 (download); rc_id 4010/4020/4030/4040 use Flow 8 (upload).

## Done When
- Persistent MQTT connection established with `_remoteCtrl` client ID
- Subscribed to remote control topic
- Each received command is executed per Remote Control ID list
- Each execution generates and publishes a completion event JSON