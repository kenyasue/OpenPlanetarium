# Task List

## 🚨 Principle of Complete Task Completion

**Continue working until all tasks in this file are completed**

- Mark every task `[x]`
- Do not finish work while incomplete tasks (`[ ]`) remain
- Skipping is allowed only for technical reasons (state the reason explicitly)

---

## Phase 1: Project scaffold

- [x] Generate the project with flutter create (project name: flatter_planetarium, all 5 platforms)
- [x] Add dependencies to pubspec.yaml (flutter_riverpod, geolocator, shared_preferences, intl, vector_math, flutter_lints, mocktail)
- [x] Configure analysis_options.yaml (flutter_lints + additional rules)
- [x] Merge Flutter entries into .gitignore (also removed the .steering/ exclusion, in line with the docs policy "retain as history")
- [x] Create the 4-layer directory skeleton (buildable with a minimal main.dart / app.dart)

## Phase 2: Domain layer (models, astronomical computation)

- [x] Implement value objects (SkyPoint / GeoLocation / HorizontalCoord / ViewportState)
- [x] Implement exception classes (AppException / LocationUnavailableException)
- [x] AstroEngine: Julian Date, GMST, LST calculation (Meeus Chapter 12, with citation comments)
- [x] AstroEngine: equatorial ⇔ horizontal coordinate conversion (azimuth north-referenced, eastward)
- [x] projection: stereographic projection (celestial sphere → screen) and inverse projection (screen → celestial sphere)
- [x] Tests: Meeus fixtures (12.b GMST / 13.b Venus Alt/Az ±0.1°)
- [x] Tests: invariants (north celestial pole altitude = latitude, eq ⇔ hor round-trip consistency, projection ⇔ inverse projection round-trip consistency) → all 19 tests pass

## Phase 3: Application layer

- [x] Implement TimeController (setTime / resetToNow / addDuration, held in UTC)
- [x] Implement LocationController (geolocator acquisition + Tokyo fallback, AsyncValue)
- [x] data/platform/location_provider.dart (geolocator wrapper)
- [x] Implement ViewportController (pan / zoom / centerOn / resize, generation management. Design change: composed geometry information (ViewportGeometry) with date/time and location via viewportStateProvider, avoiding holding state in Notifier instance fields)
- [x] Tests: ViewportController (RA normalization, Dec clamping, fov clamping 0.5°-120°, monotonically increasing viewportId) → 9 tests pass

## Phase 4: Presentation layer

- [x] SkyLayerRenderer interface and SkyPainter (renderer list composition, shouldRepaint)
- [x] BackgroundRenderer (zenith → horizon gradient)
- [x] HorizonRenderer (horizon + direction labels N/E/S/W)
- [x] GridRenderer (altitude-azimuth grid)
- [x] SkyCanvas (GestureDetector: scale-based pan/zoom / Listener: wheel / Focus: arrow and +/- keys)
- [x] GlassPanel shared widget
- [x] Responsive layouts (SkyScreen branching / desktop_layout: left/right panels + bottom bar / mobile_layout: full screen + control bar)
- [x] Dark theme setup (app.dart)
- [x] Widget tests: SkyScreen builds (3 tests including desktop/mobile branching)

## Phase 5: Quality checks and verification

- [x] Create tool/check.ps1 (one-shot run of format → analyze → test)
- [x] Apply dart format, zero flutter analyze warnings
- [x] All flutter test cases pass (31 tests)
- [x] flutter build windows --debug succeeds
- [x] ~~Launch verification with flutter run -d windows~~ (alternative performed: launched the built exe directly and confirmed window creation and 8 seconds of continued operation. flutter run requires an interactive session and is unsuitable for automated execution)

## Phase 6: Merge and documentation

- [x] Update dependency version notation in docs/architecture.md to match reality (riverpod ^3 / geolocator ^14 / intl ^0.20)
- [x] Post-implementation retrospective (recorded at the bottom of this file)
- [x] Commit feature/m1-foundation, merge to main, and push

---

## Post-Implementation Retrospective

### Completion date
2026-06-11

### Differences between plan and actual

**What differed from the plan**:
- Changed the ViewportController design: from the originally planned "Controller watches date/time and location and holds ViewportState directly" to "hold only geometry information (ViewportGeometry), with viewportStateProvider composing date/time and location." This avoids the problem of state being reset when the Riverpod Notifier is rebuilt
- Changed the AstroEngine interface from the functional design document (abstract + projectToScreen) into a split design of AstroEngine (concrete class for coordinate transformation) + ViewProjection (per-frame projection context), and updated docs/functional-design.md to match the implementation
- Visual verification via flutter run -d windows was replaced by launching the built exe and confirming continued operation (due to the automated execution environment)

**Newly required tasks**:
- Addressing implementation-validator findings: removal of the global viewportId counter (unified on generation), addition of limitingMagnitude / enabledLayers to ViewportState (preventing rework in M2), narrowing the LocationController catch, TextPainter caching, focal-point zoom (zoom focalPoint)

**Tasks skipped for technical reasons**: none

### Lessons learned

**Technical lessons**:
- The Meeus worked examples (12.a/12.b/13.b) function well as verification fixtures for GMST and coordinate transformation. Even omitting nutation, the error stays within 0.1°
- The stereographic projection scale "half screen height = scale × 2tan(fov/4)" accurately maps the field of view to the screen height
- Even in Riverpod v3, a design that avoids holding state in Notifier instance fields (state-composing provider) is the safe approach

**Process improvements**:
- Verification by implementation-validator detected, in advance, a spec deviation (missing ViewportState fields) that would have caused rework in M2

### Suggestions for next time
- Unit tests for the renderers (Background/Horizon/Grid) are not yet in place. Introduce a golden test or smoke test mechanism when adding StarRenderer in M2
- Decide on migrating test fixtures to JSON (as stated in development-guidelines) when introducing the M4 Ephemeris (JPL Horizons verification)
- RA/Dec clamping during pan is naturally preserved via the inverse projection, but the feel of fast panning near the poles needs to be checked in M8
