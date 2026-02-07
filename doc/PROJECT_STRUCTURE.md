# Project Structure

Updated: 2026-02-07

## Top-level Layout
```text
.
- .gitignore
- CHANGELOG.md
- LICENSE
- README.OpenSource
- README.md
- README_EN.md
- cjpm.lock
- cjpm.toml
- cmd
- doc
- src
```

## Conventions
- Keep executable/business code under src/ as the long-term target.
- Keep docs under docs/ (or doc/ for Cangjie projects).
- Keep local runtime artifacts and secrets out of version control.
