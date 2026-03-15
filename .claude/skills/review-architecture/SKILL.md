---
name: review-architecture
description: Verify code changes comply with architecture rules. Use before committing feature code to check layer boundaries, folder structure, and naming conventions.
argument-hint: "[feature-name or file-path]"
allowed-tools: Read, Glob, Grep
---

# Architecture Compliance Review

Check that code follows the project's architecture rules.

## Steps

1. **Load rules:**
   - Read `.claude/rules/architecture.md` for layer and folder structure rules
   - Read `.claude/rules/code-style.md` for naming and style rules

2. **Identify scope:**
   - If `$ARGUMENTS` is provided, review that feature or file
   - If not, use `Bash` to find recently modified `.dart` files

3. **Check compliance:**

   **Layer boundaries:**
   - UI files must NOT import from `data/` directly (must go through shared interfaces)
   - Data files must NOT import from `ui/`
   - Shared models must NOT import from features

   **Folder structure:**
   - Files are in the correct feature directory
   - `data/` and `ui/` separation within features
   - Shared code is in `lib/shared/`, not duplicated

   **Naming:**
   - Files: snake_case
   - Classes: PascalCase
   - Screen files end with `_screen.dart`
   - Provider files end with `_providers.dart`
   - Repository implementations end with `_repository_impl.dart`

   **Import order:**
   - Dart SDK → Flutter → External packages → Project imports

4. **Report:**
   - List any violations found with file path and line number
   - Suggest fixes for each violation
   - If all clear, confirm compliance
