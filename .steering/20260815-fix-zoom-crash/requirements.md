# Requirements

## Overview

Fix the crash that occurs on iOS when zooming in on the sky view. The Milky Way bands were drawn with `MaskFilter.blur`, whose rasterizer-side cost grows with the zoom level; past roughly 20° FOV the process exceeded iOS's 2 GB per-process memory limit and was killed.

## Background

The crash is an out-of-memory kill, not a rendering error. Evidence gathered from the device:

- `idevicecrashreport` pulled eleven `JetsamEvent` reports. In each, the victim is `Runner` with `reason: per-process-limit`, `states: ['frontmost']`, and `rpages` ≈ 136,000. At the device's 16 KB page size that is **≈ 2.2 GB** (`product: iPhone12,3`).
- Running under `flutter run --profile` reproduced it as
  `EXC_RESOURCE (RESOURCE_TYPE_MEMORY: high watermark memory limit exceeded) (limit=2098 MB)`.
- A temporary auto-zoom probe (a timer stepping the FOV 1.25× per tick while printing `ProcessInfo.currentRss`) showed the **Dart heap flat at ~100-130 MB the whole time** — the growth is entirely rasterizer/Metal side.

The probe was then used to bisect the layer stack:

| Build | Result |
|---|---|
| Unmodified | dies between FOV 22.9° and 18.4° |
| Milky Way layer disabled | reaches FOV 0.5°, RSS 115-133 MB |
| Milky Way kept, `MaskFilter.blur` removed | reaches FOV 0.5°, RSS 106-135 MB |

So the blur alone accounts for it. The mechanism: a blurred draw is rasterized into an offscreen sized from the draw's bounds, and both inputs scale with `pxPerDeg` (= screen height / FOV). At the 0.5° minimum FOV the widest band's stroke is ~25,000 px across and the projected galactic circle spans ±800,000 px.

Two narrower fixes were tried on the device first and **both failed**, which is what pinned the cause down:

1. Capping the blur sigma (`min(screenLongestSide * 0.25, 256)`) — still died at the same FOV, so the sigma is not what sizes the allocation.
2. Wrapping the layer in `canvas.clipRect(screen)` — also still died, so Impeller does not intersect the blur's allocation with the clip.

## Features to Implement

### 1. Milky Way bands drawn without a blur filter
- The soft edge is produced by concentric strokes instead of `MaskFilter.blur`
- No offscreen is allocated at any zoom level, so rasterizer memory no longer depends on the FOV
- The band keeps its shape (it still follows the projected galactic plane) and its brightness at the core

### 2. Zoom-independent layer geometry
- The stroke stack is computed in degrees, so it is identical at every zoom level and can be unit-tested without a rasterizer

## Acceptance Criteria

### Milky Way bands drawn without a blur filter
- [ ] Zooming from 120° to the 0.5° minimum FOV on the device completes without the app being killed
- [ ] RSS stays in the same band as with the Milky Way disabled (~100-150 MB), rather than climbing toward 2 GB
- [ ] The alphas of the layers sum to the band's nominal alpha, so the band core keeps its previous brightness

### Zoom-independent layer geometry
- [ ] `bandLayers` returns widths in degrees and does not take the FOV or screen size
- [ ] Layers are ordered widest/faintest first, and the accumulated alpha never exceeds the band alpha
- [ ] `flutter analyze` reports no new issues and `flutter test` passes

## Success Metrics

- Continuous pinch zoom from 120° to 0.5° and back is stable on the device

## Out of Scope

The following will NOT be implemented in this phase:

- Replacing the procedural Milky Way with a real texture (already noted as a future improvement in the renderer)
- Any change to the FOV clamp range or to the LOD magnitude policy
- Auditing other layers for blur usage — `MilkyWayRenderer` is the only painter that used a `MaskFilter`

## Reference Documents

- `docs/architecture.md` - Rendering and resource-usage constraints
- `docs/functional-design.md` - F1 sky rendering
- `docs/development-guidelines.md` - Performance rules for painters
