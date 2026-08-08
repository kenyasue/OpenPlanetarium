import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/models/world_city.dart';

const _tokyo = WorldCity(
  name: 'Tokyo',
  country: 'Japan',
  latitudeDeg: 35.69,
  longitudeDeg: 139.69,
  isCapital: true,
);
const _osaka = WorldCity(
  name: 'Osaka',
  country: 'Japan',
  latitudeDeg: 34.69,
  longitudeDeg: 135.5,
  isCapital: false,
);
const _suva = WorldCity(
  name: 'Suva',
  country: 'Fiji',
  latitudeDeg: -18.13,
  longitudeDeg: 178.44,
  isCapital: true,
);

void main() {
  group('greatCircleDistanceKm', () {
    test('distance to the same point is 0', () {
      expect(greatCircleDistanceKm(35.0, 139.0, 35.0, 139.0), 0.0);
    });

    test('Tokyo-Osaka is about 400 km', () {
      final d = greatCircleDistanceKm(35.6812, 139.7671, 34.6937, 135.5023);
      // Reference value ~397 km (great-circle). Allow spherical-model slack.
      expect(d, closeTo(400, 10));
    });

    test('antipodal points are half the Earth circumference', () {
      final d = greatCircleDistanceKm(0, 0, 0, 180);
      // π × 6371 km ≈ 20015 km
      expect(d, closeTo(20015, 5));
    });
  });

  group('nearestCity', () {
    const cities = [_tokyo, _osaka, _suva];

    test('returns null for an empty list', () {
      expect(nearestCity(const [], 35, 139), isNull);
    });

    test('finds the closest city', () {
      final result = nearestCity(cities, 34.7, 135.6);
      expect(result!.city.name, 'Osaka');
      expect(result.distanceKm, lessThan(20));
    });

    test('handles the antimeridian (a point at lon -179 is near Fiji)', () {
      // -179.0° is only ~2.6° of longitude away from Suva (+178.44°) across
      // the date line; a naive |Δlon| would treat it as ~357° away
      final result = nearestCity(cities, -18.0, -179.0);
      expect(result!.city.name, 'Suva');
      expect(result.distanceKm, lessThan(300));
    });
  });

  group('WorldCity.toGeoLocation', () {
    test('carries coordinates and name', () {
      final loc = _tokyo.toGeoLocation();
      expect(loc.latitudeDeg, 35.69);
      expect(loc.longitudeDeg, 139.69);
      expect(loc.name, 'Tokyo');
    });
  });
}
