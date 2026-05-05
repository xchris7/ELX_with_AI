# Device Telemetry JSON Schema
> **AdminLink / Network Device Telemetry JSON Payload Definition**  
> Covers: NAS, AP (Access Point), SWITCH — Bilingual EN/JA

---

## Overview

This document defines the JSON packet structure used by network devices to report status and events to the AdminLink management server. All device types (NAS, AP, Switch) share a common header and some sections; device-specific sections are clearly labeled.

### Source Code Reference

The following source files **must conform to** this schema when constructing JSON packets:

| File | Role |
|------|------|
| `P_ELX/elecom_cloud_apps/admlink/admlink_genmsg.c` | **Primary target** — must construct and serialize all JSON packets according to the field definitions, types, size limits, and rules specified in this document |
| `P_ELX/elecom_cloud_apps/admlink/include/admlink_genmsg.h` | Header declarations for packet generation functions |

> **For AI assistants:** This document is the **authoritative specification** for `admlink_genmsg.c`. When reviewing, writing, or debugging code in that file, verify that all JSON field names, value types, string sizes, mutual exclusion rules, and enum values match the definitions here. The code must follow the spec — not the other way around.

### Packet Trigger Conditions

| Condition | `type` | `sts_type` | Description |
|---|---|---|---|
| Periodic timer | `status` | `0` = Regular | Sent at scheduled intervals (e.g., every `ccf_intvl` hours) |
| Event occurred | `status` | `1` = Event triggered | Status snapshot sent **after** an event; the event is also sent separately as `type=event` |
| Voluntary / on-demand | `status` | `2` = Voluntary | Sent immediately on agent startup, RC command 5060, or manual trigger |
| Fault / threshold crossing | `event` | N/A | Sent when an `act_id` threshold is crossed; carries `evt_id` linking back to `sts:[]` |

### Supported Device Categories (`prdct`)
| Code | Category |
|------|----------|
| `NAS` | Network Attached Storage |
| `AP` | Access Point (Wireless) |
| `SW` | Switch |

### JSON Packet Types
| `type` value | Description |
|---|---|
| `status` | Status JSON — periodic or event-triggered |
| `event` | Event JSON — triggered by events |

---

## ① Common Packet Header
*Applies to all JSON types (status + event)*

| JSON Key | Type | Size | Required | Notes |
|---|---|---|---|---|
| `type` | String | 10 chars (lowercase) | **Required** | `"status"` or `"event"` |
| `ver` | String | 10 chars | **Required** | Packet version e.g. `"2.00"` |
| `prdct` | String | 10 chars (UPPERCASE) | **Required** | Product category: `NAS`, `AP`, `SW` |
| `dev_id` | String | 40 chars | **Required** | UUID/GUID (no hyphens or symbols) |
| `date` | DateTime | 30 chars | **Required** | Format: `YYYY/MM/DD hh:mm:ss` (zero-padded) |
| `ms_name` | String | 20 chars | **Required** | Management software name (= `ms_mnemonic` in device registration API) |
| `ms_ver` | String | 20 chars | **Required** | Firmware version number e.g. `"1.00"` |
| `agt_name` | String | 20 chars | **Required** | Agent identifier (= `agt_mnemonic` in device registration API) |
| `agt_ver` | String | 20 chars | **Required** | Agent version number e.g. `"100"` for Ver 1.00 |
| `upld_name` | String | 20 chars | Optional | Uploader identifier |
| `upld_ver` | String | 20 chars | Optional | Uploader version e.g. `"100"` for Ver 1.00 |

**Example Header:**
```json
{
  "type": "status",
  "ver": "2.00",
  "prdct": "AP",
  "dev_id": "550e8400e29b41d4a716446655440000",
  "date": "2024/01/15 09:30:00",
  "ms_name": "AdminLink",
  "ms_ver": "1.00",
  "agt_name": "AgentV2",
  "agt_ver": "100"
}
```

---

## ② Event JSON Body
*Common to all device types*

| JSON Key | Type | Size | Required | Notes |
|---|---|---|---|---|
| `evt_id` | Number (int) | integer | **Required** | Unique per device ID; does NOT reset on reboot. Links status JSON `sts:[]` with event JSON |
| `act_id` | Number (int) | integer | **Required** | Action/event identifier |
| `act_trg` | Number (int) | integer | **Required** | Target index (e.g., port number, HDD slot, CPU index where event occurred) |
| `act_para` | String | 100 chars | **Required** | Event supplemental info; comma-separated string |
| `act_sts` | Number (int) | integer | **Required** | Action status: `0`=None, `1`=Waiting, `2`=In Progress, `3`=Done, `-1`=Unknown |
| `msg` | String | message | **Required** | Event message (may differ from `sts:[]` message in status JSON) |

