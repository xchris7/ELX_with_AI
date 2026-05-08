# Source Evidence Index

這個目錄保存從原始 SPEC.xlsx 擷取的截圖證據，供人工對照與 AI 爭議回查使用。

權威性排序：

1. `.claude/skills/<skill-name>/SKILL.md`
2. `spec/current/SPEC_v2_AGT*.md`
3. `spec/source_evidence/**/*.png`

使用方式：

- 先讀對應的權威 SKILL
- 若文字規格有疑義，再回查這裡的截圖
- 不要直接把這裡的圖片當成最新真相，必須和現行 SKILL / SPEC 一起看

## API Source Index

|API|Folder|PNG count|Authoritative SKILL|Current SPEC anchor|Notes|
|---|---|---|---|---|---|
|2.2 Device Registration|`2.2.device_registration/`|10|`.claude/skills/adminlink-register-device/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|註冊流程、參數、錯誤碼頁面較多|
|2.3 Auth Info Acquisition|`2.3.auth_info_acquisition/`|5|`.claude/skills/adminlink-auth-info/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|含授權資訊與認證參數|
|2.4 Registration Confirmation|`2.4.device_registration_confirmation/`|3|`.claude/skills/adminlink-confirm-registration/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|與 2.10 共用 URI，需注意 method|
|2.5 Software Update|`2.5/`|3|`.claude/skills/adminlink-software-update/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|軟體更新與 OTA 取得資訊|
|2.6 Upload URL Acquisition|`2.6/`|3|`.claude/skills/adminlink-upload-url/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|2.7 的前置步驟|
|2.7 Upload Completion Notify|`2.7/`|4|`.claude/skills/adminlink-upload-notify/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|圖片比相鄰 API 多 1 張，適合核對狀態與錯誤碼|
|2.8 Download URL Acquisition|`2.8/`|4|`.claude/skills/adminlink-download-url/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|2.9 的前置步驟|
|2.9 Download Completion Notify|`2.9/`|3|`.claude/skills/adminlink-download-notify/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|與 2.8 成對檢查|
|2.10 Device Unregistration|`2.10/`|3|`.claude/skills/adminlink-unregister-device/SKILL.md`|`spec/current/SPEC_v2_AGT2_Agent.md`|與 2.4 共用 URI，需注意 method|

## Folder Naming Notes

- 優先保留帶完整語意的資料夾名稱，例如 `2.2.device_registration/`
- 目前 `2.5/` 到 `2.10/` 有些目錄仍是純數字命名，若之後要再整理，建議改成 `2.<N>.<slug>/`
- 若未來新增 API 截圖，先更新本索引，再新增對應圖片

## Quick Checks

|When you need to verify|Check this first|Then check|
|---|---|---|
|Request / response field meaning|`.claude/skills/<skill-name>/SKILL.md`|matching PNG folder|
|Error code wording|`.claude/skills/<skill-name>/SKILL.md`|matching PNG folder|
|State-machine behavior|`spec/current/SPEC_v2_AGT2_Agent.md`|matching PNG folder if wording differs|
|Version diff or deleted requirement suspicion|matching PNG folder|`spec/archive/` or original merged spec backup|
