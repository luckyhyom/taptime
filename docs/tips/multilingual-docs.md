# Multilingual Documentation Management

> Best practices for managing Korean translations of English documentation.

## Approach

- **Method:** File suffix (`*_KO.md`) in the same directory as the original
- **Canonical source:** English original (agents read this)
- **Korean files:** For human readers (GitHub, team members)
- **Agents:** Must ignore `*_KO.md` files — never read or modify them unless explicitly asked

## Translation Tracking

Each `_KO.md` file has a comment at the top:

```markdown
<!-- translated from: PRD.md @ commit abc1234 (2026-03-15) -->
```

To check if a translation is outdated:

```bash
git log --format="%h %as" -1 -- docs/planning/PRD.md
# Compare hash with the one in PRD_KO.md header
```

## When to Translate

- Translations are done **on user request only** (batch update)
- Use `/translate-docs` skill to update all outdated translations
- Never auto-translate on commit — this wastes tokens

## What Gets Translated

| Translate (_KO) | Do NOT translate |
|---|---|
| README.md | .claude/rules/* |
| CLAUDE.md | .claude/skills/* |
| PLAN.md, PROGRESS.md | .claude/settings.json |
| docs/planning/* | docs/references/* |
| docs/adr/* | docs/issues/* |
| docs/guides/* | docs/conversations/* |
| docs/INDEX.md | |
| docs/tips/* | |

## Research Basis

Based on how major open source projects handle translations:

| Project | Method |
|---|---|
| standard.js, node-best-practices | File suffix (same folder) — best for small/medium projects |
| Kubernetes | Language subfolders (content/ko/) — best for large docs |
| React, Vue | Separate repos per language — best for massive docs |

File suffix was chosen because Taptime has <20 translatable documents.
