# Design Document

## Architecture Overview

Follow the 4-layer layered architecture of docs/architecture.md. M1 implements the following scope.

```
presentation/  SkyScreen (responsive branching) → SkyCanvas (Gesture) → SkyPainter (background, horizon, grid)
application/   ViewportController / TimeController / LocationController (Riverpod Notifier)
domain/        SkyPoint / GeoLocation / ViewportState / AstroEngine (pure computation)
data/          PrefsSettingsRepository (minimal) / GeolocatorLocationProvider
```

## Component Design

### 1. AstroEngine (lib/domain/astro/)

**Responsibilities**:
- Calculation of Julian Date (JD), Greenwich Mean Sidereal Time (GMST), and Local Sidereal Time (LST)
- Conversion between equatorial coordinates (RA/Dec) and horizontal coordinates (Alt/Az)
- Stereographic projection: celestial sphere → screen coordinates, screen coordinates → celestial sphere (inverse projection)

**Implementation notes**:
- GMST uses the IAU 1982 simplified formula (Meeus Chapter 12). Accuracy on the order of ±1 arcsecond is sufficient (visual display use)
- Azimuth is north = 0°, measured eastward (glossary convention). Convert from the Meeus formula (south-referenced) by +180°
- Projection is horizontal-coordinate based: convert the view center (RA/Dec) to Alt/Az for the current date/time and observing location, and use that point as the tangent point of the stereographic projection. The horizon naturally appears as a curve
- Pure computation only. Takes DateTime (UTC) and doubles; no I/O or Flutter dependencies (only Offset from dart:ui is allowed)
- Source citation comments (Meeus chapter numbers) are mandatory for formulas (development-guidelines)

### 2. ViewportState / ViewportController

**Responsibilities**:
- ViewportState: immutable snapshot of center RA/Dec, field of view (fovDeg), screen size, observation date/time, observing location, and viewportId
- ViewportController (Notifier<ViewportState>): pan (screen drag amount → celestial movement), zoom (factor → fovDeg clamped to 0.5°-120°), centerOn, resize, and reflecting date/time and location changes

**Implementation notes**:
- pan converts to angular movement proportional to the current fovDeg. Clamp at the Dec poles (±90°), normalize RA to 0-360
- Increment viewportId on every state change (foundation for query generation management in M2)
- Subscribe to TimeController / LocationController changes via ref.listen and reflect them into ViewportState

### 3. TimeController / LocationController

**Responsibilities**:
- TimeController: observation date/time (held in UTC, displayed in local time). setTime / resetToNow
- LocationController: obtains the current location via geolocator at startup (10-second timeout). On failure or denial, falls back to the default (Tokyo: 35.6812N, 139.7671E) and provides a manual-setting API

**Implementation notes**:
- geolocator calls are isolated in data/platform/location_provider.dart (domain-independent)
- Location data is never sent externally. Not persisted in M1 either (manual location persistence will be done together with the M5 settings screen)

### 4. SkyPainter skeleton (lib/presentation/painters/)

**Responsibilities**:
- Background: deep navy gradient from zenith to horizon (below the horizon distinguished with dark grayish tones)
- Horizon rendering and direction labels (N/E/S/W, projecting azimuth points on the horizon)
- Altitude-azimuth grid (altitude 0/30/60°, azimuth in 30° steps, toggleable in settings in the future)

**Implementation notes**:
- SkyPainter renders a list of SkyLayerRenderer interfaces (render(Canvas, Size, ViewportState)) in order (accommodates future layer additions, architecture.md extensibility requirement)
- Projection computations within a frame call AstroEngine directly (no precomputation needed in M1 since the object count is zero)
- Separate the canvas and UI panels with RepaintBoundary

### 5. UI skeleton (lib/presentation/screens/sky/)

