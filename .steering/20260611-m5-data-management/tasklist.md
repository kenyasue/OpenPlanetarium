# Task List

## 🚨 Principle of Complete Task Completion

Continue working until all tasks are `[x]`. Skipping is allowed only for technical reasons (with the reason stated).

---

## Phase 1: drift Catalog DB

- [x] Introduce drift / drift_flutter / build_runner and AppDatabase (stars (@DataClassName to avoid collision) + downloadedTiles, composite index)
- [x] DriftCatalogStore (importTile / starsInTiles / downloadedTiles / deleteCatalog / starCount)
- [x] Tests: in-memory import → query → delete → duplicate import replacement

## Phase 2: Download Infrastructure

- [x] CatalogManifest / CatalogDescriptor / DownloadStatus / DownloadMode models and DownloadClient (IF), add Download exceptions
- [x] DioDownloadClient (CATALOG_BASE_URL, HTTPS enforcement, 4xx/5xx retryable determination)
- [x] DownloadController (per-tile resume, SHA-256 verification (crypto), exponential backoff 3 times, cancel, Wi-Fi setting, flag cleanup in finally)
- [x] Tests: with FakeDownloadClient — happy path / resume / corrupted re-fetch / retry success and limit / cancel + resume / double-start guard / delete

## Phase 3: Repository Composition and Settings Persistence

- [x] CompositeCatalogRepository (asset BSC + DB) and catalogRepositoryProvider replacement
- [x] SettingsRepository (IF) + PrefsSettingsRepository + InMemory (for tests)
- [x] Save/restore of display, constellation, manual observing location, and download mode settings (with disposed guard)
- [x] Tests: settings save/restore (display, constellation, manual observing location), fallback for corrupted values

## Phase 4: Settings Screen UI

- [x] SettingsScreen (sections: Display/Constellation/Observing location/Data management, max width 720)
- [x] Observing location section (latitude/longitude input, 5 city presets, GPS re-acquisition)
- [x] Data management section (catalog status, progress bar, start/cancel/delete, download mode SegmentedButton)
- [x] Entry points from the left panel (settings button) and mobile (settings icon)

## Phase 5: Verification, Documentation, Merge

- [x] Update docs (change PRD F3 to the bundled approach, update implementation-plan M5 completion criteria)
- [x] tool/check.ps1 all pass (119 tests)
- [x] flutter build windows --debug succeeds + launch verified
- [x] implementation-validator verification and fixes for required findings (cancel flag cleanup in finally, cancel check inside _fetchTileVerified, disposed guard for settings restoration, limiting to on Exception, added cancel/double-start/location persistence tests)
- [x] Post-implementation retrospective (below)
- [x] Merge to main and push

---

## Post-Implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

**Points that differed from the plan**:
- Eliminated the initial download of the BSC and made asset bundling the official spec (PRD F3 updated). The onboarding screen also became unnecessary
- drift's generated data class collided with the domain Star → avoided with @DataClassName('CatalogStarRow')

**Newly required tasks**:
- Validator required findings: finally cleanup of _cancelRequested, disposed guard for deferred state writes inside build() (3 controllers)
- Due to LocationController's dependency on SettingsRepository, 3 existing tests needed InMemory replacement

**Tasks skipped for technical reasons**:
- Distribution of real Tycho-2 data (explicitly out of scope in requirements.md: source data is several hundred MB, distribution server undecided. The infrastructure is integration-tested with FakeClient; it can be added with just a CatalogDescriptor registration)

### Lessons Learned

**Technical learnings**:
- Deferred restoration inside Riverpod Notifier's build() (unawaited + then) requires a disposed guard. Converting to AsyncNotifier is the more orthodox approach (future refactoring candidate)
- drift tests are fast and reliable with NativeDatabase.memory(). Generated names can be controlled with @DataClassName
- For download cancel/resume, treating the DB-side downloadedTiles table as the source of truth keeps state management simple

**Process improvements**:
- Adding a new dependency (settings repository) to a controller breaks existing tests. When adding a DI point, always check overrides across all tests as a set

### Improvement Suggestions for Next Time
- M6: the HiPS tile cache is a separate system from DownloadController (LRU, size limit). When adding a cache_index table to AppDatabase, write a migration
- Consider failure logging for settings saves (catchError of fire-and-forget) in M8 as a diagnosability improvement
- Add a (catalog) index to the stars table when catalogs increase
