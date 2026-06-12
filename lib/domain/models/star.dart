/// Star (data model definition in docs/functional-design.md).
class Star {
  const Star({
    required this.id,
    required this.raDeg,
    required this.decDeg,
    required this.magnitude,
    required this.tileIndex,
    this.colorIndexBV,
    this.name,
  });

  /// In-catalog ID (HYG database id)
  final int id;

  /// Right ascension (RA) J2000 [deg] [0, 360)
  final double raDeg;

  /// Declination (Dec) J2000 [deg] [-90, +90]
  final double decDeg;

  /// Apparent magnitude
  final double magnitude;

  /// Spatial index tile number (precomputed at encoding time)
  final int tileIndex;

  /// B-V color index (null if missing → color falls back)
  final double? colorIndexBV;

  /// Proper name (Sirius, etc.). Mostly null
  final String? name;

  /// Display name (unnamed stars use the catalog number)
  String get displayName => name ?? 'HYG $id';

  @override
  String toString() => 'Star($displayName, mag=$magnitude)';
}
