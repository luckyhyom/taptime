# Claude Code Plugins Guide

> Useful plugins and selection recommendations for Claude Code projects.

## Recommended Plugins

### Context7 — ★★★★★ (Essential)

Injects up-to-date official documentation into context via MCP server.

- **Use case:** Prevents hallucination by fetching version-specific API docs dynamically
- **Benefit:** Uses docs-researcher subagent, saves main context window
- **Install:** `/plugin marketplace add upstash/context7` → `/plugin install context7-plugin@context7-marketplace`
- **Usage:** Auto-triggers on library/API queries, or `/context7:docs [query]`

### Language-Specific LSP — ★★★★★ (Essential for typed languages)

Provides code intelligence (go-to-definition, find references, type error checking) via Language Server Protocol.

- **Benefit:** Accurate type information reduces tokens + improves analysis accuracy
- **Install (TypeScript):** `/plugin install vtsls@claude-code-lsps`
- **Install (Dart):** Requires Dart SDK installed

### Feature-Dev — ★★★☆☆ (Large features)

Orchestrates full feature development lifecycle in 7 stages.

- **Agents:** code-explorer (codebase analysis), code-architect (architecture design), code-reviewer (issue identification)
- **Usage:** `/feature-dev` guides through explore → design → implement → review

### Superpowers — ★★★☆☆ (Methodology)

Structured software development methodology (TDD, brainstorming, code review).

- **Install:** `/plugin install superpowers@claude-plugins-official`
- **Commands:** `/brainstorming`, `/execute-plan`
- **Note:** Some overlap with Claude Code's built-in workflow

### Claude-MD-Management — ★★☆☆☆ (Optional)

Audits CLAUDE.md quality and captures session learnings.

- **Usage:** "audit my CLAUDE.md files" or `/revise-claude-md`
- **Note:** Basic auto-memory system may be sufficient

## Concepts

### OpenSpec (Spec-Driven Development)

Framework for defining "what" and "how" before writing code.

- Creates per-change folders (proposal, specs, design, tasks)
- `@/openspec/AGENTS.md` as single source of truth
- **Usage:** `/opsx:propose "your idea"`
- **Best for:** Team projects with complex specification management

### MEMORY.md (Auto-Memory System)

Claude Code's built-in session-to-session knowledge persistence.

- **Location:** `~/.claude/projects/<project>/memory/MEMORY.md`
- **Limit:** 200 lines (content beyond is not loaded)
- **Best practice:** MEMORY.md as concise index, details in separate files
- **Command:** `/memory`

## Selection Guide

| Scenario | Recommended |
|---|---|
| Solo development (practical) | Context7 + Language LSP |
| Feature-focused development | Context7 + LSP + Feature-Dev |
| Team / complex projects | Context7 + LSP + OpenSpec |

## Overlap Warning

- **Superpowers ↔ Feature-Dev:** Both provide structured dev workflows. Pick one.
- **Claude-MD-Management ↔ Auto-Memory:** Partially overlapping. Built-in memory is often enough.
