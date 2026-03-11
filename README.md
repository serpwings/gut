# gut



**Git with better UX.** A pure Bash wrapper around Git - friendlier commands, plain-English errors, and safety guardrails.  
No dependencies beyond `bash` and `git`.

---

## Why gut?

Git is powerful, but its UX has real problems:

| Problem | How gut helps |
|---|---|
| `git checkout` does 5 different things | One concept, one command |
| Cryptic errors like "non-fast-forward" | Plain-English translations + fixes |
| Staging area confusion (3-way split) | `gut status` visualizes all three areas |
| reset vs revert vs restore | `gut undo` replaces all three, interactively |
| Interactive rebase is daunting | `gut replay` guides you through squash/reword/drop |
| Submodule commands are inconsistent | `gut sub` clean list/add/update/sync/remove |
| Large files silently bloat history | `gut big` scans tree + history, integrates LFS |
| Recovery is "Google every error" | `gut rescue` diagnoses and fixes interactively |

---

## Installation

### Unix/Linux/macOS

```bash
git clone https://github.com/serpwings/gut.git
cd gut
chmod +x install.sh
./install.sh
```

By default, installs to `/usr/local`. To install elsewhere:

```bash
GUT_INSTALL_DIR=~/.local ./install.sh
```

### Windows

Git for Windows already includes the required `bash.exe`.

1. Clone or download `gut` anywhere on your machine.
2. Add the `gut\bin` directory to your Windows `PATH` environment variable.
3. You can now securely use `gut` from the **Command Prompt**, **PowerShell**, or **Git Bash**.


### Requirements

- Bash 4.0+ (also perfectly supports macOS Bash 3.2!)
- Git
- Git LFS *(optional, for `gut big` commands)*

---

## Auto-completion

`gut` comes with full auto-completion support for both **Zsh** and **Bash**. After installing, add the following to your shell profile to enable <kbd>Tab</kbd> completion for commands, branch names, and submodules.

**For Zsh** (add to `~/.zshrc`):
```zsh
fpath=("/usr/local/share/gut/completion" $fpath)
autoload -Uz compinit && compinit
```
*(If you used a custom `GUT_INSTALL_DIR`, replace `/usr/local` with your path).*

**For Bash** (add to `~/.bashrc` or `~/.bash_profile`):
```bash
source "/usr/local/share/gut/completion/gut-completion.bash"
```

Finally, reload your shell configuration for the changes to take effect:
```bash
source ~/.zshrc # or source ~/.bashrc
```

---

## Environment Variables

| Variable | Effect |
|---|---|
| `GUT_NO_COLOR=1` | Disable ANSI colors |
| `GUT_INSTALL_DIR` | Install directory (default: `/usr/local`) |
| `GUT_BIG_THRESHOLD_KB` | Min size in KB to flag as large (default: 1024) |

---

## Command Reference

### `gut init`

Initialize a new empty Git repository in the current directory.

```bash
gut init
```

---

### `gut status`

Visual, labeled breakdown of the three Git areas:

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

### `gut save [-m "message"] [--all] [file...]  [--amend]`

Combines `git add` + `git commit` in one step.

```bash
gut save                       # commit staged files (prompts for message)
gut save -m "fix login bug"    # commit staged files with a message
gut save --all -m "wip"        # stage everything and commit
gut save src/app.js -m "fix"   # stage and commit specific file(s)
gut save --amend -m "new msg"  # rewrite the last commit message
```

---

### `gut undo [--hard] [-n N] [file]`

Replaces `git reset`, `git revert`, `git restore`.

```bash
gut undo                  # soft-undo last commit (keeps work staged)
gut undo -n 3             # soft-undo last 3 commits
gut undo --hard           # DISCARD last commit and all local changes (with confirmation)
gut undo src/app.js       # unstage a specific file
gut undo --hard app.js    # discard all changes to a file (with confirmation)
```

---

### `gut sync [--publish] [--force] [--reconcile]`

Coordinated pull/push that handles diverged branches gracefully.

```bash
gut sync               # auto pull-or-push based on remote state
gut sync --publish     # push a new branch for the first time
gut sync --reconcile   # interactive merge or rebase when branches diverge
gut sync --force       # force push (uses --force-with-lease, with confirmation)
```

