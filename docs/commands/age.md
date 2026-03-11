---
title: gut age
description: "Show all local branches with how long ago their last commit was made, and how far ahead/behind they are relative to main (or master)."
---
# gut age

Show all local branches with how long ago their last commit was made, and how far ahead/behind they are relative to `main` (or `master`).

---

## Usage

```bash
gut age
```

---

## Example Output

```
=== Branch Ages ===

  Base branch: main

  feature/auth  [current]
    Created: 3 days ago    3 ahead    0 behind main

  hotfix/null-session
    Created: 2 weeks ago    0 ahead    5 behind main

  old-experiment
    Created: 4 months ago    2 ahead    18 behind main
```

---

## What It Shows

| Column | Meaning |
|---|---|
| **Branch name** | Local branch name (active branch is marked `current`) |
| **Created** | Relative time since the branch's last commit |
| **N ahead** | Commits on this branch not yet in `main` |
| **N behind** | Commits in `main` not yet merged into this branch |

!!! tip "Finding stale branches"
    Branches that are many months old and far behind `main` are good candidates for deletion if they've already been merged. Use `gut branch delete <name>` to clean them up.

---

## See Also

- [`gut compare`](compare.md) - detailed diff between two branches
- [`gut branch delete`](branch.md) - remove a branch
- [`gut stats`](stats.md) - contributor commit statistics
