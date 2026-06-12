import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/location/location_controller.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/application/time/time_controller.dart';
import 'package:open_planetarium/application/viewport/viewport_controller.dart';
import 'package:open_planetarium/data/platform/location_provider.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/astro/astro_engine.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';

/// For tests: a location provider that always fails (triggers the Tokyo fallback)
class _UnavailableLocationProvider implements DeviceLocationProvider {
  @override
  Future<GeoLocation> getCurrentLocation() async =>
      throw const LocationUnavailableException('test');
}

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      deviceLocationProviderProvider.overrideWithValue(
        _UnavailableLocationProvider(),
      ),
      settingsRepositoryProvider.overrideWithValue(
        InMemorySettingsRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ViewportController.zoom', () {
    test('FOV is clamped to 0.5°-120°', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);

      controller.zoom(0.001); // extreme zoom-out → clamped to the upper bound
      expect(container.read(viewportControllerProvider).fovDeg, kMaxFovDeg);

      controller.zoom(1e9); // extreme zoom-in → clamped to the lower bound
      expect(container.read(viewportControllerProvider).fovDeg, kMinFovDeg);
    });

    test('scaleFactor=2 halves the FOV', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);
      final before = container.read(viewportControllerProvider).fovDeg;
      controller.zoom(2.0);
      expect(
        container.read(viewportControllerProvider).fovDeg,
        closeTo(before / 2, 1e-9),
      );
    });

    test('invalid scaleFactor (zero or negative) is ignored', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);
      final before = container.read(viewportControllerProvider).fovDeg;
      controller.zoom(0);
      controller.zoom(-1);
      expect(container.read(viewportControllerProvider).fovDeg, before);
    });
  });

  group('ViewportController.pan', () {
    test('center coordinates stay within the normalized range after panning', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);
      // RA [0,360), Dec [-90,90] are maintained even after large repeated pans
      for (var i = 0; i < 50; i++) {
        controller.pan(const Offset(200, -150));
        final center = container.read(viewportControllerProvider).center;
        expect(center.raDeg, inInclusiveRange(0, 360));
        expect(center.decDeg, inInclusiveRange(-90, 90));
      }
    });

    test('dragging right moves stars right (the center moves toward the left sky)', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);
      final before = container.read(viewportControllerProvider).center;
      controller.pan(const Offset(100, 0));
      final after = container.read(viewportControllerProvider).center;
      expect(after.angularDistanceTo(before), greaterThan(0.5));
    });
  });

  group('ViewportController.centerOn / resize', () {
    test('centerOn changes the center and FOV', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);
      final target = SkyPoint(83.82, -5.39);
      controller.centerOn(target, fovDeg: 10);
      final geometry = container.read(viewportControllerProvider);
      expect(geometry.center, target);
      expect(geometry.fovDeg, 10);
    });

    test('resize with the same or empty size does not advance the generation', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);
      final before = container.read(viewportControllerProvider);
      controller.resize(before.screenSize);
      controller.resize(Size.zero);
      expect(
        container.read(viewportControllerProvider).generation,
        before.generation,
      );
    });
  });

  group('Alt/Az lock on time change', () {
    const engine = AstroEngine();

    test('advancing time keeps the view center altitude/azimuth (RA/Dec changes)', () {
      final container = _container();
      final before = container.read(viewportControllerProvider);
      final t0 = container.read(timeControllerProvider);
      const loc = GeoLocation.tokyo;
      final horBefore = engine.equatorialToHorizontal(before.center, loc, t0);

      final t1 = t0.add(const Duration(hours: 3));
      container.read(timeControllerProvider.notifier).setTime(t1);

      final after = container.read(viewportControllerProvider);
      final horAfter = engine.equatorialToHorizontal(after.center, loc, t1);
      expect(horAfter.altDeg, closeTo(horBefore.altDeg, 1e-6));
      expect(horAfter.azDeg, closeTo(horBefore.azDeg, 1e-6));
      // Confirms it is not sidereal tracking (fixed RA/Dec): rotates about 45° in 3 hours
      expect(after.center.angularDistanceTo(before.center), greaterThan(1.0));
    });

    test('Alt/Az does not drift across many time changes (playback equivalent)', () {
      final container = _container();
      final before = container.read(viewportControllerProvider);
      final t0 = container.read(timeControllerProvider);
      const loc = GeoLocation.tokyo;
      final horBefore = engine.equatorialToHorizontal(before.center, loc, t0);

      // Equivalent to 600 ticks of 100ms (1 minute × 600 = 10 hours in fine steps)
      final notifier = container.read(timeControllerProvider.notifier);
      for (var i = 0; i < 600; i++) {
        notifier.addDuration(const Duration(minutes: 1));
      }

      final t1 = container.read(timeControllerProvider);
      final after = container.read(viewportControllerProvider);
      final horAfter = engine.equatorialToHorizontal(after.center, loc, t1);
      expect(horAfter.altDeg, closeTo(horBefore.altDeg, 1e-3));
      expect(horAfter.azDeg, closeTo(horBefore.azDeg, 1e-3));
    });
  });

  group('viewportStateProvider', () {
    test('viewportId increases monotonically with each interaction', () {
      final container = _container();
      final controller = container.read(viewportControllerProvider.notifier);

      final id0 = container.read(viewportStateProvider).viewportId;
      controller.zoom(1.5);
      final id1 = container.read(viewportStateProvider).viewportId;
      controller.pan(const Offset(10, 10));
      final id2 = container.read(viewportStateProvider).viewportId;

      expect(id1, greaterThan(id0));
      expect(id2, greaterThan(id1));
    });

    test('continues with the default (Tokyo) when location acquisition fails', () async {
      final container = _container();
      final fix = await container.read(locationControllerProvider.future);
      expect(fix.location, GeoLocation.tokyo);
      expect(fix.source, LocationSource.fallback);
    });
  });
}
