---
title: gut patch
description: "Export commits as .patch files to transfer between machines (or email to a collaborator) - and apply patch files received from others."
---
# gut patch

Export commits as `.patch` files to transfer between machines (or email to a collaborator) - and apply patch files received from others.

---

## Usage

```bash
gut patch <subcommand> [arguments]
```

### Subcommands

| Subcommand | Description |
|---|---|
| `create [N] [dir]` | Export the last `N` commits as `.patch` files (default: `N=1`, current directory) |
| `apply <file.patch>` | Apply a `.patch` file as a new commit |

---

## Examples

```bash
# Export the last commit as a .patch file
gut patch create

# Export the last 3 commits
gut patch create 3

# Export to a specific directory
gut patch create 2 ~/patches/

# Apply a patch file
gut patch apply 0001-fix-login-redirect.patch
```

---

## How It Works

### Creating Patches

`gut patch create` uses `git format-patch`, which produces one `.patch` file per commit. Each file contains the full diff plus the commit message, author, and date - everything needed to replay the commit on any Git repository.

### Applying Patches

`gut patch apply` uses `git am` (apply mailbox). The patch is applied as a **new commit** preserving the original author and message. If the patch does not apply cleanly (conflicts), gut will tell you to run `gut git am --abort` to cancel.

!!! tip "Patches vs `git diff`"
    `git format-patch` produces richer output than `git diff` - it includes the commit message and metadata so the receiver can apply the patch as a proper commit with author attribution intact.

---

## See Also

- [`gut save`](save.md) - create commits before exporting them as patches
- [`gut sync`](sync.md) - push commits to a shared remote (when you have one)
