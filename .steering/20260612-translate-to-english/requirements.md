# Requirements

## Overview

Translate the entire OpenPlanetarium project from Japanese to English: all documentation (`.claude/`, `docs/`, every `.md` file including `.steering/` history) and the application itself (UI strings, code comments, log/error messages in `lib/`, `test/`, `tool/`, `src/`).

## Background

The project was developed with Japanese documentation and Japanese UI strings (copied from FlatterPlanetarium). To open the project to an international audience (OpenPlanetarium), everything user-facing and contributor-facing must be in English.

## Translation Targets

### 1. Application source code (`lib/`, ~106 files)
- UI strings (tooltips, labels, dialog titles, button text, status messages)
- Code comments and doc comments
- Exception/error messages and log messages
- MUST NOT change: identifiers, persistence keys (shared_preferences keys, DB column names), asset paths, URLs, API parameters, file formats

### 2. Tests and tools (`test/` ~33 files, `tool/` 7 files, `src/` 1 file)
- Test descriptions (`group`/`test` names), comments
- Test assertions that match UI strings MUST be updated to the exact English strings used in `lib/` (e.g., `find.text('現在時刻')`)

### 3. Documentation
- `docs/` (9 files incl. product-requirements, functional-design, architecture, glossary, etc.)
- Root files: `CLAUDE.md`, `README.md`, `prompt.md`
- `.claude/` agents, commands, skills (28 .md files)
- `.steering/` historical work documents (~50 files)

## Acceptance Criteria

### Application
- [ ] No Japanese characters remain in `lib/`, `test/`, `tool/`, `src/`
- [ ] `flutter analyze` passes with no new issues
- [ ] `flutter test` passes (all tests green)
- [ ] `npm test`, `npm run lint`, `npm run typecheck` pass

### Documentation
- [ ] No Japanese characters remain in any `.md` file
- [ ] `.claude/` skills/commands/agents remain functionally intact (frontmatter, file references, code blocks preserved)
- [ ] Technical terms translated consistently per the glossary mapping in design.md

## Success Metrics

- `grep` for Japanese characters (Hiragana/Katakana/Kanji) returns zero hits in the target directories
- App builds and runs on Windows with English UI

## Out of Scope

- Internationalization framework (flutter_localizations / ARB files) — strings stay inline, English only
- Translating binary assets or catalog data files (`assets/catalogs/`)
- Translating third-party content (LICENSE remains as-is; ios LaunchImage README is already English)
- `.metadata`, `pubspec.yaml` description (already English)

## Reference Documents

- `docs/glossary.md` — domain term definitions (source for the term mapping)
- `docs/development-guidelines.md` — coding standards
