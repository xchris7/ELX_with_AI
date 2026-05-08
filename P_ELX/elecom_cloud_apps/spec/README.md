# AdminLink SPEC Repository

## 目錄結構

```text
spec/
├── current/         現行規格（日常審查與開發引用；檔名仍保留 v2）
│   ├── SPEC_v2_AGT1_WebUI.md
│   ├── SPEC_v2_AGT2_Agent.md
│   ├── SPEC_v2_AGT3_RemoteControl.md
│   └── SPEC_v2_AGT4_ZeroTouch.md
│
├── docs/            實作說明與流程圖（輔助參考）
│   ├── docs_Zero_Touch_Flow_SPEC_Version2.md
│   ├── flowchart TD.mmd
│   └── Zero_touch_flow.png
│
├── source_evidence/ 原始 SPEC.xlsx 截圖與對照證據（非權威文字）
│   ├── 2.2.device_registration/
│   ├── 2.3.auth_info_acquisition/
│   └── 2.10/
│
└── archive/         歷史版本與中間產物（僅供查閱）
    ├── SPEC.md        (v1 舊格式)
    ├── SPEC_v1.md     (v1 正式版 2025-11-11)
    ├── SPEC_v2.bak    (v2 未拆分備份)
    └── src_spec/
        └── SPEC_v2.md (v2 合併原始檔)
```

## 截圖保留 / 清除準則（草案）

保留：

- 與現行 SKILL 或現行 SPEC 直接對應的原始 SPEC.xlsx 截圖
- 可佐證欄位定義、錯誤碼、流程圖、版本差異的頁面
- OCR 容易失真的頁面，例如刪除線、註記、日英混排或複雜表格

清除：

- 重複裁切、重複匯出或僅尺寸不同的同頁圖片
- 模糊到已無法辨識內容的圖片
- 只為一次性 OCR 測試而產生、且不再需要對照的中間產物
- 已無任何 SKILL / SPEC 對應關係的孤兒檔案

放置原則：

- 現行權威文字放在 `current/`
- 原始截圖證據放在 `source_evidence/`
- 每個 API 的快速對照入口放在 `source_evidence/README.md`
- OCR 中間產物若仍需保留，優先放 `archive/` 或 repo 外部，不放 `.claude/skills/`
