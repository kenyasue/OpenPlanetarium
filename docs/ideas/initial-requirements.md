# PRD: Virtual Planetarium App

## Virtual Planetarium App

## 1. Overview

This app is a beautiful, design-focused virtual planetarium application available on desktop and mobile.
Users can intuitively explore the night sky and visually enjoy major celestial objects such as stars, constellations, nebulae, galaxies, and star clusters.

The app is developed with Flutter, targeting deployment to Windows / macOS / Linux / iOS / Android.
It emphasizes both scientific accuracy and a beautiful visual experience.

---

## 2. Purpose

### 2.1 Product Goals

* Beginners in stargazing can enjoy a beautiful night sky
* Astronomy enthusiasts can easily check constellations, stars, and major celestial objects
* Star databases and survey images are downloaded automatically and usable offline
* Provide a highly designed planetarium experience that is attractive even purely for viewing pleasure

### 2.2 Target Users

* Stargazing beginners
* Astronomy enthusiasts
* Telescope users
* Users who want to show constellations and celestial objects for educational purposes
* General users who want to enjoy a beautiful space visual app

---

## 3. Supported Platforms

### 3.1 Technology Stack

* Frontend: Flutter
* Supported OS:

  * Windows
  * macOS
  * Linux
  * iOS
  * Android

### 3.2 UI Policy

* Responsive design supporting both desktop and mobile
* On desktop, leverage a wide sky chart canvas and side panels
* On mobile, center on a full-screen sky chart, with settings shown via bottom sheets and swipe gestures
* Dark theme as the default
* High-end sci-fi / observatory / glass-UI style design
* Prioritize visual expression over textual information

---

## 4. Key Features

## 4.1 Sky Display

### Overview

Display the night sky based on the current location, a specified date/time, and a specified direction.

### Features

* Full celestial sphere display
* Zoom in / zoom out
* Pan operation
* Compass direction display
* Altitude / azimuth display
* Right ascension (RA) / declination (Dec) display
* Horizon display
* Milky Way display
* Night sky background gradient rendering
* Star twinkling effect
* Star display adjustment according to light pollution level

### Controls

* Mobile:

  * Pinch zoom
  * Swipe to move
  * Tap to select a celestial object
* Desktop:

  * Mouse wheel zoom
  * Drag to move
  * Click to select a celestial object
  * Keyboard shortcuts

---

## 4.2 Automatic Star Database Download

### Overview

Automatically download the required star databases at app startup or during initial setup.

### Initial Settings

By default, assuming an experience close to naked-eye observation, star data down to magnitude 6 is downloaded automatically.

### Recommended Databases

#### Level 1: Default

**Bright Star Catalogue**

Use cases:

* Display of bright stars down to around magnitude 6
* Initial download
* Lightweight, fast rendering

Characteristics:

* Covers stars brighter than magnitude 6.5
* Ideal for beginner-friendly sky charts
* Easy to use offline

#### Level 2: Standard Extension

**Tycho-2 Catalogue**

Use cases:

* More detailed sky charts
* For intermediate users
* For binocular and small telescope users

Characteristics:

* About 2.5 million bright stars
* Includes positions, proper motions, and photometric data
* Also usable for star color rendering

#### Level 3: High-Precision Extension

**Gaia DR3**

Use cases:

* High-precision, large-scale sky charts
* Research-oriented, detailed exploration
* For future advanced features

Characteristics:

* Extremely large star catalog
* High-precision positional and photometric data
* Full download is huge, so per-region, per-magnitude, and per-tile downloads are required

---

## 4.3 Data Download Settings

### Overview

Users can choose which databases to download from the settings screen.

### Settings

* Star catalog selection

  * Bright Star Catalogue
  * Tycho-2
  * Gaia DR3
* Display limiting magnitude

  * Down to magnitude 4
  * Down to magnitude 5
  * Down to magnitude 6
  * Down to magnitude 8
  * Down to magnitude 10
  * Custom
* Download scope

  * Whole sky
  * Around current location
  * Around a specified constellation
  * Around a specified celestial object
* Download method

  * Automatic
  * Wi-Fi only
  * Manual
* Offline storage

  * Enabled / Disabled
