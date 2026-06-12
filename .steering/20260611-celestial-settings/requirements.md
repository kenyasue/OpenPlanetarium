# Requirements: Celestial Settings Dialog (5 Tabs) and Minor Body / Nebula Catalog Additions

Date: 2026-06-11

## User Requests (summary of original wording)

1. Consolidate display magnitude, Milky Way On/Off, and survey data into a single "Celestial Settings" dialog
2. Tab layout: DSO / solar system bodies / survey / stars / constellations
3. DSO tab: individually toggle Messier, IC, NGC, Sh2, LBN, LDN, and vdB On/Off
4. Solar system tab: planets, asteroids, and comets selectable (for asteroids and comets, find and add the best catalogs)

## Adopted Catalogs (research results)

| Data | Source | Approx. count |
|---|---|---|
| Sh2 (HII regions) | VizieR VII/20 (Sharpless 1959, galactic coordinates → J2000 conversion) | 313 |
| LBN (bright nebulae) | VizieR VII/9 (Lynds 1965, _RA_icrs available) | 1,125 |
| LDN (dark nebulae) | VizieR VII/7A (Lynds 1962, _RA_icrs available) | ~1,800 |
| vdB (reflection nebulae) | VizieR VII/21 (van den Bergh 1966, _RA/_DE available) | 158 |
| Asteroids | JPL SBDB Query API (H<8 and a<6au, 6 orbital elements + H) | 129 |
| Comets | JPL SBDB Query API (M1<13, e<0.99, epoch>2020, q/e/tp etc. + M1/K1) | several hundred |

All are fetched by conversion scripts and bundled as assets (preserving offline operation).

## Acceptance Criteria

- [ ] The 3 ControlBar icons for display magnitude, Milky Way, and survey are consolidated into a single "Celestial Settings" icon
- [ ] The Celestial Settings dialog shows 5 tabs (DSO/solar system/survey/stars/constellations)
- [ ] The 7 catalog toggles on the DSO tab are reflected in rendering and persisted
- [ ] The planet/asteroid/comet toggles on the solar system tab are reflected in rendering and persisted
- [ ] Asteroids and comets are displayed at their positions for the observation time via Keplerian orbit propagation, with display controlled by magnitude calculation
- [ ] All existing tests pass + new tests added
