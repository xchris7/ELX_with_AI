# AGENTS.md — P_ELX/elecom_cloud_apps/config_manager

dbox ↔ JSON 雙向轉換器的 **cloud config 契約**。三個 `*.spec.json` 描述
`system_r05` / `wireless_r32` / `toolbox_r18` 三個 tab 的所有欄位，由
`ui-spec.schema.json` 嚴格驗證（draft-07, strict）。

## Role & Data Flow

```
SPEC 工作簿 (Excel)
   │  _export_*  (re-export 即覆蓋此目錄)
   ▼
ELX_with_AI/.../config_manager/*.spec.json   ← 機讀契約（給 source code 與 AI 讀）
   │  read & implement
   ▼
$ELX_SRC/P_ELX/elecom_cloud_apps/config_manager/{dbox_to_json,json_to_dbox}/
   │
   ├── dbox_to_json/  device dbox → cloud-bound JSON
   └── json_to_dbox/  cloud JSON → device dbox
```

- **Excel 是唯一可改源**。`*.spec.json` 由 `_export_*` 流程覆寫，**不要**手改。
- **此 spec 對 device source code 是契約**（不是中介產物）：source 端必須遵循此處的 `json.path` / `json.type` / `json.enum` / `json.format`，否則 cloud 收到的 JSON 不合 spec。
- **改 cloud UI 欄位** = 改 Excel → 重 export → 跟著改 source（兩側 dbox_to_json + json_to_dbox）。

## Commands

```bash
# 驗 spec.json JSON 合法
jq . *.spec.json >/dev/null

# (可選 ajv) 驗 spec.json 符合 meta-schema strict
ajv -s ui-spec.schema.json -d system_r05.spec.json --strict=true

# 列某 tab 所有要寫進 payload 的欄位 path（產 default config 用）
jq -r '.entries[] | select(.json != null) | .json.path
       | map(if type=="object" then .segment + "[]" else . end) | join(".")' \
   system_r05.spec.json

# 對應 source 端
ls $ELX_SRC/P_ELX/elecom_cloud_apps/config_manager/{dbox_to_json,json_to_dbox}/
```

## Boundaries

- **不要**手改 `*.spec.json`——由 Excel `_export_*` 流程產生。
- **不要**在 `json.path` 重新引入 `[]`——已轉成 `{ segment, array: true }` 物件。
- **不要**從 `enum` 推斷下拉選項——可能是 `enum: null` 的動態 enum（見 Counterintuitive #3）。
- **不要**把 `ui.default` 當識別 key——它常為日文顯示值（見 Counterintuitive #1）。
- **修改 meta-schema `ui-spec.schema.json` 前**：strict mode 下未宣告欄位會直接 reject，先加宣告再加 entry。

## Counterintuitive: 此 spec 的真實面陷阱

1. **`ui.default` 是 enum 顯示值（常為日文），不是 device value**
   範例：`ui.default = "DHCPクライアント"` 而 `json.default = "dhcp"`。device 預設值永遠在 `json.default`（lower-case ASCII）。把 `ui.default` 當識別 key 會錯。

2. **`enumName` 目前只有日文，沒有英文**
   `json.enumName: ["DHCPクライアント","静的IPアドレス"]`——資料層尚無英文 label。要渲英文 UI 只能 fallback 到 `json.enum`（device value）。**此為已知資料缺口**，待 Excel 工作簿補強，不在此 repo 解。

3. **`ui.range` / `ui.validation` 是自由文字日文，不可機讀**
   範例：`ui.range = "固定IPアドレス/DHCPクライアント"`、`ui.validation = "なし"`。看到 `enum: null` 的動態下拉選項時，**不能**從 `ui.range` 解析；要去 source code（`gen_<tab>.c` 或 `config_<screen>.c`）看 runtime 行為。

4. **`ui.required` 與 `json.required` 規範不同層、可不同**
   `ui.required` 是表單強制；`json.required` 是 payload 強制。device 實作以 `json.required` 為準；UI 限制以 `ui.required` 為準。實際資料中兩者常不同。

5. **「canonical」依欄位類型不同**
   - **裝置內部值** canonical = `json.enum` 元素（lower-case ASCII，例 `"dhcp"`）
   - **人類可讀文字**（`label` / `screen` / `comment`）canonical = `*.en`，`*.ja` 是翻譯
   不能一律宣稱「`.en` canonical」。