* Cache deletion
* Data update check
* Downloaded data size display

---

## 4.4 Star Color Rendering

### Overview

Star colors are rendered as accurately as possible based on photometric data included in the databases.

### Candidate Input Data

* B-V color index
* Gaia BP-RP
* Spectral type
* Effective temperature

### Rendering Policy

* Blue-white stars
* White stars
* Yellow stars
* Orange stars
* Red stars

### User Settings

* Star color accuracy

  * Scientific
  * Aesthetic
  * Emphasized
* Saturation
* Color temperature correction
* Glow amount for bright stars
* Softness of star edges
* Star size scale
* Brightness curve per magnitude
* Display threshold for faint stars

---

## 4.5 Star Brightness Rendering

### Overview

Adjust on-screen brightness and size according to each star's apparent magnitude.

### Requirements

* Bright stars are larger and have a strong glow
* Faint stars are rendered small and dim
* Adjust star density according to zoom level
* On mobile, prioritize performance and automatically limit the number of displayed stars
* On desktop, allow high-density display

### Settings

* Star size multiplier
* Star brightness multiplier
* Glow intensity
* Faint star fade
* Display curve per magnitude
* Light pollution simulation

---

## 4.6 Constellation Visual Display

### Overview

Beautifully display constellation lines, constellation names, and constellation art.

### Features

* Constellation lines display
* Constellation names display
* Constellation boundary lines display
* Constellation illustrations display
* Mythology-style art overlay
* Modern minimal display
* Detailed information display per constellation

### Display Modes

* Simple line drawing
* Classic sky chart style
* Mythological illustration style
* Modern UI style
* Educational mode

### Settings

* Constellation lines ON / OFF
* Constellation names ON / OFF
* Constellation boundaries ON / OFF
* Constellation art ON / OFF
* Line opacity
* Line thickness
* Constellation name language

  * Japanese
  * English
  * Latin

---

## 4.7 Visual Display of Major Celestial Objects

### Overview

In addition to stars, display major celestial objects with visuals.

### Target Objects

* Moon
* Sun
* Planets

  * Mercury
  * Venus
  * Mars
  * Jupiter
  * Saturn
  * Uranus
  * Neptune
* Major nebulae
* Major galaxies
* Major star clusters
* Messier objects
* NGC / IC objects

### Displayed Information

* Object icon
* Thumbnail image
* Name
* Type
* Magnitude
* Distance
* Visible direction
* Ease of observation
* Description

### Visual Representation

* Planets are rendered with textures close to their actual appearance
* The Moon shows phases according to its lunar age
* Saturn shows its rings
* Jupiter shows its cloud bands
* Nebulae and galaxies are displayed photo-based or illustration-based

---

## 4.8 Survey Data Mapping Feature

### Overview

Map astronomical survey images onto the sky chart for display.
Tile-based survey display such as the HiPS format is assumed.

### Candidate Surveys

#### Initial Candidates

* DSS / DSS2
* 2MASS
* WISE
* Pan-STARRS
* SDSS
* DESI Legacy Surveys

### Display Method

* Overlay survey images on the sky chart background
* Load tiles according to zoom level
* Adjustable opacity
* Switch between multiple surveys
* Overlay survey images with the star catalog

### Settings Screen

* List of available surveys
* Download target selection
* Display target selection
* Opacity setting
* Cache size limit
* Download on Wi-Fi only
* Offline storage
* Tile resolution selection
* Description display per survey

### Recommended Implementation

For the initial implementation, support the HiPS format rather than managing all surveys independently.
In the future, implement tile retrieval, caching, and layer display referencing the Aladin Lite and CDS HiPS specifications.

---

## 4.9 Search Feature

### Overview

Search for stars, constellations, planets, nebulae, galaxies, and star clusters.

### Features

* Object name search
* Constellation name search
* Messier number search
* NGC / IC number search
* Coordinate search
* List of currently visible objects
* Recommended objects display

### Search Examples

* Orion
* Sirius
* M31
* NGC 891
* Saturn
* Polaris

---

## 4.10 Observation Support Features

### Overview

Provide auxiliary features useful for actual astronomical observation.

### Features

