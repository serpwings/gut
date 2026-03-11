---
title: gut stats
description: "Display contributor statistics for the current repository - commit counts, percentage share, and approximate lines added/deleted per author."
---
# gut stats

Display contributor statistics for the current repository - commit counts, percentage share, and approximate lines added/deleted per author.

---

## Usage

```bash
gut stats
```

---

## Example Output

```
=== Contributor Statistics ===

  Total commits: 142

  Commits per author:
  alice
    ============........ 88 commits (62%)
  bob
    ========............ 54 commits (38%)

  Lines per author (approximate):
    alice                          +4821 / -1204
    bob                            +2341 / -870
```

---

## What It Shows

| Section | Source |
|---|---|
| **Total commits** | `git rev-list --count HEAD` |
| **Commits per author** | `git shortlog -sn --no-merges` |
| **Bar chart** | Visual percentage (each block = ~5%) |
| **Lines per author** | `git log --numstat` (excludes merge commits) |

!!! note
    Lines changed is an approximation based on `numstat` output. Binary files and auto-generated code will skew the numbers.

---

## See Also

- [`gut blame`](blame.md) - see who wrote specific lines in a file
- [`gut age`](age.md) - see branch ages and ahead/behind status
- [`gut history`](history.md) - see the commit log
