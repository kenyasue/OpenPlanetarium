# Product Requirements Document

## Product Overview

### Name

**OpenPlanetarium** - A cross-platform virtual planetarium that combines beauty with scientific accuracy

### Product Concept

- **A beautiful night sky worth gazing at**: Provides a design-focused planetarium experience that is "enjoyable just to look at," with careful attention to glow, color, and Milky Way rendering
- **A scientifically accurate sky chart**: Accurately reproduces star positions, brightness, and colors based on real catalogs (Bright Star Catalogue / Tycho-2 / Gaia DR3) and photometric data
- **Offline-first data management**: Automatically downloads and caches the star database and survey images, so the app remains usable at observing locations with no network

### Product Vision

We aim for a world where everyone — from beginner stargazers to telescope users — can experience a beautiful night sky on the device in their hands.
With a single Flutter codebase deployed across Windows / macOS / Linux / iOS / Android, the app works as a high-density sky chart workspace on desktop and as a field tool that can be taken to observing locations on mobile.
It rejects the common trade-off in sky chart apps — "accurate but sterile" versus "beautiful but inaccurate" — and achieves scientific accuracy and visual beauty at the same time.
Furthermore, with equipment profiles and the FOV simulator, it lets astrophotographers complete framing studies within a single app.

### Goals

- Enable beginner stargazers to enjoy a beautiful view of the current sky at their location immediately after launch
- Enable astronomy enthusiasts to quickly search for and check major celestial objects such as stars, constellations, and Messier objects
- Automatically download the star database and survey images so the core of all functionality works in offline environments (observing locations)
- Simulate the field of view from equipment information such as telescopes, cameras, and eyepieces to support advance planning for observation and imaging
- Provide a planetarium experience with high design quality that is also appealing for pure enjoyment

## Target Users

### Primary Persona 1: Misaki Sato (24, beginner stargazer)

- A working professional living in an urban area. Became interested in stargazing after seeing night sky photos on social media
- Smartphone (iPhone / Android) is her main device. Rarely uses a PC
- **Current challenges**: Looking up at the night sky, she can't tell which star is which. Existing sky chart apps have too many settings, and the information-dense initial screen made her give up
- **Expected solution**: When she opens the app, a beautiful night sky matching the sky at her current location appears immediately, and she can learn the names of stars and constellations with just a tap
- **Typical usage scenario**: On weekend nights, she holds up her phone on the balcony or while traveling to identify constellations. Indoors, she enjoys gazing at the night sky for relaxation

### Primary Persona 2: Kenichi Yamada (45, astrophotographer)

- 15 years of astronomy experience. Does deep-sky imaging with a RASA 8 and a CMOS camera (ASI294MC Pro)
- Uses a Windows desktop at home, and a laptop and tablet at observing locations
- **Current challenges**: He bounces between multiple web tools to check whether an imaging target fits on the sensor. Observing locations often have weak signal, so online-only tools sometimes can't be used
- **Expected solution**: Once his equipment sets are registered, he can overlay a FOV frame on the target object in the sky chart to verify composition in advance, and it works offline
- **Typical workflow**: Plan imaging targets and composition on the home PC on weekday evenings → Use the tablet at the observing location on the weekend to compare with the actual sky → Image

### Secondary Persona: Educational Users (teachers, science museum staff)

- Want to show constellations and celestial objects in classes and events
- Operate a PC connected to a projector (desktop version), frequently changing the date/time and toggling constellation display
- Need a visually intuitive display that communicates even to audiences unfamiliar with technical terms

## Success Metrics (KPI)

### Primary KPIs

- **Speed of first experience**: From first launch to completing the default star data download (down to magnitude 6) and displaying the night sky within 5 minutes (Wi-Fi environment, measured at release)
- **Offline operation**: Night sky, constellation lines, and major object display down to magnitude 6 works 100% offline (verified in acceptance tests at release)
- **Rendering performance**: Maintain 55fps or higher during pan/zoom operations on mid-range mobile devices (measured in pre-release benchmarks)
- **Cross-platform deployment**: The identical feature set works on all 5 platforms: Windows / macOS / Linux / iOS / Android (at release)

### Secondary KPIs

- **Search success rate**: 95% or higher search hit rate for major object names (Japanese names, English names, catalog numbers) (measured with a search test set)
- **FOV calculation accuracy**: Field of view, magnification, and pixel scale calculations from equipment profiles within 1% error of theoretical values (verified with unit tests)
- **Design quality**: Rated "beautiful" in screenshot comparison reviews against competing apps (Stellarium, etc.) (confirmed in pre-release user reviews)
- **Learnability**: New users can perform "display sky → tap object → view details" within 5 minutes without instructions (measured in usability tests)