**Action Status Enum:**
```
0  = None (なし)
1  = Waiting for action (対処待ち)
2  = Taking action (対処中)
3  = Action taken (対処済み)
-1 = Unknown (不明)
```

---

## ③ Status JSON Common Fields
*Common to all device types*

| JSON Key | Type | Required | Notes |
|---|---|---|---|
| `sts_type` | Number (int) | **Required** | `0`=Regular, `1`=Event triggered, `2`=Voluntary |
| `proxy_flg` | Number (int) | **Required** | `0`=Invalid, `1`=Valid, `NULL`=Indefinite |
| `rmt_flg` | Number (int) | **Required** | Remote control: `0`=Invalid, `1`=Valid, `NULL`=Indefinite |
| `cfgf_flg` | Number (int) | **Required** | Config file upload: `0`=Invalid, `1`=Valid, `NULL`=Indefinite |
| `logf_flg` | Number (int) | **Required** | Log file upload: `0`=Invalid, `1`=Valid, `NULL`=Indefinite |
| `ccf_flg` | Number (int) | **Required** | Client file upload: `0`=Invalid, `1`=Valid, `NULL`=Indefinite |
| `ccf_intvl` | Number (int) | **Required** | Upload interval: `0`=No upload, `1`=1h, `3`=3h, `6`=6h |

---

## ④ Status JSON — Status Table (`sts:[]`)
*Common to all device types — included inside device-specific sections*

| JSON Key | Type | Required | Notes |
|---|---|---|---|
| `evt_id` | Number (int) | **Required** | Links to Event JSON `evt_id` |
| `act_id` | Number (int) | **Required** | Event identifier |
| `act_trg` | Number (int) | **Required** | Target index (port/HDD/CPU that triggered event) |
| `act_para` | String (100) | **Required** | Comma-separated supplemental info |
| `act_sts` | Number (int) | **Required** | Same enum as ② `act_sts` |
| `msg` | String | **Required** | Event message (may differ from event JSON message) |

---

## ⑤ Status JSON Body — NAS Specific

### System
| JSON Key | Type | Notes |
|---|---|---|
| `uptime` | Number (int) | System uptime in minutes |
| `pow_sts` | Number (int) | `0`=On, `100`=Off, `200`=Sleep/Hibernate |
| `rpw_act` | Number (int) | Power recovery: `0`=Unknown, `1`=Off, `2`=On, `3`=Maintain last |
| `cpu_load` | Number (%) | CPU usage (e.g. `87.50`) |
| `mem_load` | Number (%) | Memory usage |
| `hd_load` | Number (%) | HDD load |
| `lo_cnt` | Number (int) | Number of logged-on users |
| `os_ver` | String (100) | OS version e.g. `"10.0.17763"` |
| `wupd_msg` | String (100) | Windows Update count |
| `wupd_chk` | DateTime (30) | Windows Update last check: `YYYY/mm/dd HH:MM:SS` |
| `wupd_date` | DateTime (30) | Windows Update last performed |
| `mb_sn` | String (50) | Motherboard serial number |
| `mb_ver` | String (10) | Motherboard BIOS version |
| `host_name` | String (100) | Hostname |
| `ng_type` | Number (int) | Network group: `0`=Unknown, `100`=Domain, `200`=Workgroup |

### CPU Info Table (`cpu:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | **Required** — CPU name |
| `fan_rpm` | Number (int) | CPU fan speed (RPM) |
| `tmp` | Number (int) | CPU temperature |
| `load` | Number (%) | CPU load percentage |
| `sts:[]` | Table | Status table (see ④) |

### Case Fan Table (`case_fan:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (20) | **Required** — Fan name |
| `rpm` | Number (int) | Fan RPM |
| `sts:[]` | Table | Status table |

### Internal Disk Table (`hd:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | **Required** — Disk name |
| `vnd` | String (20) | Vendor string |
| `model` | String (40) | Model name |
| `fwv` | String (10) | Firmware version |
| `serial` | String (20) | Serial number |
| `sata_md` | String (40) | SATA transfer mode |
| `ata_ver` | String (20) | ATA standard version |
| `features` | String (40) | Supported features |
| `sec_size` | Number (int) | Logical sector size |
| `phys_size` | Number (int) | Physical sector size |
| `uptime` | Number (int) | Disk uptime (hours powered) |
| `tmp` | Number (int) | Disk temperature |
| `load` | Number (%) | Disk load |
| `smt:[]` | Table | SMART info (see ⑥) |
| `sts:[]` | Table | Status table |

