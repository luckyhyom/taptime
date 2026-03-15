# Subagents & Plan Mode — When to Use

> Created: 2026-03-15

## Subagent Types

| Agent | What It Does | When to Use |
|-------|-------------|-------------|
| **Explore** | Fast codebase search (files, keywords) | After codebase grows (Phase 2+). For small codebases, Glob/Grep is faster |
| **Plan** | Architecture design, implementation strategy | Before complex implementations spanning multiple files |
| **docs-researcher** (Context7) | Library documentation lookup | When referencing library docs (Drift, Riverpod, etc.) without polluting main context |
| **general-purpose** | Multi-step complex tasks | Independent research, multi-file exploration |

### Tips

- For small codebases, direct tool usage (Glob/Grep/Read) is faster than spawning subagents
- Subagents are most useful when parallelizing independent tasks
- docs-researcher saves main context window tokens by fetching library docs in a separate context

## Plan Mode

### What It Is

A design-first mode before implementation. Code modification/creation is disabled — only reading and searching are available. Think "draw the blueprint before building."

### When to Use

1. **Before large features spanning multiple files** — e.g., folder structure + theme + router + DB all at once
2. **When architecture decisions are needed** — e.g., DB table structure, provider wiring strategy
3. **When file dependencies are complex** — wrong ordering breaks the build

### When NOT to Use

- Single file modifications (dependency swap, doc updates)
- Straightforward tasks (file creation, config changes)
- Simple tasks already detailed in PLAN.md

### Cautions

- **Avoid overuse** — plan mode on simple tasks wastes time
- **Plan ≠ guaranteed execution** — changes may arise during implementation; don't be rigid
- **Token consumption** — plan mode exploration consumes tokens too, but it's far cheaper than implementing in the wrong direction and reverting
