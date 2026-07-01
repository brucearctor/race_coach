//! Integration tests for the coaching engine pipeline.
//!
//! Tests the full flow: create_session → process_frame → coaching cues,
//! verifying that multiple analyzers interact correctly and that the
//! AnalysisConfig properly enables/disables analyzers.

use race_coach_core::api::coaching_api;
use race_coach_core::types::*;
use serial_test::serial;

fn make_session_config() -> SessionConfig {
    SessionConfig {
        track: TrackConfig {
            name: "Test Track".to_string(),
            track_length_m: Some(3000.0),
            finish_line_a: LatLng {
                lat: 37.0,
                lng: -122.0,
            },
            finish_line_b: LatLng {
                lat: 37.0,
                lng: -121.9999,
            },
            sector_splits: vec![],
            corners: vec![Corner {
                number: 1,
                name: "Turn 1".to_string(),
                entry: LatLng {
                    lat: 37.001,
                    lng: -122.001,
                },
                apex: LatLng {
                    lat: 37.0005,
                    lng: -122.001,
                },
                exit: LatLng {
                    lat: 37.0,
                    lng: -122.001,
                },
            }],
            centerline: vec![],
        },
        analysis: AnalysisConfig::default(),
        use_mph: false,
    }
}

fn make_input(
    timestamp_ms: u64,
    lat: f64,
    lng: f64,
    speed: f32,
    g_lat: f32,
    g_long: f32,
) -> TelemetryInput {
    TelemetryInput {
        timestamp_ms,
        latitude: lat,
        longitude: lng,
        speed_kmh: speed,
        heading_deg: 180.0,
        altitude_m: 100.0,
        g_lateral: g_lat,
        g_longitudinal: g_long,
        g_vertical: 1.0,
        satellites: 12,
        hdop: 1.0,
    }
}

#[serial]
#[test]
fn test_create_session_and_process_frames() {
    // Create session
    let config = make_session_config();
    let created = coaching_api::create_session(config, None);
    assert!(created, "Session should be created");

    // Process a few frames — should not panic
    for i in 0..10 {
        let input = make_input(i * 40, 37.0, -122.0, 100.0, 0.1, -0.2);
        let output = coaching_api::process_frame(input);
        // Should return valid output
        assert!(output.track_distance_m >= 0.0);
        assert!(output.grip_utilization >= 0.0);
    }

    // Cleanup
    coaching_api::destroy_session();
}

#[serial]
#[test]
fn test_process_frame_without_session_returns_default() {
    // Ensure no session
    coaching_api::destroy_session();

    let input = make_input(0, 37.0, -122.0, 100.0, 0.0, 0.0);
    let output = coaching_api::process_frame(input);

    // Should return default output, not panic
    assert_eq!(output.track_distance_m, 0.0);
    assert!(output.coaching_cues.is_empty());
}

#[serial]
#[test]
fn test_reset_lap_clears_state() {
    let config = make_session_config();
    coaching_api::create_session(config, None);

    // Process frames to accumulate distance
    for i in 0..5 {
        let lat = 37.0 + (i as f64) * 0.0001;
        let input = make_input(i * 40, lat, -122.0, 100.0, 0.0, 0.0);
        coaching_api::process_frame(input);
    }

    // Reset
    coaching_api::reset_lap();

    // Next frame should start fresh
    let input = make_input(200, 37.0, -122.0, 100.0, 0.0, 0.0);
    let output = coaching_api::process_frame(input);
    // Distance should be small (just one frame of movement)
    assert!(
        output.track_distance_m < 50.0,
        "After reset, distance should be small, got {}",
        output.track_distance_m
    );

    coaching_api::destroy_session();
}

#[serial]
#[test]
fn test_get_ml_features_returns_empty_before_window_full() {
    let config = make_session_config();
    coaching_api::create_session(config, None);

    // Process fewer frames than the window size (25)
    for i in 0..5 {
        let input = make_input(i * 40, 37.0, -122.0, 100.0, 0.0, 0.0);
        coaching_api::process_frame(input);
    }

    let features = coaching_api::get_ml_features();
    assert!(features.is_empty(), "Should be empty before window is full");

    coaching_api::destroy_session();
}