### Volume Table (`vlm:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | **Required** — Volume name |
| `log_name` | String (10) | Logical drive letter |
| `label` | String (40) | Volume label |
| `type` | String (40) | RAID type |
| `fmt` | String (40) | File system format |
| `used` | Number (int) | Used capacity (bytes) |
| `total` | Number (int) | Total capacity (bytes) |
| `free_per` | Number (%) | Usage percent (2 decimal places) |
| `sts:[]` | Table | Status table |

### USB/eSATA Connection Table (`ex_dev:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | **Required** — Device name |
| `log_name` | String (10) | Logical drive letter |
| `label` | String (40) | Volume label |
| `port` | String (20) | Connection port |
| `type` | String (20) | Connection type |
| `fmt` | String (40) | Format type |
| `used` | Number (int) | Used bytes |
| `total` | Number (int) | Total bytes |
| `free_per` | Number (%) | Usage percent |
| `sts:[]` | Table | Status table |

### Network Info Table (`ntwk:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | **Required** — Interface name |
| `ip_adr` | String (20) | IP address (`*.*.*.*` format) |
| `mac_adr` | String (40) | MAC address (`**:**:**:**:**:**`) |
| `tx` | Number (int) | Packets sent |
| `rx` | Number (int) | Packets received |
| `sts:[]` | Table | Status table |

### Backup Status Table (`bkup:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `config` | String (50) | **Required** — Backup settings |
| `last_bkup` | DateTime | Last successful backup `YYYY/mm/dd HH:MM:SS` |
| `date` | DateTime | Last backup timestamp |
| `result` | String (50) | Last backup status |
| `sts:[]` | Table | Status table |

### UPS Status Table (`ups:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | **Required** — UPS name |
| `vnd` | String (50) | Manufacturer |
| `model` | String (50) | Product name |
| `fwv` | String (50) | Firmware version |
| `serial` | String (50) | Serial number |
| `prd_date` | DateTime | Manufacturing date (raw string from UPS API) |
| `bt_date` | DateTime | Battery operation start date |
| `bt_lev` | Number (%) | Battery remaining capacity |
| `bt_sec` | Number (int) | Estimated remaining time (seconds) |
| `bt_time` | Number (int) | Estimated remaining time (hours) |
| `tmp` | Number (int) | Internal temperature |
| `bt_sts` | String | Battery status message |
| `connect` | String (20) | Connection type |
| `config` | String | UPS setting info |
| `sts:[]` | Table | Status table |

### Additional Apps Table (`addapp:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (100) | **Required** — App name |
| `vnd` | String (50) | Publisher |
| `ver` | String (50) | Version |
| `insd` | DateTime | Install date `YYYY/mm/dd` |

---

## ⑥ SMART Information (`smt:[]`)
*Inside NAS `hd:[]` table*

| JSON Key | Type | Required | Notes |
|---|---|---|---|
| `id` | Number (int) | **Required** | SMART attribute ID |
| `val` | Number (int) | **Required** | Current value |
| `ws` | Number (int) | **Required** | Worst value |
| `ts` | Number (int) | **Required** | Threshold |
| `dth` | String (20) | **Required** | RAW data HEX (hexadecimal fixed) |
| `dt` | String (20) | Optional | RAW data Legacy: HEX for Windows, Decimal for Linux |

---

## ⑦ Status JSON Body — AP/Switch Common

### System Object (`sys`)

| JSON Key | Type | Required | Notes |
|---|---|---|---|
| `uptime` | Number (int) | Optional | System uptime in minutes |
| `ipv4` | Object | Optional | IPv4 network info |
| `ipv6` | Object | Optional | IPv6 network info (Switch only) |

#### IPv4 Object (`ipv4`)
| JSON Key | Type | Notes |
|---|---|---|
| `ip_adr` | String (20) | Representative IP address |
| `sn_msk` | String (20) | Subnet mask |
| `dfgw` | String (20) | Default gateway |
| `dns_ip` | String (20) | Primary DNS |
| `dns_ip_1` | String (20) | Secondary DNS |
| `dhcp_ip` | String (20) | DHCP server IP |

