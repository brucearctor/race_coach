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
