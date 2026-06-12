/// Observing location (geographic coordinates).
class GeoLocation {
  const GeoLocation({
    required this.latitudeDeg,
    required this.longitudeDeg,
    this.name,
  });

  /// Latitude [deg], north positive
  final double latitudeDeg;

  /// Longitude [deg], east positive
  final double longitudeDeg;

  /// Display name (manually set locations, etc.)
  final String? name;

  /// Default observing location (Tokyo Station). Fallback when location services are unavailable.
  static const tokyo = GeoLocation(
    latitudeDeg: 35.6812,
    longitudeDeg: 139.7671,
    name: 'Tokyo',
  );

  @override
  bool operator ==(Object other) =>
      other is GeoLocation &&
      other.latitudeDeg == latitudeDeg &&
      other.longitudeDeg == longitudeDeg;

  @override
  int get hashCode => Object.hash(latitudeDeg, longitudeDeg);

  @override
  String toString() => 'GeoLocation($latitudeDeg, $longitudeDeg, $name)';
}

/// Source of the location information
enum LocationSource {
  /// Device location such as GPS
  gps,

  /// Manually set by the user
  manual,

  /// Default value when acquisition fails
  fallback,
}

/// Observing location with its source
class LocationFix {
  const LocationFix({required this.location, required this.source});

  final GeoLocation location;
  final LocationSource source;
}