**Responsibilities**:
- SkyScreen: branches to the desktop layout via LayoutBuilder when width ≥ 1024px
- SkyCanvas: GestureDetector (scale-based pan/zoom integration) + Listener (wheel) + Focus (keyboard)
- Desktop: left/right panels (GlassPanel, contents are placeholders for M2 onward) + bottom bar (date/time display, "current time" button)
- Mobile: full-screen canvas + bottom control bar

## Data Flow

### Pan and zoom
```
1. GestureDetector (onScaleUpdate) obtains drag amount and scale
2. ViewportController.pan/zoom updates ViewportState (viewportId++)
3. SkyCanvas rebuilds via ref.watch → CustomPaint repaints
4. SkyPainter executes each SkyLayerRenderer in order
```

## Error Handling Strategy

### Custom error classes

- Define `AppException` (sealed base) and `LocationUnavailableException` in lib/domain/exceptions.dart (corresponding to the error classification in the functional design document)

### Error handling patterns

- LocationController expresses state (loading/error/data) with AsyncValue; on error, it continues operating with the default location (graceful degradation)
- Location acquisition failure is shown non-intrusively in the UI ("Tokyo (default)" shown in the bottom bar)

## Test Strategy

### Unit tests
- AstroEngine: fixture verification against Meeus examples 12.b (GMST) and 13.b (Venus Alt/Az, tolerance 0.1°)
- Invariants: altitude of the celestial north pole = latitude, eq→hor→eq round-trip consistency (arbitrary coordinate samples), 24h periodicity of LST
- Projection: the center point projects to the screen center, projection → inverse projection round-trip consistency, objects off-screen (behind) return null
- ViewportController: RA normalization and Dec clamping in pan, fov clamping in zoom, monotonically increasing viewportId

### Integration tests
- Minimal widget tests in M1 (SkyScreen builds without crashing)

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.0.1
  geolocator: ^14.0.2
  shared_preferences: ^2.5.3
  intl: ^0.20.2
  vector_math: ^2.2.0
dev_dependencies:
  flutter_lints: ^6.0.0
  mocktail: ^1.0.4
```
(Versions follow the latest stable at pub resolution. Riverpod adopts ^3 since v3 is the stable line — read the ^2.x notation in docs/architecture.md as the stable version at implementation time, and update the document)

## Directory Structure

```
lib/
├── main.dart
├── app.dart
├── presentation/
│   ├── screens/sky/{sky_screen,sky_canvas,desktop_layout,mobile_layout}.dart
│   ├── painters/{sky_painter,sky_layer_renderer,background_renderer,horizon_renderer,grid_renderer}.dart
│   └── widgets/glass_panel.dart
├── application/
│   ├── viewport/viewport_controller.dart
│   ├── time/time_controller.dart
│   └── location/location_controller.dart
├── domain/
│   ├── models/{sky_point,geo_location,horizontal_coord,viewport_state}.dart
│   ├── astro/{astro_engine,projection}.dart
│   └── exceptions.dart
└── data/
    └── platform/location_provider.dart
test/
├── domain/astro/{astro_engine_test,projection_test}.dart
├── application/viewport/viewport_controller_test.dart
└── fixtures/meeus_fixtures.dart
tool/check.ps1   # one-shot format/analyze/test verification
```

## Implementation Order

1. flutter create + pubspec + analysis_options + directory skeleton
2. Domain models → AstroEngine → projection (in parallel with tests)
3. Application-layer controllers (in parallel with tests)
4. Presentation layer (Painter → Canvas → layouts)
5. Quality checks (format/analyze/test/Windows build) → merge to main and push

## Security Considerations

- Location data stays in memory only. No external transmission or persistence (M1)
- No communication (no network features implemented in M1)

## Performance Considerations

- Even with few render targets in M1, establish the structure of batched CustomPainter rendering and RepaintBoundary separation
- shouldRepaint is determined by identity comparison of ViewportState

## Future Extensibility

- The SkyLayerRenderer interface allows M2 (StarRenderer) onward to extend by adding renderers only
- viewportId will be used as-is for tile query generation management in M2