## How source code uses this spec

對應 source code（已實際抽查 `~/wab-be187/P_ELX/elecom_cloud_apps/config_manager/`）：

### dbox → json（裝置端產生 cloud-bound JSON）

| spec.json | source code |
|-----------|-------------|
| `tab: system_r05` 整份 | `dbox_to_json/generator/gen_system_conf.c` |
| `tab: wireless_r32` 整份 | `dbox_to_json/generator/gen_wireless.c` + `gen_wireless_helper.c` |
| `tab: toolbox_r18` 整份 | `dbox_to_json/generator/gen_toolbox.c` |
| 共用 framework | `dbox_to_json/generator/json_generator.{h,c}` |
| CLI entry（支援 `-s system_conf|wireless|toolbox|all`） | `dbox_to_json/main.c` |

### json → dbox（裝置端消化 cloud 下發的 JSON）

`json_to_dbox/main.c` 依 top-level key (`system_conf` / `wireless_settings` / `toolbox`) 分派到各 `set_page_*()`：

| spec entry 範圍（依 `json.path[0]` + `path[1]`） | source 函式 / 檔案 |
|--------------------------------------------------|-------------------|
| `system_conf.lan_ip_address.*` | `set_page_lan_ip_address()` in `system/config_lan_ip.c` |
| `system_conf.lan_port.*` | `set_page_lan_port()` in `system/config_lan_port.c` |
| `system_conf.vlan.*` | `set_page_vlan_settings()` in `system/config_vlan.c` |
| `system_conf.syslog.*` | `set_page_syslog_settings()` in `system/config_syslog.c` |
| `wireless_settings.*`（單一入口分派各 band） | `set_page_wireless_settings()` in `wireless/config_wireless.c`，再進 `config_2g.c` / `config_5g.c` / `config_6g.c` / `config_mlo.c` / `config_wds.c` / `config_radius.c` / `config_guest_network.c` / `config_link_integrity.c` / `config_mac_filter.c` / `config_schedule.c` / `config_emergency_mode.c` / `config_wmm.c` |
| `toolbox.admin.*` | `set_page_admin()` in `toolbox/config_admin.c` |
| `toolbox.adminlink.*` | `set_page_adminlink()` in `toolbox/config_adminlink.c` |
| `toolbox.date_time.*` | `set_page_date_time()` in `toolbox/config_date_time.c` |
| `toolbox.fw_update.*` | `set_page_fw_update()` in `toolbox/config_fw_update.c` |
| `toolbox.power_saving.*` | `set_page_power_saving()` in `toolbox/config_power_saving.c` |
| `toolbox.reboot_schedule.*` | `set_page_reboot_schedule()` in `toolbox/config_reboot_schedule.c` |
| `toolbox.led.*` | `set_page_led_setting()` in `toolbox/config_led_setting.c` |
| validator helpers | `json_to_dbox/util/config_validator.c`、`util/sch_util.c` |

### Field-level mapping rules

```
spec.json entry                  source code 對應
──────────────────────          ──────────────────────────────────
json.path[]                  →  cJSON_GetObjectItemCaseSensitive() 串走訪
json.type: "string"          →  cJSON_IsString → dbox_set_str_value(TOKEN, ...)
json.type: "integer"         →  cJSON_IsNumber → dbox_set_int_value(TOKEN, ...)
json.type: "boolean"         →  cJSON_IsBool   → dbox_set_int_value(TOKEN, 0/1)
json.enum + enumName         →  string-compare 後對應到 dbox token 數值
json.format: "ipv4"          →  validator (config_validator.c) 檢查 IPv4
json.default                 →  factory default（重置時用）
json: null                   →  跳過（UI-only，不進 dbox / 不進 payload）
{segment, array:true}        →  cJSON_GetArrayItem 走訪每個 element
```

### 修改 / 新增欄位的 source-side checklist

