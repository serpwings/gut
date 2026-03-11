---
title: gut protect
description: "Prevent accidental direct pushes to important branches (e.g. main, production) by installing a local Git pre-push hook."
---
# gut protect

Prevent accidental direct pushes to important branches (e.g. `main`, `production`) by installing a local Git pre-push hook.

---

## Usage

```bash
gut protect <subcommand> [branch]
```

### Subcommands

| Subcommand | Description |
|---|---|
| `status` | Show current protection status (default if no subcommand given) |
| `add <branch>` | Protect a branch from direct pushes |
| `remove <branch>` | Remove protection for a branch |

---

## Examples

```bash
# Check what's currently protected
gut protect status

# Protect main
gut protect add main

# Protect multiple branches (run for each)
gut protect add main
gut protect add production

# Remove protection
gut protect remove main
```

---

## How It Works

`gut protect add` writes a `.git/hooks/pre-push` hook script. Whenever you attempt to push, the hook checks if the target branch is in the protected list and blocks the push with a clear message:

```
 gut-protect: Direct push to 'main' is blocked.
  Create a branch and open a PR/MR instead:
  gut branch new my-feature
  gut sync --publish
```

!!! note "Local only"
    The hook lives in `.git/hooks/` and is **not committed** to the repository. Every team member who clones the repo will need to run `gut protect add <branch>` themselves.

!!! warning "Hook is per-repository"
    Protection must be configured separately in each repository where you want it.

---

## See Also

- [`gut branch new`](branch.md) - create a feature branch instead of pushing directly
- [`gut sync --publish`](sync.md) - push the new branch for the first time
- [`gut pr`](pr.md) - open a pull request
