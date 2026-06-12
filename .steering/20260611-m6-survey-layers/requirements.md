# Requirements

## Overview

Implement Milestone 6 "Survey Layers (HiPS)" from the implementation plan. Overlay the 4 DSS layers (Colored / Blue / Red / NIR) as HiPS tiles on the star chart background, with tile caching (memory + disk LRU), opacity adjustment, and offline re-display (PRD F11).

## Features to Implement

### 1. HEALPix (NESTED) Geometry Calculations
- ang2pix (coordinates → tile number), celestial coordinates of the tile's 4 corners (continuous xyf → inverse spherical projection)
- Lower-order ancestor tile numbers and sub-quadrant UV (for gap filling)

### 2. HiPS Client and Tile Fetching
- FOV angle → order selection (functional design A6), enumeration of tiles intersecting the viewport (tile center + angular radius method)
- Tile URL construction (Norder/Dir/Npix), fetching via dio (limit of 4 concurrent connections)

### 3. Tile Cache
- Memory LRU (decoded ui.Image, count limit)
- Disk LRU (size limit, persisted index, offline re-display)

### 4. Survey Rendering and Settings
- SurveyRenderer: render tiles with drawVertices (textured 3×3 subdivided quads), layer order immediately after the background and below the horizon
- Unfetched tiles are substituted by sub-regions of ancestor tiles (A6)
- Settings: exclusive layer selection (none + 4 DSS types), opacity, cache limit; add a survey section to the settings screen
- When offline, display from cache only

### Verified HiPS URLs (CDS, as of 2026-06-11)
- DSS Colored: https://alasky.cds.unistra.fr/DSS/DSSColor
- DSS Blue:    https://alasky.cds.unistra.fr/DSS/DSS2-blue-XJ-S
- DSS Red:     https://alasky.cds.unistra.fr/DSS/DSS2Merged
- DSS NIR:     https://alasky.cds.unistra.fr/DSS/DSS2-NIR

## Acceptance Criteria

- [ ] HEALPix ang2pix → tile 4-corner round-trip consistency tests pass (center is inside the tile, midpoints of corners are in the same tile, etc.)
- [ ] Order selection changes according to field of view (FOV) and screen resolution (test)
- [ ] The disk cache observes its size limit via LRU (test)
- [ ] The memory cache observes its count limit via LRU (test)
- [ ] The 4 DSS layers can be switched in settings and opacity can be adjusted (UI)
- [ ] With a layer ON, survey imagery overlays the star chart (visual check on device)
- [ ] format / analyze / all tests pass, Windows build succeeds

## Out of Scope

- Strict verification of HiPS tile image orientation (rotation/flip) (the rendering pipeline is implemented; the final orientation adjustment will be done in M8's visual verification — interpreting the tile orientation convention requires visual confirmation)
- Simultaneous overlay of multiple surveys (exclusive switching only, as decided in the functional design's M3 spec change)
- Interpretation of properties/Allsky files (direct tile fetching approach)

## Reference Documents

- `docs/implementation-plan.md` Milestone 6
- `docs/functional-design.md` A6 / SurveyLayer / HipsSurveyProvider / TileCacheManager
- `docs/glossary.md` HiPS / HEALPix
