# Requirements: Mobile-only Wi-Fi Restriction, Semi-transparent Ground, Display Magnitude Slider

Date: 2026-06-11

## User Requests (summary of original wording)

1. Downloading additional catalogs demands a Wi-Fi connection. On wired (desktop) machines
   this validation is unnecessary. Remove it or make it a mobile-device-only feature.
2. Fill the area below the horizon with semi-transparent black to make it clear that it is below the ground.
3. Change the light pollution slider (Bortle 1-9) to a "show down to magnitude N" expression,
   supporting down to magnitude 20.

## Acceptance Criteria

- [ ] On desktop (Windows/macOS/Linux), downloads work over wired or any connection even with the
      "Wi-Fi Only" setting (the check itself is skipped)
- [ ] On mobile (Android/iOS), the Wi-Fi connection check works as before
- [ ] The area below the horizon is filled with semi-transparent black (tracking pan, zoom, and time changes)
- [ ] The horizon line and direction labels remain displayed on top of the fill
- [ ] The light pollution slider becomes "show down to magnitude N" (1-20 mag, 0.5 steps)
- [ ] All existing tests pass + new tests added
