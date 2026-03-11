---
title: gut status
description: "Visual, labelled breakdown of all three Git areas  staged changes, unstaged modifications, and untracked files."
---
# gut status

Visual, labelled breakdown of all three Git areas  staged changes, unstaged modifications, and untracked files.

---

## Usage

```bash
gut status
```

---

## Example Output

```
=== Repository Status ===
 Branch: main

  Staged (Ready to save):
  [NEW]    src/feature.js
  [MOD]    README.md

 Unstaged (Modified but not staged):
  [MOD]    src/index.js

  Untracked (New files not yet managed):
  [NEW]    notes.txt
```

---

## Sections Explained

| Section | Git equivalent | What it shows |
|---|---|---|
| **Staged** | Index / pre-commit area | Files that will be included in the next `gut save` |
| **Unstaged** | Working tree | Files that have been changed but not yet staged |
| **Untracked** | Not tracked by Git | New files that Git doesn't know about yet |

Each file is labelled `[NEW]`, `[MOD]`, or `[DEL]` and colour-coded for instant readability.

---

## File Status Labels

| Label | Meaning |
|---|---|
| `[NEW]` | File added (new to Git / staged as new) |
| `[MOD]` | File modified |
| `[DEL]` | File deleted |

---

## Detached HEAD Warning

If you are in a detached HEAD state (e.g., after `git checkout <hash>`), `gut status` will display a prominent warning and suggest how to fix it.

---

## See Also

- [`gut save`](save.md)  stage and commit changes
- [`gut history`](history.md)  view recent commit log
- [`gut rescue`](rescue.md)  diagnose repository problems
