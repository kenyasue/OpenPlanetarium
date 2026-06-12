# Task List

## 🚨 Principle of Complete Task Completion

Continue working until all tasks are `[x]`. Skipping is allowed only for technical reasons (with the reason stated).

---

## Phase 1: Starry Sky Rendering

- [x] MilkyWayRenderer (multi-layer blurred light band along the galactic plane + galactic center bulge) + display setting ON/OFF (persisted)
- [x] Tests: galactic coordinate conversion (galactic center RA 266.4°/Dec -28.9°, north pole, orthogonality of the plane, vicinity of Deneb) → 4 tests

## Phase 2: Known Rendering Issues

- [x] Clean up SkyPainter.shouldRepaint (always true + reason comment, since a new painter is only created when providers change)
- [x] Cache TextPainters in FovFrameRenderer (panel numbers = number × color key, annotations = text × color key)
- [x] Share the cos(dec) floor constant (kMinCosDec, with source comment)

## Phase 3: Documentation and Release

- [x] Update docs/functional-design.md (FovCalculator description)
- [x] Update README.md (overview, features, build instructions, data sources)
- [x] Fill in actual results for implementation-plan.md M8 completion criteria (noted mobile measurement, other-OS builds, E2E, and tile orientation verification as remaining work)
- [x] tool/check.ps1 all pass (163 tests)
- [x] flutter build windows --release succeeds + launch verified (screenshot is indicative only as another window was in the foreground. Continuous process operation confirmed)
- [x] implementation-validator verification and fixes for required findings (include color in the annotation label cache key, align rendering order comments)
- [x] Post-implementation retrospective (below)
- [x] Merge to main and push

---

## Post-Implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

**Points that differed from the plan**: none (as scoped in requirements.md)

**Newly required tasks**:
- Validator required finding: add color to the invalidation key of the annotation label cache (bug where changing an equipment frame color was not reflected)

**Tasks skipped for technical reasons** (pre-defined as out of scope in requirements.md):
- Star twinkling (constant repaint cost), real mobile device measurement and other-OS builds (no environment), strict HiPS tile orientation verification (requires interactive verification), E2E setup — all recorded as remaining work in implementation-plan.md

### Lessons Learned

**Technical learnings**:
- The procedural representation of the galactic plane can be implemented with 3 IAU constants and the standard conversion formulas, and can be self-verified with reference value tests (galactic center, north pole)
- The invalidation key of a static cache must include "all inputs affecting rendering" (not just text but also color)

**Process improvements**:
- Across the 8 milestones, the loop of validator finding → fix → added test stabilized quality. Backlogged findings were also recovered in M8

### Improvement Suggestions for Next Time (remaining pre-release work, also recorded in implementation-plan.md)
- fps measurement on real mobile devices and performance class tuning, builds and packaging for other OSes
- Consolidate MilkyWayRenderer's blur passes (4 → 1) and cache point sequences (for low-spec devices)
- 5 E2E scenarios via integration_test, all-sky cross-check of HiPS tile orientation
