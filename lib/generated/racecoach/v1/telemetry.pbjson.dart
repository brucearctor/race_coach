// This is a generated file - do not edit.
//
// Generated from racecoach/v1/telemetry.proto.

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

@$core.Deprecated('Use sourceTypeDescriptor instead')
const SourceType$json = {
  '1': 'SourceType',
  '2': [
    {'1': 'SOURCE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SOURCE_TYPE_RACEBOX_MINI', '2': 1},
    {'1': 'SOURCE_TYPE_VBOX', '2': 2},
    {'1': 'SOURCE_TYPE_OBD_BLE', '2': 3},
    {'1': 'SOURCE_TYPE_PHONE_GPS', '2': 4},
    {'1': 'SOURCE_TYPE_PHONE_IMU', '2': 5},
    {'1': 'SOURCE_TYPE_AIM', '2': 6},
    {'1': 'SOURCE_TYPE_GOPRO', '2': 7},
  ],
};

/// Descriptor for `SourceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sourceTypeDescriptor = $convert.base64Decode(
    'CgpTb3VyY2VUeXBlEhsKF1NPVVJDRV9UWVBFX1VOU1BFQ0lGSUVEEAASHAoYU09VUkNFX1RZUE'
    'VfUkFDRUJPWF9NSU5JEAESFAoQU09VUkNFX1RZUEVfVkJPWBACEhcKE1NPVVJDRV9UWVBFX09C'
    'RF9CTEUQAxIZChVTT1VSQ0VfVFlQRV9QSE9ORV9HUFMQBBIZChVTT1VSQ0VfVFlQRV9QSE9ORV'
    '9JTVUQBRITCg9TT1VSQ0VfVFlQRV9BSU0QBhIVChFTT1VSQ0VfVFlQRV9HT1BSTxAH');

@$core.Deprecated('Use telemetryFrameDescriptor instead')
const TelemetryFrame$json = {
  '1': 'TelemetryFrame',
  '2': [
    {
      '1': 'device_timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'deviceTimestamp'
    },
    {
      '1': 'arrival_timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'arrivalTimestamp'
    },
    {
      '1': 'gps',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'gps'
    },
    {
      '1': 'motion',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.MotionData',
      '10': 'motion'
    },
    {
      '1': 'engine',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.EngineData',
      '10': 'engine'
    },
    {
      '1': 'fuel',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.FuelData',
      '10': 'fuel'
    },
    {
      '1': 'source_type',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.SourceType',
      '10': 'sourceType'
    },
    {'1': 'source_device_id', '3': 11, '4': 1, '5': 9, '10': 'sourceDeviceId'},
    {'1': 'raw_payload', '3': 15, '4': 1, '5': 12, '10': 'rawPayload'},
  ],
};

/// Descriptor for `TelemetryFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List telemetryFrameDescriptor = $convert.base64Decode(
    'Cg5UZWxlbWV0cnlGcmFtZRJFChBkZXZpY2VfdGltZXN0YW1wGAEgASgLMhouZ29vZ2xlLnByb3'
    'RvYnVmLlRpbWVzdGFtcFIPZGV2aWNlVGltZXN0YW1wEkcKEWFycml2YWxfdGltZXN0YW1wGAIg'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIQYXJyaXZhbFRpbWVzdGFtcBInCgNncH'
    'MYAyABKAsyFS5yYWNlY29hY2gudjEuR3BzRGF0YVIDZ3BzEjAKBm1vdGlvbhgEIAEoCzIYLnJh'
    'Y2Vjb2FjaC52MS5Nb3Rpb25EYXRhUgZtb3Rpb24SMAoGZW5naW5lGAUgASgLMhgucmFjZWNvYW'
    'NoLnYxLkVuZ2luZURhdGFSBmVuZ2luZRIqCgRmdWVsGAYgASgLMhYucmFjZWNvYWNoLnYxLkZ1'
    'ZWxEYXRhUgRmdWVsEjkKC3NvdXJjZV90eXBlGAogASgOMhgucmFjZWNvYWNoLnYxLlNvdXJjZV'
    'R5cGVSCnNvdXJjZVR5cGUSKAoQc291cmNlX2RldmljZV9pZBgLIAEoCVIOc291cmNlRGV2aWNl'
    'SWQSHwoLcmF3X3BheWxvYWQYDyABKAxSCnJhd1BheWxvYWQ=');

