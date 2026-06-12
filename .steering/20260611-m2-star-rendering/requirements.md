# Requirements

## Overview

Implement Milestone 2 "Star Display" of the implementation plan. Load real star data equivalent to the BSC (down to magnitude 6.5) on a per-viewport basis, and render the stars beautifully according to magnitude and B-V color index.

## Background

On top of the coordinate transformation, projection, and viewport foundation built in M1, realize the core of the app: star display (PRD F1/F2/F5). The spatial index and LOD become the foundation for M5 (Tycho-2 partial download) and M6 (surveys).

## Features to Implement

### 1. Star catalog data preparation
- A conversion script that extracts stars down to magnitude 6.5 from HYG v4.1 (a real catalog integrating HIP/HD/HR) and generates a tile-partitioned binary asset
- Mapping of proper names (Sirius, etc.)

### 2. Spatial index and catalog access (F2)
- RA/Dec grid spatial index (functional design A1)
- CatalogRepository interface and asset implementation
- Zoom level → limiting magnitude LOD (A2)
- A visible-stars provider that follows viewportState changes (stale results are never displayed)

### 3. Star color and brightness display (F5)
- B-V → effective temperature → RGB conversion (A3, Ballesteros approximation)
- Magnitude → render size, glow, opacity (A4, based on the Pogson formula)
- Basic light-pollution level support (Bortle 1-9) (lowering the effective limiting magnitude)

### 4. Batched star rendering and selection
- StarRenderer: batched sprite rendering via drawAtlas (creating widgets per star is forbidden)
- Glow effect for bright stars
- Tap/click selects the nearest star and displays its information (name, magnitude, B-V)

## Acceptance Criteria

- [ ] All ~9,000 stars down to magnitude 6.5 across the whole sky are displayed in the correct positions (positions of Sirius, Betelgeuse, etc. visually verifiable)
- [ ] Sirius is rendered bluish-white and Betelgeuse reddish (color verified by unit tests)
- [ ] Stars in tiles outside the viewport are neither fetched nor rendered (verified by tests)
- [ ] When zoomed out (fov > 60°) stars are shown down to magnitude 6.0, when zoomed in down to 6.5 (LOD)
- [ ] The light pollution slider reduces the display of faint stars
- [ ] Clicking a star displays its name (or number) and magnitude
- [ ] Pan and zoom feel smooth (desktop)
- [ ] format / analyze / all tests pass, Windows build succeeds

## Out of Scope

- SQLite persistence via drift (technical judgment: ~9,000 BSC-class stars are light enough to keep fully in memory. The DB will be introduced together with the M5 Tycho-2 partial download/import. The CatalogRepository interface is defined so it can be swapped for a drift implementation in M5)
- Network download (M5) and prefetching (assets are fully loaded, so implemented in M5)
- Star twinkling and the Milky Way (M8)
- Star labels (to be designed together with constellation names in M3 and celestial object names in M4)

## Reference Documents

- `docs/implementation-plan.md` Milestone 2
- `docs/functional-design.md` A1-A4, F2/F5 acceptance criteria
- `docs/development-guidelines.md` performance conventions
