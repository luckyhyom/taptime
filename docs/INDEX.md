# Taptime Documentation Map

> Central index of all project documents. Start here to find anything.

## Project Management

- [CLAUDE.md](../CLAUDE.md): Claude-specific workflow rules and session startup instructions
- [AGENTS.md](../AGENTS.md): Cross-agent entry point (references CLAUDE.md)
- [PLAN.md](../PLAN.md): Task checklist by phase — what needs to be done
- [PROGRESS.md](../PROGRESS.md): Completion log and current status — what has been done

## Planning (Product Decisions)

- [PRD](planning/PRD.md): Full product requirements and feature specification
- [MVP Spec](planning/MVP_SPEC.md): MVP scope, data model, architecture, milestones
- [Planning Changelog](planning/CHANGELOG_PLANNING.md): Product decision history with user input in Korean

## Engineering Rules

- [Commit Rules](../.claude/rules/commit-rules.md): Conventional Commits format, atomic commit guidelines
- [Code Style](../.claude/rules/code-style.md): Dart/Flutter conventions, lint, naming, import order
- [Architecture](../.claude/rules/architecture.md): 2-layer MVVM + Repository, feature-first folder structure
- [Testing](../.claude/rules/testing.md): Unit/widget/integration test strategy and conventions
- [Pitfalls](../.claude/rules/pitfalls.md): Known mistakes and prevention rules — all agents must check

## Architecture Decisions (ADR)

- [ADR-0001](adr/0001-flutter-local-first.md): Flutter local-first, no backend server
- [ADR-0002](adr/0002-two-layer-mvvm-architecture.md): 2-layer MVVM over full Clean Architecture
- [ADR-0003](adr/0003-riverpod-state-management.md): Riverpod for state management
- [ADR-0004](adr/0004-file-based-issue-tracking.md): File-based issue tracking in docs/issues/
- [ADR-0005](adr/0005-conventional-commits.md): Conventional Commits standard
- [ADR-0006](adr/0006-claude-skills-and-hooks.md): Claude Code Skills and Hooks

## Issues & Features

- [Issue Template](issues/TEMPLATE.md): Template for BUG/FEAT files
- Issue files are stored in `docs/issues/` with prefix naming:
  - `FEAT-NNN_short-name.md` — new feature implementation record
  - `BUG-NNN_short-name.md` — bug report and resolution record

## References (Research Materials)

- [Competitive Analysis](references/competitive_analysis.md): 8 competing apps compared (aTimeLogger, Forest, Session, Toggl, etc.)
- [Tech Stack](references/tech_stack.md): Flutter packages, DB comparison, dependency list
- [Design System](references/design_system.md): Material 3, color palette, typography, iconography
- [Commit Conventions](references/commit_conventions.md): Conventional Commits research and alternatives
- [Architecture Patterns](references/architecture_patterns.md): Clean Architecture, MVVM, DDD, SOLID in Flutter
- [Project Scaffolding](references/project_scaffolding.md): Scaffolding tools, Documentation-as-Code, ADR standards, Claude Code plugins

## Skills (Slash Commands)

Custom skills available via `/command-name` in Claude Code sessions:

- `/new-feature <name>` — Create FEAT issue file and update PLAN.md
- `/bug-report <name>` — Create BUG issue file
- `/research <topic>` — Check existing references, then web search if needed
- `/update-docs` — Sync PLAN.md and PROGRESS.md after completing work
- `/review-architecture [target]` — Verify code compliance with architecture rules

Skills are defined in `.claude/skills/` (project-specific) and `~/.claude/skills/` (universal).
Universal skills (`/init-project`) are also available across all projects.

## Guides

- [Onboarding](guides/ONBOARDING.md): Reading order for newcomers
- [Setup](guides/SETUP.md): Development environment setup (Flutter, Xcode, Android)

## Tips

- [Token Efficiency](tips/token-efficiency.md): Document placement and language tips for AI token optimization
- [Context Window](tips/context-window.md): /context command interpretation guide
- [Claude Code Plugins](tips/claude-code-plugins.md): Plugin recommendations and selection guide
- [CocoaPods](tips/cocoapods.md): What CocoaPods does and why Flutter needs it for iOS
- [Indexing and Memory](tips/indexing-and-memory.md): How INDEX.md and MEMORY.md work, agent document discovery

## Personal

- [Conversation Log](conversations/LOG.md): Discussion record (written on user request only)

---

## When Working On...

| Task | Read First |
|------|-----------|
| New feature | Architecture rules → MVP Spec → create `FEAT-NNN` in issues/ |
| Bug fix | Relevant feature code → create `BUG-NNN` in issues/ |
| Planning change | PRD → update PRD → record in Planning Changelog |
| Tech decision | Existing ADRs → create new ADR in adr/ |
| Research | Check references/ first → add new research there |
| Starting a session | PLAN.md → PROGRESS.md (required for all agents) |
