# Commit Conventions Research

> **Researched:** 2026-03-14
> **Purpose:** Select commit message format and granularity rules
> **Decision:** ADR-0005, applied in `.claude/rules/commit-rules.md`

## Conventional Commits (Selected)

- Industry standard in 2025-2026, derived from Angular convention
- Machine-parseable: enables auto-changelog, semantic versioning, CI triggers
- Format: `<type>(scope): <description>`
- Only mandates `feat` and `fix`; additional types are team's choice

## Alternatives Considered

| Standard | Pros | Cons | Verdict |
|----------|------|------|---------|
| Conventional Commits | Industry standard, tool support | Requires discipline | **Selected** |
| Free-form | No learning curve | Inconsistent, no automation | Rejected |
| Gitmoji | Visual | Hard to parse, not professional | Rejected |

## Atomic Commit Principles

- One commit = one logical change
- If "and" is needed in the message, split it
- App must build after every commit
- Never mix formatting with logic changes
- Tests belong in the same commit as the feature/fix

## Flutter-specific Tools

| Tool | Package | Purpose |
|------|---------|---------|
| husky | `husky` (pub.dev) | Git hooks for Dart/Flutter |
| commitlint | `commitlint_cli` (pub.dev) | Lint commit messages |
| lint_staged | `lint_staged` (pub.dev) | Run linters on staged files only |

## Sources

- [Conventional Commits Specification](https://www.conventionalcommits.org/en/v1.0.0/)
- [Atomic Commits Explained (PHP Architect, 2025)](https://www.phparch.com/2025/06/atomic-commits-explained-stop-writing-useless-git-messages/)
- [hyiso/commitlint for Dart/Flutter](https://github.com/hyiso/commitlint)
