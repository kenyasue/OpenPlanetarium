import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/application/settings/solar_system_settings_controller.dart';
import 'package:open_planetarium/application/sky/minor_body_provider.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/models/minor_body.dart';
import 'package:open_planetarium/domain/repositories/minor_body_repository.dart';

/// Test data: a Ceres-like body (always within mag 12), a faint asteroid, and a comet
const _ceres = MinorBody(
  id: 'ceres',
  name: '1 Ceres',
  nameJa: 'ケレス',
  kind: MinorBodyKind.asteroid,
  elements: OrbitalElements(
    epochJd: 2461200.5,
    aAu: 2.766,
    e: 0.0797,
    iDeg: 10.59,
    nodeDeg: 80.25,
    argPeriDeg: 73.29,
    meanAnomalyDeg: 274.42,
  ),
  mag1: 3.34,
  mag2: 0,
);

const _faintAsteroid = MinorBody(
  id: 'faint',
  name: '99999 Faint',
  kind: MinorBodyKind.asteroid,
  elements: OrbitalElements(
    epochJd: 2461200.5,
    aAu: 3.0,
    e: 0.1,
    iDeg: 5,
    nodeDeg: 0,
    argPeriDeg: 0,
    meanAnomalyDeg: 0,
  ),
  mag1: 14.0, // always fainter than mag 12 because r·Δ>1
  mag2: 0,
);

const _brightComet = MinorBody(
  id: 'comet',
  name: '2P/Encke',
  kind: MinorBodyKind.comet,
  elements: OrbitalElements(
    epochJd: 2461200.5,
    aAu: 2.22,
    e: 0.848,
    iDeg: 11.8,
    nodeDeg: 334.6,
    argPeriDeg: 187.0,
    meanAnomalyDeg: 0,
  ),
  mag1: -5.0, // set extremely bright so it is always visible
  mag2: 6.0,
);

class _FixedMinorBodyRepository implements MinorBodyRepository {
  @override
  Future<List<MinorBody>> loadAll() async => const [
    _ceres,
    _faintAsteroid,
    _brightComet,
  ];
}

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        minorBodyRepositoryProvider.overrideWithValue(
          _FixedMinorBodyRepository(),
        ),
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('visibleMinorBodiesProvider', () {
    test('returns only minor bodies within the limiting magnitude, with position and magnitude', () async {
      final container = makeContainer();
      await container.read(minorBodyListProvider.future);

      final visible = container.read(visibleMinorBodiesProvider);
      final ids = visible.map((v) => v.body.id).toSet();
      expect(ids, contains('ceres'));
      expect(ids, contains('comet'));
      expect(ids, isNot(contains('faint'))); // fainter than mag 12 is excluded

      final ceres = visible.firstWhere((v) => v.body.id == 'ceres');
      expect(ceres.position.raDeg, inInclusiveRange(0, 360));
      expect(ceres.position.decDeg, inInclusiveRange(-90, 90));
      expect(ceres.magnitude, inInclusiveRange(5.0, 12.0)); // typical range for Ceres
    });

    test('asteroid and comet toggles work independently', () async {
      final container = makeContainer();
      await container.read(minorBodyListProvider.future);
      final controller = container.read(solarSystemSettingsProvider.notifier);

      controller.setShowAsteroids(false);
      expect(container.read(visibleMinorBodiesProvider).map((v) => v.body.id), [
        'comet',
      ]);

      controller.setShowComets(false);
      expect(container.read(visibleMinorBodiesProvider), isEmpty);

      controller.setShowAsteroids(true);
      expect(container.read(visibleMinorBodiesProvider).map((v) => v.body.id), [
        'ceres',
      ]);
    });

    test('solar system settings are persisted and restored', () async {
      final repo = InMemorySettingsRepository();
      final container1 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container1.dispose);
      container1
          .read(solarSystemSettingsProvider.notifier)
          .setShowComets(false);
      await Future<void>.delayed(Duration.zero);

      final container2 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container2.dispose);
      container2.read(solarSystemSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      final restored = container2.read(solarSystemSettingsProvider);
      expect(restored.showComets, isFalse);
      expect(restored.showPlanets, isTrue);
      expect(restored.showAsteroids, isTrue);
    });
  });
}
