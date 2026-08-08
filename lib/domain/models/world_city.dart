import 'dart:math';

import 'geo_location.dart';

/// A major city usable as an observing-location preset (bundled catalog).
class WorldCity {
  const WorldCity({
    required this.name,
    required this.country,
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.isCapital,
  });

  /// City name (English)
  final String name;

  /// Country name (English)
  final String country;

  /// Latitude [deg], north positive
  final double latitudeDeg;

  /// Longitude [deg], east positive
  final double longitudeDeg;

  /// Whether this is a national capital
  final bool isCapital;

  /// Converts to the app-wide observing-location model.
  GeoLocation toGeoLocation() => GeoLocation(
    latitudeDeg: latitudeDeg,
    longitudeDeg: longitudeDeg,
    name: name,
  );

  @override
  String toString() => 'WorldCity($name, $country)';
}

/// Result of a nearest-city search.
class NearestCityResult {
  const NearestCityResult({required this.city, required this.distanceKm});

  final WorldCity city;

  /// Great-circle distance from the query point [km]
  final double distanceKm;
}

/// Great-circle distance between two points on Earth [km].
///
/// Haversine formula with a spherical Earth of mean radius 6371 km
/// (IUGG mean radius). Accuracy (~0.5%) is ample for snapping a map tap
/// to the nearest city.
double greatCircleDistanceKm(
  double lat1Deg,
  double lon1Deg,
  double lat2Deg,
  double lon2Deg,
) {
  const earthRadiusKm = 6371.0;
  const degToRad = pi / 180.0;
  final dLat = (lat2Deg - lat1Deg) * degToRad;
  final dLon = (lon2Deg - lon1Deg) * degToRad;
  final a =
      pow(sin(dLat / 2), 2) +
      cos(lat1Deg * degToRad) * cos(lat2Deg * degToRad) * pow(sin(dLon / 2), 2);
  return 2 * earthRadiusKm * asin(min(1.0, sqrt(a)));
}

/// Finds the city closest to ([latDeg], [lonDeg]), or null if [cities] is
/// empty. Longitude wrap-around (±180°) is handled by the spherical distance.
NearestCityResult? nearestCity(
  List<WorldCity> cities,
  double latDeg,
  double lonDeg,
) {
  NearestCityResult? best;
  for (final city in cities) {
    final d = greatCircleDistanceKm(
      latDeg,
      lonDeg,
      city.latitudeDeg,
      city.longitudeDeg,
    );
    if (best == null || d < best.distanceKm) {
      best = NearestCityResult(city: city, distanceKm: d);
    }
  }
  return best;
}
