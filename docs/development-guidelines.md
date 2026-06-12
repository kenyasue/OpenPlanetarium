# Development Guidelines

This document defines the conventions and processes for developing OpenPlanetarium.
The technology stack follows `docs/architecture.md`; directory structure and dependency rules follow `docs/repository-structure.md`.

## Coding Conventions

### Basic Policy

- The language is Dart 3.x (sound null safety required). Follow `analysis_options.yaml` (flutter_lints + additional rules) and keep analyzer warnings at zero
- Do not write imports that violate the layer dependency rules (presentation → application → domain ← data)
- Do not place I/O or Flutter-dependent code in the domain layer (`dart:ui` value types only are allowed)

### Naming Conventions

#### Variables and Functions

```dart
// ✅ Good example
final limitingMagnitude = lodPolicy.magnitudeFor(viewport.fovDeg);
List<Star> starsInViewport(ViewportState viewport) { ... }

// ❌ Bad example
final mag = calc(v);
List<Star> getData(dynamic v) { ... }
```

**Principles**:
- Variables: lowerCamelCase, nouns or noun phrases
- Functions: lowerCamelCase, start with a verb
- Constants: lowerCamelCase (Dart convention; a k prefix such as `const kBaseStarRadius = 4.0;` is also acceptable)
- Booleans: start with `is` / `has` / `should` / `can`
- Variables holding physical quantities make the unit explicit with a suffix: `raDeg`, `focalLengthMm`, `pixelSizeUm`, `distanceLy` (see the glossary)

#### Classes and Types

```dart
// Classes: PascalCase, nouns
class ViewportController { ... }
class FovCalculator { ... }

// Abstract classes (interfaces): PascalCase, no prefix
abstract class CatalogRepository { ... }

// Implementation classes: prefix with the technology name
class DriftCatalogRepository implements CatalogRepository { ... }

// enums: PascalCase, values are lowerCamelCase
enum ObjectType { nebula, galaxy, openCluster }
```

#### Files and Directories

- All snake_case (`star_appearance.dart`). Role suffixes follow the rules in `docs/repository-structure.md`

### Code Formatting

- Follow the default settings of `dart format` (2-space indentation, 80-character line length)
- Unformatted code is rejected by CI (`dart format --set-exit-if-changed`)
- Import order: dart: → package: → relative, alphabetical within each group (enforced by lint)

### Comment Conventions

**dartdoc is required for public APIs (domain layer and repository interfaces)**:

```dart
/// Converts equatorial coordinates to horizontal coordinates based on the
/// observation location and date/time.
///
/// [radec] is a coordinate at the J2000 epoch. Precession correction is
/// applied internally.
/// The returned azimuth is measured with north = 0°, increasing eastward.
HorizontalCoord equatorialToHorizontal(
  SkyPoint radec,
  GeoLocation loc,
  DateTime utc,
);
```

**Inline comments should explain "why"**:

```dart
// ✅ Good example: explains the reason and constraint
// A viewport that crosses the RA 0°/360° boundary is split into two ranges for intersection testing
final ranges = viewport.crossesRaZero ? splitAtZero(range) : [range];

// ❌ Bad example: repeats what the code already says
// Split the range
final ranges = splitAtZero(range);
```

**Cite sources for formulas and astronomical calculations**:

```dart
// Ballesteros (2012) approximation: B-V color index → effective temperature [K]
final temp = 4600 * (1 / (0.92 * bv + 1.7) + 1 / (0.92 * bv + 0.62));
```

### Error Handling

**Principles**:
- Expected errors (network, permissions, validation) are expressed with domain-defined exception classes and must always lead to UI feedback (follow the error classification table in the functional design document)
- Unexpected errors must not be swallowed; propagate them upward
- `catch (e) {}` (empty catch) is prohibited
- Protect the sky display to the last: when data retrieval fails, continue displaying with already loaded data

**Exception classes**:

```dart
/// Common base exception for the app
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class DownloadException extends AppException {
  const DownloadException(super.message, {required this.retryable});
  final bool retryable;
}

class ValidationException extends AppException {
  const ValidationException(super.message, {required this.field});
  final String field;
}
```

**Asynchronous processing**:

```dart
// In the application layer, represent error states with AsyncValue (Riverpod)
// The UI must always branch its rendering for loading / error / data with AsyncValue.when
final catalogStatus = ref.watch(catalogStatusProvider);
return catalogStatus.when(
  loading: () => const ProgressIndicator(),
  error: (e, _) => DownloadErrorPanel(error: e),
  data: (status) => ...,
);
```

### Performance Conventions (Specific to This Project)

