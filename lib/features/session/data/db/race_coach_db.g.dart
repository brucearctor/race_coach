// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_coach_db.dart';

// ignore_for_file: type=lint
class SessionIndex extends Table with TableInfo<SessionIndex, SessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SessionIndex(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _trackNameMeta = const VerificationMeta(
    'trackName',
  );
  late final GeneratedColumn<String> trackName = GeneratedColumn<String>(
    'track_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dateMsMeta = const VerificationMeta('dateMs');
  late final GeneratedColumn<int> dateMs = GeneratedColumn<int>(
    'date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lapCountMeta = const VerificationMeta(
    'lapCount',
  );
  late final GeneratedColumn<int> lapCount = GeneratedColumn<int>(
    'lap_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _bestLapMsMeta = const VerificationMeta(
    'bestLapMs',
  );
  late final GeneratedColumn<int> bestLapMs = GeneratedColumn<int>(
    'best_lap_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _driverNameMeta = const VerificationMeta(
    'driverName',
  );
  late final GeneratedColumn<String> driverName = GeneratedColumn<String>(
    'driver_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _vehicleNameMeta = const VerificationMeta(
    'vehicleName',
  );
  late final GeneratedColumn<String> vehicleName = GeneratedColumn<String>(
    'vehicle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  late final GeneratedColumn<int> sessionType = GeneratedColumn<int>(
    'session_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  late final GeneratedColumn<int> surface = GeneratedColumn<int>(
    'surface',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  late final GeneratedColumn<int> uploaded = GeneratedColumn<int>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackName,
    dateMs,
    lapCount,
    bestLapMs,
    driverName,
    vehicleName,
    sessionType,
    surface,
    notes,
    uploaded,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_name')) {
      context.handle(
        _trackNameMeta,
        trackName.isAcceptableOrUnknown(data['track_name']!, _trackNameMeta),
      );
    } else if (isInserting) {
      context.missing(_trackNameMeta);
    }
    if (data.containsKey('date_ms')) {
      context.handle(
        _dateMsMeta,
        dateMs.isAcceptableOrUnknown(data['date_ms']!, _dateMsMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMsMeta);
    }
    if (data.containsKey('lap_count')) {
      context.handle(
        _lapCountMeta,
        lapCount.isAcceptableOrUnknown(data['lap_count']!, _lapCountMeta),
      );
    }
    if (data.containsKey('best_lap_ms')) {
      context.handle(
        _bestLapMsMeta,
        bestLapMs.isAcceptableOrUnknown(data['best_lap_ms']!, _bestLapMsMeta),
      );
    }
    if (data.containsKey('driver_name')) {
      context.handle(
        _driverNameMeta,
        driverName.isAcceptableOrUnknown(data['driver_name']!, _driverNameMeta),
      );
    }
    if (data.containsKey('vehicle_name')) {
      context.handle(
        _vehicleNameMeta,
        vehicleName.isAcceptableOrUnknown(
          data['vehicle_name']!,
          _vehicleNameMeta,
        ),
      );
    }
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_name'],
      )!,
      dateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_ms'],
      )!,
      lapCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lap_count'],
      )!,
      bestLapMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_lap_ms'],
      ),
      driverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_name'],
      ),
      vehicleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_name'],
      ),
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_type'],
      ),
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surface'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uploaded'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  SessionIndex createAlias(String alias) {
    return SessionIndex(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SessionEntry extends DataClass implements Insertable<SessionEntry> {
  final String id;
  final String trackName;
  final int dateMs;
  final int lapCount;
  final int? bestLapMs;
  final String? driverName;
  final String? vehicleName;
  final int? sessionType;
  final int? surface;
  final String? notes;
  final int uploaded;
  final int createdAtMs;
  final int updatedAtMs;
  const SessionEntry({
    required this.id,
    required this.trackName,
    required this.dateMs,
    required this.lapCount,
    this.bestLapMs,
    this.driverName,
    this.vehicleName,
    this.sessionType,
    this.surface,
    this.notes,
    required this.uploaded,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_name'] = Variable<String>(trackName);
    map['date_ms'] = Variable<int>(dateMs);
    map['lap_count'] = Variable<int>(lapCount);
    if (!nullToAbsent || bestLapMs != null) {
      map['best_lap_ms'] = Variable<int>(bestLapMs);
    }
    if (!nullToAbsent || driverName != null) {
      map['driver_name'] = Variable<String>(driverName);
    }
    if (!nullToAbsent || vehicleName != null) {
      map['vehicle_name'] = Variable<String>(vehicleName);
    }
    if (!nullToAbsent || sessionType != null) {
      map['session_type'] = Variable<int>(sessionType);
    }
    if (!nullToAbsent || surface != null) {
      map['surface'] = Variable<int>(surface);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['uploaded'] = Variable<int>(uploaded);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  SessionIndexCompanion toCompanion(bool nullToAbsent) {
    return SessionIndexCompanion(
      id: Value(id),
      trackName: Value(trackName),
      dateMs: Value(dateMs),
      lapCount: Value(lapCount),
      bestLapMs: bestLapMs == null && nullToAbsent
          ? const Value.absent()
          : Value(bestLapMs),
      driverName: driverName == null && nullToAbsent
          ? const Value.absent()
          : Value(driverName),
      vehicleName: vehicleName == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleName),
      sessionType: sessionType == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionType),
      surface: surface == null && nullToAbsent
          ? const Value.absent()
          : Value(surface),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      uploaded: Value(uploaded),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory SessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEntry(
      id: serializer.fromJson<String>(json['id']),
      trackName: serializer.fromJson<String>(json['track_name']),
      dateMs: serializer.fromJson<int>(json['date_ms']),
      lapCount: serializer.fromJson<int>(json['lap_count']),
      bestLapMs: serializer.fromJson<int?>(json['best_lap_ms']),
      driverName: serializer.fromJson<String?>(json['driver_name']),
      vehicleName: serializer.fromJson<String?>(json['vehicle_name']),
      sessionType: serializer.fromJson<int?>(json['session_type']),
      surface: serializer.fromJson<int?>(json['surface']),
      notes: serializer.fromJson<String?>(json['notes']),
      uploaded: serializer.fromJson<int>(json['uploaded']),
      createdAtMs: serializer.fromJson<int>(json['created_at_ms']),
      updatedAtMs: serializer.fromJson<int>(json['updated_at_ms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'track_name': serializer.toJson<String>(trackName),
      'date_ms': serializer.toJson<int>(dateMs),
      'lap_count': serializer.toJson<int>(lapCount),
      'best_lap_ms': serializer.toJson<int?>(bestLapMs),
      'driver_name': serializer.toJson<String?>(driverName),
      'vehicle_name': serializer.toJson<String?>(vehicleName),
      'session_type': serializer.toJson<int?>(sessionType),
      'surface': serializer.toJson<int?>(surface),
      'notes': serializer.toJson<String?>(notes),
      'uploaded': serializer.toJson<int>(uploaded),
      'created_at_ms': serializer.toJson<int>(createdAtMs),
      'updated_at_ms': serializer.toJson<int>(updatedAtMs),
    };
  }

  SessionEntry copyWith({
    String? id,
    String? trackName,
    int? dateMs,
    int? lapCount,
    Value<int?> bestLapMs = const Value.absent(),
    Value<String?> driverName = const Value.absent(),
    Value<String?> vehicleName = const Value.absent(),
    Value<int?> sessionType = const Value.absent(),
    Value<int?> surface = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? uploaded,
    int? createdAtMs,
    int? updatedAtMs,
  }) => SessionEntry(
    id: id ?? this.id,
    trackName: trackName ?? this.trackName,
    dateMs: dateMs ?? this.dateMs,
    lapCount: lapCount ?? this.lapCount,
    bestLapMs: bestLapMs.present ? bestLapMs.value : this.bestLapMs,
    driverName: driverName.present ? driverName.value : this.driverName,
    vehicleName: vehicleName.present ? vehicleName.value : this.vehicleName,
    sessionType: sessionType.present ? sessionType.value : this.sessionType,
    surface: surface.present ? surface.value : this.surface,
    notes: notes.present ? notes.value : this.notes,
    uploaded: uploaded ?? this.uploaded,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  SessionEntry copyWithCompanion(SessionIndexCompanion data) {
    return SessionEntry(
      id: data.id.present ? data.id.value : this.id,
      trackName: data.trackName.present ? data.trackName.value : this.trackName,
      dateMs: data.dateMs.present ? data.dateMs.value : this.dateMs,
      lapCount: data.lapCount.present ? data.lapCount.value : this.lapCount,
      bestLapMs: data.bestLapMs.present ? data.bestLapMs.value : this.bestLapMs,
      driverName: data.driverName.present
          ? data.driverName.value
          : this.driverName,
      vehicleName: data.vehicleName.present
          ? data.vehicleName.value
          : this.vehicleName,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      surface: data.surface.present ? data.surface.value : this.surface,
      notes: data.notes.present ? data.notes.value : this.notes,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntry(')
          ..write('id: $id, ')
          ..write('trackName: $trackName, ')
          ..write('dateMs: $dateMs, ')
          ..write('lapCount: $lapCount, ')
          ..write('bestLapMs: $bestLapMs, ')
          ..write('driverName: $driverName, ')
          ..write('vehicleName: $vehicleName, ')
          ..write('sessionType: $sessionType, ')
          ..write('surface: $surface, ')
          ..write('notes: $notes, ')
          ..write('uploaded: $uploaded, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackName,
    dateMs,
    lapCount,
    bestLapMs,
    driverName,
    vehicleName,
    sessionType,
    surface,
    notes,
    uploaded,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEntry &&
          other.id == this.id &&
          other.trackName == this.trackName &&
          other.dateMs == this.dateMs &&
          other.lapCount == this.lapCount &&
          other.bestLapMs == this.bestLapMs &&
          other.driverName == this.driverName &&
          other.vehicleName == this.vehicleName &&
          other.sessionType == this.sessionType &&
          other.surface == this.surface &&
          other.notes == this.notes &&
          other.uploaded == this.uploaded &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class SessionIndexCompanion extends UpdateCompanion<SessionEntry> {
  final Value<String> id;
  final Value<String> trackName;
  final Value<int> dateMs;
  final Value<int> lapCount;
  final Value<int?> bestLapMs;
  final Value<String?> driverName;
  final Value<String?> vehicleName;
  final Value<int?> sessionType;
  final Value<int?> surface;
  final Value<String?> notes;
  final Value<int> uploaded;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SessionIndexCompanion({
    this.id = const Value.absent(),
    this.trackName = const Value.absent(),
    this.dateMs = const Value.absent(),
    this.lapCount = const Value.absent(),
    this.bestLapMs = const Value.absent(),
    this.driverName = const Value.absent(),
    this.vehicleName = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.surface = const Value.absent(),
    this.notes = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionIndexCompanion.insert({
    required String id,
    required String trackName,
    required int dateMs,
    this.lapCount = const Value.absent(),
    this.bestLapMs = const Value.absent(),
    this.driverName = const Value.absent(),
    this.vehicleName = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.surface = const Value.absent(),
    this.notes = const Value.absent(),
    this.uploaded = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackName = Value(trackName),
       dateMs = Value(dateMs),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<SessionEntry> custom({
    Expression<String>? id,
    Expression<String>? trackName,
    Expression<int>? dateMs,
    Expression<int>? lapCount,
    Expression<int>? bestLapMs,
    Expression<String>? driverName,
    Expression<String>? vehicleName,
    Expression<int>? sessionType,
    Expression<int>? surface,
    Expression<String>? notes,
    Expression<int>? uploaded,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackName != null) 'track_name': trackName,
      if (dateMs != null) 'date_ms': dateMs,
      if (lapCount != null) 'lap_count': lapCount,
      if (bestLapMs != null) 'best_lap_ms': bestLapMs,
      if (driverName != null) 'driver_name': driverName,
      if (vehicleName != null) 'vehicle_name': vehicleName,
      if (sessionType != null) 'session_type': sessionType,
      if (surface != null) 'surface': surface,
      if (notes != null) 'notes': notes,
      if (uploaded != null) 'uploaded': uploaded,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionIndexCompanion copyWith({
    Value<String>? id,
    Value<String>? trackName,
    Value<int>? dateMs,
    Value<int>? lapCount,
    Value<int?>? bestLapMs,
    Value<String?>? driverName,
    Value<String?>? vehicleName,
    Value<int?>? sessionType,
    Value<int?>? surface,
    Value<String?>? notes,
    Value<int>? uploaded,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SessionIndexCompanion(
      id: id ?? this.id,
      trackName: trackName ?? this.trackName,
      dateMs: dateMs ?? this.dateMs,
      lapCount: lapCount ?? this.lapCount,
      bestLapMs: bestLapMs ?? this.bestLapMs,
      driverName: driverName ?? this.driverName,
      vehicleName: vehicleName ?? this.vehicleName,
      sessionType: sessionType ?? this.sessionType,
      surface: surface ?? this.surface,
      notes: notes ?? this.notes,
      uploaded: uploaded ?? this.uploaded,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackName.present) {
      map['track_name'] = Variable<String>(trackName.value);
    }
    if (dateMs.present) {
      map['date_ms'] = Variable<int>(dateMs.value);
    }
    if (lapCount.present) {
      map['lap_count'] = Variable<int>(lapCount.value);
    }
    if (bestLapMs.present) {
      map['best_lap_ms'] = Variable<int>(bestLapMs.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (vehicleName.present) {
      map['vehicle_name'] = Variable<String>(vehicleName.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<int>(sessionType.value);
    }
    if (surface.present) {
      map['surface'] = Variable<int>(surface.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<int>(uploaded.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionIndexCompanion(')
          ..write('id: $id, ')
          ..write('trackName: $trackName, ')
          ..write('dateMs: $dateMs, ')
          ..write('lapCount: $lapCount, ')
          ..write('bestLapMs: $bestLapMs, ')
          ..write('driverName: $driverName, ')
          ..write('vehicleName: $vehicleName, ')
          ..write('sessionType: $sessionType, ')
          ..write('surface: $surface, ')
          ..write('notes: $notes, ')
          ..write('uploaded: $uploaded, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LapIndex extends Table with TableInfo<LapIndex, LapEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LapIndex(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES session_index(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _lapNumberMeta = const VerificationMeta(
    'lapNumber',
  );
  late final GeneratedColumn<int> lapNumber = GeneratedColumn<int>(
    'lap_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lapTimeMsMeta = const VerificationMeta(
    'lapTimeMs',
  );
  late final GeneratedColumn<int> lapTimeMs = GeneratedColumn<int>(
    'lap_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sector1MsMeta = const VerificationMeta(
    'sector1Ms',
  );
  late final GeneratedColumn<int> sector1Ms = GeneratedColumn<int>(
    'sector_1_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sector2MsMeta = const VerificationMeta(
    'sector2Ms',
  );
  late final GeneratedColumn<int> sector2Ms = GeneratedColumn<int>(
    'sector_2_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sector3MsMeta = const VerificationMeta(
    'sector3Ms',
  );
  late final GeneratedColumn<int> sector3Ms = GeneratedColumn<int>(
    'sector_3_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isReferenceMeta = const VerificationMeta(
    'isReference',
  );
  late final GeneratedColumn<int> isReference = GeneratedColumn<int>(
    'is_reference',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    lapNumber,
    lapTimeMs,
    sector1Ms,
    sector2Ms,
    sector3Ms,
    isReference,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lap_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<LapEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('lap_number')) {
      context.handle(
        _lapNumberMeta,
        lapNumber.isAcceptableOrUnknown(data['lap_number']!, _lapNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_lapNumberMeta);
    }
    if (data.containsKey('lap_time_ms')) {
      context.handle(
        _lapTimeMsMeta,
        lapTimeMs.isAcceptableOrUnknown(data['lap_time_ms']!, _lapTimeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_lapTimeMsMeta);
    }
    if (data.containsKey('sector_1_ms')) {
      context.handle(
        _sector1MsMeta,
        sector1Ms.isAcceptableOrUnknown(data['sector_1_ms']!, _sector1MsMeta),
      );
    }
    if (data.containsKey('sector_2_ms')) {
      context.handle(
        _sector2MsMeta,
        sector2Ms.isAcceptableOrUnknown(data['sector_2_ms']!, _sector2MsMeta),
      );
    }
    if (data.containsKey('sector_3_ms')) {
      context.handle(
        _sector3MsMeta,
        sector3Ms.isAcceptableOrUnknown(data['sector_3_ms']!, _sector3MsMeta),
      );
    }
    if (data.containsKey('is_reference')) {
      context.handle(
        _isReferenceMeta,
        isReference.isAcceptableOrUnknown(
          data['is_reference']!,
          _isReferenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, lapNumber},
  ];
  @override
  LapEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LapEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      lapNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lap_number'],
      )!,
      lapTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lap_time_ms'],
      )!,
      sector1Ms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sector_1_ms'],
      ),
      sector2Ms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sector_2_ms'],
      ),
      sector3Ms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sector_3_ms'],
      ),
      isReference: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_reference'],
      )!,
    );
  }

  @override
  LapIndex createAlias(String alias) {
    return LapIndex(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(session_id, lap_number)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LapEntry extends DataClass implements Insertable<LapEntry> {
  final int id;
  final String sessionId;
  final int lapNumber;
  final int lapTimeMs;
  final int? sector1Ms;
  final int? sector2Ms;
  final int? sector3Ms;
  final int isReference;
  const LapEntry({
    required this.id,
    required this.sessionId,
    required this.lapNumber,
    required this.lapTimeMs,
    this.sector1Ms,
    this.sector2Ms,
    this.sector3Ms,
    required this.isReference,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['lap_number'] = Variable<int>(lapNumber);
    map['lap_time_ms'] = Variable<int>(lapTimeMs);
    if (!nullToAbsent || sector1Ms != null) {
      map['sector_1_ms'] = Variable<int>(sector1Ms);
    }
    if (!nullToAbsent || sector2Ms != null) {
      map['sector_2_ms'] = Variable<int>(sector2Ms);
    }
    if (!nullToAbsent || sector3Ms != null) {
      map['sector_3_ms'] = Variable<int>(sector3Ms);
    }
    map['is_reference'] = Variable<int>(isReference);
    return map;
  }

  LapIndexCompanion toCompanion(bool nullToAbsent) {
    return LapIndexCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      lapNumber: Value(lapNumber),
      lapTimeMs: Value(lapTimeMs),
      sector1Ms: sector1Ms == null && nullToAbsent
          ? const Value.absent()
          : Value(sector1Ms),
      sector2Ms: sector2Ms == null && nullToAbsent
          ? const Value.absent()
          : Value(sector2Ms),
      sector3Ms: sector3Ms == null && nullToAbsent
          ? const Value.absent()
          : Value(sector3Ms),
      isReference: Value(isReference),
    );
  }

  factory LapEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LapEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      lapNumber: serializer.fromJson<int>(json['lap_number']),
      lapTimeMs: serializer.fromJson<int>(json['lap_time_ms']),
      sector1Ms: serializer.fromJson<int?>(json['sector_1_ms']),
      sector2Ms: serializer.fromJson<int?>(json['sector_2_ms']),
      sector3Ms: serializer.fromJson<int?>(json['sector_3_ms']),
      isReference: serializer.fromJson<int>(json['is_reference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'lap_number': serializer.toJson<int>(lapNumber),
      'lap_time_ms': serializer.toJson<int>(lapTimeMs),
      'sector_1_ms': serializer.toJson<int?>(sector1Ms),
      'sector_2_ms': serializer.toJson<int?>(sector2Ms),
      'sector_3_ms': serializer.toJson<int?>(sector3Ms),
      'is_reference': serializer.toJson<int>(isReference),
    };
  }

  LapEntry copyWith({
    int? id,
    String? sessionId,
    int? lapNumber,
    int? lapTimeMs,
    Value<int?> sector1Ms = const Value.absent(),
    Value<int?> sector2Ms = const Value.absent(),
    Value<int?> sector3Ms = const Value.absent(),
    int? isReference,
  }) => LapEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    lapNumber: lapNumber ?? this.lapNumber,
    lapTimeMs: lapTimeMs ?? this.lapTimeMs,
    sector1Ms: sector1Ms.present ? sector1Ms.value : this.sector1Ms,
    sector2Ms: sector2Ms.present ? sector2Ms.value : this.sector2Ms,
    sector3Ms: sector3Ms.present ? sector3Ms.value : this.sector3Ms,
    isReference: isReference ?? this.isReference,
  );
  LapEntry copyWithCompanion(LapIndexCompanion data) {
    return LapEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      lapNumber: data.lapNumber.present ? data.lapNumber.value : this.lapNumber,
      lapTimeMs: data.lapTimeMs.present ? data.lapTimeMs.value : this.lapTimeMs,
      sector1Ms: data.sector1Ms.present ? data.sector1Ms.value : this.sector1Ms,
      sector2Ms: data.sector2Ms.present ? data.sector2Ms.value : this.sector2Ms,
      sector3Ms: data.sector3Ms.present ? data.sector3Ms.value : this.sector3Ms,
      isReference: data.isReference.present
          ? data.isReference.value
          : this.isReference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LapEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lapNumber: $lapNumber, ')
          ..write('lapTimeMs: $lapTimeMs, ')
          ..write('sector1Ms: $sector1Ms, ')
          ..write('sector2Ms: $sector2Ms, ')
          ..write('sector3Ms: $sector3Ms, ')
          ..write('isReference: $isReference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    lapNumber,
    lapTimeMs,
    sector1Ms,
    sector2Ms,
    sector3Ms,
    isReference,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LapEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.lapNumber == this.lapNumber &&
          other.lapTimeMs == this.lapTimeMs &&
          other.sector1Ms == this.sector1Ms &&
          other.sector2Ms == this.sector2Ms &&
          other.sector3Ms == this.sector3Ms &&
          other.isReference == this.isReference);
}

class LapIndexCompanion extends UpdateCompanion<LapEntry> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> lapNumber;
  final Value<int> lapTimeMs;
  final Value<int?> sector1Ms;
  final Value<int?> sector2Ms;
  final Value<int?> sector3Ms;
  final Value<int> isReference;
  const LapIndexCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.lapNumber = const Value.absent(),
    this.lapTimeMs = const Value.absent(),
    this.sector1Ms = const Value.absent(),
    this.sector2Ms = const Value.absent(),
    this.sector3Ms = const Value.absent(),
    this.isReference = const Value.absent(),
  });
  LapIndexCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int lapNumber,
    required int lapTimeMs,
    this.sector1Ms = const Value.absent(),
    this.sector2Ms = const Value.absent(),
    this.sector3Ms = const Value.absent(),
    this.isReference = const Value.absent(),
  }) : sessionId = Value(sessionId),
       lapNumber = Value(lapNumber),
       lapTimeMs = Value(lapTimeMs);
  static Insertable<LapEntry> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? lapNumber,
    Expression<int>? lapTimeMs,
    Expression<int>? sector1Ms,
    Expression<int>? sector2Ms,
    Expression<int>? sector3Ms,
    Expression<int>? isReference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (lapNumber != null) 'lap_number': lapNumber,
      if (lapTimeMs != null) 'lap_time_ms': lapTimeMs,
      if (sector1Ms != null) 'sector_1_ms': sector1Ms,
      if (sector2Ms != null) 'sector_2_ms': sector2Ms,
      if (sector3Ms != null) 'sector_3_ms': sector3Ms,
      if (isReference != null) 'is_reference': isReference,
    });
  }

  LapIndexCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? lapNumber,
    Value<int>? lapTimeMs,
    Value<int?>? sector1Ms,
    Value<int?>? sector2Ms,
    Value<int?>? sector3Ms,
    Value<int>? isReference,
  }) {
    return LapIndexCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      lapNumber: lapNumber ?? this.lapNumber,
      lapTimeMs: lapTimeMs ?? this.lapTimeMs,
      sector1Ms: sector1Ms ?? this.sector1Ms,
      sector2Ms: sector2Ms ?? this.sector2Ms,
      sector3Ms: sector3Ms ?? this.sector3Ms,
      isReference: isReference ?? this.isReference,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (lapNumber.present) {
      map['lap_number'] = Variable<int>(lapNumber.value);
    }
    if (lapTimeMs.present) {
      map['lap_time_ms'] = Variable<int>(lapTimeMs.value);
    }
    if (sector1Ms.present) {
      map['sector_1_ms'] = Variable<int>(sector1Ms.value);
    }
    if (sector2Ms.present) {
      map['sector_2_ms'] = Variable<int>(sector2Ms.value);
    }
    if (sector3Ms.present) {
      map['sector_3_ms'] = Variable<int>(sector3Ms.value);
    }
    if (isReference.present) {
      map['is_reference'] = Variable<int>(isReference.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LapIndexCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lapNumber: $lapNumber, ')
          ..write('lapTimeMs: $lapTimeMs, ')
          ..write('sector1Ms: $sector1Ms, ')
          ..write('sector2Ms: $sector2Ms, ')
          ..write('sector3Ms: $sector3Ms, ')
          ..write('isReference: $isReference')
          ..write(')'))
        .toString();
  }
}

abstract class _$RaceCoachDb extends GeneratedDatabase {
  _$RaceCoachDb(QueryExecutor e) : super(e);
  $RaceCoachDbManager get managers => $RaceCoachDbManager(this);
  late final SessionIndex sessionIndex = SessionIndex(this);
  late final LapIndex lapIndex = LapIndex(this);
  late final Index idxSessionDate = Index(
    'idx_session_date',
    'CREATE INDEX idx_session_date ON session_index (date_ms DESC)',
  );
  Selectable<SessionEntry> allSessions() {
    return customSelect(
      'SELECT * FROM session_index ORDER BY date_ms DESC',
      variables: [],
      readsFrom: {sessionIndex},
    ).asyncMap(sessionIndex.mapFromRow);
  }

  Selectable<SessionEntry> sessionsByTrack(String track) {
    return customSelect(
      'SELECT * FROM session_index WHERE track_name = ?1 ORDER BY date_ms DESC',
      variables: [Variable<String>(track)],
      readsFrom: {sessionIndex},
    ).asyncMap(sessionIndex.mapFromRow);
  }

  Selectable<LapEntry> lapsForSession(String sessionId) {
    return customSelect(
      'SELECT * FROM lap_index WHERE session_id = ?1 ORDER BY lap_number ASC',
      variables: [Variable<String>(sessionId)],
      readsFrom: {lapIndex},
    ).asyncMap(lapIndex.mapFromRow);
  }

  Selectable<int?> personalBestAtTrack(String track) {
    return customSelect(
      'SELECT MIN(l.lap_time_ms) AS best_ms FROM lap_index AS l INNER JOIN session_index AS s ON l.session_id = s.id WHERE s.track_name = ?1 AND l.lap_time_ms > 0',
      variables: [Variable<String>(track)],
      readsFrom: {lapIndex, sessionIndex},
    ).map((QueryRow row) => row.readNullable<int>('best_ms'));
  }

  Selectable<LapTimeTrendResult> lapTimeTrend(String track) {
    return customSelect(
      'SELECT l.lap_time_ms, s.date_ms, s.id AS session_id, l.lap_number FROM lap_index AS l INNER JOIN session_index AS s ON l.session_id = s.id WHERE s.track_name = ?1 AND l.lap_time_ms > 0 ORDER BY s.date_ms ASC, l.lap_number ASC',
      variables: [Variable<String>(track)],
      readsFrom: {lapIndex, sessionIndex},
    ).map(
      (QueryRow row) => LapTimeTrendResult(
        lapTimeMs: row.read<int>('lap_time_ms'),
        dateMs: row.read<int>('date_ms'),
        sessionId: row.read<String>('session_id'),
        lapNumber: row.read<int>('lap_number'),
      ),
    );
  }

  Selectable<String> distinctTracks() {
    return customSelect(
      'SELECT DISTINCT track_name FROM session_index ORDER BY track_name ASC',
      variables: [],
      readsFrom: {sessionIndex},
    ).map((QueryRow row) => row.read<String>('track_name'));
  }

  Selectable<int> sessionCount() {
    return customSelect(
      'SELECT COUNT(*) AS cnt FROM session_index',
      variables: [],
      readsFrom: {sessionIndex},
    ).map((QueryRow row) => row.read<int>('cnt'));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessionIndex,
    lapIndex,
    idxSessionDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_index',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lap_index', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $SessionIndexCreateCompanionBuilder =
    SessionIndexCompanion Function({
      required String id,
      required String trackName,
      required int dateMs,
      Value<int> lapCount,
      Value<int?> bestLapMs,
      Value<String?> driverName,
      Value<String?> vehicleName,
      Value<int?> sessionType,
      Value<int?> surface,
      Value<String?> notes,
      Value<int> uploaded,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $SessionIndexUpdateCompanionBuilder =
    SessionIndexCompanion Function({
      Value<String> id,
      Value<String> trackName,
      Value<int> dateMs,
      Value<int> lapCount,
      Value<int?> bestLapMs,
      Value<String?> driverName,
      Value<String?> vehicleName,
      Value<int?> sessionType,
      Value<int?> surface,
      Value<String?> notes,
      Value<int> uploaded,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

final class $SessionIndexReferences
    extends BaseReferences<_$RaceCoachDb, SessionIndex, SessionEntry> {
  $SessionIndexReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<LapIndex, List<LapEntry>> _lapIndexRefsTable(
    _$RaceCoachDb db,
  ) => MultiTypedResultKey.fromTable(
    db.lapIndex,
    aliasName: $_aliasNameGenerator(db.sessionIndex.id, db.lapIndex.sessionId),
  );

  $LapIndexProcessedTableManager get lapIndexRefs {
    final manager = $LapIndexTableManager(
      $_db,
      $_db.lapIndex,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lapIndexRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SessionIndexFilterComposer
    extends Composer<_$RaceCoachDb, SessionIndex> {
  $SessionIndexFilterComposer({
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

  ColumnFilters<String> get trackName => $composableBuilder(
    column: $table.trackName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapCount => $composableBuilder(
    column: $table.lapCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestLapMs => $composableBuilder(
    column: $table.bestLapMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleName => $composableBuilder(
    column: $table.vehicleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lapIndexRefs(
    Expression<bool> Function($LapIndexFilterComposer f) f,
  ) {
    final $LapIndexFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lapIndex,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LapIndexFilterComposer(
            $db: $db,
            $table: $db.lapIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SessionIndexOrderingComposer
    extends Composer<_$RaceCoachDb, SessionIndex> {
  $SessionIndexOrderingComposer({
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

  ColumnOrderings<String> get trackName => $composableBuilder(
    column: $table.trackName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapCount => $composableBuilder(
    column: $table.lapCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestLapMs => $composableBuilder(
    column: $table.bestLapMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleName => $composableBuilder(
    column: $table.vehicleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SessionIndexAnnotationComposer
    extends Composer<_$RaceCoachDb, SessionIndex> {
  $SessionIndexAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackName =>
      $composableBuilder(column: $table.trackName, builder: (column) => column);

  GeneratedColumn<int> get dateMs =>
      $composableBuilder(column: $table.dateMs, builder: (column) => column);

  GeneratedColumn<int> get lapCount =>
      $composableBuilder(column: $table.lapCount, builder: (column) => column);

  GeneratedColumn<int> get bestLapMs =>
      $composableBuilder(column: $table.bestLapMs, builder: (column) => column);

  GeneratedColumn<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vehicleName => $composableBuilder(
    column: $table.vehicleName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  Expression<T> lapIndexRefs<T extends Object>(
    Expression<T> Function($LapIndexAnnotationComposer a) f,
  ) {
    final $LapIndexAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lapIndex,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LapIndexAnnotationComposer(
            $db: $db,
            $table: $db.lapIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SessionIndexTableManager
    extends
        RootTableManager<
          _$RaceCoachDb,
          SessionIndex,
          SessionEntry,
          $SessionIndexFilterComposer,
          $SessionIndexOrderingComposer,
          $SessionIndexAnnotationComposer,
          $SessionIndexCreateCompanionBuilder,
          $SessionIndexUpdateCompanionBuilder,
          (SessionEntry, $SessionIndexReferences),
          SessionEntry,
          PrefetchHooks Function({bool lapIndexRefs})
        > {
  $SessionIndexTableManager(_$RaceCoachDb db, SessionIndex table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SessionIndexFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SessionIndexOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SessionIndexAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackName = const Value.absent(),
                Value<int> dateMs = const Value.absent(),
                Value<int> lapCount = const Value.absent(),
                Value<int?> bestLapMs = const Value.absent(),
                Value<String?> driverName = const Value.absent(),
                Value<String?> vehicleName = const Value.absent(),
                Value<int?> sessionType = const Value.absent(),
                Value<int?> surface = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> uploaded = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionIndexCompanion(
                id: id,
                trackName: trackName,
                dateMs: dateMs,
                lapCount: lapCount,
                bestLapMs: bestLapMs,
                driverName: driverName,
                vehicleName: vehicleName,
                sessionType: sessionType,
                surface: surface,
                notes: notes,
                uploaded: uploaded,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackName,
                required int dateMs,
                Value<int> lapCount = const Value.absent(),
                Value<int?> bestLapMs = const Value.absent(),
                Value<String?> driverName = const Value.absent(),
                Value<String?> vehicleName = const Value.absent(),
                Value<int?> sessionType = const Value.absent(),
                Value<int?> surface = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> uploaded = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SessionIndexCompanion.insert(
                id: id,
                trackName: trackName,
                dateMs: dateMs,
                lapCount: lapCount,
                bestLapMs: bestLapMs,
                driverName: driverName,
                vehicleName: vehicleName,
                sessionType: sessionType,
                surface: surface,
                notes: notes,
                uploaded: uploaded,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $SessionIndexReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({lapIndexRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lapIndexRefs) db.lapIndex],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lapIndexRefs)
                    await $_getPrefetchedData<
                      SessionEntry,
                      SessionIndex,
                      LapEntry
                    >(
                      currentTable: table,
                      referencedTable: $SessionIndexReferences
                          ._lapIndexRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $SessionIndexReferences(db, table, p0).lapIndexRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $SessionIndexProcessedTableManager =
    ProcessedTableManager<
      _$RaceCoachDb,
      SessionIndex,
      SessionEntry,
      $SessionIndexFilterComposer,
      $SessionIndexOrderingComposer,
      $SessionIndexAnnotationComposer,
      $SessionIndexCreateCompanionBuilder,
      $SessionIndexUpdateCompanionBuilder,
      (SessionEntry, $SessionIndexReferences),
      SessionEntry,
      PrefetchHooks Function({bool lapIndexRefs})
    >;
typedef $LapIndexCreateCompanionBuilder =
    LapIndexCompanion Function({
      Value<int> id,
      required String sessionId,
      required int lapNumber,
      required int lapTimeMs,
      Value<int?> sector1Ms,
      Value<int?> sector2Ms,
      Value<int?> sector3Ms,
      Value<int> isReference,
    });
typedef $LapIndexUpdateCompanionBuilder =
    LapIndexCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> lapNumber,
      Value<int> lapTimeMs,
      Value<int?> sector1Ms,
      Value<int?> sector2Ms,
      Value<int?> sector3Ms,
      Value<int> isReference,
    });

final class $LapIndexReferences
    extends BaseReferences<_$RaceCoachDb, LapIndex, LapEntry> {
  $LapIndexReferences(super.$_db, super.$_table, super.$_typedResult);

  static SessionIndex _sessionIdTable(_$RaceCoachDb db) =>
      db.sessionIndex.createAlias(
        $_aliasNameGenerator(db.lapIndex.sessionId, db.sessionIndex.id),
      );

  $SessionIndexProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $SessionIndexTableManager(
      $_db,
      $_db.sessionIndex,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $LapIndexFilterComposer extends Composer<_$RaceCoachDb, LapIndex> {
  $LapIndexFilterComposer({
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

  ColumnFilters<int> get lapNumber => $composableBuilder(
    column: $table.lapNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapTimeMs => $composableBuilder(
    column: $table.lapTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sector1Ms => $composableBuilder(
    column: $table.sector1Ms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sector2Ms => $composableBuilder(
    column: $table.sector2Ms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sector3Ms => $composableBuilder(
    column: $table.sector3Ms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isReference => $composableBuilder(
    column: $table.isReference,
    builder: (column) => ColumnFilters(column),
  );

  $SessionIndexFilterComposer get sessionId {
    final $SessionIndexFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionIndex,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionIndexFilterComposer(
            $db: $db,
            $table: $db.sessionIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LapIndexOrderingComposer extends Composer<_$RaceCoachDb, LapIndex> {
  $LapIndexOrderingComposer({
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

  ColumnOrderings<int> get lapNumber => $composableBuilder(
    column: $table.lapNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapTimeMs => $composableBuilder(
    column: $table.lapTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sector1Ms => $composableBuilder(
    column: $table.sector1Ms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sector2Ms => $composableBuilder(
    column: $table.sector2Ms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sector3Ms => $composableBuilder(
    column: $table.sector3Ms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isReference => $composableBuilder(
    column: $table.isReference,
    builder: (column) => ColumnOrderings(column),
  );

  $SessionIndexOrderingComposer get sessionId {
    final $SessionIndexOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionIndex,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionIndexOrderingComposer(
            $db: $db,
            $table: $db.sessionIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LapIndexAnnotationComposer extends Composer<_$RaceCoachDb, LapIndex> {
  $LapIndexAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lapNumber =>
      $composableBuilder(column: $table.lapNumber, builder: (column) => column);

  GeneratedColumn<int> get lapTimeMs =>
      $composableBuilder(column: $table.lapTimeMs, builder: (column) => column);

  GeneratedColumn<int> get sector1Ms =>
      $composableBuilder(column: $table.sector1Ms, builder: (column) => column);

  GeneratedColumn<int> get sector2Ms =>
      $composableBuilder(column: $table.sector2Ms, builder: (column) => column);

  GeneratedColumn<int> get sector3Ms =>
      $composableBuilder(column: $table.sector3Ms, builder: (column) => column);

  GeneratedColumn<int> get isReference => $composableBuilder(
    column: $table.isReference,
    builder: (column) => column,
  );

  $SessionIndexAnnotationComposer get sessionId {
    final $SessionIndexAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionIndex,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionIndexAnnotationComposer(
            $db: $db,
            $table: $db.sessionIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LapIndexTableManager
    extends
        RootTableManager<
          _$RaceCoachDb,
          LapIndex,
          LapEntry,
          $LapIndexFilterComposer,
          $LapIndexOrderingComposer,
          $LapIndexAnnotationComposer,
          $LapIndexCreateCompanionBuilder,
          $LapIndexUpdateCompanionBuilder,
          (LapEntry, $LapIndexReferences),
          LapEntry,
          PrefetchHooks Function({bool sessionId})
        > {
  $LapIndexTableManager(_$RaceCoachDb db, LapIndex table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LapIndexFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LapIndexOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LapIndexAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> lapNumber = const Value.absent(),
                Value<int> lapTimeMs = const Value.absent(),
                Value<int?> sector1Ms = const Value.absent(),
                Value<int?> sector2Ms = const Value.absent(),
                Value<int?> sector3Ms = const Value.absent(),
                Value<int> isReference = const Value.absent(),
              }) => LapIndexCompanion(
                id: id,
                sessionId: sessionId,
                lapNumber: lapNumber,
                lapTimeMs: lapTimeMs,
                sector1Ms: sector1Ms,
                sector2Ms: sector2Ms,
                sector3Ms: sector3Ms,
                isReference: isReference,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int lapNumber,
                required int lapTimeMs,
                Value<int?> sector1Ms = const Value.absent(),
                Value<int?> sector2Ms = const Value.absent(),
                Value<int?> sector3Ms = const Value.absent(),
                Value<int> isReference = const Value.absent(),
              }) => LapIndexCompanion.insert(
                id: id,
                sessionId: sessionId,
                lapNumber: lapNumber,
                lapTimeMs: lapTimeMs,
                sector1Ms: sector1Ms,
                sector2Ms: sector2Ms,
                sector3Ms: sector3Ms,
                isReference: isReference,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), $LapIndexReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $LapIndexReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $LapIndexReferences
                                    ._sessionIdTable(db)
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

typedef $LapIndexProcessedTableManager =
    ProcessedTableManager<
      _$RaceCoachDb,
      LapIndex,
      LapEntry,
      $LapIndexFilterComposer,
      $LapIndexOrderingComposer,
      $LapIndexAnnotationComposer,
      $LapIndexCreateCompanionBuilder,
      $LapIndexUpdateCompanionBuilder,
      (LapEntry, $LapIndexReferences),
      LapEntry,
      PrefetchHooks Function({bool sessionId})
    >;

class $RaceCoachDbManager {
  final _$RaceCoachDb _db;
  $RaceCoachDbManager(this._db);
  $SessionIndexTableManager get sessionIndex =>
      $SessionIndexTableManager(_db, _db.sessionIndex);
  $LapIndexTableManager get lapIndex =>
      $LapIndexTableManager(_db, _db.lapIndex);
}

class LapTimeTrendResult {
  final int lapTimeMs;
  final int dateMs;
  final String sessionId;
  final int lapNumber;
  LapTimeTrendResult({
    required this.lapTimeMs,
    required this.dateMs,
    required this.sessionId,
    required this.lapNumber,
  });
}