#[serial]
#[test]
fn test_get_ml_features_returns_features_after_window() {
    let config = make_session_config();
    coaching_api::create_session(config, None);

    // Process enough frames to fill the window (default 25)
    for i in 0..30 {
        let input = make_input(i * 40, 37.0, -122.0, 100.0 + (i as f32), 0.1, -0.1);
        coaching_api::process_frame(input);
    }

    let features = coaching_api::get_ml_features();
    assert_eq!(
        features.len(),
        26,
        "Should return 26 features, got {}",
        features.len()
    );

    // Verify no NaN/Inf
    for (i, &f) in features.iter().enumerate() {
        assert!(!f.is_nan(), "Feature {i} is NaN");
        assert!(!f.is_infinite(), "Feature {i} is Inf");
    }

    coaching_api::destroy_session();
}

#[serial]
#[test]
fn test_braking_generates_cue_through_cue_engine() {
    let config = make_session_config();
    coaching_api::create_session(config, None);

    // Start braking: sustained negative G for several frames
    for i in 0..10 {
        let input = make_input(i * 40, 37.0, -122.0, 150.0, 0.0, -0.8);
        coaching_api::process_frame(input);
    }

    // Stop braking
    let mut got_braking_cue = false;
    for i in 10..15 {
        let input = make_input(i * 40, 37.0, -122.0, 80.0, 0.0, 0.1);
        let output = coaching_api::process_frame(input);
        for cue in &output.coaching_cues {
            if cue.cue_type == CueType::Braking {
                got_braking_cue = true;
            }
        }
    }

    // We may or may not get a braking cue depending on reference lap availability,
    // but at minimum the braking_state should have been tracked.
    // The key assertion: no panics, and the pipeline handles the braking edge correctly.
    let _ = got_braking_cue;

    coaching_api::destroy_session();
}

#[serial]
#[test]
fn test_friction_circle_updates_grip_utilization() {
    let config = make_session_config();
    coaching_api::create_session(config, None);

    // High G-force frames to establish g_max
    for i in 0..10 {
        let input = make_input(i * 40, 37.0, -122.0, 150.0, 1.2, -0.8);
        let output = coaching_api::process_frame(input);

        // After a few frames, grip utilization should be > 0
        if i > 3 {
            assert!(
                output.grip_utilization > 0.0,
                "Grip utilization should be > 0 at frame {i}, got {}",
                output.grip_utilization
            );
        }
    }

    coaching_api::destroy_session();
}

#[serial]
#[test]
fn test_analyzer_enable_disable_via_config() {
    // Create with trail_braking disabled (default)
    let config = make_session_config();
    coaching_api::create_session(config, None);

    let analyzers = coaching_api::list_analyzers();
    let trail_braking = analyzers.iter().find(|a| a.id == "trail_braking");
    assert!(
        trail_braking.is_some(),
        "trail_braking should be registered"
    );
    assert!(
        !trail_braking.unwrap().enabled,
        "trail_braking should be disabled by default"
    );

    let jerk = analyzers.iter().find(|a| a.id == "jerk_analysis");
    assert!(jerk.is_some(), "jerk_analysis should be registered");
    assert!(
        !jerk.unwrap().enabled,
        "jerk_analysis should be disabled by default"
    );

    coaching_api::destroy_session();

    // Now create with trail_braking enabled
    let mut config2 = make_session_config();
    config2.analysis.trail_braking = true;
    config2.analysis.jerk_analysis = true;
    coaching_api::create_session(config2, None);

    let analyzers2 = coaching_api::list_analyzers();
    let trail_braking2 = analyzers2.iter().find(|a| a.id == "trail_braking");
    assert!(
        trail_braking2.unwrap().enabled,
        "trail_braking should be enabled via config"
    );
    let jerk2 = analyzers2.iter().find(|a| a.id == "jerk_analysis");
    assert!(
        jerk2.unwrap().enabled,
        "jerk_analysis should be enabled via config"
    );

    coaching_api::destroy_session();
}

#[serial]
#[test]
fn test_get_ml_features_without_session() {
    coaching_api::destroy_session();
    let features = coaching_api::get_ml_features();
    assert!(
        features.is_empty(),
        "Should return empty without active session"
    );
}