* Sky display based on current location
* Date/time change
* Time slider
* Diurnal motion animation
* Rise and set times of celestial objects
* Transit (culmination) time
* List of easily observable objects
* Lunar age display
* Light pollution level setting
* Compass direction indicator
* AR mode (candidate)

---

## 5. Screen Design

## 5.1 Home / Sky Screen

### Desktop

* Center: sky canvas
* Left: search / object list
* Right: detailed information of the selected object
* Bottom: timeline / date-time change
* Top: display mode switching

### Mobile

* Full screen: sky canvas
* Bottom: control bar
* Bottom sheet: object details
* Bottom right: current location / direction / settings buttons
* Top left: search button

---

## 5.2 Settings Screen

### Sections

1. Display settings
2. Star database settings
3. Survey data settings
4. Constellation display settings
5. Celestial object display settings
6. Offline data management
7. Performance settings
8. Language settings

---

## 5.3 Object Detail Screen

### Displayed Items

* Object name
* Type
* Image
* Apparent magnitude
* Distance
* Constellation
* Coordinates
* Current altitude / azimuth
* Observable time window
* Description
* Related objects
* Survey image display button

---

## 6. Data Design

## 6.1 Star Data

### Main Fields

* star_id
* name
* catalog_id
* right_ascension
* declination
* magnitude
* color_index
* spectral_type
* temperature
* proper_motion_ra
* proper_motion_dec
* parallax
* distance
* constellation
* source_catalog

---

## 6.2 Celestial Object Data

### Main Fields

* object_id
* name
* alternative_names
* object_type
* right_ascension
* declination
* magnitude
* angular_size
* distance
* constellation
* description
* thumbnail_url
* image_source
* catalog_source

---

## 6.3 Survey Data

### Main Fields

* survey_id
* name
* wavelength
* provider
* tile_format
* min_zoom
* max_zoom
* attribution
* cache_policy
* download_status
* enabled

---

## 7. Non-Functional Requirements

## 7.1 Performance

* Aim for near-60fps interaction on mobile
* Load large star datasets in tiled, level-divided form
* Do not render stars outside the visible area
* Manage star data with LOD per zoom level
* Cache survey image tiles
* Allow high-resolution, high-density display on desktop

---

## 7.2 Offline Support

* Default star data is stored offline
* Cache survey data selected by the user
* Basic sky chart can be displayed even when offline
* Offline data size is configurable

---

## 7.3 Design Quality

* The beauty of the night sky is the top priority
* The UI must not get in the way of the sky
* Use semi-transparent panels
* Make use of glow, blur, and granular texture
* Make object selection animations beautiful
* Use high-quality illustrations for constellation art

---

## 7.4 Extensibility

* Design allowing new star catalogs to be added
* Design allowing new survey layers to be added
* Celestial object data sources can be swapped out
* Display layers can be added in a plugin-like manner

---

## 8. MVP Scope

## 8.1 Required for MVP

* Desktop and mobile UI built with Flutter
* Sky canvas display
* Automatic download of stars down to magnitude 6, equivalent to the Bright Star Catalogue
* Brightness rendering according to star magnitude
* Star color rendering
* Constellation lines and constellation names display
* Search for major celestial objects
* Object detail display
* Data download settings
* Basic survey layer display
* Offline caching

---

## 8.2 Deferred from MVP

* Full large-scale Gaia DR3 support
* Advanced AR mode
* Telescope control
* Imaging planning feature
* Astrophoto stacking
* User-submitted content feature
* AI narration feature

---

## 9. Recommended Milestones

## Milestone 1: Foundation

* Create the Flutter project
* Design shared desktop/mobile UI
* Implement the sky canvas
* Implement coordinate transformation logic
* Date/time and current location settings

## Milestone 2: Star Display

* Import star data down to magnitude 6
* Display star positions
* Size and brightness adjustment by magnitude
* Star color rendering
* Zoom / pan controls

## Milestone 3: Constellation Display

* Implement constellation line data
* Constellation names display
* Constellation ON / OFF settings
* Basic implementation of constellation art display

## Milestone 4: Celestial Object Data

* Display planets, Moon, and Sun
* Display Messier objects and major NGC objects
* Object search
* Object detail screen

