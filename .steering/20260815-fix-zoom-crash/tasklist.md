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

## Phase 1: Diagnosis

- [x] Pull the device crash reports (`brew install libimobiledevice` → `idevicecrashreport`)
  - [x] Identify the failure as `JetsamEvent` / `per-process-limit`, `Runner` at ~2.2 GB
- [x] Reproduce under `flutter run --profile` and capture `EXC_RESOURCE (limit=2098 MB)`
- [x] Add a temporary auto-zoom + RSS probe to `SkyCanvas` (dart-define driven)
- [x] Bisect the layer stack on the device
  - [x] Baseline: dies between FOV 22.9° and 18.4°
  - [x] `NO_MILKY_WAY`: reaches FOV 0.5°, RSS 115-133 MB
  - [x] `NO_MW_BLUR`: reaches FOV 0.5°, RSS 106-135 MB → the blur is the cause

## Phase 2: Failed narrower fixes (kept for the record)

- [x] ~~Cap the blur sigma at `min(screenLongestSide * 0.25, 256)`~~ (Did not fix it: the
      allocation is not sized by the sigma. Reverted — the blur is gone entirely.)
- [x] ~~Wrap the layer in `canvas.clipRect(screen)`~~ (Did not fix it: Impeller does not
      intersect the blur's allocation with the clip. Reverted.)

## Phase 3: Replace the blur with layered strokes

- [x] Add `MilkyWayRenderer.bandLayers(widthDeg, alpha)` returning concentric strokes in degrees
- [x] Stroke the stack in `render()`, projecting each band's centre line once and reusing it
- [x] Remove `MaskFilter.blur` and the now-unused `blurSigmaFor`

## Phase 4: Quality Checks and Fixes

- [x] Rewrite `test/presentation/painters/milky_way_renderer_test.dart` around `bandLayers`
  - [x] Zoom independence
  - [x] Alphas sum to the band alpha
  - [x] Ordered widest/faintest first
  - [x] Falloff extends past the nominal edge and stays below the peak ring
  - [x] Accumulated alpha never exceeds the band alpha
  - [x] Rendering at both FOV extremes does not throw
- [x] Confirm all tests pass
  - [x] `flutter test` (270 passed)
- [x] Confirm there are no analyzer errors
  - [x] `flutter analyze` (no issues)

## Phase 5: Verification and cleanup

- [x] Re-run the on-device auto-zoom probe with the fix: FOV 0.5° reached, RSS 106→147 MB
- [x] Remove all temporary probe code
  - [x] `SkyCanvas` back to its original content (`git diff` empty)
  - [x] Diagnostic dart-defines removed from `MilkyWayRenderer`
- [x] Rebuild and install on Ken's iPhone (profile build)
- [x] Hand off to the user for on-device confirmation with real pinch gestures
- [x] Post-implementation retrospective (recorded at the bottom of this file)

---

## Post-implementation retrospective

### Implementation completion date
2026-08-15

### Differences between plan and actual

**Points that differed from the plan**:
- The original plan was built on a wrong root cause. Reading the painters showed that `MilkyWayRenderer` was the only unbounded `pxPerDeg`-scaled parameter, and the arithmetic (σ ≈ 8,782 px at the minimum FOV) was compelling enough that the sigma was capped and shipped **without reproducing the crash first**. It did not fix anything. A second guess — `clipRect` — also did not. Only after pulling the device's crash reports did the actual failure mode (a jetsam OOM, not a texture-size limit) become visible.
- The eventual fix is more invasive than planned: the blur is gone entirely rather than bounded, replaced by a stack of concentric strokes.
- The bulge highlight was left untouched. The `NO_MW_BLUR` probe kept it (and kept 25,000 px-wide strokes) and stayed flat, which cleared it directly instead of by argument.

**Newly required tasks**:
- Installing `libimobiledevice` to pull `JetsamEvent` reports.
- Building the temporary auto-zoom probe. It turned a manual, user-driven repro into a deterministic 25-step sweep that could bisect the layer stack, and it is the reason the third attempt was aimed at the right thing.

### Lessons learned

**Technical learnings**:
- **A plausible mechanism is not a diagnosis.** The sigma arithmetic was correct and alarming and still described the wrong failure: the report said `per-process-limit` at 2.2 GB, not a texture-size failure. Two device runs would have cost less than the two wrong fixes did.
- `MaskFilter.blur` in Impeller is sized by the draw's bounds and is bounded by **neither** the sigma nor the canvas clip. Inside a zoomable canvas that makes it unusable: both the stroke width and the projected geometry scale with `pxPerDeg`. A soft edge that has to survive arbitrary zoom should be drawn, not filtered.
- The decisive instrument was the cheapest one: a timer that zooms and prints `ProcessInfo.currentRss`. It immediately separated "Dart heap flat at ~120 MB" from "rasterizer climbing to 2 GB", which is what pointed at the painter rather than the data layer.
- `EXC_RESOURCE` surfaced on the Metal completion queue in one run and the main thread in another — the reporting thread says nothing about the owner of the memory.

**Process improvements**:
- Bisecting behind `bool.fromEnvironment` switches let each hypothesis be tested by rebuilding one binary, with no source churn to unwind afterwards.
- Recording the failed attempts in Phase 2 rather than deleting them keeps the reasoning auditable: the next person can see that sigma and clip were ruled out on the device, not skipped.

### Improvement suggestions for next time
- Reproduce and measure before fixing anything that cannot be observed locally. For this app that means: pull the crash report first, then instrument, then change code.
- Stale `flutter run` sessions kept holding the device and silently blocked the next launch (twice, both times noticed by the user rather than by me). Kill lingering `flutter_tools`/`lldb`/`devicectl` processes before every device run.
- Consider a painter-level guideline in `docs/development-guidelines.md`: no `MaskFilter`, `saveLayer`, or other offscreen-allocating operation whose extent scales with `pxPerDeg`.
