# Design Document

## Architecture Overview

```
presentation/  StarRenderer (batched drawAtlas rendering) / SelectionRenderer / selection info panel / light pollution slider
application/   visibleStarsProvider (follows viewportState) / lodPolicy / AppearanceSettingsController / selectedStarProvider
domain/        Star / SpatialIndex (RA/Dec grid) / StarAppearance (color/size computation) / CatalogRepository (IF)
data/          AssetCatalogRepository / TileBinaryCodec
tool/          catalog_converter (HYG CSV → tile binary + names JSON)
assets/        catalogs/bsc_tiles.bin, catalogs/star_names.json
```

## Component Design

### 1. SpatialIndex (lib/domain/spatial/spatial_index.dart)

- 12 declination bands of 15° each; RA divisions per band = max(1, round(24cos(decCenter))) (functional design A1)
- `tileIndexOf(ra, dec)` / `tilesInViewport(state)` / `tileCenter(index)` / `tileAngularRadius(index)`
- Viewport intersection uses the angular-distance method: enumerate tiles within (view diagonal radius × 1.15 margin) + tile radius (a robust method requiring no special cases at the RA 0° boundary or the poles)

### 2. Catalog data

**Binary format (bsc_tiles.bin, little-endian)**:
```
header: uint32 magic 'FPC1' | uint32 version=1 | uint32 tileCount
tile:   int32 tileIndex | int32 starCount
record: int32 id | float32 raDeg | float32 decDeg | float32 mag | float32 bv (missing = NaN)
```
- TileBinaryCodec (data layer) provides both encode/decode (encoding is also used by the conversion script and the M5 download)
- star_names.json: {"id": "Sirius", ...} (proper names only)

**AssetCatalogRepository**: on first access, decodes all tiles from rootBundle and holds a Map<int, List<Star>>. starsInTiles(tiles, limitMag) is a synchronous filter (fast for 9,000 stars).

### 3. LOD and light pollution (lib/application/viewport/lod_policy.dart)

- fov > 60° → magnitude 6.0 / otherwise → magnitude 6.5 (BSC limit. Fully implement the A2 table when the detailed catalog is introduced)
- Effective limiting magnitude = min(LOD magnitude, 6.5 - 0.5×(bortle-1), user-configured limit)

### 4. StarAppearance (lib/domain/appearance/star_appearance.dart)

- B-V → temperature: Ballesteros (2012) approximation
- Temperature → RGB: blackbody radiation approximation (Tanner Helland polynomials, clamped to 1000-40000K)
- Missing B-V: white (#FFF8F0)
- Size: radius = clamp(base × relative^0.35 × scale, 0.5, 16) where relative = 10^(-0.4×mag)
- Glow: only for mag < 2.0, intensity ∝ (2-mag)
- Fade: stars fainter than faintFadeStart have linearly decaying opacity (floor 0.15)

### 5. visibleStarsProvider (application)

```dart
final visibleStarsProvider = FutureProvider<List<Star>>((ref) async {
  final state = ref.watch(viewportStateProvider);
  final limitMag = effectiveLimitingMagnitude(state.fovDeg, settings);
  final tiles = spatialIndex.tilesInViewport(state);
  return ref.watch(catalogRepositoryProvider).starsInTiles(tiles, limitMag);
});
```
- Generation management via Riverpod auto re-evaluation: when re-evaluated with a new viewportState, the old Future's result is discarded (the AsyncValue mechanism). Rendering uses the most recent settled value (valueOrNull), continuing to display previous data while loading
- No debounce (queries take <1ms since assets are fully in memory; introduce it when moving to DB/network in M5)

### 6. StarRenderer (presentation/painters/star_renderer.dart)

- Sprite approach: at startup, generate one 64px circular-gradient ui.Image (starSpriteProvider, FutureProvider<ui.Image>)
- Main pass: canvas.drawAtlas(sprite, RSTransform (scale = radius), color list, BlendMode.modulate)
- Glow pass: for stars with mag < 2, draw the same sprite first at a larger scale × low alpha
- Fallback to drawRawPoints when the sprite has not yet been generated
- Off-screen culling: skip when project() is null or outside the screen rectangle (+8px margin)

### 7. Selection (selectedStarProvider + SelectionRenderer)

- SkyCanvas onTapUp → unproject → linear search of visible stars for minimum angular distance (fast enough for 9,000 entries); select if within 20px screen distance
- SelectionRenderer: draws a ring around the selected star
- Desktop: right panel shows name (HYG number for unnamed stars), magnitude, B-V, coordinates / Mobile: chip displayed at the top

## Data Flow

```
viewportState change → visibleStarsProvider re-evaluation → tilesInViewport → starsInTiles(limitMag)
→ SkyCanvas watches → SkyPainter (layers=[bg, horizon, grid, stars, selection]) → drawAtlas
```

## Error Handling Strategy

- Corrupted asset (magic mismatch, insufficient length) → CatalogCorruptedException (added to domain exceptions). The sky display continues without stars and the error is shown in the UI
- The conversion script skips rows of the input CSV that fail to parse, with aggregated logging (tolerance for missing data)

## Test Strategy

- SpatialIndex: full-sky sample coverage (every point belongs to some tile), center tile inclusion, RA 0°/360° wrap, near-pole behavior, count decreases with zoom
- StarAppearance: Sirius (B-V ≈ 0.0) → B component > R component, Betelgeuse (B-V ≈ 1.85) → R > B, magnitude monotonicity, fade floor
- TileBinaryCodec: encode → decode round-trip consistency, exception on corrupted data
- lodPolicy: boundary values, Bortle reflection
- AssetCatalogRepository: tile and magnitude filter verification with synthetic binary
- Selection: unit test of nearest-neighbor search

## Dependencies

No additions (rootBundle and dart:ui only)

## Implementation Order

1. Conversion script + asset generation (including SpatialIndex implementation)
2. Domain (Star / StarAppearance) + tests
3. Data layer (Codec / AssetCatalogRepository) + tests
4. Application layer (lodPolicy / visibleStars / settings / selection) + tests
5. Presentation (StarRenderer / SelectionRenderer / panel UI)
6. Verification (check.ps1 / Windows build / launch check) → merge

## Performance Considerations

- Rendering is consolidated into 1-2 drawAtlas batches. drawCircle per star is forbidden
- The star loop of ViewProjection.project uses the inlined-expanded expression (M1 implementation)
- RSTransform/Rect/Color lists are rebuilt every frame (acceptable for 9,000 entries). Consider a Float32List cache when scaling up in M5

## Future Extensibility

- CatalogRepository will be swapped for a drift implementation (DriftCatalogRepository) in M5. The interface is shared via tile + magnitude queries
- tileIndexOf is computed at encode time, so it can be used as-is after the DB migration
