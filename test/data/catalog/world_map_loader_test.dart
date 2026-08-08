import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/catalog/world_map_loader.dart';

void main() {
  group('WorldMapLoader.loadCities', () {
    test('parses the array form including the capital flag', () async {
      final loader = WorldMapLoader(
        loader: (key) async =>
            '[["Tokyo","Japan",35.69,139.69,1],'
            '["Osaka","Japan",34.69,135.5,0]]',
      );
      final cities = await loader.loadCities();
      expect(cities, hasLength(2));
      expect(cities[0].name, 'Tokyo');
      expect(cities[0].country, 'Japan');
      expect(cities[0].latitudeDeg, 35.69);
      expect(cities[0].longitudeDeg, 139.69);
      expect(cities[0].isCapital, isTrue);
      expect(cities[1].isCapital, isFalse);
    });

    test('parses integer coordinates as double', () async {
      final loader = WorldMapLoader(
        loader: (key) async => '[["Quito","Ecuador",0,-78,1]]',
      );
      final cities = await loader.loadCities();
      expect(cities.single.latitudeDeg, 0.0);
      expect(cities.single.longitudeDeg, -78.0);
    });
  });

  group('WorldMapLoader.loadLandRings', () {
    test('parses polygon rings into parallel lon/lat lists', () async {
      final loader = WorldMapLoader(
        loader: (key) async =>
            '[[[0,0],[10,0],[10,10]],[[-5,-5],[5,-5],[0,5]]]',
      );
      final rings = await loader.loadLandRings();
      expect(rings, hasLength(2));
      expect(rings[0].lonDeg, [0.0, 10.0, 10.0]);
      expect(rings[0].latDeg, [0.0, 0.0, 10.0]);
      expect(rings[1].lonDeg.length, rings[1].latDeg.length);
    });
  });

  group('bundled assets', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('world_cities.json loads with 1000+ cities and capitals', () async {
      final cities = await WorldMapLoader().loadCities();
      expect(cities.length, greaterThanOrEqualTo(1000));
      expect(cities.where((c) => c.isCapital).length, greaterThan(150));
      // Every coordinate must be in range
      for (final c in cities) {
        expect(c.latitudeDeg, inInclusiveRange(-90, 90));
        expect(c.longitudeDeg, inInclusiveRange(-180, 180));
      }
    });

    test('world_land.json loads with plausible ring data', () async {
      final rings = await WorldMapLoader().loadLandRings();
      expect(rings.length, greaterThan(50));
      for (final ring in rings) {
        expect(ring.lonDeg.length, ring.latDeg.length);
        expect(ring.lonDeg.length, greaterThanOrEqualTo(3));
      }
    });
  });
}
