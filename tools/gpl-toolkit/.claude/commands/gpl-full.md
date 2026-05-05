# GPL Full Build

在 repo root 執行完整 GPL 驗證與 .build 快照建立。

```bash
cd /path/to/gcp
./gpl.sh $ARGUMENTS --mode full
```

若未傳入 MODEL，預設為 EW-7786LBE。
Usage: /gpl-full EW-7786LBE

注意：遵守 CLAUDE.md「Token 節費規則」— gpl.sh 與 make 用 `run_in_background` 執行，完成後只 `tail -20` 確認結果。

步驟：

1. 將 <GPL_DIR_NAME>.src 複製成工作樹
2. 清除敏感雲端值
3. 還原 GPL 套件到 release 版本
4. 移除 dropbear
5. 執行 make 建置韌體
6. 驗證 uImage 與 FW image
7. 儲存 .build 快照
8. 執行 main_release() 清理流程
9. 執行 /gpl-report MODEL 產出完整分析報告
