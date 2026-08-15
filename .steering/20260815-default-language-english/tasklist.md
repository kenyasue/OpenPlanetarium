# Task List

## 🚨 Principle of Full Task Completion

**Continue working until ALL tasks in this file are complete**

### Required Rules
- **Mark every task as `[x]`**
- "Planned as a separate task due to time constraints" is forbidden
- "Deferred because the implementation is too complex" is forbidden
- Do not finish work while leaving incomplete tasks (`[ ]`) behind

### Plan only implementable tasks
- During planning, list only "tasks that can be implemented"
- Do not include "tasks we might do in the future"
- Do not include "tasks under consideration"

### The only cases where skipping a task is allowed
Skipping is allowed only when one of the following technical reasons applies:
- A change in implementation approach made the feature itself unnecessary
- An architecture change replaced it with a different implementation
- A dependency change made the task impossible to execute

When skipping, always state the reason explicitly:
```markdown
- [x] ~~Task name~~ (No longer needed due to implementation approach change: specific technical reason)
```

### If a task is too large
- Split the task into smaller subtasks
- Add the split subtasks to this file
- Complete the subtasks one by one

---

## Phase 1: Change the settings default

- [x] Change the default in `ConstellationSettings`
  - [x] Constructor default `this.language = NameLanguage.english`
  - [x] `_fromJson` fallback `?? NameLanguage.english`

## Phase 2: Align consumer defaults

- [x] `SearchService.language` default → `NameLanguage.english`
- [x] `DsoRenderer.language` default → `NameLanguage.english`
- [x] `MinorBodyRenderer.language` default → `NameLanguage.english`

## Phase 3: Quality Checks and Fixes

- [x] Add a test for the new default
  - [x] Default `ConstellationSettings().language == NameLanguage.english`
  - [x] A persisted `japanese` preference is still restored as Japanese
  - [x] Settings JSON without a `language` key falls back to English
- [x] Pin the language in `search_service_test.dart` (added during implementation:
      its acceptance set asserts Japanese labels and relied on the old default)
- [x] Confirm all tests pass
  - [x] `flutter test` (269 passed)
- [x] Confirm there are no analyzer errors
  - [x] `flutter analyze` (no issues)

## Phase 4: Documentation Updates

- [x] Update `docs/functional-design.md` if it states a default name language
      (no change needed: the persistent docs list the name-language *setting*
      but never state its initial value, so nothing contradicts the new default)
- [x] Rebuild and reinstall on the connected device (Ken's iPhone)
- [x] Post-implementation retrospective (recorded at the bottom of this file)

---

## Post-implementation retrospective

### Implementation completion date
2026-08-15

### Differences between plan and actual

**Points that differed from the plan**:
- design.md planned a new `test/application/settings/constellation_settings_test.dart`. The tests were added to the existing `settings_persistence_test.dart` instead, because two of the three cases need the same `ProviderContainer` + `InMemorySettingsRepository` harness that file already sets up; a separate file would have duplicated it for no gain.

**Newly required tasks**:
- Pinning `language: NameLanguage.japanese` in `search_service_test.dart`. Four acceptance tests there assert Japanese labels ('アンドロメダ銀河', 'かに星雲', …) and had been relying on the old default rather than stating it. Making the language explicit keeps those Japanese-label assertions meaningful and leaves the separate English-label group as the coverage for the new default.

### Lessons learned

**Technical learnings**:
- The default lived in two places that had to move together: the constructor default (used when nothing is persisted) and the `_fromJson` fallback (used when the stored blob lacks a valid `language`). Changing only the constructor would have left partially written settings resurrecting Japanese.
- The `NameLanguage.values.asNameMap()` lookup is what preserves an existing user's saved choice, so the change is safe on upgrade — only first-run behaviour moves.
- Tests that depend on a default without naming it turn any default change into a false failure. Pinning the value in the test is both the fix and the documentation.

**Process improvements**:
- Grepping for every `NameLanguage.japanese` occurrence up front (5 in `lib/`, all of them defaults) made the change list complete before any edit, so no consumer was missed.

### Improvement suggestions for next time
- If per-locale defaults are ever wanted, `ConstellationSettingsController.build()` is the seam: resolve the platform locale there and keep English as the fallback.
- The UI text is English-only with no `l10n`/ARB setup; if UI localization is added later, this name-language setting should be revisited so the two do not drift apart.
