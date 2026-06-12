# Requirements (Bug Fix)

## Reported Problem

When saving a camera or equipment set, an "A TextEditingController was used after being disposed" exception occurs, making equipment management unstable (user report, 2026-06-11, with a stack trace originating from the TextFormField at equipment_forms.dart:292).

## Root Cause Analysis

The previous response to the M7 validator findings (functional dialogs + dispose in finally/whenComplete) was inappropriate.
The Future returned by `showDialog` completes at the moment of Navigator.pop, but during the dialog route's **exit animation** (about 150ms) the Widget tree containing the TextFormField is still alive, and the AnimatedBuilder's re-listen touches the already-disposed Controller and crashes.

## Fix Details

Convert all 5 dialogs (telescope, camera, eyepiece, corrective lens, equipment set) to StatefulWidget classes,
creating the TextEditingController in State.initState and releasing it in State.dispose (safe because it is called after the route is fully destroyed).
This follows the validator's originally recommended approach (the fix proposed for Issue 1 in the M7 verification report).

## Acceptance Criteria

- [ ] No crash on add/edit/cancel for all equipment types including camera and equipment set (verified in Widget tests through save/cancel plus completion of the exit animation)
- [ ] All existing tests pass
