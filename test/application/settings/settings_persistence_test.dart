import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/location/location_controller.dart';
import 'package:open_planetarium/application/settings/appearance_settings_controller.dart';
import 'package:open_planetarium/application/settings/constellation_settings_controller.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/data/platform/location_provider.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/constellation_data.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';

class _UnavailableLocationProvider implements DeviceLocationProvider {
  @override
  Future<GeoLocation> getCurrentLocation() async =>
      throw const LocationUnavailableException('test');
}

void main() {
  group('settings persistence', () {
    test('appearance settings are saved and restored in a new container', () async {
      final repo = InMemorySettingsRepository();

      final container1 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container1.dispose);
      container1
          .read(appearanceSettingsProvider.notifier)
          .setLimitingMagnitude(12.0);
      container1.read(appearanceSettingsProvider.notifier).setSizeScale(1.5);
      await Future<void>.delayed(Duration.zero); // wait for the save to finish

      final container2 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container2.dispose);
      container2.read(appearanceSettingsProvider); // trigger build
      await Future<void>.delayed(Duration.zero); // wait for restoration to finish

      final restored = container2.read(appearanceSettingsProvider);
      expect(restored.userLimitingMagnitude, 12.0);
      expect(restored.sizeScale, 1.5);
    });

    test('constellation settings (including language) are saved and restored', () async {
      final repo = InMemorySettingsRepository();

      final container1 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container1.dispose);
      final controller = container1.read(
        constellationSettingsProvider.notifier,
      );
      controller.setLanguage(NameLanguage.latin);
      controller.setShowBoundaries(true);
      await Future<void>.delayed(Duration.zero);

      final container2 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container2.dispose);
      container2.read(constellationSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      final restored = container2.read(constellationSettingsProvider);
      expect(restored.language, NameLanguage.latin);
      expect(restored.showBoundaries, isTrue);
    });

    test('manual observing site is saved and restored in a new container (takes priority over GPS)', () async {
      final repo = InMemorySettingsRepository();
      const osaka = GeoLocation(
        latitudeDeg: 34.6937,
        longitudeDeg: 135.5023,
        name: 'Osaka',
      );

      final container1 = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          deviceLocationProviderProvider.overrideWithValue(
            _UnavailableLocationProvider(),
          ),
        ],
      );
      addTearDown(container1.dispose);
      await container1.read(locationControllerProvider.future);
      container1
          .read(locationControllerProvider.notifier)
          .setManualLocation(osaka);
      await Future<void>.delayed(Duration.zero);

      final container2 = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          deviceLocationProviderProvider.overrideWithValue(
            _UnavailableLocationProvider(),
          ),
        ],
      );
      addTearDown(container2.dispose);
      final restored = await container2.read(locationControllerProvider.future);
      expect(restored.source, LocationSource.manual);
      expect(restored.location.latitudeDeg, closeTo(34.6937, 1e-6));
      expect(restored.location.name, 'Osaka');
    });

    test('legacy JSON with only the bortle key restores with the default limiting magnitude', () async {
      final repo = InMemorySettingsRepository();
      // Saved value from an old version (has bortle, lacks userLimitingMagnitude)
      repo.values['settings.appearance'] =
          '{"sizeScale":1.5,"glowIntensity":1.0,"saturation":1.0,'
          '"bortle":9,"showMilkyWay":true}';

      final container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.read(appearanceSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      final restored = container.read(appearanceSettingsProvider);
      // The bortle key is discarded and the limiting magnitude falls back to the default
      expect(restored.userLimitingMagnitude, 6.5);
      expect(restored.sizeScale, 1.5); // other keys are restored
    });

    test('corrupted saved values fall back to defaults', () async {
      final repo = InMemorySettingsRepository();
      repo.values['settings.appearance'] = '{broken json';

      final container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.read(appearanceSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(appearanceSettingsProvider).userLimitingMagnitude,
        6.5, // default value
      );
    });
  });
}
