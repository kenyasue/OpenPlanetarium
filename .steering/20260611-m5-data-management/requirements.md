# Requirements

## Overview

Implement Milestone 5 "Data Management" from the implementation plan. Build the catalog download infrastructure (progress, resume, verification), the settings screen, settings persistence, and offline data management (PRD F3/F4).

## Key Specification Decision (Change from the PRD)

**Keep the BSC (default catalog) bundled as an asset and eliminate the initial download.**

Rationale:
- The BSC equivalent is small at 176KB, and bundling it fully satisfies the offline-first concept (PRD concept)
- The KPI "starry sky displayed within 5 minutes of first launch" is always achieved regardless of network conditions
- Bundling better achieves the original purpose of F3 (making the app usable without a network)

The download infrastructure will be used for (1) additional catalogs (Tycho-2 etc., P1) and (2) differential fetching of catalog updates.
The acceptance criteria of PRD F3 are reinterpreted from "automatic download on first launch" to "default catalog immediately available from first launch + download management for additional catalogs", and the docs will be updated accordingly.

## Features to Implement

### 1. Catalog Distribution Format and Download Infrastructure
- manifest.json (version, tile list, SHA-256, size) + tile binaries (FPC1 format, shared with M2)
- DownloadService (dio): progress stream, per-tile resume, SHA-256 verification, exponential backoff retry (3 times), cancel
- Setting to download only when connected to Wi-Fi (connectivity_plus)
- Distribution URL configurable via --dart-define (CATALOG_BASE_URL) (default is unset = download feature shows "server not configured")

### 2. Catalog DB with drift (SQLite)
- stars table ((tileIndex, magnitude) composite index, sourceCatalog column)
- CompositeCatalogRepository: composition of assets (BSC) + DB (downloaded catalogs)
- DB import of downloaded tiles (transactional)

### 3. Settings Screen (F4 + consolidation of various settings)
- Settings screen (desktop: dialog / mobile: full screen) with the following sections:
  - Display settings (light pollution, size/glow/saturation — relocation + extension of existing settings)
  - Constellation display (relocation of the existing section)
  - Observing location (manual location setting: latitude/longitude input + major city presets, GPS re-acquisition)
  - Data management (catalog list and status, download mode (auto/Wi-Fi only/manual), downloaded size, cache deletion, update check)
- Replace the settings sections in the left panel with a link to the settings screen (search stays in the left panel)

### 4. Settings Persistence (SettingsRepository)
- Save display settings, constellation settings, manual observing location, and download mode to shared_preferences, and restore them on startup

## Acceptance Criteria

- [ ] Integration test passes with a mock server (dio adapter replacement): manifest → tile fetch → DB registration → query reflection
- [ ] On download interruption → resume, completed tiles are skipped (test)
- [ ] Tiles with SHA-256 mismatch are discarded and re-fetched (test)
- [ ] Stars registered in the DB are composed into the visibleStars results (test)
- [ ] Manual observing location can be set from the settings screen and is retained after restart
- [ ] Display and constellation settings are retained after restart
- [ ] Downloaded size is displayed and the cache can be deleted
- [ ] format / analyze / all tests pass, Windows build succeeds

## Out of Scope

- Distribution of real Tycho-2 data (the source data is several hundred MB and the distribution server is undecided. The download/import infrastructure is verified with mocks; real data will be added once the server is set up — the design allows this with just a CatalogDescriptor registration)
- Onboarding screen (no longer needed since bundling the BSC eliminates the initial download)
- Survey tile cache (M6)
- UI language switching (M8)

## Reference Documents

- `docs/implementation-plan.md` Milestone 5
- `docs/functional-design.md` DownloadService / catalog distribution format
- `docs/architecture.md` data persistence strategy
