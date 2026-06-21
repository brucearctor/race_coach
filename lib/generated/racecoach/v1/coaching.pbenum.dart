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

class CoachingCueType extends $pb.ProtobufEnum {
  static const CoachingCueType COACHING_CUE_TYPE_UNSPECIFIED =
      CoachingCueType._(
          0, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_UNSPECIFIED');
  static const CoachingCueType COACHING_CUE_TYPE_BRAKING =
      CoachingCueType._(1, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_BRAKING');
  static const CoachingCueType COACHING_CUE_TYPE_THROTTLE =
      CoachingCueType._(2, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_THROTTLE');
  static const CoachingCueType COACHING_CUE_TYPE_LINE =
      CoachingCueType._(3, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_LINE');
  static const CoachingCueType COACHING_CUE_TYPE_SPEED =
      CoachingCueType._(4, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_SPEED');
  static const CoachingCueType COACHING_CUE_TYPE_SECTOR_TIME =
      CoachingCueType._(
          5, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_SECTOR_TIME');
  static const CoachingCueType COACHING_CUE_TYPE_LAP_TIME =
      CoachingCueType._(6, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_LAP_TIME');
  static const CoachingCueType COACHING_CUE_TYPE_G_FORCE =
      CoachingCueType._(7, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_G_FORCE');
  static const CoachingCueType COACHING_CUE_TYPE_GENERAL =
      CoachingCueType._(8, _omitEnumNames ? '' : 'COACHING_CUE_TYPE_GENERAL');

  static const $core.List<CoachingCueType> values = <CoachingCueType>[
    COACHING_CUE_TYPE_UNSPECIFIED,
    COACHING_CUE_TYPE_BRAKING,
    COACHING_CUE_TYPE_THROTTLE,
    COACHING_CUE_TYPE_LINE,
    COACHING_CUE_TYPE_SPEED,
    COACHING_CUE_TYPE_SECTOR_TIME,
    COACHING_CUE_TYPE_LAP_TIME,
    COACHING_CUE_TYPE_G_FORCE,
    COACHING_CUE_TYPE_GENERAL,
  ];

  static final $core.List<CoachingCueType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static CoachingCueType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CoachingCueType._(super.value, super.name);
}

class CuePriority extends $pb.ProtobufEnum {
  static const CuePriority CUE_PRIORITY_UNSPECIFIED =
      CuePriority._(0, _omitEnumNames ? '' : 'CUE_PRIORITY_UNSPECIFIED');
  static const CuePriority CUE_PRIORITY_LOW =
      CuePriority._(1, _omitEnumNames ? '' : 'CUE_PRIORITY_LOW');
  static const CuePriority CUE_PRIORITY_MEDIUM =
      CuePriority._(2, _omitEnumNames ? '' : 'CUE_PRIORITY_MEDIUM');
  static const CuePriority CUE_PRIORITY_HIGH =
      CuePriority._(3, _omitEnumNames ? '' : 'CUE_PRIORITY_HIGH');
  static const CuePriority CUE_PRIORITY_CRITICAL =
      CuePriority._(4, _omitEnumNames ? '' : 'CUE_PRIORITY_CRITICAL');

  static const $core.List<CuePriority> values = <CuePriority>[
    CUE_PRIORITY_UNSPECIFIED,
    CUE_PRIORITY_LOW,
    CUE_PRIORITY_MEDIUM,
    CUE_PRIORITY_HIGH,
    CUE_PRIORITY_CRITICAL,
  ];

  static final $core.List<CuePriority?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CuePriority? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CuePriority._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
