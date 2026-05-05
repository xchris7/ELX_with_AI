# gpl-toolkit

ELECOM 無線 AP 韌體的 GPL 釋出自動化工具組。  
將 internal firmware source tree 整理成符合 GPL 授權要求的公開 release tarball。

---

## 支援機種

| MODEL | 客戶型號 | Wi-Fi 晶片 |
|-------|---------|-----------|
| EW-7476LBS | WAB-BE36-S | MT7992 |
| EW-7486LBE | WAB-BE36-M | MT7992 |
| EW-7786LBE | WAB-BE72-M | MT7992 |
| EW-7896LBE | WAB-BE187-M | MT7990 / MT7991 |

---

## 需求

| 工具 | 說明 |
|------|------|
| `bash` ≥ 4.0 | 主腳本執行環境 |
| `python3` | gpl_tools/ 輔助工具 |
| `git` | 來源樹操作 |
| `find`, `tar` | 基本操作 |
| `make` | `--mode full` 時需要 |
| `openssl`, `shc` | `--protect-shell-scripts` 時需要 |

安裝 shc（Ubuntu/Debian）：

```bash
sudo apt install shc
```

---

## 安裝

```bash
git clone <repo-url> gpl-toolkit
cd gpl-toolkit
```

不需要額外安裝步驟，直接執行 `gpl.sh` 即可。

---

## 使用方式

### Release 模式（在已整理好的 GPL tree 內執行）

```bash
cd <GPL_DIR_NAME>
/path/to/gpl-toolkit/gpl.sh <MODEL>
```

### Test 模式（full — 首次，含完整 build）

```bash
./gpl.sh <MODEL> --mode full
```

需要在同層目錄準備好 `<GPL_DIR_NAME>.src`。  
Build 成功後會存下 `<GPL_DIR_NAME>.build` 快照，供後續 quick mode 使用。

### Test 模式（quick — 重複驗證）

```bash
./gpl.sh <MODEL> --mode quick
```

使用既有的 `.build` 快照，跳過耗時的 `make`，快速重跑 GPL 清理流程。

### 加上 shell script 保護

```bash
./gpl.sh <MODEL> --mode quick --protect-shell-scripts
```

對 `add_files/` 及 `wifi7_add_files/wl_scripts/` 內的 shell scripts 套用混合保護：
- **sourced / library scripts** → 自解密 wrapper（仍是 shell）
- **直接執行 scripts** → shc 編譯為 target ELF binary

---

## 目錄結構

```
gpl-toolkit/
├── gpl.sh                  # 主腳本
├── gpl_tools/
│   ├── strip_shell_comments.py         # 移除 shell script 開發者註解
│   ├── strip_web_comments.py           # 移除 web 檔案開發者註解
│   ├── patch_makefiles.py              # 修補 Makefile（GPL release 政策）
│   ├── protect_runtime_shell_scripts.py # wrapper + shc 混合保護
│   ├── encrypt_shell_scripts.py        # wrapper 加密底層實作
│   └── REFERENCE_MAP.md               # 函式索引與決策樹（給 AI / 開發者）
├── GPL_TEST_SOP.md         # 完整 SOP 文件
├── CONTRIBUTING.md         # 開發者指引
└── CHANGELOG.md            # 版本記錄
```

執行時期會在工具組**同層目錄**建立：

```
<GPL_DIR_NAME>.src/         # 原始來源樹（full mode 輸入）
<GPL_DIR_NAME>.build/       # build 後快照（quick mode 輸入）
<GPL_DIR_NAME>/             # 每次執行重建的工作樹
```

---

## 產出

成功後在工作樹目錄內產生：

```
<CUSTOMER_MODEL_NAME>_<version>_<date>.tar.gz
```

例如：`WAB-BE72-M_1.2.3_20260430.tar.gz`

---

## 完整 SOP

詳見 [GPL_TEST_SOP.md](GPL_TEST_SOP.md)。

開發者指引（新增機種、修改清理規則）詳見 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## License

本工具組本身以 MIT License 釋出。  
所處理的韌體各套件依其原始授權（GPL v2、LGPL 等）釋出。
