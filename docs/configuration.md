---
title: Configuration
description: "gut is configured entirely through environment variables. There are no config files  just export variables in your shell profile."
---
# Configuration

gut is configured entirely through environment variables. There are no config files  just export variables in your shell profile.

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `GUT_NO_COLOR` | `0` | Set to `1` to disable all ANSI colour output |
| `GUT_INSTALL_DIR` | `/usr/local` | Install prefix used by `install.sh` |
| `GUT_BIG_THRESHOLD_KB` | `1024` | Minimum file size (in KB) flagged by `gut big scan` |
| `GIT_REMOTE` | `origin` | Remote name used by `gut sync --publish` |

---

## Disabling Colours

Useful in CI environments or when piping output:

```bash
export GUT_NO_COLOR=1
gut status
```

Output changes from colour-coded to plain text. All information is preserved.

---

## Large File Threshold

Control which files `gut big scan` flags as "large":

```bash
# Flag files over 500 KB (instead of the default 1024 KB)
export GUT_BIG_THRESHOLD_KB=500
gut big scan
```

---

## Persistent Configuration

Add variables to your shell profile for permanent effect:

=== "Zsh (~/.zshrc)"
    ```zsh
    export GUT_BIG_THRESHOLD_KB=512
    ```

=== "Bash (~/.bashrc)"
    ```bash
    export GUT_BIG_THRESHOLD_KB=512
    ```

=== "Fish (~/.config/fish/config.fish)"
    ```fish
    set -x GUT_BIG_THRESHOLD_KB 512
    ```
