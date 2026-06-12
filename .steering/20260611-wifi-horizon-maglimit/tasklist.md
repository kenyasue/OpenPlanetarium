# Task List

## Phase 1: Mobile-only Wi-Fi Restriction

- [x] DownloadController: make the Wi-Fi check mobile-only via isMobilePlatformProvider (connectivity check also DI'd via unmeteredConnectivityCheckerProvider; wired connections also allowed)
- [x] DataManagementSection: supplementary note on desktop
- [x] Tests: on desktop the download starts even with wifiOnly; on mobile it is rejected as before (+ succeeds when connected to Wi-Fi)

## Phase 2: Semi-transparent Fill Below the Horizon

- [x] Add centerAltRad/scalePx/screenCenter getters to ViewProjection
- [x] New GroundRenderer (analytic circle/line determination + evenOdd fill)
- [x] sky_canvas: change the render order to ground fill → horizon line after stars and the solar system
- [x] Tests: inside/outside determination is correct in 7 cases — center altitude positive/negative/near 0/zenith/nadir/off-screen

## Phase 3: Display Magnitude Slider (mag 1-20)

- [x] AppearanceSettings: remove bortle, consolidate into userLimitingMagnitude (clamped 1-20)
- [x] Persistence: read and discard the bortle key, add setLimitingMagnitude
- [x] lod_policy: extend the LOD table (8.0/10.5/14.0/20.0) + effective magnitude = min(LOD, user)
- [x] StarAppearance.renderParams: tie the fade start to the user magnitude
- [x] UI: change the ControlBar dialog + DisplaySettingsSection to a "show down to magnitude N" slider
- [x] Fix existing tests (places referencing bortle) + new tests
- [x] docs/functional-design.md: update the A2 table and A4 light pollution descriptions (+ glossary.md)

## Phase 4: Verification

- [x] implementation-validator verification and fixes for required findings (0 required, 3 recommended applied)
- [x] tool/check.ps1 fully passing (187 tests)
- [x] Post-implementation retrospective
- [x] Merge to main and push

---

## Post-implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

- Mostly as planned. Validator findings (all recommended) were applied:
  - Added a backward-compatibility test reading saved JSON containing only the old bortle key
  - Changed the 2 remaining "light pollution level" mentions in functional-design.md to "display limiting magnitude"
  - Added a comment to GroundRenderer's yz computation noting it also works correctly at the true nadir (denominator 0 → Infinity)
- The validator suggested re-adding `dart:typed_data`, but this was declined because the analyzer's
  unnecessary_import (provided by flutter/foundation) makes its removal mandatory.

### Lessons Learned

- Because stereographic projection maps circles to circles, the horizon (great circle) fill can be
  implemented without mesh subdivision, using an analytic circle (center always on the vertical line
  through the screen center) + an evenOdd Path. Since the radius diverges at center altitude ≈ 0,
  a fallback to a straight-line approximation is needed.
- Wrapping platform-dependent branching (the Wi-Fi restriction) in a Provider (isMobilePlatformProvider)
  rather than referencing defaultTargetPlatform directly allows it — together with the connectivity check
  (unmeteredConnectivityChecker) — to be freely overridden in tests.
- Letting the user directly manipulate "show down to magnitude N" is more intuitive than an
  indirect metric like the Bortle scale, and it unifies LOD and the fade-start magnitude on a
  single consistent axis.

### Improvement Suggestions for Next Time

- Magnitude-20 support is complete through UI, LOD, and fade, but the deepest current catalog is
  Tycho-2 (mag 10). When adding deeper catalogs such as Gaia DR3, the download size and tile
  partitioning will need a redesign (finer Norder subdivision).
- If the ground fill's color/opacity is to be made configurable, add it to AppearanceSettings.