#### IPv6 Object (`ipv6`)
| JSON Key | Type | Notes |
|---|---|---|
| `uni_adr:[]` | Table (45 chars) | Unicast address / prefix length |
| `dfgw` | String (45) | Default gateway |
| `ll_adr` | String (45) | Link-local address / prefix length |
| `dns_ipv6` | String (45) | Primary DNS IPv6 |
| `dns_ipv6_1` | String (45) | Secondary DNS IPv6 |

### Slave Mode Object (`client_md`)
*AP only — slave/child unit mode*

| JSON Key | Type | Notes |
|---|---|---|
| `ch` | String (100) | Current channel (e.g. `"Ch 36 + 40 + 44 + 48（自動）"`) |

### PoE Info Object (`poe_info`)
*Switch only*

| JSON Key | Type | Notes |
|---|---|---|
| `pow_bdgt` | Number (int) | Maximum PoE power budget |
| `pow_cnsp` | Number (int) | Current PoE consumption |
| `sts:[]` | Table | Status table (PoE overload events) |

### WAN Settings (`wan_conf`) — Router Mode
*AP router mode only*

| JSON Key | Type | Notes |
|---|---|---|
| `ip_adr` | String (20) | WAN IP (IPv4) |
| `def_gw` | String (20) | Default gateway (IPv4) |
| `dns_ip` | String (20) | Primary DNS (IPv4) |
| `dns_ip_1` | String (20) | Secondary DNS (IPv4) |
| `dhcp_ip` | String (20) | DHCP server (IPv4) |
| `ipv6_adr:[]` | Table (45) | WAN IP addresses (IPv6) |
| `ipv6_def_gw` | String (45) | Default gateway (IPv6) |
| `dns_ipv6` | String (45) | Primary DNS (IPv6) |
| `dns_ipv6_1` | String (45) | Secondary DNS (IPv6) |
| `dhcp_ipv6` | String (45) | DHCP server (IPv6) |

### Wired Port Info Table (`wired_info:[]`)

| JSON Key | Type | Notes |
|---|---|---|
| `pt_no` | Number (int) | Port number |
| `link` | Number (int) | Link status: `1`=Up, `2`=Down |
| `mac_adr` | String (40) | MAC address |
| `loop_sts` | Number (int) | Loop state: `1`=Loop, `2`=Normal |
| `poe_info` | Object | PoE per-port info (Switch w/ PoE) |
| `sttstcs` | Object | Network statistics (see ⑧) |
| `sts:[]` | Table | Status table (loop detection event 4250) |

#### Per-Port PoE Info (`poe_info` inside `wired_info`)
| JSON Key | Type | Notes |
|---|---|---|
| `status` | Number (int) | `1`=ON, `2`=OFF (ERROR also = OFF) |
| `power` | Number (int) | Supply power (mW) |
| `voltage` | Number (int) | Supply voltage (V) |
| `sts:[]` | Table | PoE per-port overload events (4260) |

### Wireless Info Table (`wireles_info:[]`)
*AP only — max 3 entries: 2.4GHz, 5GHz, 6GHz*

| JSON Key | Type | Notes |
|---|---|---|
| `band` | String | Band name: `"2.4GHz"`, `"5GHz"`, `"6GHz"` |
| `runt_ch` | String (100) | Runtime channel string (from Web UI) |
| `client_cnt` | Number (int) | Connected client count |
| `sttstcs` | Object | Statistics (see ⑧) |
| `mlo_sttstcs` | Object | MLO statistics (see ⑧) |

### MLO Info Object (`mlo_info`)
*AP only (BE series)*

| JSON Key | Type | Notes |
|---|---|---|
| `client_cnt` | Number (int) | MLO connected client count |

---

## ⑧ Network Statistics (`sttstcs`)
*Common to AP/Switch — appears in wired port and wireless band objects*

| JSON Key | SNMP Equivalent | Description |
|---|---|---|
| `ooct` | `ifOutOctets` | Sent octets |
| `oup` | `ifOutUcastPkts` | Sent unicast packets |
| `omp` | `ifOutMulticastPkts` | Sent multicast packets |
| `odc` | `ifOutDiscards` | Sent discarded packets |
| `oer` | `ifOutErrors` | Sent error packets |
| `ioct` | `ifInOctets` | Received octets |
| `iup` | `ifInUcastPkts` | Received unicast packets |
| `imp` | `ifInMulticastPkts` | Received multicast packets |
| `idc` | `ifInDiscards` | Received discarded packets |
| `ier` | `ifInErrors` | Received error packets |
| `iukp` | `ifInUnknownProtos` | Non-supported protocol packets (AP only) |
| `drevt` | `etherStatsDropEvents` | Drop event count |
| `crcaer` | `etherStatsCRCAlignErrors` | CRC align errors |
| `usp` | `etherStatsUndersizePkts` | Undersize packets |
| `osp` | `etherStatsOversizePkts` | Oversize packets |
| `frgmt` | `etherStatsFragments` | Fragments |
| `clsn` | `etherStatsCollisions` | Collisions |

