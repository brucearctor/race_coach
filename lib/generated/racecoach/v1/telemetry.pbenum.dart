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

class SourceType extends $pb.ProtobufEnum {
  static const SourceType SOURCE_TYPE_UNSPECIFIED =
      SourceType._(0, _omitEnumNames ? '' : 'SOURCE_TYPE_UNSPECIFIED');
  static const SourceType SOURCE_TYPE_RACEBOX_MINI =
      SourceType._(1, _omitEnumNames ? '' : 'SOURCE_TYPE_RACEBOX_MINI');
  static const SourceType SOURCE_TYPE_VBOX =
      SourceType._(2, _omitEnumNames ? '' : 'SOURCE_TYPE_VBOX');
  static const SourceType SOURCE_TYPE_OBD_BLE =
      SourceType._(3, _omitEnumNames ? '' : 'SOURCE_TYPE_OBD_BLE');
  static const SourceType SOURCE_TYPE_PHONE_GPS =
      SourceType._(4, _omitEnumNames ? '' : 'SOURCE_TYPE_PHONE_GPS');
  static const SourceType SOURCE_TYPE_PHONE_IMU =
      SourceType._(5, _omitEnumNames ? '' : 'SOURCE_TYPE_PHONE_IMU');
  static const SourceType SOURCE_TYPE_AIM =
      SourceType._(6, _omitEnumNames ? '' : 'SOURCE_TYPE_AIM');
  static const SourceType SOURCE_TYPE_GOPRO =
      SourceType._(7, _omitEnumNames ? '' : 'SOURCE_TYPE_GOPRO');

  static const $core.List<SourceType> values = <SourceType>[
    SOURCE_TYPE_UNSPECIFIED,
    SOURCE_TYPE_RACEBOX_MINI,
    SOURCE_TYPE_VBOX,
    SOURCE_TYPE_OBD_BLE,
    SOURCE_TYPE_PHONE_GPS,
    SOURCE_TYPE_PHONE_IMU,
    SOURCE_TYPE_AIM,
    SOURCE_TYPE_GOPRO,
  ];

  static final $core.List<SourceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static SourceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SourceType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
