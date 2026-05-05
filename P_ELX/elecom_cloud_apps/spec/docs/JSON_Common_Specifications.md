# JSON Common Specifications / JSON 共通仕様

> *For details of each block, refer to the "JSON Definition" sheet.*  
> *各ブロック詳細は、「JSON定義」シートを参照*

---

## 1. JSON Data Structure / JSONデータ構造

---

### 1.1 Event JSON / イベントJSON

Event JSON consists of the following **two blocks**:  
イベントJSONは下記 **2つのブロック** で構成される。

| # | Block / ブロック | Description / 説明 |
|---|----------------|-------------------|
| ① | Common Items / 共通項目 | Common header fields shared across all JSON types |
| ② | Event JSON body / イベントJSONボディ | Event-specific payload data |

**Structure diagram / 構造図:**

```
┌─────────────────────────────────┐
│         1. Event JSON           │
│         イベントJSON             │
├─────────────────────────────────┤
│      ① Common Items            │
│      ① 共通項目                 │
├─────────────────────────────────┤
│    ② Event JSON body           │
│    ② イベントJSONボディ          │
└─────────────────────────────────┘
```

---

### 1.2 Status JSON / ステータスJSON

Status JSON block composition **differs by device type**.  
ステータスJSONは **デバイス毎に**、異なるブロックで構成される。

#### 1.2.1 NAS

NAS Status JSON consists of the following **three blocks**:  
NAS用のステータスJSONは下記 **3つのブロック** で構成される。

| # | Block / ブロック | Description / 説明 |
|---|----------------|-------------------|
| ① | Common Items / 共通項目 | Common header fields |
| ③ | Status JSON common / ステータスJSON共通 | Common status fields shared across device types |
| ⑤ | Status JSON body (NAS) / ステータスJSONボディ（NAS） | NAS-specific status data |

#### 1.2.2 AP / SWITCH / AP・スイッチ

AP/SWITCH Status JSON consists of the following **three blocks**:  
AP/スイッチ用のステータスJSONは下記 **3つのブロック** で構成される。

| # | Block / ブロック | Description / 説明 |
|---|----------------|-------------------|
| ① | Common Items / 共通項目 | Common header fields |
| ③ | Status JSON common / ステータスJSON共通 | Common status fields shared across device types |
| ⑦ | Status JSON body (AP/SWITCH common) / ステータスJSONボディ（AP/SWITCH共通） | AP/SWITCH common status data; contains ⑧ network statistics sub-block |

**Structure diagram (AP/SWITCH) / 構造図（AP/スイッチ）:**

```
┌──────────────────────────────────────────────────┐
│         2.2. Status JSON (AP/SWITCH)             │
│         2.2. ステータスJSON（AP/スイッチ）          │
├──────────────────────────────────────────────────┤
│                 ① Common Items                  │
├──────────────────────────────────────────────────┤
│          ③ Status JSON Common                   │
│          ③ ステータスJSON共通                     │
├──────────────────────────────────────────────────┤
│   ⑦ Status JSON body (AP/SWITCH common)         │
│   ⑦ ステータスJSONボディ（AP/スイッチ共通）         │
│  ┌────────────────────────────────────────────┐  │
│  │       ⑧ network statistics data           │  │
│  │       ⑧ 統計(statistics)データ              │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

### 1.3 Configuration Status JSON / 設定ステータスJSON

Configuration Status JSON block composition **differs by device type**.  
設定ステータスJSONはデバイス毎に、異なるブロックで構成される。

> **Note: NAS is not supported. / ※NASは非対応。**

| # | Block / ブロック | Description / 説明 |
|---|----------------|-------------------|
| ① | Common Items / 共通項目 | Common header fields |
| ⑨ | Configuration status JSON body / 設定ステータスJSONボディ（AP/SWITCH共通） | AP/SWITCH configuration status data; includes AP-only nested sub-blocks ⑩⑪ |

**⑨ Configuration status JSON body** contains the following AP-only nested blocks:  
**⑨ 設定ステータスJSONボディ** には以下のサブブロック（APのみ）が含まれる：

| # | Sub-Block / サブブロック | Device / 対象 | Description / 説明 |
|---|------------------------|--------------|-------------------|
| ⑩ | SSID information / SSID情報 | AP only / APのみ | SSID configuration details |
| ⑪ | RADIUS Server information / RADIUSサーバー情報 | AP only / APのみ | RADIUS server configuration details |

**Structure diagram / 構造図:**

```
┌────────────────────────────────────────────────────┐
│         3. Configuration status JSON               │
│         3. 設定ステータスJSON                         │
├────────────────────────────────────────────────────┤
│                   ① Common Items                  │
│                   ① 共通項目                        │
├────────────────────────────────────────────────────┤
│      ⑨ Configuration status JSON body             │
│      ⑨ 設定ステータスJSONボディ                       │
│  ┌──────────────────────────────────────────────┐  │
│  │       ⑩ SSID information (AP only)          │  │
│  │       ⑩ SSID情報（APのみ）                   │  │
│  └──────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────┐  │
│  │   ⑪ RADIUS Server information (AP only)     │  │
│  │   ⑪ RADIUSサーバー情報（APのみ）               │  │
│  └──────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────┘
```

---

## 2. Regulations / 仕様

### 2.1 Character Code / 文字コード

| Item | Value |
|------|-------|
| Encoding / 文字コード | **UTF-8 (including BOM) / UTF-8（BOM付）** |

---

### 2.2 Table Items / テーブル項目の規則

Even if items in a table do not exist, **the table itself must still be set**.  
テーブル内の項目が存在しない場合も、**テーブルは設定する事**。

**Example / 例:** "USB/eSATA connection status" when nothing is connected  
「USB/eSATA接続状況」で何も接続されていない時

```json
{ "ex_dev": [] }
```

---

### 2.3 Null Values / null値の規則

If an item value does not exist, **set the value to `null`**.  
項目の値が存在しないときは、**値に `null` を設定する事**。

> When displaying items on the Adminlink Web screen, the item name is displayed and the value is shown as `--`.  
> アドミリンクWeb画面上での項目の表示は、項目名は表示され、値は `--` となります。

**Example / 例:** When uptime cannot be obtained / 通電（稼働）時間(uptime)が取得できない場合

```json
"uptime": null
```

---

### 2.4 Unsupported Items / 非対応項目の規則

If an item is not supported, **do not output the item name**.  
項目をサポートしていない場合は、**項目名を出力しない事**。

> When displaying items on the Adminlink web screen, the items themselves are not displayed.  
> アドミリンクWeb画面上での項目の表示は、項目自体が表示されません。

---

### 2.5 JSON Escape Characters / JSONエスケープ文字

If JSON-prohibited characters are to be included, **escape processing must be performed**.  
JSONの禁止文字を含める場合は、**エスケープ処理を行う事**。

| Character / 文字 | Escape / エスケープ後 |
|-----------------|---------------------|
| `"` Double quotation / ダブルクォーテーション | `\"` |
| `\` Backslash / バックスラッシュ | `\\` |
| Backspace / バックスペース | `\b` |
| Form feed / フォームフィード | `\f` |
| Line feed / ラインフィード | `\n` |
| Carriage return / キャリッジリターン | `\r` |
| Horizontal tab / 水平タブ | `\t` |
| Unicode escape / Unicodeエスケープ | `\uXXXX` |
