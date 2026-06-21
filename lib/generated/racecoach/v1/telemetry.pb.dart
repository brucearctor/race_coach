// This is a generated file - do not edit.
//
// Generated from racecoach/v1/telemetry.proto.

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

import 'telemetry.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'telemetry.pbenum.dart';

/// A single telemetry sample from any data source. Each source fills the
/// sub-messages it can provide; absent sub-messages mean the source doesn't
/// produce that type of data (e.g., OBD has no GPS).
class TelemetryFrame extends $pb.GeneratedMessage {
  factory TelemetryFrame({
    $0.Timestamp? deviceTimestamp,
    $0.Timestamp? arrivalTimestamp,
    GpsData? gps,
    MotionData? motion,
    EngineData? engine,
    FuelData? fuel,
    SourceType? sourceType,
    $core.String? sourceDeviceId,
    $core.List<$core.int>? rawPayload,
  }) {
    final result = create();
    if (deviceTimestamp != null) result.deviceTimestamp = deviceTimestamp;
    if (arrivalTimestamp != null) result.arrivalTimestamp = arrivalTimestamp;
    if (gps != null) result.gps = gps;
    if (motion != null) result.motion = motion;
    if (engine != null) result.engine = engine;
    if (fuel != null) result.fuel = fuel;
    if (sourceType != null) result.sourceType = sourceType;
    if (sourceDeviceId != null) result.sourceDeviceId = sourceDeviceId;
    if (rawPayload != null) result.rawPayload = rawPayload;
    return result;
  }

  TelemetryFrame._();

