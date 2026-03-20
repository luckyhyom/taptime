# Multi-Agent Collaboration Operations v1

- **Status:** draft
- **Created:** 2026-03-20
- **Scope:** cross-agent collaboration workflow for this repository

## Purpose

This document proposes a shared operating model for multiple agents working in
the same repository without relying on one specific agent runtime.

The goal is to reduce:

- duplicate work
- file ownership conflicts
- drift between code state and tracking documents
- process knowledge living only in Claude-specific skills

This is a draft proposal, not mandatory project policy yet.

## Operating Model

### 1. Session entrypoint

Every agent should start from the same source-of-truth sequence:

1. `AGENTS.md`
2. `CLAUDE.md`
3. `PLAN.md`
4. `PROGRESS.md`

This keeps onboarding stable across agent runtimes and reduces hidden process
knowledge.

### 2. Task claiming

Before changing code, the agent should identify one concrete work unit and its
expected file scope.

Recommended claim format:

- **Task:** short task name
- **Owner:** agent/session identifier
- **Files:** expected file scope
- **Status:** in progress / blocked / ready for review
- **Blockers:** none or concise blocker note

For active work, the claim should be recorded in `PROGRESS.md`. For larger
features, feature-specific detail should live in `docs/issues/FEAT-*.md` or
`docs/issues/BUG-*.md`.

### 3. Ownership

Each active task should have a single owner at a time.

Rules:

- one agent owns one work unit
- one work unit has one declared file scope
- avoid assigning the same file to multiple agents unless one is review-only
- if scope expands, update the ownership note before editing new files

### 4. Handoff

When stopping work, the agent should leave a short handoff in `PROGRESS.md`
covering:

- what changed
- what is incomplete
- exact next task
- blocker or risk, if any

### 5. Closeout

A task is not complete when code merely exists. It is complete when the working
state is verifiable and the tracking documents match reality.

Minimum closeout steps:

1. finish implementation
2. add or update relevant tests
3. run `flutter analyze`
4. run `flutter test`
5. update `PLAN.md`
6. update `PROGRESS.md`

## Work Unit Design

Work should be split by responsibility, not only by feature label.

Good examples:

- preset form UI layout
- preset form validation and state handling
- preset repository tests
- timer state persistence

Bad examples:

- presets
- timer
- app polish

Preferred split rules:

- keep each work unit small enough to finish in one session
- keep file overlap minimal
- separate implementation from verification when useful
- prefer additive changes over broad refactors when parallel work is active

If a feature requires multiple agents, split ownership by layer or by file set.

Example:

- Agent A: `lib/features/preset/ui/`
- Agent B: `lib/features/preset/data/` and tests
- Agent C: widget tests only

## Source Of Truth

Repository collaboration should not depend on one tool vendor.

Use these roles consistently:

- `PLAN.md`: backlog and completion checklist only
- `PROGRESS.md`: current active state, handoff, blockers, next task
- `docs/issues/FEAT-*.md` and `docs/issues/BUG-*.md`: feature or bug level detail
- `docs/INDEX.md`: document discovery map
- `.claude/rules/`: project engineering rules

Rules:

- do not use `PROGRESS.md` as a backlog
- do not use `PLAN.md` as a session log
- do not store critical process knowledge only in a skill
- do not assume `.claude/` automation exists in every runtime

## Compatibility Rules

### Common to all agents

These should remain readable and usable without Claude-specific features:

- `AGENTS.md`
- `CLAUDE.md`
- `PLAN.md`
- `PROGRESS.md`
- `docs/issues/`
- repository tests and verification commands

### Claude-specific accelerators

These are useful, but optional from a repository governance standpoint:

- `.claude/skills/`
- `.claude/settings.json`
- Claude hooks such as automatic Dart formatting

Claude-specific automation should accelerate work, not define the only valid
workflow.

## Definition Of Done

A work unit is done only if all of the following are true:

- implementation is complete for the agreed scope
- relevant tests were added or updated
- `flutter analyze` passes
- `flutter test` passes
- `PLAN.md` reflects completed tasks
- `PROGRESS.md` reflects the current repo state and next task

## Adoption Path

This proposal is intentionally lightweight for v1.

If adopted later, promote the stable parts into:

- `AGENTS.md` for the universal entrypoint
- `CLAUDE.md` for required workflow rules
- `docs/INDEX.md` for discoverability

Possible later upgrades:

- add a dedicated active-ownership section to `PROGRESS.md`
- require feature issue files for any multi-session implementation
- add git-level verification such as `pre-commit` or `pre-push`
- add a runtime-neutral verification script instead of tool-specific habits

## Defaults Chosen In This v1 Proposal

- Collaboration rules live under `docs/` rather than a root-only folder
- `docs/harness/ideas/` is the draft area for cross-agent operations proposals
- active ownership is recorded in `PROGRESS.md`
- feature detail remains in `docs/issues/`
- Claude skills are treated as optional accelerators, not global requirements
