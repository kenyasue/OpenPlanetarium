import 'package:drift/drift.dart';

import '../../domain/models/equipment.dart' as domain;
import '../../domain/repositories/equipment_repository.dart';
import 'equipment_database.dart';

/// Drift-based persistence implementation for equipment profiles.
class DriftEquipmentRepository implements EquipmentRepository {
  DriftEquipmentRepository(this._db);

  final EquipmentDatabase _db;

  @override
  Future<List<domain.Telescope>> telescopes() async {
    final rows = await _db.select(_db.telescopes).get();
    return [
      for (final row in rows)
        domain.Telescope(
          id: row.id,
          name: row.name,
          type:
              domain.TelescopeType.values.asNameMap()[row.type] ??
              domain.TelescopeType.other,
          apertureMm: row.apertureMm,
          focalLengthMm: row.focalLengthMm,
          note: row.note,
        ),
    ];
  }

  @override
  Future<void> saveTelescope(domain.Telescope telescope) {
    return _db
        .into(_db.telescopes)
        .insertOnConflictUpdate(
          TelescopesCompanion.insert(
            id: telescope.id,
            name: telescope.name,
            type: telescope.type.name,
            apertureMm: telescope.apertureMm,
            focalLengthMm: telescope.focalLengthMm,
            note: Value(telescope.note),
          ),
        );
  }

  @override
  Future<void> deleteTelescope(String id) =>
      (_db.delete(_db.telescopes)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<domain.CameraDevice>> cameras() async {
    final rows = await _db.select(_db.cameras).get();
    return [
      for (final row in rows)
        domain.CameraDevice(
          id: row.id,
          name: row.name,
          sensorWidthMm: row.sensorWidthMm,
          sensorHeightMm: row.sensorHeightMm,
          pixelSizeUm: row.pixelSizeUm,
          resolutionX: row.resolutionX,
          resolutionY: row.resolutionY,
          sensorType:
              domain.SensorType.values.asNameMap()[row.sensorType] ??
              domain.SensorType.cmos,
          isColor: row.isColor,
          note: row.note,
        ),
    ];
  }

  @override
  Future<void> saveCamera(domain.CameraDevice camera) {
    return _db
        .into(_db.cameras)
        .insertOnConflictUpdate(
          CamerasCompanion.insert(
            id: camera.id,
            name: camera.name,
            sensorWidthMm: camera.sensorWidthMm,
            sensorHeightMm: camera.sensorHeightMm,
            pixelSizeUm: camera.pixelSizeUm,
            resolutionX: camera.resolutionX,
            resolutionY: camera.resolutionY,
            sensorType: camera.sensorType.name,
            isColor: camera.isColor,
            note: Value(camera.note),
          ),
        );
  }

  @override
  Future<void> deleteCamera(String id) =>
      (_db.delete(_db.cameras)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<domain.Eyepiece>> eyepieces() async {
    final rows = await _db.select(_db.eyepieces).get();
    return [
      for (final row in rows)
        domain.Eyepiece(
          id: row.id,
          name: row.name,
          focalLengthMm: row.focalLengthMm,
          apparentFovDeg: row.apparentFovDeg,
          barrelSize:
              domain.BarrelSize.values.asNameMap()[row.barrelSize] ??
              domain.BarrelSize.inch125,
          note: row.note,
        ),
    ];
  }

  @override
  Future<void> saveEyepiece(domain.Eyepiece eyepiece) {
    return _db
        .into(_db.eyepieces)
        .insertOnConflictUpdate(
          EyepiecesCompanion.insert(
            id: eyepiece.id,
            name: eyepiece.name,
            focalLengthMm: eyepiece.focalLengthMm,
            apparentFovDeg: eyepiece.apparentFovDeg,
            barrelSize: eyepiece.barrelSize.name,
            note: Value(eyepiece.note),
          ),
        );
  }

  @override
  Future<void> deleteEyepiece(String id) =>
      (_db.delete(_db.eyepieces)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<domain.OpticalModifier>> modifiers() async {
    final rows = await _db.select(_db.modifiers).get();
    return [
      for (final row in rows)
        domain.OpticalModifier(
          id: row.id,
          name: row.name,
          kind:
              domain.ModifierKind.values.asNameMap()[row.kind] ??
              domain.ModifierKind.barlow,
          factor: row.factor,
          note: row.note,
        ),
    ];
  }

  @override
  Future<void> saveModifier(domain.OpticalModifier modifier) {
    return _db
        .into(_db.modifiers)
        .insertOnConflictUpdate(
          ModifiersCompanion.insert(
            id: modifier.id,
            name: modifier.name,
            kind: modifier.kind.name,
            factor: modifier.factor,
            note: Value(modifier.note),
          ),
        );
  }

  @override
  Future<void> deleteModifier(String id) =>
      (_db.delete(_db.modifiers)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<domain.EquipmentSet>> equipmentSets() async {
    final rows = await _db.select(_db.equipmentSets).get();
    return [
      for (final row in rows)
        domain.EquipmentSet(
          id: row.id,
          name: row.name,
          telescopeId: row.telescopeId,
          cameraId: row.cameraId,
          eyepieceId: row.eyepieceId,
          modifierId: row.modifierId,
          frameColorArgb: row.frameColorArgb,
          note: row.note,
        ),
    ];
  }

  @override
  Future<void> saveEquipmentSet(domain.EquipmentSet set) {
    return _db
        .into(_db.equipmentSets)
        .insertOnConflictUpdate(
          EquipmentSetsCompanion.insert(
            id: set.id,
            name: set.name,
            telescopeId: set.telescopeId,
            cameraId: Value(set.cameraId),
            eyepieceId: Value(set.eyepieceId),
            modifierId: Value(set.modifierId),
            frameColorArgb: set.frameColorArgb,
            note: Value(set.note),
          ),
        );
  }

  @override
  Future<void> deleteEquipmentSet(String id) =>
      (_db.delete(_db.equipmentSets)..where((t) => t.id.equals(id))).go();
}
