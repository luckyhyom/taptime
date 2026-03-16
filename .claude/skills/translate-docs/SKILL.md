---
description: Update all outdated Korean translation files (_KO.md). Compares commit hashes to skip up-to-date translations.
---

# Translate Docs

Update Korean translations for all translatable documents.

## Steps

1. Get the list of translatable files from `docs/tips/multilingual-docs.md` (the "What Gets Translated" table)

2. For each translatable file, check if translation is outdated:
   ```bash
   # Get current commit hash of the English original
   git log --format="%h" -1 -- <original_file>

   # Read only the first line of the _KO file to get the tracked hash
   head -1 <ko_file>
   ```
   - If the hashes match → skip (already up to date)
   - If the hashes differ or _KO file doesn't exist → needs translation

3. For files that need translation:
   - Read the English original
   - Create/update the `_KO.md` file with:
     - `<!-- translated from: <filename> @ commit <hash> (<date>) -->` as the first line
     - Full Korean translation of the content
   - Preserve all code blocks, file paths, and technical terms in English

4. Report summary:
   - How many files checked
   - How many skipped (up to date)
   - How many translated/updated
   - Total tokens saved by skipping

## Important

- Never modify the English originals
- Preserve markdown formatting exactly
- Keep code blocks, file paths, command examples in English
- Technical terms (Repository, ViewModel, Riverpod, etc.) stay in English
