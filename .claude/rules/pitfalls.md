# Pitfalls

> Known mistakes and rules to prevent them. All agents must check this file.
> Add new entries when mistakes are discovered.

---

## DON'T: Delete user-created files without asking

- **Found:** 2026-03-14
- **Context:** Tried to delete empty LEARNING.md assuming it was unnecessary
- **Rule:** Never delete files the user created, even if empty. Ask first.

## DON'T: Modify documents without explaining changes first

- **Found:** 2026-03-14
- **Context:** Attempted to rewrite CLAUDE.md without summarizing what would change
- **Rule:** Summarize all planned changes and get approval before writing.

## DON'T: Auto-record conversation logs

- **Found:** 2026-03-14
- **Context:** Automatically wrote to conversations/LOG.md without being asked
- **Rule:** Only write to `docs/conversations/LOG.md` when the user explicitly requests it.

## DON'T: Assume architecture without checking current decisions

- **Found:** 2026-03-14
- **Context:** Documents referenced 3-layer Clean Architecture after it was changed to 2-layer MVVM
- **Rule:** Always check `docs/adr/` and `.claude/rules/architecture.md` for current architecture decisions before writing code or documents.

## DON'T: Write duplicate content across documents

- **Found:** 2026-03-14
- **Context:** README.md had project structure, tech stack, and other info already in INDEX.md and other docs
- **Rule:** Keep documents focused on their single purpose. Link to other documents instead of duplicating content.

## DON'T: Add your own summaries to conversation logs

- **Found:** 2026-03-14
- **Context:** Added discussion summaries and decision notes to LOG.md when user only wanted their own words recorded
- **Rule:** Conversation log records user's original words only. Do not add agent summaries or analysis.

## DON'T: Write .md documents in Korean

- **Found:** 2026-03-15
- **Context:** Wrote tips file with Korean descriptions despite CLAUDE.md rule requiring all .md documents in English
- **Rule:** All `.md` documents must be written in English. The only exception is user's original input recorded under "Original" sections in conversation logs and planning changelog.

## DON'T: Commit secrets or credentials to git

- **Found:** 2026-03-22
- **Context:** Supabase anon key was hardcoded in `supabase_config.dart` and nearly committed
- **Rule:** Never hardcode API keys, tokens, or credentials in source files. Use `.env` + `--dart-define-from-file` for secrets. Always verify `.gitignore` covers `.env`, `*.jks`, `*.keystore`, `google-services.json`, `GoogleService-Info.plist`. Before committing, check `git diff` for any credential-like strings.

## DON'T: Display secrets in tool output or conversation

- **Found:** 2026-03-22
- **Context:** Supabase API keys were printed in full via CLI command output
- **Rule:** When running commands that output secrets (API keys, tokens, passwords), warn the user. Avoid printing full key values. If keys are accidentally exposed, recommend rotation.

## DO: Record progress before ending a session

- **Found:** 2026-03-15
- **Context:** Risk of losing uncommitted decisions and context when a session ends unexpectedly
- **Rule:** When a significant decision is made or work context changes (even without code to commit), immediately update PROGRESS.md. Don't wait for a commit to record decisions, blockers, or context that the next agent would need.
