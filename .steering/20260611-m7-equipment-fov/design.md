# Design Document

## Architecture Overview

```
presentation/  EquipmentScreen (management UI) / FovFrameRenderer / FovControlSection (left panel)
application/   equipmentProviders (CRUD, listing) / ActiveFovController (set selection, rotation, mosaic)
domain/        equipment models / FovCalculator (pure calculation) / EquipmentRepository (IF)
data/          EquipmentDatabase (drift, equipment.db) / DriftEquipmentRepository
```

## Component Design

### 1. Domain Models (lib/domain/models/equipment.dart)

Conforms to the models in functional-design.md (Telescope / CameraDevice / Eyepiece / OpticalModifier / EquipmentSet).
EquipmentSet guarantees mutual exclusion of cameraId and eyepieceId via assert. ids are UUIDs.

### 2. FovCalculator (lib/domain/optics/fov_calculator.dart)

Formulas from functional design A5 (exact atan formula, 206.265 coefficient).
- CameraFovResult {widthDeg, heightDeg, diagonalDeg, pixelScaleArcsec, effectiveFocalLengthMm, fRatio}
- EyepieceFovResult {magnification, trueFovDeg, exitPupilMm, effectiveFocalLengthMm}
- FitResult enum {fits, tight, overflow} + checkFit(frameW/H, targetMaj/Min): axis comparison ignoring rotation (compare the target's major/minor axes against the frame's long/short sides. Within 90% = fits, within 100% = tight)
- MosaicPlan {panels: List<MosaicPanel{row, col, order, center}>}: panel spacing = frame dimensions × (1-overlap), RA spacing corrected by cos(dec), serpentine (boustrophedon) order

### 3. EquipmentDatabase (lib/data/database/equipment_database.dart)

- 5 tables (telescopes / cameras / eyepieces / modifiers / equipmentSets). Numbers are real, enums are text
- DriftEquipmentRepository implements EquipmentRepository: per-type CRUD; instead of watch (Stream), update notification via FutureProvider + invalidate

### 4. ActiveFovController (application/fov/active_fov_controller.dart)

```dart
class ActiveFovState { String? activeSetId; double rotationDeg; bool mosaicEnabled; int rows; int cols; double overlap; }
```
- Persisted (settings.fov). Computed frame values are derived via fovFrameProvider (Provider):
```dart
class FovFrame { final bool isCircle; final double widthDeg; final double heightDeg; final String label; }
final fovFrameProvider = Provider<FovFrame?>; // computed from activeSet + equipment lists
```

### 5. FovFrameRenderer (presentation/painters/fov_frame_renderer.dart)

- Center: selectedObjectPosition ?? view center
- Rectangle: angular offsets on the tangent plane (rotate ±w/2, ±h/2) → ra=ra0+dx/cos(dec0), dec=dec0+dy → project each side subdivided in 3 and draw a polygon
- Circle: 36-point circumference
- Mosaic: render each of the rows × cols panels the same way + number label (centered)
- Annotation label: size/magnification notation below the frame (in the equipment set color)
- Layer order: immediately before SelectionRenderer

### 6. UI

- EquipmentScreen (reached from the settings screen + directly from the left panel): equipment set list (first) + per-type ExpansionTiles. Add/edit via dialog forms (numeric validation = ValidationException policy)
- FovControlSection (desktop left panel): set selection Dropdown, rotation Slider, mosaic toggle + rows/columns/overlap, fit determination display (when a celestial object is selected)
- Mobile: via the settings screen (equipment management) + display is automatic when there is an active set

## Test Strategy

- FovCalculator: all numeric examples from the acceptance criteria (1% error) + mosaic center spacing, serpentine order, cos(dec) correction
- DriftEquipmentRepository: in-memory CRUD, set reference integrity
- ActiveFovController: fovFrame derivation (camera/eyepiece/corrective lens)

## Implementation Order

1. Domain models + FovCalculator + tests
2. EquipmentDatabase + repository + tests
3. ActiveFovController + fovFrameProvider + tests
4. FovFrameRenderer + SkyCanvas integration
5. Equipment management UI + FovControlSection
6. Verification → validator → merge
