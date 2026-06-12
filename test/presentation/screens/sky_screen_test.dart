import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/app.dart';
import 'package:open_planetarium/application/location/location_controller.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/data/platform/location_provider.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/presentation/screens/sky/desktop_layout.dart';
import 'package:open_planetarium/presentation/screens/sky/mobile_layout.dart';
import 'package:open_planetarium/presentation/screens/sky/sky_canvas.dart';

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
  testWidgets('desktop width shows DesktopLayout', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DesktopLayout), findsOneWidget);
    expect(find.byType(SkyCanvas), findsOneWidget);
  });

  testWidgets('mobile width shows MobileLayout', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MobileLayout), findsOneWidget);
    expect(find.byType(SkyCanvas), findsOneWidget);
  });

  testWidgets('the Now button is shown', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Now'), findsOneWidget);
  });
}
