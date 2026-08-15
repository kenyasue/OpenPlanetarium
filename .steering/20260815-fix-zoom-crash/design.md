# Design Document

## Architecture Overview

No architectural change. The fix is local to one painter, `lib/presentation/painters/milky_way_renderer.dart`, which implements `SkyLayerRenderer` and is composed into the layer list by `SkyCanvas`.

```
SkyCanvas → SkyPainter → layers[]
                           └─ MilkyWayRenderer.render(canvas, context)
                                └─ bandLayers(widthDeg, alpha)  ← soft edge, no filter
```

## Component Design

### 1. `MilkyWayRenderer.bandLayers` (pure function)

**Responsibilities**:
- Turn one band (angular width, alpha) into the stack of concentric strokes that reproduces its softened cross-section

**Implementation notes**:
- The cross-section is modelled as: full strength inside `core = width/2 - σ`, smoothstep falloff to zero at `outer = width/2 + 2σ`, with `σ = 0.35 * width` — the same 0.35 factor the old `MaskFilter.blur` used, so the visible extent of the glow is unchanged.
- The span `[0, outer]` is divided into `_layerCount + 1` rings. Walking from the outermost ring inward, each stroke is given the alpha its ring is still missing: `alpha_i = bandAlpha * profile(ringMidpoint) - alreadyCovered`. A point at distance *d* from the centre line is painted by every stroke at least `2d` wide, so the accumulated alpha traces the profile.
- Widths are returned in **degrees**, not pixels. The stack therefore does not depend on the zoom level or the screen — which is both the point of the fix and what makes it unit-testable without a rasterizer.
- Alpha compositing is `1-(1-a₁)(1-a₂)…` rather than a plain sum. These alphas total under 0.1, where the difference is below 0.5% — documented in the code rather than corrected for.

### 2. `MilkyWayRenderer.render`

**Responsibilities**:
- Project each band's centre line once and stroke the layer stack along it

**Implementation notes**:
- The projected polyline is computed once per band and reused by all of its layers; only the `Paint` differs.
- The bulge highlight keeps its radial gradient. A gradient shader is evaluated per screen pixel inside the device clip and allocates no offscreen, and the probe run that removed only the blur (bulge still drawn, bands still 25,000 px wide) stayed flat at ~130 MB — so it is not implicated.

## Data Flow

### Rendering one frame of the Milky Way
```
1. SkyPainter builds SkyRenderContext (projection + state), pxPerDeg = height / fovDeg
2. For each band: project the centre line (121 samples of the galactic circle)
3. layers = bandLayers(widthDeg, alpha)          ← degrees, zoom independent
4. For each layer, widest first: stroke the polyline at layer.widthDeg * pxPerDeg
```

## Error Handling Strategy

### Custom Error Classes

None. The failure being fixed is an OS memory kill, not a Dart-level error, so it cannot be caught — it has to be prevented by construction.

### Error Handling Patterns

Unchanged.

## Test Strategy

### Unit Tests
- `bandLayers` is deterministic and independent of zoom
- Layer alphas sum to the band alpha (the core keeps its brightness)
- Layers are ordered widest/faintest first (drawing order is load-bearing)
- The widest stroke reaches beyond the nominal band edge and contributes less than half the peak ring
- The accumulated alpha never overshoots the band alpha

### Integration Tests
- Recording the layer into a `PictureRecorder` at both FOV extremes completes without throwing

### On-device verification
- The temporary auto-zoom probe (FOV 120° → 0.5°, printing `ProcessInfo.currentRss`) must complete with RSS flat

## Dependencies

None added.

## Directory Structure

```
lib/presentation/painters/milky_way_renderer.dart       (blur replaced by layered strokes)
test/presentation/painters/milky_way_renderer_test.dart (rewritten for bandLayers)
```

## Implementation Order

1. Replace the blurred stroke with `bandLayers` + concentric strokes
2. Rewrite the unit tests around `bandLayers`
3. `flutter analyze` / `flutter test`
4. Re-run the on-device auto-zoom probe, then strip the temporary probe code
5. Rebuild and reinstall on the device

## Security Considerations

- None.

## Performance Considerations

- Rasterizer memory becomes independent of the zoom level: the measured RSS at the 0.5° minimum FOV is ~147 MB, against a 2 GB kill before.
- Per frame the Milky Way now issues up to 6 strokes per band instead of 1 blurred stroke (4 bands → up to 24 stroked polylines). Each is an ordinary translucent stroke with no offscreen, which is far cheaper than the blur it replaces; the projection work is unchanged because the polyline is shared across a band's layers.

## Future Extensibility

`_layerCount` trades smoothness against overdraw and can be tuned in one place. If the procedural bands are later replaced by a Milky Way texture, `bandLayers` disappears with them — and the constraint it encodes (no zoom-scaled filter in a painter) should carry over to whatever replaces it.
