# ADR-0003: Riverpod for State Management

- **Status:** Accepted
- **Date:** 2026-03-14

## Context

Flutter offers multiple state management solutions. Need to choose one that fits a solo developer building a small-to-medium app.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Riverpod | Type-safe, compile-time checks, no BuildContext dependency, great testing, less boilerplate | Steeper initial learning curve |
| BLoC/Cubit | Mature, predictable, strict pattern | Boilerplate heavy (Event + State + BLoC per feature), overkill for this scale |
| Provider | Simple, official Flutter recommendation | Less type-safe, context-dependent, being superseded by Riverpod |
| GetX | Minimal boilerplate | Poor testability, implicit magic, not recommended by community |

## Decision

Riverpod (latest stable).

## Rationale

- Less boilerplate than BLoC for a solo developer
- Type-safe providers catch errors at compile time
- No BuildContext dependency — logic can be tested without widget tree
- Natural fit for dependency injection (repository interfaces → implementations)
- Active development with Riverpod 3.0 (September 2025)

## Consequences

- Must learn Riverpod's provider model (Provider, StateNotifier, AsyncValue)
- Code generation with `riverpod_generator` recommended for less boilerplate
- All state management is consistent across features
