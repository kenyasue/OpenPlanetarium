# Task List

## 🚨 Task Completion Principle

**Continue working until every task in this file is complete (`[x]`).**
Skips only for technical reasons, recorded as `- [x] ~~task~~ (reason)`.

---

## Phase 1: README.md

- [x] Rewrite README.md: OpenPlanetarium intro, Requirements, Getting Started, per-platform guides (Windows/macOS/Linux/Android/iOS), Development, Documentation, Data Sources, License sections
- [x] Verify test-count and asset claims in README against the repo (219 tests; feature list retained per user request)

## Phase 1.5: Rename application to OpenPlanetarium (user request mid-work)

- [x] Rename Dart package `flatter_planetarium` → `open_planetarium` (pubspec.yaml + 35 files of `package:` imports in lib/, test/, tool/)
- [x] Windows runner: binary name, window title (OpenPlanetarium), Runner.rc product strings
- [x] Linux runner: binary name, application ID (org.yasue.open_planetarium), window title
- [x] macOS runner: AppInfo.xcconfig product name/bundle ID (org.yasue.openPlanetarium) + pbxproj/xcscheme app references
- [x] Android: namespace/applicationId (org.yasue.open_planetarium), label, MainActivity package move
- [x] iOS: CFBundleDisplayName/CFBundleName + bundle IDs in pbxproj
- [x] Update README output paths; MaterialApp title; docs/ branding (4 files)
- [x] Verify: flutter analyze clean (after dart fix for import ordering), 219 tests pass, Windows debug build produces open_planetarium.exe (required deleting stale build\windows CMake cache)

## Phase 2: .gitignore

- [x] Add `.fvm/`, `macos/Pods/`, symbol files, `mvp-log.json` entries
- [x] Review: confirm tracked-file set is correct for release (lock files, .metadata, *.g.dart stay; *.iml covers stale flatter_planetarium.iml)

## Phase 3: License & metadata

- [x] Update LICENSE copyright line (2026 Ken Yasue)
- [x] Update package.json name/description/keywords/author for OpenPlanetarium docs tooling

## Phase 4: Verification

- [x] `npm test` passes (7 tests)
- [x] `npm run lint` passes
- [x] `npm run typecheck` passes
- [x] `flutter analyze` clean
- [x] implementation-validator subagent review passes (PASS on all 6 checks; README Dart constraint tightened to ^3.11.4 per its note)

---

## Retrospective

### Completion date
2026-06-12

### Plan vs. actual

**Differences from plan**:
- Mid-work, the user requested renaming the application to OpenPlanetarium. This became Phase 1.5: Dart package rename (`flatter_planetarium` → `open_planetarium`, 35 import files), plus all five platform runners (Windows RC/CMake, Linux CMake/GTK title, macOS xcconfig/pbxproj/xcscheme, iOS Info.plist/pbxproj, Android gradle/manifest/MainActivity package move) and docs/ branding.
- The rename changed import alphabetical order, producing 32 `directives_ordering` lints — fixed with `dart fix --apply --code=directives_ordering`.
- The Windows build failed after the rename due to a stale CMake cache in `build/windows`; deleting that directory resolved it.
- A second mid-work user request ("add list of features to README") was already satisfied by the rewritten README's Features section.

**Notable consequence (accepted)**: app identity (bundle IDs, applicationId, APPLICATION_ID) changed, so any locally persisted data under the old identity behaves as a fresh install. Acceptable since nothing has shipped.

### Lessons learned
- Renaming a Flutter app touches ~7 distinct identity surfaces (pubspec, imports, and five platform runners); a checklist per platform avoids stragglers. A final case-insensitive grep is the safety net.
- CMake caches the project name; platform build dirs must be cleared after renaming.
- Import-order lints are sensitive to package renames — run `dart fix` immediately after.

### Improvements for next time
- Consider adding GitHub Actions CI (analyze + test on push) before the first release tag — deliberately left out of scope here.
- The repo has zero commits; the initial commit should be made after user review of this preparation.
