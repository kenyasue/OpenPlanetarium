import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/fov/active_fov_controller.dart';
import 'package:open_planetarium/application/fov/equipment_providers.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/data/database/equipment_database.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/models/equipment.dart';

void main() {
  late EquipmentDatabase db;
  late ProviderContainer container;

  const telescope = Telescope(
    id: 't1',
    name: 'RASA 8',
    type: TelescopeType.rasa,
    apertureMm: 203,
    focalLengthMm: 400,
  );
  const camera = CameraDevice(
    id: 'c1',
    name: 'ASI294MC Pro',
    sensorWidthMm: 19.1,
    sensorHeightMm: 13.0,
    pixelSizeUm: 4.63,
    resolutionX: 4144,
    resolutionY: 2822,
  );
  const eyepiece = Eyepiece(
    id: 'e1',
    name: '25mm',
    focalLengthMm: 25,
    apparentFovDeg: 50,
  );
  const barlow = OpticalModifier(
    id: 'm1',
    name: '2x',
    kind: ModifierKind.barlow,
    factor: 2.0,
  );

  setUp(() async {
    db = EquipmentDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        equipmentDatabaseProvider.overrideWith((ref) {
          ref.onDispose(db.close);
          return db;
        }),
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final repo = container.read(equipmentRepositoryProvider);
    await repo.saveTelescope(telescope);
    await repo.saveCamera(camera);
    await repo.saveEyepiece(eyepiece);
    await repo.saveModifier(barlow);
  });

  Future<void> loadAll() async {
    // Reload the cached lists, then wait for loading to finish
    container
      ..invalidate(telescopesProvider)
      ..invalidate(camerasProvider)
      ..invalidate(eyepiecesProvider)
      ..invalidate(modifiersProvider)
      ..invalidate(equipmentSetsProvider);
    await container.read(telescopesProvider.future);
    await container.read(camerasProvider.future);
    await container.read(eyepiecesProvider.future);
    await container.read(modifiersProvider.future);
    await container.read(equipmentSetsProvider.future);
  }

  group('fovFrameProvider', () {
    test('a rectangular frame is derived from a camera set', () async {
      await container
          .read(equipmentRepositoryProvider)
          .saveEquipmentSet(
            const EquipmentSet(
              id: 's1',
              name: 'Deep Sky',
              telescopeId: 't1',
              cameraId: 'c1',
            ),
          );
      await loadAll();
      container.read(activeFovProvider.notifier).setActiveSet('s1');

      final frame = container.read(fovFrameProvider);
      expect(frame, isNotNull);
      expect(frame!.isCircle, isFalse);
      expect(frame.widthDeg, closeTo(2.7352, 0.03));
      expect(frame.heightDeg, closeTo(1.8619, 0.02));
      expect(frame.label, contains('Deep Sky'));
    });

    test('a circular frame is derived from an eyepiece set plus Barlow', () async {
      await container
          .read(equipmentRepositoryProvider)
          .saveEquipmentSet(
            const EquipmentSet(
              id: 's2',
              name: 'Visual',
              telescopeId: 't1',
              eyepieceId: 'e1',
              modifierId: 'm1',
            ),
          );
      await loadAll();
      container.read(activeFovProvider.notifier).setActiveSet('s2');

      final frame = container.read(fovFrameProvider);
      expect(frame, isNotNull);
      expect(frame!.isCircle, isTrue);
      // 400mm×2 / 25mm = 32x → true FOV 50/32 = 1.5625°
      expect(frame.widthDeg, closeTo(1.5625, 0.016));
    });

    test('returns null when no set is selected or a reference is broken (telescope deleted)', () async {
      await loadAll();
      expect(container.read(fovFrameProvider), isNull);

      // Deleting the telescope after selecting the set safely yields null
      await container
          .read(equipmentRepositoryProvider)
          .saveEquipmentSet(
            const EquipmentSet(
              id: 's3',
              name: 'Orphan',
              telescopeId: 't1',
              cameraId: 'c1',
            ),
          );
      await loadAll();
      container.read(activeFovProvider.notifier).setActiveSet('s3');
      expect(container.read(fovFrameProvider), isNotNull);

      await container.read(equipmentRepositoryProvider).deleteTelescope('t1');
      container.invalidate(telescopesProvider);
      await container.read(telescopesProvider.future);
      expect(container.read(fovFrameProvider), isNull);
    });
  });
}
