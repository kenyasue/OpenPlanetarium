import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/database/drift_equipment_repository.dart';
import 'package:open_planetarium/data/database/equipment_database.dart';
import 'package:open_planetarium/domain/models/equipment.dart';

void main() {
  late EquipmentDatabase db;
  late DriftEquipmentRepository repo;

  setUp(() {
    db = EquipmentDatabase(NativeDatabase.memory());
    repo = DriftEquipmentRepository(db);
  });

  tearDown(() => db.close());

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

  group('DriftEquipmentRepository', () {
    test('telescope CRUD (save → fetch → update → delete)', () async {
      await repo.saveTelescope(telescope);
      var list = await repo.telescopes();
      expect(list.single.name, 'RASA 8');
      expect(list.single.type, TelescopeType.rasa);
      expect(list.single.fRatio, closeTo(400 / 203, 1e-9));

      await repo.saveTelescope(
        const Telescope(
          id: 't1',
          name: 'RASA 8 Mk2',
          type: TelescopeType.rasa,
          apertureMm: 203,
          focalLengthMm: 400,
        ),
      );
      list = await repo.telescopes();
      expect(list.single.name, 'RASA 8 Mk2'); // upsert

      await repo.deleteTelescope('t1');
      expect(await repo.telescopes(), isEmpty);
    });

    test('camera, eyepiece, and optical modifier CRUD', () async {
      await repo.saveCamera(camera);
      expect((await repo.cameras()).single.pixelSizeUm, 4.63);

      await repo.saveEyepiece(
        const Eyepiece(
          id: 'e1',
          name: '25mm',
          focalLengthMm: 25,
          apparentFovDeg: 50,
        ),
      );
      expect((await repo.eyepieces()).single.apparentFovDeg, 50);

      await repo.saveModifier(
        const OpticalModifier(
          id: 'm1',
          name: '2x Barlow',
          kind: ModifierKind.barlow,
          factor: 2.0,
        ),
      );
      expect((await repo.modifiers()).single.kind, ModifierKind.barlow);

      await repo.deleteCamera('c1');
      await repo.deleteEyepiece('e1');
      await repo.deleteModifier('m1');
      expect(await repo.cameras(), isEmpty);
      expect(await repo.eyepieces(), isEmpty);
      expect(await repo.modifiers(), isEmpty);
    });

    test('equipment set save and restore (camera mode, color)', () async {
      await repo.saveTelescope(telescope);
      await repo.saveCamera(camera);
      await repo.saveEquipmentSet(
        const EquipmentSet(
          id: 's1',
          name: 'Deep Sky Setup',
          telescopeId: 't1',
          cameraId: 'c1',
          frameColorArgb: 0xFFE8A95B,
        ),
      );
      final set = (await repo.equipmentSets()).single;
      expect(set.name, 'Deep Sky Setup');
      expect(set.isCameraMode, isTrue);
      expect(set.frameColorArgb, 0xFFE8A95B);
      expect(set.eyepieceId, isNull);
    });
  });
}
