# Requirements

## Overview

Prepare the OpenPlanetarium repository for public release on GitHub: a complete README with introduction and per-platform setup/build/run instructions, a verified `.gitignore`, and a proper MIT license.

## Background

The project was translated to English and is functionally complete (M1–M8 milestones done, 219 tests green). Before publishing on GitHub, the repository metadata must present the project properly to newcomers: the README currently lacks platform-specific instructions, the LICENSE carries a template copyright holder, and template artifacts (package.json metadata) remain.

## Deliverables

### 1. README.md
- Project introduction under the **OpenPlanetarium** name (note: Flutter package name remains `flatter_planetarium`)
- Feature overview (already exists — keep/polish)
- Prerequisites and environment setup (Flutter SDK version, platform toolchains)
- Build & run instructions for each supported platform: Windows, macOS, Linux, Android, iOS
- Development section: code generation, tests, check script, devcontainer, npm doc tooling
- Existing sections preserved: catalog server option, data generation scripts, documentation map, data sources, license

### 2. .gitignore check
- Verify Flutter/Dart, Node, IDE, OS coverage
- Add missing entries appropriate for an open-source Flutter release (e.g. `.fvm/`, macOS Pods, symbol files, local dev logs)
- Confirm no file currently in the tree would be wrongly ignored or wrongly published

### 3. MIT License
- LICENSE file present at root with MIT text
- Copyright line updated from the template holder ("Generative Agents") to the project owner (Ken Yasue, 2026)
- README license section references the LICENSE file and notes data-source licenses

### 4. Repository metadata cleanup
- package.json: replace template name/description ("claude-code-book-chapter8") with project-appropriate metadata, set license MIT, keep all scripts working

## Acceptance Criteria

- [ ] README contains working setup/build/run commands for all 5 platforms
- [ ] README commands verified against the actual project (at minimum: Windows build runs)
- [ ] .gitignore covers Flutter, Node, IDE, OS artifacts; review documented in design.md
- [ ] LICENSE is MIT with correct holder/year
- [ ] `npm test`, `npm run lint`, `npm run typecheck` still pass
- [ ] `flutter analyze` clean

## Out of Scope

- Renaming the Flutter package (`flatter_planetarium`) or directories
- CI/CD workflows (GitHub Actions) — can be a follow-up
- Creating the GitHub repository / pushing / tagging a release
- Screenshots and store assets
- CONTRIBUTING.md / CODE_OF_CONDUCT.md (not requested)

## Reference Documents

- `docs/repository-structure.md`
- `docs/development-guidelines.md`
- Current `README.md`, `.gitignore`, `LICENSE`
