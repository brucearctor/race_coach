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

class SpeedUnit extends $pb.ProtobufEnum {
  static const SpeedUnit SPEED_UNIT_UNSPECIFIED =
      SpeedUnit._(0, _omitEnumNames ? '' : 'SPEED_UNIT_UNSPECIFIED');
  static const SpeedUnit SPEED_UNIT_MPH =
      SpeedUnit._(1, _omitEnumNames ? '' : 'SPEED_UNIT_MPH');
  static const SpeedUnit SPEED_UNIT_KMH =
      SpeedUnit._(2, _omitEnumNames ? '' : 'SPEED_UNIT_KMH');

  static const $core.List<SpeedUnit> values = <SpeedUnit>[
    SPEED_UNIT_UNSPECIFIED,
    SPEED_UNIT_MPH,
    SPEED_UNIT_KMH,
  ];

  static final $core.List<SpeedUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SpeedUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpeedUnit._(super.value, super.name);
}

class TemperatureUnit extends $pb.ProtobufEnum {
  static const TemperatureUnit TEMPERATURE_UNIT_UNSPECIFIED = TemperatureUnit._(
      0, _omitEnumNames ? '' : 'TEMPERATURE_UNIT_UNSPECIFIED');
  static const TemperatureUnit TEMPERATURE_UNIT_CELSIUS =
      TemperatureUnit._(1, _omitEnumNames ? '' : 'TEMPERATURE_UNIT_CELSIUS');
  static const TemperatureUnit TEMPERATURE_UNIT_FAHRENHEIT =
      TemperatureUnit._(2, _omitEnumNames ? '' : 'TEMPERATURE_UNIT_FAHRENHEIT');

  static const $core.List<TemperatureUnit> values = <TemperatureUnit>[
    TEMPERATURE_UNIT_UNSPECIFIED,
    TEMPERATURE_UNIT_CELSIUS,
    TEMPERATURE_UNIT_FAHRENHEIT,
  ];

  static final $core.List<TemperatureUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static TemperatureUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TemperatureUnit._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
