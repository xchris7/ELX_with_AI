# GPL Release Mode

在既有 GPL source tree 根目錄直接執行 release 清理（不重建工作樹）。

```bash
cd /path/to/wab-be72-gpl
/path/to/gcp/gpl.sh $ARGUMENTS
```

Usage: /gpl-release EW-7786LBE

注意：
- 必須在仍保有 .git 的 GPL source tree 根目錄執行
- SOURCE_PATH 取自 pwd（當前目錄）
- gpl_tools/ 從 gpl.sh 所在目錄尋找
- 不會重建工作樹，也不會先做原始韌體 build
