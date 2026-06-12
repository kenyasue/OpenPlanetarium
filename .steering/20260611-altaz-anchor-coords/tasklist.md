# Task List

## Phase 1: AltAz-anchored Rendering

- [x] Listen for time changes in ViewportController and recompute the center to maintain the pre-change Alt/Az
- [x] Unit tests: the view center's Alt/Az is preserved after a time change (single change + drift verification over 600 steps)

## Phase 2: Always-on Coordinate Display

- [x] New CoordinateDisplay widget (altitude/azimuth + RA (hms)/Dec (dm), tracking viewportState)
- [x] desktop_layout: placed at the top right (above the celestial object detail panel)
- [x] mobile_layout: placed at the top right

## Phase 3: Mobile 3-row Layout

- [x] Split _TimeBlock into _TimeSliderRow (time + slider) and _PlaybackControls (playback + Now)
- [x] multiline: row 1 = full-width slider, row 2 = playback + icon group (Wrap), row 3 = status
- [x] Update Widget tests (verify slider and coordinate display at mobile width)

## Phase 4: Verification

- [x] tool/check.ps1 fully passing (176 tests)
- [x] Merge to main and push

---

## Post-implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

- Mostly as planned. Visual confirmation via screenshots was abandoned because the user
  was using the screen, so verification was done with Widget tests (both desktop 1800px and mobile 420px).
- Splitting _TimeBlock yielded a secondary optimization: even in single-row mode,
  the playback controls are no longer rebuilt by the time tick.

### Lessons Learned

- `ref.listen` inside Riverpod v3's Notifier.build is well suited to updating state in
  response to changes in other providers without rebuilding the provider itself
  (re-anchoring the view center from time changes). Since both previous/next are passed,
  "compute Alt/Az at the pre-change time → inverse-transform at the new time" can be
  implemented without a loop.
- Because equatorialToHorizontal / horizontalToEquatorial are exact inverse transforms,
  the cumulative drift stays under 1e-3° even over 600 fine time steps.

### Improvement Suggestions for Next Time

- Whether to also anchor to Alt/Az when the observing location changes (currently it stays
  RA/Dec-anchored) needs consideration. When switching to a travel destination, "keep looking
  in the same direction" may be more intuitive.
