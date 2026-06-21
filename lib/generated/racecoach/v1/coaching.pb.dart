// This is a generated file - do not edit.
//
// Generated from racecoach/v1/coaching.proto.

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

import 'coaching.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'coaching.pbenum.dart';

/// A coaching cue to be spoken to the driver.
class CoachingCue extends $pb.GeneratedMessage {
  factory CoachingCue({
    CoachingCueType? type,
    $core.String? message,
    CuePriority? priority,
    $0.Timestamp? timestamp,
    $core.int? sectorNumber,
    $core.double? deltaSeconds,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (message != null) result.message = message;
    if (priority != null) result.priority = priority;
    if (timestamp != null) result.timestamp = timestamp;
    if (sectorNumber != null) result.sectorNumber = sectorNumber;
    if (deltaSeconds != null) result.deltaSeconds = deltaSeconds;
    return result;
  }

  CoachingCue._();

  factory CoachingCue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CoachingCue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CoachingCue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'racecoach.v1'),
      createEmptyInstance: create)
    ..aE<CoachingCueType>(1, _omitFieldNames ? '' : 'type',
        enumValues: CoachingCueType.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aE<CuePriority>(3, _omitFieldNames ? '' : 'priority',
        enumValues: CuePriority.values)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aI(5, _omitFieldNames ? '' : 'sectorNumber',
        fieldType: $pb.PbFieldType.OU3)
    ..aD(6, _omitFieldNames ? '' : 'deltaSeconds',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoachingCue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoachingCue copyWith(void Function(CoachingCue) updates) =>
      super.copyWith((message) => updates(message as CoachingCue))
          as CoachingCue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CoachingCue create() => CoachingCue._();
  @$core.override
  CoachingCue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CoachingCue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CoachingCue>(create);
  static CoachingCue? _defaultInstance;

  @$pb.TagNumber(1)
  CoachingCueType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(CoachingCueType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  CuePriority get priority => $_getN(2);
  @$pb.TagNumber(3)
  set priority(CuePriority value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPriority() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriority() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTimestamp() => $_ensure(3);

  /// Optional: which sector/corner this cue relates to.
  @$pb.TagNumber(5)
  $core.int get sectorNumber => $_getIZ(4);
  @$pb.TagNumber(5)
  set sectorNumber($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSectorNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearSectorNumber() => $_clearField(5);

  /// Optional: the delta that triggered this cue (e.g., +0.3s slower).
  @$pb.TagNumber(6)
  $core.double get deltaSeconds => $_getN(5);
  @$pb.TagNumber(6)
  set deltaSeconds($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDeltaSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeltaSeconds() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
