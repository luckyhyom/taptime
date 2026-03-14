# ADR-0004: File-Based Issue Tracking

- **Status:** Accepted
- **Date:** 2026-03-14

## Context

Need a system to track bugs, features, and technical decisions. Options include hosted platforms (GitHub Issues, Linear) and file-based tracking within the repository.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| GitHub Issues | Web UI, PR/commit linking, labels, milestones | Online-only, not included in git clone, vendor lock-in |
| Linear | Fast UI, great workflow | Paid for teams, external dependency |
| File-based (docs/issues/) | Offline, versioned with code, AI agents can read directly, portable | No UI, manual search/filter |

## Decision

File-based issue tracking in `docs/issues/` with structured markdown templates.

## Rationale

- Offline-first matches our local-first app philosophy
- AI agents can glob and read issue files for immediate context
- Issues are versioned alongside the code that fixes them
- Can migrate to GitHub Issues later if needed
- Template includes technical analysis, security consideration, and test verification

## Consequences

- No web UI for browsing issues — rely on file explorer / grep
- Must maintain discipline in creating issue files
- Issue references in commits use `#ISSUE-NNN` format
