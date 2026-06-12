# Requirements (Bug Fix)

## Reported Problem

The HiPS survey display looks wrong, clearly appearing to stop partway through (user report, 2026-06-11).
The FPS KPI is not a concern; accurate display takes priority.

## Root Cause Analysis

1. **Texture orientation rotated 180°**: The mapping between tile image and in-face coordinates was assumed to be (image x=1-fy, image y=1-fx), but verification against real data (cross-checking the DSSColor Norder4/Npix29.jpg tile containing M45 with in-face coordinates) showed the correct mapping is **(image x=fy, image y=fx)**. Every tile was drawn rotated 180°, failing to align with adjacent tiles and producing a broken patchwork appearance
2. **Whole-tile skipping at the FOV edge**: Tiles containing even a single unprojectable point (behind the FOV) were skipped entirely, causing large gaps at wide FOV (orders 0-2, tile angular size 30-60°) — the main cause of the "stops partway" appearance
3. **Insufficient subdivision of huge tiles**: A fixed 3×3 subdivision could not represent the spherical curvature of low-order tiles, causing misalignment at boundaries
4. **Sampling misses at the screen edge**: Tile enumeration sampled only within the screen, occasionally missing edge tiles

## Fix Details

- Corrected the UV mapping to the correspondence confirmed with real data (image x=fy / image y=fx) (sub-quadrants of ancestor tiles also have X/Y swapped)
- Per-quad partial rendering (only quads whose 4 vertices are projectable are drawn; the whole tile is not discarded)
- Adapt the subdivision count to the tile angular size (about 4°/quad, 3-16 subdivisions)
- Extended tile enumeration sampling to one step beyond the screen edge
- Extended ancestor-tile fallback from a fixed 3 levels to going all the way back to order 0
- Increased the in-memory tile cache capacity from 64 to 192 (prevents thrashing at wide FOV; the FPS KPI is not a concern)

## Acceptance Criteria

- [ ] All existing tests pass
- [ ] Wide-FOV and medium-FOV screenshots with survey ON (DSS Colored) show a continuous display with no gaps or rotation misalignment
