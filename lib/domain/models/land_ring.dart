/// A land polygon ring in geographic coordinates (world map background).
class LandRing {
  const LandRing(this.lonDeg, this.latDeg);

  /// Longitudes [deg] of the ring vertices
  final List<double> lonDeg;

  /// Latitudes [deg] of the ring vertices (same length as [lonDeg])
  final List<double> latDeg;
}
