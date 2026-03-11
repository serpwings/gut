---
title: gut rescue
description: "Diagnoses and fixes the most common Git problems through an interactive menu."
---
# gut rescue

Diagnoses and fixes the most common Git problems through an interactive menu.

---

## Usage

```bash
gut rescue [subcommand]
```

Running `gut rescue` with no subcommand performs a **full health check**.

## Subcommands

| Subcommand | Description |
|---|---|
| *(none)* | Full repository health check |
| `detached` | Fix detached HEAD state interactively |
| `conflicts` | Walk through unresolved merge conflicts |
| `lost` | Browse the reflog to find lost commits |
| `rebase` | Abort, skip, or continue a stuck rebase |
| `stash` | Apply, pop, or inspect saved stashes |
| `init` | Initialize a new repository (safe if already a repo) |

---

## Health Check

```bash
gut rescue
```

Runs a series of checks and reports:

- Current branch
- Detached HEAD status
- Uncommitted changes
- Unresolved merge conflicts
- In-progress rebase
- Remote `origin` configuration

---

## Subcommand Details {#subcommands}

### detached

```bash
gut rescue detached
```

Triggered when `HEAD` points to a commit rather than a branch. Offers:

1. **Create a new branch here**  saves your work to a named branch
2. **Switch to an existing branch**  abandons the detached state (unstaged changes may be lost)

### conflicts {#conflicts}

```bash
gut rescue conflicts
```

Lists all files with unresolved merge conflict markers and walks you through resolving them:

1. Open each file and look for `<<<<<<<`, `=======`, `>>>>>>>` markers.
2. Edit the file, keeping the changes you want.
3. Run `gut save <file>` to mark the file as resolved.
4. Run `gut save` to complete the merge.

Or, to abort: `gut git merge --abort`

### lost

```bash
gut rescue lost
```

Shows the 20 most recent reflog entries with timestamps, so you can find commits that appear "gone" after a reset or accidental branch deletion. Explains how to recover via `gut branch new` + cherry-pick.

### rebase

```bash
gut rescue rebase
```

If a rebase is in progress, offers:

1. **Abort**  returns the repository to the state before the rebase started
2. **Skip**  skips the current commit and continues
3. **Continue**  resumes after you've resolved conflicts

### stash {#stash}

```bash
gut rescue stash
```

Lists all saved stashes and offers:

1. **Apply** most recent stash (keeps it in the list)
2. **Pop** most recent stash (removes it from the list)
3. **Show** stash contents

### init

```bash
gut rescue init
```

Initialises a new Git repository in the current directory. Safe to run if you're already in a repo  it will warn you.

---

## See Also

- [`gut whoops`](whoops.md)  jump to a past state via reflog
- [`gut stash`](stash.md)  manage stashed work
- [`gut integrate`](integrate.md)  merge branches with conflict guidance
