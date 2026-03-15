# ADR-0007: Drift as Local Database (replacing Isar)

- **Status:** Accepted
- **Date:** 2026-03-15
- **Deciders:** User, Claude

## Context

Isar was originally selected as the local database (ADR-0001). During Phase 1 implementation, it was discovered that:

1. **Isar is abandoned** — no longer actively maintained
2. **Dependency conflicts** — `isar_generator` conflicts with `build_runner`, blocking code generation

A replacement was needed that supports type-safe queries, code generation, and the repository pattern for future Supabase migration.

## Decision

Use **Drift** (SQLite-based) as the local database.

## Rationale

- **Actively maintained** — regular releases, responsive maintainer
- **Type-safe queries** — compile-time checked SQL via Dart code generation
- **Reactive streams** — `watch()` queries integrate naturally with Riverpod
- **Migration support** — structured schema versioning for production upgrades
- **SQLite-based** — battle-tested storage engine, wide platform support
- **Isolate support** — heavy queries can run off the main thread

## Consequences

- Requires `build_runner` for code generation (same as Isar would have)
- SQL knowledge helpful but not required (Drift provides a Dart query API)
- Database file is a standard SQLite file (inspectable with external tools)
- `drift_flutter` package handles platform-specific SQLite bundling
