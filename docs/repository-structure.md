# Repository Structure Document

This document maps the 4-tier layered architecture defined in `docs/architecture.md` onto the directory structure of a Flutter project.
It follows standard Flutter conventions (`lib/` / `test/` / snake_case file names).

## Project Structure

```
OpenPlanetarium/
├── lib/                        # Application source code
│   ├── main.dart               # Entry point
│   ├── app.dart                # Root widget (theme, routing, responsive branching)
│   ├── presentation/           # Presentation layer (screens, widgets, painters)
│   ├── application/            # Application layer (controllers, services, state management)
│   ├── domain/                 # Domain layer (models, astronomical calculations, pure logic)
│   ├── data/                   # Data layer (repository implementations, DB, HTTP, cache)
│   └── l10n/                   # Internationalization resources (ARB)
├── assets/                     # Bundled assets
│   ├── catalogs/               # Bundled catalog data (constellation lines, major celestial objects)
│   ├── textures/               # Planet and Moon textures
│   ├── images/                 # Celestial object thumbnails, constellation art
│   └── fonts/                  # Fonts
├── test/                       # Unit and widget tests
├── integration_test/           # E2E tests
├── tool/                       # Development helper scripts (catalog conversion, etc.)
├── docs/                       # Project documentation
│   └── ideas/                  # Drafts and ideas
├── .steering/                  # Work-unit documents (outside git management)
├── .claude/                    # Claude Code configuration (commands / skills / agents)
├── windows/ macos/ linux/ ios/ android/   # Platform-specific build settings (Flutter-generated)
├── pubspec.yaml                # Dependencies and asset definitions
└── analysis_options.yaml       # Static analysis settings
```

## Directory Details

### lib/presentation/ (Presentation Layer)

**Role**: Rendering via screens, widgets, and CustomPainter. Receiving user input

**Structure**:
```
presentation/
├── screens/                    # Per-screen units
│   ├── sky/                    # Sky screen (home)
│   │   ├── sky_screen.dart             # Screen body including responsive branching
│   │   ├── sky_canvas.dart             # Sky canvas widget (including GestureDetector)
│   │   ├── desktop_layout.dart         # Desktop layout (persistent panels)
│   │   ├── mobile_layout.dart          # Mobile layout (bottom sheets)
│   │   └── widgets/                    # Screen-specific widgets (control bar, time slider, etc.)
│   ├── search/                 # Search screen and search panel
│   ├── object_detail/          # Celestial object detail (supports both panel and bottom sheet)
│   ├── settings/               # Settings screen (8 sections)
│   ├── equipment/              # Equipment management and equipment set editing
│   └── onboarding/             # First launch and initial download
├── painters/                   # CustomPainter group (SkyLayerRenderer implementations)
│   ├── sky_painter.dart                # Parent painter for layer composition
│   ├── background_renderer.dart        # Background gradient and Milky Way
│   ├── star_renderer.dart              # Stars (batch rendering with drawAtlas)
│   ├── constellation_renderer.dart     # Constellation lines, boundaries, names
│   ├── solar_system_renderer.dart      # Sun, Moon, planets
│   ├── dso_renderer.dart               # Deep-sky object icons and labels
│   ├── survey_renderer.dart            # Survey tiles
│   └── fov_frame_renderer.dart         # FOV frame and mosaic grid
└── widgets/                    # Shared widgets across screens
    ├── glass_panel.dart                # Semi-transparent glass panel
    └── ...
```

**Naming conventions**:
- Screens: `<name>_screen.dart`; painters/renderers: `<name>_renderer.dart`
- Place screen-specific widgets in each `screens/<name>/widgets/`; place only those used by multiple screens in `presentation/widgets/`

**Dependencies**:
- May depend on: `application/` (via Riverpod providers), `domain/` (references to models and value types only)
- Must not depend on: `data/`

### lib/application/ (Application Layer)

**Role**: Use case orchestration and state management. Controllers (Riverpod Notifier) and services

