// This is a generated file - do not edit.
//
// Generated from racecoach/v1/session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use speedUnitDescriptor instead')
const SpeedUnit$json = {
  '1': 'SpeedUnit',
  '2': [
    {'1': 'SPEED_UNIT_UNSPECIFIED', '2': 0},
    {'1': 'SPEED_UNIT_MPH', '2': 1},
    {'1': 'SPEED_UNIT_KMH', '2': 2},
  ],
};

/// Descriptor for `SpeedUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List speedUnitDescriptor = $convert.base64Decode(
    'CglTcGVlZFVuaXQSGgoWU1BFRURfVU5JVF9VTlNQRUNJRklFRBAAEhIKDlNQRUVEX1VOSVRfTV'
    'BIEAESEgoOU1BFRURfVU5JVF9LTUgQAg==');

@$core.Deprecated('Use temperatureUnitDescriptor instead')
const TemperatureUnit$json = {
  '1': 'TemperatureUnit',
  '2': [
    {'1': 'TEMPERATURE_UNIT_UNSPECIFIED', '2': 0},
    {'1': 'TEMPERATURE_UNIT_CELSIUS', '2': 1},
    {'1': 'TEMPERATURE_UNIT_FAHRENHEIT', '2': 2},
  ],
};

/// Descriptor for `TemperatureUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List temperatureUnitDescriptor = $convert.base64Decode(
    'Cg9UZW1wZXJhdHVyZVVuaXQSIAocVEVNUEVSQVRVUkVfVU5JVF9VTlNQRUNJRklFRBAAEhwKGF'
    'RFTVBFUkFUVVJFX1VOSVRfQ0VMU0lVUxABEh8KG1RFTVBFUkFUVVJFX1VOSVRfRkFIUkVOSEVJ'
    'VBAC');

@$core.Deprecated('Use surfaceConditionDescriptor instead')
const SurfaceCondition$json = {
  '1': 'SurfaceCondition',
  '2': [
    {'1': 'SURFACE_CONDITION_UNSPECIFIED', '2': 0},
    {'1': 'SURFACE_CONDITION_DRY', '2': 1},
    {'1': 'SURFACE_CONDITION_DAMP', '2': 2},
    {'1': 'SURFACE_CONDITION_WET', '2': 3},
  ],
};

/// Descriptor for `SurfaceCondition`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List surfaceConditionDescriptor = $convert.base64Decode(
    'ChBTdXJmYWNlQ29uZGl0aW9uEiEKHVNVUkZBQ0VfQ09ORElUSU9OX1VOU1BFQ0lGSUVEEAASGQ'
    'oVU1VSRkFDRV9DT05ESVRJT05fRFJZEAESGgoWU1VSRkFDRV9DT05ESVRJT05fREFNUBACEhkK'
    'FVNVUkZBQ0VfQ09ORElUSU9OX1dFVBAD');

@$core.Deprecated('Use sessionTypeDescriptor instead')
const SessionType$json = {
  '1': 'SessionType',
  '2': [
    {'1': 'SESSION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SESSION_TYPE_PRACTICE', '2': 1},
    {'1': 'SESSION_TYPE_QUALIFYING', '2': 2},
    {'1': 'SESSION_TYPE_RACE', '2': 3},
    {'1': 'SESSION_TYPE_TEST', '2': 4},
  ],
};

/// Descriptor for `SessionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sessionTypeDescriptor = $convert.base64Decode(
    'CgtTZXNzaW9uVHlwZRIcChhTRVNTSU9OX1RZUEVfVU5TUEVDSUZJRUQQABIZChVTRVNTSU9OX1'
    'RZUEVfUFJBQ1RJQ0UQARIbChdTRVNTSU9OX1RZUEVfUVVBTElGWUlORxACEhUKEVNFU1NJT05f'
    'VFlQRV9SQUNFEAMSFQoRU0VTU0lPTl9UWVBFX1RFU1QQBA==');

@$core.Deprecated('Use sessionDescriptor instead')
const Session$json = {
  '1': 'Session',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'track_name', '3': 2, '4': 1, '5': 9, '10': 'trackName'},
    {
      '1': 'start_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endTime'
    },
    {
      '1': 'laps',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.Lap',
      '10': 'laps'
    },
    {
      '1': 'config',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.SessionConfig',
      '10': 'config'
    },
    {
      '1': 'active_sources',
      '3': 7,
      '4': 3,
      '5': 14,
      '6': '.racecoach.v1.SourceType',
      '10': 'activeSources'
    },
  ],
};

