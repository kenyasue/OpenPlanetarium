# Requirements: AltAz-anchored Rendering, Always-on Coordinate Display, Mobile 3-row Layout

Date: 2026-06-11

## User Requests (summary of original wording)

1. Make the mobile bottom controls 3 rows and make the time slider as long as possible
2. When the time is changed, render anchored to Alt/Az (horizontal coordinates) instead of the current RA/Dec anchoring
   (matching the intuition of standing on the ground looking up; stars move across the FOV as the time changes)
3. Always display the current view-center coordinates in both AltAz and RA/Dec at the top right of the screen

## Acceptance Criteria

- [ ] Mobile: row 1 = time slider (maximum width), row 2 = playback controls + settings icons, row 3 = status
- [ ] Whether the time is changed via the time slider, diurnal playback, date/time pickers, or the Now button,
      the Alt/Az of the view center is maintained
- [ ] Altitude/azimuth and RA/Dec are always displayed at the top right on both desktop and mobile,
      and track panning, zooming, and time changes
- [ ] All existing tests pass + new tests added
