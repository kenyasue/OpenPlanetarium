import 'dart:math' as math;

/// Position on the celestial sphere (equatorial coordinates, epoch J2000).
///
/// [raDeg] is right ascension (RA) [0, 360); [decDeg] is declination (Dec) [-90, +90].
class SkyPoint {
  const SkyPoint._(this.raDeg, this.decDeg);

  /// Creates with normalization. RA wraps to [0, 360); Dec is clamped to [-90, +90].
  factory SkyPoint(double raDeg, double decDeg) =>
      SkyPoint._(normalizeRa(raDeg), decDeg.clamp(-90.0, 90.0));

  /// Right ascension (RA) [deg] [0, 360)
  final double raDeg;

  /// Declination (Dec) [deg] [-90, +90]
  final double decDeg;

  /// Normalizes RA to [0, 360)
  static double normalizeRa(double raDeg) {
    final r = raDeg % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  /// Angular distance between two points [deg] (spherical law of cosines)
  double angularDistanceTo(SkyPoint other) {
    const d2r = math.pi / 180.0;
    final cosD =
        math.sin(decDeg * d2r) * math.sin(other.decDeg * d2r) +
        math.cos(decDeg * d2r) *
            math.cos(other.decDeg * d2r) *
            math.cos((raDeg - other.raDeg) * d2r);
    return math.acos(cosD.clamp(-1.0, 1.0)) / d2r;
  }

  @override
  bool operator ==(Object other) =>
      other is SkyPoint && other.raDeg == raDeg && other.decDeg == decDeg;

  @override
  int get hashCode => Object.hash(raDeg, decDeg);

  @override
  String toString() =>
      'SkyPoint(ra: ${raDeg.toStringAsFixed(4)}°, dec: ${decDeg.toStringAsFixed(4)}°)';
}