/// Descriptor for `Session`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDescriptor = $convert.base64Decode(
    'CgdTZXNzaW9uEh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIdCgp0cmFja19uYW1lGA'
    'IgASgJUgl0cmFja05hbWUSOQoKc3RhcnRfdGltZRgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSCXN0YXJ0VGltZRI1CghlbmRfdGltZRgEIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSB2VuZFRpbWUSJQoEbGFwcxgFIAMoCzIRLnJhY2Vjb2FjaC52MS5MYXBSBGxh'
    'cHMSMwoGY29uZmlnGAYgASgLMhsucmFjZWNvYWNoLnYxLlNlc3Npb25Db25maWdSBmNvbmZpZx'
    'I/Cg5hY3RpdmVfc291cmNlcxgHIAMoDjIYLnJhY2Vjb2FjaC52MS5Tb3VyY2VUeXBlUg1hY3Rp'
    'dmVTb3VyY2Vz');

@$core.Deprecated('Use lapDescriptor instead')
const Lap$json = {
  '1': 'Lap',
  '2': [
    {'1': 'lap_number', '3': 1, '4': 1, '5': 13, '10': 'lapNumber'},
    {'1': 'lap_time_seconds', '3': 2, '4': 1, '5': 2, '10': 'lapTimeSeconds'},
    {
      '1': 'telemetry',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.TelemetryFrame',
      '10': 'telemetry'
    },
    {'1': 'is_reference', '3': 4, '4': 1, '5': 8, '10': 'isReference'},
    {
      '1': 'sector_times_seconds',
      '3': 5,
      '4': 3,
      '5': 2,
      '10': 'sectorTimesSeconds'
    },
    {
      '1': 'start_time',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
  ],
};

/// Descriptor for `Lap`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lapDescriptor = $convert.base64Decode(
    'CgNMYXASHQoKbGFwX251bWJlchgBIAEoDVIJbGFwTnVtYmVyEigKEGxhcF90aW1lX3NlY29uZH'
    'MYAiABKAJSDmxhcFRpbWVTZWNvbmRzEjoKCXRlbGVtZXRyeRgDIAMoCzIcLnJhY2Vjb2FjaC52'
    'MS5UZWxlbWV0cnlGcmFtZVIJdGVsZW1ldHJ5EiEKDGlzX3JlZmVyZW5jZRgEIAEoCFILaXNSZW'
    'ZlcmVuY2USMAoUc2VjdG9yX3RpbWVzX3NlY29uZHMYBSADKAJSEnNlY3RvclRpbWVzU2Vjb25k'
    'cxI5CgpzdGFydF90aW1lGAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJc3Rhcn'
    'RUaW1l');

@$core.Deprecated('Use sessionConfigDescriptor instead')
const SessionConfig$json = {
  '1': 'SessionConfig',
  '2': [
    {
      '1': 'finish_line_point_a',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'finishLinePointA'
    },
    {
      '1': 'finish_line_point_b',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'finishLinePointB'
    },
    {
      '1': 'sector_lines',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.SectorLine',
      '10': 'sectorLines'
    },
    {
      '1': 'speed_unit',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.SpeedUnit',
      '10': 'speedUnit'
    },
    {
      '1': 'temp_unit',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.TemperatureUnit',
      '10': 'tempUnit'
    },
    {
      '1': 'audio_coaching_enabled',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'audioCoachingEnabled'
    },
  ],
};

/// Descriptor for `SessionConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionConfigDescriptor = $convert.base64Decode(
    'Cg1TZXNzaW9uQ29uZmlnEkQKE2ZpbmlzaF9saW5lX3BvaW50X2EYASABKAsyFS5yYWNlY29hY2'
    'gudjEuR3BzRGF0YVIQZmluaXNoTGluZVBvaW50QRJEChNmaW5pc2hfbGluZV9wb2ludF9iGAIg'
    'ASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFSEGZpbmlzaExpbmVQb2ludEISOwoMc2VjdG9yX2'
    'xpbmVzGAMgAygLMhgucmFjZWNvYWNoLnYxLlNlY3RvckxpbmVSC3NlY3RvckxpbmVzEjYKCnNw'
    'ZWVkX3VuaXQYBCABKA4yFy5yYWNlY29hY2gudjEuU3BlZWRVbml0UglzcGVlZFVuaXQSOgoJdG'
    'VtcF91bml0GAUgASgOMh0ucmFjZWNvYWNoLnYxLlRlbXBlcmF0dXJlVW5pdFIIdGVtcFVuaXQS'
    'NAoWYXVkaW9fY29hY2hpbmdfZW5hYmxlZBgGIAEoCFIUYXVkaW9Db2FjaGluZ0VuYWJsZWQ=');

