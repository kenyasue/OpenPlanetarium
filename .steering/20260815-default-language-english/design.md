# Design Document

## Architecture Overview

No architectural change. `NameLanguage` is a domain enum (`lib/domain/models/constellation_data.dart`) that flows from a single Riverpod settings provider down to the renderers and the search service. Changing the default is a matter of changing the initial value at the one authoritative source plus the defensive defaults of its consumers.

```
ConstellationSettingsController (application/settings)
  └─ ConstellationSettings.language   ← single source of truth (default value changes here)
       ├─ constellationRendererProvider / DsoRenderer / MinorBodyRenderer  (presentation/painters)
       └─ searchServiceProvider → SearchService.language                   (application/search)
```

All consumers read the language via `constellationSettingsProvider.select((s) => s.language)`, so they receive the new default automatically. Their own constructor defaults are only fallbacks for direct instantiation (tests, previews) and are aligned for consistency.

## Component Design

### 1. `ConstellationSettings` (`lib/application/settings/constellation_settings_controller.dart`)

**Responsibilities**:
- Holds the constellation display settings, including `language`
- Serializes/deserializes those settings to/from persisted JSON

**Implementation notes**:
- Two places carry the default: the constructor default (`this.language = ...`) used when nothing is persisted, and the `_fromJson` fallback used when the persisted JSON lacks a valid `language` key. Both must change, otherwise a partially written settings blob would resurrect Japanese.
- A persisted `language: "japanese"` must keep resolving to Japanese — `NameLanguage.values.asNameMap()` lookup already guarantees this, so existing users are unaffected.

### 2. `SearchService` (`lib/application/search/search_service.dart`)

**Responsibilities**:
- Produces search result labels in the active display language

**Implementation notes**:
- The provider passes the language explicitly; only the constructor default changes. Matching stays cross-language, so search behavior is unchanged.

### 3. `DsoRenderer` / `MinorBodyRenderer` (`lib/presentation/painters/`)

**Responsibilities**:
- Draw object labels in the active display language

**Implementation notes**:
- `MinorBodyRenderer` keeps a static label cache keyed by language and clears it on language switch; changing the default value does not affect that mechanism.

## Data Flow

### First launch after a clean install
```
1. ConstellationSettingsController.build() returns const ConstellationSettings()  → language = english
2. It asynchronously reads 'settings.constellation' from the settings repository
3. No value stored → the default is kept
4. Renderers / SearchService watch the provider and render English names
```

### Launch for a user who previously chose Japanese
```
1. build() returns the English default momentarily
2. The stored JSON is read and _fromJson resolves language = japanese
3. state is replaced → renderers rebuild with Japanese names (user's choice preserved)
```

## Error Handling Strategy

### Custom Error Classes

None required.

### Error Handling Patterns

Unchanged: a `FormatException` while decoding persisted settings falls back to the defaults, which now means English.

## Test Strategy

### Unit Tests
- `ConstellationSettings` default: `language == NameLanguage.english`
- `_fromJson` behavior via the persistence round-trip: a stored `japanese` value is restored as Japanese

### Integration Tests
- Existing `test/application/settings/settings_persistence_test.dart` (save/restore including language) must keep passing
- Existing `test/application/search/search_service_test.dart` passes an explicit language and is unaffected

## Dependencies

None added.

## Directory Structure

```
lib/application/settings/constellation_settings_controller.dart  (default + JSON fallback)
lib/application/search/search_service.dart                       (constructor default)
lib/presentation/painters/dso_renderer.dart                      (constructor default)
lib/presentation/painters/minor_body_renderer.dart               (constructor default)
test/application/settings/constellation_settings_test.dart       (new: default-value test)
```

## Implementation Order

1. Change the default in `ConstellationSettings` (constructor + `_fromJson` fallback)
2. Align the constructor defaults in `SearchService`, `DsoRenderer`, `MinorBodyRenderer`
3. Add a test covering the new default and the "existing preference wins" behavior
4. `flutter analyze` / `flutter test`
5. Rebuild and reinstall on the connected device

## Security Considerations

- None; no new data is read, written, or transmitted.

## Performance Considerations

- None. The change is a compile-time constant; no extra work at runtime.

## Future Extensibility

If per-locale defaults are wanted later, the natural seam is `ConstellationSettingsController.build()`: resolve an initial `NameLanguage` from the platform locale before falling back to English. Keeping the enum default at English makes that a purely additive change.
