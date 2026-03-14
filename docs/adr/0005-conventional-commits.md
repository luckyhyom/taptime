# ADR-0005: Conventional Commits Standard

- **Status:** Accepted
- **Date:** 2026-03-14

## Context

Need a consistent commit message format that supports automation (changelog generation, semantic versioning) and is readable by both humans and AI agents.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Conventional Commits | Industry standard, machine-parseable, tool support (commitlint, changelog generators) | Requires discipline, slightly more verbose |
| Free-form messages | No learning curve | Inconsistent, no automation possible |
| Gitmoji | Visual, fun | Hard to parse, not widely used in professional settings |

## Decision

Conventional Commits with project-specific scopes.

## Rationale

- Most widely adopted standard in 2025-2026
- Enables automatic changelog generation and semantic versioning
- `commitlint_cli` (Dart package) enforces format via pre-commit hooks
- Scopes map to our feature-first architecture (timer, preset, history, stats, settings)

## Consequences

- All contributors (human and AI) must follow the format
- Pre-commit hooks will reject non-conforming messages
- Commit history becomes searchable and filterable by type/scope
