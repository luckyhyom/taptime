# ADR-0006: Claude Code Skills and Hooks

- **Status:** Accepted
- **Date:** 2026-03-15
- **Deciders:** User, Claude

## Context

The project needs consistent workflows across different agent sessions: creating feature/bug files, updating tracking documents, checking architecture compliance, and managing research references. Manual processes are error-prone and inconsistent.

## Decision

Use Claude Code's **Skills** (`.claude/skills/`) for reusable workflow automation and **Hooks** (`.claude/settings.json`) for automatic code formatting.

### Skills Created

| Skill | Purpose |
|-------|---------|
| `/new-feature` | Create FEAT issue file + update PLAN.md |
| `/bug-report` | Create BUG issue file |
| `/research` | Check existing references before web search |
| `/update-docs` | Sync PLAN.md + PROGRESS.md |
| `/review-architecture` | Verify layer boundaries and naming conventions |

### Hooks Created

| Event | Trigger | Action |
|-------|---------|--------|
| PostToolUse | Edit/Write on `.dart` files | Auto-run `dart format -l 120` |

### Alternatives Considered

- **Commands** (`.claude/commands/`): Legacy format, lacks supporting files and subagent support. Skills are the recommended replacement.
- **MCP Servers**: Overkill for current needs. Considered for future Supabase integration (v2.0).
- **No automation**: Relies on agents remembering all conventions — error-prone as shown by past pitfalls.

## Consequences

- Agents can use `/new-feature timer-pause` instead of manually creating files and updating PLAN.md
- Dart files are always formatted consistently without manual intervention
- Research is deduplicated by checking existing references first
- Skills are auto-discovered by Claude Code at session start (descriptions only — loaded on demand)
