# Indexing and Memory

How INDEX.md and MEMORY.md work, and how agents discover project documents.

## INDEX.md vs MEMORY.md

| | MEMORY.md | INDEX.md |
|---|---|---|
| Purpose | Cross-session memory (user info, feedback, project state) | Project documentation map |
| Auto-loaded | Yes, injected into every conversation | No, agent reads it manually |
| Size limit | 200 lines (hard limit, truncated after) | No hard limit (shorter is better) |
| Overlap | None — different purposes | None |

## How agents find documents

```
CLAUDE.md (auto-injected)
  → mentions "see docs/INDEX.md"
    → agent reads INDEX.md
      → finds and reads needed document
```

This is manual, not automatic lazy loading. It depends on agent judgment.

## When indexing fails

- Document not registered in INDEX.md → agent doesn't know it exists
- CLAUDE.md doesn't mention INDEX.md → agent may skip it entirely
- Sub-agents (Agent tool) may not receive CLAUDE.md → main agent must pass paths explicitly in the prompt

## Current safeguards

CLAUDE.md references INDEX.md 3 times (lines 3, 31, 79), making it very unlikely to be missed by the main agent.
