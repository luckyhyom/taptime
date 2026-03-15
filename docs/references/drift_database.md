# Drift — Local Database for Flutter

> Research date: 2026-03-15
>
> Sources:
> - [Drift official docs](https://drift.simonbinder.eu/)
> - [drift on pub.dev](https://pub.dev/packages/drift)
> - [drift_flutter on pub.dev](https://pub.dev/packages/drift_flutter)
> - [drift_dev on pub.dev](https://pub.dev/packages/drift_dev)
> - [Drift Setup guide](https://drift.simonbinder.eu/setup/)
> - [Drift Tables reference](https://drift.simonbinder.eu/dart_api/tables/)
> - [Drift Migrations guide](https://drift.simonbinder.eu/migrations/)
> - [Drift Isolates](https://drift.simonbinder.eu/isolates/)

## Overview

Drift is a reactive, type-safe persistence library for Flutter and Dart, built on top of SQLite. It generates type-safe Dart code from table definitions, turning database rows into typed objects. Drift works on Android, iOS, macOS, Windows, Linux, and the web.

Key selling points:

- **Type-safe queries** — compile-time verification of SQL, no raw `Map<String, dynamic>` parsing
- **Reactive streams** — any query can be turned into an auto-updating `Stream` with zero extra effort
- **Built-in threading** — run database operations across isolates out of the box
- **Schema migrations** — tooling to generate and test migrations automatically
- **Dart API and SQL API** — define tables in Dart or write verified `.drift` SQL files

## Dependencies

As of 2026-03-15, latest stable versions:

```yaml
# pubspec.yaml

dependencies:
  drift: ^2.32.0
  drift_flutter: ^0.3.0       # bundles SQLite for Flutter, handles platform setup
  path_provider: ^2.1.5       # needed for database file location

dev_dependencies:
  drift_dev: ^2.32.0          # code generator
  build_runner: ^2.11.1       # runs the code generator
```

Note: `drift` and `drift_dev` versions should always match (same minor version).

## Setup Pattern

### 1. Define tables

Each table is a Dart class extending `Table`. Columns are defined as getters ending with an extra pair of parentheses:

```dart
// lib/database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get content => text().named('body')();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
}
```

### 2. Create the database class

Annotate with `@DriftDatabase` and list all tables:

```dart
@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
```

### 3. Run code generation

```bash
# Generate once
dart run build_runner build

# Watch mode (re-generates on file changes)
dart run build_runner watch
```

This produces `database.g.dart` with all generated code.

### 4. Optional: build.yaml configuration

For SQLite-only Flutter apps, no `build.yaml` is needed. For PostgreSQL or custom options:

```yaml
# build.yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            my_database: lib/database.dart   # needed for make-migrations
```

## Key Features

### Column types

| Dart type    | Drift column   | SQL type          |
|--------------|----------------|-------------------|
| `int`        | `integer()`    | INTEGER           |
| `BigInt`     | `int64()`      | INTEGER           |
| `String`     | `text()`       | TEXT              |
| `bool`       | `boolean()`    | INTEGER (0/1)     |
| `double`     | `real()`       | REAL              |
| `Uint8List`  | `blob()`       | BLOB              |
| `DateTime`   | `dateTime()`   | INTEGER or TEXT    |
| Custom       | type converter | varies             |

### Column modifiers

- `nullable()` — allow NULL (non-nullable by default)
- `withDefault(expr)` — database-level default via SQL expression
- `clientDefault(fn)` — Dart-computed default (no migration needed when added)
- `unique()` — uniqueness constraint
- `check(expr)` — validation constraint
- `withLength(min, max)` — text length constraint
- `autoIncrement()` — auto-incrementing primary key
- `references(OtherTable, #column)` — foreign key with optional `onUpdate`/`onDelete`
- `named('sql_name')` — explicit SQL column name
- `generatedAs(expr)` — computed/virtual column

### Primary keys

```dart
// Auto-increment (most common)
IntColumn get id => integer().autoIncrement()();

// Custom primary key
@override
Set<Column<Object>> get primaryKey => {email};
```

### Foreign keys

```dart
class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get artist => integer().references(Artists, #id)();
}
```

Note: foreign keys require `PRAGMA foreign_keys = ON` in SQLite. Enable it in `beforeOpen`:

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
```

### Indexes

```dart
@TableIndex(name: 'user_name', columns: {#name})
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}
```

### Reactive streams (watch queries)

Any query can become a stream that auto-updates when underlying data changes:

```dart
// Single query
final todos = await (select(todoItems)..where((t) => t.completed.equals(false))).get();

// As a reactive stream
final todosStream = (select(todoItems)..where((t) => t.completed.equals(false))).watch();
```

### Isolate support

Drift can run database operations on a background isolate with no extra setup. The `driftDatabase()` helper from `drift_flutter` handles this automatically.

### Transactions and batches

```dart
await transaction(() async {
  await into(todoItems).insert(item1);
  await into(todoItems).insert(item2);
});

await batch((b) {
  b.insertAll(todoItems, [item1, item2, item3]);
});
```

### Schema migrations

Drift provides `make-migrations` tooling for safe, testable migrations:

```bash
# 1. Add databases to build.yaml (see above)
# 2. Generate initial schema snapshot
dart run drift_dev make-migrations

# 3. After changing tables, bump schemaVersion and run again
dart run drift_dev make-migrations
```

This generates step-by-step migration files:

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: stepByStep(
    from1To2: (m, schema) async {
      await m.createTable(schema.newTable);
    },
    from2To3: (m, schema) async {
      await m.addColumn(schema.todoItems, schema.todoItems.priority);
    },
  ),
);
```

## Gotchas & Best Practices

### Gotchas

1. **Extra parentheses required** — every column definition must end with `()()`. The first creates the column builder, the second finalizes it. Forgetting the trailing `()` causes confusing compile errors.

2. **Don't query in migration callbacks** — drift expects the latest schema when using high-level query APIs (`select`, `update`, etc.). Inside migration callbacks, the schema is in a transitional state. Use raw `customStatement()` for data manipulation during migrations instead.

3. **Android database backup** — Android may back up the database file and restore it on reinstall. Uninstalling the app is not always enough to reset the database during development. Clear app data explicitly or use `adb` to remove the file.

4. **Foreign keys are OFF by default** — SQLite does not enforce foreign keys unless you explicitly enable them with `PRAGMA foreign_keys = ON` in the `beforeOpen` callback.

5. **DateTime storage** — by default, drift stores `DateTime` as Unix timestamps (INTEGER). If you need text format or timezone awareness, configure it explicitly.

6. **Generated file conflicts** — running `build_runner build` while `watch` is active can cause conflicts. Use one or the other.

### Best practices

1. **Use `make-migrations` over manual migrations** — manually writing migration callbacks is error-prone. The `make-migrations` command generates both migration code and tests automatically.

2. **Export schema snapshots before changing tables** — drift's code generator only sees the current schema. Always run `make-migrations` before modifying tables so the previous schema is preserved for comparison.

3. **Index frequently queried columns** — especially columns used in `WHERE` clauses or joins. Use `@TableIndex` annotation.

4. **Use `clientDefault` for Dart-side defaults** — unlike `withDefault` (SQL-level), `clientDefault` does not require a migration when added to an existing column.

5. **Avoid N+1 queries** — use joins or batch operations instead of querying in loops.

6. **Keep database as a singleton** — instantiate `AppDatabase` once (e.g., via Riverpod provider) and reuse it throughout the app. Opening multiple connections to the same database file causes issues.

7. **Use transactions for multi-step writes** — wrap related inserts/updates in `transaction()` for atomicity and better performance.

8. **Test migrations** — drift can generate migration test scaffolding via `make-migrations`. Use it to verify that upgrades from every previous version work correctly.

9. **Provide the database via DI** — pass `QueryExecutor` to the constructor so tests can use an in-memory database:
   ```dart
   // In tests
   final db = AppDatabase(NativeDatabase.memory());
   ```
