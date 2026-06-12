# Design

## Approach Overview

In-place translation, no i18n framework. Work proceeds in dependency order so tests can match translated UI strings:

```
Phase 1: lib/ (app code: UI strings + comments)
Phase 2: test/, tool/, src/ (tests read translated lib/ for exact UI-string matches)
Phase 3: Verification (flutter analyze, flutter test, npm test/lint/typecheck)
Phase 4: docs/ + root .md (CLAUDE.md, README.md, prompt.md)
Phase 5: .claude/ (agents, commands, skills)
Phase 6: .steering/ historical documents
Phase 7: Final sweep (Japanese-character grep = 0 hits) + validation
```

Translation work is fanned out to parallel subagents (Agent tool), batched by directory. Each agent receives the same invariants and term glossary (below) to keep translations consistent.

## Translation Invariants (every agent must follow)

**Translate:**
- Comments, doc comments (`///`), TODO notes
- String literals shown to users (Text widgets, tooltips, dialog titles, SnackBar messages)
- Exception messages, log messages
- Markdown prose, headings, tables, mermaid labels

**Never change:**
- Identifiers (class/method/variable names) — already English
- shared_preferences keys, Drift table/column names, JSON keys
- Asset paths, URLs, HTTP parameters, catalog IDs (e.g., `I/259/tyc2`)
- Code inside markdown code blocks when it is config/commands (translate only comments within)
- Numbers, formulas, coordinate math
- YAML frontmatter keys in `.claude/` files (translate only the values such as `description`)

## Term Glossary (consistency contract)

| Japanese | English |
|---|---|
| 恒星 | star |
| 星座 / 星座線 / 星座名 | constellation / constellation lines / constellation names |
| 天体 | celestial object |
| 太陽系天体 | solar system body |
| 小天体 | minor body |
| 視野 / 視野角 | field of view (FOV) |
| 視野シミュレーター | FOV simulator |
| 機材 / 機材管理 | equipment / equipment management |
| 望遠鏡 / 接眼レンズ / カメラ | telescope / eyepiece / camera |
| 観測地 / 現在地 | observing location / current location |
| 日周運動 | diurnal motion |
| 赤経 / 赤緯 | right ascension (RA) / declination (Dec) |
| 方位角 / 高度 | azimuth / altitude |
| 地平線 / 地面 | horizon / ground |
| 等級 / 限界等級 | magnitude / limiting magnitude |
| サーベイ | survey |
| 星図 | sky chart |
| 天の川 | Milky Way |
| 歳差 / 章動 | precession / nutation |
| 恒星時 | sidereal time |
| ステアリングファイル | steering file |
| 永続ドキュメント | persistent documents |
| 振り返り | retrospective |
| 要求内容 | requirements |
| 設計書 | design document |
| タスクリスト | task list |
| 受け入れ条件 | acceptance criteria |
| ユビキタス言語 | ubiquitous language |

## Component Design

### Subagent batches (Phase 1, lib/ — 5 parallel agents)
1. `lib/domain/` (~40 files)
2. `lib/data/` (~20 files)
3. `lib/application/` (~25 files)
4. `lib/presentation/painters/` + `lib/presentation/widgets/` (~22 files)
5. `lib/presentation/screens/` + `lib/app.dart` (~20 files) — densest UI strings

### Subagent batches (Phase 2 — 3 parallel agents)
1. `test/domain/` + `test/fixtures/`
2. `test/application/` + `test/data/`
3. `test/presentation/` + `tool/` + `src/` — presentation tests must `Read` the translated widgets first and match UI strings exactly

### Subagent batches (Phases 4–6 — parallel agents)
- docs: one agent per large file group (`docs/ideas/initial-requirements.md` is 793 lines — own agent; others grouped)
- `.claude/`: one agent per skill directory group, one for agents+commands
- `.steering/`: grouped by milestone (~4 agents)

## Error Handling Strategy

- After each phase, run the Japanese-character grep on the phase's directories; re-dispatch an agent for any file with remaining hits
- Phase 3 gates the code translation: if `flutter test` fails on a string mismatch, fix the test to match `lib/` (the lib string is canonical)
- Agents report files changed + any strings they intentionally left untouched (e.g., Japanese place names in test fixtures — translate the label, keep the coordinates)

## Test Strategy

- `flutter analyze` — no new diagnostics
- `flutter test` — full suite green
- `npm test` / `npm run lint` / `npm run typecheck` — template TS checks green
- Final: `flutter build windows --debug` smoke build

## Implementation Order

1. Phase 1 (lib) → 2. Phase 2 (tests/tools) → 3. Phase 3 (verify code) → 4. Phases 4+5+6 in parallel (docs are independent of code) → 5. Phase 7 final sweep + implementation-validator

## Security / Performance Considerations

- No functional changes; translation only. Risk is limited to accidentally altering string keys — mitigated by the invariants list and the full test suite.