## Milestone 5: Data Management

* Automatic star database download
* Download settings screen
* Offline caching
* Data update feature

## Milestone 6: Survey Layers

* Research and implement HiPS-style tile display
* Layer selection for DSS / 2MASS / WISE, etc.
* Opacity setting
* Survey cache management

## Milestone 7: Design Polish

* UI visual improvements
* Add animations
* Improve quality of the sky rendering
* Improve mobile usability
* Improve desktop usability

---

## 10. Success Metrics

* Basic sky chart is usable within 5 minutes of first launch
* Night sky down to magnitude 6 can be displayed offline
* Smooth zooming and panning on mobile
* High-density sky display on desktop
* Constellation lines and names are displayed clearly and beautifully
* Users can intuitively select star data and survey data from the settings screen
* The appearance of the night sky feels more beautiful than competing apps

---

## 11. Technical Notes

### 11.1 Handling Large-Scale Star Data

Huge catalogs like Gaia DR3 must not be downloaded in full by the app; they need to be partitioned by magnitude, sky region, and zoom level.
For the MVP, target stars down to magnitude 6, and incrementally add detailed catalogs in the future.

### 11.2 Survey Data

Survey images are extremely large, so the basic approach is on-demand tile retrieval and caching rather than a whole-sky bulk download.
Referencing the HiPS format, fetch only the tiles needed for each zoom level.

### 11.3 Rendering in Flutter

Rendering large numbers of stars with standard Flutter widgets becomes slow, so use CustomPainter, Canvas, and where appropriate Fragment Shaders or Impeller.
GPU optimization may become necessary in the future.

---

## 12. Future Extensions

* AR sky navigation
* Telescope mount integration
* Imaging planning
* Observation log
* Astrophoto management
* AI-powered sky narration
* Learning mode for children
* Mythology story mode
* Live astronomical event display
* Comet / Asteroid data support
* Artificial satellite display

## 4.11 Viewport-Based Object Search and Rendering Optimization

### Overview

To display large numbers of stars, deep-sky objects, and survey tiles at high speed, search, load, and render only the celestial object data needed for the area currently visible on screen, the zoom level, and the display limiting magnitude.

The app does not load all star data into memory at once; instead, it uses a spatial index that partitions sky coordinates to fetch only the objects contained in the visible area.

---

### Purpose

* Display quickly even with large-scale star catalogs
* Keep memory usage low on mobile devices
* Make rendering smooth during zoom and pan
* Load survey images and object data only for the needed area
* Design that can scale to huge database extensions like Gaia DR3

---

### Target Data

* Star data
* Deep-sky objects such as nebulae, galaxies, and star clusters
* Constellation lines and constellation boundaries
* Survey image tiles
* Future comet, asteroid, and artificial satellite data

---

### Basic Specification

The app computes the following from the current display state.

* RA / Dec at the center of the screen
* RA / Dec range of the visible area
* Zoom level
* Screen resolution
* Display limiting magnitude
* Enabled display layers
* Current date/time
* Current location

Based on that information, it queries the local DB or cache for only the objects needed for display.

---

### Spatial Index

Star data and celestial object data are managed with a spatial index that partitions the sky into regions.

Recommended approaches:

* HEALPix
* HTM
* RA/Dec grid
* Custom tile scheme

For the MVP, adopt the easy-to-implement RA/Dec grid or a custom tile scheme, and consider HEALPix support in the future.

---

### Data Partitioning

Star data is partitioned and stored under the following criteria.

* Sky region tile
* Magnitude range
* Catalog type
* Zoom level
* Display layer

Example:

```text
stars/
  catalog_bright_star/
    mag_0_6/
      tile_0001.bin
      tile_0002.bin

  catalog_tycho2/
    mag_0_8/
    mag_8_10/

  catalog_gaia_dr3/
    mag_0_10/
    mag_10_12/
    mag_12_15/
```

---

### Display Query

When the visible area changes, the app executes the following query.

```text
getVisibleObjects(
  viewportRaMin,
  viewportRaMax,
  viewportDecMin,
  viewportDecMax,
  zoomLevel,
  limitingMagnitude,
  enabledLayers
)
```

Returned items:

* Stars within the visible area
* Deep-sky objects within the visible area
* Constellation lines intersecting the visible area
* Survey tiles needed for the visible area

---

### LOD per Zoom Level

Control the amount of data loaded according to the zoom level.

#### Wide-Field View

* Down to magnitude 4–6
* Major constellation lines
* Major objects only
* Low-resolution survey image tiles

#### Mid-Range View

* Down to magnitude 8–10
* More constellation lines and object labels
* Messier objects and major NGC objects
* Mid-resolution survey tiles

#### Detailed View

* Magnitude 12 and beyond
* High-density star display
* Detailed NGC / IC objects
* High-resolution survey tiles
* Detailed catalogs such as Gaia DR3

---

### Prefetching

To reduce latency during pan and zoom, also pre-load tiles surrounding the current visible area.

Prefetch targets:

* Visible screen area
* 1–2 surrounding tiles
* Tiles ahead in the direction of movement
* The next LOD of the current zoom level
* Adjacent survey image tiles

---

### Caching

Fetched tile data is cached locally.

Cache strategies:

* Memory cache
* Disk cache
* LRU policy
* Per-catalog cache size limits
* Per-survey cache size limits

Users can adjust cache sizes on the settings screen.

---

### Asynchronous Loading

Fetching object data must not block the UI thread.

Requirements:

* Run data queries in the background
* Keep showing lower-LOD data while loading
* Smoothly swap in new data when it arrives
* Discard stale query results
* Throttle query frequency during fast panning

---

### Query Cancellation

If the user pans or zooms quickly, cancel queries for outdated viewports.

Requirements:

* Track the latest viewport ID
* Do not reflect stale query results on screen
* Apply debounce / throttle during continuous interaction
* Switch to a simplified display mode during fast movement

---

### Rendering Optimization

Exclude objects outside the visible area at render time as well.

Requirements:

* Do not render off-screen stars
* Avoid overlapping labels
* Do not render stars that are too small
* Control label density according to zoom level
* Batch rendering with Canvas / CustomPainter
* Do not create stars as individual Widgets
* Consider GPU shader rendering as needed

---

### Integration with Survey Data

Survey images are also fetched per tile based on the visible area.

Requirements:

* Fetch only tiles needed for the current visible area
* Select tile resolutions matching the zoom level
* Do not render tiles outside the visible area
* On opacity changes, redraw only — do not re-download
* When switching surveys, fetch only tiles for the same viewport

---

### Acceptance Criteria

* With display down to magnitude 6, panning and zooming are smooth even on mobile
* Even with Tycho-2-scale data, the full dataset is not loaded into memory
* Stars outside the visible area are not searched or rendered
* After pan/zoom, the needed objects appear progressively
* The UI does not freeze during fast interaction
* Stale query results are not mistakenly shown in the new viewport
* Survey tiles are fetched only for the visible area and its surroundings
* After cache deletion, data can be re-downloaded and re-displayed

---

### Implementation Priority

Required for the MVP.

Reasons:

* Rendering large numbers of stars directly in Flutter easily causes performance problems
* It becomes the foundation for handling Tycho-2 / Gaia DR3 / survey layers in the future
* Memory management is critical for supporting both desktop and mobile

## 4.12 Equipment Profiles and Field of View Simulator

### Overview

Provide a feature where users can register equipment information such as telescopes, cameras, eyepieces, Barlow lenses, and reducers, and display the actual field of view (FOV) on the sky chart.

With this feature, users can check in advance, before observing, "how the target object will fit in the camera frame," "how much area will be visible through an eyepiece," and "how the field of view changes when using a Barlow or reducer."

---

### Purpose

* Make framing checks easier for observation and astrophotography
* Allow checking whether an imaging target fits on the camera sensor
* Visualize the field of view for each telescope-camera combination
* Simulate the true field of view when using eyepieces
* Reflect focal length changes when using Barlows or reducers
* Allow saving and switching between multiple equipment sets

---

## 4.12.1 Equipment Profile Management

### Registrable Equipment

#### Telescope

Users can register telescope information.

Input fields:

* Equipment name
* Type

  * Refractor
  * Reflector
  * Schmidt-Cassegrain
  * Ritchey-Chrétien
  * RASA
  * Newtonian
  * Other
