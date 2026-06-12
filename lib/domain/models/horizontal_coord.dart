/// Horizontal coordinates.
///
/// Azimuth is north=0°, measured eastward (glossary convention; differs by +180° from Meeus's south-based convention).
class HorizontalCoord {
  const HorizontalCoord({required this.altDeg, required this.azDeg});

  /// Altitude [deg] horizon=0, zenith=+90
  final double altDeg;

  /// Azimuth [deg] north=0, east=90, south=180, west=270
  final double azDeg;

  @override
  bool operator ==(Object other) =>
      other is HorizontalCoord &&
      other.altDeg == altDeg &&
      other.azDeg == azDeg;

  @override
  int get hashCode => Object.hash(altDeg, azDeg);

  @override
  String toString() =>
      'HorizontalCoord(alt: ${altDeg.toStringAsFixed(4)}°, az: ${azDeg.toStringAsFixed(4)}°)';
}
