# Changelog

## [Unreleased]

### Added
- `gpl_tools/protect_runtime_shell_scripts.py` — wrapper + shc 混合保護
- `gpl_tools/encrypt_shell_scripts.py` — wrapper 加密底層實作
- EW-7896LBE (WAB-BE187-M) 支援（MT7990 / MT7991，P_MTK v8.2.1.5）
- `strip_p_elx_binaries` 函式，統一 P_ELX binary-only 元件處理
- `clean_board_cfg_sensitive` 函式，移除 make_feeds.conf 內 src- feed
- `parse_args` 重構，支援任意順序的旗標組合

### Changed
- `patch_makefiles.py` 新增 `elecom_cloud_apps/config_manager` 殘留引用清除
- be187 的 `clean_p_mtk_wl_radius` 改用 sed（v8.2.1.5 無 clean baseline commit）

### Fixed
- `g_config_elx.h` 生成改為 conditional，避免 non-elx build 失敗

---

## 初始版本

- `gpl.sh` 主腳本，支援 EW-7476LBS / EW-7486LBE / EW-7786LBE
- `gpl_tools/strip_shell_comments.py`
- `gpl_tools/strip_web_comments.py`
- `gpl_tools/patch_makefiles.py`
- `GPL_TEST_SOP.md` 完整 SOP
- `gpl_tools/REFERENCE_MAP.md` 函式索引
