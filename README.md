# OpenPlanetarium

A cross-platform virtual planetarium that combines beauty with scientific accuracy.
Built with Flutter, running on **Windows, macOS, Linux, Android, and iOS** from a single codebase.

OpenPlanetarium is offline-first: all star, constellation, and deep-sky data is bundled, so the full sky works without a network connection. Survey imagery and extended catalogs can be downloaded on demand.

## Download

Prebuilt binaries are available on the [Releases page](https://github.com/kenyasue/OpenPlanetarium/releases):

- **Windows**: download `OpenPlanetarium-<version>-windows-x64.zip` from the [latest release](https://github.com/kenyasue/OpenPlanetarium/releases/latest), unzip it anywhere, and run `open_planetarium.exe` (keep the exe together with the DLLs and `data/` folder in the zip)

For other platforms, build from source — see the [Platform Guides](#platform-guides) below.

## Features

- **Sky view**: Full celestial sphere based on current location, date/time, and direction. Supports panning, zooming (focal zoom), and keyboard controls
- **Stars**: Real catalog (derived from HYG v4.1; 8,920 stars down to magnitude 6.5 bundled). Scientifically accurate star colors from B-V color index, with size and glow scaled by magnitude
- **Constellations**: Constellation lines, names (Japanese/English/Latin), and IAU boundaries for all 88 constellations
- **Solar system bodies**: Position calculations for the Sun, Moon (with phases), and 7 planets (Meeus/Standish compliant), plus lunar age display
- **Deep-sky objects**: 110 Messier objects plus major NGC/IC objects (717 objects total), with type icons
- **Search**: Object names (Japanese/English), constellation names, M/NGC/IC numbers, planet names
- **Object details**: Magnitude, coordinates, altitude/azimuth, rise/transit/set times
- **Observation support**: Time slider, diurnal motion playback (60x/600x/3600x), light pollution level setting
- **Survey layers**: Overlays DSS (Colored/Blue/Red/NIR) HiPS tiles on the star chart. Tiles are LRU-cached and can be redisplayed offline
- **Equipment & field-of-view simulator**: Register telescopes, cameras, eyepieces, and Barlows/reducers to display FOV frames (rotatable), fit checks, and mosaic imaging plans
- **Milky Way**: Procedural rendering along the galactic plane
- **Offline-first**: All star, constellation, and object data is bundled. Settings, equipment, and observing locations are persisted

## Requirements

- **Flutter SDK** (stable channel, Dart SDK `^3.11.4`) — [install guide](https://docs.flutter.dev/get-started/install)
- Platform toolchains:

| Target | Additional requirements |
|---|---|
| Windows | Visual Studio 2022 with the "Desktop development with C++" workload |
| macOS | Xcode (latest stable), CocoaPods (`sudo gem install cocoapods`) |
| Linux | `clang`, `cmake`, `ninja-build`, `pkg-config`, GTK 3 headers |
| Android | Android Studio (or Android SDK + command-line tools), an emulator or device |
| iOS | macOS with Xcode, CocoaPods, an iOS simulator or device |

Run `flutter doctor` and resolve any reported issues for your target platform.

## Getting Started

```bash
git clone https://github.com/<your-account>/OpenPlanetarium.git
cd OpenPlanetarium
flutter pub get
flutter run        # picks a connected device; or pass -d <device> as shown below
```

> The generated Drift database code (`lib/data/database/*.g.dart`) is committed, so no code-generation step is needed for a fresh build. Regenerate it only after changing the database schema (see [Development](#development)).

## Platform Guides

### Windows

```bash
flutter config --enable-windows-desktop   # once per machine
flutter run -d windows                    # debug run
flutter build windows --release           # release build
```

Release output: `build\windows\x64\runner\Release\open_planetarium.exe` (ship the whole `Release` folder — it contains the required DLLs and `data/` directory).

### macOS

```bash
flutter config --enable-macos-desktop     # once per machine
flutter run -d macos                      # debug run
flutter build macos --release             # release build
```

Release output: `build/macos/Build/Products/Release/open_planetarium.app`. For distribution outside your machine, sign and notarize per [Flutter's macOS deployment guide](https://docs.flutter.dev/deployment/macos).

### Linux

```bash
# Debian/Ubuntu toolchain
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

flutter config --enable-linux-desktop     # once per machine
flutter run -d linux                      # debug run
flutter build linux --release             # release build
```

Release output: `build/linux/x64/release/bundle/` (run `bundle/open_planetarium`).

### Android

```bash
flutter doctor --android-licenses         # accept SDK licenses once
flutter run -d <device-or-emulator-id>    # debug run (flutter devices to list)
flutter build apk --release               # APK
flutter build appbundle --release         # Play Store bundle (AAB)
```

Outputs: `build/app/outputs/flutter-apk/app-release.apk` and `build/app/outputs/bundle/release/app-release.aab`. Release builds use the debug signing config until you [configure signing](https://docs.flutter.dev/deployment/android#sign-the-app).

### iOS

```bash
cd ios && pod install && cd ..            # first build only, if prompted
flutter run -d <simulator-or-device-id>   # debug run
flutter build ios --release               # requires code signing set up in Xcode
```

Open `ios/Runner.xcworkspace` in Xcode to configure your team/signing for device builds and App Store distribution.

## Development

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # regenerate Drift code (after schema changes)
flutter test                                              # unit & widget tests (219 tests)
flutter analyze                                           # static analysis
pwsh tool/check.ps1                                       # format + analyze + test in one go
```

A [devcontainer](.devcontainer/devcontainer.json) is provided for containerized development environments.

This repository uses spec-driven development; Node.js tooling (Prettier/ESLint/Vitest, `npm install` then `npm test` / `npm run lint`) supports the documentation workflow and is not required for building the app.

### Serving Additional Catalogs (Optional)

To provide additional catalogs such as Tycho-2 for download, specify the distribution server URL at build time:

```bash
flutter build windows --release --dart-define=CATALOG_BASE_URL=https://example.com/catalogs
```

### Data Generation Scripts (tool/catalog_converter)

The bundled assets can be regenerated with the following (place the source data in cache/):

```bash
dart run tool/catalog_converter/convert.dart                # stars (HYG -> bsc_tiles.bin)
dart run tool/catalog_converter/convert_constellations.dart # constellations (Stellarium+HYG)
dart run tool/catalog_converter/convert_dso.dart            # deep-sky objects (OpenNGC)
```

## Documentation

The persistent documents for spec-driven development are in `docs/`:

- `product-requirements.md` — Product requirements document (PRD)
- `functional-design.md` — Functional design document (including algorithms A1-A6)
- `architecture.md` — Technical specification (4-tier layered architecture)
- `repository-structure.md` — Repository structure document
- `development-guidelines.md` — Development guidelines
- `glossary.md` — Glossary
- `implementation-plan.md` — Implementation plan by milestone (M1-M8)

Work-unit plans and retrospectives are kept as history in `.steering/`.

## Data Sources

- Stars: [HYG Database](https://github.com/astronexus/HYG-Database) v4.1 (CC BY-SA 4.0)
- Constellation lines: Stellarium modern sky culture / IAU boundaries: Delporte (1930)
- Deep-sky objects: [OpenNGC](https://github.com/mattiaverga/OpenNGC) (CC BY-SA 4.0)
- Survey imagery: DSS2 (CDS/Aladin HiPS, STScI/NASA)

## License

[MIT License](LICENSE). Bundled data is subject to the licenses of its respective sources (see [Data Sources](#data-sources)).