## Functional Requirements

### Core Features (MVP)

#### F1: Sky Display (Sky Canvas)

**User story**:
As a beginner stargazer, I want a full-sky display based on my current location, date/time, and direction, so I can check the night sky at my current place and time

**Acceptance criteria**:
- [ ] The night sky is displayed based on the current location (GPS or manual setting) and date/time
- [ ] Zoom in / zoom out and pan operations work (mobile: pinch/swipe, desktop: wheel/drag)
- [ ] Cardinal directions, altitude, azimuth, right ascension (RA), declination (Dec), and the horizon can be displayed
- [ ] The Milky Way and the night sky background gradient are displayed
- [ ] Celestial objects can be selected by tap / click
- [ ] The appearance of stars changes according to the light pollution level setting
- [ ] On desktop, main operations are available via keyboard shortcuts

**Priority**: P0 (must-have)

#### F2: Viewport-Based Object Query and Rendering Optimization

**User story**:
As a mobile user, I want a mechanism that loads and renders only the objects needed for the visible region, so that operation remains smooth even with large star datasets

**Acceptance criteria**:
- [ ] All star data is not loaded into memory at once; only objects within the visible region are fetched via a spatial index (RA/Dec grid or custom tiling scheme)
- [ ] LOD control by zoom level works (wide: up to mag 6, medium: up to mag 10, detailed: mag 12 and beyond)
- [ ] Stars outside the visible region are excluded from query and rendering
- [ ] Data queries run in the background, and the UI does not freeze during fast pan/zoom
- [ ] Query results for an old viewport are never erroneously displayed in the new visible region (query cancellation / debounce)
- [ ] Neighboring tiles and tiles ahead in the direction of movement are prefetched
- [ ] Fetched tiles are LRU-cached in memory + on disk
- [ ] Rendering is done in batch via Canvas / CustomPainter; stars are not created as individual Widgets

**Priority**: P0 (must-have)

#### F3: Star Database Provisioning and Download Management

**User story**:
As a beginner user, I want star data to be available from the first launch, so I can view the night sky without tedious setup

**Acceptance criteria** (spec change at M5 implementation: the default catalog was switched to a bundled approach.
Bundling (176KB) fully satisfies offline-first and makes the first-experience KPI independent of network conditions):
- [x] Star data equivalent to the Bright Star Catalogue (down to magnitude 6.5) is bundled with the app and is available immediately and offline from first launch
- [x] Additional catalogs (Tycho-2, etc.) can be downloaded tile by tile (with progress display, pause/resume, and SHA-256 verification)
- [x] Failed downloads can be retried, and the error reason is displayed

**Priority**: P0 (must-have) (delivery of actual Tycho-2 data is P1: after the distribution server is set up)

#### F4: Data Download Settings

**User story**:
As an astronomy enthusiast, I want to configure which star catalogs, magnitudes, regions, and download methods to use, so I can match my usage and device storage

**Acceptance criteria**:
- [ ] Star catalog (Bright Star Catalogue / Tycho-2) can be selected
- [ ] Display limiting magnitude (mag 4 / 5 / 6 / 8 / 10 / custom) can be selected
- [ ] Download scope (entire sky / around current location / around specified constellations or objects) can be selected
- [ ] Download method (automatic / Wi-Fi only / manual) can be selected
- [ ] Downloaded data size is displayed, and cache deletion and update checks are available

**Priority**: P0 (must-have)

#### F5: Star Color and Brightness Rendering

**User story**:
As an astronomy enthusiast, I want stars to be rendered with colors (based on B-V color index, etc.) and brightness/size according to magnitude, so I can enjoy a night sky close to the real one

**Acceptance criteria**:
- [ ] Star color (blue-white to red) is derived and rendered from the B-V color index (or spectral type / effective temperature)
- [ ] Star size and glow intensity vary with apparent magnitude (bright stars are larger with stronger glow; faint stars are smaller and dimmer)
- [ ] Star color accuracy modes (scientific / aesthetic / enhanced) can be switched
- [ ] Saturation, glow amount, size scale, and per-magnitude brightness curves can be configured
- [ ] The number of displayed stars is automatically controlled according to zoom level and device performance

**Priority**: P0 (must-have) (detailed settings are P1)

#### F6: Constellation Visual Display

