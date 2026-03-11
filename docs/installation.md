---
title: Installation
description: "| Requirement | Version | Notes |"
---
# Installation

## Requirements

| Requirement | Version | Notes |
|---|---|---|
| **Bash** | 3.2+ | macOS default Bash (3.2) is fully supported |
| **Git** | Any | Must be on your `PATH` |
| **Git LFS** | Any | Optional  only needed for `gut big` commands |

---

## Unix / Linux / macOS

```bash
git clone https://github.com/seowings/gut.git
cd gut
chmod +x install.sh
./install.sh
```

By default, gut installs to `/usr/local`:

- Binary: `/usr/local/bin/gut`
- Library: `/usr/local/lib/gut/*.sh`
- Completion: `/usr/local/share/gut/completion/`

### Custom install directory

```bash
GUT_INSTALL_DIR=~/.local ./install.sh
```

Make sure the `bin` subdirectory is on your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Windows

Git for Windows already ships with `bash.exe`, so gut works without any extra setup.

1. Clone or download gut anywhere on your machine.
2. Add the `gut\bin` directory to your Windows `PATH` environment variable.
3. Use `gut` from **Command Prompt**, **PowerShell**, or **Git Bash**.

---

## Verifying the Installation

```bash
gut --version   #  gut v0.1.0
gut --help      # full command reference
```

---

## Auto-Completion

gut ships with tab-completion for both **Zsh** and **Bash**, covering all commands and their subcommands. It also completes branch names for `gut switch`, `gut integrate`, and `gut compare`.

=== "Zsh"
    Add to `~/.zshrc`:

    ```zsh
    fpath=("/usr/local/share/gut/completion" $fpath)
    autoload -Uz compinit && compinit
    ```

    Then reload:

    ```bash
    source ~/.zshrc
    ```

=== "Bash"
    Add to `~/.bashrc` or `~/.bash_profile`:

    ```bash
    source "/usr/local/share/gut/completion/gut-completion.bash"
    ```

    Then reload:

=== "Git Bash (Windows)"
    Because `gut` isn't installed to a standard Unix directory on Windows, you'll need to source the completion file directly from wherever you downloaded the `gut` repository.

    Add this to `~/.bashrc` or `~/.bash_profile`:

    ```bash
    # Replace C:/path/to/gut with the actual folder where you put gut
    source "C:/path/to/gut/completion/gut-completion.bash"
    ```

    Then reload:

    ```bash
    source ~/.bashrc
    ```

!!! tip "Custom install directory"
    If you used `GUT_INSTALL_DIR`, replace `/usr/local` with your chosen path in the completion snippets above.

---

## Uninstalling

### Unix / macOS

```bash
rm /usr/local/bin/gut
rm -rf /usr/local/lib/gut
rm -rf /usr/local/share/gut
```

And remove the completion lines from your shell profile.

### Windows

1. Delete the `gut` folder you downloaded.
2. Remove the `gut\bin` directory from your Windows `PATH` environment variable.