---

### `gut branch <subcommand>`

```bash
gut branch list          # list local branches
gut branch new <name>    # create and switch to a new branch
gut branch delete <name> # delete a branch (with confirmation)
gut branch rename <old> <new>
```

### `gut switch <branch>`

```bash
gut switch main          # switch to a branch
```

---

### `gut integrate <from-branch>`

Merge or rebase another branch into your current one, with guidance.

```bash
gut integrate feature/auth
```

Prompts you to choose between **merge** (safe) and **rebase** (clean), explains trade-offs.

---

### `gut replay [N]`

Friendly interactive rebase  no raw editor required.

```bash
gut replay        # shows last 10 commits, lets you pick how many to edit
gut replay 3      # edit last 3 commits
```

Actions available:
1. **Squash**  combine N commits into one (prompts for new message)
2. **Reword**  edit commit messages
3. **Drop**  permanently delete commits (with confirmation)
4. **Reorder**  open full interactive editor

---

### `gut sub <subcommand>`

Clean submodule management:

```bash
gut sub list                    # list all submodules with status
gut sub add <url> [path]        # add a submodule
gut sub update                  # initialize and update all submodules recursively
gut sub sync                    # sync URLs from .gitmodules
gut sub remove <path>           # cleanly remove a submodule (with confirmation)
```

Status indicators:
- `[OK]`  in sync
- `[DRIFT]`  current commit differs from recorded
- `[INIT]`  not yet initialized
- `[CONF]`  merge conflict

---

### `gut big <subcommand>`

Large file scanning and Git LFS integration:

```bash
gut big scan             # find large files in working tree and git history
gut big setup            # install Git LFS for this repo
gut big track '*.psd'   # track a file type with LFS
gut big status           # show LFS status
```

Set `GUT_BIG_THRESHOLD_KB` to control the size threshold (default: 1024 KB).

---

### `gut rescue [subcommand]`

Diagnoses and fixes common Git problems:

```bash
gut rescue               # run a full health check
gut rescue detached      # fix detached HEAD interactively
gut rescue conflicts     # walk through conflict resolution
gut rescue lost          # browse reflog to find lost commits
gut rescue rebase        # abort, skip, or continue a stuck rebase
gut rescue stash         # apply, pop, or inspect stashed work
gut rescue init          # initialize a new repository
```

---

### `gut history [N]`

Clean, readable commit log (default: 10 commits):

```bash
gut history
gut history 25
```

---

## Escape Hatches (`gut log`, `gut git`)

If a command isn't covered by `gut`, you can pass it directly to `git`. For convenience, `gut log` passes directly to `git log`.

```bash
gut log --oneline
gut log -p src/
gut git bisect start
gut git reflog --date=relative
```

---

## Architecture

```
gut/
 bin/
    gut              # entry point + dispatcher
    gut.cmd          # Windows wrapper
 completion/          # auto-completion scripts
    gut-completion.bash
    _gut
 lib/
    colors.sh        # ANSI colors, emoji presets
    init.sh          # gut init
    utils.sh         # logging, confirmations, error translation
    status.sh        # gut status, gut history
    save.sh          # gut save
    undo.sh          # gut undo
    sync.sh          # gut sync
    branch.sh        # gut branch, gut switch
    integrate.sh     # gut integrate
    replay.sh        # gut replay
    sub.sh           # gut sub
    big.sh           # gut big
    rescue.sh        # gut rescue
 install.sh
```

---

## Design Rules

- **One concept = one command.** No flag overloading.
- **Always explain** what's happening and why.
- **Interactive prompts** when intent is unclear  never guess destructively.
- **Warn with confirmation** before any destructive operation.
- **Plain-English errors** translate cryptic git output into actionable guidance.

---

## Contributing

Contributions are wide open and highly encouraged! Whether it's a bug report, a documentation typo, or a new feature, users are welcome to contribute. 

Feel free to:
- **Open an Issue** if you find a bug or have a suggestion.
- **Submit a Pull Request** to improve the codebase or documentation.

---

## License

[MIT License](LICENSE) - Copyright (c) 2024-2026 Faisal Shahzad <info@serpwings.com>