- Do not use widgets for rendering stars and celestial objects. Always batch-render inside a CustomPainter (`drawRawPoints` / `drawAtlas`)
- Do not perform heavy computation (coordinate conversion loops, sorting) inside `build()`. Render results precomputed by controllers
- Always run DB queries, tile decoding, and catalog imports in a background isolate
- Attach a viewportId (generation ID) to visible-area queries and discard stale results
- Do not make changes that break the `RepaintBoundary` boundaries (sky canvas / UI panels / FOV frame)

## Git Workflow Rules

### Branch Strategy

**Branch types**:
- `main`: Always in a state where build and tests pass. Release tags are placed here
- `feature/[feature-name]`: New feature development (e.g. `feature/star-rendering`)
- `fix/[fix-description]`: Bug fixes
- `refactor/[target]`: Refactoring
- `docs/[target]`: Documentation-only changes

**Flow**: GitHub Flow (no develop branch; given the small team, feature branches are based directly off main)

```
main
  ├─ feature/star-rendering
  ├─ feature/equipment-fov
  └─ fix/ra-boundary-query
```

- As a rule, align the unit of a steering file (`.steering/[YYYYMMDD]-[task-name]/`) with the unit of a feature branch

### Commit Message Conventions

**Format** (Conventional Commits):

```
<type>(<scope>): <subject>

<body>
```

**Type**: `feat` / `fix` / `docs` / `style` / `refactor` / `test` / `perf` / `chore`

**Scope examples**: `sky` (sky display), `catalog` (catalogs and downloads), `survey` (HiPS), `equipment` (equipment), `search`, `settings`, `astro` (astronomical calculations)

**Example**:

```
feat(astro): implement conversion from equatorial to horizontal coordinates

- Add sidereal time calculation (simplified formula per IAU 2006)
- Atmospheric refraction correction is out of MVP scope and not implemented (see TODO comment)
- Add tests verified against fixtures from the Chronological Scientific Tables 2026
```

- The subject may be written in Japanese. Aim for 50 characters or fewer
- One concern per commit. Do not mix formatting changes with functional changes

### Pull Request Process

**Pre-creation checks**:
- [ ] Zero warnings from `flutter analyze`
- [ ] `dart format` applied
- [ ] All `flutter test` cases pass
- [ ] Generated code (`*.g.dart`) is up to date (`build_runner` has been run)
- [ ] No layer dependency rule violations

**PR template**:

```markdown
## Summary
[Concise description of the change]

## Related Steering
.steering/[YYYYMMDD]-[task-name]/

## Changes
- [Change 1]
- [Change 2]

## Tests
- [ ] Unit tests added/updated
- [ ] Platforms verified: [Windows / macOS / Linux / iOS / Android]

## Screenshots (required for UI changes)
[Both desktop / mobile]
```

**Review process**:
1. Self-review (read through the diff)
2. Confirm CI (analyze / format / test) passes
3. Assign reviewers
4. Address feedback
5. After approval, squash merge into main

## Testing Strategy

### Test Pyramid

```
        E2E (integration_test)        ← Primary flows only (about 5 scenarios)
      ──────────────────────
      Integration tests (test/ + in-memory DB) ← Data flow and caching
    ──────────────────────────
    Unit tests (test/)               ← Thick coverage centered on the domain layer
```

### Coverage Targets (from the Architecture Document)

| Target | Goal |
|------|------|
| `lib/domain/` (astronomical calculations, FOV calculations, spatial index) | 90% or higher |
| `lib/application/` | 80% or higher |
| `lib/data/` | Covered by integration tests (no numeric target) |
| `lib/presentation/` | Widget tests for major widgets + E2E |

### Unit Tests

**Targets**: Pure calculations in the domain layer, logic in the application layer

**Example**:

```dart
void main() {
  group('FovCalculator', () {
    test('FOV of RASA 8 + ASI294MC Pro is within 1% of the theoretical value', () {
      final result = FovCalculator.cameraFov(
        telescope: rasa8,          // fl=400mm
        camera: asi294mcPro,       // 19.1×13.0mm
        modifier: null,
      );
      expect(result.widthDeg, closeTo(2.735, 0.027));
      expect(result.pixelScale, closeTo(2.388, 0.024));
    });

    test('a 2x Barlow doubles the effective focal length', () {
      final result = FovCalculator.cameraFov(
        telescope: rasa8,
        camera: asi294mcPro,
        modifier: barlow2x,
      );
      expect(result.effectiveFocalLengthMm, 800);
    });
  });
}
```

**Accuracy verification of astronomical calculations**:
- Save known ephemeris values (Chronological Scientific Tables, JPL Horizons output) as JSON in `test/fixtures/` and verify against them with tolerances
- State the source, retrieval date/time, and epoch of each fixture in comments

### Test Naming Conventions

- `group` uses the class or method name; `test` describes "[expected result] under [condition]"

```dart
// ✅ Good examples
test('tiles on both sides are returned for a viewport crossing the RA 0°/360° boundary', () { ... });
test('stars dimmer than the limiting magnitude are not included in query results', () { ... });

// ❌ Bad examples
test('test1', () { ... });
test('works', () { ... });
```

