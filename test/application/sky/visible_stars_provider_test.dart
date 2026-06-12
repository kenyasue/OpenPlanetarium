import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/selection/object_picker.dart';
import 'package:open_planetarium/application/settings/appearance_settings_controller.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/application/sky/solar_system_provider.dart';
import 'package:open_planetarium/application/sky/visible_stars_provider.dart';
import 'package:open_planetarium/application/viewport/lod_policy.dart';
import 'package:open_planetarium/application/viewport/viewport_controller.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/appearance/star_appearance.dart';
import 'package:open_planetarium/domain/astro/projection.dart';
import 'package:open_planetarium/domain/models/sky_object.dart';
import 'package:open_planetarium/domain/models/solar_system.dart';
import 'package:open_planetarium/domain/models/star.dart';
import 'package:open_planetarium/domain/repositories/catalog_repository.dart';

/// Fake repository that records query arguments
class _RecordingCatalogRepository implements CatalogRepository {
  List<int>? lastTiles;
  double? lastLimit;

  @override
  Future<List<Star>> starsInTiles(
    List<int> tiles,
    double limitingMagnitude,
  ) async {
    lastTiles = tiles;
    lastLimit = limitingMagnitude;
    return const [];
  }

  @override
  Future<List<Star>> namedStars() async => const [];
}

void main() {
  group('lodPolicy', () {
    test('LOD limit deepens in steps as the FOV narrows', () {
      expect(lodLimitingMagnitude(100), 8.0);
      expect(lodLimitingMagnitude(60), 10.5);
      expect(lodLimitingMagnitude(20), 14.0);
      expect(lodLimitingMagnitude(5), 20.0);
      expect(lodLimitingMagnitude(0.5), 20.0);
    });

    test('effective limiting magnitude is the minimum of LOD limit and user setting', () {
      // By default (show up to mag 6.5) the user setting applies
      expect(effectiveLimitingMagnitude(30, const AppearanceSettings()), 6.5);

      // Urban-sky equivalent (show up to mag 2.5)
      const city = AppearanceSettings(userLimitingMagnitude: 2.5);
      expect(effectiveLimitingMagnitude(30, city), 2.5);

      // Even at a mag-20 setting, the LOD limit applies in wide FOV
      const deep = AppearanceSettings(userLimitingMagnitude: 20.0);
      expect(effectiveLimitingMagnitude(100, deep), 8.0);
      expect(effectiveLimitingMagnitude(3, deep), 20.0);
    });
  });

  group('visibleStarsProvider', () {
    test('queries the repository with viewport tiles and the effective limiting magnitude', () async {
      final repo = _RecordingCatalogRepository();
      final container = ProviderContainer(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(repo),
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(visibleStarsProvider.future);

      expect(repo.lastTiles, isNotNull);
      expect(repo.lastTiles, isNotEmpty);
      // Not all 184 all-sky tiles are requested (viewport-based)
      final index = container.read(spatialIndexProvider);
      expect(repo.lastTiles!.length, lessThan(index.tileCount));
      // Effective limiting magnitude with default settings = user setting mag 6.5
      expect(repo.lastLimit, 6.5);
    });

    test('changing the magnitude setting re-evaluates the limiting magnitude', () async {
      final repo = _RecordingCatalogRepository();
      final container = ProviderContainer(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(repo),
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(visibleStarsProvider.future);
      container
          .read(appearanceSettingsProvider.notifier)
          .setLimitingMagnitude(12.0);
      await container.read(visibleStarsProvider.future);
      // Even at a mag-12 setting, the LOD limit 8.0 applies at the default fov=70°
      expect(repo.lastLimit, 8.0);

      container.read(viewportControllerProvider.notifier).zoom(2.0); // fov=35°
      await container.read(visibleStarsProvider.future);
      // LOD limit 10.5 at fov=35° < user setting 12.0
      expect(repo.lastLimit, 10.5);
    });
  });

  group('pickObjectAtPoint', () {
    test('selects a star near the click position; outside the threshold returns null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(viewportStateProvider);
      final projection = ViewProjection(state);

      // A star placed at the view center is selected by clicking the screen center
      final centerStar = Star(
        id: 1,
        raDeg: state.center.raDeg,
        decDeg: state.center.decDeg,
        magnitude: 1.0,
        tileIndex: 0,
      );
      final screenCenter = Offset(
        state.screenSize.width / 2,
        state.screenSize.height / 2,
      );
      final picked = pickObjectAtPoint(
        stars: [centerStar],
        dsos: const [],
        solarBodies: const [],
        projection: projection,
        point: screenCenter,
      );
      expect(picked, isA<StarObject>());
      expect((picked! as StarObject).star, centerStar);

      expect(
        pickObjectAtPoint(
          stars: [centerStar],
          dsos: const [],
          solarBodies: const [],
          projection: projection,
          point: screenCenter + const Offset(100, 0),
        ),
        isNull,
      );
    });

    test('between a nearby star and planet, the brighter (lower magnitude) one wins', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(viewportStateProvider);
      final projection = ViewProjection(state);
      final screenCenter = Offset(
        state.screenSize.width / 2,
        state.screenSize.height / 2,
      );
      final nearPoint = projection.unproject(screenCenter + const Offset(3, 0));
      final faintStar = Star(
        id: 2,
        raDeg: state.center.raDeg,
        decDeg: state.center.decDeg,
        magnitude: 6.0,
        tileIndex: 0,
      );
      // Venus (representative magnitude -4) sitting 3px away takes priority
      final venus = SolarBodyPosition(
        body: SolarBodyId.venus,
        position: nearPoint,
        angularDiameterDeg: 0,
      );
      final picked = pickObjectAtPoint(
        stars: [faintStar],
        dsos: const [],
        solarBodies: [venus],
        projection: projection,
        point: screenCenter,
      );
      expect(picked, isA<SolarBodyObject>());
    });
  });
}
