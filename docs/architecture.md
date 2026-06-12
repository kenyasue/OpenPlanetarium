# Architecture Design Document

This document defines the system structure and technology selections required to technically realize `docs/product-requirements.md` (PRD) and `docs/functional-design.md` (Functional Design Document).

## Technology Stack

### Language and Runtime

| Technology | Version | Rationale |
|------|-----------|----------|
| Flutter | 3.x (latest stable) | A single codebase deploys to all 5 platforms: Windows / macOS / Linux / iOS / Android (PRD mandatory requirement). The Impeller renderer enables high-frame-rate Canvas rendering |
| Dart | 3.x | Flutter's standard language. Concurrency via Isolates allows DB queries and tile decoding to run without blocking the UI thread (F2 requirement). Robustness through sound null safety |

**Note**: The development environment is a devcontainer (CLAUDE.md). Node.js v24.11.0 / TypeScript 5.x / npm are for documentation tooling and auxiliary scripts; the application itself is implemented in Flutter / Dart.

### Frameworks and Libraries

| Technology | Version | Purpose | Rationale |
|------|-----------|------|----------|
| flutter_riverpod | ^3.x | State management / DI | Compile-time-safe provider references. AsyncValue's async state representation aligns with the visible celestial object stream (F2). Easy to override in tests |
| drift | ^2.x | Local DB (SQLite) | Type-safe query generation. Since the primary query is per-tile range search on a `(tileIndex, magnitude)` composite index, drift's stronger SQL control is a better fit than an ORM. Supports all 5 platforms |
| dio | ^5.x | HTTP communication | Standard support for download progress notifications, cancel tokens, and retry implementation via interceptors (F3 requirement) |
| geolocator | ^14.x | Location services | Supports all 5 platforms. Detailed permission-state reporting allows implementing a fallback (manual location setting) on denial |
| shared_preferences | ^2.x | Lightweight settings persistence | Key-value storage for display settings, etc. The de facto standard with support for all platforms |
| connectivity_plus | ^6.x | Network state detection | Needed to evaluate the "download only on Wi-Fi" setting (F4) |
| path_provider | ^2.x | Data directory access | Abstraction of platform-specific app data / cache directories |
| intl | ^0.20.x | Internationalization | Japanese/English UI (PRD requirement). Message management via ARB files |
| uuid | ^4.x | ID generation | ID generation for equipment profiles, etc. |
| vector_math | ^2.x | Vector / matrix math | Support for coordinate transformation and projection calculations |

**Areas implemented in-house (decision not to adopt packages)**:

| Area | Decision | Reason |
|------|------|------|
| Astronomical calculations (AstroEngine / EphemerisEngine) | In-house implementation | This is the app's core capability, and accuracy/performance requirements must be under our own control. Dart astronomy packages have insufficient maintenance and accuracy validation |
| Tile cache (TileCacheManager) | In-house implementation | No existing package satisfies the requirements for per-survey capacity limits, LRU, and 3-level fallback (F11) |
| HiPS client | In-house implementation | No Dart implementation exists. Implement tile URL construction and HEALPix npix computation based on the HiPS specification (IVOA recommendation) |

### Development Tools

| Technology | Version | Purpose | Rationale |
|------|-----------|------|----------|
| flutter_lints | ^4.x | Static analysis | Flutter's officially recommended rule set. Additional rules defined in development-guidelines |
| build_runner | ^2.x | Code generation | Code generation for drift and riverpod_generator |
| flutter_test / integration_test | Bundled with SDK | Testing | Unit, widget, and E2E tests (corresponding to the test strategy in the functional design document) |
| mocktail | ^1.x | Mocking | Null-safety-compatible mocking library. Mocks repositories and services |
| melos | ^6.x (optional) | Monorepo management | Consider adopting when packages are split in the future (extracting the core calculation library) |

## Architecture Patterns

### Layered Architecture (4 layers)

Adopt a 4-layer structure corresponding to the system diagram in the functional design document.

