// This is a generated file - do not edit.
//
// Generated from racecoach/v1/track.proto.

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

@$core.Deprecated('Use directionDescriptor instead')
const Direction$json = {
  '1': 'Direction',
  '2': [
    {'1': 'DIRECTION_UNSPECIFIED', '2': 0},
    {'1': 'DIRECTION_CLOCKWISE', '2': 1},
    {'1': 'DIRECTION_COUNTER_CLOCKWISE', '2': 2},
  ],
};

/// Descriptor for `Direction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List directionDescriptor = $convert.base64Decode(
    'CglEaXJlY3Rpb24SGQoVRElSRUNUSU9OX1VOU1BFQ0lGSUVEEAASFwoTRElSRUNUSU9OX0NMT0'
    'NLV0lTRRABEh8KG0RJUkVDVElPTl9DT1VOVEVSX0NMT0NLV0lTRRAC');

@$core.Deprecated('Use trackDescriptor instead')
const Track$json = {
  '1': 'Track',
  '2': [
    {'1': 'track_id', '3': 1, '4': 1, '5': 9, '10': 'trackId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'country', '3': 3, '4': 1, '5': 9, '10': 'country'},
    {'1': 'region', '3': 4, '4': 1, '5': 9, '10': 'region'},
    {
      '1': 'center',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'center'
    },
    {
      '1': 'auto_detect_radius_meters',
      '3': 6,
      '4': 1,
      '5': 2,
      '10': 'autoDetectRadiusMeters'
    },
    {
      '1': 'configurations',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.TrackConfiguration',
      '10': 'configurations'
    },
  ],
};

/// Descriptor for `Track`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trackDescriptor = $convert.base64Decode(
    'CgVUcmFjaxIZCgh0cmFja19pZBgBIAEoCVIHdHJhY2tJZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
    'gKB2NvdW50cnkYAyABKAlSB2NvdW50cnkSFgoGcmVnaW9uGAQgASgJUgZyZWdpb24SLQoGY2Vu'
    'dGVyGAUgASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFSBmNlbnRlchI5ChlhdXRvX2RldGVjdF'
    '9yYWRpdXNfbWV0ZXJzGAYgASgCUhZhdXRvRGV0ZWN0UmFkaXVzTWV0ZXJzEkgKDmNvbmZpZ3Vy'
    'YXRpb25zGAcgAygLMiAucmFjZWNvYWNoLnYxLlRyYWNrQ29uZmlndXJhdGlvblIOY29uZmlndX'
    'JhdGlvbnM=');

@$core.Deprecated('Use trackConfigurationDescriptor instead')
const TrackConfiguration$json = {
  '1': 'TrackConfiguration',
  '2': [
    {'1': 'config_id', '3': 1, '4': 1, '5': 9, '10': 'configId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'length_meters', '3': 3, '4': 1, '5': 2, '10': 'lengthMeters'},
    {
      '1': 'direction',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.racecoach.v1.Direction',
      '10': 'direction'
    },
    {
      '1': 'finish_line_a',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'finishLineA'
    },
    {
      '1': 'finish_line_b',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'finishLineB'
    },
    {
      '1': 'sectors',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.SectorSplit',
      '10': 'sectors'
    },
    {
      '1': 'centerline',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'centerline'
    },
    {
      '1': 'corners',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.Corner',
      '10': 'corners'
    },
  ],
};

/// Descriptor for `TrackConfiguration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trackConfigurationDescriptor = $convert.base64Decode(
    'ChJUcmFja0NvbmZpZ3VyYXRpb24SGwoJY29uZmlnX2lkGAEgASgJUghjb25maWdJZBISCgRuYW'
    '1lGAIgASgJUgRuYW1lEiMKDWxlbmd0aF9tZXRlcnMYAyABKAJSDGxlbmd0aE1ldGVycxI1Cglk'
    'aXJlY3Rpb24YBCABKA4yFy5yYWNlY29hY2gudjEuRGlyZWN0aW9uUglkaXJlY3Rpb24SOQoNZm'
    'luaXNoX2xpbmVfYRgFIAEoCzIVLnJhY2Vjb2FjaC52MS5HcHNEYXRhUgtmaW5pc2hMaW5lQRI5'
    'Cg1maW5pc2hfbGluZV9iGAYgASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFSC2ZpbmlzaExpbm'
    'VCEjMKB3NlY3RvcnMYByADKAsyGS5yYWNlY29hY2gudjEuU2VjdG9yU3BsaXRSB3NlY3RvcnMS'
    'NQoKY2VudGVybGluZRgIIAMoCzIVLnJhY2Vjb2FjaC52MS5HcHNEYXRhUgpjZW50ZXJsaW5lEi'
    '4KB2Nvcm5lcnMYCSADKAsyFC5yYWNlY29hY2gudjEuQ29ybmVyUgdjb3JuZXJz');

