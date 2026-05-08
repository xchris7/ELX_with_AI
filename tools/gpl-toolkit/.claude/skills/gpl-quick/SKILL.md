---
name: gpl-quick
description: Quickly re-run GPL cleanup from an existing .build snapshot without rebuilding firmware. Use after a successful /full when re-testing cleanup only. Requires a prior successful /full run.
argument-hint: "MODEL [--protect-shell-scripts]"
disable-model-invocation: true
---

# GPL Quick Validation

從 .build 快照快速重跑 GPL 清理流程（跳過 make）。

```bash
cd /path/to/gcp
./gpl.sh $ARGUMENTS --mode quick
```

Usage: /quick EW-7786LBE
Usage: /quick EW-7786LBE --protect-shell-scripts

前提：必須先有一次成功的 /full 產生的 .build 快照。

跳過：敏感值清理、build 前 source 還原、dropbear 移除、韌體 build。
執行：完整 main_release() 清理流程。
完成後：執行 /report MODEL 產出完整分析報告。
