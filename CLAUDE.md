# Taptime - Claude Code Rules

## Session Startup (REQUIRED)

**Every agent session MUST start by reading these files in order:**

1. **PLAN.md** — understand what work exists, what's done, what's next
2. **PROGRESS.md** — understand current state, blockers, and notes from previous agents

Do NOT start any implementation work before reading both files.

## Project Overview

- **App:** Taptime — a time management app with preset-based Pomodoro timer
- **Platform:** Flutter (iOS + Android)
- **Architecture:** Clean Architecture with repository pattern (domain / infrastructure / presentation)
- **State management:** Riverpod
- **Local DB:** Isar

## Documentation Rules

### Language

- All `.md` documents must be written in **English**
- Exception: user's original input is recorded **in Korean** under "Original" sections in `CHANGELOG_PLANNING.md`

### Planning Changes

- When any planning change occurs (feature added/removed/modified, scope change, architectural decision), update `docs/CHANGELOG_PLANNING.md` with:
  - **Original (User Input):** user's exact words in Korean, quoted
  - **Background:** why the change was needed (in English)
  - **Changes:** what was modified and where (in English)
  - **Impact:** downstream effects on other features/plans (in English)
- Also update the relevant source document (`PRD.md` or `MVP_SPEC.md`) to reflect the change

### PLAN.md vs PROGRESS.md

| File | Purpose | Contains | Updated When |
|------|---------|----------|-------------|
| `PLAN.md` | What needs to be done | Phases, tasks, priorities, backlog | Task added/removed/completed (`[x]`) |
| `PROGRESS.md` | What has been done & current state | Completion log, current status, blockers, notes for next agent | Every commit |

- **PLAN.md:** Checklist of all tasks grouped by phase. Mark `[x]` when a task is done. Do NOT put status or logs here.
- **PROGRESS.md:** Chronological log of completed work, current active phase, blockers, and handoff notes. Do NOT put future tasks here.

### Commit Rules

- Update `PROGRESS.md` on every commit
- Mark completed tasks as `[x]` in `PLAN.md`

### Conversation Log

- `docs/conversations/LOG.md` is for the user's personal record
- Only write to it **when the user explicitly requests** — do NOT auto-record

### References

- Research and reference materials are stored in `docs/references/`
- Check `docs/references/INDEX.md` before performing web searches — the answer may already exist

## Code Conventions

- Follow Flutter/Dart style guide
- Use English for all code, comments, and commit messages
- Keep infrastructure layer swappable via abstract interfaces in domain layer