### Use of Mocks and Stubs

**Principles**:
- Mock external dependencies (repositories, HTTP, location) with mocktail
- Use domain layer calculations as-is (do not mock them)
- Use drift's in-memory execution (`NativeDatabase.memory()`) for DB integration tests
- Return manifest / tile binaries via a dio mock adapter for HTTP integration tests

```dart
class MockCatalogRepository extends Mock implements CatalogRepository {}

final container = ProviderContainer(overrides: [
  catalogRepositoryProvider.overrideWithValue(mockRepo),
]);
```

### E2E Tests and Performance Tests

- The 5 scenarios in `integration_test/` (first launch / search / equipment FOV / offline / pan-zoom performance) serve as the release criteria
- The pan-zoom performance test records frame times with `traceAction` and verifies 55fps (average frame time of 18ms or less) on a mid-range physical device

## Code Review Criteria

### Review Points

**Functionality**:
- [ ] Does it satisfy the PRD acceptance criteria and the steering requirements?
- [ ] Are edge cases considered (RA boundary, poles, leap years, time zones)?
- [ ] Does error handling follow the classification table in the functional design document?

**Readability**:
- [ ] Is naming clear (including unit suffixes for physical quantities)?
- [ ] Do formulas have source citations in comments?
- [ ] Is there a "why" explanation for complex logic?

**Maintainability**:
- [ ] Does it comply with the layer dependency rules?
- [ ] Is there no duplicated code (was Grep used to check for similar implementations before implementing)?
- [ ] Does it stay within the guideline of 300 lines or fewer per file?

**Performance**:
- [ ] Is there no heavy computation inside `build()`?
- [ ] Are widgets not used for star rendering?
- [ ] Is there no I/O or decoding that blocks the UI thread?
- [ ] Are there no unnecessary repaints (breaking `RepaintBoundary`)?

**Security**:
- [ ] Is all SQL limited to drift parameter binding?
- [ ] Are there no HTTP (non-HTTPS) URLs?
- [ ] Is location data not sent externally?

### How to Write Review Comments

Make the priority explicit: `[Required]` / `[Recommended]` / `[Suggestion]` / `[Question]`

```markdown
## ✅ Good example
[Required] This query reads all tiles into memory before filtering.
Without limitingMagnitude in the WHERE clause, the memory limit will be exceeded when Tycho-2 is introduced.

## ❌ Bad example
This way of writing it is not good.
```

## Development Process

### Spec-Driven Development Flow (per CLAUDE.md)

1. **Document review**: Read CLAUDE.md → read the relevant `docs/` → search for existing similar implementations with Grep
2. **Work planning**: Create requirements / design / tasklist in `.steering/[YYYYMMDD]-[task-name]/` (using the steering skill)
3. **Implementation**: Implement according to tasklist.md, updating progress as you go
4. **Verification**: Tests, behavior checks, retrospective
5. **Update**: Update persistent documents in `docs/` as needed

### CI (Required Checks)

The following run automatically on every PR, and all must pass before merging is allowed:

| Check | Command |
|------|------|
| Formatting | `dart format --set-exit-if-changed .` |
| Static analysis | `flutter analyze` |
| Generated code diff | `git diff --exit-code` after `dart run build_runner build` |
| Unit and widget tests | `flutter test --coverage` |
| Build verification | Windows / Linux / Android (always in CI). macOS / iOS verified before release |

## Development Environment Setup

### Required Tools

| Tool | Version | Notes |
|--------|-----------|-----------------|
| Flutter SDK | 3.x stable (pinned per project with fvm) | `fvm install && fvm use` |
| Dart | Bundled with Flutter | |
| devcontainer | - | Development environment described in CLAUDE.md. For Linux desktop and Android builds |
| Node.js | v24.11.0 | For helper scripts in `tool/` (not used in the app itself) |
| Platform toolchains | - | Windows: Visual Studio (C++), macOS/iOS: Xcode, Android: Android Studio |

### Setup Steps

```bash
# 1. Clone the repository
git clone <URL>
cd OpenPlanetarium

# 2. Prepare the Flutter SDK (when using fvm)
fvm install
fvm use

# 3. Install dependencies
flutter pub get

# 4. Code generation (drift / riverpod)
dart run build_runner build --delete-conflicting-outputs

# 5. Run tests
flutter test

# 6. Launch (e.g. Windows desktop)
flutter run -d windows
```

### Recommended Development Tools

- **Flutter DevTools**: Checking frame times and repaint regions (verification of the performance conventions)
- **drift_db_viewer / DB Browser for SQLite**: Inspecting the contents of the catalog DB
- **Aladin Lite (Web)**: Reference for comparative verification of HiPS survey display
