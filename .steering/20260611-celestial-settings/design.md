# Design: Celestial Settings Dialog (5 Tabs) and Minor Body / Nebula Catalog Additions

## 1. DSO Catalog Filter

- Add `ObjectType.darkNebula` (label "dark nebula", for LDN; dedicated color in DsoRenderer)
- Add a `DsoCatalog` enum {messier, ngc, ic, sh2, lbn, ldn, vdb, other} to
  deep_sky_object.dart. `DeepSkyObject.catalogs` (Set) is derived from the Messier number and
  id prefixes (NGC/IC/SH2-/LBN/LDN/VDB)
- `DsoSettingsController` (persisted 'settings.dso'): a bool per the 7 catalogs.
  Defaults: messier/ngc/ic=ON, sh2/lbn/ldn/vdb=OFF (faint nebulae are opted in explicitly)
- `visibleDsosProvider`: filters dsoListProvider by catalogs ∩ enabled catalogs ≠ ∅.
  sky_canvas and selection hit-testing use this (search remains over all entries)
- Conversion script `convert_dso_extra.dart`: fetches the 4 catalogs from VizieR TAP and
  generates `assets/catalogs/dso_extra.json` (same schema as dso.json).
  Sh2 is rotated from galactic coordinates to J2000 equatorial coordinates. ID format: 'SH2-155'/'LBN1111'/
  'LDN1773'/'VDB142'. Formatting added to catalogLabel
- AssetDsoRepository merge-loads dso.json + dso_extra.json (if present)

## 2. Solar System Minor Bodies (asteroids and comets)

- `MinorBody` model (domain/models/minor_body.dart):
  kind (asteroid/comet), name, nameJa?, OrbitalElements
  {epochJd, a, e, iDeg, nodeDeg, argPeriDeg, maDeg (mean anomaly at epoch)},
  magnitude parameters (asteroid: h / comet: m1, k1).
  Comets are stored converted as a = q/(1−e) (only e<0.99 accepted)
- `EphemerisEngine.minorBodyGeocentric(elements, utc)`:
  Kepler's equation (reusing the existing solver) → heliocentric ecliptic coordinates → geocentric conversion.
  Return value: position (RA/Dec) + heliocentric distance r + geocentric distance Δ
  Mean motion n = 0.9856076686 / a^1.5 [deg/day]
- Magnitudes: asteroid V = H + 5log10(rΔ) (phase correction omitted — conservative side),
  comet m = M1 + 5log10(Δ) + 2.5·K1·log10(r)
- `convert_minor_bodies.dart`: fetches from the JPL SBDB Query API and generates
  `assets/catalogs/minor_bodies.json` (Japanese names assigned to well-known asteroids)
- `AssetMinorBodyRepository` + `minorBodyListProvider` (FutureProvider)
- `visibleMinorBodiesProvider`: computes positions and magnitudes tied to time + settings,
  returning only those at or below the display limit (asteroids mag 12.0, comets mag 13.0)
- `SolarSystemSettingsController` (persisted 'settings.solarSystem'):
  showPlanets/showAsteroids/showComets (all default true)
- `MinorBodyRenderer`: asteroid = small diamond + label, comet = dot + anti-solar
  tail (computed from the Sun's on-screen position). Zoom-linked magnitude gating as with DSO
- sky_canvas: with showPlanets=false, only the Sun and Moon remain.
  MinorBodyRenderer comes immediately after SolarSystemRenderer

## 3. Celestial Settings Dialog

- `celestial_settings_dialog.dart`: `showCelestialSettingsDialog(context)`.
  A DefaultTabController inside an AlertDialog (5 tabs: DSO/solar system/survey/stars/constellations),
  fixed size (width 440 × height 460), each tab scrollable
  - DSO: switches for the 7 catalogs (with count annotations)
  - Solar system: planet/asteroid/comet switches + notes on data source and epoch
  - Survey: existing SurveySettingsSection
  - Stars: display magnitude slider + Milky Way switch (merging the old _MagnitudeLimitContent)
  - Constellations: existing ConstellationSettingsSection
- ControlBar: replace the 3 icons for display magnitude, Milky Way, and survey with a single
  "Celestial Settings" icon (Icons.auto_awesome_outlined). Shown as active when a survey is enabled

## Test Strategy

- Unit tests for DsoCatalog classification and filtering
- minorBodyGeocentric: convert Standish's Mars elements into the minor body format and verify
  agreement with the existing planet position computation (a strong check requiring no external data)
- Unit tests for the magnitude formulas
- Dialog Widget tests (5 tabs displayed, toggles reflected) + update of existing ControlBar tests