@$core.Deprecated('Use sectorLineDescriptor instead')
const SectorLine$json = {
  '1': 'SectorLine',
  '2': [
    {'1': 'sector_number', '3': 1, '4': 1, '5': 13, '10': 'sectorNumber'},
    {
      '1': 'point_a',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'pointA'
    },
    {
      '1': 'point_b',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'pointB'
    },
  ],
};

/// Descriptor for `SectorLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sectorLineDescriptor = $convert.base64Decode(
    'CgpTZWN0b3JMaW5lEiMKDXNlY3Rvcl9udW1iZXIYASABKA1SDHNlY3Rvck51bWJlchIuCgdwb2'
    'ludF9hGAIgASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFSBnBvaW50QRIuCgdwb2ludF9iGAMg'
    'ASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFSBnBvaW50Qg==');

@$core.Deprecated('Use sessionMetaDescriptor instead')
const SessionMeta$json = {
  '1': 'SessionMeta',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'driver_name', '3': 2, '4': 1, '5': 9, '10': 'driverName'},
    {
      '1': 'vehicle',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.Vehicle',
      '10': 'vehicle'
    },
    {
      '1': 'conditions',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.Conditions',
      '10': 'conditions'
    },
    {
      '1': 'session_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.SessionType',
      '10': 'sessionType'
    },
    {
      '1': 'device_info',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.DeviceInfo',
      '10': 'deviceInfo'
    },
    {'1': 'notes', '3': 7, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'created_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `SessionMeta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionMetaDescriptor = $convert.base64Decode(
    'CgtTZXNzaW9uTWV0YRIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSHwoLZHJpdmVyX2'
    '5hbWUYAiABKAlSCmRyaXZlck5hbWUSLwoHdmVoaWNsZRgDIAEoCzIVLnJhY2Vjb2FjaC52MS5W'
    'ZWhpY2xlUgd2ZWhpY2xlEjgKCmNvbmRpdGlvbnMYBCABKAsyGC5yYWNlY29hY2gudjEuQ29uZG'
    'l0aW9uc1IKY29uZGl0aW9ucxI8CgxzZXNzaW9uX3R5cGUYBSABKA4yGS5yYWNlY29hY2gudjEu'
    'U2Vzc2lvblR5cGVSC3Nlc3Npb25UeXBlEjkKC2RldmljZV9pbmZvGAYgASgLMhgucmFjZWNvYW'
    'NoLnYxLkRldmljZUluZm9SCmRldmljZUluZm8SFAoFbm90ZXMYByABKAlSBW5vdGVzEjkKCmNy'
    'ZWF0ZWRfYXQYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQ'
    'oKdXBkYXRlZF9hdBgJIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRB'
    'dA==');

