---
title: gut tag
description: "A streamlined way to create, list, push, and delete tags."
---
# gut tag

A streamlined way to create, list, push, and delete tags.

---

## Usage

```bash
gut tag <subcommand> [arguments]
```

### Subcommands

| Subcommand | Description |
|---|---|
| `list` | Show all tags alphabetically. (Default) |
| `latest` | Show the most recently created tag name. |
| `create <name> [-m "Message"]` | Create a new tag (optionally annotated). |
| `delete <name>` | Delete a tag locally and trigger remote deletion. |
| `push <name>` | Push a specific tag to the remote. |
| `<name>` | Shorthand to create a lightweight tag `<name>`. |

### Examples

```bash
# Sames as gut tag list
gut tag

# Create a tag "v1.2.0" quickly
gut tag v1.2.0

# Create an annotated tag
gut tag create v1.2.1 -m "Hotfix release"

# Push the tag to your upstream remote
gut tag push v1.2.1
```