---

## ⑨ Configuration Status JSON — AP/Switch Common

> **Note for AI:** Section ⑨ fields are **NOT** a third `type` value. They are included as nested objects **inside** a `type="status"` packet body (alongside the ③ common fields and ⑦ runtime status). The config section is sent together with runtime status to give a full device snapshot. `prdct` determines which sub-sections are included.

### System Config (`sys`)
| JSON Key | Type | Notes |
|---|---|---|
| `prdn` | String | Product name/model number |
| `blver` | String | Boot Loader Version |
| `sysloc` | String (50) | System location (SNMP `sysLocation`) |
| `prvt_vlan` | Number (int) | Private VLAN: `1`=Valid, `2`=Invalid, `NULL`=Indefinite |
| `mal_mod` | Number (int) | Forwarding learning: `1`=IVL, `2`=SVL |

### IPv4 Config (`ipv4`)
| JSON Key | Type | Notes |
|---|---|---|
| `ip_md` | Number (int) | Address method: `1`=DHCP, `2`=Static |

### IPv6 Config (`ipv6`)
| JSON Key | Type | Notes |
|---|---|---|
| `ipv4_dhcp` | Number (int) | IPv4 DHCP client: `1`=Valid, `2`=Invalid |
| `atcfg` | Number (int) | IPv6 auto config (RA): `1`=Valid, `2`=Invalid |
| `dhcp` | Number (int) | IPv6 DHCPv6 client: `1`=Valid, `2`=Invalid |

### AP-Specific Config
| JSON Key | Type | Notes |
|---|---|---|
| `op_md` | Number (int) | Operation mode: `1`=AP, `2`=Router, `3`=Slave |
| `emg_md` | Number (int) | Emergency/disaster mode: `1`=Valid, `2`=Invalid |
| `emg_avlbl_pt` | Number (int) | Allowed ports in emergency: `1`=No restriction, `2`=Web/Mail only |

### WAN Config (`wan_conf`) — Router Mode
| JSON Key | Type | Notes |
|---|---|---|
| `accs_type_str` | String | Access type string (use this when type=4 auto) |
| `accs_type` | Number (int) | `1`=DHCP, `2`=Static IP, `3`=PPPoE, `4`=Auto, `5`=Transix, `6`=v6plus |
| `mac_adr` | String (40) | WAN MAC address |

> **NOTE:** Include only one of `accs_type_str` OR `accs_type` in JSON. When `accs_type=4` (Auto), MUST use `accs_type_str` instead.

**`accs_type_str` examples for Auto:**
- `"自動判定(DHCP)"`
- `"自動判定(Transix)"`
- `"自動判定(v6プラス)"`

### LAN Config (`lan_conf`) — Router Mode
| JSON Key | Type | Notes |
|---|---|---|
| `ip_adr` | String (20) | LAN IP address |
| `mac_adr` | String (40) | LAN MAC address |

### Slave Mode Config (`client_md`)
| JSON Key | Type | Notes |
|---|---|---|
| `ssid` | String (50) | Connected SSID |
| `enc_type` | Number (int) | Encryption type |
| `bssid` | String (50) | BSSID (MAC address of AP) |

### Wired Port Config Table (`wired_info:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `pt_no` | Number (int) | Port number |
| `name` | String | Interface name |
| `enable_flg` | Number (int) | `1`=Enabled, `2`=Disabled |
| `mode_str` | String | Speed/duplex string (use this OR `mode`) |
| `mode` | Number (int) | Speed/duplex code (use this OR `mode_str`) |
| `pvid` | Number (int) | Port VLAN ID (PVID), range 1–4095 |
| `tv_tbl:[]` | Table | Tag-Based VLAN membership |
| `pv_vlan_map` | String | Private VLAN portmap string |
| `poe_info` | Object | PoE config per port |

> **NOTE:** Include only one of `mode_str` OR `mode` in JSON.

**`mode` enum:**
```
1 = Auto
2 = 10Mbps Half-duplex
3 = 10Mbps Full-duplex
4 = 100Mbps Half-duplex
5 = 100Mbps Full-duplex
6 = 1000Mbps Full-duplex
7 = 2.5Gbps Full-duplex
8 = 5Gbps Full-duplex
9 = 10Gbps Full-duplex
```

