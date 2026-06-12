# Requirements

## Overview

Implement Milestone 1 "Foundation" of the implementation plan (docs/implementation-plan.md).
Build the skeleton of the Flutter project, the 4-layer architecture, the coordinate transformation engine, and the foundation of the sky canvas, reaching a state where "the sky at the current location and current date/time (no stars yet) is rendered and can be panned and zoomed."

## Background

All features of FlatterPlanetarium (star display, constellations, celestial objects, surveys, FOV simulation) are built on top of coordinate transformation (AstroEngine), viewport management, and the rendering pipeline. Solidifying the accuracy and structure of this foundation in M1 is a prerequisite for the subsequent milestones (M2-M8).

## Features to Implement

### 1. Flutter project scaffold and 4-layer structure
- Create a Flutter project at the repository root (project name: flatter_planetarium, with Windows/macOS/Linux/iOS/Android enabled)
- Directory structure of lib/presentation, application, domain, data, l10n following docs/repository-structure.md
- analysis_options.yaml (flutter_lints), pubspec.yaml (flutter_riverpod, geolocator, shared_preferences, intl, vector_math)

### 2. Domain base models and AstroEngine
- Value objects: SkyPoint (RA/Dec), GeoLocation, HorizontalCoord, ViewportState
- Calculation of Julian Date and Greenwich/local sidereal time
- Conversion between equatorial and horizontal coordinates
- Celestial sphere to screen coordinate conversion via stereographic projection, and its inverse (tap position to celestial coordinates)

### 3. Application-layer controllers
- ViewportController: pan, zoom, centerOn, viewportId generation management
- TimeController: holding/changing the observation date/time and "return to current time"
- LocationController: GPS acquisition (geolocator) with manual location fallback (default: Tokyo)

### 4. Sky canvas skeleton and responsive UI
- SkyPainter skeleton: night-sky background gradient, horizon, direction labels (N/E/S/W), altitude-azimuth grid
- Gestures: pinch zoom/swipe (mobile), wheel/drag (desktop), keyboard shortcuts (arrow pan, +/- zoom)
- Responsive layout skeleton: desktop (central canvas + left/right panel placeholders + bottom bar) / mobile (full screen + bottom control bar)
- Dark theme and GlassPanel (translucent panel) basics

## Acceptance Criteria

### AstroEngine
- [ ] Matches known ephemeris fixture values (Meeus worked examples: GMST for 1987-04-10, altitude/azimuth of Venus) within tolerance
- [ ] Invariant tests pass: altitude of the celestial north pole = observing location latitude, equatorial → horizontal → equatorial round-trip consistency, etc.
- [ ] Projection → inverse projection round-trip yields matching coordinates

### Sky canvas
- [ ] Launches on Windows desktop with horizon, directions, and grid displayed
- [ ] Mouse drag pans and wheel zooms (FOV clamped to 0.5°-120°)
- [ ] Horizon and direction display follow changes to date/time and location

### Project quality
- [ ] `dart format` / zero `flutter analyze` warnings / all `flutter test` cases pass
- [ ] Windows build (`flutter build windows --debug`) succeeds

## Success Metrics

- Pan/zoom operations run at roughly 60fps with few render targets (visually smooth)
- AstroEngine test coverage forms the foundation toward the 90% domain-layer target

## Out of Scope

The following will not be implemented in this phase:

- Display of stars, constellations, and celestial objects (M2-M4)
- DB via drift and catalog download (M2, M5)
- CI environment setup (the remote is Gitea (git.yasue.org) and the runner configuration is unconfirmed, so a local verification script (tool/check.ps1) substitutes for it. CI adoption to be decided separately)
- Build verification on macOS / iOS (this development machine is Windows, so Windows + static analysis substitutes)
- Deletion of TypeScript template files (src/, package.json, etc.) (kept since they do not conflict with the Flutter setup)

## Reference Documents

- `docs/implementation-plan.md` - Milestone 1
- `docs/functional-design.md` - AstroEngine / ViewportController / screen transition diagram
- `docs/architecture.md` - 4-layer architecture, technology stack
- `docs/repository-structure.md` - directory structure
- `docs/development-guidelines.md` - coding conventions