**Structure**:
```
application/
├── viewport/
│   ├── viewport_controller.dart        # Orchestrates view point, zoom, and visible object queries
│   └── lod_policy.dart                 # LOD decision: zoom → limiting magnitude
├── time/
│   └── time_controller.dart            # Observation date/time, time slider, animation
├── layers/
│   └── layer_controller.dart           # Display layer ON/OFF and survey selection
├── search/
│   └── search_service.dart             # Query interpretation, search, ranking
├── download/
│   └── download_service.dart           # Catalog download queue, progress, resume
├── fov/
│   └── fov_simulation_service.dart     # Orchestrates FOV calculation (calculation itself lives in domain)
├── location/
│   └── location_controller.dart        # GPS acquisition and manual location fallback
└── settings/
    └── settings_controller.dart        # Reading, writing, and applying settings
```

**Naming conventions**:
- Stateful components: `<name>_controller.dart` (Riverpod Notifier / AsyncNotifier)
- Stateless use cases: `<name>_service.dart`

**Dependencies**:
- May depend on: `domain/` (calculations, models, repository interfaces)
- Must not depend on: `presentation/`, implementation classes in `data/` (interfaces only)

### lib/domain/ (Domain Layer)

**Role**: Entities, value objects, pure calculations. Independent of I/O and the Flutter framework

**Structure**:
```
domain/
├── models/                     # Entities and value objects
│   ├── star.dart
│   ├── deep_sky_object.dart
│   ├── solar_system_body.dart
│   ├── constellation_data.dart
│   ├── survey_layer.dart
│   ├── equipment/                      # Telescope / CameraDevice / Eyepiece / ...
│   ├── viewport_state.dart
│   ├── sky_point.dart                  # RA/Dec value object
│   └── geo_location.dart
├── astro/                      # Astronomical calculations (pure functions)
│   ├── astro_engine.dart               # Coordinate conversion, sidereal time, projection
│   ├── ephemeris_engine.dart           # Sun/Moon/planet positions, rise/set times
│   └── projection.dart                 # Stereographic projection and inverse projection
├── appearance/
│   └── star_appearance.dart            # B-V → color, magnitude → size/glow
├── spatial/
│   ├── spatial_index.dart              # Spatial index abstraction + RA/Dec grid implementation
│   └── healpix.dart                    # HEALPix npix calculation for HiPS
├── optics/
│   └── fov_calculator.dart             # FOV, magnification, pixel scale, mosaic calculations
└── repositories/               # Repository interfaces (implementations live in data/)
    ├── catalog_repository.dart
    ├── equipment_repository.dart
    ├── survey_repository.dart
    └── settings_repository.dart
```

**Naming conventions**:
- Models are singular nouns (`star.dart`). Calculation modules are `<name>_engine.dart` / `<name>_calculator.dart`

**Dependencies**:
- May depend on: none (Dart standard library and `dart:ui` value types (Color/Offset, etc.) only)
- Must not depend on: `presentation/`, `application/`, `data/`, I/O packages (dio / drift / geolocator, etc.)

### lib/data/ (Data Layer)

**Role**: Implementations of the domain layer's repository interfaces. DB, HTTP, cache, isolates

**Structure**:
```
data/
├── database/
│   ├── app_database.dart               # drift database definition (catalogs.db)
│   ├── equipment_database.dart         # Equipment DB (equipment.db)
│   └── tables/                         # Table definitions
├── repositories/               # Implementations of domain interfaces
│   ├── drift_catalog_repository.dart
│   ├── drift_equipment_repository.dart
│   ├── hips_survey_repository.dart
│   └── prefs_settings_repository.dart
├── catalog/
│   ├── catalog_descriptor.dart         # Catalog definition (manifest URL, magnitude range)
│   ├── catalog_importer.dart           # Tile binary → DB registration (runs in an isolate)
│   └── tile_binary_codec.dart          # Tile binary encoding/decoding
├── survey/
│   ├── hips_client.dart                # HiPS tile URL construction and retrieval
│   └── tile_cache_manager.dart         # Memory + disk LRU cache
├── network/
│   ├── download_client.dart            # dio wrapper (progress, retry, resume)
│   └── connectivity_checker.dart       # Wi-Fi detection
└── platform/
    └── location_provider.dart          # geolocator wrapper
```

