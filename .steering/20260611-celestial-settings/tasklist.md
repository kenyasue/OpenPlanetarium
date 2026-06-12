# Task List

## Phase 1: DSO Catalog Filter Foundation

- [x] Add ObjectType.darkNebula + DsoCatalog enum + DeepSkyObject.catalogs derivation
- [x] DsoSettingsController (persisted) + visibleDsosProvider
- [x] Switch sky_canvas and selection hit-testing to visibleDsosProvider
- [x] Add darkNebula color and icon to DsoRenderer
- [x] Unit tests (classification, filtering, persistence)

## Phase 2: Additional DSO Catalogs (Sh2/LBN/LDN/vdB)

- [x] convert_dso_extra.dart (VizieR TAP fetch, Sh2 galactic coordinate conversion, JSON generation)
- [x] Run it to generate assets/catalogs/dso_extra.json (3,383 objects; coordinates verified with Sh2-155 etc.)
- [x] AssetDsoRepository merge load (sorted brightest first) + catalogLabel formatting
- [x] Tests (merge, labels, classification, regression)

## Phase 3: Solar System Minor Bodies

- [x] MinorBody model + OrbitalElements
- [x] EphemerisEngine.minorBodyGeocentric + magnitude calculation (Kepler computation factored into _orbitalXyz)
- [x] Unit tests (agreement check against Mars elements, high-eccentricity convergence, magnitude formulas)
- [x] convert_minor_bodies.dart (JPL SBDB fetch, JSON generation)
- [x] Run it to generate assets/catalogs/minor_bodies.json (129 asteroids + 120 comets)
- [x] AssetMinorBodyRepository + minorBodyListProvider
- [x] SolarSystemSettingsController (persisted) + visibleMinorBodiesProvider
- [x] MinorBodyRenderer + sky_canvas integration (including the planet filter)
- [x] Tests (providers, settings)

## Phase 4: Celestial Settings Dialog

- [x] celestial_settings_dialog.dart (5 tabs)
- [x] ControlBar: replace 3 icons with a single Celestial Settings icon
- [x] Widget tests (tabs, toggles) + update existing ControlBar tests (all 217 tests passing)

## Phase 4.5: Additional Requests (user instructions during implementation)

- [x] DSO display magnitude slider (mag 0-20, 0.5 steps; objects with unknown magnitude follow only the catalog switch)
- [x] DSO label display toggle + expanded renderer labels (all labels eligible when zoomed in, with automatic thinning)
- [x] Drop magnitude culling from DsoRenderer and centralize it in visibleDsosProvider
- [x] Tests (magnitude filter, all catalogs OFF, slider/toggle Widget tests)

## Phase 5: Verification

- [x] implementation-validator verification and fixes for required findings
      (required: add error notification to minorBodyListProvider / recommended: active comment, vdB column comment, other-always-visible comment)
- [x] tool/check.ps1 fully passing (219 tests)
- [x] Docs updates (functional-design settings table, nebula catalogs/minor bodies in glossary)
- [x] Post-implementation retrospective
- [x] Merge to main and push

---

## Post-implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

- The planned 5-tab layout, catalog additions, and minor bodies were all implemented. During
  implementation the user additionally requested a "DSO display magnitude slider" and "DSO label
  display", which were handled within the same feature
  (added limitingMagnitude/showLabels to DsoSettings; centralized DsoRenderer's magnitude
  culling on the provider side).
- Search still targets all DSOs (including the 3,383 entries). Search → centering is
  possible even with the catalog OFF (no icon is shown) — accepted as part of the spec.

### Lessons Learned

- VizieR computed columns (_RA_icrs etc.) cannot be named in an ADQL SELECT column list, so
  fetch with SELECT * + header mapping. Classical catalogs that only carry galactic coordinates,
  like Sh2, can be converted to J2000 via the inverse rotation with the IAU constants
  (verified with Sh2-155 etc.).
- The JPL SBDB Query API can directly fetch the subset optimal for the client using sb-cdata
  filters (H/a/M1/e/epoch). Comets can be unified onto the same propagation code as asteroids
  via the q/(1-e) → a conversion and the precomputation M0 = n×(epoch−tp).
- Newton's method for Kepler's equation can fall short at 8 iterations for high eccentricity
  (e≈0.97) (changed to 32 iterations + early convergence check).
- When catalogs without magnitude information (Sh2/LBN/LDN) are mixed in, the magnitude slider
  confuses users unless it explicitly states "unknown magnitudes follow the catalog switch".

### Improvement Suggestions for Next Time

- Minor bodies and the new nebula catalogs are excluded from search (F8) and tap selection.
  Integrate them into SearchService in the next search feature expansion.
- Comet orbital elements degrade in accuracy over time (especially after Jupiter encounters).
  Keep an operations note to regenerate the assets about once a year (re-run convert_minor_bodies.dart).
- The MinorBodyRenderer label cache does not yet clear on language switching
  (same as DsoRenderer; add clearCache() when i18n is introduced).