* Aperture mm
* Focal length mm
* F-ratio
* Notes

Example:

```text
Name: RASA 8
Aperture: 203 mm
Focal Length: 400 mm
F-ratio: f/2
```

---

#### Camera

Users can register astrophotography camera information.

Input fields:

* Camera name
* Sensor width mm
* Sensor height mm
* Pixel size μm
* Resolution width px
* Resolution height px
* Sensor type

  * CMOS
  * CCD
  * DSLR
  * Mirrorless
  * Planetary Camera
* Color / Monochrome
* Notes

Example:

```text
Name: ASI294MC Pro
Sensor Width: 19.1 mm
Sensor Height: 13.0 mm
Resolution: 4144 x 2822 px
Pixel Size: 4.63 μm
```

---

#### Eyepiece

Users can register eyepieces for visual observation.

Input fields:

* Eyepiece name
* Focal length mm
* Apparent field of view AFOV degree
* Barrel diameter

  * 1.25 inch
  * 2 inch
* Notes

Example:

```text
Name: 25mm Plössl
Focal Length: 25 mm
Apparent Field of View: 50°
```

---

#### Barlow Lens

Input fields:

* Equipment name
* Magnification factor

  * 1.5x
  * 2x
  * 2.5x
  * 3x
  * Custom
* Notes

Effects:

* Effective focal length becomes longer
* Field of view becomes narrower
* Suited to planetary imaging and lunar close-ups

Example:

```text
Telescope Focal Length: 1000 mm
Barlow: 2x
Effective Focal Length: 2000 mm
```

---

#### Reducer

Input fields:

* Equipment name
* Reduction factor

  * 0.8x
  * 0.67x
  * 0.63x
  * 0.5x
  * Custom
* Notes

Effects:

* Effective focal length becomes shorter
* Field of view becomes wider
* Suited to wide targets such as nebulae and galaxies

Example:

```text
Telescope Focal Length: 2000 mm
Reducer: 0.67x
Effective Focal Length: 1340 mm
```

---

## 4.12.2 Camera Field of View Display

### Overview

Calculate the imaging field of view from the telescope-camera combination and display it as a rectangular frame on the sky chart.

### Displayed Items

* Camera sensor FOV frame
* Horizontal field of view
* Vertical field of view
* Diagonal field of view
* Pixel scale
* Effective focal length
* F-ratio
* Size comparison with the target object

### Calculations

#### Effective Focal Length

```text
Effective Focal Length = Telescope Focal Length × Barlow/Reducer Factor
```

Examples:

```text
400 mm × 0.67 = 268 mm
400 mm × 2.0 = 800 mm
```

#### Camera Field of View

```text
FOV Width = 57.3 × Sensor Width / Effective Focal Length
FOV Height = 57.3 × Sensor Height / Effective Focal Length
```

#### Pixel Scale

```text
Pixel Scale = 206.265 × Pixel Size / Effective Focal Length
```

Units:

```text
arcsec / pixel
```

---

### Display on the Sky Chart

* Display the camera frame centered on the selected object
* Adjustable frame rotation angle
* Comparative display of multiple frames
* Accurately reflect the camera aspect ratio
* Show the actual composition according to sensor size
* Frames can be overlaid on survey images

### UI Operations

* Drag the frame to reposition it
* Adjust the angle with a rotation handle
* Auto-center on the target object
* Save frames
* Screenshot export

---

## 4.12.3 Eyepiece Field of View Display

### Overview

Calculate the visual observation field of view from the telescope-eyepiece combination and display it as a circular frame on the sky chart.

### Displayed Items

* Eyepiece FOV circle
* Magnification
* True field of view
* Apparent field of view
* Exit pupil diameter
* Effective focal length
* FOV after applying Barlow / reducer

### Calculations

#### Magnification

```text
Magnification = Effective Telescope Focal Length / Eyepiece Focal Length
```

Example:

```text
1000 mm / 25 mm = 40x
```

#### True Field of View

```text
True Field of View = Apparent Field of View / Magnification
```

Example:

```text
50° / 40x = 1.25°
```

#### Exit Pupil

