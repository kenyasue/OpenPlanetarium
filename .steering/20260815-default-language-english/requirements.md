# Requirements

## Overview

Change the default display language for celestial object names (`NameLanguage`) from Japanese to English, so a freshly installed app shows English names out of the box.

## Background

The UI text was translated to English in `.steering/20260612-translate-to-english`, but the *object name* language setting (constellations, DSOs, planets, minor bodies) still defaults to `NameLanguage.japanese`. As a result, a first-time user sees an English UI overlaid with Japanese object labels ("オリオン座", "アンドロメダ銀河"). Since the app is now distributed internationally (App Store / Google Play), English is the appropriate default.

The setting itself remains user-switchable (Japanese / English / Latin) from the Constellation display settings — only the initial value changes.

## Features to Implement

### 1. English as the initial value of the name language setting
- `ConstellationSettings.language` defaults to `NameLanguage.english`
- Users who have never touched the language setting see English object names
- Users who already saved a language preference keep their saved value

### 2. Consistent defaults across all name-language consumers
- The default parameter of `SearchService.language`, `DsoRenderer.language`, and `MinorBodyRenderer.language` also becomes English, so any call site that omits the argument behaves consistently with the app default

## Acceptance Criteria

### English as the initial value of the name language setting
- [ ] With no persisted settings, `const ConstellationSettings().language == NameLanguage.english`
- [ ] Restoring settings JSON that lacks a `language` key (or has an unknown value) yields `NameLanguage.english`
- [ ] Restoring settings JSON with `language: "japanese"` still yields `NameLanguage.japanese` (existing users are not overwritten)
- [ ] Switching the language in the settings UI still works for all three options

### Consistent defaults across all name-language consumers
- [ ] `SearchService`, `DsoRenderer`, and `MinorBodyRenderer` default to `NameLanguage.english`
- [ ] `flutter analyze` reports no new issues, and `flutter test` passes

## Success Metrics

- On a clean install, constellation / DSO / planet / minor-body labels and search results are rendered in English without any user action

## Out of Scope

The following will NOT be implemented in this phase:

- UI text localization (an `l10n`/ARB setup); the UI is already English-only
- Auto-detecting the device locale to pick the name language
- Adding new languages beyond Japanese / English / Latin

## Reference Documents

- `docs/product-requirements.md` - Product requirements document
- `docs/functional-design.md` - Functional design document
- `.steering/20260612-translate-to-english/` - The earlier UI translation work