1. spec.json 已從 Excel re-export，**不要手改**
2. **dbox→json 側**：在 `dbox_to_json/generator/gen_<tab>.c` 加對應 dbox token 走訪 → 組 cJSON 物件
3. **json→dbox 側**：在 `json_to_dbox/<tab>/config_<screen>.c` 對應 `set_page_*()` / 子函式內加 cJSON 解析 + dbox 寫入
4. 若新 enum：確認 device 內部 value 已對應到 dbox token，並在 source 內處理 string→int 對映
5. 若新 array 欄位：兩側都要走 `cJSON_GetArrayItem` 迴圈
6. `make -C $ELX_SRC/P_ELX/elecom_cloud_apps/config_manager` build 通過
7. 跑 round-trip 驗證：`dbox_to_json` 出來的 JSON 餵給 `json_to_dbox` 應還原同樣 dbox state

## Files in this folder

| File | Role |
|---|---|
| `CLAUDE.md` | This guide. Read first. |
| `ui-spec.schema.json` | Meta-schema. Validates every `*.spec.json`. Strict mode — unknown fields are rejected. |
| `system_r05.spec.json` | LAN / VLAN / Syslog / LAN-port. JSON root `system_conf`. |
| `wireless_r32.spec.json` | Guest / 2.4G / 5G / 6G / MLO / WDS / RADIUS / Link Integrity. JSON root `wireless_settings`. |
| `toolbox_r18.spec.json` | Admin / Date Time / FW Update / Power Saving / Reboot / LED / AdminLink. JSON root `toolbox`. |

## Entry shape

Every `entries[]` item: `{ id, ui, json }`.

- `ui.*` describes how the field is rendered.
- `json.*` describes how the field is serialized into the device config payload.
- `json: null` means UI-only (do NOT write into payload).

## Examples

### Example 1 — dropdown (string + enum)
```json
{
  "id": "system_conf.lan_ip_address.lan_ip_addr.assignment",
  "ui": { "label": { "en": "IP address assignment" }, "inputType": "dropdown", "default": "DHCPクライアント", "required": true },
  "json": { "path": ["system_conf","lan_ip_address","lan_ip_addr","assignment"],
            "type": "string", "default": "dhcp",
            "enum": ["dhcp","static"], "enumName": ["DHCPクライアント","静的IPアドレス"], "required": false }
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

## Hard rules（純機械約束）

1. `json.type` ∈ {`string`, `integer`, `boolean`}。Arrays/objects 由 `json.path` 表達。
2. `enum` 與 `enumName` 是平行陣列，長度必須相等。
3. `json.path` 中 array 段必為 `{ segment, array: true }` 物件，**永不**用 `[]` 字串。
4. `ssid_no` 系統指派、不可編輯，SSID array 用它當 immutable key。
5. UI-only entry（`json: null`）絕不可進 config payload。
6. Meta-schema strict：新欄位先改 `ui-spec.schema.json`，再加 entry。

## Gotchas

- **2.4G / 5G / 6G 結構同形**：可參數化 band segment；spec 內三組 entry 平行存在。
- **`／` 分隔符**：spec export 已 split 成 array；source 端不要再 split。
- **Case sensitivity**：`json.enum` 元素是 lower-case device value；`json.enumName` 是顯示 label，大小寫由 spec 決定。

## Adding a new entry — checklist

1. Excel 改完 → re-export → spec.json 自動更新。
2. 對應 source 兩側都要動（見 §How source code uses this spec → checklist）。
3. `id` 在同 tab 內唯一。
4. Pick `ui.inputType`：`dropdown` / `radio` / `checkbox` / `textbox` / `label`。
5. 依 `json.type` 填：
   - dropdown / radio → `type:"string"` + `enum` + `enumName`（等長）
   - checkbox → `type:"boolean"`，無 min/max/format/pattern
   - textbox 數字 → `type:"integer"` + `minimum` + `maximum`
   - textbox 文字 → `type:"string"` + `format` 與 / 或 `pattern`
6. SSID array entries 不要加 `ssid_no`——系統產生。

## Domain Knowledge

- Meta-schema：`ui-spec.schema.json`（draft-07, strict）
- Spec 上游：SPEC 工作簿（不在此 repo），由 `_export_*` 流程覆寫此目錄
- Source code 真相：`$ELX_SRC/P_ELX/elecom_cloud_apps/config_manager/{dbox_to_json,json_to_dbox}/`
- 父層 package 指引：[../CLAUDE.md](../CLAUDE.md)
