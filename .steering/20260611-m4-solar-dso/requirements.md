# Requirements

## Overview

Implement Milestone 4 "Solar System and Deep Sky Objects" of the implementation plan. Complete the display of the Sun, Moon, planets, and Messier/major NGC objects (F7), search (F8), object details (F9), and observation support (date/time change, time slider, diurnal motion, moon age, F10).

## Features to Implement

### 1. EphemerisEngine (ephemeris computation)
- Apparent positions of the Sun (Meeus Chapter 25 low precision), Moon (Meeus Chapter 47 principal terms), and 7 planets (Standish approximate Keplerian elements)
- Moon age, illuminated fraction, rise/set and transit times (Meeus Chapter 15)

### 2. Display of solar system and deep sky objects
- SolarSystemRenderer: Sun (glow), Moon (phase rendering according to moon age), planets (stylized disks in characteristic colors, Saturn = rings, Jupiter = bands)
- DSO asset extracting the 110 Messier objects + bright NGC/IC (V ≤ magnitude 10) from OpenNGC
- DsoRenderer: type icons (galaxy = ellipse / cluster = dot-cluster style / nebula = dashed circle) + labels (shared LabelDeclutter, magnitude LOD)

### 3. Search (F8)
- Search and interpretation of celestial object names (Japanese/English), constellation names, M/NGC/IC numbers, and planet names
- Selecting a result centers the sky chart (desktop: left panel, mobile: search button → sheet)

### 4. Object details (F9) and selection integration
- Unify the selection target into SkyObject (star/DSO/solar system body), with tap selection supporting all types
- Detail display: name, type, magnitude, constellation, coordinates, current altitude/azimuth, rise/set/transit times, description

### 5. Observation support (F10)
- Time slider (±12 hours) and diurnal motion playback (speed multipliers), "return to current time"
- Moon age display (bottom bar)

## Acceptance Criteria

- [ ] The solar position matches Meeus example 25.a (1992-10-13) within ±0.05° (test)
- [ ] The lunar position matches Meeus example 47.a (1992-04-12) within ±0.3°, planets (Venus, equivalent to Meeus 33.a) ±0.2° (test)
- [ ] The Moon is rendered with a shape according to its age, and the moon age is shown in the bottom bar
- [ ] Saturn has rings and Jupiter has bands as stylized representations
- [ ] Searches for M31 / NGC 891 / Sirius / Orion / Saturn / すばる (Subaru, the Japanese name for the Pleiades) hit and center the view (test)
- [ ] The details of any object show rise/set and transit times
- [ ] The sky follows the time slider, and the play button animates diurnal motion
- [ ] format / analyze / all tests pass, Windows build succeeds

## Out of Scope

- Planet rendering with photographic textures (considered in M8. Stylized representation satisfies the MVP acceptance; PRD F7's "textures close to the actual appearance" remains as an M8 quality improvement item)
- DSO thumbnail photos (icon display substitutes. F7's acceptance criterion is "icon or thumbnail")
- List of currently visible objects and recommended objects (P1, M8 backlog)
- Advanced fuzzy matching in search (handled with prefix matching + alias table)

## Reference Documents

- `docs/implementation-plan.md` Milestone 4
- `docs/functional-design.md` EphemerisEngine / SearchService / UC3 / screen transitions
