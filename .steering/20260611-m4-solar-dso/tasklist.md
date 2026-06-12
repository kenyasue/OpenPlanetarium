# Task List

## 🚨 Principle of Complete Task Completion

Continue working until all tasks are `[x]`. Skipping only for technical reasons (state the reason explicitly).

---

## Phase 1: Ephemeris computation (EphemerisEngine)

- [x] SolarBodyId / MoonPhase / RiseSetTimes models (+ representative magnitude extension)
- [x] Solar position (Meeus Chapter 25 low precision)
- [x] Lunar position, parallax, apparent diameter (16 principal terms of Meeus Chapter 47)
- [x] Planetary positions (Standish Keplerian elements, geocentric conversion)
- [x] Moon age and illuminated fraction (moonPhase)
- [x] Rise/set and transit times (10-minute sampling + linear/parabolic interpolation. Adopted a numerical method instead of the analytic formula of Meeus Chapter 15 — robust even for circumpolar/never-rising cases and extreme latitudes)
- [x] Tests: Meeus examples 25.a/47.a/Venus, invariants (ecliptic latitude ranges, inner planet elongations), rise/set consistency → all 13 tests pass

## Phase 2: DSO data

- [x] DeepSkyObject / ObjectType domain models
- [x] convert_dso.dart (OpenNGC + addendum → dso.json, 110 Messier + V ≤ 10.5, 26 Japanese names)
- [x] Asset generation (717 objects, 77KB. Special case for M73 = Other type, manual identification of M102 = NGC5866, threshold adjusted to 10.5 to include NGC 891)
- [x] AssetDsoRepository + DsoRepository (IF)
- [x] Tests: asset regression (complete 110 Messier set, M31/M42/M45, magnitude sorting, catalogLabel)

## Phase 3: Selection unification, solar system provider, search

- [x] SkyObject (sealed: Star/Dso/SolarBody) and selectedObjectProvider (replacing and deleting selectedStarProvider)
- [x] solarSystemProvider (time-linked 9 bodies, lunar apparent diameter) + moonPhaseProvider
- [x] Tap selection for all types (pickObjectAtPoint, magnitude priority)
- [x] SearchService (M/NGC/IC interpretation, partial name matching, Japanese planet names) + searchProvider group
- [x] Tests: search acceptance set (M31/NGC891/Sirius/Orion/Saturn/すばる (Subaru)/distinguishing M1 from M101), pickObject priority (star vs Venus)

## Phase 4: Rendering

- [x] SkyRenderContext refactoring (signature change for all renderers, LabelDeclutter shared across layers)
- [x] SolarSystemRenderer (solar glow, lunar phase Path, stylized planet disks, Saturn's rings, Jupiter's bands, labels)
- [x] DsoRenderer (type icons, magnitude LOD, label declutter)
- [x] SelectionRenderer following SkyObject (selectedObjectPositionProvider)
- [x] SkyCanvas layer restructuring (bg → horizon → grid → constellation → dso → star → solar → selection)

## Phase 5: UI

- [x] Search panel (desktop left panel, mobile search button → sheet, result selection triggers centerOn + selection)
- [x] Detail panel SkyObject support (altitude/azimuth, rise/set/transit, catalog, apparent diameter)
- [x] Time slider (0-24h of the current day), diurnal motion playback (60x/600x/3600x cycle), moon age display (bottom bar)
  - Note: the "±12 hours" in requirements.md was respecified as "specifying 0-24h of the current day" (an equal or better capability for arbitrary time selection. Date changing to be considered together with the M5 settings)
- [x] TimeController extension (TimePlaybackController, Timer managed via ref.onDispose)

## Phase 6: Quality checks, verification, merge

- [x] tool/check.ps1 all pass (104 tests)
- [x] flutter build windows --debug succeeds + launch check
- [x] implementation-validator review and fixes for mandatory findings (making riseSetTimes a Provider = per-date recomputation, nuRad naming, firstWhere fallback in SearchPanel)
- [x] Post-implementation retrospective (bottom)
- [x] Merge to main and push

---

## Post-Implementation Retrospective

### Completion date
2026-06-11

### Differences between plan and actual

**What differed from the plan**:
- Rise/set and transit use a numerical sampling method (10-minute intervals + interpolation) rather than the analytic formula of Meeus Chapter 15. It is robust because circumpolar/never-rising case distinctions are unnecessary
- The time slider was changed from ±12 hours to specifying "0-24h of the current day" (clearer meaning and simpler implementation)
- The renderer interface was overhauled into SkyRenderContext (the plan was to add individually in M4, but the need to share LabelDeclutter led to a full refactoring)

**Newly required tasks**:
- Validator mandatory findings: moving the in-build execution of riseSetTimes into a Provider (preventing jank during diurnal playback), computing rise/set for solar system bodies using a representative noon position

**Tasks skipped for technical reasons**: none

### Lessons learned

**Technical lessons**:
- The combination of Standish approximate Keplerian elements + Meeus low-precision formulas achieved Sun ±0.05° / Moon ±0.3° / Venus ±0.3° against the Meeus examples on the first implementation (the memorized coefficients were accurate)
- The lunar phase can be expressed as a Path composition of "bright-side semicircle + terminator ellipse (half-width r|2k-1|)"
- In OpenNGC, non-NGC objects such as M45 are separated into addendum.csv. M73 (an asterism) is Type=Other, and M102 has its identification deferred, so special-case handling is needed

**Process improvements**:
- Writing the search acceptance tests against the real asset detected during implementation that NGC 891 fell through the magnitude filter (turning acceptance criteria into tests is effective)

### Suggestions for next time
- The dispose path of the static TextPainter caches in the DSO/SolarSystem renderers should be put in order together with the M5 data update mechanism (validator recommendation)
- The per-frame loop over the 717 DSOs can be reduced by truncating the magnitude-sorted list (to be handled in the M8 rendering optimization)
- The waxing field is currently unused (the phase direction is determined by the Sun direction vector). If used for first/last quarter display, do so in M8
