import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/models/world_map_projection.dart';

void main() {
  group('equirectangular projection', () {
    test('map corners', () {
      expect(lonToMapX(-180), 0.0);
      expect(lonToMapX(180), 1.0);
      expect(latToMapY(90), 0.0);
      expect(latToMapY(-90), 1.0);
    });

    test('origin (0,0) maps to the center', () {
      expect(lonToMapX(0), 0.5);
      expect(latToMapY(0), 0.5);
    });

    test('round-trips lon/lat', () {
      for (var lon = -180.0; lon <= 180.0; lon += 30.0) {
        expect(mapXToLon(lonToMapX(lon)), closeTo(lon, 1e-9));
      }
      for (var lat = -90.0; lat <= 90.0; lat += 15.0) {
        expect(mapYToLat(latToMapY(lat)), closeTo(lat, 1e-9));
      }
    });

    test('isOnMap rejects letterbox taps', () {
      expect(isOnMap(0.5, 0.5), isTrue);
      expect(isOnMap(0, 1), isTrue);
      expect(isOnMap(-0.01, 0.5), isFalse);
      expect(isOnMap(0.5, 1.01), isFalse);
    });
  });
}
