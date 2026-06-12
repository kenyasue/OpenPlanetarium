# Task List

## 🚨 Principle of Complete Task Completion

Continue working until all tasks are `[x]`. Skipping is allowed only for technical reasons (with the reason stated).

---

## Phase 1: HEALPix Geometry

- [x] Healpix: ang2pixNest / pixBoundary, pixGridPoint (continuous xyf inverse projection) / ancestor (grid position)
- [x] HipsTileRef / SurveyLayerDef (4 built-in layers, URL reachability verified) / chooseHipsOrder / tilesForViewport (screen sampling method)
- [x] Tests: round-trip consistency (orders 0–6), order 0 = 12 tiles, ancestor containment, order selection boundaries → 10 tests

## Phase 2: Caches

- [x] MemoryTileCache (LRU count limit, dispose)
- [x] DiskTileCache (size-limit LRU, index.json persistence, reconciliation, deferred persistence of lastAccess on get too, race protection on initialization)
- [x] Tests: LRU, limits, restoration for both caches, LRU order preserved after restart → 8 tests

## Phase 3: Fetch Service

- [x] HipsTileFetcher (IF) + DioHipsTileFetcher
- [x] SurveyTileService (memory → disk → network, 4 concurrent connections, tileVersion notification, 60-second negative cache, codec.dispose)
- [x] Tests: fetch flow with fakes, disk hit, failure suppression → 4 tests

## Phase 4: Rendering and Settings UI

- [x] SurveyRenderer (3×3 subdivided drawVertices + ImageShader, ancestor tile substitution (up to 3 levels), opacity via saveLayer)
- [x] SkyCanvas layer integration (immediately after the background) + tileVersion repaint
- [x] SurveySettingsController (persisted) + survey section in the settings screen (exclusive ChoiceChip, opacity, cache deletion, attribution display)
- [x] Visual check on device (launched with DSS Colored as default and verified via screenshot. Strict verification of texture orientation is M8 scope)

## Phase 5: Verification and Merge

- [x] tool/check.ps1 all pass (141 tests)
- [x] flutter build windows --debug succeeds + launch verified
- [x] implementation-validator verification and fixes for required findings (codec.dispose, lastAccess persistence on get (deferred batch), Completer pattern for _ensureInitialized)
- [x] Post-implementation retrospective (below)
- [x] Merge to main and push

---

## Post-Implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

**Points that differed from the plan**:
- Viewport tile enumeration adopted the screen sampling method rather than the BFS proposal (as per the adopted proposal in design.md. Simpler to implement and gap-free)
- ancestor()'s return value was changed from Rect uvRect to a grid position tuple (UV calculation is on the renderer side. More flexible than the spec)

**Newly required tasks**:
- Validator required findings: ui.Codec dispose, lastAccess persistence in DiskTileCache.get (2-second deferred batch), race protection on initialization

**Tasks skipped for technical reasons**: none (texture orientation verification was already defined as M8 scope in requirements.md)

### Lessons Learned

**Technical learnings**:
- HEALPix ang2pix / inverse projection (xyf2loc) can be self-verified with round-trip tests (center → pix match), and matched at all orders on the first implementation
- Texture mapping of HEALPix diamonds is possible with drawVertices + ImageShader. Curvature is approximated with 3×3 subdivision
- Both ui.Codec and ui.Image require dispose. Calling codec.dispose() immediately after obtaining the frame is the safe pattern

**Process improvements**:
- Screenshot capture (PowerShell + CopyFromScreen) allowed on-device display verification to be incorporated into the loop. Will be used heavily for M8's visual verification

### Improvement Suggestions for Next Time
- M8: visual verification and finalization of texture orientation (fx/fy ↔ image xy), skipping null-vertex portions of low-order tiles (validator issue 4), separating ancestor tile lookup into a read-only method (issue 3)
- Moving tilesForViewport from application → domain is an M8 refactoring candidate
