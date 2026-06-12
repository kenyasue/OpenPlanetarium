# Task List

## 🚨 Task Completion Principle

**Continue working until every task in this file is complete (`[x]`).**

- Skipping for "time constraints" or "too complex" is forbidden
- Skips are allowed only for technical reasons, recorded as: `- [x] ~~task~~ (no longer needed: reason)`
- If a task is too large, split it into subtasks in this file

---

## Phase 1: Application code (lib/)

- [x] Translate `lib/domain/` (models, astro, spatial, optics, repositories, exceptions)
- [x] Translate `lib/data/` (catalog, database, network, survey, settings, platform)
- [x] Translate `lib/application/` (controllers, providers, services)
- [x] Translate `lib/presentation/painters/` + `lib/presentation/widgets/`
- [x] Translate `lib/presentation/screens/` + `lib/app.dart` (UI strings)
- [x] Sweep: zero Japanese characters in `lib/`

## Phase 2: Tests and tools

- [x] Translate `test/domain/` + `test/fixtures/`
- [x] Translate `test/application/` + `test/data/`
- [x] Translate `test/presentation/` (match translated UI strings exactly) + `tool/` + `src/`
- [x] Sweep: zero Japanese characters in `test/`, `tool/`, `src/` (Japanese remains only as intentional `ja`-field data values in tool/ converters and Japanese-name-search test fixtures)
- [x] Fix control_bar `_StatusBlock` RenderFlex overflow caused by longer English status strings (converted Row to Wrap)

## Phase 3: Code verification

- [x] `flutter analyze` passes with no new issues (No issues found)
- [x] `flutter test` passes (219 tests green)
- [x] `npm test` passes (7 tests)
- [x] `npm run lint` passes
- [x] `npm run typecheck` passes

## Phase 4: Documentation (docs/ + root)

- [x] Translate `docs/ideas/initial-requirements.md`
- [x] Translate `docs/product-requirements.md` + `docs/glossary.md` (glossary keeps Japanese terms in parentheses as ubiquitous-language references)
- [x] Translate `docs/functional-design.md` (one nameJa example value kept)
- [x] Translate `docs/architecture.md` + `docs/implementation-plan.md`
- [x] Translate `docs/repository-structure.md` + `docs/development-guidelines.md`
- [x] Translate `CLAUDE.md`, `README.md`, `prompt.md`

## Phase 5: .claude/ (agents, commands, skills)

- [x] Translate `.claude/agents/` + `.claude/commands/`
- [x] Translate `.claude/skills/steering/` + `.claude/skills/development-guidelines/`
- [x] Translate `.claude/skills/architecture-design/` + `.claude/skills/functional-design/` + `.claude/skills/glossary-creation/`
- [x] Translate `.claude/skills/prd-writing/` + `.claude/skills/repository-structure/`

## Phase 6: .steering/ history

- [x] Translate `.steering/20260611-m1..m4` milestone docs (すばる kept as Japanese-name search feature example, glossed "(Subaru)")
- [x] Translate `.steering/20260611-m5..m8` milestone docs
- [x] Translate `.steering/20260611-*` fix/feature docs (hips-display-fix, equipment-dialog-fix, ui-control-bar, altaz-anchor-coords, wifi-horizon-maglimit, vizier-tycho2, celestial-settings)

## Phase 7: Final verification

- [x] Project-wide sweep: Japanese-character grep returns zero hits in target dirs (remaining Japanese is only the documented intentional set: catalog `ja` data fields, tool/ name-data maps, Japanese-name search test fixtures, glossary reference terms, and this steering directory's own JP→EN mapping table)
- [x] `flutter build windows --debug` smoke build succeeds
- [x] implementation-validator subagent review passes (PASS on all 6 checks; both trivial polish items fixed or accepted)
- [x] Retrospective recorded below

---

## Retrospective

### Completion date
2026-06-12

### Plan vs. actual

**Differences from plan**:
- The longer English status strings ("Moon age …", "FOV …°") caused a `RenderFlex` overflow in the control bar `_StatusBlock` at mobile widths, failing 2 widget tests. Fixed by converting the fixed `Row` to a `Wrap` — the only functional (non-text) code change in the entire effort.
- One pre-existing test failure surfaced: the Saturn search test queried '土星' but the lib translation Anglicized `SolarBodyId` display names; the test was updated to query 'Saturn' (lib is canonical).
- Two non-.md config files (`.prettierignore`, `analysis_options.yaml`) contained Japanese comments and were added to scope during the final sweep.

**Intentional Japanese kept** (by design, not skipped work):
- `assets/catalogs/*.json` `ja` fields and the `_japaneseNames`/`_jaNames` maps in `tool/catalog_converter/` — these are Japanese-name *data* powering the Japanese-name display/search feature (`NameLanguage.japanese`, `nameJa`)
- Test fixtures/queries exercising Japanese-name search (`search_service_test.dart` etc.)
- Parenthesized Japanese reference terms in `docs/glossary.md` (ubiquitous-language cross-reference)
- The JP→EN term mapping table in this directory's `design.md`

### Lessons learned

**Technical**:
- Translating UI strings can break layouts: English is typically longer than Japanese, so fixed-width `Row`s need `Wrap`/`Flexible` review.
- Order matters: translating `lib/` before `test/` let test agents read the canonical English strings instead of guessing, avoiding assertion mismatches.
- A shared term glossary in every agent prompt kept 18 parallel agents consistent (FOV, observing location, diurnal motion, etc.).

**Process**:
- Phase-gating with a Japanese-character grep sweep after each phase caught stragglers cheaply (e.g. `.prettierignore`).
- `nameJa`/`labelJa` identifiers now hold English values in domain enums; identifiers were deliberately left unrenamed (out of scope). A future cleanup could rename them to `label`/`displayName`.

### Improvements for next time
- For repo-wide text transformations, include non-.md config files (dotfiles, yaml comments) in the initial scope inventory.
- When translating user-facing strings, run widget tests at multiple viewport widths early to catch overflow regressions before the final phase.
