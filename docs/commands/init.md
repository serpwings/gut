---
title: gut init
description: "Initialize a new git repository in the current directory with sensible defaults."
---
# gut init

Initialize a new git repository in the current directory with sensible defaults.

---

## Usage

```bash
gut init
```

Running `gut init` creates a `.git` folder in your current directory and establishes the default branch as tracking `main` (if not otherwise specified in Git configuration settings).

Unlike regular `git init`, `gut init` will set up a more robust initial commit and branch structure so you can start working right away.

### Examples

```bash
mkdir new-project
cd new-project
gut init
```
