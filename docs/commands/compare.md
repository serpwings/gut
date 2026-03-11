---
title: gut compare
description: "Compare your current branch against another to see ahead/behind counts, changed files, and unique commits on each side."
---
# gut compare

Compare your current branch against another to see ahead/behind counts, changed files, and unique commits on each side.

---

## Usage

```bash
gut compare <branch-or-commit>
```

---

## Example Output

```
=== Comparing main -> feature/auth ===

  3 commit(s) ahead of main
  1 commit(s) behind main

Changed Files:
  src/auth.js  (12 change(s))
  tests/auth.spec.js  (4 change(s))
  2 files changed, 16 insertions(+), 0 deletions(-)

Commits only in feature/auth:
  + a1b2c3d add JWT validation
  + d4e5f6a scaffold auth service
  + g7h8i9j add login endpoint

Commits only in main:
  - z1y2x3w merge hotfix for null session
```

---

## What It Shows

| Section | Description |
|---|---|
| **Ahead / Behind** | How many commits each branch has that the other doesn't |
| **Changed Files** | List of files with differences between the two branches |
| **Commits only in `current`** | Commits you have that the target doesn't |
| **Commits only in `target`** | Commits the target has that you don't |

---

## See Also

- [`gut branch`](branch.md) - create and manage branches
- [`gut integrate`](integrate.md) - merge the target into current
- [`gut age`](age.md) - see branch ages and ahead/behind totals
