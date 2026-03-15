# Commit Rules (Project-Specific)

> Base rules (format, types, atomic commits) are in `~/.claude/rules/commit-rules.md`.

## Scopes

- Feature: `timer`, `preset`, `history`, `stats`, `settings`
- Layer: `ui`, `domain`, `data`, `infra`
- Platform: `android`, `ios`

## Recording Changes

- Simple changes: explain background in commit body
- Significant features/bugs: create detailed record in `docs/issues/`

## Co-Author

All commits by Claude must include:
```
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
