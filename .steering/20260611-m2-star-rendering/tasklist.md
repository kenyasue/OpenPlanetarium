# Task List

## 🚨 Principle of Complete Task Completion

Continue working until all tasks are `[x]`. Skipping only for technical reasons (state the reason explicitly).

---

## Phase 1: Domain layer (spatial index, star model, appearance computation)

- [x] Star model (id / name / raDeg / decDeg / magnitude / colorIndexBV / tileIndex. hip merged into id and omitted)
- [x] SpatialIndex (RA/Dec grid: tileIndexOf / tilesInViewport / tileCenter, A1-compliant, 184 tiles for the whole sky)
- [x] StarAppearance (B-V → RGB (Ballesteros + blackbody approximation), magnitude → size/glow/fade)
- [x] CatalogRepository interface + added CatalogCorruptedException
- [x] Tests: SpatialIndex (full-sky coverage, RA wrap, poles, viewport inclusion)
- [x] Tests: StarAppearance (Sirius bluish-white / Betelgeuse red, magnitude monotonicity) → 20 tests pass

## Phase 2: Data preparation (conversion script, assets)

- [x] TileBinaryCodec (encode / decode, FPC1 format)
- [x] Tests: Codec round-trip consistency, corruption detection
- [x] tool/catalog_converter/convert.dart (HYG v4.1 CSV → bsc_tiles.bin + star_names.json, mag ≤ 6.5)
- [x] Run conversion and generate assets (8,920 stars / 184 tiles / 358 proper names / 176KB. Registered assets in pubspec.yaml)
- [x] AssetCatalogRepository (injectable loader, tile + magnitude filtering; made SpatialIndex dart:ui-independent so the conversion script can use it)
- [x] Tests: AssetCatalogRepository (synthetic binary)

## Phase 3: Application layer

- [x] lodPolicy (fov → limiting magnitude, composition of Bortle and user limit)
- [x] AppearanceSettingsController (Bortle value, size/glow multipliers, Notifier)
- [x] visibleStarsProvider (follows viewportState, tile queries)
- [x] selectedStarProvider + nearest-neighbor selection logic (pickStarAtPoint, brighter stars prioritized)
- [x] Tests: lodPolicy, visible-stars provider (exclusion outside the viewport), nearest-neighbor selection → all pass

## Phase 4: Presentation layer

- [x] Star sprite generation (starSpriteProvider, 64px radial gradient)
- [x] StarRenderer (batched drawAtlas rendering + glow pass + culling. Rendering is skipped when the sprite is not yet generated — judged that a fallback rendering is unnecessary since generation completes within a few frames)
- [x] SelectionRenderer (selection ring + ticks)
- [x] Layer integration into SkyCanvas (stars / selection) and tap selection (onTapUp)
- [x] Selection info panel (desktop right panel implementation, mobile chip)
- [x] Light pollution slider (display settings section in the left panel)

## Phase 5: Quality checks and verification

- [x] tool/check.ps1 all pass (format / analyze / test, 67 tests)
- [x] flutter build windows --debug succeeds
- [x] exe launch check (continued operation confirmed)
- [x] implementation-validator review and fixes for mandatory findings (resetting the cached failed Future, SnackBar notification for catalog load errors, documenting the sort assumption in dartdoc)

## Phase 6: Merge and documentation

- [x] Update docs (reflected the decision to move drift adoption to M5 in implementation-plan.md)
- [x] Post-implementation retrospective (bottom of this file)
- [x] Merge to main and push

---

## Post-Implementation Retrospective

### Completion date
2026-06-11

### Differences between plan and actual

**What differed from the plan**:
- The data source is HYG v4.1 (integrated HIP/HD/HR/BSC catalog, CC BY-SA 4.0) rather than the Yale BSC. It is easy to obtain as CSV and has proper names and B-V well curated. 8,920 stars at mag ≤ 6.5
- Changed the SpatialIndex.tilesInViewport signature from taking a ViewportState to taking primitives (dart:ui independence, for sharing with the conversion script)
- In Riverpod v3, AsyncValue.valueOrNull has been removed and merged into .value (added to the M1 lessons)

**Newly required tasks**:
- implementation-validator mandatory findings: resetting AssetCatalogRepository's cached failed Future, SnackBar notification for visibleStarsProvider errors

**Tasks skipped for technical reasons**:
- StarRenderer's drawRawPoints fallback when the sprite is not yet generated (sprite generation completes within a few frames after startup and the fallback rendering would never be visible, so it was omitted. render skips when the sprite is null)

### Lessons learned

**Technical lessons**:
- drawAtlas + BlendMode.modulate consolidates per-star color and opacity into a single draw call. The anchor of RSTransform.fromComponents allows sprite-center-based placement
- HYG's ra is in hours (×15 needed). id=0 is the Sun and must be excluded
- Sorting stars within a tile by ascending magnitude lets the limiting-magnitude filter terminate early with break

**Process improvements**:
- The validator finding (cached failed Future) preempted a problem that would have become real harm with the M5 network migration. For repository implementations, error-path tests should be written first

### Suggestions for next time
- When introducing M5 (Tycho-2): precomputed cache of StarRenderer color/size, band narrowing in tilesInViewport, adding catalogId/sourceCatalog to the Star model (validator-recommended findings)
- Design a shared mechanism for label overlap avoidance with constellation name labels (M3)
