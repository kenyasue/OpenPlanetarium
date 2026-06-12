import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/drift_equipment_repository.dart';
import '../../data/database/equipment_database.dart';
import '../../domain/models/equipment.dart';
import '../../domain/repositories/equipment_repository.dart';

/// Equipment DB (equipment.db, one instance app-wide)
final equipmentDatabaseProvider = Provider<EquipmentDatabase>((ref) {
  final db = EquipmentDatabase();
  ref.onDispose(db.close);
  return db;
});

final equipmentRepositoryProvider = Provider<EquipmentRepository>(
  (ref) => DriftEquipmentRepository(ref.watch(equipmentDatabaseProvider)),
);

final telescopesProvider = FutureProvider<List<Telescope>>(
  (ref) => ref.watch(equipmentRepositoryProvider).telescopes(),
);

final camerasProvider = FutureProvider<List<CameraDevice>>(
  (ref) => ref.watch(equipmentRepositoryProvider).cameras(),
);

final eyepiecesProvider = FutureProvider<List<Eyepiece>>(
  (ref) => ref.watch(equipmentRepositoryProvider).eyepieces(),
);

final modifiersProvider = FutureProvider<List<OpticalModifier>>(
  (ref) => ref.watch(equipmentRepositoryProvider).modifiers(),
);

final equipmentSetsProvider = FutureProvider<List<EquipmentSet>>(
  (ref) => ref.watch(equipmentRepositoryProvider).equipmentSets(),
);
