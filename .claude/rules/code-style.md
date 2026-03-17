# Code Style

## Linter

- Use `very_good_analysis` as base lint rules
- Custom overrides in `analysis_options.yaml` as needed

## Dart Conventions

- Formatter: `dart format` with line length 120
- Prefer `final` over `var`, `const` constructors where possible
- Avoid `dynamic` — always specify types explicitly
- Use trailing commas for multi-line argument lists
- Use single quotes (`'`) for strings
- One public class per file (private helpers in same file OK)
- Max function length: aim for < 30 lines; extract if longer
- No commented-out code in commits

## Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Files | snake_case | `timer_screen.dart` |
| Classes | PascalCase | `TimerScreen` |
| Variables / functions | camelCase | `startTimer()` |
| Constants | camelCase | `defaultDuration` |
| Private members | _prefix | `_isRunning` |
| Enums | PascalCase values | `SessionStatus.completed` |

## Import Order

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. External packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Project imports
import 'package:taptime/features/timer/ui/timer_screen.dart';
```

## Comments

### Language

- Comments and doc comments: **Korean**
- Code, variable names, class names: **English**
- UI strings: Korean (primary), English (secondary) — managed via localization

### Detail Level

Comments target **"a developer seeing this codebase for the first time."**
Explain enough to understand the intent and design, but don't explain what the code literally does.

| Level | When | Example |
|-------|------|---------|
| **Why** (default) | Design decisions, trade-offs, non-obvious choices | `// UUID를 쓰는 이유: 클라우드 동기화 시 기기 간 충돌 방지` |
| **What** | Framework/library magic that isn't readable from code alone | `// clientDefault: Dart 코드에서 기본값을 제공한다 (SQL 레벨 withDefault와 달리 마이그레이션 불필요)` |
| **None** | Self-explanatory code | `final rows = await query.get();` ← no comment needed |

### Doc Comments (`///`)

For **public API** — classes, fields, methods exposed to other files.

```dart
/// 프리셋(활동 템플릿) 모델.
///
/// 사용자가 만드는 타이머 활동의 설정을 담는 불변(immutable) 클래스.
/// 이 클래스는 Drift(DB)와 완전히 독립된 순수 Dart 클래스이다.
@immutable
class Preset {
  /// 타이머 시간 (분 단위, 1~180)
  final int durationMin;
```

Rules:
- First line: one-sentence summary
- Blank `///` line, then details (if needed)
- Fields: single-line `///` with unit/range/constraint info
- Private members (`_`): doc comment not required, use `//` if needed

### Inline Comments (`//`)

For **implementation details** inside methods — reasoning, gotchas, library specifics.

```dart
// 하루치 세션은 소량(수십 건 이하)이므로
// SQL GROUP BY 대신 Dart에서 집계하여 가독성을 높인다.
final sessions = await getSessionsByDate(date);
```

Rules:
- Comment goes **above** the relevant code, not to the right
- Multi-line inline comments: each line starts with `//`
- No `/* */` block comments

### Section Dividers

For grouping related members inside a class (3+ sections).

```dart
// ── 조회 ───────────────────────────────────────────────────

// ── 쓰기 ───────────────────────────────────────────────────

// ── 변환 ───────────────────────────────────────────────────
```

Format: `// ── LABEL ──` + dashes to ~64 chars. Korean labels. Blank line after divider.

### What NOT to Comment

- Code that reads like prose (`return rows.map(_toModel).toList()`)
- Getter/setter without logic
- Override methods whose behavior is obvious from the interface
- Commented-out code — delete it, git has history
