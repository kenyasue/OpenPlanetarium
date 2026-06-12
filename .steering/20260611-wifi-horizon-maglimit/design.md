# Design: Mobile-only Wi-Fi Restriction, Semi-transparent Ground, Display Magnitude Slider

## 1. Mobile-only Wi-Fi Restriction

- Run the Wi-Fi check in `DownloadController.startDownload` only when
  `defaultTargetPlatform` is Android/iOS
  (controllable in tests via `debugDefaultTargetPlatformOverride`).
- Inject the determination via a Provider (`isMobilePlatformProvider`) for testability.
- `DataManagementSection`: on desktop, show a supplementary note
  "applies only on mobile devices" when "Wi-Fi Only" is selected.

## 2. Semi-transparent Fill Below the Horizon

- Exploit the property that in stereographic projection the image of a great circle (alt=0)
  is a circle or a straight line, and derive the fill region analytically (no mesh subdivision needed).
- Add `centerAltRad` / `scalePx` / `screenCenter` getters to `ViewProjection`.
- Horizon circle in tangent-plane coordinates (y = zenith direction):
  - Horizon point at the view-center azimuth: y_a = -2·tan(alt0/2)
  - Horizon point at the opposite azimuth: y_b = +2·sin(alt0)/(1-cos(alt0))
  - Circle: center y=(y_a+y_b)/2, radius=(|y_b-y_a|)/2 (the x center is always the screen center)
  - The image of the zenith y_z = 2·cos(alt0)/(1+sin(alt0)) is inside the circle → sky = inside,
    ground = outside (fill rectangle minus circle with evenOdd). If outside, ground = inside the circle (fill the circle).
  - When |alt0| is small or the radius is huge (>10^6px), use a straight-line approximation
    (fill below the horizon's screen y = cy + 2·tan(alt0/2)·scale).
- Insert a new `GroundRenderer` after stars and the solar system, immediately before the
  horizon line (HorizonRenderer) (stars are dimmed by the fill; lines and direction labels remain on top).
  Render order: background → survey → Milky Way → grid → constellations → DSO → stars → solar system →
  **ground fill → horizon line** → FOV frame → selection ring
- Fill color: semi-transparent black (alpha≈0.55)

## 3. Display Magnitude Slider (mag 1-20)

- Remove `bortle` from `AppearanceSettings` and consolidate into `userLimitingMagnitude`
  (default 6.5, clamped 1.0-20.0). Also remove the `bortleLimitingMagnitude` getter.
- Persistence: the `bortle` key is read and discarded (backward compatibility).
- Extend `lodLimitingMagnitude` based on the A2 table (>60°: 8.0 / 20-60°: 10.5 /
  5-20°: 14.0 / ≤5°: 20.0). Effective magnitude = min(LOD, user setting).
- Change the fade-start magnitude in `StarAppearance.renderParams` to
  `max(5.0, userLimitingMagnitude - 1.5)` (smooth fade-out near the limit).
- UI: change the ControlBar light pollution dialog and DisplaySettingsSection to a
  "show down to magnitude N.N" slider (min 1.0, max 20.0, 0.5 steps).
  Also change the icon tooltip to "Display magnitude (down to N.N mag)".
- Update the A2 table and the A4 light pollution descriptions in docs/functional-design.md.
