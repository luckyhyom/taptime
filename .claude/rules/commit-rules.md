# Commit Rules

## Format (Conventional Commits)

```
<type>(scope): <description>

[optional body - explain "why", not "what"]

[optional footer - issue ref, breaking change]
```

- Subject: imperative mood, lowercase, no period, max 50 chars
- Body: wrap at 72 chars
- Footer: `Closes #N`, `BREAKING CHANGE: ...`

## Types

| Type | When to Use |
|------|------------|
| `feat` | New user-facing feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring, no behavior change |
| `style` | Formatting only (dart format, whitespace) |
| `docs` | Documentation changes only |
| `test` | Adding or modifying tests |
| `chore` | Dependencies, config, maintenance |
| `build` | Build system, Xcode/Gradle config |
| `perf` | Performance improvement, no functional change |

## Scopes

- Feature: `timer`, `preset`, `history`, `stats`, `settings`
- Layer: `ui`, `domain`, `data`, `infra`
- Platform: `android`, `ios`

## Atomic Commits

- One commit = one logical change
- If you need "and" to describe the commit, split it
- App must build successfully after every commit
- Never mix formatting changes with logic changes
- Include related tests in the same commit as the feature/fix

## Recording Changes

- Simple changes: explain background in commit body
- Significant features/bugs: create detailed record in `docs/issues/`

## Co-Author

All commits by Claude must include:
```
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