```text
Exit Pupil = Telescope Aperture / Magnification
```

Example:

```text
200 mm / 40x = 5 mm
```

---

### Display on the Sky Chart

* Display the eyepiece's circular field of view
* Comparative display of multiple eyepieces
* Display the magnified FOV when using a Barlow
* Display the widened FOV when using a reducer
* Check whether the target object fits within the field of view

---

## 4.12.4 Equipment Sets

### Overview

Frequently used equipment combinations can be saved as an "equipment set."

### Information Included in an Equipment Set

* Telescope
* Camera
* Eyepiece
* Barlow
* Reducer
* Filter
* Frame rotation angle
* Display color
* Notes

### Examples

```text
Deep Sky Setup
- Telescope: RASA 8
- Camera: ASI294MC Pro
- Reducer: None
- Purpose: Wide-field nebula imaging

Planetary Setup
- Telescope: RC12
- Camera: Planetary Camera
- Barlow: 2.5x
- Purpose: Jupiter / Saturn / Moon

Visual Setup
- Telescope: 1000mm Refractor
- Eyepiece: 25mm
- Purpose: General visual observation
```

---

## 4.12.5 Multi-Frame Comparison

### Overview

Display multiple equipment sets on the sky chart simultaneously to compare differences in field of view.

### Usage Examples

* RASA 8 + ASI294MC Pro
* RC12 + 0.67x Reducer + ASI294MC Pro
* Telescope + 25mm eyepiece
* Telescope + 10mm eyepiece
* Telescope + 2x Barlow + planetary camera

### Display

* Show a name on each frame
* Per-frame color setting
* ON / OFF toggle
* Opacity adjustment
* Frame rotation angle adjustment

---

## 4.12.6 Framing Check Against a Target Object

### Overview

For a selected object, check how it would look with the current equipment set.

### Features

* Display the frame centered on the object
* Display the object's apparent size
* Display the object's coverage ratio relative to the FOV
* Determine "fits / does not fit"
* Show recommended equipment sets
* Suggest recommended framing

### Example

```text
Target: M31 Andromeda Galaxy
Apparent Size: approx. 3.0° × 1.0°
Current FOV: 2.7° × 1.8°
Result: May slightly overflow horizontally
Suggestion: Recommend a shorter focal length or mosaic imaging
```

---

## 4.12.7 Mosaic Imaging Plan

### Overview

When a large object does not fit in a single field of view, display a mosaic composition for imaging with multiple frames.

### Features

* 2-panel mosaic
* 4-panel mosaic
* 3×2 mosaic
* Custom rows and columns
* Overlap ratio setting
* Display of each panel's center coordinates
* Imaging order display

### Settings

* Overlap ratio

  * 10%
  * 15%
  * 20%
  * 25%
  * Custom
* Frame rotation angle
* Centering on the target object
* RA/Dec coordinate output

---

## 4.12.8 Settings Screen

### Equipment Settings Section

Add the following to the settings screen.

* Telescope management
* Camera management
* Eyepiece management
* Barlow management
* Reducer management
* Equipment set management
* Display frame settings
* Frame color settings
* Frame opacity settings
* Default equipment set selection

---

## 4.12.9 Acceptance Criteria

* The field of view can be calculated from the telescope focal length and camera sensor size
* The camera FOV can be displayed as a rectangle on the sky chart
* The eyepiece FOV can be displayed as a circle on the sky chart
* The field of view narrows when a Barlow factor is applied
* The field of view widens when a reducer factor is applied
* Multiple equipment sets can be saved
* Multiple FOV frames can be displayed simultaneously
* Selecting a target object shows whether it fits in the current field of view
* The frame rotation angle can be changed
* Operable on both mobile and desktop

---

## 4.12.10 Implementation Priority

Implement the basic features in the MVP.

### Implemented in the MVP

* Telescope registration
* Camera registration
* Eyepiece registration
* Barlow / reducer factor input
* Camera FOV frame display
* Eyepiece FOV circle display
* Frame overlay on the target object
* Equipment set saving
* Mosaic imaging plan

### Later Phases
* Recommended framing suggestions
* Multi-equipment comparison
* Filter management
* Integration with imaging planning
* Telescope mount integration
