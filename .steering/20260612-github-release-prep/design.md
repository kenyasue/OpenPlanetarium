# Design

## Current State Audit

| Item | State | Action |
|---|---|---|
| README.md | English, good feature list, but titled "FlatterPlanetarium", no per-platform instructions, no prerequisites | Rewrite with OpenPlanetarium branding + platform sections |
| .gitignore | Covers Node, Flutter basics, IDE, OS | Add `.fvm/`, `macos/Pods/`, symbol files, `mvp-log.json`; keep the rest |
| LICENSE | MIT text present, holder "Copyright (c) 2025 Generative Agents" (template) | Update to `Copyright (c) 2026 Ken Yasue` |
| package.json | name "claude-code-book-chapter8", description "Claude Code book - Chapter 8 template" | Rename to `openplanetarium-docs-tooling`, real description; scripts unchanged |
| Generated files | `lib/data/database/*.g.dart` committed (correct for Flutter apps — no build step needed by users before `pub get`+`build_runner`) | Keep tracked; README documents regeneration |
| mvp-log.json | Local development log produced during MVP build | Add to .gitignore (not meaningful for the public repo) |
| prompt.md | One-line historical kickoff prompt | Keep (harmless project history) |

## README Structure

```
# OpenPlanetarium
intro paragraph + platform badges line (text only, no external badge services)
## Features (existing list, kept)
## Requirements
  - Flutter SDK (stable, Dart ^3.11), per-platform toolchains table
## Getting Started (all platforms)
  git clone → flutter pub get → dart run build_runner build → flutter run
## Platform Guides
  ### Windows (VS 2022 C++ workload; flutter config --enable-windows-desktop; run/build commands; output path)
  ### macOS (Xcode + CocoaPods; run/build; output path)
  ### Linux (clang/cmake/ninja/GTK3 apt line; run/build; output path)
  ### Android (Android Studio/SDK; licenses; run/build apk + appbundle)
  ### iOS (Xcode + CocoaPods; simulator run; codesigned build note)
## Development
  tests, tool/check.ps1, devcontainer note, docs tooling (npm), catalog server option, data generation scripts
## Documentation (existing map)
## Data Sources (existing)
## License (point to LICENSE, MIT; data licenses note)
```

Command accuracy rules:
- `flutter config --enable-<platform>-desktop` for desktop targets
- Windows debug output: `build\windows\x64\runner\Debug\flatter_planetarium.exe` (verified in this session); release: `...\Release\...`
- Code generation required after clone because `.g.dart` files ARE committed — state it as optional ("only needed after modifying Drift tables")... verify: they are tracked, so after clone build works without build_runner. Document as "regenerate when changing database schema".

## .gitignore Additions

```
# Flutter additions
.fvm/
macos/Pods/
app.*.symbols
app.*.map.json

# Local development logs
mvp-log.json
```

Review notes: `pubspec.lock` and `package-lock.json` stay tracked (application repo). `.metadata` stays tracked (flutter upgrade metadata). `*.iml` already covered. `windows/linux/macos/ios` ephemeral dirs already covered. `.claude/settings.local.json` already covered.

## Verification

- `npm test` / `npm run lint` / `npm run typecheck` (workflow step 7)
- `flutter analyze`
- Spot-verify README claims that are cheap to verify locally (Windows debug build already verified earlier this session; test count claim)
- implementation-validator subagent reviews README accuracy against the repo

## Implementation Order

1. README.md rewrite
2. .gitignore additions
3. LICENSE copyright update
4. package.json metadata
5. Verification suite + validator
