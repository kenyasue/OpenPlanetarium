# Design Document

## Architecture Overview

```
presentation/  SurveyRenderer (drawVertices textured quads) / SurveySettingsSection
application/   SurveyTileService (fetch queue, repaint notification) / SurveySettingsController (persistence)
domain/        Healpix (NESTED geometry) / HipsTileRef / SurveyLayer definitions
data/          HipsClient (URL construction + dio fetch) / MemoryTileCache / DiskTileCache
```

## Component Design

### 1. Healpix (lib/domain/spatial/healpix.dart)

- `int ang2pixNest(int order, double raDeg, double decDeg)` (standard HEALPix algorithm)
- `List<SkyPoint> pixCorners(int order, int pix, {int steps})`: returns tile boundary points via continuous xyf → inverse spherical projection (equivalent to healpix_base xyf2loc) (steps>1 also yields edge midpoints)
- `(int ancestorPix, Rect uvRect) ancestor(int order, int pix, int ancestorOrder)`: computes the ancestor tile and sub-quadrant UV from the lower bits of NESTED
- Source comments: Górski et al. (2005), healpix_base's xyf conversion

### 2. HipsTileRef / SurveyLayer (domain)

```dart
class HipsTileRef { final String surveyId; final int order; final int pix;
  String get path => 'Norder$order/Dir${(pix ~/ 10000) * 10000}/Npix$pix.jpg';
  String get key => '$surveyId/$order/$pix'; }
class SurveyLayerDef { final String id; final String name; final String baseUrl; final int maxOrder; }
```
- 4 built-in layers (verified URLs from requirements.md, maxOrder=9 or so)

### 3. Order Selection and Tile Enumeration (HipsGeometry, domain)

- order = clamp(ceil(log2(58.6° × pxPerDeg / 512)), 0, maxOrder) (the minimum order at which a 512px tile does not fall below the screen resolution)
- tilesForViewport: scanning all 12×4^order tiles is infeasible at high orders, so low orders (≤3) use full scan + angular distance check, and high orders use BFS from the center tile (neighbors expanded by angular distance check, capped at 64 tiles)
  - Simplified proposal: per order, tile angular radius ≈ 58.6°/2^order. Find tile centers within view diagonal + tile radius via the union of ang2pix of sample points within the viewport (unproject the screen over an 8×8 grid) + their neighbors (simple to implement and less prone to gaps) → adopted
- Adopted method: sample the screen at even intervals (about 1/2 of the tile's screen size) → ang2pix of each point → de-duplicate. Even at low orders where a tile is larger than the screen, the center point always yields at least 1 tile

### 4. Caches (data)

- MemoryTileCache: LRU via LinkedHashMap, max N entries (default 64). ui.Image is disposed
- DiskTileCache: `<cache>/survey_tiles/<surveyId>/<order>_<pix>.jpg` + index.json (key → size, lastAccess).
  On put, if over the limit, delete oldest first. On initialization, reconcile the index against actual files
- Fetch flow: memory → disk (decode and put into memory) → network (when allowed; save and put into memory/disk)

### 5. SurveyTileService (application)

- `ui.Image? tileImage(HipsTileRef ref)`: synchronous lookup (memory hits only). On miss, enqueue for fetching
- Fetch queue: 4 concurrent connections (semaphore); on completion increment `tileVersionProvider` (StateProvider<int>) → SkyCanvas repaint
- Offline / fetch failure: consult disk only. Failed tiles get a 60-second negative cache to suppress retries

### 6. SurveyRenderer (presentation)

- Layer order: immediately after BackgroundRenderer (below horizon, constellations, and stars)
- Per tile: project the 3×3 grid points from pixCorners and render with drawVertices (TextureCoordinates + ImageShader). Tiles containing unprojectable points are skipped
- Unfetched tiles: look up an ancestor via ancestor() (up to 3 levels up) and render its UV sub-rectangle as a substitute
- Opacity: Paint.color alpha (applied via colorFilter when using ImageShader)

### 7. Settings (SurveySettingsController, persisted)

```dart
class SurveySettings { final String? activeSurveyId; final double opacity; final int cacheLimitMb; }
```
- Survey section in the settings screen (layer ChoiceChip, opacity Slider, cache limit, cache deletion)

## Test Strategy

- Healpix: order 0 has 12 tiles, validity of ang2pix samples in all quadrants, pixCorners center containment (ang2pix of the center and corner midpoints lands in the same tile), ancestor UV/number consistency (the child's center lies within the ancestor's UV rectangle)
- Order selection: boundary values for fov/resolution
- DiskTileCache: size limit, LRU eviction, index restoration in a temporary directory
- MemoryTileCache: count limit, access order update
- SurveyTileService: fetch → version increment with a fake HipsClient, negative cache
- Rendering is verified visually on device (see the out-of-scope clause)

## Implementation Order

1. Healpix geometry + tests
2. The two caches + tests
3. HipsClient, SurveyTileService + tests
4. SurveyRenderer, SkyCanvas integration, settings UI
5. Verification → validator → merge

## Performance Considerations

- ang2pix for screen sampling is a few dozen points × trigonometry, negligible
- drawVertices is 9 quads = 54 vertices per tile. With ≲30 visible tiles this is negligible
- ui.Image decoding happens in the background (instantiateImageCodec)
