# GPL Release 專案

## 專案簡介

此目錄用於 ELECOM 無線 AP 韌體的 GPL 釋出流程，負責將 internal firmware source tree 整理成符合 GPL 授權要求的公開 release tarball。

## 支援機種

| MODEL | GPL_DIR_NAME | CUSTOMER_MODEL_NAME | P_MTK 版本 | Wi-Fi 晶片 |
|-------|-------------|---------------------|-----------|-----------|
| EW-7476LBS | wab-be36-s-gpl | WAB-BE36-S | mt7988-mt7992-MP3 | MT7992 |
| EW-7486LBE | wab-be36-gpl | WAB-BE36-M | mt7988-mt7992-MP3 | MT7992 |
| EW-7786LBE | wab-be72-gpl | WAB-BE72-M | mt7988-mt7992-MP3 | MT7992 |
| EW-7896LBE | wab-be187-gpl | WAB-BE187-M | v8.2.1.5 | MT7990 / MT7991 |

## 核心檔案

- `gpl.sh` — 主腳本，負責 GPL release 清理與 test workflow
- `gpl_tools/` — Python 輔助工具：
  - `strip_shell_comments.py` — 移除 shell script 註解
  - `strip_web_comments.py` — 移除 web 檔案開發者註解
  - `patch_makefiles.py` — 修補 Makefile
  - `protect_runtime_shell_scripts.py` — shell script 保護（wrapper + shc）
  - `encrypt_shell_scripts.py` — 加密工具
- `GPL_TEST_SOP.md` — 完整 SOP 文件（中文）

## 快速指令

```bash
# 完整驗證（第一次）
./gpl.sh EW-7786LBE --mode full

# 快速重跑 GPL 清理
./gpl.sh EW-7786LBE --mode quick

# 加 shell script 保護
./gpl.sh EW-7786LBE --mode quick --protect-shell-scripts

# 在既有 GPL tree 內直接整理
cd wab-be72-gpl
/path/to/gcp/gpl.sh EW-7786LBE
```

## 目錄約定（test mode）

- `<GPL_DIR_NAME>.src` — 原始來源樹（full 模式輸入）
- `<GPL_DIR_NAME>.build` — 成功 build 後的快照（quick 模式輸入）
- `<GPL_DIR_NAME>` — 每次執行 --mode 時重新建立的工作樹

## 相依工具

- 基本：`find`, `git`, `python3`, `tar`
- full mode 額外需要：`make`
- protect-shell-scripts 額外需要：`openssl`, `shc`（`sudo apt install shc`）

## 完整 SOP

詳見 `GPL_TEST_SOP.md`。