### VLAN Table (`vlan_tbl:[]`) — Max 4096
| JSON Key | Type | Notes |
|---|---|---|
| `vlanid` | Number (int) | VLAN ID |
| `vlan_name` | String | VLAN name (Switch only) |
| `man_login` | Number (int) | Admin login: `1`=Valid, `2`=Invalid |
| `tvm_tbl:[]` | Table | VLAN member table (ports + SSIDs) |
| `pv_vlan_map` | String | Private VLAN portmap string |

#### VLAN Member Table (`tvm_tbl:[]`)
| JSON Key | Type | Notes |
|---|---|---|
| `wired_pt_no` | Number (int) | Wired port number |
| `wired_name` | String | Wired interface name |
| `wireles_band` | String | Wireless band `"2.4GHz"` or `"5GHz"` (use OR `wireles_band_id`) |
| `wireles_band_id` | Number (int) | `1`=2.4GHz, `2`=5GHz, `3`=6GHz, `4`=MLO |
| `wireles_ssid` | String (50) | Wireless SSID name |
| `vlan_type` | Number (int) | `1`=Untagged, `2`=Tagged |

> **NOTE:** Include only one of `wireles_band` OR `wireles_band_id`. Both `wired_pt_no`/`wired_name` (wired) and `wireles_band`/`wireles_ssid` (wireless) use this same table.

### Wireless Config Table (`wireles_info:[]`)
*AP only — 2.4GHz, 5GHz, 6GHz entries*

| JSON Key | Type | Notes |
|---|---|---|
| `band` | String | `"2.4GHz"`, `"5GHz"`, `"6GHz"` |
| `enable_flg` | Number (int) | `1`=Valid, `2`=Invalid |
| `wc_mode` | Number (int) | Wireless mode (11b=1, 11g=2, ..., 11ax/be=12) |
| `enbl_ssid` | Number (int) | Number of active SSIDs |
| `auto_ch` | Number (int) | Auto channel: `1`=Valid, `2`=Invalid |
| `atch_rng` | Number (int) | Auto channel range (W52, W52+W53, etc.) |
| `atch_intvl` | Number (int) | Auto channel interval (1=30min, 2=1h, ...) |
| `atch_clnt_exist` | Number (int) | Change ch with clients connected: `1`=Valid, `2`=Invalid |
| `ch_bndwdth` | Number (int) | Channel bandwidth (20MHz=1, 40MHz=2, ...) |
| `tx_pow` | Number (int) | Transmit power (0–100%) |
| `ssid_info:[]` | Table | SSID info (see ⑩) |
| `radius_ent:[]` | Table | RADIUS server info (see ⑪), max 2 |
| `wds_mode` | Number (int) | WDS: `1`=Disabled, `2`=Normal, `3`=Wired-only, `4`=Enabled |
| `wds_type` | Number (int) | WDS mode: `1`=STA, `2`=AP, `3`=AP&STA |
| `wds_lmac` | String (40) | WDS local MAC address |
| `wds_ch` | String (5) | WDS channel |
| `wds_vlan_type` | Number (int) | `1`=Untagged, `2`=Tagged |
| `wds_vlan_id` | Number (int) | WDS VLAN ID (1–4096) |
| `wds_auth` | Number (int) | WDS auth: `1`=WPA2, `2`=WPA/WPA2, `3`=WPA3, `4`=WPA2/WPA3 |
| `wds_enc_type` | Number (int) | WDS encryption: `1`=None, `2`=AES, `3`=TKIP/AES |
| `wds_opst:[]` | Table | WDS peer MAC table (max 8) |
| `mac_flt:[]` | Table | MAC filter (use this OR `macadr_flt:[]`) |

### MLO Info Config (`mlo_info`)
| JSON Key | Type | Notes |
|---|---|---|
| `enable_flg` | Number (int) | `1`=Invalid(off), `2`=Valid(on) |
| `ssid_info` | Object | SSID info object (not array, see ⑩) |
| `mac_adr` | String (20) | MLO MAC address |
| `interface` | Number (int) | `1`=2.4+5GHz, `2`=2.4+6GHz, `3`=5+6GHz, `4`=2.4+5+6GHz |
| `radius_ent:[]` | Table | RADIUS servers |
| `wds_interface` | Number (int) | WDS interface (same enum as `interface`) |

### MAC Address Filter Table (`macadr_flt:[]`) — Max 48
> **IMPORTANT:** Include only ONE of `macadr_flt:[]` OR `wireles_info:[].mac_flt:[]` — never both.

| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | Filter name |
| `mac_adr:[]` | String Table | MAC addresses (max 256, 20 chars each) |

### Dial-In User Table (`diusr_tbl:[]`) — Switch, Max 64
| JSON Key | Type | Notes |
|---|---|---|
| `user` | String (50) | Username |
| `vlanid` | Number (int) | VLAN ID |

### Guest Network (`guest_nw`)
| JSON Key | Type | Notes |
|---|---|---|
| `enable` | Number (int) | `1`=Valid, `2`=Invalid |
| `band` | Number (int) | `1`=2.4GHz, `2`=5GHz, `3`=6GHz, `4`=MLO |
| `ssid` | String (50) | SSID |
| `dhcp_ip` | String (20) | DHCP IP |
| `dhcp_msk` | String (20) | DHCP subnet mask |
| `dhcp_lt` | Number (int) | Lease time: `1`=30min, `2`=1h, `3`=2h, `4`=12h, `5`=1day, ... `9`=Unlimited |
| `dhcp_st` | String (20) | DHCP start IP |
| `dhcp_end` | String (20) | DHCP end IP |
| `gst_cnct_time` | Number (int) | Guest connectable time (hours) |
| `cnct_rst_time` | Number (int) | Connection restriction time (hours) |
| `cnctbl_cnt` | Number (int) | Connectable count |
| `gst_ath_type` | Number (int) | Auth: `1`=Auth screen, `2`=Email auth, `3`=No auth |
| `cnct_lmt` | Number (int) | Connection limit count |
| `com_rstrct` | Number (int) | `1`=No restriction, `2`=Web/Mail only |
| `trfcspng` | Number (int) | Traffic shaping: `1`=Enabled, `2`=Disabled |
| `lmtd_rate` | Number (int) | Rate limiting |
| `avlbl_pt:[]` | Table | Available port table (max 10) |

### Forwarding Table (`fwtbl:[]`) — Switch, Max 8192
| JSON Key | Type | Notes |
|---|---|---|
| `id` | Number (int) | Entry ID |
| `vlanid` | Number (int) | VID |
| `pt` | String | Port (e.g. `"1"`, `"1,3-5"`) |
| `mac_adr` | String (40) | MAC address |
| `type` | Number (int) | `1`=Static unicast, `2`=Static multicast, `3`=Dynamic |

---

## ⑩ SSID Info (`ssid_info`)
*AP only*

| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (50) | SSID name |
| `bcssid` | Number (int) | Broadcast SSID: `1`=Invalid, `2`=Valid |
| `fast_roaming` | Number (int) | Fast roaming: `1`=Invalid, `2`=Valid |
| `auth_type` | Number (int) | Auth: `1`=None, `2`=WEP, `3`=WPA-Personal, `4`=WPA-Enterprise, `5`=802.1x/EAP, `6`=Enhanced Open |
| `enc_type` | Number (int) | Encryption: `1`=AES, `2`=TKIP, `3`=TKIP/AES |
| `vlanid` | Number (int) | VLAN ID |
| `vlan_type` | Number (int) | `1`=Untagged, `2`=Tagged |
| `add_auth_type` | Number (int) | Additional auth (MAC filter/RADIUS options) |
| `sprtr` | Number (int) | Separator: `1`=Invalid, `2`=STA, `3`=SSID, `4`=STA&SSID |
| `cnct_limit` | Number (int) | Connection limit count |
| `macaf_id` | Number (int 0–47) | MAC filter table index (links to `macadr_flt:[]`) |

---

## ⑪ RADIUS Server Entry (`radius_ent`)
*AP only — appears as array `radius_ent:[]` (max 2: primary/secondary)*

| JSON Key | Type | Notes |
|---|---|---|
| `name` | String (10) | `"primary"` or `"secondary"` |
| `type` | Number (int) | `1`=External, `2`=Internal |
| `ip_adr` | String (20) | RADIUS server IP |
| `auth_pt` | Number (int) | Authentication port |
| `ses_to` | Number (int) | Session timeout |
| `man_flg` | Number (int) | Management: `1`=Valid, `2`=Invalid |
| `man_pt` | Number (int) | Management port |

---

## Device Support Matrix

> **Current development target:** `WAB-BE` column covers the `WAB-BE187-M` (EW-7896LBE) device — the primary target of this repository. It is an AP-mode device with MLO and Guest Network support, no PoE, no Forwarding Table.