@$core.Deprecated('Use vehicleDescriptor instead')
const Vehicle$json = {
  '1': 'Vehicle',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'make', '3': 2, '4': 1, '5': 9, '10': 'make'},
    {'1': 'model', '3': 3, '4': 1, '5': 9, '10': 'model'},
    {'1': 'year', '3': 4, '4': 1, '5': 13, '10': 'year'},
    {'1': 'vehicle_class', '3': 5, '4': 1, '5': 9, '10': 'vehicleClass'},
    {'1': 'weight_kg', '3': 6, '4': 1, '5': 2, '10': 'weightKg'},
    {'1': 'power_hp', '3': 7, '4': 1, '5': 2, '10': 'powerHp'},
    {'1': 'tire_compound', '3': 8, '4': 1, '5': 9, '10': 'tireCompound'},
    {
      '1': 'tire_pressures',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.TirePressures',
      '10': 'tirePressures'
    },
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `Vehicle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vehicleDescriptor = $convert.base64Decode(
    'CgdWZWhpY2xlEhIKBG5hbWUYASABKAlSBG5hbWUSEgoEbWFrZRgCIAEoCVIEbWFrZRIUCgVtb2'
    'RlbBgDIAEoCVIFbW9kZWwSEgoEeWVhchgEIAEoDVIEeWVhchIjCg12ZWhpY2xlX2NsYXNzGAUg'
    'ASgJUgx2ZWhpY2xlQ2xhc3MSGwoJd2VpZ2h0X2tnGAYgASgCUgh3ZWlnaHRLZxIZCghwb3dlcl'
    '9ocBgHIAEoAlIHcG93ZXJIcBIjCg10aXJlX2NvbXBvdW5kGAggASgJUgx0aXJlQ29tcG91bmQS'
    'QgoOdGlyZV9wcmVzc3VyZXMYCSABKAsyGy5yYWNlY29hY2gudjEuVGlyZVByZXNzdXJlc1INdG'
    'lyZVByZXNzdXJlcxIUCgVub3RlcxgKIAEoCVIFbm90ZXM=');

@$core.Deprecated('Use tirePressuresDescriptor instead')
const TirePressures$json = {
  '1': 'TirePressures',
  '2': [
    {'1': 'front_left_psi', '3': 1, '4': 1, '5': 2, '10': 'frontLeftPsi'},
    {'1': 'front_right_psi', '3': 2, '4': 1, '5': 2, '10': 'frontRightPsi'},
    {'1': 'rear_left_psi', '3': 3, '4': 1, '5': 2, '10': 'rearLeftPsi'},
    {'1': 'rear_right_psi', '3': 4, '4': 1, '5': 2, '10': 'rearRightPsi'},
  ],
};

/// Descriptor for `TirePressures`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tirePressuresDescriptor = $convert.base64Decode(
    'Cg1UaXJlUHJlc3N1cmVzEiQKDmZyb250X2xlZnRfcHNpGAEgASgCUgxmcm9udExlZnRQc2kSJg'
    'oPZnJvbnRfcmlnaHRfcHNpGAIgASgCUg1mcm9udFJpZ2h0UHNpEiIKDXJlYXJfbGVmdF9wc2kY'
    'AyABKAJSC3JlYXJMZWZ0UHNpEiQKDnJlYXJfcmlnaHRfcHNpGAQgASgCUgxyZWFyUmlnaHRQc2'
    'k=');

@$core.Deprecated('Use conditionsDescriptor instead')
const Conditions$json = {
  '1': 'Conditions',
  '2': [
    {
      '1': 'surface',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.SurfaceCondition',
      '10': 'surface'
    },
    {'1': 'ambient_temp_c', '3': 2, '4': 1, '5': 2, '10': 'ambientTempC'},
    {'1': 'track_temp_c', '3': 3, '4': 1, '5': 2, '10': 'trackTempC'},
    {'1': 'humidity_pct', '3': 4, '4': 1, '5': 2, '10': 'humidityPct'},
  ],
};

/// Descriptor for `Conditions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conditionsDescriptor = $convert.base64Decode(
    'CgpDb25kaXRpb25zEjgKB3N1cmZhY2UYASABKA4yHi5yYWNlY29hY2gudjEuU3VyZmFjZUNvbm'
    'RpdGlvblIHc3VyZmFjZRIkCg5hbWJpZW50X3RlbXBfYxgCIAEoAlIMYW1iaWVudFRlbXBDEiAK'
    'DHRyYWNrX3RlbXBfYxgDIAEoAlIKdHJhY2tUZW1wQxIhCgxodW1pZGl0eV9wY3QYBCABKAJSC2'
    'h1bWlkaXR5UGN0');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {'1': 'device_model', '3': 1, '4': 1, '5': 9, '10': 'deviceModel'},
    {'1': 'firmware_version', '3': 2, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {'1': 'sample_rate_hz', '3': 3, '4': 1, '5': 13, '10': 'sampleRateHz'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEiEKDGRldmljZV9tb2RlbBgBIAEoCVILZGV2aWNlTW9kZWwSKQoQZmlybX'
    'dhcmVfdmVyc2lvbhgCIAEoCVIPZmlybXdhcmVWZXJzaW9uEiQKDnNhbXBsZV9yYXRlX2h6GAMg'
    'ASgNUgxzYW1wbGVSYXRlSHo=');
