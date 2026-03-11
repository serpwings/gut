---
title: gut alias
description: "Create, list, remove, and run personal shortcut commands stored in ~/.gutconfig."
---
# gut alias

Create, list, remove, and run personal shortcut commands stored in `~/.gutconfig`.

---

## Usage

```bash
gut alias <subcommand> [arguments]
```

### Subcommands

| Subcommand | Description |
|---|---|
| `list` | Show all defined aliases (default) |
| `add <name> <command>` | Create a new alias |
| `remove <name>` | Delete an alias |
| `run <name> [args]` | Execute an alias by name |

---

## Examples

```bash
# List current aliases
gut alias
gut alias list

# Add aliases for common commands
gut alias add lg "log --oneline --graph --decorate --all"
gut alias add st "status --short"

# Run an alias directly
gut alias run lg

# Remove an alias
gut alias remove lg
```

---

## How It Works

Aliases are saved as shell `alias` entries in `~/.gutconfig`. To use them in your regular shell sessions, source the file from your shell profile:

```bash
# In your ~/.zshrc or ~/.bashrc
source ~/.gutconfig
```

Then you can run them directly without the `gut alias run` prefix:

```bash
lg        # runs: git log --oneline --graph --decorate --all
```

!!! tip "Alias vs gut alias run"
    `gut alias run <name>` works any time without sourcing `~/.gutconfig`. Sourcing the file lets you use the short name directly in your shell.

---

## See Also

- [Configuration](../configuration.md) - environment variables for gut's behaviour