  factory TelemetryFrame.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TelemetryFrame.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TelemetryFrame',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'deviceTimestamp',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'arrivalTimestamp',
        subBuilder: $0.Timestamp.create)
    ..aOM<GpsData>(3, _omitFieldNames ? '' : 'gps', subBuilder: GpsData.create)
    ..aOM<MotionData>(4, _omitFieldNames ? '' : 'motion',
        subBuilder: MotionData.create)
    ..aOM<EngineData>(5, _omitFieldNames ? '' : 'engine',
        subBuilder: EngineData.create)
    ..aOM<FuelData>(6, _omitFieldNames ? '' : 'fuel',
        subBuilder: FuelData.create)
    ..aE<SourceType>(10, _omitFieldNames ? '' : 'sourceType',
        enumValues: SourceType.values)
    ..aOS(11, _omitFieldNames ? '' : 'sourceDeviceId')
    ..a<$core.List<$core.int>>(
        15, _omitFieldNames ? '' : 'rawPayload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TelemetryFrame clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TelemetryFrame copyWith(void Function(TelemetryFrame) updates) =>
      super.copyWith((message) => updates(message as TelemetryFrame))
          as TelemetryFrame;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TelemetryFrame create() => TelemetryFrame._();
  @$core.override
  TelemetryFrame createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TelemetryFrame getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TelemetryFrame>(create);
  static TelemetryFrame? _defaultInstance;

  /// When the measurement was actually taken (device clock).
  /// For sources without a clock (e.g., OBD), this is unset.
  @$pb.TagNumber(1)
  $0.Timestamp get deviceTimestamp => $_getN(0);
  @$pb.TagNumber(1)
  set deviceTimestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureDeviceTimestamp() => $_ensure(0);

  /// When the phone received the data. Always set.
  @$pb.TagNumber(2)
  $0.Timestamp get arrivalTimestamp => $_getN(1);
  @$pb.TagNumber(2)
  set arrivalTimestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasArrivalTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearArrivalTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureArrivalTimestamp() => $_ensure(1);

  /// Data sub-messages — each source populates what it can.
  @$pb.TagNumber(3)
  GpsData get gps => $_getN(2);
  @$pb.TagNumber(3)
  set gps(GpsData value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasGps() => $_has(2);
  @$pb.TagNumber(3)
  void clearGps() => $_clearField(3);
  @$pb.TagNumber(3)
  GpsData ensureGps() => $_ensure(2);

  @$pb.TagNumber(4)
  MotionData get motion => $_getN(3);
  @$pb.TagNumber(4)
  set motion(MotionData value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMotion() => $_has(3);
  @$pb.TagNumber(4)
  void clearMotion() => $_clearField(4);
  @$pb.TagNumber(4)
  MotionData ensureMotion() => $_ensure(3);

  @$pb.TagNumber(5)
  EngineData get engine => $_getN(4);
  @$pb.TagNumber(5)
  set engine(EngineData value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEngine() => $_has(4);
  @$pb.TagNumber(5)
  void clearEngine() => $_clearField(5);
  @$pb.TagNumber(5)
  EngineData ensureEngine() => $_ensure(4);

  @$pb.TagNumber(6)
  FuelData get fuel => $_getN(5);
  @$pb.TagNumber(6)
  set fuel(FuelData value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFuel() => $_has(5);
  @$pb.TagNumber(6)
  void clearFuel() => $_clearField(6);
  @$pb.TagNumber(6)
  FuelData ensureFuel() => $_ensure(5);

  /// Source identification.
  @$pb.TagNumber(10)
  SourceType get sourceType => $_getN(6);
  @$pb.TagNumber(10)
  set sourceType(SourceType value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSourceType() => $_has(6);
  @$pb.TagNumber(10)
  void clearSourceType() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get sourceDeviceId => $_getSZ(7);
  @$pb.TagNumber(11)
  set sourceDeviceId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(11)
  $core.bool hasSourceDeviceId() => $_has(7);
  @$pb.TagNumber(11)
  void clearSourceDeviceId() => $_clearField(11);

  /// Original bytes from the device for replay / re-parsing.
  @$pb.TagNumber(15)
  $core.List<$core.int> get rawPayload => $_getN(8);
  @$pb.TagNumber(15)
  set rawPayload($core.List<$core.int> value) => $_setBytes(8, value);
  @$pb.TagNumber(15)
  $core.bool hasRawPayload() => $_has(8);
  @$pb.TagNumber(15)
  void clearRawPayload() => $_clearField(15);
}

/// GPS position, speed, and quality data.
class GpsData extends $pb.GeneratedMessage {
  factory GpsData({
    $core.double? latitude,
    $core.double? longitude,
    $core.double? speedKmh,
    $core.double? headingDegrees,
    $core.double? altitudeMeters,
    $core.int? satellites,
    $core.double? hdop,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (speedKmh != null) result.speedKmh = speedKmh;
    if (headingDegrees != null) result.headingDegrees = headingDegrees;
    if (altitudeMeters != null) result.altitudeMeters = altitudeMeters;
    if (satellites != null) result.satellites = satellites;
    if (hdop != null) result.hdop = hdop;
    return result;
  }

  GpsData._();

  factory GpsData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GpsData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GpsData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..aD(3, _omitFieldNames ? '' : 'speedKmh', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'headingDegrees',
        fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'altitudeMeters',
        fieldType: $pb.PbFieldType.OF)
    ..aI(6, _omitFieldNames ? '' : 'satellites', fieldType: $pb.PbFieldType.OU3)
    ..aD(7, _omitFieldNames ? '' : 'hdop', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpsData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpsData copyWith(void Function(GpsData) updates) =>
      super.copyWith((message) => updates(message as GpsData)) as GpsData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GpsData create() => GpsData._();
  @$core.override
  GpsData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GpsData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GpsData>(create);
  static GpsData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get speedKmh => $_getN(2);
  @$pb.TagNumber(3)
  set speedKmh($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpeedKmh() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpeedKmh() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get headingDegrees => $_getN(3);
  @$pb.TagNumber(4)
  set headingDegrees($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeadingDegrees() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeadingDegrees() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get altitudeMeters => $_getN(4);
  @$pb.TagNumber(5)
  set altitudeMeters($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAltitudeMeters() => $_has(4);
  @$pb.TagNumber(5)
  void clearAltitudeMeters() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get satellites => $_getIZ(5);
  @$pb.TagNumber(6)
  set satellites($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSatellites() => $_has(5);
  @$pb.TagNumber(6)
  void clearSatellites() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get hdop => $_getN(6);
  @$pb.TagNumber(7)
  set hdop($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHdop() => $_has(6);
  @$pb.TagNumber(7)
  void clearHdop() => $_clearField(7);
}

/// Inertial / motion data (accelerometer, gyroscope).
class MotionData extends $pb.GeneratedMessage {
  factory MotionData({
    $core.double? gForceLateral,
    $core.double? gForceLongitudinal,
    $core.double? gForceVertical,
    $core.double? yawRateDps,
    $core.double? pitchRateDps,
    $core.double? rollRateDps,
  }) {
    final result = create();
    if (gForceLateral != null) result.gForceLateral = gForceLateral;
    if (gForceLongitudinal != null)
      result.gForceLongitudinal = gForceLongitudinal;
    if (gForceVertical != null) result.gForceVertical = gForceVertical;
    if (yawRateDps != null) result.yawRateDps = yawRateDps;
    if (pitchRateDps != null) result.pitchRateDps = pitchRateDps;
    if (rollRateDps != null) result.rollRateDps = rollRateDps;
    return result;
  }

  MotionData._();

  factory MotionData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MotionData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MotionData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'gForceLateral',
        fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'gForceLongitudinal',
        fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'gForceVertical',
        fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'yawRateDps', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'pitchRateDps',
        fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'rollRateDps', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MotionData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MotionData copyWith(void Function(MotionData) updates) =>
      super.copyWith((message) => updates(message as MotionData)) as MotionData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MotionData create() => MotionData._();
  @$core.override
  MotionData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MotionData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MotionData>(create);
  static MotionData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get gForceLateral => $_getN(0);
  @$pb.TagNumber(1)
  set gForceLateral($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGForceLateral() => $_has(0);
  @$pb.TagNumber(1)
  void clearGForceLateral() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get gForceLongitudinal => $_getN(1);
  @$pb.TagNumber(2)
  set gForceLongitudinal($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGForceLongitudinal() => $_has(1);
  @$pb.TagNumber(2)
  void clearGForceLongitudinal() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get gForceVertical => $_getN(2);
  @$pb.TagNumber(3)
  set gForceVertical($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGForceVertical() => $_has(2);
  @$pb.TagNumber(3)
  void clearGForceVertical() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get yawRateDps => $_getN(3);
  @$pb.TagNumber(4)
  set yawRateDps($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYawRateDps() => $_has(3);
  @$pb.TagNumber(4)
  void clearYawRateDps() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get pitchRateDps => $_getN(4);
  @$pb.TagNumber(5)
  set pitchRateDps($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPitchRateDps() => $_has(4);
  @$pb.TagNumber(5)
  void clearPitchRateDps() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get rollRateDps => $_getN(5);
  @$pb.TagNumber(6)
  set rollRateDps($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRollRateDps() => $_has(5);
  @$pb.TagNumber(6)
  void clearRollRateDps() => $_clearField(6);
}

/// Engine / ECU data (from OBD-II or CAN bus).
class EngineData extends $pb.GeneratedMessage {
  factory EngineData({
    $core.double? rpm,
    $core.double? throttlePct,
    $core.double? coolantTempC,
    $core.double? intakeTempC,
    $core.double? engineLoadPct,
    $core.double? timingAdvanceDeg,
    $core.double? mafGps,
  }) {
    final result = create();
    if (rpm != null) result.rpm = rpm;
    if (throttlePct != null) result.throttlePct = throttlePct;
    if (coolantTempC != null) result.coolantTempC = coolantTempC;
    if (intakeTempC != null) result.intakeTempC = intakeTempC;
    if (engineLoadPct != null) result.engineLoadPct = engineLoadPct;
    if (timingAdvanceDeg != null) result.timingAdvanceDeg = timingAdvanceDeg;
    if (mafGps != null) result.mafGps = mafGps;
    return result;
  }

  EngineData._();

  factory EngineData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EngineData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EngineData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'rpm', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'throttlePct', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'coolantTempC',
        fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'intakeTempC', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'engineLoadPct',
        fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'timingAdvanceDeg',
        fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'mafGps', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EngineData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EngineData copyWith(void Function(EngineData) updates) =>
      super.copyWith((message) => updates(message as EngineData)) as EngineData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EngineData create() => EngineData._();
  @$core.override
  EngineData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EngineData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EngineData>(create);
  static EngineData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get rpm => $_getN(0);
  @$pb.TagNumber(1)
  set rpm($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRpm() => $_has(0);
  @$pb.TagNumber(1)
  void clearRpm() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get throttlePct => $_getN(1);
  @$pb.TagNumber(2)
  set throttlePct($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasThrottlePct() => $_has(1);
  @$pb.TagNumber(2)
  void clearThrottlePct() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get coolantTempC => $_getN(2);
  @$pb.TagNumber(3)
  set coolantTempC($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCoolantTempC() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoolantTempC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get intakeTempC => $_getN(3);
  @$pb.TagNumber(4)
  set intakeTempC($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIntakeTempC() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntakeTempC() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get engineLoadPct => $_getN(4);
  @$pb.TagNumber(5)
  set engineLoadPct($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEngineLoadPct() => $_has(4);
  @$pb.TagNumber(5)
  void clearEngineLoadPct() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get timingAdvanceDeg => $_getN(5);
  @$pb.TagNumber(6)
  set timingAdvanceDeg($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimingAdvanceDeg() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimingAdvanceDeg() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get mafGps => $_getN(6);
  @$pb.TagNumber(7)
  set mafGps($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMafGps() => $_has(6);
  @$pb.TagNumber(7)
  void clearMafGps() => $_clearField(7);
}

/// Fuel system data (from OBD-II).
class FuelData extends $pb.GeneratedMessage {
  factory FuelData({
    $core.double? shortFuelTrim1Pct,
    $core.double? shortFuelTrim2Pct,
    $core.double? longFuelTrim1Pct,
    $core.double? longFuelTrim2Pct,
    $core.double? fuelLevelPct,
  }) {
    final result = create();
    if (shortFuelTrim1Pct != null) result.shortFuelTrim1Pct = shortFuelTrim1Pct;
    if (shortFuelTrim2Pct != null) result.shortFuelTrim2Pct = shortFuelTrim2Pct;
    if (longFuelTrim1Pct != null) result.longFuelTrim1Pct = longFuelTrim1Pct;
    if (longFuelTrim2Pct != null) result.longFuelTrim2Pct = longFuelTrim2Pct;
    if (fuelLevelPct != null) result.fuelLevelPct = fuelLevelPct;
    return result;
  }

  FuelData._();

  factory FuelData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FuelData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FuelData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'shortFuelTrim1Pct',
        protoName: 'short_fuel_trim_1_pct', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'shortFuelTrim2Pct',
        protoName: 'short_fuel_trim_2_pct', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'longFuelTrim1Pct',
        protoName: 'long_fuel_trim_1_pct', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'longFuelTrim2Pct',
        protoName: 'long_fuel_trim_2_pct', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'fuelLevelPct',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FuelData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FuelData copyWith(void Function(FuelData) updates) =>
      super.copyWith((message) => updates(message as FuelData)) as FuelData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FuelData create() => FuelData._();
  @$core.override
  FuelData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FuelData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FuelData>(create);
  static FuelData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get shortFuelTrim1Pct => $_getN(0);
  @$pb.TagNumber(1)
  set shortFuelTrim1Pct($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShortFuelTrim1Pct() => $_has(0);
  @$pb.TagNumber(1)
  void clearShortFuelTrim1Pct() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get shortFuelTrim2Pct => $_getN(1);
  @$pb.TagNumber(2)
  set shortFuelTrim2Pct($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShortFuelTrim2Pct() => $_has(1);
  @$pb.TagNumber(2)
  void clearShortFuelTrim2Pct() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get longFuelTrim1Pct => $_getN(2);
  @$pb.TagNumber(3)
  set longFuelTrim1Pct($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLongFuelTrim1Pct() => $_has(2);
  @$pb.TagNumber(3)
  void clearLongFuelTrim1Pct() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get longFuelTrim2Pct => $_getN(3);
  @$pb.TagNumber(4)
  set longFuelTrim2Pct($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLongFuelTrim2Pct() => $_has(3);
  @$pb.TagNumber(4)
  void clearLongFuelTrim2Pct() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get fuelLevelPct => $_getN(4);
  @$pb.TagNumber(5)
  set fuelLevelPct($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFuelLevelPct() => $_has(4);
  @$pb.TagNumber(5)
  void clearFuelLevelPct() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
