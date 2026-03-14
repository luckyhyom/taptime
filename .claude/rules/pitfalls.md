# Pitfalls

> Known mistakes and rules to prevent them. All agents must check this file.
> Add new entries when mistakes are discovered.

---

## DON'T: Delete user-created files without asking

- **Found:** 2026-03-14
- **Context:** Tried to delete empty LEARNING.md assuming it was unnecessary
- **Rule:** Never delete files the user created, even if empty. Ask first.

## DON'T: Modify documents without explaining changes first

- **Found:** 2026-03-14
- **Context:** Attempted to rewrite CLAUDE.md without summarizing what would change
- **Rule:** Summarize all planned changes and get approval before writing.

## DON'T: Auto-record conversation logs

- **Found:** 2026-03-14
- **Context:** Automatically wrote to conversations/LOG.md without being asked
- **Rule:** Only write to `docs/conversations/LOG.md` when the user explicitly requests it.

## DON'T: Assume architecture without checking current decisions

- **Found:** 2026-03-14
- **Context:** Documents referenced 3-layer Clean Architecture after it was changed to 2-layer MVVM
- **Rule:** Always check `docs/adr/` and `.claude/rules/architecture.md` for current architecture decisions before writing code or documents.
