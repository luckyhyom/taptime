# ADR-0001: Flutter Local-First Architecture (No Backend)

- **Status:** Accepted
- **Date:** 2026-03-14

## Context

Initial plan included a NestJS + PostgreSQL backend with Docker. During system design discussion, we evaluated whether a separate backend server is justified for a personal time tracking app.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| NestJS + PostgreSQL | Full control, SQL queries, schema migrations | Over-engineered for personal app, dual storage + sync complexity, infra cost |
| Flutter + Supabase | Managed DB, built-in auth, no server to maintain | Adds online dependency, still needs offline support |
| Flutter + Isar (local-only) | Simplest, fully offline, no infra | No cross-device sync, data tied to device |

## Decision

Flutter + Isar (local-only) for MVP and foreseeable future. Supabase for cloud backup only if/when needed (v2.0).

## Rationale

- Data volume is small (~3,000 sessions/year) — Isar handles this easily
- Timer must work offline (subway, airplane) — local-first is the only option that guarantees this
- Adding a backend actually increases Flutter complexity (dual storage, sync logic, conflict resolution, network error handling)
- No sensitive data requiring server-side protection
- Repository pattern allows swapping Isar for Supabase later without touching UI

## Consequences

- No multi-device sync (acceptable for personal use)
- Data export/import (JSON) added to MVP as backup safety net
- Google Calendar integration will use client-side OAuth instead of server-mediated