@$core.Deprecated('Use gpsDataDescriptor instead')
const GpsData$json = {
  '1': 'GpsData',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'speed_kmh', '3': 3, '4': 1, '5': 2, '10': 'speedKmh'},
    {'1': 'heading_degrees', '3': 4, '4': 1, '5': 2, '10': 'headingDegrees'},
    {'1': 'altitude_meters', '3': 5, '4': 1, '5': 2, '10': 'altitudeMeters'},
    {'1': 'satellites', '3': 6, '4': 1, '5': 13, '10': 'satellites'},
    {'1': 'hdop', '3': 7, '4': 1, '5': 2, '10': 'hdop'},
  ],
};

/// Descriptor for `GpsData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpsDataDescriptor = $convert.base64Decode(
    'CgdHcHNEYXRhEhoKCGxhdGl0dWRlGAEgASgBUghsYXRpdHVkZRIcCglsb25naXR1ZGUYAiABKA'
    'FSCWxvbmdpdHVkZRIbCglzcGVlZF9rbWgYAyABKAJSCHNwZWVkS21oEicKD2hlYWRpbmdfZGVn'
    'cmVlcxgEIAEoAlIOaGVhZGluZ0RlZ3JlZXMSJwoPYWx0aXR1ZGVfbWV0ZXJzGAUgASgCUg5hbH'
    'RpdHVkZU1ldGVycxIeCgpzYXRlbGxpdGVzGAYgASgNUgpzYXRlbGxpdGVzEhIKBGhkb3AYByAB'
    'KAJSBGhkb3A=');

@$core.Deprecated('Use motionDataDescriptor instead')
const MotionData$json = {
  '1': 'MotionData',
  '2': [
    {'1': 'g_force_lateral', '3': 1, '4': 1, '5': 2, '10': 'gForceLateral'},
    {
      '1': 'g_force_longitudinal',
      '3': 2,
      '4': 1,
      '5': 2,
      '10': 'gForceLongitudinal'
    },
    {'1': 'g_force_vertical', '3': 3, '4': 1, '5': 2, '10': 'gForceVertical'},
    {'1': 'yaw_rate_dps', '3': 4, '4': 1, '5': 2, '10': 'yawRateDps'},
    {'1': 'pitch_rate_dps', '3': 5, '4': 1, '5': 2, '10': 'pitchRateDps'},
    {'1': 'roll_rate_dps', '3': 6, '4': 1, '5': 2, '10': 'rollRateDps'},
  ],
};

/// Descriptor for `MotionData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List motionDataDescriptor = $convert.base64Decode(
    'CgpNb3Rpb25EYXRhEiYKD2dfZm9yY2VfbGF0ZXJhbBgBIAEoAlINZ0ZvcmNlTGF0ZXJhbBIwCh'
    'RnX2ZvcmNlX2xvbmdpdHVkaW5hbBgCIAEoAlISZ0ZvcmNlTG9uZ2l0dWRpbmFsEigKEGdfZm9y'
    'Y2VfdmVydGljYWwYAyABKAJSDmdGb3JjZVZlcnRpY2FsEiAKDHlhd19yYXRlX2RwcxgEIAEoAl'
    'IKeWF3UmF0ZURwcxIkCg5waXRjaF9yYXRlX2RwcxgFIAEoAlIMcGl0Y2hSYXRlRHBzEiIKDXJv'
    'bGxfcmF0ZV9kcHMYBiABKAJSC3JvbGxSYXRlRHBz');

