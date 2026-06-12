# Task List

## 🚨 Principle of Complete Task Completion

Continue working until all tasks are `[x]`. Skipping is allowed only for technical reasons (with the reason stated).

---

## Phase 1: Domain (Models, FOV Calculation)

- [x] Equipment models (Telescope / CameraDevice / Eyepiece / OpticalModifier / EquipmentSet, camera/eyepiece mutual exclusion assert)
- [x] FovCalculator (camera FOV atan formula, pixel scale, magnification, true field of view (TFOV), exit pupil, fit determination (rotation-free best case), mosaic plan)
- [x] Tests: PRD calculation examples (1% error KPI), fit of elongated/square objects, mosaic spacing / serpentine order / cos(dec) correction → 12 tests

## Phase 2: Data Layer

- [x] EquipmentDatabase (drift 5 tables, @DataClassName to avoid collision) + code generation
- [x] EquipmentRepository (IF) + DriftEquipmentRepository (upsert CRUD)
- [x] Tests: in-memory CRUD, equipment set saving, enum conversion fallback

## Phase 3: Application Layer

- [x] ActiveFovController (set selection, rotation, mosaic settings, persistence, disposed guard)
- [x] fovFrameProvider (equipment set → FovFrame derivation) + fovFitProvider (fit determination for the selected DSO)
- [x] Tests: frame derivation (camera rectangle / eyepiece circle + Barlow), null on broken references → 3 tests

## Phase 4: Presentation

- [x] FovFrameRenderer (rectangle, circle, rotation, mosaic grid + numbers, annotation labels (declutter), TextPainter disposed)
- [x] SkyCanvas integration (immediately before Selection, tracking the selected celestial object or screen center)
- [x] EquipmentScreen (per-type lists, add/edit/delete dialogs, validation, equipment set editing (mode exclusion, color selection))
- [x] FovControlSection (left panel: set selection, rotation slider, mosaic rows/columns/overlap, 3-color fit determination display) + settings screen entry point
- [x] ~~Visual check (frame display, rotation, mosaic)~~ (alternative performed: launch and continuous operation check + 3 unit tests of derivation logic. Frame display requires UI operations to register equipment, so it will be done in M8's acceptance testing)

## Phase 5: Verification and Merge

- [x] tool/check.ps1 all pass (159 tests)
- [x] flutter build windows --debug succeeds + launch verified
- [x] implementation-validator verification and fixes for required findings (fixed checkFit to rotation-free best-case determination + added tests, dispose dialog TextEditingControllers in finally/whenComplete)
- [x] Post-implementation retrospective (below)
- [x] Merge to main and push

---

## Post-Implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

**Points that differed from the plan**:
- Did not create FovSimulationService (abstract IF); instead consolidated into the pure-calculation static class FovCalculator (no I/O, so no mocking needed. The IF deviation from the functional design is recorded for M8's docs reconciliation)
- checkFit was fixed per validator finding to the "rotation-free best case" (min of the 2 axis pairings)

**Newly required tasks**:
- 2 validator required findings (checkFit axis pairing, controller dispose) + fovFrameProvider tests (as listed in the design document)

**Tasks skipped for technical reasons**:
- The visual check of frame display involves UI operations to register equipment, so it was replaced by unit tests + M8 acceptance testing (noted in Phase 4)

### Lessons Learned

**Technical learnings**:
- For functional dialogs (showXxxDialog), disposing TextEditingControllers in finally/whenComplete is the minimal-change pattern
- Fit determination must take the min of the 2 rotations rather than a fixed "major axis ↔ long side" pairing, or square objects are misjudged
- drift's @DataClassName is essential to avoid name collisions with domain models (re-application of the M5 lesson)

**Process improvements**:
- The validator identified the checkFit axis-pairing bug along with a test gap. Write test cases for boundary shapes (square, elongated) from the start

### Improvement Suggestions for Next Time
- M8: unify FovFrameRenderer's TextPainter caching (same pattern as other renderers), warn about referencing sets when deleting equipment, share the minCosDec constant, update the FovSimulationService description in docs/functional-design.md to match the implementation