**Naming conventions**:
- Repository implementations are `<technology>_<interface name>.dart` (e.g. `drift_catalog_repository.dart`)

**Dependencies**:
- May depend on: `domain/` (interfaces and models)
- Must not depend on: `presentation/`, `application/`

### assets/ (Bundled Assets)

**Role**: Bundled data required for the offline guarantee (PRD offline requirement)

| Subdirectory | Contents | Format |
|---|---|---|
| `catalogs/` | Constellation lines, constellation boundaries, constellation names, Messier/major NGC object metadata | JSON / binary |
| `textures/` | Planet, Moon, and Sun textures | WebP |
| `images/` | Major celestial object thumbnails, constellation art (P1) | WebP |
| `fonts/` | UI fonts | TTF/OTF |

**Note**: The Bright Star Catalogue uses the initial-download approach (F3), but bundling a minimal subset of the stars referenced by constellation lines as assets is under consideration (to accommodate first launch while offline). The decision will be made in the steering file at implementation time.

### test/ (Unit and Widget Tests)

**Role**: Location for unit tests and widget tests

**Structure**: Mirror the structure of `lib/`
```
test/
├── domain/
│   ├── astro/
│   │   ├── astro_engine_test.dart
│   │   └── ephemeris_engine_test.dart
│   ├── optics/
│   │   └── fov_calculator_test.dart
│   └── spatial/
│       └── spatial_index_test.dart
├── application/
│   └── viewport/
│       └── viewport_controller_test.dart
├── data/
│   └── survey/
│       └── tile_cache_manager_test.dart
├── presentation/
│   └── screens/                        # Widget tests
└── fixtures/                           # Test data such as ephemeris values and catalog samples
```

**Naming convention**: `<file under test>_test.dart` (Dart standard)

### integration_test/ (E2E Tests)

**Role**: Tests of primary user flows on real devices and emulators (corresponds to the E2E strategy in the architecture document)

```
integration_test/
├── first_launch_test.dart      # First launch → download → sky display
├── search_flow_test.dart       # Search → centering → detail display
├── equipment_fov_test.dart     # Equipment registration → FOV frame display
├── offline_mode_test.dart      # Offline behavior
└── perf/
    └── pan_zoom_perf_test.dart # Frame rate measurement (55fps KPI)
```

### tool/ (Development Helper Scripts)

**Role**: Build and data preparation helpers (not included in the app itself)

```
tool/
├── catalog_converter/          # Source catalog (BSC/Tycho-2) → distribution tile binary conversion
└── generate_constellation_data/ # Generation and validation of constellation line data
```

**Note**: Dart scripts are the default; if Node.js / TypeScript is used, keep it confined to this directory

### docs/ (Documentation Directory)

**Documents located here**:
- `product-requirements.md`: Product requirements document
- `functional-design.md`: Functional design document
- `architecture.md`: Technical specification
- `repository-structure.md`: Repository structure document (this document)
- `development-guidelines.md`: Development guidelines
- `glossary.md`: Glossary
- `ideas/`: Output of brainstorming and idea sessions

## File Placement Rules

### Source Files

| File Type | Location | Naming Convention | Example |
|------------|--------|---------|-----|
| Screen | `lib/presentation/screens/<feature>/` | `<name>_screen.dart` | `sky_screen.dart` |
| Rendering renderer | `lib/presentation/painters/` | `<name>_renderer.dart` | `star_renderer.dart` |
| Controller (state) | `lib/application/<feature>/` | `<name>_controller.dart` | `viewport_controller.dart` |
| Service (use case) | `lib/application/<feature>/` | `<name>_service.dart` | `download_service.dart` |
| Entity | `lib/domain/models/` | Singular noun | `star.dart` |
| Calculation engine | `lib/domain/<area>/` | `<name>_engine.dart` / `<name>_calculator.dart` | `astro_engine.dart` |
| Repository interface | `lib/domain/repositories/` | `<name>_repository.dart` | `catalog_repository.dart` |
| Repository implementation | `lib/data/repositories/` | `<technology>_<name>_repository.dart` | `drift_catalog_repository.dart` |

