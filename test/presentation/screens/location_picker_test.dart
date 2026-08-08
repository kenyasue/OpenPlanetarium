import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/location/location_controller.dart';
import 'package:open_planetarium/application/location/world_cities_provider.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/data/catalog/world_map_loader.dart';
import 'package:open_planetarium/data/platform/location_provider.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/presentation/screens/settings/widgets/location_section.dart';

class _UnavailableLocationProvider implements DeviceLocationProvider {
  @override
  Future<GeoLocation> getCurrentLocation() async =>
      throw const LocationUnavailableException('test');
}

/// Small deterministic catalog: 2 countries, 3 cities
const _citiesJson =
    '[["Tokyo","Japan",35.69,139.69,1],'
    '["Osaka","Japan",34.69,135.5,0],'
    '["Paris","France",48.85,2.35,1]]';

/// One triangle-shaped land mass
const _landJson = '[[[0,0],[40,0],[40,40]]]';

/// The lat/lon entry fields, located by label (DropdownMenu also embeds
/// TextFields internally, so find.byType(TextField) alone is ambiguous)
TextField _fieldWithLabel(WidgetTester tester, String label) =>
    tester.widget<TextField>(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == label,
      ),
    );

void main() {
  late ProviderContainer container;

  Widget wrap() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            child: SingleChildScrollView(child: LocationSection()),
          ),
        ),
      ),
    );
  }

  setUp(() {
    container = ProviderContainer(
      overrides: [
        deviceLocationProviderProvider.overrideWithValue(
          _UnavailableLocationProvider(),
        ),
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
        worldMapLoaderProvider.overrideWithValue(
          WorldMapLoader(
            loader: (key) async =>
                key.endsWith('world_cities.json') ? _citiesJson : _landJson,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('selecting a country filters the city menu', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Open the country picker and choose Japan
    await tester.tap(find.byKey(const ValueKey('country-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japan').last);
    await tester.pumpAndSettle();

    // Open the city picker: Japanese cities are offered without country
    // suffix, and Paris is absent
    await tester.tap(find.byKey(const ValueKey('city-picker')));
    await tester.pumpAndSettle();
    expect(find.text('Tokyo'), findsWidgets);
    expect(find.text('Osaka'), findsWidgets);
    expect(find.textContaining('Paris'), findsNothing);
  });

  testWidgets('selecting a city sets the observing location', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('city-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paris (France)').last);
    await tester.pumpAndSettle();

    final fix = container.read(locationControllerProvider).value!;
    expect(fix.location.name, 'Paris');
    expect(fix.location.latitudeDeg, closeTo(48.85, 1e-6));
    expect(fix.location.longitudeDeg, closeTo(2.35, 1e-6));
    expect(fix.source, LocationSource.manual);

    // The lat/lon input fields follow the selected city automatically
    expect(
      _fieldWithLabel(tester, 'Latitude (N+)').controller!.text,
      '48.8500',
    );
    expect(
      _fieldWithLabel(tester, 'Longitude (E+)').controller!.text,
      '2.3500',
    );
  });

  testWidgets('the city picker search narrows the list', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('city-picker')));
    await tester.pumpAndSettle();
    expect(find.text('Tokyo (Japan)'), findsOneWidget);
    expect(find.text('Paris (France)'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Search'), 'par');
    await tester.pumpAndSettle();
    expect(find.text('Paris (France)'), findsOneWidget);
    expect(find.text('Tokyo (Japan)'), findsNothing);
  });

  testWidgets('tapping the map sets lat/lon from the tapped point', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // The map fills the InteractiveViewer; its center is lat 0, lon 0
    final map = find.byType(InteractiveViewer);
    await tester.tap(map);
    await tester.pumpAndSettle();

    final fix = container.read(locationControllerProvider).value!;
    // (0,0) is >150 km from every test city, so no snap: exact coordinates
    expect(fix.location.name, 'Map point');
    expect(fix.location.latitudeDeg, closeTo(0, 0.5));
    expect(fix.location.longitudeDeg, closeTo(0, 0.5));

    // A tap on an empty map area also fills the lat/lon input fields
    expect(
      double.parse(_fieldWithLabel(tester, 'Latitude (N+)').controller!.text),
      fix.location.latitudeDeg,
    );
    expect(
      double.parse(_fieldWithLabel(tester, 'Longitude (E+)').controller!.text),
      fix.location.longitudeDeg,
    );
  });

  testWidgets('a saved location is restored into the fields on startup', (
    tester,
  ) async {
    final settings = InMemorySettingsRepository();
    // Persisted by a previous session's setManualLocation
    settings.values['settings.manualLocation'] =
        '{"lat":-33.87,"lon":151.21,"name":"Sydney"}';
    container = ProviderContainer(
      overrides: [
        deviceLocationProviderProvider.overrideWithValue(
          _UnavailableLocationProvider(),
        ),
        settingsRepositoryProvider.overrideWithValue(settings),
        worldMapLoaderProvider.overrideWithValue(
          WorldMapLoader(
            loader: (key) async =>
                key.endsWith('world_cities.json') ? _citiesJson : _landJson,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final fix = container.read(locationControllerProvider).value!;
    expect(fix.location.name, 'Sydney');
    expect(fix.source, LocationSource.manual);

    expect(
      _fieldWithLabel(tester, 'Latitude (N+)').controller!.text,
      '-33.8700',
    );
    expect(
      _fieldWithLabel(tester, 'Longitude (E+)').controller!.text,
      '151.2100',
    );
  });

  testWidgets(
    'asset load failure shows error placeholders but keeps manual entry',
    (tester) async {
      container = ProviderContainer(
        overrides: [
          deviceLocationProviderProvider.overrideWithValue(
            _UnavailableLocationProvider(),
          ),
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
          worldMapLoaderProvider.overrideWithValue(
            WorldMapLoader(
              loader: (key) async => 'not a json', // malformed asset
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('City catalog unavailable'), findsOneWidget);
      expect(find.text('World map unavailable'), findsOneWidget);
      // Manual lat/lon entry still works without the catalog
      await tester.enterText(find.byType(TextField).first, '10');
      await tester.enterText(find.byType(TextField).last, '20');
      await tester.tap(find.text('Set'));
      await tester.pump();
      final fix = container.read(locationControllerProvider).value!;
      expect(fix.location.latitudeDeg, 10);
      expect(fix.location.longitudeDeg, 20);
    },
  );

  testWidgets('map tap near a city snaps the pickers to that city', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Tap the pixel corresponding to Tokyo (lat 35.69, lon 139.69)
    final map = find.byType(InteractiveViewer);
    final topLeft = tester.getTopLeft(map);
    final size = tester.getSize(map);
    final target =
        topLeft +
        Offset(
          (139.69 + 180) / 360 * size.width,
          (90 - 35.69) / 180 * size.height,
        );
    await tester.tapAt(target);
    await tester.pumpAndSettle();

    final fix = container.read(locationControllerProvider).value!;
    expect(fix.location.name, 'Tokyo');
    // The country picker follows the snapped city
    expect(find.text('Japan'), findsWidgets);
  });
}