| Field | EHB-SX2B | EHB-SG2C | EHB-SG2C-PL | EHB-SX2A | **WAB-BE** *(WAB-BE187-M)* | WAB-M1775 | WAB-S733 AP | WAB-S733 RT | WAB-S733 Slave | WAB-I/S-PS | WAB-S1167IW |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Common Header | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Event JSON | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Status Common | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| PoE | - | ✓ | ✓ | - | - | - | - | - | - | - | - |
| Wireless Info | - | - | - | - | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| WAN Config | - | - | - | - | - | - | ✗ | ✓ | ✗ | - | ✓ |
| MLO Info | - | - | - | - | ✓ | - | - | - | - | - | - |
| Guest Network | - | - | - | - | ✓ | ✓ | - | - | - | ✓ | - |
| Forwarding Table | ✓ | ✓ | ✓ | ✓ | - | - | - | - | - | - | - |

---

## Complete JSON Example — AP Status

```json
{
  "type": "status",
  "ver": "2.00",
  "prdct": "AP",
  "dev_id": "550e8400e29b41d4a716446655440000",
  "date": "2024/01/15 09:30:00",
  "ms_name": "AdminLink",
  "ms_ver": "1.50",
  "agt_name": "APAgent",
  "agt_ver": "200",

  "sts_type": 0,
  "proxy_flg": 0,
  "rmt_flg": 1,
  "cfgf_flg": 1,
  "logf_flg": 1,
  "ccf_flg": 1,
  "ccf_intvl": 6,

  "sys": {
    "uptime": 14400,
    "ipv4": {
      "ip_adr": "192.168.1.100",
      "sn_msk": "255.255.255.0",
      "dfgw": "192.168.1.1",
      "dns_ip": "8.8.8.8",
      "dns_ip_1": "8.8.4.4"
    }
  },

  "wired_info": [
    {
      "pt_no": 1,
      "link": 1,
      "mac_adr": "AA:BB:CC:DD:EE:FF",
      "sttstcs": {
        "ooct": 1048576,
        "oup": 8192,
        "ioct": 2097152,
        "iup": 16384,
        "ier": 0,
        "oer": 0,
        "idc": 0,
        "odc": 0
      }
    }
  ],

  "wireles_info": [
    {
      "band": "2.4GHz",
      "runt_ch": "Ch 6（自動）",
      "client_cnt": 5,
      "sttstcs": {
        "ooct": 524288,
        "oup": 4096,
        "ioct": 1048576,
        "iup": 8192
      }
    },
    {
      "band": "5GHz",
      "runt_ch": "Ch 36 + 40（自動）",
      "client_cnt": 12
    }
  ]
}
```

## Complete JSON Example — Event

```json
{
  "type": "event",
  "ver": "2.00",
  "prdct": "SW",
  "dev_id": "660f9511f30c52e5b827557766551111",
  "date": "2024/01/15 10:45:32",
  "ms_name": "AdminLink",
  "ms_ver": "1.50",
  "agt_name": "SWAgent",
  "agt_ver": "150",

  "evt_id": 4250,
  "act_id": 4250,
  "act_trg": 3,
  "act_para": "port=3",
  "act_sts": 1,
  "msg": "Loop detected on port 3"
}
```

---

## Key Notes for AI Code Generation

### ⚠️ Mutual Exclusion Rules
These pairs are mutually exclusive — include only ONE per JSON payload:

| Pair A | Pair B |
|---|---|
| `accs_type_str` | `accs_type` |
| `mode_str` | `mode` |
| `wireles_band` | `wireles_band_id` |
| `macadr_flt:[]` | `wireles_info:[].mac_flt:[]` |

### Date/Time Format
- Standard: `YYYY/MM/DD hh:mm:ss` (zero-padded, e.g. `2021/01/02 03:04:56`)
- Zero-suppress variant also accepted: `2021/6/2 11:33:48`
- Date-only: `YYYY/mm/dd`

### ID/UUID Format
- `dev_id`: UUID/GUID with NO hyphens or symbols — 32 hex chars only

### String Encoding
- All size limits are **single-byte (half-width)** character counts
- Multi-byte chars (Japanese) count as more than 1

### Status Table Pattern
The `sts:[]` array appears at multiple levels. It always contains the same 6 fields (`evt_id`, `act_id`, `act_trg`, `act_para`, `act_sts`, `msg`). Empty array `[]` when no active events.

### SNMP OID References
Many fields map to standard SNMP OIDs under `1.3.6.1.4.1.41868.*` (private enterprise). Refer to device SNMP MIB for full OID mapping.
