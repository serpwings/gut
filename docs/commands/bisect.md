---
title: gut bisect
description: "Guided binary search to find the exact commit that introduced a bug. Automates the setup and walks you step by step through git bisect."
---
# gut bisect

Guided binary search to find the exact commit that introduced a bug. Automates the setup and walks you step by step through `git bisect`.

---

## Usage

```bash
gut bisect <subcommand>
```

### Subcommands

| Subcommand | Description |
|---|---|
| `start` | Start a guided bisect session (prompts for bad and good commits) |
| `good` | Mark the current commit as working (bug not present) |
| `bad` | Mark the current commit as broken (bug present) |
| `skip` | Skip the current commit (can't test it) |
| `abort` | Stop bisecting and return to your original HEAD |
| `log` | Show the bisect history for the current session |

---

## Walkthrough

### 1. Start bisect

```bash
gut bisect start
```

You'll be prompted to enter:
- **Bad commit** - a commit that *has* the bug (defaults to `HEAD`)
- **Good commit** - a commit that *didn't* have the bug (e.g. a tag like `v1.0.0`, a hash, or `HEAD~20`)

Git will check out a commit halfway between good and bad.

### 2. Test and mark

Test the currently checked-out commit (run your test suite, reproduce the bug, etc.). Then:

```bash
gut bisect good     # bug is NOT present in this commit
gut bisect bad      # bug IS present in this commit
```

Repeat until git announces the first bad commit.

### 3. Finish

Once found, gut offers to automatically run `git bisect reset` to return to your original branch.

---

## Example Session

```
=== Guided Bisect (Find a Bug) ===

Git bisect helps you find the exact commit that introduced a bug.
You'll mark commits as 'good' (no bug) or 'bad' (has bug).

Bad commit (has the bug) [default: HEAD]:
Good commit (no bug  tag, hash, or 'HEAD~N'): v1.0.0

Bisect started! Git has checked out a midpoint commit.

Now test if the bug exists in the current commit, then run:
  gut bisect good    if the bug is NOT present
  gut bisect bad     if the bug IS present
  gut bisect skip    skip this commit (e.g. can't test it)
  gut bisect abort   give up and return to HEAD
```

!!! tip "Automation"
    If you have a test command that returns exit code 0 for good and non-zero for bad, you can use `git bisect run <command>` directly for fully automatic bisect.

---

## See Also

- [`gut rescue`](rescue.md) - diagnose other common Git problems
- [`gut history`](history.md) - view the commit log to find your good commit reference
