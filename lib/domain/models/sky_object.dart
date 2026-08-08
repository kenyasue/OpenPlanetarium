import 'constellation_data.dart';
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

  /// Display name in [language] (star and catalog names are
  /// language-neutral and shared across languages)
  String displayNameIn(NameLanguage language);

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
  String displayNameIn(NameLanguage language) => star.displayName;

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
  String displayNameIn(NameLanguage language) => dso.displayNameIn(language);

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
  String displayNameIn(NameLanguage language) => body.nameIn(language);

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
