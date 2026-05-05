---
title: JSON Common Specifications
version: 1.0
language: en
description: >
  Defines the common JSON data structure, block composition rules, and encoding
  regulations used across all device types (NAS, AP, SWITCH) in the Adminlink
  service. Covers Event JSON, Status JSON, and Configuration Status JSON.
tags: [json, specification, event, status, configuration, NAS, AP, SWITCH]
---

# JSON Common Specifications

> For details of each numbered block (①–⑪), refer to the **JSON Definition** sheet.

---

## 1. JSON Data Structure

All JSON messages in this system are composed of **named blocks** identified by
circled numbers (①②③…). Block composition varies by JSON type and device type.

---

### 1.1 Event JSON

Sent by the device to report events.

**Block composition:**

| Block ID | Name | Description |
|----------|------|-------------|
| ① | Common Items | Common header fields shared across all JSON types |
| ② | Event JSON body | Event-specific payload data |

**Structure:**

```
Event JSON
├── ① Common Items
└── ② Event JSON body
```

---

### 1.2 Status JSON

Reports the current operational status of a device.  
Block composition **differs by device type**.

#### 1.2.1 NAS

| Block ID | Name | Description |
|----------|------|-------------|
| ① | Common Items | Common header fields |
| ③ | Status JSON common | Status fields shared across all device types |
| ⑤ | Status JSON body (NAS) | NAS-specific status data |

**Structure:**

```
Status JSON [NAS]
├── ① Common Items
├── ③ Status JSON common
└── ⑤ Status JSON body (NAS)
```

#### 1.2.2 AP / SWITCH

| Block ID | Name | Description |
|----------|------|-------------|
| ① | Common Items | Common header fields |
| ③ | Status JSON common | Status fields shared across all device types |
| ⑦ | Status JSON body (AP/SWITCH common) | AP/SWITCH shared status data |
| ⑧ | network statistics data | Network statistics sub-block nested inside ⑦ |

**Structure:**

```
Status JSON [AP / SWITCH]
├── ① Common Items
├── ③ Status JSON common
└── ⑦ Status JSON body (AP/SWITCH common)
    └── ⑧ network statistics data
```

---

### 1.3 Configuration Status JSON

Reports the current configuration state of a device.  
Block composition **differs by device type**.

> **NAS is not supported for this JSON type.**

| Block ID | Name | Device Scope | Description |
|----------|------|-------------|-------------|
| ① | Common Items | All | Common header fields |
| ⑨ | Configuration status JSON body | AP / SWITCH | AP/SWITCH configuration status data |
| ⑩ | SSID information | AP only | SSID configuration details (nested inside ⑨) |
| ⑪ | RADIUS Server information | AP only | RADIUS server configuration details (nested inside ⑨) |

**Structure:**

```
Configuration Status JSON [AP / SWITCH]
├── ① Common Items
└── ⑨ Configuration status JSON body
    ├── ⑩ SSID information          [AP only]
    └── ⑪ RADIUS Server information [AP only]
```

---

## 2. Encoding

| Property | Value |
|----------|-------|
| Character encoding | UTF-8 |
| BOM | Required (UTF-8 with BOM) |

---

## 3. Data Representation Rules

### 3.1 Empty Tables

If no items exist within a table field, the table key **must still be present** with an
empty array as its value. Do not omit the key.

```json
{ "ex_dev": [] }
```

*Example context: `ex_dev` (USB/eSATA connected devices) when no devices are attached.*

---

### 3.2 Missing Values — Use `null`

If an item is supported by the device but its value cannot be obtained at runtime,
set the value to **`null`**. Do not omit the key.

```json
{ "uptime": null }
```

*On the Adminlink Web UI, the item label is shown and the value is displayed as `--`.*

---

### 3.3 Unsupported Items — Omit the Key

If an item is **not supported** by the device model, **omit the key entirely** from
the JSON output. Do not output the key with a `null` or empty value.

*On the Adminlink Web UI, unsupported items are not displayed at all.*

> **Rule summary:**
> | Situation | Action |
> |-----------|--------|
> | Item supported, value available | Output key with value |
> | Item supported, value unavailable | Output key with `null` |
> | Item not supported | Omit key entirely |

---

### 3.4 JSON Character Escaping

All JSON-prohibited characters must be escaped before inclusion in string values.

| Character | Escape Sequence |
|-----------|----------------|
| `"` (double quotation mark) | `\"` |
| `\` (backslash) | `\\` |
| Backspace (U+0008) | `\b` |
| Form feed (U+000C) | `\f` |
| Line feed / newline (U+000A) | `\n` |
| Carriage return (U+000D) | `\r` |
| Horizontal tab (U+0009) | `\t` |
| Other control characters | `\uXXXX` |
