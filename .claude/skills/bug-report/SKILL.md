---
name: bug-report
description: Create a new BUG file from template. Use when a bug is discovered during development or testing.
argument-hint: "<bug-name> [description]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Bug Report Registration

Create a BUG issue file for tracking and resolution.

## Steps

1. **Read current state:**
   - Read `docs/issues/TEMPLATE.md` for the issue template format
   - Use `Glob` on `docs/issues/BUG-*.md` to determine the next number (BUG-NNN)

2. **Create BUG file:**
   - File path: `docs/issues/BUG-{NNN}_{$ARGUMENTS}.md`
   - Convert `$ARGUMENTS` to kebab-case for the filename
   - Fill in the template with:
     - Type: `bug`
     - Status: `open`
     - Created: today's date
   - Include Steps to Reproduce and Expected vs Actual sections
   - Fill Technical Analysis if the cause is known
   - Fill Security Consideration section

3. **Report:**
   - Show the created file path
   - Summarize the bug and its severity
