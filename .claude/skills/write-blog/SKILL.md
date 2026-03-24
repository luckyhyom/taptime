---
name: write-blog
description: Write a technical blog post about a specific phase or topic. Focuses on "why this choice" decisions with code examples from the project.
argument-hint: "<phase or topic, e.g. 'Phase B' or 'Platform Channel'>"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Agent
---

# Write Technical Blog Post

Write a "why" focused technical blog post based on actual project code and git history.

## Audience

Backend developer learning Flutter/mobile. Explain concepts clearly with code examples.

## Steps

1. **Gather context:**
   - Run `git log --oneline` filtered to the relevant phase/topic to identify commits
   - Read `PROGRESS.md` for the session summary of that phase
   - Read relevant `docs/adr/` files for architecture decisions
   - Read relevant `docs/issues/FEAT-*` files for feature context
   - Read the actual code files that were created/modified

2. **Identify the "why" decisions:**
   - What options were considered and rejected?
   - What constraints drove the design? (platform limits, performance, simplicity)
   - What patterns from the existing codebase were followed or broken?
   - What was surprising or non-obvious?

3. **Write the post to `docs/blog/YYYY-MM-DD-topic-slug.md`:**

   Format:
   ```markdown
   # [Title — one sentence describing the key insight]

   > YYYY-MM-DD | Taptime v2.1 Phase X

   ## Background
   (What problem were we solving? 2-3 sentences.)

   ## Key Decisions
   ### 1. [Decision title]
   (Why this choice? What was the alternative? Include actual project code.)

   ### 2. [Decision title]
   ...

   ## Code Walkthrough
   (Walk through 1-2 key code snippets from the actual project, explaining the "why" behind each part.)

   ## What I Learned
   (2-3 bullet points of transferable insights.)
   ```

   Rules:
   - Written in **Korean** (blog is for the user, not agents)
   - Code snippets from the **actual project** (not hypothetical examples)
   - Include file paths with code snippets so reader can find them
   - Focus on **decisions and trade-offs**, not step-by-step tutorials
   - Keep it concise — aim for 800-1500 words

4. **Report:**
   - Show the file path of the created blog post
   - List the key decisions covered

## Notes

- If `$ARGUMENTS` is empty, ask which phase/topic to write about
- If `$ARGUMENTS` is "all" or "catch-up", write posts for all phases that don't have one yet
- Check `docs/blog/` for existing posts to avoid duplicates
- Blog posts are for human readers — do NOT add them to agent-facing docs like INDEX.md