@$core.Deprecated('Use engineDataDescriptor instead')
const EngineData$json = {
  '1': 'EngineData',
  '2': [
    {'1': 'rpm', '3': 1, '4': 1, '5': 2, '10': 'rpm'},
    {'1': 'throttle_pct', '3': 2, '4': 1, '5': 2, '10': 'throttlePct'},
    {'1': 'coolant_temp_c', '3': 3, '4': 1, '5': 2, '10': 'coolantTempC'},
    {'1': 'intake_temp_c', '3': 4, '4': 1, '5': 2, '10': 'intakeTempC'},
    {'1': 'engine_load_pct', '3': 5, '4': 1, '5': 2, '10': 'engineLoadPct'},
    {
      '1': 'timing_advance_deg',
      '3': 6,
      '4': 1,
      '5': 2,
      '10': 'timingAdvanceDeg'
    },
    {'1': 'maf_gps', '3': 7, '4': 1, '5': 2, '10': 'mafGps'},
  ],
};

/// Descriptor for `EngineData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List engineDataDescriptor = $convert.base64Decode(
    'CgpFbmdpbmVEYXRhEhAKA3JwbRgBIAEoAlIDcnBtEiEKDHRocm90dGxlX3BjdBgCIAEoAlILdG'
    'hyb3R0bGVQY3QSJAoOY29vbGFudF90ZW1wX2MYAyABKAJSDGNvb2xhbnRUZW1wQxIiCg1pbnRh'
    'a2VfdGVtcF9jGAQgASgCUgtpbnRha2VUZW1wQxImCg9lbmdpbmVfbG9hZF9wY3QYBSABKAJSDW'
    'VuZ2luZUxvYWRQY3QSLAoSdGltaW5nX2FkdmFuY2VfZGVnGAYgASgCUhB0aW1pbmdBZHZhbmNl'
    'RGVnEhcKB21hZl9ncHMYByABKAJSBm1hZkdwcw==');

@$core.Deprecated('Use fuelDataDescriptor instead')
const FuelData$json = {
  '1': 'FuelData',
  '2': [
    {
      '1': 'short_fuel_trim_1_pct',
      '3': 1,
      '4': 1,
      '5': 2,
      '10': 'shortFuelTrim1Pct'
    },
    {
      '1': 'short_fuel_trim_2_pct',
      '3': 2,
      '4': 1,
      '5': 2,
      '10': 'shortFuelTrim2Pct'
    },
    {
      '1': 'long_fuel_trim_1_pct',
      '3': 3,
      '4': 1,
      '5': 2,
      '10': 'longFuelTrim1Pct'
    },
    {
      '1': 'long_fuel_trim_2_pct',
      '3': 4,
      '4': 1,
      '5': 2,
      '10': 'longFuelTrim2Pct'
    },
    {'1': 'fuel_level_pct', '3': 5, '4': 1, '5': 2, '10': 'fuelLevelPct'},
  ],
};

/// Descriptor for `FuelData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fuelDataDescriptor = $convert.base64Decode(
    'CghGdWVsRGF0YRIwChVzaG9ydF9mdWVsX3RyaW1fMV9wY3QYASABKAJSEXNob3J0RnVlbFRyaW'
    '0xUGN0EjAKFXNob3J0X2Z1ZWxfdHJpbV8yX3BjdBgCIAEoAlIRc2hvcnRGdWVsVHJpbTJQY3QS'
    'LgoUbG9uZ19mdWVsX3RyaW1fMV9wY3QYAyABKAJSEGxvbmdGdWVsVHJpbTFQY3QSLgoUbG9uZ1'
    '9mdWVsX3RyaW1fMl9wY3QYBCABKAJSEGxvbmdGdWVsVHJpbTJQY3QSJAoOZnVlbF9sZXZlbF9w'
    'Y3QYBSABKAJSDGZ1ZWxMZXZlbFBjdA==');
