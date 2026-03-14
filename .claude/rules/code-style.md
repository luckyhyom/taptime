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

## Language

- All code, comments, and variable names in English
- UI strings: Korean (primary), English (secondary) — managed via localization
