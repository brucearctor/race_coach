// This is a generated file - do not edit.
//
// Generated from racecoach/v1/coaching.proto.

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

@$core.Deprecated('Use coachingCueTypeDescriptor instead')
const CoachingCueType$json = {
  '1': 'CoachingCueType',
  '2': [
    {'1': 'COACHING_CUE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'COACHING_CUE_TYPE_BRAKING', '2': 1},
    {'1': 'COACHING_CUE_TYPE_THROTTLE', '2': 2},
    {'1': 'COACHING_CUE_TYPE_LINE', '2': 3},
    {'1': 'COACHING_CUE_TYPE_SPEED', '2': 4},
    {'1': 'COACHING_CUE_TYPE_SECTOR_TIME', '2': 5},
    {'1': 'COACHING_CUE_TYPE_LAP_TIME', '2': 6},
    {'1': 'COACHING_CUE_TYPE_G_FORCE', '2': 7},
    {'1': 'COACHING_CUE_TYPE_GENERAL', '2': 8},
  ],
};

/// Descriptor for `CoachingCueType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List coachingCueTypeDescriptor = $convert.base64Decode(
    'Cg9Db2FjaGluZ0N1ZVR5cGUSIQodQ09BQ0hJTkdfQ1VFX1RZUEVfVU5TUEVDSUZJRUQQABIdCh'
    'lDT0FDSElOR19DVUVfVFlQRV9CUkFLSU5HEAESHgoaQ09BQ0hJTkdfQ1VFX1RZUEVfVEhST1RU'
    'TEUQAhIaChZDT0FDSElOR19DVUVfVFlQRV9MSU5FEAMSGwoXQ09BQ0hJTkdfQ1VFX1RZUEVfU1'
    'BFRUQQBBIhCh1DT0FDSElOR19DVUVfVFlQRV9TRUNUT1JfVElNRRAFEh4KGkNPQUNISU5HX0NV'
    'RV9UWVBFX0xBUF9USU1FEAYSHQoZQ09BQ0hJTkdfQ1VFX1RZUEVfR19GT1JDRRAHEh0KGUNPQU'
    'NISU5HX0NVRV9UWVBFX0dFTkVSQUwQCA==');

@$core.Deprecated('Use cuePriorityDescriptor instead')
const CuePriority$json = {
  '1': 'CuePriority',
  '2': [
    {'1': 'CUE_PRIORITY_UNSPECIFIED', '2': 0},
    {'1': 'CUE_PRIORITY_LOW', '2': 1},
    {'1': 'CUE_PRIORITY_MEDIUM', '2': 2},
    {'1': 'CUE_PRIORITY_HIGH', '2': 3},
    {'1': 'CUE_PRIORITY_CRITICAL', '2': 4},
  ],
};

/// Descriptor for `CuePriority`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cuePriorityDescriptor = $convert.base64Decode(
    'CgtDdWVQcmlvcml0eRIcChhDVUVfUFJJT1JJVFlfVU5TUEVDSUZJRUQQABIUChBDVUVfUFJJT1'
    'JJVFlfTE9XEAESFwoTQ1VFX1BSSU9SSVRZX01FRElVTRACEhUKEUNVRV9QUklPUklUWV9ISUdI'
    'EAMSGQoVQ1VFX1BSSU9SSVRZX0NSSVRJQ0FMEAQ=');

@$core.Deprecated('Use coachingCueDescriptor instead')
const CoachingCue$json = {
  '1': 'CoachingCue',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.CoachingCueType',
      '10': 'type'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'priority',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.CuePriority',
      '10': 'priority'
    },
    {
      '1': 'timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'sector_number', '3': 5, '4': 1, '5': 13, '10': 'sectorNumber'},
    {'1': 'delta_seconds', '3': 6, '4': 1, '5': 2, '10': 'deltaSeconds'},
  ],
};

/// Descriptor for `CoachingCue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coachingCueDescriptor = $convert.base64Decode(
    'CgtDb2FjaGluZ0N1ZRIxCgR0eXBlGAEgASgOMh0ucmFjZWNvYWNoLnYxLkNvYWNoaW5nQ3VlVH'
    'lwZVIEdHlwZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEjUKCHByaW9yaXR5GAMgASgOMhku'
    'cmFjZWNvYWNoLnYxLkN1ZVByaW9yaXR5Ughwcmlvcml0eRI4Cgl0aW1lc3RhbXAYBCABKAsyGi'
    '5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASIwoNc2VjdG9yX251bWJlchgF'
    'IAEoDVIMc2VjdG9yTnVtYmVyEiMKDWRlbHRhX3NlY29uZHMYBiABKAJSDGRlbHRhU2Vjb25kcw'
    '==');
