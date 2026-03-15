# Taptime - Progress

> **What has been done and where we are now.** Status log for agents to understand current state.
> Agents: read PLAN.md first, then this file to see what's already completed.

## Current Status

- **Active Phase:** Phase 1 (Foundation) — in progress
- **Last Updated:** 2026-03-15
- **Blocker:** None (Android SDK는 후순위, iOS 개발 가능)

## Completed Work

### 2026-03-14 — Project Initialization & Planning

- Created project directory structure (`taptime/`)
- Wrote PRD with full feature specification (`docs/PRD.md`)
- Defined MVP scope with data model, architecture, milestones (`docs/MVP_SPEC.md`)
- Researched 8 competing apps, documented findings (`docs/references/competitive_analysis.md`)
- Selected tech stack: Flutter + Riverpod + Isar + GoRouter (`docs/references/tech_stack.md`)
- Designed color palette and UI system (`docs/references/design_system.md`)
- Established planning changelog (`docs/CHANGELOG_PLANNING.md`)
- Set up CLAUDE.md, PLAN.md, PROGRESS.md workflow

### 2026-03-14 — Architecture Simplification & Doc Restructure

- Removed NestJS backend, Docker, team features, rankings, multi-device sync from scope
- Added heatmap, streaks, data export/import to roadmap
- Restructured docs: `docs/planning/` for product docs, `docs/adr/` for tech decisions
- Set up `.claude/rules/` for modular development rules
- Established CLAUDE.md + AGENTS.md relationship (AGENTS.md references CLAUDE.md)

### 2026-03-14 — Development Rules Setup

- Established commit rules: Conventional Commits format (`.claude/rules/commit-rules.md`)
- Established issue tracking: file-based in `docs/issues/`, template with technical/security/test sections
- Established code style rules: `very_good_analysis` lint, Dart conventions (`.claude/rules/code-style.md`)
- Established architecture: 2-layer MVVM + Repository, feature-first folder structure (`.claude/rules/architecture.md`)
- Established testing rules: unit/widget/integration strategy (`.claude/rules/testing.md`)
- Recorded 5 ADRs: local-first architecture, 2-layer MVVM, Riverpod, file-based issues, conventional commits
- Created `docs/INDEX.md` as central documentation map
- Added `docs/guides/ONBOARDING.md` for newcomer reading order
- Added `docs/tips/` for practical knowledge (token efficiency, context window)
- Added `.claude/rules/pitfalls.md` for mistake prevention
- Created `README.md`
- Saved missing research to `docs/references/` (commit conventions, architecture patterns)
- Replaced `docs/learning/` with `docs/tips/`

### 2026-03-15 — Skills, Hooks & Document Fixes

- Created 5 custom skills in `.claude/skills/`:
  - `new-feature` — FEAT file creation + PLAN.md update
  - `bug-report` — BUG file creation
  - `research` — reference check before web search
  - `update-docs` — PLAN.md + PROGRESS.md sync
  - `review-architecture` — architecture compliance check
- Created `.claude/settings.json` with PostToolUse hook (auto `dart format` on .dart files)
- Recorded ADR-0006: Claude Code Skills and Hooks
- Fixed `docs/planning/MVP_SPEC.md`: updated Section 4 from 3-layer Clean Architecture to 2-layer MVVM + feature-first (was stale since ADR-0002)
- Fixed `docs/issues/TEMPLATE.md`: added FEAT/BUG prefix naming convention
- Updated `docs/INDEX.md` with Skills section
- Updated `CLAUDE.md` with Skills reference
- Phase 0 (Planning & Design) completed

### 2026-03-15 — Reusability & Plugin Packaging

- Created user-level universal skills in `~/.claude/skills/`:
  - `init-project` — new project bootstrap with docs structure and rules
  - `new-feature`, `bug-report`, `research`, `update-docs` (universal versions)
- Created user-level universal rules in `~/.claude/rules/`:
  - `commit-rules.md` (Conventional Commits without project-specific scopes)
- Refactored project-level `commit-rules.md` to contain only project-specific scopes
- Created Claude Code Plugin at `~/workspace/claude-project-starter/`:
  - `.claude-plugin/plugin.json`, skills, hooks, settings, README
  - Multi-language auto-format hook (dart, js/ts, python, go, rust)
- Researched project scaffolding best practices, saved to `docs/references/project_scaffolding.md`
- Updated `docs/INDEX.md` with ADR-0006, new reference, context-window tip

### 2026-03-15 — Phase 1 Start: Environment Setup

- Installed Flutter SDK 3.41.4 (stable) via Homebrew
- Created GitHub repo: https://github.com/luckyhyom/taptime (public)
- Pushed all commits to remote `origin/main`

## Notes for Next Agent

### Immediate Next Task

Phase 1 (Foundation) in progress. Flutter SDK installed. **Next:** resolve platform toolchain issues, then `flutter create` and scaffold the project.

### Environment Status

- Flutter 3.41.4 ✓, Xcode 26.3 ✓, CocoaPods ✓, Chrome ✓
- Android SDK: deferred (SDK 36 + BuildTools 28.0.3 needed later)

### Key Context

- All documents are indexed in `docs/INDEX.md`
- Development rules: `.claude/rules/` (project) + `~/.claude/rules/` (universal)
- Skills: `.claude/skills/` (project) + `~/.claude/skills/` (universal, includes `/init-project`)
- Plugin: `~/workspace/claude-project-starter/` (distributable package)
- Research materials are in `docs/references/` (read on demand)
- Conversation log is user's words only — do not add agent summaries