```
┌────────────────────────────────────────────┐
│  Presentation layer (lib/presentation)      │ ← Screens, Widgets, CustomPainter
├────────────────────────────────────────────┤
│  Application layer (lib/application)         │ ← Controllers, Services (use cases)
├────────────────────────────────────────────┤
│  Domain layer (lib/domain)                   │ ← Models, astronomical calculations, spatial index
├────────────────────────────────────────────┤
│  Data layer (lib/data)                       │ ← Repository implementations, DB, HTTP, cache
└────────────────────────────────────────────┘
```

#### Presentation Layer
- **Responsibilities**: Screen layout (desktop/mobile switching), accepting user input, rendering via SkyPainter
- **Allowed operations**: Calling application-layer Controllers / Services (via Riverpod)
- **Prohibited operations**: Direct access to the data layer, implementing domain logic

#### Application Layer
- **Responsibilities**: Use case mediation (ViewportController, DownloadService, etc.), state management, query debounce / cancellation control
- **Allowed operations**: Calling domain-layer computations, calling repository interfaces (abstractions)
- **Prohibited operations**: Depending on Widgets, direct manipulation of SQL or HTTP

#### Domain Layer
- **Responsibilities**: Entity definitions, astronomical calculations (coordinate transformation, ephemeris computation), star appearance computation, spatial index, field of view (FOV) computation
- **Allowed operations**: Pure computation only
- **Prohibited operations**: Depending on I/O (DB, network, files), depending on the Flutter framework (excluding `dart:ui` value types)

#### Data Layer
- **Responsibilities**: Implementing repository interfaces, SQLite (drift) access, HTTP communication, tile cache, running heavy processing in Isolates
- **Allowed operations**: All external I/O
- **Prohibited operations**: Implementing business logic, holding UI state

**Dependency direction**: presentation → application → domain ← data (the data layer implements domain-layer interfaces; through dependency inversion, the domain layer knows nothing about I/O)

### Concurrency Architecture

To keep the UI thread (main Isolate) at 60fps, heavy processing is offloaded (addressing F2 and performance KPIs).

```
Main Isolate                      Worker Isolates
┌───────────────────┐            ┌─────────────────────┐
│ UI / SkyPainter rendering │  via Port  │ DB queries (drift)      │
│ ViewportController │ ◄────────► │ Catalog tile decoding  │
│ Gesture handling     │            │ Survey image decoding   │
└───────────────────┘            │ Catalog import     │
                                 └─────────────────────┘
```

- Move DB access to the background with drift's `DriftIsolate`
- Run image decoding via `compute` / `Isolate.run`; only the conversion to `ui.Image` happens on the main Isolate
- Query results are returned tagged with a viewportId (generation ID); the main side checks the generation and discards stale results

## Data Persistence Strategy

### Storage Approach

| Data Type | Storage | Format | Reason |
|-----------|----------|-------------|------|
| Star, deep-sky object, and constellation catalogs | SQLite (drift) | Tables (with composite index) | Fast range search by tile number + magnitude. Easy management of partial-download state |
| Equipment profiles / equipment sets | SQLite (drift) | Tables | Integrity management of relations (equipment set → equipment) |
| Display settings / language settings | shared_preferences | Key-value | Lightweight; can be read synchronously at startup |
| Survey tiles (HiPS) | File cache | JPEG / PNG + metadata DB | Files are efficient for images. LRU metadata (last access, size) managed in SQLite |
| Celestial object thumbnails / constellation art | App bundle + file cache | WebP / PNG | Major objects bundled with the app (offline guarantee); additional ones cached |
| Catalog distribution data (server side) | Static file hosting (CDN possible) | manifest.json + tile binaries | No server logic required. Can be operated with static HTTPS hosting alone |

### Data Layout

```
<ApplicationSupportDirectory>/        ← Persistent data that is never deleted
├── catalogs.db                       # Catalog DB
├── equipment.db                      # Equipment DB
└── <CacheDirectory>/                 ← Cache the OS may clear
    ├── survey_tiles/<surveyId>/...   # HiPS tiles
    ├── thumbnails/
    └── cache_index.db                # LRU metadata
```