### Test Files

| Test Type | Location | Naming Convention | Example |
|-----------|--------|---------|-----|
| Unit/widget test | `test/` (mirrors lib) | `<target>_test.dart` | `fov_calculator_test.dart` |
| E2E test | `integration_test/` | `<scenario>_test.dart` | `first_launch_test.dart` |
| Test data | `test/fixtures/` | Name describing the contents | `ephemeris_2026_fixtures.json` |

### Configuration Files

| File Type | Location | Notes |
|------------|--------|---------|
| Dependencies and asset definitions | `pubspec.yaml` (root) | Commit `pubspec.lock` as well |
| Static analysis | `analysis_options.yaml` (root) | flutter_lints + additional rules |
| Build-time constants (distribution URLs, etc.) | `lib/data/catalog/catalog_descriptor.dart`, etc. | Make overridable via `--dart-define` |
| Internationalization | `lib/l10n/app_ja.arb`, `app_en.arb` | Generated with flutter gen-l10n |

## Naming Conventions

### Directory Names

- All lowercase snake_case (Dart package convention). Examples: `object_detail/`, `solar_system/`
- Layer directories use role names (`presentation` / `application` / `domain` / `data`)
- Feature directories are singular (`search/`, `viewport/`)

### File Names

- All snake_case (mandatory Dart convention). Example: `star_appearance.dart`
- Class names within files use PascalCase (e.g. `StarAppearance` inside `star_appearance.dart`)
- Role suffixes: `_screen` / `_renderer` / `_controller` / `_service` / `_engine` / `_repository` / `_test`

## Dependency Rules

### Dependencies Between Layers

```
presentation/
    ↓ (OK: via providers)
application/
    ↓ (OK)
domain/  ←──── data/ (OK: interface implementation. Dependency inversion)
```

**Forbidden dependencies**:
- `domain/` → other layers, I/O packages (❌ the domain layer is pure calculations only)
- `presentation/` → `data/` (❌ always go through application)
- `data/` → `application/` / `presentation/` (❌)
- `application/` → `presentation/` (❌)

**Implementation and wiring**: Binding data layer implementations to domain interfaces is done in Riverpod provider definitions (`lib/app.dart` or each layer's `providers.dart`).

### Prohibition of Circular Dependencies

- When circular references between models are needed, use references by ID (e.g. `EquipmentSet.telescopeId`) and do not hold object references
- Resolve cycles within a layer by extracting interfaces or factoring out a shared module

## Scaling Strategy

### Adding Features

1. **Small features**: Add to an existing feature directory
2. **Medium features** (e.g. AR mode): Create a new feature directory in each layer (`application/ar/`, `presentation/screens/ar/`)
3. **Large, highly independent features** (e.g. publishing the astronomical calculation library externally): Create `packages/` and adopt a monorepo with melos (a future consideration in the architecture document)

### Managing File Size

- 300 lines or fewer per file is recommended; splitting is strongly recommended at 500 lines or more
- Painters maintain the structure already split per rendering layer (`<name>_renderer.dart`)

## Special Directories

### .steering/ (Steering Files)

**Role**: Work-unit planning documents (see CLAUDE.md)

```
.steering/
└── [YYYYMMDD]-[task-name]/
    ├── requirements.md
    ├── design.md
    └── tasklist.md
```

### .claude/ (Claude Code Configuration)

```
.claude/
├── commands/                # Slash commands (setup-project, etc.)
├── skills/                  # Skills (prd-writing / steering, etc.)
└── agents/                  # Subagent definitions
```

## Exclusion Settings

### .gitignore

In addition to the standard Flutter exclusions:
- `build/`, `.dart_tool/` (Flutter build artifacts)
- `*.g.dart` files are committed (drift / riverpod generated code; CI checks for generation diffs)
- `.env`, `*.log`, `.DS_Store`
- `coverage/`

**Note**: `.steering/` is kept under git management because the policy is to retain it as history (CLAUDE.md "retain as history").

### Analysis Exclusions (analysis_options.yaml)

```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - build/**
    - tool/**
```
