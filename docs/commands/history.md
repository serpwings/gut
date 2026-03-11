---
title: gut history
description: "View a clean, one-line commit log for the current branch."
---
# gut history

View a clean, one-line commit log for the current branch.

---

## Usage

```bash
gut history [N]
```

`N` is an optional number limiting how many commits to show. If omitted, shows the full history.

---

## Example Output

```
a1b2c3d  fix: null check on login redirect
d4e5f6a  feat: add JWT validation
g7h8i9j  chore: update dependencies
h0i1j2k  initial commit
```

---

## Examples

```bash
# Show full history
gut history

# Show the 5 most recent commits
gut history 5
```

---

## See Also

- [`gut status`](status.md) - see staged/unstaged/untracked changes
- [`gut whoops`](whoops.md) - jump back to a previous state via the reflog
- [`gut compare`](compare.md) - compare commits between branches
