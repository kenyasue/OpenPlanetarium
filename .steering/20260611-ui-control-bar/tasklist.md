# Task List

## 🚨 Principle of Complete Task Completion

Continue working until every task is `[x]`. Skipping is allowed only for technical reasons (state the reason explicitly).

---

## Phase 1: ControlBar Implementation

- [x] control_bar.dart (time display, slider, playback, Now, Moon age, observing location, FOV angle + 7 icons)
- [x] Common settings-dialog helper (title + reuse of existing section Widgets)
- [x] Light pollution dialog (Bortle slider + limiting magnitude)
- [x] Time settings dialog (date picker + time picker + reset — date change is new)
- [x] Milky Way toggle and active-state display for the survey/FOV icons

## Phase 2: Layout Cleanup

- [x] desktop_layout: replace the bottom with ControlBar, simplify the left panel to search + settings entry point only
- [x] mobile_layout: replace the bottom with ControlBar (horizontal scroll)
- [x] Delete time_location_bar.dart (replaced by ControlBar)

## Phase 3: Tests, Verification, Merge

- [x] Widget tests: dialogs open from ControlBar icons, Milky Way toggle, consistency with existing tests
- [x] tool/check.ps1 fully passing (173 tests)
- [x] flutter build windows --debug succeeds + launch confirmed + screenshot
- [x] implementation-validator verification and fixes for required findings
- [x] Post-implementation retrospective (below)
- [x] Merge to main and push

## Follow-up: Mobile Multi-line Display (2026-06-11 additional user request)

- [x] Add a multiline mode to ControlBar (time row = full-width slider / icon row = wrapped with Wrap / status row)
- [x] mobile_layout: drop horizontal scrolling and replace with ControlBar(multiline: true)
- [x] Add Widget tests for no overflow at mobile width (420px), all controls displayed, and dialog open/close
- [x] tool/check.ps1 fully passing (174 tests)

---

## Post-implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

- As planned, the 7 settings icons + time slider (kept in place) were consolidated into ControlBar, the left panel was simplified to search + settings entry point only, and time_location_bar.dart was deleted.
- Additional fixes from validator findings (unplanned):
  - Required: LocationSection's ScaffoldMessenger (SnackBar) cannot be safely referenced from a context inside a dialog → changed to inline `_errorText` display.
  - Recommended: same for SurveySettingsSection's SnackBar → converted to ConsumerStatefulWidget and display `_statusText` inline.
  - Recommended: changed EquipmentScreen.open to `Navigator.of(context, rootNavigator: true)` (safe even when called from a context inside a dialog).
  - Recommended: split ControlBar into 3 Consumer boundaries — _TimeBlock/_SettingsIcons/_StatusBlock — so the settings icon group is not rebuilt by the 100ms tick during playback.

### Lessons Learned

- Referencing ScaffoldMessenger/Navigator from a context inside a dialog causes problems where it cannot reach the root Scaffold or pushes onto the dialog's internal Navigator, so shared section Widgets embedded in dialogs should be designed around inline display + rootNavigator.
- When a dialog title duplicates a heading inside the section, Widget tests should verify open/close with `find.byType(AlertDialog)` and verify text loosely with `findsWidgets`.
- For a bar containing high-frequency updates (the time tick), splitting Consumer boundaries by update frequency minimizes the rebuild scope.

### Improvement Suggestions for Next Time

- Settings section Widgets (LocationSection etc.) are used both "embedded in a screen" and "embedded in a dialog", so when adding new sections, follow the convention — already added to the development-guidelines pattern — of avoiding direct SnackBar/Navigator references.
