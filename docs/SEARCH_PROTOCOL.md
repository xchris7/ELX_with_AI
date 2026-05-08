# Search Protocol (Meta)

**Purpose**: Cross-cutting principles for AI-assisted search in this repo. Domain-specific routing lives in each package's `AGENTS.md` (lazy-loaded by AI agents per the [agents.md](https://agents.md/) nested-context model).

**When to read this file**: When the question is *cross-package*, or you don't know which package owns it. For a known domain, open the package's `AGENTS.md` directly via the table below.

## Domain → Package AGENTS.md

| Domain | Read first |
|---|---|
| AdminLink / cloud agent (act_id, MQTT, registration, OTA, …) | [`P_ELX/elecom_cloud_apps/AGENTS.md`](../P_ELX/elecom_cloud_apps/AGENTS.md) |
| dbox API (`dbox_get_*`, `dbox_set_*`, token definitions) | `wab-be187/P_ELX/dbox2/include/`, `nodes/` *(no AGENTS.md yet — see fallback)* |
| CGI / Web UI submit (`*_submit.c`, `cgi_param`) | `wab-be187/P_ELX/fcgibox/modules/submit/elecom/` *(no AGENTS.md yet — see fallback)* |
| Wi-Fi / WLAN encryption (`WLAN_AUTH_*`, `WLAN_ENC_*`) | `wab-be187/board_include/x_wlan.h` + `wab-be187/P_ELX/fcgibox/modules/submit/elecom/wlencrypt_submit.c` |
| GPL release tooling | [`tools/gpl-toolkit/.claude/skills/`](../tools/gpl-toolkit/.claude/skills/) |

When a package gains its own `AGENTS.md`, its row collapses to a single link.

## Cross-cutting principles (apply everywhere)

1. **Spec/refs before source.** If the domain has an entry-point file (SKILL, AGENTS.md, spec), open it first. Source verifies details the spec doesn't cover.
2. **Single-domain stays in its package.** Don't grep `elecom_cloud_apps/` for a pure dbox question.
3. **Token-first for cross-package chains.** Locate a concrete token in its native package first, then grep that exact token across the relevant packages — never grep blindly.

## Generic grep recipe

```bash
# Convergence: which file → which line
grep -rl "PATTERN" <package-scope>      # narrow to the file
grep -n "PATTERN" <file-from-above>     # locate the line

# Cross-package trigger chain (token-first)
grep -n "TOKEN_NAME" <home-package>/    # confirm definition
grep -rn "TOKEN_NAME" wab-be187/P_ELX/{pkg-a,pkg-b}/   # trace usage across packages
```

## Skip rules (also enforced in root `AGENTS.md` Boundaries)

- ❌ `spec/archive/**` — superseded by `spec/current/`
- ❌ `wab-be72/` — different hardware target
- ❌ Recursive grep of the entire `wab-be187/`

## Extension principle

**When adding a new domain or package, do NOT grow this file's content.**

- Add the package to root `AGENTS.md` Layer 3 table (1 row).
- Create `P_ELX/<package>/AGENTS.md` for domain-specific routing, search hints, and counterintuitive rules. Use [`PACKAGE_AGENTS_TEMPLATE.md`](PACKAGE_AGENTS_TEMPLATE.md).
- Update this file's *Domain → Package AGENTS.md* row to a single link (the path-list form is a fallback for packages without AGENTS.md).

This keeps `docs/SEARCH_PROTOCOL.md` at a stable ~40 lines regardless of package count, per progressive-disclosure guidance ([`INDUSTRY_PRACTICES_2026.md`](INDUSTRY_PRACTICES_2026.md) §8.8).
