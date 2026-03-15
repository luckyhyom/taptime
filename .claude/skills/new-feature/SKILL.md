---
name: new-feature
description: Create a new FEAT file from template and update PLAN.md. Use when starting implementation of a new feature.
argument-hint: "<feature-name> [description]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# New Feature Registration

Create a FEAT issue file and update PLAN.md for a new feature.

## Steps

1. **Read current state:**
   - Read `docs/issues/TEMPLATE.md` for the issue template format
   - Read `PLAN.md` to find where this feature belongs
   - Use `Glob` on `docs/issues/FEAT-*.md` to determine the next number (FEAT-NNN)

2. **Create FEAT file:**
   - File path: `docs/issues/FEAT-{NNN}_{$ARGUMENTS}.md`
   - Convert `$ARGUMENTS` to kebab-case for the filename
   - Fill in the template with:
     - Type: `feature`
     - Priority: ask the user if not provided
     - Status: `open`
     - Created: today's date
   - Leave Solution, Test, and Takeaway sections empty (to be filled during/after implementation)

3. **Update PLAN.md:**
   - Add the task to the appropriate phase if not already listed
   - Format: `- [ ] {description} (FEAT-{NNN})`

4. **Report:**
   - Show the created file path
   - Show where it was added in PLAN.md
