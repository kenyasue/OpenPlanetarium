# Requirements

## Overview

Implement Milestone 3 "Constellation Display" of the implementation plan. Beautifully display the constellation lines, constellation names, and constellation boundaries of all 88 constellations, with individual ON/OFF, opacity, line width, and name-language switching (Japanese/English/Latin) (PRD F6).

## Background

Star display was completed in M2; visualizing the connections between stars (constellations) supports beginners' understanding of the sky (Persona 1). Label rendering and overlap avoidance will also be reused for celestial object name display in M4.

## Features to Implement

### 1. Constellation data asset generation
- Resolve the constellation lines (HIP polylines) of the Stellarium modern sky culture (index.json) to HYG coordinates
- Convert the IAU boundaries (edges, B1875 epoch) to J2000 via precession and turn them into boundary polylines
- Names of the 88 constellations (Latin = native / English / Japanese = translation table inside the conversion script)
- Label anchor positions (average of constellation line vertices)

### 2. Constellation rendering
- ConstellationRenderer: rendering of lines, boundaries, and name labels (below the star layer, above the grid)
- Label overlap avoidance (greedy placement via grid hashing)

### 3. Display settings
- Individual ON/OFF for lines/names/boundaries, line opacity and width, name-language switching
- Added to the display settings section of the left panel (desktop)

## Acceptance Criteria

- [ ] Constellation lines of all 88 constellations are displayed (the shapes of Orion and the Big Dipper (Ursa Major) visually verifiable)
- [ ] Constellation names are displayed in the selected language (Japanese/English/Latin)
- [ ] Constellation boundaries can be displayed (precessed to J2000)
- [ ] Lines, names, and boundaries can each be toggled ON/OFF
- [ ] Line opacity and width are adjustable
- [ ] Labels do not overlap each other (when they would overlap, one is omitted)
- [ ] The frame rate feels smooth even with constellation display ON
- [ ] format / analyze / all tests pass, Windows build succeeds

## Out of Scope

- Constellation artwork illustration display (P1. Stellarium's illustrations require individual license verification, so the art display pipeline will be considered in M8 together with self-made assets) — P1 items of the implementation plan follow the backlog rule
- Display mode switching such as education mode (P1)
- Per-constellation detailed information display (integrated with search and details in M4)

## Reference Documents

- `docs/implementation-plan.md` Milestone 3
- `docs/product-requirements.md` F6
- `docs/functional-design.md` ConstellationData / SkyPainter layering order
