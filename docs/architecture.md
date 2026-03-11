---
title: Architecture
description: "gut is designed to be simple, auditable, and dependency-free. The entire codebase is pure Bash."
---
# Architecture

gut is designed to be simple, auditable, and dependency-free. The entire codebase is pure Bash.

---

## Directory Structure

```
gut/
 bin/
    gut              # Entry point + command dispatcher
    gut.cmd          # Windows CMD wrapper
 completion/
    _gut             # Zsh completion script
    gut-completion.bash  # Bash completion script
 lib/
    colors.sh        # ANSI colour codes
    utils.sh         # Logging, confirmations, error translation
    init.sh          # gut init
    status.sh        # gut status, gut history
    save.sh          # gut save
    undo.sh          # gut undo
    sync.sh          # gut sync
    branch.sh        # gut branch, gut switch
    integrate.sh     # gut integrate
    replay.sh        # gut replay
    stash.sh         # gut stash
    snapshot.sh      # gut snapshot
    whoops.sh        # gut whoops
    rescue.sh        # gut rescue
    bisect.sh        # gut bisect
    sub.sh           # gut sub
    big.sh           # gut big
    tag.sh           # gut tag
    protect.sh       # gut protect
    alias.sh         # gut alias
    compare.sh       # gut compare
    blame.sh         # gut blame
    stats.sh         # gut stats
    age.sh           # gut age
    pr.sh            # gut pr
    patch.sh         # gut patch
    utils.sh         # Shared utilities
 install.sh           # Installer script
```

---

## Dispatch Mechanism

`bin/gut` is the sole entry point. It:

1. Resolves `GUT_HOME` from its own location (`dirname` of the script).
2. Sources `lib/utils.sh` (which in turn sources `lib/colors.sh`).
3. Maps the first CLI argument to a library file via `gut_cmd_to_lib`.
4. Sets `cmd_context` to the command name and **sources** the library file  rather than forking a subprocess  so the library has access to the full environment.

```bash
cmd_context="${cmd}" source "${LIB_DIR}/${lib_file}" "$@"
```

Sourcing (rather than executing) keeps the shell environment shared, which is important for commands like `branch.sh` that handle two different top-level commands (`branch` and `switch`) and use `cmd_context` to differentiate.

---

## Shared Utilities (`lib/utils.sh`)

All library files source `utils.sh` first. It provides:

| Function | Purpose |
|---|---|
| `gut_log` | Blue informational message |
| `gut_success` | Green success message |
| `gut_warn` | Yellow warning message |
| `gut_error` | Red error message (to stderr) |
| `gut_confirm` | Interactive yes/no prompt (defaults to `n` for safety) |
| `gut_is_repo` | Returns 0 if inside a Git work tree |
| `gut_translate_error` | Translates cryptic Git error strings to plain English |
| `gut_header` | Prints a decorated section header |

---

## Colour System (`lib/colors.sh`)

`colors.sh` defines ANSI escape code variables (`CLR_RED`, `CLR_GREEN`, etc.).

When `GUT_NO_COLOR=1` is set, all these values are blanked out - so every library file gets plain output for free simply by using these variables rather than hardcoded sequences.

---

## Repo Check

Before sourcing any library (except `rescue` and `init`), `bin/gut` calls `gut_is_repo`. If the current directory is not inside a Git work tree, it prints a friendly error and exits  preventing confusing raw Git errors from reaching the user.

---

## Installer (`install.sh`)

The installer:

1. Copies all `lib/*.sh` files to `$GUT_INSTALL_DIR/lib/gut/`.
2. Copies completion scripts to `$GUT_INSTALL_DIR/share/gut/completion/`.
3. Patches `bin/gut`'s `LIB_DIR` assignment to point at the installed lib path, then writes the result to `$GUT_INSTALL_DIR/bin/gut`.
4. Makes all installed scripts executable.

This patching step is what allows `gut` to be invoked from any directory  it knows exactly where its library lives at install time.
