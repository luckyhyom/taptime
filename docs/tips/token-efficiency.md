# Token Efficiency Tips

> How to manage documents and conversations to minimize AI token usage.

## Writing Language

- English uses ~1.5-2x fewer tokens than Korean for the same content
- AI output tokens cost 5x more than input tokens (Claude API pricing)
- Best practice: documents in English, conversation in user's preferred language

## File Placement by Read Frequency

| Location | When Loaded | Put Here |
|----------|------------|----------|
| `.claude/rules/` | Every session (auto) | Rules that must always be followed |
| `CLAUDE.md` | Every session (auto) | Workflow rules, keep under 200 lines |
| `docs/references/` | On demand (manual read) | Research materials, rarely referenced |
| `docs/adr/` | On demand (manual read) | Architecture decisions, read when relevant |

- **Do NOT** put large research documents in `.claude/rules/` — they load every session and waste tokens
- **Do** put concise, actionable rules in `.claude/rules/`

## Search vs Read

| Action | Token Cost |
|--------|-----------|
| Write a file | Minimal (one tool call) |
| Read a file | Proportional to file size |
| Web search + parse + summarize | **Most expensive** |

- Save research results to `docs/references/` — reading a saved file is much cheaper than re-searching
- Keep reference files focused — split large research into separate topic files

## Multilingual Documentation

- English originals are canonical (agents read these)
- `*_KO.md` files are Korean translations for human readers on GitHub
- Korean uses ~1.3-2.4x more tokens than English for the same content
- Translation is done on user request only (`/translate-docs`), not on every commit
- Each `_KO.md` file tracks the source commit hash for sync checking
- See `docs/tips/multilingual-docs.md` for full details

## Conversation Style

- User writes in Korean + AI responds in Korean: standard cost
- User writes in Korean + AI responds in English: **most cost-effective** (output is longer and more expensive, English output uses fewer tokens)
- Practical choice: use whatever language is most comfortable — optimize only if hitting usage limits
