# Project Scaffolding & Documentation-as-Code

> Researched: 2026-03-15

## Summary

Research on best practices for project documentation structuring, Claude Code plugins, and existing scaffolding tools.

## Terminology

| Term | Definition |
|------|-----------|
| **Project Scaffolding** | Initial project structure setup (files, folders, configs) |
| **Documentation-as-Code** | Version-controlled docs alongside code in Git |
| **Persistent Markdown Planning** | PLAN.md/PROGRESS.md workflow for task tracking |
| **ADR (Architecture Decision Records)** | Documenting technical decisions with context and rationale |
| **MADR** | Markdown ADR — structured format with Considered Options and Consequences |
| **Claude Code Plugin** | Distributable package of skills, hooks, rules, MCP servers |
| **Claude Code Skills** | Custom slash commands in `.claude/skills/` |
| **Claude Code Rules** | Auto-loaded instructions in `.claude/rules/` |
| **Claude Code Hooks** | Event-based automation in `.claude/settings.json` |

## Existing Tools

### Claude Code Starter Kits

| Tool | Repo | Focus |
|------|------|-------|
| **claude-code-mastery-starter-kit** | TheDecipherist/claude-code-mastery-project-starter-kit | Interactive project wizard, MDD workflow, project management |
| **claude-starter-kit** | serpro69/claude-starter-kit | GitHub template repo with .claude/ structure |
| **Claude-Code-Scaffolding-Skill** | hmohamed01/Claude-Code-Scaffolding-Skill | 70+ project type scaffolding for IDEs |
| **awesome-claude-code** | hesreallyhim/awesome-claude-code | Curated list of community resources |

### Official Anthropic Plugin Marketplace

Categories: Code Intelligence (LSP), External Integrations (GitHub, Slack, Sentry), Development Workflows (commit-commands, pr-review-toolkit), Output Styles.

## ADR Standard Formats

### Nygard Format (Original, 2011)
- Sections: Status, Context, Decision, Consequences
- Simple, lightweight

### MADR Format (Recommended)
- Sections: Context and Problem Statement, Considered Options, Decision Outcome (with Positive/Negative Consequences), Links
- More structured, better for team decisions
- Reference: adr.github.io/madr/

## Claude Code Plugin Structure

```
plugin/
├── .claude-plugin/
│   └── plugin.json          # name, version, description, author, keywords
├── skills/                  # Slash commands
├── hooks/
│   └── hooks.json           # Event automation
├── settings.json            # Default settings
├── .mcp.json               # MCP servers
└── README.md
```

Install: `/plugin install name@marketplace` or `claude --plugin-dir ./plugin`

## User-Level vs Project-Level

| Level | Location | Scope |
|-------|----------|-------|
| User | `~/.claude/rules/`, `~/.claude/skills/` | All projects |
| Project | `.claude/rules/`, `.claude/skills/` | This project only (version-controlled) |
| Plugin | Via marketplace | Distributable, installable |

Project-level overrides user-level for same-name skills.

## Best Practices

- CLAUDE.md: under 200 lines, only non-inferrable instructions
- Rules: topic-based files, `paths` frontmatter for scoping
- Skills: universal in `~/.claude/skills/`, project-specific in `.claude/skills/`
- Hooks: `SessionStart` for context injection, `Stop` for completion verification
- ADR: use MADR format, sequential numbering (0001, 0002...)
- Docs: update in same commit as code changes

## Sources

- Claude Code official docs (plugins, skills, hooks, rules, MCP)
- adr.github.io — ADR templates and MADR specification
- joelparkerhenderson/architecture-decision-record — comprehensive examples
- TheDecipherist/claude-code-mastery-project-starter-kit
- serpro69/claude-starter-kit
