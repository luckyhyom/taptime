// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PresetsTable extends Presets with TableInfo<$PresetsTable, PresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyGoalMinMeta = const VerificationMeta(
    'dailyGoalMin',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMin = GeneratedColumn<int>(
    'daily_goal_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    durationMin,
    icon,
    color,
    dailyGoalMin,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PresetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('daily_goal_min')) {
      context.handle(
        _dailyGoalMinMeta,
        dailyGoalMin.isAcceptableOrUnknown(
          data['daily_goal_min']!,
          _dailyGoalMinMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PresetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      dailyGoalMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_min'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $PresetsTable createAlias(String alias) {
    return $PresetsTable(attachedDatabase, alias);
  }
}

class PresetRow extends DataClass implements Insertable<PresetRow> {
  final String id;
  final String name;

  /// 타이머 시간 (분 단위)
  final int durationMin;

  /// 아이콘 식별자 (예: 'menu_book') — AppConstants.presetIcons의 키
  final String icon;

  /// 색상 hex 문자열 (예: '#4A90D9')
  final String color;

  /// 일일 목표 시간 (분 단위, 0이면 목표 없음)
  final int dailyGoalMin;

  /// 홈 화면 그리드에서의 정렬 순서
  final int sortOrder;

  /// clientDefault: Dart 코드에서 기본값을 제공한다.
  /// withDefault(SQL 레벨)과 달리 기존 테이블에 컬럼을 추가할 때
  /// 마이그레이션이 필요 없다는 장점이 있다.
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 소프트 삭제 시각. null이면 활성 상태, non-null이면 삭제됨.
  final DateTime? deletedAt;

  /// 동기화 상태: 'synced' 또는 'pending'
  final String syncStatus;

  /// 마지막으로 클라우드와 동기화된 시각
  final DateTime? lastSyncedAt;
  const PresetRow({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.icon,
    required this.color,
    required this.dailyGoalMin,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['duration_min'] = Variable<int>(durationMin);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['daily_goal_min'] = Variable<int>(dailyGoalMin);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  PresetsCompanion toCompanion(bool nullToAbsent) {
    return PresetsCompanion(
      id: Value(id),
      name: Value(name),
      durationMin: Value(durationMin),
      icon: Value(icon),
      color: Value(color),
      dailyGoalMin: Value(dailyGoalMin),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory PresetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PresetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      dailyGoalMin: serializer.fromJson<int>(json['dailyGoalMin']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'durationMin': serializer.toJson<int>(durationMin),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'dailyGoalMin': serializer.toJson<int>(dailyGoalMin),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  PresetRow copyWith({
    String? id,
    String? name,
    int? durationMin,
    String? icon,
    String? color,
    int? dailyGoalMin,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => PresetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    durationMin: durationMin ?? this.durationMin,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    dailyGoalMin: dailyGoalMin ?? this.dailyGoalMin,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  PresetRow copyWithCompanion(PresetsCompanion data) {
    return PresetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      dailyGoalMin: data.dailyGoalMin.present
          ? data.dailyGoalMin.value
          : this.dailyGoalMin,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PresetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('durationMin: $durationMin, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('dailyGoalMin: $dailyGoalMin, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    durationMin,
    icon,
    color,
    dailyGoalMin,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PresetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.durationMin == this.durationMin &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.dailyGoalMin == this.dailyGoalMin &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class PresetsCompanion extends UpdateCompanion<PresetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> durationMin;
  final Value<String> icon;
  final Value<String> color;
  final Value<int> dailyGoalMin;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const PresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.dailyGoalMin = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PresetsCompanion.insert({
    required String id,
    required String name,
    required int durationMin,
    required String icon,
    required String color,
    this.dailyGoalMin = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       durationMin = Value(durationMin),
       icon = Value(icon),
       color = Value(color);
  static Insertable<PresetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? durationMin,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? dailyGoalMin,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (durationMin != null) 'duration_min': durationMin,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (dailyGoalMin != null) 'daily_goal_min': dailyGoalMin,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? durationMin,
    Value<String>? icon,
    Value<String>? color,
    Value<int>? dailyGoalMin,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return PresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMin: durationMin ?? this.durationMin,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      dailyGoalMin: dailyGoalMin ?? this.dailyGoalMin,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (dailyGoalMin.present) {
      map['daily_goal_min'] = Variable<int>(dailyGoalMin.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('durationMin: $durationMin, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('dailyGoalMin: $dailyGoalMin, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES presets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    presetId,
    startedAt,
    endedAt,
    durationSeconds,
    status,
    memo,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;

  /// 외래키: 이 세션이 속한 프리셋의 id.
  /// references()로 외래키 관계를 선언한다.
  /// onDelete: KeyAction.cascade → 프리셋 삭제 시 관련 세션도 함께 삭제된다.
  final String presetId;
  final DateTime startedAt;
  final DateTime endedAt;

  /// 실제 소요 시간 (초 단위)
  final int durationSeconds;

  /// 'completed' 또는 'stopped' — SessionStatus enum과 대응
  final String status;

  /// 선택적 메모
  final String? memo;
  final DateTime createdAt;

  /// 마지막 수정 시각. 동기화 시 충돌 해결에 사용.
  final DateTime updatedAt;

  /// 소프트 삭제 시각. null이면 활성 상태, non-null이면 삭제됨.
  final DateTime? deletedAt;

  /// 동기화 상태: 'synced' 또는 'pending'
  final String syncStatus;

  /// 마지막으로 클라우드와 동기화된 시각
  final DateTime? lastSyncedAt;
  const SessionRow({
    required this.id,
    required this.presetId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.status,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['preset_id'] = Variable<String>(presetId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      presetId: Value(presetId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      durationSeconds: Value(durationSeconds),
      status: Value(status),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      presetId: serializer.fromJson<String>(json['presetId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      status: serializer.fromJson<String>(json['status']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'presetId': serializer.toJson<String>(presetId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'status': serializer.toJson<String>(status),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    String? presetId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? status,
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SessionRow(
    id: id ?? this.id,
    presetId: presetId ?? this.presetId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    status: status ?? this.status,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      status: data.status.present ? data.status.value : this.status,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('status: $status, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    presetId,
    startedAt,
    endedAt,
    durationSeconds,
    status,
    memo,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.presetId == this.presetId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.status == this.status &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> presetId;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<int> durationSeconds;
  final Value<String> status;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.presetId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.status = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String presetId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,
    required String status,
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       presetId = Value(presetId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       durationSeconds = Value(durationSeconds),
       status = Value(status);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? presetId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<String>? status,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (presetId != null) 'preset_id': presetId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (status != null) 'status': status,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? presetId,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<int>? durationSeconds,
    Value<String>? status,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('status: $status, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTableTable extends UserSettingsTable
    with TableInfo<$UserSettingsTableTable, UserSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vibrationEnabledMeta = const VerificationMeta(
    'vibrationEnabled',
  );
  @override
  late final GeneratedColumn<bool> vibrationEnabled = GeneratedColumn<bool>(
    'vibration_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    soundEnabled,
    vibrationEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    }
    if (data.containsKey('vibration_enabled')) {
      context.handle(
        _vibrationEnabledMeta,
        vibrationEnabled.isAcceptableOrUnknown(
          data['vibration_enabled']!,
          _vibrationEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      vibrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration_enabled'],
      )!,
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }
}

class UserSettingsRow extends DataClass implements Insertable<UserSettingsRow> {
  final int id;

  /// 'light', 'dark', 'system' 중 하나
  final String themeMode;
  final bool soundEnabled;
  final bool vibrationEnabled;
  const UserSettingsRow({
    required this.id,
    required this.themeMode,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['vibration_enabled'] = Variable<bool>(vibrationEnabled);
    return map;
  }

  UserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsTableCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      soundEnabled: Value(soundEnabled),
      vibrationEnabled: Value(vibrationEnabled),
    );
  }

  factory UserSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      vibrationEnabled: serializer.fromJson<bool>(json['vibrationEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'vibrationEnabled': serializer.toJson<bool>(vibrationEnabled),
    };
  }

  UserSettingsRow copyWith({
    int? id,
    String? themeMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) => UserSettingsRow(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
  );
  UserSettingsRow copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      vibrationEnabled: data.vibrationEnabled.present
          ? data.vibrationEnabled.value
          : this.vibrationEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, themeMode, soundEnabled, vibrationEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.soundEnabled == this.soundEnabled &&
          other.vibrationEnabled == this.vibrationEnabled);
}

class UserSettingsTableCompanion extends UpdateCompanion<UserSettingsRow> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<bool> soundEnabled;
  final Value<bool> vibrationEnabled;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
  });
  static Insertable<UserSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? soundEnabled,
    Expression<bool>? vibrationEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (vibrationEnabled != null) 'vibration_enabled': vibrationEnabled,
    });
  }

  UserSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? themeMode,
    Value<bool>? soundEnabled,
    Value<bool>? vibrationEnabled,
  }) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (vibrationEnabled.present) {
      map['vibration_enabled'] = Variable<bool>(vibrationEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled')
          ..write(')'))
        .toString();
  }
}

class $ActiveTimersTable extends ActiveTimers
    with TableInfo<$ActiveTimersTable, ActiveTimerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveTimersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES presets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pausedDurationSecondsMeta =
      const VerificationMeta('pausedDurationSeconds');
  @override
  late final GeneratedColumn<int> pausedDurationSeconds = GeneratedColumn<int>(
    'paused_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remainingSecondsMeta = const VerificationMeta(
    'remainingSeconds',
  );
  @override
  late final GeneratedColumn<int> remainingSeconds = GeneratedColumn<int>(
    'remaining_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    presetId,
    startedAt,
    pausedDurationSeconds,
    isPaused,
    pausedAt,
    remainingSeconds,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_timers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveTimerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('paused_duration_seconds')) {
      context.handle(
        _pausedDurationSecondsMeta,
        pausedDurationSeconds.isAcceptableOrUnknown(
          data['paused_duration_seconds']!,
          _pausedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('remaining_seconds')) {
      context.handle(
        _remainingSecondsMeta,
        remainingSeconds.isAcceptableOrUnknown(
          data['remaining_seconds']!,
          _remainingSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingSecondsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActiveTimerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveTimerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      pausedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_duration_seconds'],
      )!,
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
      remainingSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_seconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ActiveTimersTable createAlias(String alias) {
    return $ActiveTimersTable(attachedDatabase, alias);
  }
}

class ActiveTimerRow extends DataClass implements Insertable<ActiveTimerRow> {
  /// 항상 'singleton' — 단일행 패턴
  final String id;

  /// 외래키: 이 타이머가 실행 중인 프리셋의 id.
  /// 프리셋이 삭제되면 활성 타이머도 함께 삭제된다.
  final String presetId;

  /// 타이머가 최초로 시작된 시각
  final DateTime startedAt;

  /// 지금까지 누적된 일시정지 시간 (초 단위)
  final int pausedDurationSeconds;

  /// 현재 일시정지 상태인지 여부
  final bool isPaused;

  /// 현재 일시정지가 시작된 시각 (running이면 null)
  final DateTime? pausedAt;

  /// 마지막 저장 시점의 남은 시간 (초 단위)
  final int remainingSeconds;
  final DateTime createdAt;
  const ActiveTimerRow({
    required this.id,
    required this.presetId,
    required this.startedAt,
    required this.pausedDurationSeconds,
    required this.isPaused,
    this.pausedAt,
    required this.remainingSeconds,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['preset_id'] = Variable<String>(presetId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['paused_duration_seconds'] = Variable<int>(pausedDurationSeconds);
    map['is_paused'] = Variable<bool>(isPaused);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    map['remaining_seconds'] = Variable<int>(remainingSeconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActiveTimersCompanion toCompanion(bool nullToAbsent) {
    return ActiveTimersCompanion(
      id: Value(id),
      presetId: Value(presetId),
      startedAt: Value(startedAt),
      pausedDurationSeconds: Value(pausedDurationSeconds),
      isPaused: Value(isPaused),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      remainingSeconds: Value(remainingSeconds),
      createdAt: Value(createdAt),
    );
  }

  factory ActiveTimerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveTimerRow(
      id: serializer.fromJson<String>(json['id']),
      presetId: serializer.fromJson<String>(json['presetId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      pausedDurationSeconds: serializer.fromJson<int>(
        json['pausedDurationSeconds'],
      ),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      remainingSeconds: serializer.fromJson<int>(json['remainingSeconds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'presetId': serializer.toJson<String>(presetId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'pausedDurationSeconds': serializer.toJson<int>(pausedDurationSeconds),
      'isPaused': serializer.toJson<bool>(isPaused),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'remainingSeconds': serializer.toJson<int>(remainingSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ActiveTimerRow copyWith({
    String? id,
    String? presetId,
    DateTime? startedAt,
    int? pausedDurationSeconds,
    bool? isPaused,
    Value<DateTime?> pausedAt = const Value.absent(),
    int? remainingSeconds,
    DateTime? createdAt,
  }) => ActiveTimerRow(
    id: id ?? this.id,
    presetId: presetId ?? this.presetId,
    startedAt: startedAt ?? this.startedAt,
    pausedDurationSeconds: pausedDurationSeconds ?? this.pausedDurationSeconds,
    isPaused: isPaused ?? this.isPaused,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    createdAt: createdAt ?? this.createdAt,
  );
  ActiveTimerRow copyWithCompanion(ActiveTimersCompanion data) {
    return ActiveTimerRow(
      id: data.id.present ? data.id.value : this.id,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedDurationSeconds: data.pausedDurationSeconds.present
          ? data.pausedDurationSeconds.value
          : this.pausedDurationSeconds,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      remainingSeconds: data.remainingSeconds.present
          ? data.remainingSeconds.value
          : this.remainingSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimerRow(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedDurationSeconds: $pausedDurationSeconds, ')
          ..write('isPaused: $isPaused, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('remainingSeconds: $remainingSeconds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    presetId,
    startedAt,
    pausedDurationSeconds,
    isPaused,
    pausedAt,
    remainingSeconds,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveTimerRow &&
          other.id == this.id &&
          other.presetId == this.presetId &&
          other.startedAt == this.startedAt &&
          other.pausedDurationSeconds == this.pausedDurationSeconds &&
          other.isPaused == this.isPaused &&
          other.pausedAt == this.pausedAt &&
          other.remainingSeconds == this.remainingSeconds &&
          other.createdAt == this.createdAt);
}

class ActiveTimersCompanion extends UpdateCompanion<ActiveTimerRow> {
  final Value<String> id;
  final Value<String> presetId;
  final Value<DateTime> startedAt;
  final Value<int> pausedDurationSeconds;
  final Value<bool> isPaused;
  final Value<DateTime?> pausedAt;
  final Value<int> remainingSeconds;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ActiveTimersCompanion({
    this.id = const Value.absent(),
    this.presetId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedDurationSeconds = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.remainingSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActiveTimersCompanion.insert({
    required String id,
    required String presetId,
    required DateTime startedAt,
    this.pausedDurationSeconds = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.pausedAt = const Value.absent(),
    required int remainingSeconds,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       presetId = Value(presetId),
       startedAt = Value(startedAt),
       remainingSeconds = Value(remainingSeconds);
  static Insertable<ActiveTimerRow> custom({
    Expression<String>? id,
    Expression<String>? presetId,
    Expression<DateTime>? startedAt,
    Expression<int>? pausedDurationSeconds,
    Expression<bool>? isPaused,
    Expression<DateTime>? pausedAt,
    Expression<int>? remainingSeconds,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (presetId != null) 'preset_id': presetId,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedDurationSeconds != null)
        'paused_duration_seconds': pausedDurationSeconds,
      if (isPaused != null) 'is_paused': isPaused,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (remainingSeconds != null) 'remaining_seconds': remainingSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActiveTimersCompanion copyWith({
    Value<String>? id,
    Value<String>? presetId,
    Value<DateTime>? startedAt,
    Value<int>? pausedDurationSeconds,
    Value<bool>? isPaused,
    Value<DateTime?>? pausedAt,
    Value<int>? remainingSeconds,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ActiveTimersCompanion(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      startedAt: startedAt ?? this.startedAt,
      pausedDurationSeconds:
          pausedDurationSeconds ?? this.pausedDurationSeconds,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: pausedAt ?? this.pausedAt,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (pausedDurationSeconds.present) {
      map['paused_duration_seconds'] = Variable<int>(
        pausedDurationSeconds.value,
      );
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (remainingSeconds.present) {
      map['remaining_seconds'] = Variable<int>(remainingSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimersCompanion(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedDurationSeconds: $pausedDurationSeconds, ')
          ..write('isPaused: $isPaused, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('remainingSeconds: $remainingSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PresetsTable presets = $PresetsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  late final $ActiveTimersTable activeTimers = $ActiveTimersTable(this);
  late final Index idxSessionsPresetId = Index(
    'idx_sessions_preset_id',
    'CREATE INDEX idx_sessions_preset_id ON sessions (preset_id)',
  );
  late final Index idxSessionsStartedAt = Index(
    'idx_sessions_started_at',
    'CREATE INDEX idx_sessions_started_at ON sessions (started_at)',
  );
  late final Index idxSessionsPresetStarted = Index(
    'idx_sessions_preset_started',
    'CREATE INDEX idx_sessions_preset_started ON sessions (preset_id, started_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    presets,
    sessions,
    userSettingsTable,
    activeTimers,
    idxSessionsPresetId,
    idxSessionsStartedAt,
    idxSessionsPresetStarted,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'presets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'presets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('active_timers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PresetsTableCreateCompanionBuilder =
    PresetsCompanion Function({
      required String id,
      required String name,
      required int durationMin,
      required String icon,
      required String color,
      Value<int> dailyGoalMin,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$PresetsTableUpdateCompanionBuilder =
    PresetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> durationMin,
      Value<String> icon,
      Value<String> color,
      Value<int> dailyGoalMin,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$PresetsTableReferences
    extends BaseReferences<_$AppDatabase, $PresetsTable, PresetRow> {
  $$PresetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<SessionRow>>
  _sessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.presets.id, db.sessions.presetId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActiveTimersTable, List<ActiveTimerRow>>
  _activeTimersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activeTimers,
    aliasName: $_aliasNameGenerator(db.presets.id, db.activeTimers.presetId),
  );

  $$ActiveTimersTableProcessedTableManager get activeTimersRefs {
    final manager = $$ActiveTimersTableTableManager(
      $_db,
      $_db.activeTimers,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activeTimersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PresetsTableFilterComposer
    extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalMin => $composableBuilder(
    column: $table.dailyGoalMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activeTimersRefs(
    Expression<bool> Function($$ActiveTimersTableFilterComposer f) f,
  ) {
    final $$ActiveTimersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeTimers,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveTimersTableFilterComposer(
            $db: $db,
            $table: $db.activeTimers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalMin => $composableBuilder(
    column: $table.dailyGoalMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get dailyGoalMin => $composableBuilder(
    column: $table.dailyGoalMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activeTimersRefs<T extends Object>(
    Expression<T> Function($$ActiveTimersTableAnnotationComposer a) f,
  ) {
    final $$ActiveTimersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeTimers,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveTimersTableAnnotationComposer(
            $db: $db,
            $table: $db.activeTimers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PresetsTable,
          PresetRow,
          $$PresetsTableFilterComposer,
          $$PresetsTableOrderingComposer,
          $$PresetsTableAnnotationComposer,
          $$PresetsTableCreateCompanionBuilder,
          $$PresetsTableUpdateCompanionBuilder,
          (PresetRow, $$PresetsTableReferences),
          PresetRow,
          PrefetchHooks Function({bool sessionsRefs, bool activeTimersRefs})
        > {
  $$PresetsTableTableManager(_$AppDatabase db, $PresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> dailyGoalMin = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PresetsCompanion(
                id: id,
                name: name,
                durationMin: durationMin,
                icon: icon,
                color: color,
                dailyGoalMin: dailyGoalMin,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int durationMin,
                required String icon,
                required String color,
                Value<int> dailyGoalMin = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PresetsCompanion.insert(
                id: id,
                name: name,
                durationMin: durationMin,
                icon: icon,
                color: color,
                dailyGoalMin: dailyGoalMin,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PresetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionsRefs = false, activeTimersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionsRefs) db.sessions,
                    if (activeTimersRefs) db.activeTimers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          PresetRow,
                          $PresetsTable,
                          SessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$PresetsTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PresetsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.presetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activeTimersRefs)
                        await $_getPrefetchedData<
                          PresetRow,
                          $PresetsTable,
                          ActiveTimerRow
                        >(
                          currentTable: table,
                          referencedTable: $$PresetsTableReferences
                              ._activeTimersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PresetsTableReferences(
                                db,
                                table,
                                p0,
                              ).activeTimersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.presetId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PresetsTable,
      PresetRow,
      $$PresetsTableFilterComposer,
      $$PresetsTableOrderingComposer,
      $$PresetsTableAnnotationComposer,
      $$PresetsTableCreateCompanionBuilder,
      $$PresetsTableUpdateCompanionBuilder,
      (PresetRow, $$PresetsTableReferences),
      PresetRow,
      PrefetchHooks Function({bool sessionsRefs, bool activeTimersRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String presetId,
      required DateTime startedAt,
      required DateTime endedAt,
      required int durationSeconds,
      required String status,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> presetId,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<int> durationSeconds,
      Value<String> status,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PresetsTable _presetIdTable(_$AppDatabase db) => db.presets
      .createAlias($_aliasNameGenerator(db.sessions.presetId, db.presets.id));

  $$PresetsTableProcessedTableManager get presetId {
    final $_column = $_itemColumn<String>('preset_id')!;

    final manager = $$PresetsTableTableManager(
      $_db,
      $_db.presets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PresetsTableFilterComposer get presetId {
    final $$PresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableFilterComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PresetsTableOrderingComposer get presetId {
    final $$PresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableOrderingComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $$PresetsTableAnnotationComposer get presetId {
    final $$PresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool presetId})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                presetId: presetId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                status: status,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String presetId,
                required DateTime startedAt,
                required DateTime endedAt,
                required int durationSeconds,
                required String status,
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                presetId: presetId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                status: status,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({presetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (presetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.presetId,
                                referencedTable: $$SessionsTableReferences
                                    ._presetIdTable(db),
                                referencedColumn: $$SessionsTableReferences
                                    ._presetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool presetId})
    >;
typedef $$UserSettingsTableTableCreateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> soundEnabled,
      Value<bool> vibrationEnabled,
    });
typedef $$UserSettingsTableTableUpdateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> soundEnabled,
      Value<bool> vibrationEnabled,
    });

class $$UserSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTableTable,
          UserSettingsRow,
          $$UserSettingsTableTableFilterComposer,
          $$UserSettingsTableTableOrderingComposer,
          $$UserSettingsTableTableAnnotationComposer,
          $$UserSettingsTableTableCreateCompanionBuilder,
          $$UserSettingsTableTableUpdateCompanionBuilder,
          (
            UserSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $UserSettingsTableTable,
              UserSettingsRow
            >,
          ),
          UserSettingsRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableTableManager(
    _$AppDatabase db,
    $UserSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
              }) => UserSettingsTableCompanion(
                id: id,
                themeMode: themeMode,
                soundEnabled: soundEnabled,
                vibrationEnabled: vibrationEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
              }) => UserSettingsTableCompanion.insert(
                id: id,
                themeMode: themeMode,
                soundEnabled: soundEnabled,
                vibrationEnabled: vibrationEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTableTable,
      UserSettingsRow,
      $$UserSettingsTableTableFilterComposer,
      $$UserSettingsTableTableOrderingComposer,
      $$UserSettingsTableTableAnnotationComposer,
      $$UserSettingsTableTableCreateCompanionBuilder,
      $$UserSettingsTableTableUpdateCompanionBuilder,
      (
        UserSettingsRow,
        BaseReferences<_$AppDatabase, $UserSettingsTableTable, UserSettingsRow>,
      ),
      UserSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$ActiveTimersTableCreateCompanionBuilder =
    ActiveTimersCompanion Function({
      required String id,
      required String presetId,
      required DateTime startedAt,
      Value<int> pausedDurationSeconds,
      Value<bool> isPaused,
      Value<DateTime?> pausedAt,
      required int remainingSeconds,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ActiveTimersTableUpdateCompanionBuilder =
    ActiveTimersCompanion Function({
      Value<String> id,
      Value<String> presetId,
      Value<DateTime> startedAt,
      Value<int> pausedDurationSeconds,
      Value<bool> isPaused,
      Value<DateTime?> pausedAt,
      Value<int> remainingSeconds,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ActiveTimersTableReferences
    extends BaseReferences<_$AppDatabase, $ActiveTimersTable, ActiveTimerRow> {
  $$ActiveTimersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PresetsTable _presetIdTable(_$AppDatabase db) =>
      db.presets.createAlias(
        $_aliasNameGenerator(db.activeTimers.presetId, db.presets.id),
      );

  $$PresetsTableProcessedTableManager get presetId {
    final $_column = $_itemColumn<String>('preset_id')!;

    final manager = $$PresetsTableTableManager(
      $_db,
      $_db.presets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActiveTimersTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedDurationSeconds => $composableBuilder(
    column: $table.pausedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PresetsTableFilterComposer get presetId {
    final $$PresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableFilterComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveTimersTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedDurationSeconds => $composableBuilder(
    column: $table.pausedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PresetsTableOrderingComposer get presetId {
    final $$PresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableOrderingComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveTimersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get pausedDurationSeconds => $composableBuilder(
    column: $table.pausedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PresetsTableAnnotationComposer get presetId {
    final $$PresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.presets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.presets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveTimersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveTimersTable,
          ActiveTimerRow,
          $$ActiveTimersTableFilterComposer,
          $$ActiveTimersTableOrderingComposer,
          $$ActiveTimersTableAnnotationComposer,
          $$ActiveTimersTableCreateCompanionBuilder,
          $$ActiveTimersTableUpdateCompanionBuilder,
          (ActiveTimerRow, $$ActiveTimersTableReferences),
          ActiveTimerRow,
          PrefetchHooks Function({bool presetId})
        > {
  $$ActiveTimersTableTableManager(_$AppDatabase db, $ActiveTimersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveTimersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveTimersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveTimersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> pausedDurationSeconds = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<int> remainingSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveTimersCompanion(
                id: id,
                presetId: presetId,
                startedAt: startedAt,
                pausedDurationSeconds: pausedDurationSeconds,
                isPaused: isPaused,
                pausedAt: pausedAt,
                remainingSeconds: remainingSeconds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String presetId,
                required DateTime startedAt,
                Value<int> pausedDurationSeconds = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                required int remainingSeconds,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveTimersCompanion.insert(
                id: id,
                presetId: presetId,
                startedAt: startedAt,
                pausedDurationSeconds: pausedDurationSeconds,
                isPaused: isPaused,
                pausedAt: pausedAt,
                remainingSeconds: remainingSeconds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActiveTimersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({presetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (presetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.presetId,
                                referencedTable: $$ActiveTimersTableReferences
                                    ._presetIdTable(db),
                                referencedColumn: $$ActiveTimersTableReferences
                                    ._presetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActiveTimersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveTimersTable,
      ActiveTimerRow,
      $$ActiveTimersTableFilterComposer,
      $$ActiveTimersTableOrderingComposer,
      $$ActiveTimersTableAnnotationComposer,
      $$ActiveTimersTableCreateCompanionBuilder,
      $$ActiveTimersTableUpdateCompanionBuilder,
      (ActiveTimerRow, $$ActiveTimersTableReferences),
      ActiveTimerRow,
      PrefetchHooks Function({bool presetId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PresetsTableTableManager get presets =>
      $$PresetsTableTableManager(_db, _db.presets);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
  $$ActiveTimersTableTableManager get activeTimers =>
      $$ActiveTimersTableTableManager(_db, _db.activeTimers);
}
