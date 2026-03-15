# Commit Rules (Project-Specific)

> Base rules (format, types, atomic commits) are in `~/.claude/rules/commit-rules.md`.

## Scopes

- Feature: `timer`, `preset`, `history`, `stats`, `settings`
- Layer: `ui`, `domain`, `data`, `infra`
- Platform: `android`, `ios`

## Commit Timing

- Commit after each logical unit of work — do not accumulate unrelated changes
- If you realize uncommitted changes exist from a previous task, commit them before starting new work

## Recording Changes

- Simple changes: explain background in commit body
- Significant features/bugs: create detailed record in `docs/issues/`

## Dependency Changes

- When adding/removing dependencies, list each one with a brief reason in the commit body
- Example:
  ```
  chore: add core dependencies for phase 1

  - flutter_riverpod: type-safe state management
  - go_router: declarative routing with deep link support
  ```

## Co-Author

All commits by Claude must include:
```
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
