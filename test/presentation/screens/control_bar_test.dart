import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/app.dart';
import 'package:open_planetarium/application/location/location_controller.dart';
import 'package:open_planetarium/application/settings/appearance_settings_controller.dart';
import 'package:open_planetarium/application/settings/dso_settings_controller.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/application/settings/solar_system_settings_controller.dart';
import 'package:open_planetarium/data/platform/location_provider.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/deep_sky_object.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/presentation/screens/sky/widgets/coordinate_display.dart';

class _UnavailableLocationProvider implements DeviceLocationProvider {
  @override
  Future<GeoLocation> getCurrentLocation() async =>
      throw const LocationUnavailableException('test');
}

Widget _app() {
  return ProviderScope(
    overrides: [
      deviceLocationProviderProvider.overrideWithValue(
        _UnavailableLocationProvider(),
      ),
      settingsRepositoryProvider.overrideWithValue(
        InMemorySettingsRepository(),
      ),
    ],
    child: const PlanetariumApp(),
  );
}

void main() {
  Future<void> pumpDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('bottom bar has 5 settings icons, slider, and Now button', (
    tester,
  ) async {
    await pumpDesktop(tester);

    expect(
      find.byIcon(Icons.auto_awesome_outlined),
      findsOneWidget,
    ); // Celestial settings
    expect(find.byIcon(Icons.edit_calendar_outlined), findsOneWidget); // Time
    expect(
      find.byIcon(Icons.place_outlined),
      findsOneWidget,
    ); // Observing location
    expect(find.byIcon(Icons.crop_free), findsOneWidget); // FOV
    expect(find.byIcon(Icons.build_outlined), findsOneWidget); // Equipment
    expect(find.byType(Slider), findsOneWidget); // Time slider (kept)
    expect(find.text('Now'), findsOneWidget);

    // Always-on coordinate display at top right (AltAz + RA/Dec)
    expect(find.byType(CoordinateDisplay), findsOneWidget);
    expect(find.textContaining('Alt '), findsWidgets);
    expect(find.textContaining('RA '), findsWidgets);
  });

  testWidgets('celestial settings dialog opens with 5 tabs', (tester) async {
    await pumpDesktop(tester);

    await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Celestial Settings'), findsOneWidget);
    for (final tab in [
      'DSO',
      'Solar System',
      'Survey',
      'Stars',
      'Constellations',
    ]) {
      expect(find.text(tab), findsOneWidget, reason: tab);
    }

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog toggles on the DSO tab update the settings', (
    tester,
  ) async {
    await pumpDesktop(tester);

    await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(AlertDialog));
    final container = ProviderScope.containerOf(element, listen: false);
    expect(
      container.read(dsoSettingsProvider).isEnabled(DsoCatalog.sh2),
      isFalse,
    );

    await tester.tap(find.textContaining('Sh2 (HII regions'));
    await tester.pumpAndSettle();
    expect(
      container.read(dsoSettingsProvider).isEnabled(DsoCatalog.sh2),
      isTrue,
    );

    // DSO limiting magnitude slider (dragging left lowers the magnitude)
    final dsoSlider = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Slider),
    );
    await tester.ensureVisible(dsoSlider);
    await tester.pumpAndSettle();
    await tester.drag(dsoSlider, const Offset(-120, 0));
    await tester.pumpAndSettle();
    expect(
      container.read(dsoSettingsProvider).limitingMagnitude,
      lessThan(20.0),
    );

    // Label visibility toggle
    expect(container.read(dsoSettingsProvider).showLabels, isTrue);
    await tester.ensureVisible(find.text('Show object name labels'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show object name labels'));
    await tester.pumpAndSettle();
    expect(container.read(dsoSettingsProvider).showLabels, isFalse);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'planet/asteroid/comet toggles on the Solar System tab update the settings',
    (tester) async {
      await pumpDesktop(tester);

      await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solar System'));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(AlertDialog));
      final container = ProviderScope.containerOf(element, listen: false);
      expect(container.read(solarSystemSettingsProvider).showComets, isTrue);

      await tester.tap(find.text('Comets'));
      await tester.pumpAndSettle();
      expect(container.read(solarSystemSettingsProvider).showComets, isFalse);

      await tester.tap(find.text('Asteroids'));
      await tester.pumpAndSettle();
      expect(
        container.read(solarSystemSettingsProvider).showAsteroids,
        isFalse,
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Stars tab can change limiting magnitude and Milky Way', (
    tester,
  ) async {
    await pumpDesktop(tester);

    await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stars'));
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(AlertDialog));
    final container = ProviderScope.containerOf(element, listen: false);

    // Limiting magnitude slider
    final dialogSlider = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Slider),
    );
    await tester.drag(dialogSlider, const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(
      container.read(appearanceSettingsProvider).userLimitingMagnitude,
      greaterThan(6.5),
    );

    // Milky Way toggle
    expect(container.read(appearanceSettingsProvider).showMilkyWay, isTrue);
    await tester.tap(find.text('Milky Way'));
    await tester.pumpAndSettle();
    expect(container.read(appearanceSettingsProvider).showMilkyWay, isFalse);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Survey and Constellations tabs can be opened', (tester) async {
    await pumpDesktop(tester);

    await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Survey'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Survey Data'), findsWidgets);

    await tester.tap(find.text('Constellations'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Constellation'), findsWidgets);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('time settings dialog opens with date and time buttons', (
    tester,
  ) async {
    await pumpDesktop(tester);

    await tester.tap(find.byIcon(Icons.edit_calendar_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Time Settings'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    expect(find.text('Reset to Now'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'mobile width shows all controls across multiple rows (no horizontal scrolling)',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 100));

      // All 5 icons + slider + Now button are shown without overflow
      expect(tester.takeException(), isNull);
      for (final icon in [
        Icons.auto_awesome_outlined,
        Icons.edit_calendar_outlined,
        Icons.place_outlined,
        Icons.crop_free,
        Icons.build_outlined,
      ]) {
        expect(find.byIcon(icon), findsOneWidget);
      }
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Now'), findsOneWidget);
      expect(find.byType(CoordinateDisplay), findsOneWidget);

      // The celestial settings dialog can also be opened and closed at mobile width
      await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('observing location and FOV dialogs can be opened and closed', (
    tester,
  ) async {
    await pumpDesktop(tester);

    for (final (icon, title) in [
      (Icons.place_outlined, 'Observing Location'),
      (Icons.crop_free, 'FOV Simulator'),
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget, reason: title);
      // The title may duplicate an internal section heading, so assert one or more
      expect(find.text(title), findsWidgets, reason: title);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: title);
    }
  });
}
