---
title: gut undo
description: "Replaces git reset, git revert, and git restore with a single, safe, interactive command."
---
# gut undo

Replaces `git reset`, `git revert`, and `git restore` with a single, safe, interactive command.

---

## Usage

```bash
gut undo [options] [file...]
```

## Options

| Option | Description |
|---|---|
| `--hard` | Discard changes entirely (requires confirmation) |
| `-n N` | Undo the last N commits (default: 1) |
| `[file...]` | Operate on specific files instead of commits |

---

## Examples

```bash
# Soft-undo the last commit (keeps changes staged)
gut undo

# Soft-undo the last 3 commits
gut undo -n 3

# DISCARD the last commit and all local changes (destructive)
gut undo --hard

# Unstage a specific file (keeps working-tree changes)
gut undo src/app.js

# Discard all working-tree changes to a file (destructive)
gut undo --hard src/app.js
```

---

## Behaviour by Mode

### File mode (`gut undo [file...]`)

| Variant | Effect |
|---|---|
| `gut undo <file>` | Unstages the file (moves from staged  unstaged) |
| `gut undo --hard <file>` | Discards all working-tree changes to the file (requires confirmation) |

### Commit mode (no files specified)

| Variant | Effect |
|---|---|
| `gut undo` | Soft reset  undoes the last commit, keeps changes staged |
| `gut undo -n 3` | Soft reset  undoes the last 3 commits, keeps changes staged |
| `gut undo --hard` | Hard reset  discards the last commit AND all local changes (requires confirmation) |

!!! danger "Hard undo is irreversible"
    `gut undo --hard` permanently discards uncommitted changes. gut will always ask for confirmation before proceeding. If you're unsure, use `gut snapshot` first to save your work.

---

## Root Commit Handling

If you try to undo past the very first commit in a repository, gut handles this gracefully:

- **Soft**: Removes the root commit using `git update-ref -d HEAD`, leaving your files intact.
- **Hard**: Removes the root commit and cleans the working tree entirely.

---

## See Also

- [`gut save`](save.md)  make a commit (the opposite operation)
- [`gut snapshot`](snapshot.md)  save a stash before risky operations
- [`gut whoops`](whoops.md)  jump to any past state via reflog
- [`gut rescue`](rescue.md)  recover from more complex situations
