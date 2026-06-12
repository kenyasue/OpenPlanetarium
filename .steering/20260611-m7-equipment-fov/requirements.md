# Requirements

## Overview

Implement Milestone 7 "Equipment Profiles / FOV Simulator" from the implementation plan. Register telescopes, cameras, eyepieces, and Barlows/reducers; display FOV frames on the star chart (camera = rectangle, eyepiece = circle); and provide fit determination for target celestial objects and mosaic imaging plans (PRD F12).

## Features to Implement

### 1. FOV Calculation (FovCalculator, KPI: error within 1%)
- Effective focal length, camera field of view (exact atan formula), pixel scale
- Eyepiece magnification, true field of view (TFOV), exit pupil diameter
- Fit determination (fits/tight/overflow)
- Mosaic plan (rows × columns, overlap ratio, Dec-dependent RA spacing correction, serpentine order)

### 2. Equipment Profile Management
- Domain models (Telescope / CameraDevice / Eyepiece / OpticalModifier / EquipmentSet)
- Equipment DB (drift, EquipmentDatabase) and EquipmentRepository (CRUD)
- Equipment management screen (per-type lists, add/edit/delete dialogs, validation)
- Creation and switching of equipment sets (telescope + camera or eyepiece + corrective lens, display color, rotation angle)

### 3. FOV Frame Display
- FovFrameRenderer: display the active equipment set's frame on the selected celestial object (or the screen center if none)
- Rotation angle slider; annotations on the frame such as field of view (FOV) and magnification
- Fit determination display (comparison with the selected object's apparent diameter, recommendation message)
- Mosaic mode (rows, columns, overlap ratio specification; panel frames + number display)

## Acceptance Criteria

- [ ] RASA 8 (400mm) + ASI294MC Pro (19.1×13.0mm, 4.63µm) yields FOV 2.74°×1.86° and 2.39"/px within 1% error (test)
- [ ] 1000mm + 25mm/AFOV 50° yields 40x magnification, TFOV 1.25°, and with 200mm aperture an exit pupil of 5mm (test)
- [ ] Barlow 2x / reducer 0.67x are reflected in the effective focal length (test)
- [ ] M31 (apparent diameter approx. 3.0°×1.0°) is judged overflow in a 2.74°×1.86° frame + mosaic suggestion (test)
- [ ] Mosaic plan panel centers are spaced taking the overlap ratio into account and ordered in serpentine fashion (test)
- [ ] Equipment registration, editing, deletion, and equipment set saving work and are retained after restart (DB test)
- [ ] The camera frame (rectangle) and eyepiece field of view (circle) are displayed on the star chart and can be rotated (visual check)
- [ ] format / analyze / all tests pass, Windows build succeeds

## Out of Scope

- Simultaneous comparison display of multiple equipment sets (P1, backlog)
- Frame drag movement / rotation handle (rotation is handled by slider. Direct manipulation to be considered in M8's usability improvements)
- Filter management / imaging plan integration (Post-MVP)
- Screenshot export (M8)

## Reference Documents

- `docs/implementation-plan.md` Milestone 7
- `docs/functional-design.md` A5 / FovSimulationService / equipment models
- `docs/product-requirements.md` F12
