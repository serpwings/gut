---
title: gut integrate
description: "Merge or rebase another branch into your current one, with guided prompts explaining the trade-offs."
---
# gut integrate

Merge or rebase another branch into your current one, with guided prompts explaining the trade-offs.

---

## Usage

```bash
gut integrate <branch>
```

---

## Examples

```bash
# Integrate a feature branch into your current branch
gut integrate feature/auth

# Integrate main into your feature branch (to catch up)
gut integrate main
```

---

## Interactive Menu

When you run `gut integrate`, you are asked to choose a strategy:

```
What would you like to do?
  1) Merge   Brings in changes with a merge commit (safe, preserves history)
  2) Rebase  Replays your commits on top of 'feature/auth' (cleaner, rewrites history)
  3) Cancel
```

### Option 1: Merge

Uses `git merge --no-ff`  always creates a merge commit even if a fast-forward would be possible. This preserves the full history of when the branch existed and when it was integrated.

**Best for:** Feature branches being merged into `main`/`develop`, or any situation where you want a clear record of the integration point.

### Option 2: Rebase

Uses `git rebase` to replay your current branch's commits on top of the target branch. This gives a linear history but **rewrites** your commits (new hashes).

**Best for:** Syncing your feature branch with the latest `main` before opening a PR, when you're the sole author of the branch.

!!! warning "Don't rebase shared branches"
    If others have based work on your branch, rebasing rewrites the history they've already pulled. Use **merge** instead.

---

## Conflict Resolution

If either strategy hits a conflict, gut prints the conflicting files and tells you exactly what to do:

=== "Merge conflict"
    ```
     Merge conflict detected!

    Files with conflicts:
      src/auth.js

    1. Edit the conflicting files.
    2. Run gut save to mark them resolved and commit.
       Or run gut git merge --abort to cancel the merge.
    ```

=== "Rebase conflict"
    ```
     Rebase conflict detected!

    Resolve conflicts, then run:
      gut git rebase --continue  to proceed
      gut git rebase --abort     to cancel
    ```

---

## See Also

- [`gut sync --reconcile`](sync.md)  reconcile diverged remote branches
- [`gut replay`](replay.md)  interactively edit commits after integrating
- [`gut rescue conflicts`](rescue.md#conflicts)  walk through conflict resolution step by step
