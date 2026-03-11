---
title: gut snapshot
description: "Instantly save your current work-in-progress - including untracked files - as a timestamped stash entry, without making a formal commit."
---
# gut snapshot

Instantly save your current work-in-progress - including untracked files - as a timestamped stash entry, without making a formal commit.

---

## Usage

```bash
gut snapshot
```

When run, `gut snapshot`:

1. Checks if the working tree has any changes (tracked or untracked).
2. If changes exist, runs `git stash push --include-untracked` with an automatic timestamp label.
3. Tells you the exact command to restore the snapshot.

If the working tree is already clean, it warns you and does nothing.

---

## Example Output

```
[INFO] Creating a timestamped stash snapshot...
[OK] Snapshot saved: 'snapshot: 2024-03-11 10:30:00'
Restore it anytime with: gut stash pop
List all snapshots:      gut stash list
```

---

## Restoring a Snapshot

```bash
# Restore the most recent snapshot
gut stash pop

# Browse all snapshots
gut stash list

# Apply without removing from the stash
gut stash apply
```

---

## Difference from `gut stash`

| | `gut snapshot` | `gut stash save` |
|---|---|---|
| **Label** | Auto-generated timestamp | Optional custom message |
| **Untracked files** | Always included | Always included |
| **Intended use** | Quick "save state" button | Named, intentional stash |

---

## See Also

- [`gut stash`](stash.md) - manage named stash entries
- [`gut whoops`](whoops.md) - time machine for Git reflog states
- [`gut undo`](undo.md) - undo the last commit
