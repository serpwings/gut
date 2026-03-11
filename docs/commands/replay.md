---
title: gut replay
description: "Friendly interactive rebase  no raw editor required. Lets you squash, reword, drop, or reorder recent commits through a simple numbered menu."
---
# gut replay

Friendly interactive rebase  no raw editor required. Lets you squash, reword, drop, or reorder recent commits through a simple numbered menu.

---

## Usage

```bash
gut replay [N]
```

| Argument | Description |
|---|---|
| `N` | Number of recent commits to operate on (prompted if omitted) |

---

## Examples

```bash
# Interactive  shows last 10 commits and asks how many to edit
gut replay

# Edit the last 3 commits
gut replay 3
```

---

## Menu Options

After selecting how many commits to edit, you see the list and are offered:

```
What would you like to do?
  1) Squash   Combine all 3 commits into one
  2) Reword   Edit commit messages
  3) Drop     Delete specific commits
  4) Reorder  Full interactive editor
  5) Cancel
```

### 1. Squash

Combines all N commits into a single new commit. You are prompted for the new message.

```bash
gut replay 3
#  choose 1
#  type "feat: complete user auth module"
```

Internally uses `git reset --soft HEAD~N` followed by `git commit -m`, avoiding the interactive editor entirely.

### 2. Reword

- **N = 1**: Prompts for a new message and runs `git commit --amend -m`.
- **N > 1**: Offers to open the interactive rebase editor with all commits set to `reword` mode.

### 3. Drop

Displays the commit list with numbers. Enter the commit numbers you want to permanently delete (space-separated). Requires confirmation before proceeding.

### 4. Reorder

Opens the full `git rebase -i` editor where you can freely rearrange, squash, fixup, edit, or drop commits.

### 5. Cancel

Exits without making any changes.

---

## Important Notes

!!! warning "Replay rewrites history"
    `gut replay` rewrites commits. If you've already pushed the commits being edited, you'll need `gut sync --force` to update the remote.
    
    Never replay commits that others have based work on.

!!! tip "Rule of thumb"
    Use `gut replay` to clean up your work **before** opening a pull request  squashing "wip" commits, fixing typo'd messages, or dropping debug commits.

---

## See Also

- [`gut save --amend`](save.md)  reword only the very last commit (simpler)
- [`gut integrate`](integrate.md)  merge a branch rather than rebasing
- [`gut sync --force`](sync.md)  force-push after replaying
