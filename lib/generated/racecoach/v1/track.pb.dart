// This is a generated file - do not edit.
//
// Generated from racecoach/v1/track.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'telemetry.pb.dart' as $0;
import 'track.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'track.pbenum.dart';

/// A racetrack facility, potentially with multiple configurations.
class Track extends $pb.GeneratedMessage {
  factory Track({
    $core.String? trackId,
    $core.String? name,
    $core.String? country,
    $core.String? region,
    $0.GpsData? center,
    $core.double? autoDetectRadiusMeters,
    $core.Iterable<TrackConfiguration>? configurations,
  }) {
    final result = create();
    if (trackId != null) result.trackId = trackId;
    if (name != null) result.name = name;
    if (country != null) result.country = country;
    if (region != null) result.region = region;
    if (center != null) result.center = center;
    if (autoDetectRadiusMeters != null)
      result.autoDetectRadiusMeters = autoDetectRadiusMeters;
    if (configurations != null) result.configurations.addAll(configurations);
    return result;
  }

  Track._();

  factory Track.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Track.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Track',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'trackId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'country')
    ..aOS(4, _omitFieldNames ? '' : 'region')
    ..aOM<$0.GpsData>(5, _omitFieldNames ? '' : 'center',
        subBuilder: $0.GpsData.create)
    ..aD(6, _omitFieldNames ? '' : 'autoDetectRadiusMeters',
        fieldType: $pb.PbFieldType.OF)
    ..pPM<TrackConfiguration>(7, _omitFieldNames ? '' : 'configurations',
        subBuilder: TrackConfiguration.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Track clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Track copyWith(void Function(Track) updates) =>
      super.copyWith((message) => updates(message as Track)) as Track;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Track create() => Track._();
  @$core.override
  Track createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Track getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Track>(create);
  static Track? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get trackId => $_getSZ(0);
  @$pb.TagNumber(1)
  set trackId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTrackId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrackId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get country => $_getSZ(2);
  @$pb.TagNumber(3)
  set country($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCountry() => $_has(2);
  @$pb.TagNumber(3)
  void clearCountry() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get region => $_getSZ(3);
  @$pb.TagNumber(4)
  set region($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRegion() => $_has(3);
  @$pb.TagNumber(4)
  void clearRegion() => $_clearField(4);

  /// Center of the facility for proximity auto-detection.
  @$pb.TagNumber(5)
  $0.GpsData get center => $_getN(4);
  @$pb.TagNumber(5)
  set center($0.GpsData value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCenter() => $_has(4);
  @$pb.TagNumber(5)
  void clearCenter() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.GpsData ensureCenter() => $_ensure(4);

  /// Radius in meters for geofence-based auto-detection.
  @$pb.TagNumber(6)
  $core.double get autoDetectRadiusMeters => $_getN(5);
  @$pb.TagNumber(6)
  set autoDetectRadiusMeters($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAutoDetectRadiusMeters() => $_has(5);
  @$pb.TagNumber(6)
  void clearAutoDetectRadiusMeters() => $_clearField(6);

  /// Available course configurations.
  @$pb.TagNumber(7)
  $pb.PbList<TrackConfiguration> get configurations => $_getList(6);
}

/// A specific course layout within a track facility.
class TrackConfiguration extends $pb.GeneratedMessage {
  factory TrackConfiguration({
    $core.String? configId,
    $core.String? name,
    $core.double? lengthMeters,
    Direction? direction,
    $0.GpsData? finishLineA,
    $0.GpsData? finishLineB,
    $core.Iterable<SectorSplit>? sectors,
    $core.Iterable<$0.GpsData>? centerline,
    $core.Iterable<Corner>? corners,
  }) {
    final result = create();
    if (configId != null) result.configId = configId;
    if (name != null) result.name = name;
    if (lengthMeters != null) result.lengthMeters = lengthMeters;
    if (direction != null) result.direction = direction;
    if (finishLineA != null) result.finishLineA = finishLineA;
    if (finishLineB != null) result.finishLineB = finishLineB;
    if (sectors != null) result.sectors.addAll(sectors);
    if (centerline != null) result.centerline.addAll(centerline);
    if (corners != null) result.corners.addAll(corners);
    return result;
  }

  TrackConfiguration._();

  factory TrackConfiguration.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TrackConfiguration.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrackConfiguration',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aD(3, _omitFieldNames ? '' : 'lengthMeters',
        fieldType: $pb.PbFieldType.OF)
    ..aE<Direction>(4, _omitFieldNames ? '' : 'direction',
        enumValues: Direction.values)
    ..aOM<$0.GpsData>(5, _omitFieldNames ? '' : 'finishLineA',
        subBuilder: $0.GpsData.create)
    ..aOM<$0.GpsData>(6, _omitFieldNames ? '' : 'finishLineB',
        subBuilder: $0.GpsData.create)
    ..pPM<SectorSplit>(7, _omitFieldNames ? '' : 'sectors',
        subBuilder: SectorSplit.create)
    ..pPM<$0.GpsData>(8, _omitFieldNames ? '' : 'centerline',
        subBuilder: $0.GpsData.create)
    ..pPM<Corner>(9, _omitFieldNames ? '' : 'corners',
        subBuilder: Corner.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackConfiguration clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackConfiguration copyWith(void Function(TrackConfiguration) updates) =>
      super.copyWith((message) => updates(message as TrackConfiguration))
          as TrackConfiguration;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrackConfiguration create() => TrackConfiguration._();
  @$core.override
  TrackConfiguration createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TrackConfiguration getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TrackConfiguration>(create);
  static TrackConfiguration? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configId => $_getSZ(0);
  @$pb.TagNumber(1)
  set configId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get lengthMeters => $_getN(2);
  @$pb.TagNumber(3)
  set lengthMeters($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLengthMeters() => $_has(2);
  @$pb.TagNumber(3)
  void clearLengthMeters() => $_clearField(3);

  @$pb.TagNumber(4)
  Direction get direction => $_getN(3);
  @$pb.TagNumber(4)
  set direction(Direction value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDirection() => $_has(3);
  @$pb.TagNumber(4)
  void clearDirection() => $_clearField(4);

  /// Start/finish line (two GPS points forming a line segment).
  @$pb.TagNumber(5)
  $0.GpsData get finishLineA => $_getN(4);
  @$pb.TagNumber(5)
  set finishLineA($0.GpsData value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFinishLineA() => $_has(4);
  @$pb.TagNumber(5)
  void clearFinishLineA() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.GpsData ensureFinishLineA() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.GpsData get finishLineB => $_getN(5);
  @$pb.TagNumber(6)
  set finishLineB($0.GpsData value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFinishLineB() => $_has(5);
  @$pb.TagNumber(6)
  void clearFinishLineB() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.GpsData ensureFinishLineB() => $_ensure(5);

  /// Sector split lines.
  @$pb.TagNumber(7)
  $pb.PbList<SectorSplit> get sectors => $_getList(6);

  /// Track centerline polyline for map overlay.
  @$pb.TagNumber(8)
  $pb.PbList<$0.GpsData> get centerline => $_getList(7);

  /// Named corners / turn landmarks.
  @$pb.TagNumber(9)
  $pb.PbList<Corner> get corners => $_getList(8);
}

/// A sector split line defined by two GPS points.
class SectorSplit extends $pb.GeneratedMessage {
  factory SectorSplit({
    $core.int? sectorNumber,
    $core.String? name,
    $0.GpsData? pointA,
    $0.GpsData? pointB,
  }) {
    final result = create();
    if (sectorNumber != null) result.sectorNumber = sectorNumber;
    if (name != null) result.name = name;
    if (pointA != null) result.pointA = pointA;
    if (pointB != null) result.pointB = pointB;
    return result;
  }

  SectorSplit._();

  factory SectorSplit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SectorSplit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SectorSplit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'sectorNumber',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOM<$0.GpsData>(3, _omitFieldNames ? '' : 'pointA',
        subBuilder: $0.GpsData.create)
    ..aOM<$0.GpsData>(4, _omitFieldNames ? '' : 'pointB',
        subBuilder: $0.GpsData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SectorSplit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SectorSplit copyWith(void Function(SectorSplit) updates) =>
      super.copyWith((message) => updates(message as SectorSplit))
          as SectorSplit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SectorSplit create() => SectorSplit._();
  @$core.override
  SectorSplit createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SectorSplit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SectorSplit>(create);
  static SectorSplit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sectorNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set sectorNumber($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSectorNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSectorNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.GpsData get pointA => $_getN(2);
  @$pb.TagNumber(3)
  set pointA($0.GpsData value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPointA() => $_has(2);
  @$pb.TagNumber(3)
  void clearPointA() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.GpsData ensurePointA() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.GpsData get pointB => $_getN(3);
  @$pb.TagNumber(4)
  set pointB($0.GpsData value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPointB() => $_has(3);
  @$pb.TagNumber(4)
  void clearPointB() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.GpsData ensurePointB() => $_ensure(3);
}

/// A named corner or turn on the track.
class Corner extends $pb.GeneratedMessage {
  factory Corner({
    $core.int? number,
    $core.String? name,
    $0.GpsData? apex,
    $0.GpsData? entry,
    $0.GpsData? exit,
  }) {
    final result = create();
    if (number != null) result.number = number;
    if (name != null) result.name = name;
    if (apex != null) result.apex = apex;
    if (entry != null) result.entry = entry;
    if (exit != null) result.exit = exit;
    return result;
  }

  Corner._();

  factory Corner.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Corner.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Corner',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'number', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOM<$0.GpsData>(3, _omitFieldNames ? '' : 'apex',
        subBuilder: $0.GpsData.create)
    ..aOM<$0.GpsData>(4, _omitFieldNames ? '' : 'entry',
        subBuilder: $0.GpsData.create)
    ..aOM<$0.GpsData>(5, _omitFieldNames ? '' : 'exit',
        subBuilder: $0.GpsData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Corner clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Corner copyWith(void Function(Corner) updates) =>
      super.copyWith((message) => updates(message as Corner)) as Corner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Corner create() => Corner._();
  @$core.override
  Corner createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Corner getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Corner>(create);
  static Corner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get number => $_getIZ(0);
  @$pb.TagNumber(1)
  set number($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.GpsData get apex => $_getN(2);
  @$pb.TagNumber(3)
  set apex($0.GpsData value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasApex() => $_has(2);
  @$pb.TagNumber(3)
  void clearApex() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.GpsData ensureApex() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.GpsData get entry => $_getN(3);
  @$pb.TagNumber(4)
  set entry($0.GpsData value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEntry() => $_has(3);
  @$pb.TagNumber(4)
  void clearEntry() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.GpsData ensureEntry() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.GpsData get exit => $_getN(4);
  @$pb.TagNumber(5)
  set exit($0.GpsData value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasExit() => $_has(4);
  @$pb.TagNumber(5)
  void clearExit() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.GpsData ensureExit() => $_ensure(4);
}

/// Index of all available tracks (for sync).
class TrackLibraryManifest extends $pb.GeneratedMessage {
  factory TrackLibraryManifest({
    $core.Iterable<TrackSummary>? tracks,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (tracks != null) result.tracks.addAll(tracks);
    if (version != null) result.version = version;
    return result;
  }

  TrackLibraryManifest._();

  factory TrackLibraryManifest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TrackLibraryManifest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrackLibraryManifest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..pPM<TrackSummary>(1, _omitFieldNames ? '' : 'tracks',
        subBuilder: TrackSummary.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackLibraryManifest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackLibraryManifest copyWith(void Function(TrackLibraryManifest) updates) =>
      super.copyWith((message) => updates(message as TrackLibraryManifest))
          as TrackLibraryManifest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrackLibraryManifest create() => TrackLibraryManifest._();
  @$core.override
  TrackLibraryManifest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TrackLibraryManifest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TrackLibraryManifest>(create);
  static TrackLibraryManifest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TrackSummary> get tracks => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get version => $_getI64(1);
  @$pb.TagNumber(2)
  set version($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);
}

/// Lightweight summary for the manifest index.
class TrackSummary extends $pb.GeneratedMessage {
  factory TrackSummary({
    $core.String? trackId,
    $core.String? name,
    $core.String? country,
    $core.String? region,
    $0.GpsData? center,
    $core.Iterable<$core.String>? configurationNames,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (trackId != null) result.trackId = trackId;
    if (name != null) result.name = name;
    if (country != null) result.country = country;
    if (region != null) result.region = region;
    if (center != null) result.center = center;
    if (configurationNames != null)
      result.configurationNames.addAll(configurationNames);
    if (version != null) result.version = version;
    return result;
  }

  TrackSummary._();

  factory TrackSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TrackSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrackSummary',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'trackId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'country')
    ..aOS(4, _omitFieldNames ? '' : 'region')
    ..aOM<$0.GpsData>(5, _omitFieldNames ? '' : 'center',
        subBuilder: $0.GpsData.create)
    ..pPS(6, _omitFieldNames ? '' : 'configurationNames')
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrackSummary copyWith(void Function(TrackSummary) updates) =>
      super.copyWith((message) => updates(message as TrackSummary))
          as TrackSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrackSummary create() => TrackSummary._();
  @$core.override
  TrackSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TrackSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TrackSummary>(create);
  static TrackSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get trackId => $_getSZ(0);
  @$pb.TagNumber(1)
  set trackId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTrackId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrackId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get country => $_getSZ(2);
  @$pb.TagNumber(3)
  set country($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCountry() => $_has(2);
  @$pb.TagNumber(3)
  void clearCountry() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get region => $_getSZ(3);
  @$pb.TagNumber(4)
  set region($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRegion() => $_has(3);
  @$pb.TagNumber(4)
  void clearRegion() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.GpsData get center => $_getN(4);
  @$pb.TagNumber(5)
  set center($0.GpsData value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCenter() => $_has(4);
  @$pb.TagNumber(5)
  void clearCenter() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.GpsData ensureCenter() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get configurationNames => $_getList(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get version => $_getI64(6);
  @$pb.TagNumber(7)
  set version($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearVersion() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