- The catalog DB is clearly distinguished as "persistent data" while survey tiles are "cache". Even if the cache is wiped when OS storage runs low, catalogs and settings are retained and the sky display is preserved (PRD reliability requirement)

### Backup and Recovery Strategy

- **Settings / equipment profiles**: Integrity guaranteed by DB transactions. On schema changes, use drift migrations; copy the DB file before migrating (`equipment.db.bak`, one generation) and then run
- **Catalog DB**: Not backed up (it can be restored by re-downloading). On corruption detection, propose re-downloading the affected catalog
- **Cache**: Assumed volatile. Inconsistencies between `cache_index.db` and the actual files are verified and repaired at startup

## Performance Requirements

### Response Time (technical breakdown of PRD KPIs)

| Operation | Target | Measurement Environment / Method |
|------|---------|---------|
| Frame time during pan/zoom | ≤18ms (55fps or higher) | Mid-range Android device (Snapdragon 7xx class), measured with DevTools timeline |
| Same (desktop) | ≤16ms (60fps) | Core i5 equivalent / 8GB RAM |
| Launch → initial sky display (already downloaded) | ≤3 seconds | Cold start, measured with Stopwatch |
| Viewport change → start of progressive display of new objects | ≤200ms (on cache hit) | Measured from tile query issuance to first rendered frame |
| Search input → suggestion display | ≤300ms | Against an index of 10,000 celestial objects |
| First launch → sky display (Wi-Fi) | ≤5 minutes | Including download of a BSC-equivalent catalog (assumed ~2MB) |

### Resource Usage

| Resource | Limit | Reason |
|---------|------|------|
| Memory (star data) | Loaded tiles ≤ 60 tiles (performance class high) / 30 (mid) / 15 (low) | Do not load the full Tycho-2 set (~2.5 million stars) into memory (PRD requirement). Limit estimated from a few thousand stars per tile on average × ~100B per record |
| Memory (survey tiles) | Decoded images ≤ 128MB (high) / 64MB (mid and below) | ui.Image consumes uncompressed memory, so it is constrained via LRU |
| Disk (default) | Survey cache default 2GB (configurable); catalogs only as selected | F4 cache capacity setting requirement |
| Network | Concurrent survey tile fetches ≤ 4 connections | Balances consideration for HiPS server load with effective bandwidth use |

### Rendering Pipeline Constraints

- Stars are rendered only via batch rendering with `drawRawPoints` / `drawAtlas`. An implementation of one Widget per star is prohibited
- Separate repaints of the sky canvas, UI panels, and FOV frames with `RepaintBoundary`
- Label rendering has a per-frame cap (per performance class), and overlap avoidance uses a grid hash at O(n log n) or better

## Security Architecture

### Data Protection

- **Location data**: Used only on-device and never sent externally (PRD requirement). Only manually set locations are stored in the settings DB (no GPS history retained)
- **Encryption**: Since no personal or authentication data is handled, stored data is not encrypted (equipment profiles do not qualify as sensitive data). Re-evaluate if an account feature is added in the future
- **Secret management**: Secrets such as API keys are currently unnecessary. Catalog distribution URLs are managed in a configuration file (build-time constants) to avoid scattered hardcoding

### Communication Security

- All communication (catalog distribution, HiPS servers) is HTTPS only. Disabling certificate verification is prohibited
- Downloaded catalog tiles are verified against SHA-256 checksums in manifest.json; mismatches are discarded and re-fetched (protection against corruption/tampering)

### Input Validation

- Search queries and equipment numeric inputs are validated in the application layer (positive numbers, character length limits)
- SQL uses only drift parameter binding. Building SQL via string concatenation is prohibited
- HiPS and catalog URLs use only an app-managed whitelist; loading user-entered URLs is not supported in the MVP

## Scalability Design

### Handling Data Growth

- **Expected data volume**: ~9,000 stars at MVP (BSC) → ~2.5 million with Tycho-2 adoption. ~14,000 deep-sky objects (Messier + major NGC/IC)
- **Measures**:
  - Partitioned storage and partial download via spatial index (tiles) + magnitude ranges (functional design A1/A2)
  - The DB keeps tile queries at O(log n) with a `(tileIndex, magnitude)` composite index
  - When adding catalogs, the schema stays shared (distinguished by a `sourceCatalog` column); tables are not split
