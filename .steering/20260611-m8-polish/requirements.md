# Requirements

## Overview

Carry out Milestone 8 "Design Polish / Release Preparation" from the implementation plan. Improve the quality of the starry sky rendering (Milky Way), resolve known rendering issues, reconcile documentation, and verify the release build.

## Implementation Targets

### 1. Starry Sky Rendering Quality Improvements
- Procedural representation of the Milky Way (a faint band of light along the galactic plane. Compute the galactic plane from the north galactic pole RA 192.86°/Dec 27.13° (J2000))
- Add a Milky Way ON/OFF toggle to the display settings

### 2. Resolution of Known Rendering Issues (Backlog of Validator Findings)
- Change SkyPainter.shouldRepaint to state-based determination (eliminate layer list identity comparison)
- Cache TextPainters in FovFrameRenderer (unify the pattern with other renderers)
- Share the cos(dec) floor constant and add a comment

### 3. Documentation Reconciliation / Release Preparation
- Update the FovSimulationService description in docs/functional-design.md to match the implementation (FovCalculator)
- Update README.md to reflect the actual state of the app (build/run instructions, feature list)
- Fill in actual results for the M8 completion criteria in implementation-plan.md (for items that cannot be performed, state the reason and the alternative)
- flutter build windows --release succeeds + launch verified + screenshot

## Acceptance Criteria

- [ ] The Milky Way is displayed along the galactic plane and can be toggled ON/OFF in settings (galactic plane geometry test + visual check)
- [ ] format / analyze / all tests pass
- [ ] flutter build windows --release succeeds + launch verified
- [ ] README.md and docs are consistent with the implementation

## Out of Scope (with reasons)

- Star twinkling animation (due to battery/jank risk from constant repainting. A PRD F1 feature list item but outside the acceptance criteria. Moved to backlog)
- 55fps measurement on real mobile devices and iOS/macOS/Linux build verification (this development machine is Windows only. Noted as remaining work in implementation-plan.md)
- Strict verification of HiPS tile orientation (cross-checking against an all-sky survey requires interactive verification. Only a rough screenshot check was performed; TODO comment retained)
- Setting up integration_test (E2E) (substituted by 159 unit tests + launch smoke test. Setting up the E2E environment is recorded in implementation-plan as future work)

## Reference Documents

- `docs/implementation-plan.md` Milestone 8
- Validator finding backlogs of each milestone (retrospectives in .steering/*/tasklist.md)
