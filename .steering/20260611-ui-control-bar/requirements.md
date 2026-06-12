# Requirements

## Overview

Improve the UI overall. Consolidate all display-related settings into the bottom control panel,
so that light pollution level, Milky Way, time settings, observing location settings, survey data display,
equipment management, and FOV simulator can each be opened from an icon. The time slider stays in the bottom bar (user instruction).

## Implementation Scope

### 1. ControlBar (revamp of the bottom control panel)
- Replaces the existing TimeLocationBar
- Keep: observation date/time display, **time slider**, diurnal motion playback, "Now", Moon age, observing location name, FOV angle
- Icons to add (tap to open a settings dialog/screen):
  - Light pollution level (dialog: Bortle slider + limiting magnitude)
  - Milky Way (direct toggle on the icon; ON state highlighted — faster to operate than a dialog since it is a single switch)
  - Time settings (dialog: date picker + time picker + reset to current time; date-change capability is new)
  - Observing location settings (dialog: reuse the existing LocationSection)
  - Survey data display (dialog: reuse the existing SurveySettingsSection; highlighted when active)
  - FOV simulator (dialog: reuse the existing FovControlSection; highlighted when active)
  - Equipment management (navigates to EquipmentScreen)

### 2. Layout Cleanup
- Desktop left panel: simplify to search + an entry point to all settings (constellations etc.) only
  (remove the permanently displayed DisplaySettingsSection and FovControlSection)
- Mobile bottom bar: the same ControlBar (horizontal scroll)
- Constellation settings and data management remain in the settings screen (SettingsScreen)

## Acceptance Criteria

- [ ] The bottom bar shows 7 settings icons + time slider + playback + Now + Moon age
- [ ] Each icon opens the corresponding settings dialog/screen, and changes are reflected immediately
- [ ] The date can be changed in the time settings dialog (new feature)
- [ ] The Milky Way, survey, and FOV icons show an active state
- [ ] Works in both desktop and mobile layouts (Widget tests)
- [ ] format / analyze / all tests pass, Windows build succeeds
