# Taptime - Claude Code Rules

> For the full documentation map, see `docs/INDEX.md`.
> For coding standards, see `.claude/rules/`.

## Session Startup (REQUIRED)

**Every agent session MUST start by reading these files in order:**

1. **PLAN.md** — understand what work exists, what's done, what's next
2. **PROGRESS.md** — understand current state, blockers, and notes from previous agents

Do NOT start any implementation work before reading both files.

## Project Overview

- **App:** Taptime — a time management app with preset-based Pomodoro timer
- **Platform:** Flutter (iOS + Android), local-first (Drift/SQLite)
- **Architecture:** 2-layer MVVM + Repository pattern, feature-first folder structure
- **State management:** Riverpod

## Documentation Rules

### Language

- All `.md` documents must be written in **English**
- Exception: user's original input recorded **in Korean** under "Original" sections
- `*_KO.md` files are Korean translations for human readers — agents must ignore them
- See `docs/tips/multilingual-docs.md` for translation management rules

### Document Map

- **`docs/INDEX.md`** is the central index of all project documents
- Check it before creating new documents — avoid duplication
- Update it when adding new documents

### Planning Changes

- When any planning change occurs, update `docs/planning/CHANGELOG_PLANNING.md` with:
  - **Original (User Input):** user's exact words in Korean, quoted
  - **Background:** why the change was needed (in English)
  - **Changes:** what was modified and where (in English)
  - **Impact:** downstream effects on other features/plans (in English)
- Also update the relevant source document (`PRD.md` or `MVP_SPEC.md`)

### PLAN.md vs PROGRESS.md

| File | Purpose | Contains | Updated When |
|------|---------|----------|-------------|
| `PLAN.md` | What needs to be done | Phases, tasks, priorities, backlog | Task added/removed/completed (`[x]`) |
| `PROGRESS.md` | Current state & handoff | Status, next agent notes, recent 2-3 sessions only | Every commit |

- **PLAN.md:** Checklist of all tasks grouped by phase. Mark `[x]` when a task is done. Do NOT put status or logs here.
- **PROGRESS.md:** Current status + handoff notes for next agent. Keep only recent 2-3 sessions — older history lives in git log. Do NOT put future tasks here.

### Commit Rules

- Update `PROGRESS.md` on every commit
- Mark completed tasks as `[x]` in `PLAN.md`

### Issue & Feature Tracking

- All issues and feature records go in `docs/issues/`
- Use template: `docs/issues/TEMPLATE.md`
- Naming: `FEAT-NNN_short-name.md` for features, `BUG-NNN_short-name.md` for bugs
- When implementing a feature or fixing a bug, create the corresponding file

### Conversation Log

- `docs/conversations/LOG.md` — written **only when user explicitly requests**

### References

- Research materials in `docs/references/`
- Check existing references before performing web searches

### Skills (Slash Commands)

- Custom skills are in `.claude/skills/` — use them for consistent workflows
- `/new-feature`, `/bug-report`, `/research`, `/update-docs`, `/review-architecture`
- See `docs/INDEX.md` for full descriptions

### Architecture Decisions

- Record in `docs/adr/NNNN-title.md` when a technical choice is made or changed

## Code Reuse

Before writing new code, **search existing code first:**

- Utility functions → `lib/core/utils/`
- Shared models → `lib/shared/models/`
- Repository interfaces → `lib/shared/repositories/`
- Constants → `lib/core/constants/`
- Widgets → `lib/features/*/ui/widgets/`

Rules:
- Reuse existing repository methods — check interfaces before adding new queries
- Reuse existing helpers (e.g., `_queryByDateRange`, `_toModel`) inside implementations
- Extract to `core/utils/` when 2+ features need the same logic
- After implementation, run `/simplify` to catch missed reuse opportunities
