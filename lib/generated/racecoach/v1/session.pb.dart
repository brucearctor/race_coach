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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
