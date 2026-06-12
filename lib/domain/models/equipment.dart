/// Equipment profiles (F12, per docs/functional-design.md).
library;

/// Telescope type
enum TelescopeType {
  refractor('Refractor'),
  reflector('Reflector'),
  sct('Schmidt-Cassegrain'),
  rc('Ritchey-Chretien'),
  rasa('RASA'),
  newtonian('Newtonian'),
  other('Other');

  const TelescopeType(this.labelJa);

  final String labelJa;
}

class Telescope {
  const Telescope({
    required this.id,
    required this.name,
    required this.type,
    required this.apertureMm,
    required this.focalLengthMm,
    this.note,
  });

  final String id;
  final String name;
  final TelescopeType type;

  /// Aperture [mm]
  final double apertureMm;

  /// Focal length [mm]
  final double focalLengthMm;

  final String? note;

  /// Focal ratio
  double get fRatio => focalLengthMm / apertureMm;
}

/// Sensor type
enum SensorType { cmos, ccd, dslr, mirrorless, planetary }

class CameraDevice {
  const CameraDevice({
    required this.id,
    required this.name,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.pixelSizeUm,
    required this.resolutionX,
    required this.resolutionY,
    this.sensorType = SensorType.cmos,
    this.isColor = true,
    this.note,
  });

  final String id;
  final String name;
  final double sensorWidthMm;
  final double sensorHeightMm;

  /// Pixel size [µm]
  final double pixelSizeUm;

  final int resolutionX;
  final int resolutionY;
  final SensorType sensorType;
  final bool isColor;
  final String? note;
}

/// Barrel diameter
enum BarrelSize { inch125, inch2 }

class Eyepiece {
  const Eyepiece({
    required this.id,
    required this.name,
    required this.focalLengthMm,
    required this.apparentFovDeg,
    this.barrelSize = BarrelSize.inch125,
    this.note,
  });

  final String id;
  final String name;
  final double focalLengthMm;

  /// Apparent field of view (AFOV) [deg]
  final double apparentFovDeg;

  final BarrelSize barrelSize;
  final String? note;
}

/// Corrective lens kind
enum ModifierKind {
  barlow('Barlow'),
  reducer('Reducer');

  const ModifierKind(this.labelJa);

  final String labelJa;
}

/// Barlow lens / reducer
class OpticalModifier {
  const OpticalModifier({
    required this.id,
    required this.name,
    required this.kind,
    required this.factor,
    this.note,
  });

  final String id;
  final String name;
  final ModifierKind kind;

  /// Magnification factor (Barlow: >1, reducer: <1)
  final double factor;

  final String? note;
}

/// Frequently used equipment combination (F12).
///
/// Camera FOV mode (cameraId) and eyepiece FOV mode (eyepieceId) are mutually exclusive.
class EquipmentSet {
  const EquipmentSet({
    required this.id,
    required this.name,
    required this.telescopeId,
    this.cameraId,
    this.eyepieceId,
    this.modifierId,
    this.frameColorArgb = 0xFF53C8E8,
    this.note,
  }) : assert(
         (cameraId != null) ^ (eyepieceId != null),
         'Specify either a camera or an eyepiece, not both',
       );

  final String id;
  final String name;
  final String telescopeId;
  final String? cameraId;
  final String? eyepieceId;
  final String? modifierId;

  /// Display color of the FOV frame (ARGB)
  final int frameColorArgb;

  final String? note;

  bool get isCameraMode => cameraId != null;
}
