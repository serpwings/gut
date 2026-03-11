---
title: gut whoops
description: "A reflog browser that lets you jump your branch back to any recent Git state - with an automatic safety stash to protect your current work."
---
# gut whoops

A reflog browser that lets you jump your branch back to any recent Git state - with an automatic safety stash to protect your current work.

---

## Usage

```bash
gut whoops
```

`gut whoops` shows the last 15 entries from `git reflog` (checkouts, commits, merges, resets) in a numbered list. You pick the number you want to return to, and gut does the rest safely.

---

## Example Session

```
=== Recent States (Reflog) ===

  1) HEAD@{0}  3 minutes ago  commit: fix login redirect
  2) HEAD@{1}  18 minutes ago  commit: add JWT validation
  3) HEAD@{2}  1 hour ago  checkout: moving from main to feature/auth
  4) HEAD@{3}  2 hours ago  merge: finished integrating hotfix
  ...

Jump to which state? (number, or Enter to cancel): 3
```

---

## Safety Features

Before jumping, gut:

1. **Auto-stashes dirty work** - if you have any uncommitted changes (staged or unstaged), gut runs `git stash push --include-untracked` with a `whoops-autosave: <timestamp>` label, so nothing is lost.
2. **Asks for confirmation** - you must confirm before `git reset --hard` runs.
3. **Tells you how to undo** - if you land in the wrong state, just run `gut whoops` again and jump back.

!!! warning "Hard reset"
    Jumping to a past state uses `git reset --hard`. Any commits made *after* the target state will no longer be on the branch (though they remain in the reflog for a while). The auto-stash saves your *uncommitted* work, but committed work after the target is effectively on a detached/orphaned chain until you use `gut whoops` again.

---

## See Also

- [`gut snapshot`](snapshot.md) - manually save a stash checkpoint before a risky operation
- [`gut stash`](stash.md) - view and manage all stash entries
- [`gut history`](history.md) - read-only view of the commit log
