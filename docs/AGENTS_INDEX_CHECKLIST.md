# AGENTS Index Correctness Checklist

Use this checklist when reviewing index structure in the workspace root `AGENTS.md` and a package-level `P_ELX/<package>/AGENTS.md`.

## Scope

- [ ] The review target is explicitly identified: root `AGENTS.md`, package `AGENTS.md`, or both.
- [ ] The corresponding source tree under `$ELX_SRC/` has been identified before judging index coverage.
- [ ] The review is checking index correctness only, not rewriting domain content.

## Root AGENTS.md

- [ ] Each listed package in root `AGENTS.md` exists under `P_ELX/`.
- [ ] Each listed package also exists under `$ELX_SRC/P_ELX/`.
- [ ] Each package entry points to a real package guide path.
- [ ] The root entry tells the reader where to go next, not just what the package is called.
- [ ] Status text describes guide or knowledge coverage clearly and does not imply non-existent sub-guides.
- [ ] No package with an existing guide is omitted from the root index.
- [ ] No package is listed if the mirrored source package does not exist.

## Package AGENTS.md

- [ ] The package guide identifies the mirrored source path under `$ELX_SRC/P_ELX/<package>/`.
- [ ] The package guide covers the major first-level directories that a reader would reasonably need.
- [ ] Every indexed directory actually exists either in the documentation repo, the mirrored source tree, or both as described.
- [ ] No major working directory is missing from the index.
- [ ] Each directory entry gives a usable first stop: a guide file, a section in the same document, or the exact source subtree.
- [ ] If a directory has no dedicated guide, the index says so indirectly by routing through the package guide first instead of implying a non-existent child guide.
- [ ] Directory descriptions match real ownership boundaries rather than generic guesses.
- [ ] The index distinguishes clearly between documentation directories, source directories, and evidence or test directories.

## Routing Check

- [ ] A reader looking for API behavior can reach the correct SKILL or spec entry within one or two hops.
- [ ] A reader looking for source implementation can identify the correct subtree without guessing directory names.
- [ ] A reader looking for config contract information is routed to the package-specific contract guide when one exists.
- [ ] A reader looking for tests or verification artifacts can distinguish them from normative specs.
- [ ] Cross-package search guidance does not send the reader into broad repo-wide search before a local index or owning document is checked.

## Mismatch Check

- [ ] The index does not name directories that do not exist.
- [ ] The index does not omit directories that are repeatedly referenced elsewhere in the same guide.
- [ ] The index does not claim a child guide that is missing.
- [ ] The index does not label a source subtree as authoritative for specs when the guide says SKILL or spec files are the source of truth.
- [ ] The same concept is not routed to two conflicting first stops.

## Walkthrough Test

- [ ] Starting from root `AGENTS.md`, you can navigate to the intended package guide without guessing.
- [ ] Starting from the package guide, you can find the API/spec entry path without using repo-wide grep.
- [ ] Starting from the package guide, you can find the main implementation subtree without ambiguity.
- [ ] Starting from the package guide, you can find config-related material without mistaking source code for the contract.
- [ ] Starting from the package guide, you can tell where tests or validation helpers live.

## Review Outcome

- [ ] Coverage is complete enough for common entry points.
- [ ] Routing is accurate enough that the next step is obvious.
- [ ] Terminology matches the real structure.
- [ ] The index introduces no false affordances.
- [ ] Any remaining gaps are listed explicitly as follow-up work.

## Notes

- Write findings as `missing`, `misrouted`, `ambiguous`, or `accurate`.
- If a gap is intentional, note the reason next to the unchecked item.
- When checking a package guide, validate against both `P_ELX/<package>/` and `$ELX_SRC/P_ELX/<package>/` as applicable.
