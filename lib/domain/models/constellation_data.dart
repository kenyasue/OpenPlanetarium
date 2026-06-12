import 'sky_point.dart';

/// Display language for constellation names (F6)
enum NameLanguage { japanese, english, latin }

/// Constellation (lines, names, label position).
class ConstellationData {
  const ConstellationData({
    required this.iau,
    required this.nameLatin,
    required this.nameEn,
    required this.nameJa,
    required this.labelAnchor,
    required this.lines,
  });

  /// IAU abbreviation ('Ori', etc.)
  final String iau;

  final String nameLatin;
  final String nameEn;
  final String nameJa;

  /// Anchor position for the constellation name label (mean direction of constellation line vertices)
  final SkyPoint labelAnchor;

  /// Polylines of the constellation lines (J2000 coordinates)
  final List<List<SkyPoint>> lines;

  String nameIn(NameLanguage language) => switch (language) {
    NameLanguage.japanese => nameJa,
    NameLanguage.english => nameEn,
    NameLanguage.latin => nameLatin,
  };
}

/// Complete constellation data for the whole sky.
class ConstellationSet {
  const ConstellationSet({
    required this.constellations,
    required this.boundaries,
  });

  final List<ConstellationData> constellations;

  /// Polylines of IAU boundaries (shared across the whole sky; not attributed to individual constellations)
  final List<List<SkyPoint>> boundaries;
}
