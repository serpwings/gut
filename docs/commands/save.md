---
title: gut save
description: "Combines git add and git commit into one step. Optionally prompts for a commit message if none is provided."
---
# gut save

Combines `git add` and `git commit` into one step. Optionally prompts for a commit message if none is provided.

---

## Usage

```bash
gut save [options] [file...]
```

## Options

| Option | Description |
|---|---|
| `-m "message"` | Commit message (prompts interactively if omitted) |
| `--all`, `-a` | Stage all changes before committing (like `git add -A`) |
| `--amend` | Rewrite the last commit (message or staged content) |
| `[file...]` | Stage and commit specific files only |

---

## Examples

```bash
# Commit already-staged files (prompts for message)
gut save

# Commit with a message
gut save -m "fix login redirect"

# Stage everything and commit
gut save --all -m "wip: refactor auth module"

# Stage and commit specific files
gut save src/login.js tests/login.spec.js -m "fix: null check"

# Amend the last commit with a new message
gut save --amend -m "fix: correct error message wording"

# Amend the last commit, opening the editor
gut save --amend
```

---

## Behaviour

1. **Staging**: If `--all` is given, runs `git add -A`. If specific files are provided, runs `git add <files>`. Otherwise, nothing is staged  only already-staged changes are committed.
2. **Message**: If `-m` is not provided and there are staged changes, you are prompted to type a message interactively. An empty message is rejected.
3. **Amend**: If `--amend` is set and there are staged changes, they are squashed into the last commit. If nothing is staged, it opens the editor to reword the last commit message.

!!! warning "Amend rewrites history"
    `--amend` rewrites the last commit. If you've already pushed it, you'll need `gut sync --force` to update the remote. Don't amend commits that others may have based work on.

---

## See Also

- [`gut status`](status.md)  check what's staged before saving
- [`gut undo`](undo.md)  un-save (undo) the last commit
- [`gut sync`](sync.md)  push saved commits to the remote
