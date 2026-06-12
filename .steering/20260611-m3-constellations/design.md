# Design Document

## Architecture Overview

```
presentation/  ConstellationRenderer (lines, boundaries, labels) / LabelDeclutter / settings UI extension
application/   constellationSetProvider / ConstellationSettingsController
domain/        ConstellationData / ConstellationSet / ConstellationRepository (IF) / NameLanguage
data/          AssetConstellationRepository (loads constellations.json)
tool/          convert_constellations.dart (Stellarium index.json + HYG → constellations.json)
assets/        catalogs/constellations.json
```

## Component Design

### 1. Conversion script (tool/catalog_converter/convert_constellations.dart)

- Input: cache/modern_skyculture.json (Stellarium modern), cache/hygdata_v41.csv (HIP → J2000 coordinates)
- Constellation lines: constellations[].lines (HIP polylines) → resolve coordinates via HYG's hip column. Unresolved HIP entries are warned and skipped
- Boundaries: parse edges (format "001:002 M+ 22:52:00 +34:30:00 ... AND LAC", B1875),
  interpolate each edge at 1° intervals (M = meridian direction: Dec varies / P = parallel direction: RA varies), then
  convert to J2000 using IAU 1976 precession (ζ, z, θ from Meeus Chapter 21)
- Names: native as the Latin name, common_name.english as the English name, Japanese from the 88-constellation translation table inside the script
- Label position: average of the unit vectors of all constellation line vertices (RA-wrap safe)
- Output JSON: { constellations: [{iau, la, en, ja, labelRa, labelDec, lines: [[[ra,dec],...], ...]}], boundaries: [[[ra,dec],...], ...] }

### 2. Domain models

```dart
enum NameLanguage { japanese, english, latin }

class ConstellationData {
  final String iau;            // 'Ori'
  final String nameLatin, nameEn, nameJa;
  final SkyPoint labelAnchor;
  final List<List<SkyPoint>> lines;   // polyline groups
  String nameIn(NameLanguage lang);
}

class ConstellationSet {
  final List<ConstellationData> constellations;
  final List<List<SkyPoint>> boundaries; // whole-sky boundary polylines (not attributed to constellations)
}

abstract class ConstellationRepository {
  Future<ConstellationSet> load();
}
```

### 3. ConstellationSettingsController (application)

```dart
class ConstellationSettings {
  final bool showLines;     // default: true
  final bool showNames;     // default: true
  final bool showBoundaries;// default: false
  final double lineOpacity; // 0.05-1.0, default 0.35
  final double lineWidth;   // 0.5-3.0, default 1.0
  final NameLanguage language; // default: japanese
}
```

### 4. ConstellationRenderer (presentation)

- Render order: after GridRenderer and before StarRenderer in SkyPainter's layer list
- Lines: reuse drawSkyPolyline (M1's shared helper). Color is a pale blue-gray (#7E9BB8) × opacity
- Boundaries: kept simple as solid lines × low opacity (0.15) rather than dashed-style short segments
- Labels: cache TextPainters per language and constellation (Map<String, TextPainter>, rebuilt on language change).
  Overlap avoidance via LabelDeclutter
- Culling: project labelAnchor / a representative point of the polyline and skip if null

### 5. LabelDeclutter (presentation/painters/label_declutter.dart)

- Within one frame, registers reserved label rectangles in a grid hash (64px cells), and
  rejects placement of a new label if it intersects an existing one (greedy method)
- Also shared with the M4 celestial object labels (created per frame via the constructor)

## Data Flow

```
Startup → constellationSetProvider (FutureProvider) loads the asset JSON (once)
View change → SkyCanvas watches → ConstellationRenderer(set, settings) is recreated → rendering
```

## Error Handling Strategy

- Missing or malformed asset JSON: throw CatalogCorruptedException, SnackBar notification + continue displaying without the constellation layer (same policy as M2)

## Test Strategy

- Conversion result verification: read the generated asset and confirm 88 constellations, all names non-empty, coordinates within normal ranges, and that Orion's lines contain vertices near Betelgeuse/Rigel (asset regression test)
- AssetConstellationRepository: parsing and corruption detection with synthetic JSON
- ConstellationData.nameIn: language switching
- LabelDeclutter: intersection rejection, non-intersection acceptance
- Precession conversion: no unit tests for functions inside the conversion script; instead, guarantee via the asset regression test that boundary coordinates fall within [0,360)/[-90,90] plus the plausibility of a known point (near the Aries boundary) (the script lives in tool/ and is outside analyzer scope)

## Dependencies

No additions

## Implementation Order

1. Conversion script (including precession conversion) → asset generation
2. Domain models + repository IF
3. Data layer (AssetConstellationRepository) + tests
4. Application layer (settings controller / setProvider)
5. Presentation (LabelDeclutter / ConstellationRenderer / settings UI)
6. Verification → validator → merge

## Performance Considerations

- Constellation lines total about 700 segments for all 88 constellations. Per-frame projection is negligible compared to stars (9,000)
- TextPainters keep a laid-out cache; never call layout() inside render (M1 lesson)
- Boundaries are about 780 edges × interpolation points. When display is OFF, no processing at all

## Future Extensibility

- Constellation artwork: structure allows adding artworkAsset / anchor to ConstellationData (backward-compatible JSON addition)
- LabelDeclutter is shared with M4's celestial object and star name labels
