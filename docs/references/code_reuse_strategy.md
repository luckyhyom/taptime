# Code Reuse Strategy in Agentic Coding

> Researched: 2026-03-17
> Purpose: Strategies to prevent code duplication when working with AI coding agents

## Problem

GitClear research (211M lines analyzed): after AI adoption, **code cloning grew 4x** (8.3% → 12.3%), refactoring collapsed from 25% to <10% of changed lines. AI agents don't pause to check whether a function already exists — they produce output based on available context.

Source: [GitClear AI Copilot Code Quality 2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research)

## Key Insight

> "If your codebase follows consistent patterns, the agent will follow those patterns almost to a tee."
> — Simon Willison, [Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/)

A well-structured codebase is itself the best reuse enforcement mechanism.

## Strategies (by effort/impact)

### Low Effort, High Impact — Apply Now

**1. Explicit reuse instructions in CLAUDE.md**

Anthropic's official recommendation ([best-practices](https://code.claude.com/docs/en/best-practices)). CLAUDE.md is loaded every session. Keep under ~200 lines (LLMs follow ~150-200 instructions reliably).

Example rules:
- "Before creating new helpers, search `core/utils/` and `shared/`"
- "Reuse existing repository methods — check interfaces in `shared/repositories/`"

**2. Consistent codebase patterns**

LLMs are in-context learners. If existing code follows a pattern (e.g., Repository + _toModel/_toCompanion), the agent replicates it naturally.

**3. `/simplify` skill (already installed)**

Post-implementation review for reuse, quality, and efficiency. Catches duplication after writing.

### Medium Effort, High Impact — Apply When Project Grows

**4. DCM (Dart Code Metrics)**

Flutter-specific code quality tool with `check-code-duplication` command. Can be integrated as pre-commit hook or CI step.

- Site: [dcm.dev](https://dcm.dev/docs/cli/code-quality-checks/code-duplication/)
- Native Dart/Flutter support

**5. MCP Servers for codebase awareness**

| Server | Feature | Token Efficiency |
|--------|---------|-----------------|
| [codebase-optimizer-mcp](https://github.com/liadgez/codebase-optimizer-mcp) | `detect_code_duplicates` function | — |
| [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) | Knowledge graph of codebase | ~3,400 tokens vs ~412,000 |
| [code-index-mcp](https://github.com/johnhuang316/code-index-mcp) | Semantic search + symbol resolution | — |

### Higher Effort, Strategic — Plan for Later

**6. Multi-agent review pattern**

Spawn a subagent to search for existing code before writing new code. Claude Code supports this via [subagents](https://code.claude.com/docs/en/sub-agents).

**7. Code health metrics (CodeScene approach)**

Integrate objective quality signals as MCP tools. Agents lack reliable understanding of maintainability without external metrics.

Source: [CodeScene blog](https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality)

## Decision for Taptime

- **Now:** CLAUDE.md reuse rules + `/simplify` after implementation
- **Later (if needed):** DCM for automated duplication detection
- **Not needed yet:** MCP servers, multi-agent review (project is small)

## References

- [Anthropic — Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)
- [Simon Willison — Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/)
- [CodeScene — Agentic AI Best Practice Patterns](https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality)
- [Faros AI — DRY Principle and AI-Generated Code](https://www.faros.ai/blog/ai-generated-code-and-the-dry-principle)
- [Trail of Bits — claude-code-config](https://github.com/trailofbits/claude-code-config)
- [GitClear — AI Copilot Code Quality 2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research)
- [MIT Missing Semester — Agentic Coding (2026)](https://missing.csail.mit.edu/2026/agentic-coding/)