**User story**:
As a beginner stargazer, I want constellation lines and names to be displayed beautifully, so I can understand how the stars in the night sky connect

**Acceptance criteria**:
- [ ] Constellation lines and names for all 88 constellations are displayed
- [ ] Constellation lines, names, and constellation boundaries can each be toggled ON / OFF
- [ ] Line opacity and thickness can be adjusted
- [ ] Constellation name language (Japanese / English / Latin) can be switched
- [ ] Basic display of constellation art (illustration overlays) is available (P1)

**Priority**: P0 (must-have) (constellation art and display mode switching are P1)

#### F7: Visual Display of Major Celestial Objects

**User story**:
As an astronomy enthusiast, I want the Moon, Sun, planets, Messier objects, and more to be displayed visually, so I can enjoy highlights beyond the stars

**Acceptance criteria**:
- [ ] The Sun, the Moon, and the 7 planets (Mercury through Neptune) are displayed at their correct positions for the current date/time
- [ ] The Moon is displayed with phases according to moon age
- [ ] Planets are displayed with textures close to their actual appearance (Saturn's rings, Jupiter's bands)
- [ ] The 110 Messier objects and major NGC / IC objects are displayed as icons or thumbnails
- [ ] Each object shows its name, type, and magnitude

**Priority**: P0 (must-have)

#### F8: Search

**User story**:
As an astronomy enthusiast, I want to search by object name, constellation name, or catalog number, so I can find the object I'm looking for quickly

**Acceptance criteria**:
- [ ] Search by object name (e.g., Sirius, Saturn) and constellation name (e.g., Orion) works
- [ ] Search by Messier number (M31) and NGC / IC number (NGC 891) works
- [ ] Search works in both Japanese and English
- [ ] Selecting a search result centers the sky chart on that object
- [ ] A list of currently visible objects and recommended objects is displayed (P1)

**Priority**: P0 (must-have)

#### F9: Object Detail View

**User story**:
As a beginner stargazer, I want a detail screen including images, magnitude, distance, and observation information, so I can learn about the selected object

**Acceptance criteria**:
- [ ] Object name, type, image, apparent magnitude, distance, parent constellation, and coordinates are displayed
- [ ] Current altitude/azimuth and observable times (rise/set and transit times) are displayed
- [ ] A description is displayed
- [ ] Shown in a side panel on desktop and a bottom sheet on mobile

**Priority**: P0 (must-have)

#### F10: Observation Support (Date/Time Change, Time Slider)

**User story**:
As an educational user, I want to freely change the date/time and play diurnal motion as an animation, so I can show how the stars move

**Acceptance criteria**:
- [ ] The date/time can be changed arbitrarily, and the sky display follows
- [ ] The time can be changed continuously with a time slider
- [ ] Diurnal motion animation (fast-forward playback of time) is available
- [ ] Moon age is displayed
- [ ] "Return to current time" works with one tap / one click

**Priority**: P0 (must-have)

#### F11: Survey Layer Display (HiPS)

**User story**:
As an astronomy enthusiast, I want to overlay survey images such as DSS on the sky chart, so I can see the actual appearance of nebulae and galaxies that the chart alone cannot show

**Acceptance criteria**:
- [ ] Tile-based survey display in HiPS format is supported
- [ ] The following 4 layers can be displayed and switched as the initial surveys
  - DSS Colored (color composite)
  - DSS Blue (blue light)
  - DSS Red (red light)
  - DSS NIR (near infrared)
- [ ] Tiles at a resolution matching the zoom level are loaded
- [ ] Opacity can be adjusted
- [ ] Only tiles for the visible region and its surroundings are fetched and cached
- [ ] Surveys other than DSS (2MASS / WISE, etc.) can be added (P1)

**Priority**: P0 (display and switching of the 4 DSS layers) / P1 (adding non-DSS surveys, detailed settings)

#### F12: Equipment Profiles / FOV Simulator

**User story**:
As an astrophotographer, I want to display the field of view from registered combinations of telescopes, cameras, eyepieces, etc. on the sky chart, so I can verify composition before imaging

**Acceptance criteria**:
- [ ] Telescopes (aperture, focal length, etc.), cameras (sensor size, pixel size, etc.), eyepieces (focal length, apparent FOV), and Barlows / reducers (magnification factor) can be registered, edited, and deleted
- [ ] Field of view and pixel scale are calculated from telescope + camera combinations and displayed as a rectangular frame on the sky chart (within 1% error)
- [ ] Magnification, true FOV, and exit pupil are calculated from telescope + eyepiece combinations and displayed as a circular frame
- [ ] Barlow / reducer factors are reflected in the effective focal length
- [ ] Frame rotation angle can be adjusted
- [ ] Equipment sets (combinations) can be saved and switched
- [ ] A frame can be overlaid centered on the selected object to check whether it "fits / does not fit"
- [ ] Mosaic imaging plans can be created (specifying rows, columns, and overlap ratio, with center coordinates shown for each panel)

