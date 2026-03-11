---
title: gut big
description: "Scan your working tree and Git history for large files, and manage them with Git Large File Storage (LFS)."
---
# gut big

Scan your working tree and Git history for large files, and manage them with Git Large File Storage (LFS).

---

## Usage

```bash
gut big <subcommand> [arguments]
```

### Subcommands

| Subcommand | Description |
|---|---|
| `scan` | List all files in the working tree and history exceeding the size threshold |
| `track <pattern>` | Add a file or glob pattern to Git LFS tracking |
| `setup` | Enable Git LFS for the current repository (`git lfs install`) |
| `status` | Show which files are currently tracked by LFS |

---

## Examples

```bash
# Scan for large files (default threshold: 1 MB)
gut big scan

# Track all PSD files with LFS
gut big track '*.psd'

# Then commit the new .gitattributes rule
gut save .gitattributes -m "track PSD files with LFS"

# Enable LFS for the first time
gut big setup

# Check LFS tracking status
gut big status
```

---

## Threshold

The minimum file size that `gut big scan` flags is controlled by the `GUT_BIG_THRESHOLD_KB` environment variable (default: `1024` KB = 1 MB).

```bash
# Flag files over 500 KB instead
export GUT_BIG_THRESHOLD_KB=500
gut big scan
```

See [Configuration](../configuration.md) for making this persistent.

---

## What Scan Shows

| Section | Description |
|---|---|
| **Working Tree** | Large files present in your current directory |
| **Git History** | Large blob objects recorded anywhere in the repo's history |

!!! warning "History blobs can't be removed with a simple commit"
    If `gut big scan` finds large blobs in your *history*, removing them requires rewriting history with `git filter-repo` or `BFG Repo Cleaner`. Adding the file to LFS now only prevents *future* commits from storing it as a regular blob.

---

## See Also

- [Configuration](../configuration.md) - set `GUT_BIG_THRESHOLD_KB`
- [`gut save`](save.md) - commit the `.gitattributes` changes after tracking