- **Preparation for Gaia DR3 (Post-MVP)**: SpatialIndex is already abstracted as an interface. Design headroom is reserved to swap in a HEALPix-based implementation and add per-magnitude-range tile binary distribution

### Feature Extensibility (addressing PRD extensibility requirements)

| Extension Point | Design |
|------|------|
| Adding a new star catalog | Possible by registering a `CatalogDescriptor` (ID, manifest URL, magnitude range definitions) only. Import and queries share a common implementation |
| Adding a new survey layer | Just add a `SurveyLayer` record (no code change needed for HiPS-compliant servers) |
| Adding a display layer | SkyPainter renders a list of `SkyLayerRenderer` interfaces in order, so new layers (e.g., artificial satellites) can be added plugin-style |
| Swapping celestial object data sources | Swappable through the separation of repository interfaces (domain layer) and implementations (data layer) |

## Test Strategy

### Unit Tests

- **Framework**: flutter_test + mocktail
- **Scope**: Entire domain layer (AstroEngine, EphemerisEngine, FovSimulationService, SpatialIndex, StarAppearance), application-layer logic (LOD determination, viewportId generation management)
- **Coverage targets**: Domain layer 90%+, application layer 80%+
- **Accuracy verification**: Astronomical calculations are compared against fixtures of known ephemeris values (Chronological Scientific Tables, JPL Horizons output). FOV calculations within 1% error against examples in the PRD (KPI)

### Integration Tests

- **Method**: drift in-memory DB + mock HTTP server (swapping dio's adapter)
- **Scope**: Download → import → tile query flow, interrupt/resume, cache LRU, settings application

### E2E Tests

- **Tool**: integration_test (official Flutter)
- **Scenarios**: First launch → auto download → sky display → tap object → detail view / search → centering / equipment registration → FOV frame display / offline operation
- **Execution environment**: CI requires Windows, Linux, and Android emulators; macOS and iOS are verified pre-release

### Performance Tests

- Frame rate measurement on a mid-range physical device (55fps KPI) is included in release criteria
- Frame times are automatically measured with `integration_test`'s traceAction to detect regressions

## Technical Constraints

### Environment Requirements

- **OS**: Windows 10 or later / macOS 12 or later / Ubuntu 22.04 or later (major distributions) / iOS 14 or later / Android 8.0 (API 26) or later
- **Minimum memory**: 2GB mobile, 4GB desktop
- **Required disk space**: App itself + default catalogs under 200MB. Survey cache up to the configured limit (default 2GB)
- **Required external dependencies**: Catalog distribution server (static HTTPS hosting), public HiPS servers (CDS, etc.). Both allow offline operation after the initial download

### Performance Constraints

- Do not render stars with standard Flutter Widgets (CustomPainter required). Future adoption of fragment shaders (`FragmentProgram`) will be considered when improving glow rendering quality
- On platforms where Impeller is disabled (some Linux environments), Skia fallback applies; this is covered by performance class detection

### Security Constraints

- Non-HTTPS communication prohibited
- Sending location data externally prohibited
- Adding user-specified URL data sources is not supported in the MVP (whitelist approach)

## Dependency Management

| Library | Purpose | Version Management Policy |
|-----------|------|-------------------|
| flutter_riverpod | State management | `^` (auto minor). Major upgrades affect the design, so perform them deliberately |
| drift | DB | `^`. Since updates involve schema migrations, migration tests are mandatory when upgrading |
| dio | HTTP | `^` |
| geolocator / connectivity_plus / path_provider | Platform integration | `^`. Verify behavior after OS major updates |
| flutter_lints | Static analysis | `^`. Rule additions applied only with team agreement |

**Policy**:
- Commit `pubspec.lock` to guarantee build reproducibility
- Pin the Flutter SDK version per project with `fvm` or similar, keeping CI and development environments in sync
- When adding dependencies, "support for all 5 platforms" is an adoption requirement (otherwise isolate via conditional imports)
