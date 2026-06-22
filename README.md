# 🏁 Race Coach

Real-time motorsport telemetry and coaching app for track day enthusiasts. Connects to a **RaceBox Mini** GPS receiver via Bluetooth LE, provides live telemetry, automatic lap detection, and audio coaching — all on your Android phone.

## Features

### 📡 Live Telemetry
- **RaceBox Mini** BLE connection (25 Hz GPS, UBX protocol)
- Speed, G-force, heading, altitude, satellite count
- Real-time dashboard with gauges and track map

### 🏎️ Lap Detection
- Automatic finish line crossing detection (line-segment intersection)
- Lap timer with best lap tracking
- Configurable finish line per track configuration

### 🎙️ Audio Coaching
- **Turn Announcer** — calls out corner names on approach (100m trigger)
- **Lap Times** — announces lap time + delta at finish line ("New best! 1:42.3")
- **Coach** mode (planned) — braking/speed/line feedback vs reference lap
- **Spotter** mode — important events only
- Multiple TTS voice selection with preview

### 🏁 Track Library
- **Thunderhill Raceway Park** — 4 configurations:
  - East Bypass (9 corners with apex/entry/exit coordinates)
  - East Full, West, 5-Mile
- Auto-detection by GPS proximity
- Manual track/configuration selection in settings

### ☁️ Cloud Sync
- **Google Sign-In** → Firebase Auth
- Session upload to **Cloud Storage** (protobuf format)
- Session metadata in **Firestore** (track, laps, best time)

### 📊 Session Recording
- Automatic protobuf-based session recording
- Raw telemetry frame capture at full rate
- Local storage with list/load/delete

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│  RaceBox    │────▶│  Telemetry   │────▶│  Lap Detection  │
│  Mini (BLE) │     │  Bus         │     │  Bridge         │
└─────────────┘     └──────┬───────┘     └────────┬────────┘
                           │                      │
                    ┌──────▼───────┐     ┌────────▼────────┐
                    │  Session     │     │  Audio Coaching  │
                    │  Recorder    │     │  (TTS)           │
                    └──────┬───────┘     └─────────────────┘
                           │
                    ┌──────▼───────┐
                    │  Cloud Sync  │
                    │  (Firebase)  │
                    └──────────────┘
```

**State Management:** Riverpod  
**Protocol:** Protobuf (telemetry frames, sessions, track configs)  
**Routing:** GoRouter  

## Project Structure

```
lib/
├── core/           # Theme, router, shared utilities
├── features/
│   ├── auth/       # Google Sign-In + Firebase Auth
│   ├── ble/        # BLE scanner and connection
│   ├── coaching/   # Audio modes, turn announcer, lap time announcer
│   ├── live/       # Dashboard, lap detection, bridge providers
│   ├── racebox/    # RaceBox protocol parser, BLE service, device UI
│   ├── session/    # Recording, storage, cloud upload
│   ├── settings/   # App settings screen
│   ├── telemetry/  # TelemetryBus, adapters, state
│   └── track/      # Track library, auto-detection, selector
├── generated/      # Protobuf generated code
└── main.dart
```

## Setup

### Prerequisites
- Flutter 3.32+
- Android device with BLE support
- RaceBox Mini GPS receiver

### Firebase (for cloud sync)
1. Create a Firebase project or use an existing one
2. Enable **Google Sign-In** in Firebase Console → Authentication → Sign-in method
3. Add your app's SHA-1 fingerprint to the Firebase Android app
4. Download `google-services.json` to `android/app/`
5. Create `lib/firebase_options.dart` with your project config

### Run
```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test          # 130 tests
flutter analyze       # 0 errors
```

| Test Suite | Count |
|---|---|
| RaceBox Protocol (UBX) | 16 |
| Telemetry State | 18 |
| RaceBox Adapter | 12 |
| Track Service | 12 |
| Session Recording | 10 |
| Lap Detector | 14 |
| Turn Announcer | 12 |
| Lap Time Announcer | 13 |
| Widget Smoke | 2 |
| **Total** | **130** |

## Hardware

- **RaceBox Mini** — 25 Hz GPS, BLE 5.0, UBX binary protocol
- Any Android phone with BLE support (tested on Samsung Galaxy S24)

## Roadmap

- [ ] Reference lap capture and comparison
- [ ] Coach mode (braking/speed feedback vs reference)
- [ ] Landscape dashboard for in-car use
- [ ] Session review/playback screen
- [ ] Track outline from recorded GPS traces
- [ ] Additional track libraries
- [ ] iOS support
- [ ] On-device ML coaching (TFLite)

## License

Private — all rights reserved.
