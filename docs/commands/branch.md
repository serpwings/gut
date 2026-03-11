---
title: gut branch & gut switch
description: "Branch creation, listing, deletion, and renaming. gut switch changes your active branch."
---
# gut branch & gut switch

Branch creation, listing, deletion, and renaming. `gut switch` changes your active branch.

---

## gut branch

```bash
gut branch <subcommand> [arguments]
```

### Subcommands

| Subcommand | Description |
|---|---|
| `list` | List all local branches (default if no subcommand given) |
| `new <name>` | Create a new branch and switch to it |
| `delete <name>` | Delete a branch (with confirmation) |
| `rename <old> <new>` | Rename a branch |
| `rename <new>` | Rename the current branch |

### Examples

```bash
# List all branches
gut branch list
gut branch          # same thing

# Create and switch to a new branch
gut branch new feature/user-auth

# Delete a branch (confirms first)
gut branch delete old-experiment

# Rename a branch
gut branch rename old-name new-name

# Rename the current branch
gut branch rename better-name
```

---

## gut switch

```bash
gut switch <branch>
```

Switch to an existing branch.

### Examples

```bash
gut switch main
gut switch feature/user-auth
```

!!! tip "Creating vs switching"
    `gut switch` is for changing to an **existing** branch. To create a **new** branch and switch to it in one step, use `gut branch new <name>`.

---

## Branch Delete Behaviour

`gut branch delete` first attempts a **safe delete** (`git branch -d`), which only succeeds if the branch has been fully merged. If the branch has unmerged commits, gut warns you and offers a force delete:

```
  Could not delete branch normally (it may have unsaved work).
Proceed with FORCE delete? This will LOSE changes. [y/N]
```

!!! danger "Force delete loses unmerged commits"
    If you force-delete a branch that hasn't been merged, any commits unique to that branch will be lost. Use `gut compare` first to check what's on the branch.

---

## See Also

- [`gut switch`](#gut-switch)  change branches
- [`gut sync --publish`](sync.md)  push a new branch to the remote
- [`gut compare`](compare.md)  see what's different between branches
- [`gut integrate`](integrate.md)  merge one branch into another
- [`gut age`](age.md)  see branch ages and ahead/behind status
