---
name: flutter-verify
description: Run flutter analyze and flutter test in a sub-agent to keep main context clean. Use after writing code.
allowed-tools: Bash, Read, Grep
---

# Flutter Build Verification

Run static analysis and tests in an isolated context, then report only the issues.

## Steps

1. **Run `flutter analyze`:**
   - Execute `flutter analyze` from the project root
   - Collect any errors, warnings, or info messages

2. **Run `flutter test`** (if test files exist):
   - Execute `flutter test` from the project root
   - Collect any test failures

3. **Report:**
   - If all clean: "No issues found."
   - If issues exist: list each with file path, line number, and message
   - Group by severity: errors first, then warnings
   - Do NOT include the full raw output — summarize concisely
