import '../models/equipment.dart';

/// Persistence interface for equipment profiles (implemented in the data layer).
///
/// All lists are returned in registration order. On deletion, the caller
/// (application layer) is responsible for checking consistency of equipment
/// sets that reference the item.
abstract class EquipmentRepository {
  Future<List<Telescope>> telescopes();
  Future<void> saveTelescope(Telescope telescope);
  Future<void> deleteTelescope(String id);

  Future<List<CameraDevice>> cameras();
  Future<void> saveCamera(CameraDevice camera);
  Future<void> deleteCamera(String id);

  Future<List<Eyepiece>> eyepieces();
  Future<void> saveEyepiece(Eyepiece eyepiece);
  Future<void> deleteEyepiece(String id);

  Future<List<OpticalModifier>> modifiers();
  Future<void> saveModifier(OpticalModifier modifier);
  Future<void> deleteModifier(String id);

  Future<List<EquipmentSet>> equipmentSets();
  Future<void> saveEquipmentSet(EquipmentSet set);
  Future<void> deleteEquipmentSet(String id);
}
