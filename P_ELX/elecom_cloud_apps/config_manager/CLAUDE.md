# AGENTS.md — P_ELX/elecom_cloud_apps/config_manager

dbox ↔ JSON 雙向轉換器的 AI 知識層。對應 source code:
`$ELX_SRC/P_ELX/elecom_cloud_apps/config_manager/{dbox_to_json,json_to_dbox}/`

此目錄存放 cloud UI 用的 spec / meta-schema：三個 `*.spec.json` 各自描述
`system_r05`、`wireless_r32`、`toolbox_r18` 三個 tab 的欄位，由
`ui-spec.schema.json` 嚴格驗證。

## Boundaries

- **不要**手改 `*.spec.json`——由 `_export_*` 工作簿產生（見 §Source of truth）。
- **不要**在 `json.path` 重新引入 `[]`——已轉成 `{ segment, array: true }`。
- **不要**從 `enum` 推斷下拉選項——可能是 `enum: null` 的動態 enum（見 Counterintuitive 1）。
- **修改 meta-schema (`ui-spec.schema.json`) 前**：strict mode 下未宣告欄位會直接 reject，先加宣告再加 entry。

## Counterintuitive: cloud UI spec 領域陷阱

1. **`enum: null` 不是缺資料，是 runtime 動態 enum**
   有些 wireless 下拉選項依 ssid count / country code 才能展開。看到 `enum: null` 不要當作壞掉，要查 `ui.range` / `ui.comment`。

2. **`ui.required` 與 `json.required` 可以不同**
   `ui.required` 控表單，`json.required` 控 payload。表單必填不代表一定寫進 config，反之亦然。

3. **英文 `*.en` 是 canonical，日文 `*.ja` 只供 traceability**
   雖客戶是 ELECOM（日商），spec 內衝突一律以英文為準。日文段落不可作為決策依據。

4. **`ssid_no` 系統指派、不可編輯、非 user-editable key**
   SSID array entries 用 `ssid_no` 當不可變 key，使用者表單上看不到也改不了。

5. **UI-only entry（`json: null`）絕不可進 config payload**
   渲染表單但不序列化。寫進 payload 會被 strict schema 拒絕或產生未定義行為。

## Files in this folder

| File | Role |
|---|---|
| `CLAUDE.md` | This guide. Read first. |
| `ui-spec.schema.json` | Meta-schema. Validates every `*.spec.json`. Strict mode — unknown fields are rejected. |
| `system_r05.spec.json` | LAN / VLAN / Syslog / LAN-port settings. JSON root `system_conf`. |
| `wireless_r32.spec.json` | Guest / 2.4G / 5G / 6G / MLO / WDS / RADIUS / Link Integrity. JSON root `wireless_settings`. |
| `toolbox_r18.spec.json` | Admin / Date Time / FW Update / I'm here / Power Saving / Reboot / LED / AdminLink. JSON root `toolbox`. |

## What an entry looks like
Every `entries[]` item has the same shape: `{ id, ui, json }`.
- `ui.*` describes how the field is rendered to the user.
- `json.*` describes how the field is serialized into the device config payload.
- `json: null` means UI-only (do NOT write into config payload).
- English fields (`*.en`) are the source of truth. Japanese (`*.ja`) for traceability only.

### Example 1 — dropdown (string + enum)
```json
{
  "id": "system_conf.lan_ip_address.lan_ip_addr.assignment",
  "ui": { "label": { "en": "IP address assignment" }, "inputType": "dropdown", "default": "DHCP", "required": true },
  "json": { "path": ["system_conf","lan_ip_address","lan_ip_addr","assignment"],
            "type": "string", "default": "dhcp",
            "enum": ["dhcp","static"], "enumName": ["DHCP","Static"], "required": true }
}
```

### Example 2 — checkbox (boolean)
```json
{ "ui": { "inputType": "checkbox", "default": false },
  "json": { "path": ["system_conf","syslog","syslog","enable"], "type": "boolean", "default": false } }
```

### Example 3 — integer textbox with min/max
```json
{ "json": { "path": ["system_conf","lan_ip_address","dhcp","lease"],
            "type": "integer", "default": 48, "minimum": 1, "maximum": 168 } }
```

### Example 4 — IPv4 textbox with format
```json
{ "json": { "path": ["system_conf","lan_ip_address","lan_ip_addr","ipv4addr"],
            "type": "string", "format": "ipv4", "default": "192.168.3.1" } }
```

### Example 5 — array of objects
```json
{ "json": { "path": ["wireless_settings","ssid","ssid",{ "segment":"2g", "array":true },"ssid"],
            "type": "string" } }
```
Renders as `wireless_settings.ssid.ssid.2g[].ssid`. Array elements keyed by `ssid_no`.

### Example 6 — UI-only field (json is null)
If `json` is `null`, render the field but do NOT include it in the config payload.

## Common tasks → which fields to read
| Task | Read |
|---|---|
| Render a screen | All entries with same `ui.screen.en`, sorted by `ui.no` |
| Build default config | Every entry where `json !== null`; walk `json.path` and place `json.default` |
| Validate input | `json.type` + `enum` / `pattern` / `format` / `minimum` / `maximum` |
| Diff two versions | Match by `id` |

## Hard rules
1. `json.type` is exactly one of `string` / `integer` / `boolean`. Arrays/objects are expressed via `json.path`.
2. `enum` and `enumName` are parallel arrays of equal length.
3. Path segments ending in `[]` were converted to `{ segment, array: true }`. Never re-introduce `[]` in paths.
4. `ssid_no` is system-assigned, immutable, not user-editable.
5. UI-only entries (`json: null`) must never appear in the config payload.
6. English (`*.en`) is canonical. Fall back to `ja` only with a translation flag.
7. Meta-schema is strict. New fields require updating `ui-spec.schema.json` first.

## Gotchas
- **Dynamic enums** — Some wireless dropdowns have `enum: null` because options depend on runtime state (ssid count, country code). Don't hard-code from `enum`; check `ui.range` / `ui.comment`.
- **2.4G / 5G / 6G are structurally identical.** Parameterize on the band segment.
- **`required` appears in both `ui` and `json`** and may differ. Use `ui.required` for the form, `json.required` for the payload.
- **`pattern` and `format` may co-exist.** Apply both.
- **`／` separator** is already split into arrays — never split again.
- **Case sensitivity:** `enum` = device value (lower-case), `enumName` = user label.

## Adding a new entry — checklist
1. Decide screen + no + JSON path. Confirm `id` is unique within the tab.
2. Pick `ui.inputType` from `dropdown / radio / checkbox / textbox / label`.
3. Fill `json` according to type:
   - dropdown / radio → `type:"string"` + `enum` + `enumName` (equal length)
   - checkbox → `type:"boolean"`. No min/max/format/pattern.
   - textbox numeric → `type:"integer"` + `minimum` + `maximum`
   - textbox text → `type:"string"` + `format` and/or `pattern`
4. Validate against `ui-spec.schema.json` in strict mode.
5. SSID array entries: do NOT add `ssid_no` — it is generated.

## Source of truth
Flattened source data lives in `_export_system_r05`, `_export_wireless_r32`, `_export_toolbox_r18` (generated from the bilingual spec workbook). Re-running the export overwrites the `*.spec.json` files. Never hand-edit a generated file — fix the source sheet and re-export.
