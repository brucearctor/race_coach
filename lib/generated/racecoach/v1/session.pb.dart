// This is a generated file - do not edit.
//
// Generated from racecoach/v1/session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'session.pbenum.dart';
import 'telemetry.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'session.pbenum.dart';

/// A complete driving session (one outing at a track).
class Session extends $pb.GeneratedMessage {
  factory Session({
    $core.String? sessionId,
    $core.String? trackName,
    $0.Timestamp? startTime,
    $0.Timestamp? endTime,
    $core.Iterable<Lap>? laps,
    SessionConfig? config,
    $core.Iterable<$1.SourceType>? activeSources,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (trackName != null) result.trackName = trackName;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (laps != null) result.laps.addAll(laps);
    if (config != null) result.config = config;
    if (activeSources != null) result.activeSources.addAll(activeSources);
    return result;
  }

  Session._();

  factory Session.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Session.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Session',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'trackName')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'startTime',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'endTime',
        subBuilder: $0.Timestamp.create)
    ..pPM<Lap>(5, _omitFieldNames ? '' : 'laps', subBuilder: Lap.create)
    ..aOM<SessionConfig>(6, _omitFieldNames ? '' : 'config',
        subBuilder: SessionConfig.create)
    ..pc<$1.SourceType>(
        7, _omitFieldNames ? '' : 'activeSources', $pb.PbFieldType.KE,
        valueOf: $1.SourceType.valueOf,
        enumValues: $1.SourceType.values,
        defaultEnumValue: $1.SourceType.SOURCE_TYPE_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session copyWith(void Function(Session) updates) =>
      super.copyWith((message) => updates(message as Session)) as Session;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Session create() => Session._();
  @$core.override
  Session createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Session getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Session>(create);
  static Session? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get trackName => $_getSZ(1);
  @$pb.TagNumber(2)
  set trackName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTrackName() => $_has(1);
  @$pb.TagNumber(2)
  void clearTrackName() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get startTime => $_getN(2);
  @$pb.TagNumber(3)
  set startTime($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStartTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureStartTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get endTime => $_getN(3);
  @$pb.TagNumber(4)
  set endTime($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEndTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureEndTime() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<Lap> get laps => $_getList(4);

  @$pb.TagNumber(6)
  SessionConfig get config => $_getN(5);
  @$pb.TagNumber(6)
  set config(SessionConfig value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasConfig() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfig() => $_clearField(6);
  @$pb.TagNumber(6)
  SessionConfig ensureConfig() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<$1.SourceType> get activeSources => $_getList(6);
}

/// A single lap within a session.
class Lap extends $pb.GeneratedMessage {
  factory Lap({
    $core.int? lapNumber,
    $core.double? lapTimeSeconds,
    $core.Iterable<$1.TelemetryFrame>? telemetry,
    $core.bool? isReference,
    $core.Iterable<$core.double>? sectorTimesSeconds,
    $0.Timestamp? startTime,
  }) {
    final result = create();
    if (lapNumber != null) result.lapNumber = lapNumber;
    if (lapTimeSeconds != null) result.lapTimeSeconds = lapTimeSeconds;
    if (telemetry != null) result.telemetry.addAll(telemetry);
    if (isReference != null) result.isReference = isReference;
    if (sectorTimesSeconds != null)
      result.sectorTimesSeconds.addAll(sectorTimesSeconds);
    if (startTime != null) result.startTime = startTime;
    return result;
  }

  Lap._();

  factory Lap.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Lap.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Lap',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'lapNumber', fieldType: $pb.PbFieldType.OU3)
    ..aD(2, _omitFieldNames ? '' : 'lapTimeSeconds',
        fieldType: $pb.PbFieldType.OF)
    ..pPM<$1.TelemetryFrame>(3, _omitFieldNames ? '' : 'telemetry',
        subBuilder: $1.TelemetryFrame.create)
    ..aOB(4, _omitFieldNames ? '' : 'isReference')
    ..p<$core.double>(
        5, _omitFieldNames ? '' : 'sectorTimesSeconds', $pb.PbFieldType.KF)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'startTime',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lap clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lap copyWith(void Function(Lap) updates) =>
      super.copyWith((message) => updates(message as Lap)) as Lap;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Lap create() => Lap._();
  @$core.override
  Lap createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Lap getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Lap>(create);
  static Lap? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lapNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set lapNumber($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLapNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearLapNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get lapTimeSeconds => $_getN(1);
  @$pb.TagNumber(2)
  set lapTimeSeconds($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLapTimeSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearLapTimeSeconds() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$1.TelemetryFrame> get telemetry => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get isReference => $_getBF(3);
  @$pb.TagNumber(4)
  set isReference($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsReference() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsReference() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.double> get sectorTimesSeconds => $_getList(4);

  @$pb.TagNumber(6)
  $0.Timestamp get startTime => $_getN(5);
  @$pb.TagNumber(6)
  set startTime($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStartTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartTime() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureStartTime() => $_ensure(5);
}

/// Configuration for a session (set before or during recording).
class SessionConfig extends $pb.GeneratedMessage {
  factory SessionConfig({
    $1.GpsData? finishLinePointA,
    $1.GpsData? finishLinePointB,
    $core.Iterable<SectorLine>? sectorLines,
    SpeedUnit? speedUnit,
    TemperatureUnit? tempUnit,
    $core.bool? audioCoachingEnabled,
  }) {
    final result = create();
    if (finishLinePointA != null) result.finishLinePointA = finishLinePointA;
    if (finishLinePointB != null) result.finishLinePointB = finishLinePointB;
    if (sectorLines != null) result.sectorLines.addAll(sectorLines);
    if (speedUnit != null) result.speedUnit = speedUnit;
    if (tempUnit != null) result.tempUnit = tempUnit;
    if (audioCoachingEnabled != null)
      result.audioCoachingEnabled = audioCoachingEnabled;
    return result;
  }

  SessionConfig._();

  factory SessionConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOM<$1.GpsData>(1, _omitFieldNames ? '' : 'finishLinePointA',
        subBuilder: $1.GpsData.create)
    ..aOM<$1.GpsData>(2, _omitFieldNames ? '' : 'finishLinePointB',
        subBuilder: $1.GpsData.create)
    ..pPM<SectorLine>(3, _omitFieldNames ? '' : 'sectorLines',
        subBuilder: SectorLine.create)
    ..aE<SpeedUnit>(4, _omitFieldNames ? '' : 'speedUnit',
        enumValues: SpeedUnit.values)
    ..aE<TemperatureUnit>(5, _omitFieldNames ? '' : 'tempUnit',
        enumValues: TemperatureUnit.values)
    ..aOB(6, _omitFieldNames ? '' : 'audioCoachingEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionConfig copyWith(void Function(SessionConfig) updates) =>
      super.copyWith((message) => updates(message as SessionConfig))
          as SessionConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionConfig create() => SessionConfig._();
  @$core.override
  SessionConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionConfig>(create);
  static SessionConfig? _defaultInstance;

  /// Finish line definition (two GPS points forming a line segment).
  @$pb.TagNumber(1)
  $1.GpsData get finishLinePointA => $_getN(0);
  @$pb.TagNumber(1)
  set finishLinePointA($1.GpsData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFinishLinePointA() => $_has(0);
  @$pb.TagNumber(1)
  void clearFinishLinePointA() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.GpsData ensureFinishLinePointA() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.GpsData get finishLinePointB => $_getN(1);
  @$pb.TagNumber(2)
  set finishLinePointB($1.GpsData value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFinishLinePointB() => $_has(1);
  @$pb.TagNumber(2)
  void clearFinishLinePointB() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.GpsData ensureFinishLinePointB() => $_ensure(1);

  /// Sector split points (optional).
  @$pb.TagNumber(3)
  $pb.PbList<SectorLine> get sectorLines => $_getList(2);

  /// Preferences.
  @$pb.TagNumber(4)
  SpeedUnit get speedUnit => $_getN(3);
  @$pb.TagNumber(4)
  set speedUnit(SpeedUnit value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSpeedUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpeedUnit() => $_clearField(4);

  @$pb.TagNumber(5)
  TemperatureUnit get tempUnit => $_getN(4);
  @$pb.TagNumber(5)
  set tempUnit(TemperatureUnit value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTempUnit() => $_has(4);
  @$pb.TagNumber(5)
  void clearTempUnit() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get audioCoachingEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set audioCoachingEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAudioCoachingEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearAudioCoachingEnabled() => $_clearField(6);
}

/// A sector split line (two GPS points forming a line segment).
class SectorLine extends $pb.GeneratedMessage {
  factory SectorLine({
    $core.int? sectorNumber,
    $1.GpsData? pointA,
    $1.GpsData? pointB,
  }) {
    final result = create();
    if (sectorNumber != null) result.sectorNumber = sectorNumber;
    if (pointA != null) result.pointA = pointA;
    if (pointB != null) result.pointB = pointB;
    return result;
  }

  SectorLine._();

  factory SectorLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SectorLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SectorLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'sectorNumber',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<$1.GpsData>(2, _omitFieldNames ? '' : 'pointA',
        subBuilder: $1.GpsData.create)
    ..aOM<$1.GpsData>(3, _omitFieldNames ? '' : 'pointB',
        subBuilder: $1.GpsData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SectorLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SectorLine copyWith(void Function(SectorLine) updates) =>
      super.copyWith((message) => updates(message as SectorLine)) as SectorLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SectorLine create() => SectorLine._();
  @$core.override
  SectorLine createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SectorLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SectorLine>(create);
  static SectorLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sectorNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set sectorNumber($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSectorNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSectorNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.GpsData get pointA => $_getN(1);
  @$pb.TagNumber(2)
  set pointA($1.GpsData value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPointA() => $_has(1);
  @$pb.TagNumber(2)
  void clearPointA() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.GpsData ensurePointA() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.GpsData get pointB => $_getN(2);
  @$pb.TagNumber(3)
  set pointB($1.GpsData value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPointB() => $_has(2);
  @$pb.TagNumber(3)
  void clearPointB() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.GpsData ensurePointB() => $_ensure(2);
}

/// Who was driving, what car, what conditions — snapshotted at session start.
class SessionMeta extends $pb.GeneratedMessage {
  factory SessionMeta({
    $core.String? sessionId,
    $core.String? driverName,
    Vehicle? vehicle,
    Conditions? conditions,
    SessionType? sessionType,
    DeviceInfo? deviceInfo,
    $core.String? notes,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (driverName != null) result.driverName = driverName;
    if (vehicle != null) result.vehicle = vehicle;
    if (conditions != null) result.conditions = conditions;
    if (sessionType != null) result.sessionType = sessionType;
    if (deviceInfo != null) result.deviceInfo = deviceInfo;
    if (notes != null) result.notes = notes;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  SessionMeta._();

  factory SessionMeta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionMeta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionMeta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'driverName')
    ..aOM<Vehicle>(3, _omitFieldNames ? '' : 'vehicle',
        subBuilder: Vehicle.create)
    ..aOM<Conditions>(4, _omitFieldNames ? '' : 'conditions',
        subBuilder: Conditions.create)
    ..aE<SessionType>(5, _omitFieldNames ? '' : 'sessionType',
        enumValues: SessionType.values)
    ..aOM<DeviceInfo>(6, _omitFieldNames ? '' : 'deviceInfo',
        subBuilder: DeviceInfo.create)
    ..aOS(7, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionMeta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionMeta copyWith(void Function(SessionMeta) updates) =>
      super.copyWith((message) => updates(message as SessionMeta))
          as SessionMeta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionMeta create() => SessionMeta._();
  @$core.override
  SessionMeta createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionMeta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionMeta>(create);
  static SessionMeta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get driverName => $_getSZ(1);
  @$pb.TagNumber(2)
  set driverName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDriverName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDriverName() => $_clearField(2);

  @$pb.TagNumber(3)
  Vehicle get vehicle => $_getN(2);
  @$pb.TagNumber(3)
  set vehicle(Vehicle value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVehicle() => $_has(2);
  @$pb.TagNumber(3)
  void clearVehicle() => $_clearField(3);
  @$pb.TagNumber(3)
  Vehicle ensureVehicle() => $_ensure(2);

  @$pb.TagNumber(4)
  Conditions get conditions => $_getN(3);
  @$pb.TagNumber(4)
  set conditions(Conditions value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasConditions() => $_has(3);
  @$pb.TagNumber(4)
  void clearConditions() => $_clearField(4);
  @$pb.TagNumber(4)
  Conditions ensureConditions() => $_ensure(3);

  @$pb.TagNumber(5)
  SessionType get sessionType => $_getN(4);
  @$pb.TagNumber(5)
  set sessionType(SessionType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSessionType() => $_has(4);
  @$pb.TagNumber(5)
  void clearSessionType() => $_clearField(5);

  @$pb.TagNumber(6)
  DeviceInfo get deviceInfo => $_getN(5);
  @$pb.TagNumber(6)
  set deviceInfo(DeviceInfo value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDeviceInfo() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeviceInfo() => $_clearField(6);
  @$pb.TagNumber(6)
  DeviceInfo ensureDeviceInfo() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get notes => $_getSZ(6);
  @$pb.TagNumber(7)
  set notes($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNotes() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotes() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get updatedAt => $_getN(8);
  @$pb.TagNumber(9)
  set updatedAt($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureUpdatedAt() => $_ensure(8);
}

/// Vehicle metadata, snapshotted at session start.
class Vehicle extends $pb.GeneratedMessage {
  factory Vehicle({
    $core.String? name,
    $core.String? make,
    $core.String? model,
    $core.int? year,
    $core.String? vehicleClass,
    $core.double? weightKg,
    $core.double? powerHp,
    $core.String? tireCompound,
    TirePressures? tirePressures,
    $core.String? notes,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (make != null) result.make = make;
    if (model != null) result.model = model;
    if (year != null) result.year = year;
    if (vehicleClass != null) result.vehicleClass = vehicleClass;
    if (weightKg != null) result.weightKg = weightKg;
    if (powerHp != null) result.powerHp = powerHp;
    if (tireCompound != null) result.tireCompound = tireCompound;
    if (tirePressures != null) result.tirePressures = tirePressures;
    if (notes != null) result.notes = notes;
    return result;
  }

  Vehicle._();

  factory Vehicle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Vehicle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Vehicle',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'make')
    ..aOS(3, _omitFieldNames ? '' : 'model')
    ..aI(4, _omitFieldNames ? '' : 'year', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'vehicleClass')
    ..aD(6, _omitFieldNames ? '' : 'weightKg', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'powerHp', fieldType: $pb.PbFieldType.OF)
    ..aOS(8, _omitFieldNames ? '' : 'tireCompound')
    ..aOM<TirePressures>(9, _omitFieldNames ? '' : 'tirePressures',
        subBuilder: TirePressures.create)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Vehicle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Vehicle copyWith(void Function(Vehicle) updates) =>
      super.copyWith((message) => updates(message as Vehicle)) as Vehicle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Vehicle create() => Vehicle._();
  @$core.override
  Vehicle createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Vehicle getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Vehicle>(create);
  static Vehicle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get make => $_getSZ(1);
  @$pb.TagNumber(2)
  set make($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMake() => $_has(1);
  @$pb.TagNumber(2)
  void clearMake() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get model => $_getSZ(2);
  @$pb.TagNumber(3)
  set model($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasModel() => $_has(2);
  @$pb.TagNumber(3)
  void clearModel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get year => $_getIZ(3);
  @$pb.TagNumber(4)
  set year($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYear() => $_has(3);
  @$pb.TagNumber(4)
  void clearYear() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get vehicleClass => $_getSZ(4);
  @$pb.TagNumber(5)
  set vehicleClass($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVehicleClass() => $_has(4);
  @$pb.TagNumber(5)
  void clearVehicleClass() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get weightKg => $_getN(5);
  @$pb.TagNumber(6)
  set weightKg($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWeightKg() => $_has(5);
  @$pb.TagNumber(6)
  void clearWeightKg() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get powerHp => $_getN(6);
  @$pb.TagNumber(7)
  set powerHp($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPowerHp() => $_has(6);
  @$pb.TagNumber(7)
  void clearPowerHp() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get tireCompound => $_getSZ(7);
  @$pb.TagNumber(8)
  set tireCompound($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTireCompound() => $_has(7);
  @$pb.TagNumber(8)
  void clearTireCompound() => $_clearField(8);

  @$pb.TagNumber(9)
  TirePressures get tirePressures => $_getN(8);
  @$pb.TagNumber(9)
  set tirePressures(TirePressures value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasTirePressures() => $_has(8);
  @$pb.TagNumber(9)
  void clearTirePressures() => $_clearField(9);
  @$pb.TagNumber(9)
  TirePressures ensureTirePressures() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);
}

/// Cold tire pressures at session start.
class TirePressures extends $pb.GeneratedMessage {
  factory TirePressures({
    $core.double? frontLeftPsi,
    $core.double? frontRightPsi,
    $core.double? rearLeftPsi,
    $core.double? rearRightPsi,
  }) {
    final result = create();
    if (frontLeftPsi != null) result.frontLeftPsi = frontLeftPsi;
    if (frontRightPsi != null) result.frontRightPsi = frontRightPsi;
    if (rearLeftPsi != null) result.rearLeftPsi = rearLeftPsi;
    if (rearRightPsi != null) result.rearRightPsi = rearRightPsi;
    return result;
  }

  TirePressures._();

  factory TirePressures.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TirePressures.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TirePressures',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'frontLeftPsi',
        fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'frontRightPsi',
        fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'rearLeftPsi', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'rearRightPsi',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TirePressures clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TirePressures copyWith(void Function(TirePressures) updates) =>
      super.copyWith((message) => updates(message as TirePressures))
          as TirePressures;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TirePressures create() => TirePressures._();
  @$core.override
  TirePressures createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TirePressures getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TirePressures>(create);
  static TirePressures? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get frontLeftPsi => $_getN(0);
  @$pb.TagNumber(1)
  set frontLeftPsi($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFrontLeftPsi() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrontLeftPsi() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get frontRightPsi => $_getN(1);
  @$pb.TagNumber(2)
  set frontRightPsi($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrontRightPsi() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrontRightPsi() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get rearLeftPsi => $_getN(2);
  @$pb.TagNumber(3)
  set rearLeftPsi($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRearLeftPsi() => $_has(2);
  @$pb.TagNumber(3)
  void clearRearLeftPsi() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get rearRightPsi => $_getN(3);
  @$pb.TagNumber(4)
  set rearRightPsi($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRearRightPsi() => $_has(3);
  @$pb.TagNumber(4)
  void clearRearRightPsi() => $_clearField(4);
}

/// Track/weather conditions at session time.
class Conditions extends $pb.GeneratedMessage {
  factory Conditions({
    SurfaceCondition? surface,
    $core.double? ambientTempC,
    $core.double? trackTempC,
    $core.double? humidityPct,
  }) {
    final result = create();
    if (surface != null) result.surface = surface;
    if (ambientTempC != null) result.ambientTempC = ambientTempC;
    if (trackTempC != null) result.trackTempC = trackTempC;
    if (humidityPct != null) result.humidityPct = humidityPct;
    return result;
  }

  Conditions._();

  factory Conditions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Conditions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Conditions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aE<SurfaceCondition>(1, _omitFieldNames ? '' : 'surface',
        enumValues: SurfaceCondition.values)
    ..aD(2, _omitFieldNames ? '' : 'ambientTempC',
        fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'trackTempC', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'humidityPct', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conditions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conditions copyWith(void Function(Conditions) updates) =>
      super.copyWith((message) => updates(message as Conditions)) as Conditions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Conditions create() => Conditions._();
  @$core.override
  Conditions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Conditions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Conditions>(create);
  static Conditions? _defaultInstance;

  @$pb.TagNumber(1)
  SurfaceCondition get surface => $_getN(0);
  @$pb.TagNumber(1)
  set surface(SurfaceCondition value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSurface() => $_has(0);
  @$pb.TagNumber(1)
  void clearSurface() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get ambientTempC => $_getN(1);
  @$pb.TagNumber(2)
  set ambientTempC($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmbientTempC() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmbientTempC() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get trackTempC => $_getN(2);
  @$pb.TagNumber(3)
  set trackTempC($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTrackTempC() => $_has(2);
  @$pb.TagNumber(3)
  void clearTrackTempC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get humidityPct => $_getN(3);
  @$pb.TagNumber(4)
  set humidityPct($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHumidityPct() => $_has(3);
  @$pb.TagNumber(4)
  void clearHumidityPct() => $_clearField(4);
}

/// Data source device info.
class DeviceInfo extends $pb.GeneratedMessage {
  factory DeviceInfo({
    $core.String? deviceModel,
    $core.String? firmwareVersion,
    $core.int? sampleRateHz,
  }) {
    final result = create();
    if (deviceModel != null) result.deviceModel = deviceModel;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (sampleRateHz != null) result.sampleRateHz = sampleRateHz;
    return result;
  }

  DeviceInfo._();

  factory DeviceInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceModel')
    ..aOS(2, _omitFieldNames ? '' : 'firmwareVersion')
    ..aI(3, _omitFieldNames ? '' : 'sampleRateHz',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) =>
      super.copyWith((message) => updates(message as DeviceInfo)) as DeviceInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceInfo create() => DeviceInfo._();
  @$core.override
  DeviceInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceInfo>(create);
  static DeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceModel => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceModel($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceModel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get firmwareVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set firmwareVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFirmwareVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirmwareVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sampleRateHz => $_getIZ(2);
  @$pb.TagNumber(3)
  set sampleRateHz($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSampleRateHz() => $_has(2);
  @$pb.TagNumber(3)
  void clearSampleRateHz() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
