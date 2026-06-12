# Task List

## 🚨 Principle of Complete Task Completion

Continue working until all tasks are `[x]`. Skipping only for technical reasons (state the reason explicitly).

---

## Phase 1: Data preparation

- [x] convert_constellations.dart (Stellarium index.json parsing, HIP → HYG coordinate resolution, B1875 → J2000 precession conversion of IAU boundaries, 88-constellation Japanese translation table, source and license noted)
- [x] Asset generation (88 constellations / 781 boundary polylines / 0 unresolved HIP / 162KB)

## Phase 2: Domain and data layers

- [x] ConstellationData / ConstellationSet / NameLanguage / ConstellationRepository (IF, with exception conditions in dartdoc)
- [x] AssetConstellationRepository (JSON loading, corruption detection)
- [x] Tests: nameIn language switching, repository (synthetic JSON, corruption)
- [x] Tests: regression verification of the generated asset (88 constellations, non-empty names, coordinate ranges, Orion's shape, precession plausibility of boundaries)

## Phase 3: Application layer

- [x] ConstellationSettingsController (lines/names/boundaries ON/OFF, opacity, width, language)
- [x] constellationSetProvider (loaded once at startup)

## Phase 4: Presentation layer

- [x] LabelDeclutter (greedy placement with grid hashing, designed for sharing with M4)
- [x] ConstellationRenderer (lines, boundaries, labels; the TextPainter cache was changed to a single-language cache that is disposed and rebuilt on language switch (addressing a mandatory validator finding))
- [x] SkyCanvas layer integration (after Grid, before Star)
- [x] Settings UI extension (constellation section: 3 toggles, 2 sliders, language SegmentedButton)
- [x] Tests: LabelDeclutter (4 cases)

## Phase 5: Quality checks, verification, merge

- [x] tool/check.ps1 all pass (78 tests)
- [x] flutter build windows --debug succeeds + launch check
- [x] implementation-validator review and fixes for mandatory findings (label cache lifetime management, dartdoc, citation comments, inflate for labels at the screen edge)
- [x] Post-implementation retrospective (bottom)
- [x] Merge to main and push

---

## Post-Implementation Retrospective

### Completion date
2026-06-11

### Differences between plan and actual

**What differed from the plan**:
- For constellation boundaries, CDS (VI/49) could not be downloaded due to anti-bot protection, so the edges from Stellarium index.json (same IAU boundaries, B1875) were used. As a result, everything is sourced from a single source together with the constellation lines
- The label cache was changed from the planned per-language multi-cache to "hold only the current language, dispose on switch" following a validator finding (cap of 88 entries, leak prevention)

**Newly required tasks**: addressing validator findings (cache lifetime, dartdoc, citation comments)

**Tasks skipped for technical reasons**: none

### Lessons learned

**Technical lessons**:
- Stellarium's modern sky culture index.json provides constellation lines (HIP), IAU boundaries (edges), and names in a single file; combined with HYG's hip column, no additional data sources are needed
- IAU boundaries are at the B1875 epoch, so precession conversion (Meeus Chapter 21, about a 1.7° RA shift) is mandatory. The interpolate-then-convert order preserves the straightness of the edges
- TextPainter must be disposed. Caching in a per-frame throwaway renderer is managed with static + explicit invalidation

**Process improvements**:
- The asset regression test (verifying the generated artifact in tests) is effective for quality assurance of the conversion script. Since the script itself is outside analyzer scope, this approach will be continued

### Suggestions for next time
- M4: when sharing LabelDeclutter with celestial object name labels, introduce a priority-based (magnitude-ordered) placement order
- Viewport pre-culling (bounding box) when boundaries are ON will be decided during the M6 frame measurements
- The layers-list identity check in SkyPainter.shouldRepaint is a known issue since M2. Revisit with state-based determination in the M8 rendering optimization