**Priority**: P0 (basic features) / P1 (mosaic plan details, multi-frame comparison)

#### F13: Responsive UI (Desktop / Mobile)

**User story**:
As any user, I want UI layouts optimized for desktop and mobile respectively, so I can use the app in the form best suited to my device

**Acceptance criteria**:
- [ ] Desktop: displayed with a layout of central canvas + left-side search / object list + right-side detail panel + bottom timeline
- [ ] Mobile: displayed with a layout of full-screen canvas + bottom control bar + bottom-sheet details
- [ ] A dark theme is the base, with a premium design featuring translucent panels and glassmorphism styling
- [ ] UI panels do not obstruct the sky display (collapsible / auto-hide)
- [ ] The layout follows screen size changes (window resize, rotation)

**Priority**: P0 (must-have)

### Future Features (Post-MVP)

#### Gaia DR3 Support

Staged download and display of the large-scale catalog (Gaia DR3) by magnitude, sky region, and zoom level. Includes HEALPix support for the spatial index.

**Priority**: P2 (nice-to-have)

#### AR Mode

AR navigation that uses device sensors to display the night sky in the direction the device is pointed.

**Priority**: P2 (nice-to-have)

#### Other Post-MVP Features

- Telescope mount control integration
- Imaging planning and observation logs
- Astrophoto stacking and photo management
- AI-powered sky commentary, kids' learning mode, mythology story mode
- Comet, asteroid, and artificial satellite data support
- Live astronomical event display
- User-submitted content

**Priority**: P2 (nice-to-have)

## Non-Functional Requirements

### Performance

- Frame rate during pan/zoom: 55fps or higher on mobile (mid-range devices), 60fps on desktop
- Time from viewport change to start of progressive display of required objects: within 200ms (on cache hit)
- Initial display of magnitude-6 data (about 9,000 stars): within 3 seconds of launch (when already downloaded)
- Even with Tycho-2-scale data (about 2.5 million stars), the full dataset is never loaded into memory (tile management with a memory usage cap)
- Survey tiles are fetched only for the visible region + surroundings, and tile-cached

### Offline Support

- Default star data (down to magnitude 6), constellation data, and major object data work 100% offline
- User-selected catalogs and survey data are disk-cached and can be redisplayed offline
- Users can set an upper limit on offline data storage
- After cache deletion, data can be restored by re-downloading

### Usability

- New users can perform "display sky → select object → view details" within 5 minutes without instructions
- All display settings are organized into 8 sections of the settings screen (Display / Star Database / Surveys / Constellations / Objects / Offline Data / Performance / Language)
- Japanese and English UI are supported (Latin notation is also selectable for constellation names)

### Design Quality

- Use a dark theme base, translucent panels (glass UI), and glow/blur effects
- The UI does not obstruct the sky display (collapsible panels, auto-hide)
- Show animations on object selection (selection ring, focus movement)
- Prioritize visual expression over textual information

### Reliability

- Interrupted downloads can be resumed or retried, and incomplete data never corrupts the sky chart
- Equipment profiles, settings, and caches are stored locally and persist across app restarts
- Display continues with the default star data even when data fetching fails (graceful degradation)

### Scalability and Extensibility

- Data source abstraction design that allows new star catalogs to be added
- New survey layers (HiPS-compliant) can be used with configuration changes only
- A rendering architecture where display layers can be added like plugins
- A spatial index design that does not block future Gaia DR3 / HEALPix support

### Security and Privacy

- Location data is used only on the device and is never sent externally
- If location permission is denied, fall back to manual location setting
- Data downloads are performed over HTTPS

## Out of Scope

Items explicitly out of scope (as of MVP):

- Full-scale, large-volume Gaia DR3 support (Post-MVP)
- AR mode (Post-MVP)
- Imaging execution support such as telescope mount control, imaging planning, and photo stacking (Post-MVP)
- User accounts, cloud sync, user-submitted content
- Content features such as AI commentary and learning modes
- Orbit calculation and display of comets, asteroids, and artificial satellites
- Web browser version (supported OSes are Windows / macOS / Linux / iOS / Android only)
