# GPL Quick Validation

從 .build 快照快速重跑 GPL 清理流程（跳過 make）。

```bash
cd /path/to/gcp
./gpl.sh $ARGUMENTS --mode quick
```

Usage: /gpl-quick EW-7786LBE
Usage: /gpl-quick EW-7786LBE --protect-shell-scripts

前提：必須先有一次成功的 /gpl-full 產生的 .build 快照。

跳過：敏感值清理、build 前 source 還原、dropbear 移除、韌體 build。
執行：完整 main_release() 清理流程。
