import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'equipment_database.g.dart';

@DataClassName('TelescopeRow')
class Telescopes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get apertureMm => real()();
  RealColumn get focalLengthMm => real()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CameraRow')
class Cameras extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get sensorWidthMm => real()();
  RealColumn get sensorHeightMm => real()();
  RealColumn get pixelSizeUm => real()();
  IntColumn get resolutionX => integer()();
  IntColumn get resolutionY => integer()();
  TextColumn get sensorType => text()();
  BoolColumn get isColor => boolean()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('EyepieceRow')
class Eyepieces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get focalLengthMm => real()();
  RealColumn get apparentFovDeg => real()();
  TextColumn get barrelSize => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ModifierRow')
class Modifiers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  RealColumn get factor => real()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('EquipmentSetRow')
class EquipmentSets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get telescopeId => text()();
  TextColumn get cameraId => text().nullable()();
  TextColumn get eyepieceId => text().nullable()();
  TextColumn get modifierId => text().nullable()();
  IntColumn get frameColorArgb => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Equipment DB (equipment.db; see docs/architecture.md, data persistence strategy).
@DriftDatabase(
  tables: [Telescopes, Cameras, Eyepieces, Modifiers, EquipmentSets],
)
class EquipmentDatabase extends _$EquipmentDatabase {
  EquipmentDatabase([QueryExecutor? executor])
    : super(executor ?? _openDefault());

  static QueryExecutor _openDefault() =>
      driftDatabase(name: 'equipment', native: const DriftNativeOptions());

  @override
  int get schemaVersion => 1;
}
