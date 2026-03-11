---
title: gut sync
description: "Coordinated pull/push that detects the state of your branch relative to its remote counterpart and does the right thing automatically."
---
# gut sync

Coordinated pull/push that detects the state of your branch relative to its remote counterpart and does the right thing automatically.

---

## Usage

```bash
gut sync [options]
```

## Options

| Option | Description |
|---|---|
| `--publish` | Push a new branch to the remote for the first time |
| `--reconcile` | Interactively merge or rebase when branches have diverged |
| `--force` | Force-push using `--force-with-lease` (with confirmation) |

---

## Examples

```bash
# Smart sync: pulls if behind, pushes if ahead
gut sync

# Publish a new branch to the remote for the first time
gut sync --publish

# Reconcile a diverged branch (choose merge or rebase)
gut sync --reconcile

# Force-push (safe version  won't overwrite if remote changed)
gut sync --force
```

---

## How It Works

`gut sync` fetches the remote first, then compares `HEAD` to `@{u}` (the upstream tracking branch):

| Situation | Action |
|---|---|
| **Up to date** | Reports nothing to sync |
| **You are ahead** | Pushes your commits to the remote |
| **You are behind** | Pulls remote commits via fast-forward |
| **Diverged** | Warns and suggests `--reconcile` |

---

## Divergence Handling (`--reconcile`)

When you and the remote have both made commits since the last common ancestor, neither fast-forward pull nor a plain push will work. `--reconcile` offers a guided menu:

1. **Merge**  Brings in remote changes with a merge commit. Safe; preserves full history.
2. **Rebase**  Replays your commits on top of the remote. Cleaner history; rewrites your commits.
3. **Cancel**  Does nothing.

!!! tip "When to use each"
    - Use **merge** on shared branches (`main`, `develop`) or when working in a team.
    - Use **rebase** on your own feature branches where you want a linear history.

---

## Unsaved Changes Warning

If you have unstaged or staged changes when you run `gut sync`, gut will warn you:

```
  You have unsaved local changes. These will not be synced.
Tip: run 'gut save --all' first if you want to include them.
```

The sync operation still proceeds  your local changes are not touched.

---

## Force Push

`--force` uses `--force-with-lease` rather than plain `--force`. This means the push will be rejected if someone else has pushed to the same branch since your last fetch  protecting against accidental overwrites.

!!! warning
    Force-pushing rewrites remote history. Only use it on branches that are yours alone (e.g., a feature branch before it's been merged).

---

## See Also

- [`gut save`](save.md)  create commits before syncing
- [`gut branch`](branch.md)  create and manage branches
- [`gut integrate`](integrate.md)  merge branches locally
