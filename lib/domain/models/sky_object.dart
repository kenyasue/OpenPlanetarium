import 'deep_sky_object.dart';
import 'solar_system.dart';
import 'star.dart';

/// Unified type for selectable/searchable celestial objects (star / deep-sky object / solar system body).
///
/// Position resolution differs by kind (stars and DSOs have fixed RA/Dec,
/// solar system bodies are time-dependent via EphemerisEngine), so no
/// coordinates are held here.
sealed class SkyObject {
  const SkyObject();

  String get displayName;

  /// Type label ('Star', 'Galaxy', 'Planet', etc.)
  String get typeLabel;

  double? get magnitude;

  /// Identity key (for comparing selection state)
  String get key;
}

class StarObject extends SkyObject {
  const StarObject(this.star);

  final Star star;

  @override
  String get displayName => star.displayName;

  @override
  String get typeLabel => 'Star';

  @override
  double? get magnitude => star.magnitude;

  @override
  String get key => 'star:${star.id}';
}

class DsoObject extends SkyObject {
  const DsoObject(this.dso);

  final DeepSkyObject dso;

  @override
  String get displayName => dso.displayName;

  @override
  String get typeLabel => dso.objectType.labelJa;

  @override
  double? get magnitude => dso.magnitude;

  @override
  String get key => 'dso:${dso.id}';
}

class SolarBodyObject extends SkyObject {
  const SolarBodyObject(this.body);

  final SolarBodyId body;

  @override
  String get displayName => body.nameJa;

  @override
  String get typeLabel => switch (body) {
    SolarBodyId.sun => 'Star (Sun)',
    SolarBodyId.moon => 'Satellite',
    _ => 'Planet',
  };

  @override
  double? get magnitude => body.representativeMagnitude;

  @override
  String get key => 'solar:${body.name}';
}
