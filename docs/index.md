---
title: gut
description: "Git with better UX. A pure Bash wrapper around Git - friendlier commands, plain-English errors, and safety guardrails."
---
# gut

**Git with better UX.** A pure Bash wrapper around Git - friendlier commands, plain-English errors, and safety guardrails.  
No dependencies beyond `bash` and `git`.

---

## Why gut?

Git is powerful, but its interface was designed for kernel developers, not everyday users. **gut** makes Git approachable without sacrificing any of its power.

| Problem | How gut helps |
|---|---|
| `git checkout` does 5 different things | One concept, one command |
| Cryptic errors like "non-fast-forward" | Plain-English translations + actionable fixes |
| Staging area confusion (3-way split) | `gut status` visualises all three areas clearly |
| `reset` vs `revert` vs `restore` | `gut undo` replaces all three, interactively |
| Interactive rebase is daunting | `gut replay` guides you through squash/reword/drop |
| Submodule commands are inconsistent | `gut sub`  clean list/add/update/sync/remove |
| Large files silently bloat history | `gut big` scans tree + history, integrates LFS |
| Recovery is "Google every error" | `gut rescue` diagnoses and fixes interactively |

---

## Quick Start

```bash
git clone https://github.com/serpwings/gut.git
cd gut && ./install.sh
```

Then use `gut` wherever you'd use `git`:

```bash
gut status              # see what's changed
gut save -m "fix bug"   # stage + commit in one step
gut sync                # smart pull or push
gut undo                # soft-undo last commit
gut rescue              # diagnose any problem
```

---

## Design Principles

- **One concept = one command.** No flag overloading.
- **Always explain** what's happening and why.
- **Interactive prompts** when intent is unclear  never guess destructively.
- **Warn before every destructive operation** and require confirmation.
- **Plain-English errors** translate cryptic git output into fix suggestions.
- **Escape hatch always available** via `gut git <cmd>` or `gut log`.

---

## Command Overview

=== "Core Workflow"
    | Command | Description |
    |---|---|
    | [`gut status`](commands/status.md) | Visual, labelled breakdown of all three Git areas |
    | [`gut save`](commands/save.md) | Stage + commit in one step |
    | [`gut undo`](commands/undo.md) | Replaces `reset`, `revert`, `restore` |
    | [`gut sync`](commands/sync.md) | Smart pull/push with divergence handling |
    | [`gut branch`](commands/branch.md) | Branch creation, deletion, renaming |
    | [`gut switch`](commands/branch.md#switch) | Switch branches safely |

=== "History & Inspection"
    | Command | Description |
    |---|---|
    | [`gut history`](commands/history.md) | Clean, readable commit log |
    | [`gut compare`](commands/compare.md) | Diff summary between branches |
    | [`gut blame`](commands/blame.md) | Annotated file history by author |
    | [`gut stats`](commands/stats.md) | Contributor statistics with bar charts |
    | [`gut age`](commands/age.md) | Branch ages and ahead/behind status |

=== "Recovery"
    | Command | Description |
    |---|---|
    | [`gut stash`](commands/stash.md) | Save/restore/manage work in progress |
    | [`gut snapshot`](commands/snapshot.md) | Timestamped quicksave stash |
    | [`gut whoops`](commands/whoops.md) | Reflog browser to jump to any past state |
    | [`gut rescue`](commands/rescue.md) | Diagnose and fix common Git problems |
    | [`gut bisect`](commands/bisect.md) | Guided binary search for a bad commit |

=== "Advanced"
    | Command | Description |
    |---|---|
    | [`gut integrate`](commands/integrate.md) | Merge or rebase with guidance |
    | [`gut replay`](commands/replay.md) | Friendly interactive rebase |
    | [`gut sub`](commands/sub.md) | Submodule management |
    | [`gut big`](commands/big.md) | Large file scan + Git LFS integration |
    | [`gut tag`](commands/tag.md) | Semantic version tags |
    | [`gut protect`](commands/protect.md) | Block direct pushes to branches |
    | [`gut alias`](commands/alias.md) | Personal command shortcuts |
    | [`gut pr`](commands/pr.md) | Open a pull request in the browser |
    | [`gut patch`](commands/patch.md) | Export/apply commits as `.patch` files |
