---
title: gut pr
description: "Open a Pull Request (or Merge Request) for the current branch directly in your browser - no need to navigate to the website manually."
---
# gut pr

Open a Pull Request (or Merge Request) for the current branch directly in your browser - no need to navigate to the website manually.

---

## Usage

```bash
gut pr
```

`gut pr` automatically detects your Git hosting provider from the remote URL and builds the correct "new PR" URL for your current branch.

---

## Supported Providers

| Provider | URL opened |
|---|---|
| **GitHub** | `https://github.com/<owner>/<repo>/pull/new/<branch>` |
| **GitLab** | `https://gitlab.com/<...>/-/merge_requests/new?...` |
| **Bitbucket** | `https://bitbucket.org/<...>/pull-requests/new?...` |

!!! note "Other providers"
    If your remote is hosted on a self-hosted GitLab/Gitea/Forgejo instance or another provider, gut will display a warning and show the remote URL so you can open the PR manually.

---

## Example

```bash
# You're on: feature/user-auth
gut pr
```

```
[INFO] Opening PR page for branch 'feature/user-auth'...
  URL: https://github.com/myorg/myrepo/pull/new/feature/user-auth
```

Your browser opens automatically to the pre-filled new PR form.

---

## Prerequisites

- Your branch must already be pushed to the remote. Run `gut sync --publish` first if you haven't pushed it yet.
- The remote must be named `origin`.

---

## See Also

- [`gut sync --publish`](sync.md) - push a new branch to the remote
- [`gut protect`](protect.md) - prevent direct pushes to protected branches
