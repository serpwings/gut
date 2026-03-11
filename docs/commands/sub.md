---
title: gut sub
description: "Clean, consistent submodule management  list, add, update, sync, and remove."
---
# gut sub

Clean, consistent submodule management  list, add, update, sync, and remove.

---

## Usage

```bash
gut sub <subcommand> [arguments]
```

## Subcommands

| Subcommand | Description |
|---|---|
| `list` | List all submodules with status indicators |
| `add <url> [path]` | Add a new submodule |
| `update` | Initialise and update all submodules recursively |
| `sync` | Sync submodule URLs from `.gitmodules` |
| `remove <path>` | Cleanly remove a submodule (with confirmation) |

---

## Examples

```bash
# List all submodules and their status
gut sub list

# Add a submodule
gut sub add https://github.com/example/lib.git

# Add with a custom path
gut sub add https://github.com/example/lib.git vendor/lib

# Update all submodules
gut sub update

# Sync URLs after editing .gitmodules
gut sub sync

# Remove a submodule
gut sub remove vendor/lib
```

---

## Status Indicators

`gut sub list` shows each submodule with a status label:

| Label | Meaning |
|---|---|
| `[OK]` | Submodule is at the expected commit |
| `[DRIFT]` | Currently checked out commit differs from the recorded one |
| `[INIT]` | Submodule exists in config but hasn't been initialised |
| `[CONF]` | Submodule has a merge conflict |

---

## After Adding or Removing

Submodule changes (adding, removing) modify `.gitmodules` and the Git index. Always commit the result:

```bash
gut sub add https://github.com/example/lib.git
gut save .gitmodules -m "chore: add lib submodule"
```

---

## See Also

- [`gut big`](big.md)  manage large files with Git LFS
