// Natural Earth → world map assets (assets/map/) conversion script
//
// Usage:
//   1. Place the following in tool/catalog_converter/cache/
//      - ne_110m_land.geojson
//      - ne_50m_populated_places_simple.geojson
//        (https://github.com/nvkelso/natural-earth-vector geojson/, public domain)
//   2. dart run tool/catalog_converter/convert_worldmap.dart
//
// Outputs:
//   - assets/map/world_land.json   : land polygon rings [[[lon,lat],...],...]
//   - assets/map/world_cities.json : cities [[name, country, lat, lon, capital], ...]
import 'dart:convert';
import 'dart:io';

void main() {
  _convertLand();
  _convertCities();
}

/// Rounds to 2 decimal places (~1.1 km resolution — sufficient for a
/// dialog-sized world map and keeps the asset small).
double _round2(num v) => (v * 100).round() / 100;

void _convertLand() {
  final geo =
      jsonDecode(
            File(
              'tool/catalog_converter/cache/ne_110m_land.geojson',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  final rings = <List<List<double>>>[];
  for (final feature in geo['features'] as List) {
    final geometry = (feature as Map)['geometry'] as Map;
    final type = geometry['type'] as String;
    // Both Polygon and MultiPolygon appear in the dataset. Only outer rings
    // are kept: inner rings (lakes) are invisible at this display size.
    final polygons = type == 'Polygon'
        ? [geometry['coordinates'] as List]
        : (geometry['coordinates'] as List).cast<List>();
    for (final polygon in polygons) {
      final outer = polygon.first as List;
      final ring = <List<double>>[];
      for (final point in outer) {
        final lon = _round2((point as List)[0] as num);
        final lat = _round2(point[1] as num);
        // Skip consecutive duplicates created by coordinate rounding
        if (ring.isNotEmpty && ring.last[0] == lon && ring.last[1] == lat) {
          continue;
        }
        ring.add([lon, lat]);
      }
      if (ring.length >= 3) rings.add(ring);
    }
  }

  final out = File('assets/map/world_land.json')
    ..writeAsStringSync(jsonEncode(rings));
  final points = rings.fold<int>(0, (sum, r) => sum + r.length);
  stdout.writeln(
    'world_land.json: ${rings.length} rings, $points points, '
    '${out.lengthSync()} bytes',
  );
}

void _convertCities() {
  final geo =
      jsonDecode(
            File(
              'tool/catalog_converter/cache/ne_50m_populated_places_simple.geojson',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  // [name, country, lat, lon, capital(0/1)] — array form keeps the asset small
  final cities = <List<dynamic>>[];
  var capitals = 0;
  for (final feature in geo['features'] as List) {
    final props = (feature as Map)['properties'] as Map;
    final name = props['name'] as String?;
    final country = props['adm0name'] as String?;
    final lat = props['latitude'] as num?;
    final lon = props['longitude'] as num?;
    if (name == null || country == null || lat == null || lon == null) {
      continue;
    }
    // adm0cap = 1 marks national capitals (featurecla 'Admin-0 capital')
    final isCapital = (props['adm0cap'] as num? ?? 0) == 1;
    if (isCapital) capitals++;
    cities.add([name, country, _round2(lat), _round2(lon), isCapital ? 1 : 0]);
  }

  // Sort by country then name so the pickers get stable, readable ordering
  cities.sort((a, b) {
    final byCountry = (a[1] as String).compareTo(b[1] as String);
    return byCountry != 0
        ? byCountry
        : (a[0] as String).compareTo(b[0] as String);
  });

  final out = File('assets/map/world_cities.json')
    ..writeAsStringSync(jsonEncode(cities));
  stdout.writeln(
    'world_cities.json: ${cities.length} cities ($capitals capitals), '
    '${out.lengthSync()} bytes',
  );
}
