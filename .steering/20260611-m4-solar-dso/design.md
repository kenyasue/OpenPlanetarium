# Design Document

## Architecture Overview

```
presentation/  SolarSystemRenderer / DsoRenderer / search panel / detail panel extension / time slider
application/   ephemerisProvider (time-linked solar system positions) / SearchService / selectedObjectProvider (unified) / TimeController extension (playback)
domain/        EphemerisEngine / SolarBodyId / DeepSkyObject / SkyObject (selection unification) / MoonPhase / RiseSetTimes
data/          AssetDsoRepository (dso.json)
tool/          convert_dso.dart (OpenNGC → dso.json)
```

## Component Design

### 1. EphemerisEngine (lib/domain/astro/ephemeris_engine.dart)

- `SkyPoint position(SolarBodyId body, DateTime utc)`: apparent position (geocentric; aberration and nutation omitted)
  - Sun: Meeus Chapter 25 low-precision formula (L0, M, C → true longitude → equatorial coordinates)
  - Moon: principal periodic terms of Meeus Chapter 47 (simplified ELP2000, roughly 6 longitude terms, 4 latitude terms, 1 parallax term)
  - Planets: Standish (JPL) approximate Keplerian elements (valid 1800-2050) → Kepler's equation → heliocentric ecliptic → geocentric conversion
- `MoonPhase moonPhase(DateTime utc)`: phase angle, illuminated fraction, and moon age from the Sun-Moon ecliptic longitude difference (days since new moon = mean synodic month × phase fraction, rather than the longitude difference / 12.19° approximation)
- `RiseSetTimes riseSetTimes(SkyPoint radec, GeoLocation loc, DateTime localDate)`: Meeus Chapter 15 (h0 = -0.5667°, non-iterative approximation). null for circumpolar objects or those that never rise
- Obliquity of the ecliptic: ε = 23.4393 - 0.0130T [degrees] (simplified)

### 2. DSO data

- convert_dso.dart: extracts from OpenNGC (semicolon-delimited) entries with Type ∈ {G,OCl,GCl,PN,Neb,EmN,RfN,SNR,Cl+N,GPair, etc.} and (has an M number or V-Mag ≤ 10)
- dso.json: [{id, name, ja?, type, ra, dec, mag?, majAx?, minAx?, con, m?, names:[aliases]}]
- Japanese names: translation table of famous objects (~25 entries) (Andromeda Galaxy, Orion Nebula, Pleiades (Subaru), etc.)
- DeepSkyObject domain model (subset compliant with functional-design + ObjectType enum)

### 3. SkyObject (selection unification, domain/models/sky_object.dart)

```dart
sealed class SkyObject {
  String get displayName;
  String get typeLabel;        // 'Star', 'Galaxy', 'Planet', etc.
  double? get magnitude;
}
class StarObject extends SkyObject { final Star star; }
class DsoObject extends SkyObject { final DeepSkyObject dso; }
class SolarBodyObject extends SkyObject { final SolarBodyId body; }
```
- Position resolution: StarObject/DsoObject have fixed RA/Dec, SolarBodyObject is time-dependent via EphemerisEngine
- selectedStarProvider → replaced by selectedObjectProvider (SkyObject?) (M2's selectedStarProvider is deleted)

### 4. ephemerisProvider (application/sky/solar_system_provider.dart)

```dart
class SolarBodyPosition { final SolarBodyId body; final SkyPoint position; final double? magnitude; final double angularDiameterDeg; }
final solarSystemProvider = Provider<List<SolarBodyPosition>>((ref) {
  final time = ref.watch(timeControllerProvider);
  // Compute positions of the 9 bodies (follows the time slider). Magnitudes are simplified values (representative table for planets)
});
```
- The Moon's apparent diameter is computed from distance (mean 0.52°), the Sun fixed at 0.53°, planets treated as points

### 5. SearchService (application/search/search_service.dart)

- Query interpretation: `M31`/`NGC 224`/`IC 434` (regex) → DSO number search; otherwise name prefix matching (star proper names, DSO names/Japanese names, constellation names (3 languages), solar system body names (Japanese/English))
- Results: SearchResult (SkyObject or constellation, label, type). Constellations only center on the labelAnchor
- searchProvider: synchronous search (all data in memory). The search target is the full data set, not just visible objects (stars limited to those with proper names)

### 6. Rendering

- SolarSystemRenderer (after StarRenderer):
  - Sun: large radial-gradient disk + strong glow
  - Moon: apparent diameter rendered at projection scale (minimum 12px). The dark side is overlaid with a Path (elliptical terminator approximation) based on illuminated fraction and phase direction
  - Planets: characteristic-color disks (minimum 3px) + slight glow. Saturn: elliptical stroked rings (stylized with fixed tilt). Jupiter: two parallel band lines
  - Labels (name, Japanese name)
- DsoRenderer (after Constellation, before Star): magnitude LOD according to fov (fov > 40°: Messier objects only / below that: all). Type icons + labels only for bright objects
- The selection ring (SelectionRenderer) follows the current position of the SkyObject

### 7. UI

- Left panel (desktop): search TextField at the top + result list (selection triggers centerOn + selected state)
- Mobile: top-left search button → full-screen sheet (same component)
- Detail panel: SkyObject support (altitude/azimuth and rise/set/transit computed via EphemerisEngine/AstroEngine)
- Bottom bar: moon age icon + value, time slider (±12h, committed on release), play button (1x/60x/600x/3600x cycle), current time
- TimeController extension: `startPlayback(speed)/stopPlayback` (addDuration via Timer.periodic at 100ms)

## Error Handling Strategy

- Corrupted DSO asset: CatalogCorruptedException → SnackBar notification + continue without the DSO layer (same policy as M2/M3)
- riseSetTimes: circumpolar / never-rising cases expressed as null fields (not exceptions)

## Test Strategy

- EphemerisEngine: Meeus examples 25.a (Sun ±0.05°) / 47.a (Moon ±0.3°) / 33.a (Venus ±0.2°), invariants (planetary ecliptic latitude |β| < 9°, lunar ecliptic latitude |β| < 5.5°, Mercury elongation < 28.5°, Venus < 48°)
- MoonPhase: new moon (without using known 2026 dates) → illuminated fraction in range 0..1, consistency with the solar ecliptic longitude difference
- riseSetTimes: H ≈ 0 at transit time (maximum altitude), alt ≈ -0.5667 ± 0.5° at rise/set times, rise/set = null for circumpolar stars
- SearchService: the 6 acceptance-criteria queries + case and whitespace variations
- AssetDsoRepository: synthetic JSON + generated asset regression (existence and coordinates of M31/M42/M45, 110 Messier objects)
- Moon phase rendering is excluded from widget/unit tests (visual verification)

## Implementation Order

1. EphemerisEngine + tests (heaviest, highest priority)
2. DSO conversion script + asset + repository + tests
3. SkyObject unification, selectedObjectProvider, solarSystemProvider
4. SearchService + tests
5. Renderers (SolarSystem / Dso) + selection integration
6. UI (search panel, detail extension, time slider, moon age)
7. Verification → validator → merge

## Performance Considerations

- Solar system positions are recomputed only on time changes (Provider). During playback, 9-body computation at 100ms intervals = 10 times/second is negligible
- DSOs number a few hundred. Projecting all of them is still lighter than the 9,000 stars