@$core.Deprecated('Use sectorSplitDescriptor instead')
const SectorSplit$json = {
  '1': 'SectorSplit',
  '2': [
    {'1': 'sector_number', '3': 1, '4': 1, '5': 13, '10': 'sectorNumber'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'point_a',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'pointA'
    },
    {
      '1': 'point_b',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'pointB'
    },
  ],
};

/// Descriptor for `SectorSplit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sectorSplitDescriptor = $convert.base64Decode(
    'CgtTZWN0b3JTcGxpdBIjCg1zZWN0b3JfbnVtYmVyGAEgASgNUgxzZWN0b3JOdW1iZXISEgoEbm'
    'FtZRgCIAEoCVIEbmFtZRIuCgdwb2ludF9hGAMgASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFS'
    'BnBvaW50QRIuCgdwb2ludF9iGAQgASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFSBnBvaW50Qg'
    '==');

@$core.Deprecated('Use cornerDescriptor instead')
const Corner$json = {
  '1': 'Corner',
  '2': [
    {'1': 'number', '3': 1, '4': 1, '5': 13, '10': 'number'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'apex',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'apex'
    },
    {
      '1': 'entry',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'entry'
    },
    {
      '1': 'exit',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'exit'
    },
  ],
};

/// Descriptor for `Corner`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cornerDescriptor = $convert.base64Decode(
    'CgZDb3JuZXISFgoGbnVtYmVyGAEgASgNUgZudW1iZXISEgoEbmFtZRgCIAEoCVIEbmFtZRIpCg'
    'RhcGV4GAMgASgLMhUucmFjZWNvYWNoLnYxLkdwc0RhdGFSBGFwZXgSKwoFZW50cnkYBCABKAsy'
    'FS5yYWNlY29hY2gudjEuR3BzRGF0YVIFZW50cnkSKQoEZXhpdBgFIAEoCzIVLnJhY2Vjb2FjaC'
    '52MS5HcHNEYXRhUgRleGl0');

@$core.Deprecated('Use trackLibraryManifestDescriptor instead')
const TrackLibraryManifest$json = {
  '1': 'TrackLibraryManifest',
  '2': [
    {
      '1': 'tracks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.racecoach.v1.TrackSummary',
      '10': 'tracks'
    },
    {'1': 'version', '3': 2, '4': 1, '5': 4, '10': 'version'},
  ],
};

/// Descriptor for `TrackLibraryManifest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trackLibraryManifestDescriptor = $convert.base64Decode(
    'ChRUcmFja0xpYnJhcnlNYW5pZmVzdBIyCgZ0cmFja3MYASADKAsyGi5yYWNlY29hY2gudjEuVH'
    'JhY2tTdW1tYXJ5UgZ0cmFja3MSGAoHdmVyc2lvbhgCIAEoBFIHdmVyc2lvbg==');

@$core.Deprecated('Use trackSummaryDescriptor instead')
const TrackSummary$json = {
  '1': 'TrackSummary',
  '2': [
    {'1': 'track_id', '3': 1, '4': 1, '5': 9, '10': 'trackId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'country', '3': 3, '4': 1, '5': 9, '10': 'country'},
    {'1': 'region', '3': 4, '4': 1, '5': 9, '10': 'region'},
    {
      '1': 'center',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.racecoach.v1.GpsData',
      '10': 'center'
    },
    {
      '1': 'configuration_names',
      '3': 6,
      '4': 3,
      '5': 9,
      '10': 'configurationNames'
    },
    {'1': 'version', '3': 7, '4': 1, '5': 4, '10': 'version'},
  ],
};

/// Descriptor for `TrackSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trackSummaryDescriptor = $convert.base64Decode(
    'CgxUcmFja1N1bW1hcnkSGQoIdHJhY2tfaWQYASABKAlSB3RyYWNrSWQSEgoEbmFtZRgCIAEoCV'
    'IEbmFtZRIYCgdjb3VudHJ5GAMgASgJUgdjb3VudHJ5EhYKBnJlZ2lvbhgEIAEoCVIGcmVnaW9u'
    'Ei0KBmNlbnRlchgFIAEoCzIVLnJhY2Vjb2FjaC52MS5HcHNEYXRhUgZjZW50ZXISLwoTY29uZm'
    'lndXJhdGlvbl9uYW1lcxgGIAMoCVISY29uZmlndXJhdGlvbk5hbWVzEhgKB3ZlcnNpb24YByAB'
    'KARSB3ZlcnNpb24=');
