---
title: gut stash
description: "Save your work-in-progress temporarily, switch context, and restore your changes later."
---
# gut stash

Save your work-in-progress temporarily, switch context, and restore your changes later.

---

## Usage

```bash
gut stash <subcommand> [arguments]
```

## Subcommands

| Subcommand | Description |
|---|---|
| `save [message]` | Stash current changes (prompts for description if omitted) |
| `pop` | Restore the most recent stash and remove it from the list |
| `apply [N]` | Apply stash N (default: 0) without removing it from the list |
| `list` | Show all saved stashes |
| `show [N]` | Show the diff contents of stash N (default: 0) |
| `drop [N]` | Delete stash N permanently (default: 0, requires confirmation) |
| `clear` | Delete all stashes permanently (requires confirmation) |

---

## Examples

```bash
# Stash everything (prompts for an optional description)
gut stash save

# Stash with a description
gut stash save "half-done navbar refactor"

# Restore and remove most recent stash
gut stash pop

# List all stashes
gut stash list

# Inspect stash contents before applying
gut stash show 0

# Apply stash 1 (keeps it in the list)
gut stash apply 1

# Delete a specific stash
gut stash drop 2

# Delete all stashes
gut stash clear
```

---

## Typical Workflow

```bash
# You're working on a feature and need to switch to fix a hotfix
gut stash save "in-progress: feature/dark-mode"

gut switch main
gut branch new hotfix/critical-bug
# ... fix bug ...
gut save -m "fix: critical null pointer in auth"
gut sync

# Return to your feature
gut switch feature/dark-mode
gut stash pop
```

---

## See Also

- [`gut snapshot`](snapshot.md)  a simpler, timestamped quicksave
- [`gut rescue stash`](rescue.md#stash)  recover stashes interactively via rescue menu
