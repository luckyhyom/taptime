# ADR-0002: 2-Layer MVVM + Repository Pattern (Over Full Clean Architecture)

- **Status:** Accepted
- **Date:** 2026-03-14

## Context

Needed to decide the app architecture level. Options ranged from no formal architecture to full Clean Architecture with 3 layers (presentation/domain/data).

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Full Clean Architecture (3-layer) | Maximum separation, testable, swappable | 8-12 files per feature, Use Cases often pass-through, over-engineered for 1-dev team |
| 2-Layer MVVM + Repository | Flutter official recommendation, less boilerplate, sufficient separation | Less strict boundaries, may need refactoring if complexity grows |
| No formal architecture | Fastest to start | Unmaintainable as app grows |

## Decision

2-Layer (UI + Data) with MVVM pattern and Repository interfaces. Feature-first folder structure. Add Domain layer per-feature only when complexity demands it.

## Rationale

- Flutter official architecture guide (2025) recommends 2 layers
- Full Clean Architecture's Use Cases are mostly pass-through for this app's complexity
- Feature-first keeps related files co-located
- Repository pattern still enables infrastructure swapping (Isar → Supabase)
- DDD concepts (Entity, Value Object) adopted selectively without formal DDD overhead

## Consequences

- Simpler codebase, faster development
- If a feature becomes complex, a domain sublayer can be added inside that feature only
- Team onboarding (if ever needed) requires less architectural knowledge
