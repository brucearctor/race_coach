// Auto-generated module — re-exports all proto2type generated types for racecoach.v1.
//
// Each .type.rs file is included inline so all types share the same namespace,
// allowing cross-file references (e.g., Session referencing GpsData from telemetry).
//
// Regenerate with: buf generate

use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

// ---------------------------------------------------------------------------
// telemetry.proto types
// ---------------------------------------------------------------------------

include!("telemetry.type.rs");

// ---------------------------------------------------------------------------
// track.proto types
// ---------------------------------------------------------------------------

include!("track.type.rs");

// ---------------------------------------------------------------------------
// coaching.proto types
// ---------------------------------------------------------------------------

include!("coaching.type.rs");

// ---------------------------------------------------------------------------
// session.proto types
// ---------------------------------------------------------------------------

include!("session.type.rs");
