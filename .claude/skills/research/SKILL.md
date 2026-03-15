---
name: research
description: Search existing references first, then web search if needed. Use when investigating a technology, pattern, or best practice.
argument-hint: "<topic>"
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch, Write, Edit
---

# Research with Reference Check

Look up existing project references before performing new web searches.

## Steps

1. **Check existing references:**
   - Use `Grep` to search `docs/references/` for `$ARGUMENTS` and related keywords
   - If found, read the relevant reference file and present the information

2. **If not found or insufficient:**
   - Use `WebSearch` to find up-to-date information on the topic
   - Summarize findings for the user

3. **Save results:**
   - If the research produced useful new information, ask the user whether to save it
   - If yes, save to `docs/references/{topic-name}.md` with a consistent format:
     ```markdown
     # {Topic Title}

     > Researched: {date}

     ## Summary
     (Key findings)

     ## Details
     (Detailed information, comparisons, pros/cons)

     ## Sources
     (URLs or references)
     ```
   - Update `docs/INDEX.md` if a new reference file was created
