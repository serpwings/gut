---
title: gut blame
description: "An annotated view of a file showing who wrote each line, when, and which commit it came from - grouped by author to reduce visual noise."
---
# gut blame

An annotated view of a file showing who wrote each line, when, and which commit it came from - grouped by author to reduce visual noise.

---

## Usage

```bash
gut blame <file>
```

---

## Example Output

```
=== Blame: src/auth.js ===

a1b2c3d alice  2024-03-01
  12   function validateToken(token) {
  13     if (!token) return false;

d4e5f6a bob  2024-02-15
  14     return jwt.verify(token, SECRET);
  15   }
```

Author headers are only repeated when the author changes, keeping the output readable even for long files.

---

## See Also

- [`gut history`](history.md) - see commits on the current branch
- [`gut stats`](stats.md) - see commit counts per author
